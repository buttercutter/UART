module test_UART(clk, reset, serial_out, enable, i_data, o_busy, received_data, data_is_valid, rx_error);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
parameter PARITY_TYPE = 0;  // 0 = even parity, 1 = odd parity

input clk;
input reset;

// transmitter signals
input enable;
input [(INPUT_DATA_WIDTH-1):0] i_data;
output o_busy;
output serial_out;

`ifdef FORMAL
wire baud_clk;
wire [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;  // Tx internal PISO
`endif

// receiver signals
wire serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
wire [($clog2(NUMBER_OF_BITS)-1) : 0] state;  // for Rx
`endif

UART uart(.clk(clk), .reset(reset), .serial_out(serial_out), .enable(enable), .i_data(i_data), .o_busy(o_busy), .serial_in(serial_in), .received_data(received_data), .data_is_valid(data_is_valid), .rx_error(rx_error)
`ifdef FORMAL
	, .state(state), .baud_clk(baud_clk), .shift_reg(shift_reg)
`endif
);

assign serial_in = serial_out; // tx goes to rx, so that we know that our UART works at least in terms of logic-wise

`ifdef FORMAL

localparam Rx_IDLE       = 4'b0000;
localparam Rx_START_BIT  = 4'b0001;
localparam Rx_DATA_BIT_0 = 4'b0010;
localparam Rx_DATA_BIT_1 = 4'b0011;
localparam Rx_DATA_BIT_2 = 4'b0100;
localparam Rx_DATA_BIT_3 = 4'b0101;
localparam Rx_DATA_BIT_4 = 4'b0110;
localparam Rx_DATA_BIT_5 = 4'b0111;
localparam Rx_DATA_BIT_6 = 4'b1000;
localparam Rx_DATA_BIT_7 = 4'b1001;
localparam Rx_PARITY_BIT = 4'b1010;
localparam Rx_STOP_BIT   = 4'b1011;

localparam NUMBER_OF_RX_SYNCHRONIZERS = 3; // three FF synhronizers for clock domain crossing
localparam CLOCKS_PER_BIT = 8;

reg had_been_enabled;   // a signal to latch 'enable'
reg[($clog2(NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS)-1) : 0] cnt;  // to track the number of clock cycles incurred between assertion of 'transmission_had_started' signal from Tx and assertion of 'data_is_valid' signal from Rx

reg transmission_had_started; 

initial had_been_enabled = 0;  
initial cnt = 0;
initial transmission_had_started = 0;

always @(posedge clk)
begin
	if(reset) begin
		transmission_had_started <= 0;
	end
		
	else begin
		if(baud_clk)
			transmission_had_started <= had_been_enabled;  // Tx only operates at every rising edge of 'baud_clk' (Tx's clock)
	end
end

reg had_just_reset;
initial had_just_reset = 0;

wire [($clog2(NUMBER_OF_BITS-1)-1) : 0] stop_bit_location;
assign stop_bit_location = (cnt < NUMBER_OF_BITS) ? (NUMBER_OF_BITS - 1 - cnt) : 0;  // if not during UART transmission, set to zero as default for no specific reason

wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location_plus_one = stop_bit_location + 1;

always @(posedge clk)
begin
	assert(cnt < NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1);
	assert(stop_bit_location < NUMBER_OF_BITS);
end

always @(posedge clk)
begin
    if(reset) begin
        cnt <= 1;
    	had_been_enabled <= 0;
    end
    
    else begin
    
        if(enable && (!had_been_enabled)) begin
    	    cnt <= 1;
    	    assert(cnt == 1);            
    	    had_been_enabled <= 1;
    	    assert(state == Rx_IDLE);
    	    assert(data_is_valid == 0);
    	    
    	    if(had_just_reset) begin
    	    	assert(&shift_reg == 1);
    	    end
    	    
	    	assert(serial_out == 1);
	    	assert(o_busy == 0);
        end

    	else if(transmission_had_started) begin
    	
    		if(baud_clk) begin
	        	cnt <= cnt + 1;
	        end

			if(cnt == 0) begin // start of UART transmission
				assert(state < Rx_STOP_BIT);
				assert(data_is_valid == 0);
				assert(shift_reg == {1'b0, 1'b1, (^i_data), i_data});  // ^data is even parity bit
				assert(serial_out == 0);   // start bit
				assert(o_busy == 1);
			end
			
			else if((cnt > 0) && (cnt < (NUMBER_OF_BITS-1))) begin  // during UART transmission
				assert(state < Rx_STOP_BIT);
				assert(data_is_valid == 0);
				assert(shift_reg[stop_bit_location_plus_one] == 1'b0);
				assert(shift_reg[stop_bit_location] == 1'b1);
				assert(o_busy == 1);				
			end

			else if(cnt == (NUMBER_OF_BITS - 1)) begin // end of UART transmission
				assert(state < Rx_STOP_BIT);
				assert(data_is_valid == 0);
				assert(serial_out == 1);   // stop bit
				assert(o_busy == 1);
			end
			
			else begin // if(cnt > ((NUMBER_OF_BITS + 1)*CLOCKS_PER_BIT)) begin  // UART Rx internal states
				
				if(state == Rx_START_BIT) begin
					assert(data_is_valid == 0);
					assert(serial_in == 0);
					assert(o_busy == 1);
					assert(cnt == (NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1)*CLOCKS_PER_BIT);					
				end

				else if((state > Rx_START_BIT) && (state < Rx_PARITY_BIT)) begin // data bits
					assert(data_is_valid == 1);
					assert(o_busy == 1);
					assert(cnt == (NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + (state - Rx_START_BIT) +  1)*CLOCKS_PER_BIT);					
				end
	
				else if(state == Rx_PARITY_BIT) begin
					assert(data_is_valid == 0);
					assert(serial_in == ^i_data);
					assert(o_busy == 1);
					assert(cnt == (NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + state +  1)*CLOCKS_PER_BIT);					
				end
						
				else begin // if(state == Rx_STOP_BIT) begin  // end of one UART transaction (both transmitting and receiving)
					assert(state == Rx_STOP_BIT);
					assert(data_is_valid == 1);
					assert(serial_in == 1);
					assert(o_busy == 0);
					assert(cnt == (NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1)*CLOCKS_PER_BIT);
					cnt <= 0;
					had_been_enabled <= 0;
				end
				/*
				else begin
					assert(state == Rx_IDLE);
					assert(data_is_valid == 0);
					assert(serial_in == 1); 
				end*/
			end
    	end
    	    
    	else begin  // UART Tx and Rx are idling, still waiting for baud_clk
    	    cnt <= 1;
    	    assert(cnt == 1);
    	    assert(state == Rx_IDLE);
    	    assert(data_is_valid == 0);
    	    assert(serial_out == 1);
    	    
    	    if(had_been_enabled)
	    	    assert(o_busy == 1);
	    	else
	    		assert(o_busy == 0);
    	end
    end
end

always @(posedge clk)
begin
    if(reset) begin
    	had_just_reset <= 1;
		//assert();
    end

    else begin
    	had_just_reset <= 0;
    
    	if(had_been_enabled) begin
	    	assert(o_busy == 1);
    	end

    	else begin
    	    assert(o_busy == 0);
	    	assert(serial_out == 1);
    	end
    end
end

always @(posedge clk)
begin
    if(reset | o_busy) begin
        assume(enable == 0);
    end
	
	if(enable | had_been_enabled) begin
		assume($past(i_data) == i_data);
	end
end

always @(posedge clk)
begin
    assert(!rx_error);   // no parity error

    if(data_is_valid) begin   // state == Rx_STOP_BIT
        assert(received_data == i_data);
        assert(cnt < NUMBER_OF_BITS*CLOCKS_PER_BIT);
    end
end

`endif

endmodule

`default_nettype none

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
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + PARITY_ENABLED + 2;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
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

reg had_been_enabled;   // a signal to latch Tx 'enable' signal
reg[($clog2((2*NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1)*CLOCKS_PER_BIT)-1) : 0] cnt;  // to track the number of clock cycles incurred between assertion of 'transmission_had_started' signal from Tx and assertion of 'data_is_valid' signal from Rx

reg transmission_had_started; 
reg first_clock_passed;

initial begin
	had_been_enabled = 0;  
	cnt = 0;
	transmission_had_started = 0;
	first_clock_passed = 0;
end

always @(posedge clk)
begin
	first_clock_passed <= 1;
end

wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location_plus_one = stop_bit_location + 1;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location_plus_two = stop_bit_location_plus_one + 1;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] parity_bit_location = stop_bit_location - 1;

assign stop_bit_location = (cnt < NUMBER_OF_BITS) ? (NUMBER_OF_BITS - 1 - cnt) : 0;  // if not during UART transmission, set to zero as default for no specific reason


always @(posedge clk)
begin
	assert(cnt < NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1);
	assert(stop_bit_location < NUMBER_OF_BITS);
	
	if(first_clock_passed) begin
		if($past(reset) == 0) begin 
			if(cnt < NUMBER_OF_BITS) begin
				assert(stop_bit_location == (NUMBER_OF_BITS - 1 - cnt));
			end
		end

		if($past(first_clock_passed) == 0) begin
			assert($past(&shift_reg) == 1);
		end
	end
end

always @(posedge clk)
begin
    if(reset) begin
        cnt <= 0;
		transmission_had_started <= 0;
    end

	else if(baud_clk) begin
		if(transmission_had_started | had_been_enabled) begin
			cnt <= cnt + 1;
		end
		transmission_had_started <= had_been_enabled;  // Tx only operates at every rising edge of 'baud_clk' (Tx's clock)
	end   
	
	else begin
	
        if((enable && (!had_been_enabled)) || ((transmission_had_started) && (cnt == (NUMBER_OF_BITS-1)))) begin
    	    cnt <= 0;  
			transmission_had_started <= 0;
    	end
    end
    
    if(first_clock_passed) begin
    	if(($past(had_been_enabled)) && ($past(baud_clk)) && (!reset) && !($past(reset)) && !($past(transmission_had_started))) begin
	   		assert(transmission_had_started);
	   	end
    end
end

wire [($clog2(INPUT_DATA_WIDTH + NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS) - 1) : 0] i_data_index [(INPUT_DATA_WIDTH-1) : 0];
wire [(INPUT_DATA_WIDTH-1) : 0] Tx_shift_reg_assertion;

wire tx_shift_reg_contains_data_bits = ((transmission_had_started) && (cnt >= 1) && (cnt < (INPUT_DATA_WIDTH + 1)));  // shift_reg is one clock cycle before the data bits get registered to serial_out
	
// for induction purpose, checks whether the Tx PISO shift_reg is shifting out all 'INPUT_DATA_WIDTH' data bits correctly

generate
	genvar Tx_shift_reg_index;	

	for(Tx_shift_reg_index=(INPUT_DATA_WIDTH - 1); Tx_shift_reg_index >= 0; Tx_shift_reg_index=Tx_shift_reg_index-1) 
	begin : assert_Tx_shift_reg_label

		// predicate logic simplification using deMorgan Therorem
		// if (A and B) assert(C); is the same as assert((!A) || (!B) || C);  

		assign i_data_index[Tx_shift_reg_index] = (Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt)) ? (Tx_shift_reg_index + cnt - 1) : (INPUT_DATA_WIDTH - 1);

		assign Tx_shift_reg_assertion[Tx_shift_reg_index] = (!(Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt))) || (!tx_shift_reg_contains_data_bits) || (shift_reg[Tx_shift_reg_index] == i_data[i_data_index[Tx_shift_reg_index]]);    
		
		always @(posedge clk) begin 
			assert(Tx_shift_reg_assertion[Tx_shift_reg_index]);
		end
		
		/*
		always @(*) begin
			if(Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt)) begin
			
				i_data_index[Tx_shift_reg_index] = Tx_shift_reg_index + cnt + 1;	

				if(tx_shift_reg_contains_data_bits) begin
					Tx_shift_reg_assertion[Tx_shift_reg_index] = (shift_reg[Tx_shift_reg_index] == i_data[i_data_index[Tx_shift_reg_index]]);
					
					assert(Tx_shift_reg_assertion[Tx_shift_reg_index]);
				end
			end
		end*/
	end
endgenerate
							
always @(posedge clk)
begin
    if(reset) begin
    	had_been_enabled <= 0;
    end   

    else begin
 
        if(enable && (!had_been_enabled)) begin           
    	    had_been_enabled <= 1;
    	    assert(cnt == 0);  // transmission had not started
    	    assert(data_is_valid == 0);
    	    
    	    if($past(reset)) begin
    	    	assert(&shift_reg == 1);
    	    end
    	    
	    	assert(serial_out == 1);
	    	assert(o_busy == 0);
        end

		else if((!transmission_had_started) && (had_been_enabled)) begin // waiting for the start of UART transmission
			assert(state == Rx_IDLE);
			
			assert(serial_out == 1);
			assert(data_is_valid == 0);
			assert(shift_reg == {1'b1, (^i_data), i_data, 1'b0});  // ^data is even parity bit
			assert(o_busy == 1);  
		end

		else if(transmission_had_started) begin
			if(cnt == 1) begin
				assert(serial_out == 0);  // start bit
				assert(shift_reg == {1'b0, 1'b1, (^i_data), i_data});
				assert(o_busy == 1);
			end
			
			else if((cnt > 1) && (cnt < (INPUT_DATA_WIDTH + PARITY_ENABLED + 1))) begin  // during UART data bits transmission
				
				assert((state + NUMBER_OF_RX_SYNCHRONIZERS) < Rx_PARITY_BIT);					
				assert((state + NUMBER_OF_RX_SYNCHRONIZERS) >= Rx_DATA_BIT_0);
								
				assert(data_is_valid == 0);					
				assert(o_busy == 1);				
			end
			
			else if(cnt <= (INPUT_DATA_WIDTH + PARITY_ENABLED + 1)) begin  // during UART parity bit transmission
			
				assert((state + NUMBER_OF_RX_SYNCHRONIZERS) <= Rx_PARITY_BIT);

				assert(serial_out == (^i_data));
				assert(shift_reg == 1);
				assert(data_is_valid == 0);					
				assert(o_busy == 1);				
			end
			
			else if(cnt == NUMBER_OF_BITS) begin  // UART stop bit transmission
				assert((state + NUMBER_OF_RX_SYNCHRONIZERS) == Rx_STOP_BIT);
				
				assert(serial_out == 1); // stop bit
				assert(shift_reg == 0);  
				assert(o_busy == 1);
			end

			else if(cnt == NUMBER_OF_BITS + 1) begin // end of UART transmission
				had_been_enabled <= 0;
			
				assert((state + NUMBER_OF_RX_SYNCHRONIZERS) == Rx_IDLE);
				assert(data_is_valid == 0);
				assert(shift_reg == 0);
				assert(serial_out == 1);   // default idle bit
				
				if($past(shift_reg) == 0) begin
					assert(!o_busy);
				end
			end
			
			else begin // if(cnt > (NUMBER_OF_BITS + 1)) begin  // UART Rx internal states
				
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
					//assert(shift_reg == );				
				end
						
				else begin // if(state == Rx_STOP_BIT) begin  // end of one UART transaction (both transmitting and receiving)
					assert(state == Rx_STOP_BIT);
					assert(data_is_valid == 1);
					assert(serial_in == 1);
					assert(o_busy == 0);
					assert(cnt == (NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS + 1)*CLOCKS_PER_BIT);
				end
				/*
				else begin
					assert(state == Rx_IDLE);
					assert(data_is_valid == 0);
					assert(serial_in == 1); 
				end*/
			end
    	end
    	    
    	else begin  // UART Tx is idling, still waiting for ((next enable signal) && (baud_clk))
    	    assert(cnt == 0);
    	    assert(data_is_valid == 0);
    	    assert(serial_out == 1);
    	    assert(state == Rx_IDLE);
    	    
    	    if(!had_been_enabled) begin
				if(first_clock_passed && ($past(cnt) == (NUMBER_OF_BITS - 1))) begin  // Tx had just finished
					if($past(reset)) begin
						assert(&shift_reg == 1);
					end					

					else begin
						assert(shift_reg == 0);
					end
				end

				else if(first_clock_passed && ($past(shift_reg) == 0)) begin  // Tx is waiting to be enabled again after a transmission
					if($past(reset)) begin
						assert(&shift_reg == 1);
					end
					
					else begin
						assert(shift_reg == 0);
					end
				end

				else begin  // Tx is waiting to be enabled for the first time
					assert(&shift_reg == 1);
				end
    	    end
    	end
    end
end

always @(posedge clk)
begin	
	if(!$past(reset)) begin
		if((had_been_enabled) && (!$past(had_been_enabled))) begin  // Tx starts transmission now
			assert(!$past(o_busy));
			assert(o_busy);
		end

		else if((had_been_enabled) && ($past(had_been_enabled))) begin  // Tx is in the midst of transmission
			assert($past(o_busy));
			
			if($past(shift_reg) == 0) begin
				assert(!o_busy);
			end
		end

		else if((!had_been_enabled) && ($past(had_been_enabled))) begin  // Tx finished transmission
			assert(serial_out == 1);
		
			if(first_clock_passed) begin
		    	assert(($past(o_busy)) && (!o_busy));
			
				if($past(enable)) begin
					assert(o_busy);
				end
			end
		end
		
		else begin  // Tx had not been enabled yet
			assert(!o_busy);
			assert(serial_out == 1);
		end
	end
end

always @(posedge clk)
begin
    if(reset | o_busy) begin
        assume(enable == 0);
    end
	
	if((!data_is_valid) || ((!$past(data_is_valid)) && (data_is_valid)) || (state == Rx_STOP_BIT) || ((data_is_valid) && ($past(state) == Rx_STOP_BIT))) begin
		assume($past(i_data) == i_data);  // must not change until Rx and Tx data comparison is done
	end
end

always @(posedge clk)
begin
    assert(!rx_error);   // no parity error

    if(data_is_valid) begin   // state == Rx_STOP_BIT
        assert(received_data == i_data);
        assert(cnt < NUMBER_OF_BITS*CLOCKS_PER_BIT);
    end

	if((!$past(reset)) && (state <= Rx_STOP_BIT) && (first_clock_passed) && (transmission_had_started) && ($past(transmission_had_started)) && ($past(baud_clk))) begin
		assert(cnt - $past(cnt) == 1);
	end
end

`endif

endmodule

module test_UART(clk, reset, serial_out, enable, i_data, o_busy, received_data, data_is_valid, rx_error);

parameter INPUT_DATA_WIDTH = 8;

input clk;
input reset;

// transmitter signals
input enable;
input [(INPUT_DATA_WIDTH-1):0] i_data;
output o_busy;
output serial_out;

// receiver signals
wire serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
wire [3:0] state;
`endif

UART uart(.clk(clk), .reset(reset), .serial_out(serial_out), .enable(enable), .i_data(i_data), .o_busy(o_busy), .serial_in(serial_in), .received_data(received_data), .data_is_valid(data_is_valid), .rx_error(rx_error)
`ifdef FORMAL
	, .state(state)
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

localparam NUMBER_OF_STATES = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
localparam NUMBER_OF_RX_SYNCHRONIZERS = 3; // three FF synhronizers for clock domain crossing
localparam CLOCKS_PER_STATE = 8;

reg has_been_enabled;   // a signal to latch 'enable'
reg[($clog2((NUMBER_OF_STATES + NUMBER_OF_RX_SYNCHRONIZERS)*CLOCKS_PER_STATE)-1) : 0] cnt;  // to track the number of clock cycles incurred between assertion of 'enable' signal from Tx and assertion of 'data_is_valid' signal from Rx

initial has_been_enabled = 0;  
initial cnt = 0;

always @(posedge clk)
begin
    if(reset) begin
        cnt <= 0;
    	has_been_enabled <= 0;
    end
    
    else begin
        if(enable && (!has_been_enabled)) begin
    	    cnt <= 0;
    	    assert(cnt == 0);            
    	    has_been_enabled <= 1;
	    	assert(serial_out == 1);
        end

    	else if(has_been_enabled) begin
	        cnt <= cnt + 1;

			if(cnt == (1*CLOCKS_PER_STATE)) begin // start of UART transmission
				assert(data_is_valid == 0);
				assert(serial_out == 0);   // start bit
			end

			else if(cnt == (NUMBER_OF_STATES*CLOCKS_PER_STATE)) begin // end of UART transmission
				assert(data_is_valid == 0);
				assert(serial_out == 1);   // stop bit
			end
			
			else if(cnt == (NUMBER_OF_STATES + NUMBER_OF_RX_SYNCHRONIZERS)*CLOCKS_PER_STATE) begin  // end of one UART transaction (both transmitting and receiving)
				assert(data_is_valid == 1);
				assert(serial_out == 1);
				cnt <= 0;
				has_been_enabled <= 0;
			end
			
			else begin
				assert(data_is_valid == 0);
				assert(o_busy == 1);  // busy in the midst of UART transmission
			end
    	end
    	    
    	else begin  // UART Tx and Rx are idling
    	    cnt <= 0;
    	    assert(cnt == 0);
    	end
    end
end

always @(posedge clk)
begin
    if(reset | o_busy)
        assume(enable == 0);

    else begin
    	if(has_been_enabled) begin
            assume($past(i_data) == i_data);
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
    assert(!rx_error);   // no parity error

    if(data_is_valid) begin   // state == Rx_STOP_BIT
        assert(received_data == i_data);
        assert(cnt < NUMBER_OF_STATES*CLOCKS_PER_STATE);
    end
end

`endif

endmodule

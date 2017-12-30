module test_UART(clk, reset, serial_out, enable, i_data, o_busy, received_data, data_is_valid, rx_error);

parameter INPUT_DATA_WIDTH = 8;
localparam NUMBER_OF_STATES = INPUT_DATA_WIDTH + 3;
localparam CLOCKS_PER_STATE = 8;

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

UART uart(.clk(clk), .reset(reset), .serial_out(serial_out), .enable(enable), .i_data(i_data), .o_busy(o_busy), .serial_in(serial_in), .received_data(received_data), .data_is_valid(data_is_valid), .rx_error(rx_error));

assign serial_in = serial_out; // tx goes to rx, so that we know that our UART works at least in terms of logic-wise

`ifdef FORMAL

reg has_been_enabled;
reg[$clog2(NUMBER_OF_STATES*CLOCKS_PER_STATE):0] cnt;  // to track the number of clock cycles between assertion of 'enable' signal from Tx and assertion of 'data_is_valid' signal from Rx

initial has_been_enabled = 0;
initial cnt = 0;

always @(posedge clk)
begin
    if(reset) begin
    	has_been_enabled <= 0;
		cnt <= 0;
    end
    
    else begin
        if(enable) begin
    	    cnt <= 0;
    	    assert(cnt == 0);            
    	    has_been_enabled <= 1;
	    	assert(serial_out == 1);
        end

    	if(has_been_enabled) begin
	        cnt <= cnt + 1;

			if(cnt == NUMBER_OF_STATES*CLOCKS_PER_STATE) begin  // end of one UART transaction
				assert(data_is_valid == 1);
				cnt <= 0;
				has_been_enabled <= 0;
			end
    	end
    	    
    	else begin
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

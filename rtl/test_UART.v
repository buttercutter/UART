module test_UART(clk, reset, serial_out, enable, i_data, o_busy, received_data, data_is_valid, rx_error);

parameter INPUT_DATA_WIDTH = 8;

input clk;
input reset;

// transmitter signals
input enable;
input [(INPUT_DATA_WIDTH-1):0] i_data;
output reg o_busy;
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
reg[3:0] cnt = 0;

initial has_been_enabled = 0;

always @(posedge clk)
begin
    if(enable)
	has_been_enabled <= 1;

    if(has_been_enabled) begin
	cnt <= cnt + 1;

	if(cnt == 80) begin
	    assert(data_is_valid == 1);
	    cnt <= 0;
 	    has_been_enabled <= 0;
	end
    end
end

always @(posedge clk)
begin
    if((!enable) && (data_is_valid)) begin
        assume($past(i_data) == i_data);
	assert(o_busy == 1);
    end

    if(o_busy)
        assume(enable == 0);
    else
	assert(serial_out == 1);

    if(reset)
	assert(serial_out == 1);

    assert(!rx_error);

    if(data_is_valid) 
    	assert(received_data == i_data);
end

`endif

endmodule

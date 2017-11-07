module test_UART(clk, serial_out, enable_tx, i_data, o_busy, serial_in, received_data, data_is_valid, rx_error);

input clk;

// transmitter signals
input enable_tx;
input [7:0] i_data;
output reg o_busy;
output reg serial_out;
wire start;

// receiver signals
input serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [7:0] received_data;

UART uart(.clk(clk), .serial_out(serial_out), .start(start), .i_data(i_data), .o_busy(o_busy), .serial_in(serial_in), .received_data(received_data), .data_is_valid(data_is_valid), .rx_error(rx_error));

assign serial_in = serial_out; // tx goes to rx, so that we know that our UART works at least in terms of logic-wise

`ifdef FORMAL

initial assume(clk == 0);

always @(posedge clk)
begin
    assume(start == !o_busy && enable_tx);
end

always @(posedge clk)
begin
    assert(!rx_error);

    if(data_is_valid) 
    	assert(received_data == i_data);
end

`endif

endmodule

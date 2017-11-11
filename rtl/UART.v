module UART(clk, serial_out, start, i_data, o_busy, serial_in, received_data, data_is_valid, rx_error);

input clk;

// transmitter signals
input start;
input [7:0] i_data;
output reg o_busy;
output reg serial_out;

// receiver signals
input serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [7:0] received_data;

// UART transmitter
Tx_top tx (.clk(clk), .start(start), .i_data(i_data), .o_busy(o_busy), .serial_out(serial_out));

// UART receiver
Rx_top rx (.clk(clk), .serial_in(serial_in), .received_data(received_data), .rx_error(rx_error), .data_is_valid(data_is_valid));

endmodule

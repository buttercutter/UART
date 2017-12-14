module Rx_top(clk, serial_in, received_data, rx_error, data_is_valid);  // serial input, parallel output

input clk, serial_in;
output reg rx_error;
output reg data_is_valid;
output reg [7:0] received_data;

wire data_is_available;
wire serial_in_synced;

// 3 flip-flop synchronizer
synchronizer sync (.clk(clk), .serial_in(serial_in), .serial_in_synced(serial_in_synced));

// determines when to sample data
RxUART rx (.clk(clk), .serial_in(serial_in_synced), .data_is_available(data_is_available), .data_is_valid(data_is_valid));

// handles data sampling
SIPO_shift_register SIPO (.clk(clk), .serial_in(serial_in_synced), .data_is_available(data_is_available), .received_data(received_data)); 

// even parity check
check_parity cp (.clk(clk), .serial_in(serial_in_synced), .data_is_valid(data_is_valid), .rx_error(rx_error));

endmodule

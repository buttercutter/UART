module Rx_top(clk, reset, serial_in, received_data, rx_error, data_is_valid
`ifdef FORMAL
	, state
`endif
);  // serial input, parallel output

parameter INPUT_DATA_WIDTH = 8;

input clk, reset, serial_in;
output reg rx_error;
output reg data_is_valid;
output reg [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
output [3:0] state;
`endif

wire data_is_available;
wire is_parity_stage;
wire serial_in_synced;

// 3 flip-flop synchronizer
synchronizer sync (.clk(clk), .serial_in(serial_in), .serial_in_synced(serial_in_synced));

// determines when to sample data
RxUART rx (.clk(clk), .reset(reset), .serial_in_synced(serial_in_synced), .data_is_available(data_is_available), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage), .received_data(received_data)
`ifdef FORMAL
	, .state(state)
`endif
);

// even parity check
check_parity cp (.clk(clk), .serial_in_synced(serial_in_synced), .received_data(received_data), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage), .rx_error(rx_error));

endmodule

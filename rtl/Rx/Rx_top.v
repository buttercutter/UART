module Rx_top(clk, reset, serial_in, received_data, rx_error, data_is_valid
`ifdef FORMAL
	, state, serial_in_synced, start_detected, sampling_strobe, data_is_available
`endif
);  // serial input, parallel output

parameter INPUT_DATA_WIDTH = 8;

input clk, reset, serial_in;
output rx_error;
output data_is_valid;
output [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
output [($clog2(NUMBER_OF_BITS)-1) : 0] state;
output serial_in_synced;
output start_detected;
output sampling_strobe;
output data_is_available;
`endif

wire is_parity_stage;
wire serial_in_synced;
wire sampling_strobe;

// 3 flip-flop synchronizer
synchronizer sync (.clk(clk), .reset(reset), .serial_in(serial_in), .serial_in_synced(serial_in_synced));

// determines when to sample data
RxUART rx (.clk(clk), .reset(reset), .serial_in_synced(serial_in_synced), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage), .received_data(received_data), .sampling_strobe(sampling_strobe)
`ifdef FORMAL
	, .state(state), .start_detected(start_detected), .data_is_available(data_is_available)
`endif
);

// even parity check
check_parity cp (.clk(clk), .sampling_strobe(sampling_strobe), .reset(reset), .serial_in_synced(serial_in_synced), .received_data(received_data), .is_parity_stage(is_parity_stage), .rx_error(rx_error));

endmodule

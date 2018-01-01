module RxUART(clk, reset, serial_in_synced, data_is_available, data_is_valid, is_parity_stage, received_data
`ifdef FORMAL
	, state
`endif
);  // manages UART Rx deserializer-related control signal

parameter INPUT_DATA_WIDTH = 8;

input clk, reset, serial_in_synced;
output reg data_is_available; // if asserted HIGH, it is ok to sample the serial_in
output reg data_is_valid;   // all 8-bit data have been sampled, please note that valid does not mean no data corruption
output reg is_parity_stage; // is the parity bit being received now ?
output [(INPUT_DATA_WIDTH-1):0]received_data;   // deserialized data

`ifdef FORMAL
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
output [($clog2(NUMBER_OF_BITS)-1) : 0] state;
`endif

wire start_detected; // start_bit is detected
wire sampling_strobe; // determines when to sample the incoming Rx

// synchronous detection of start bit (falling edge by UART definition)
detect_start_bit dsb (.clk(clk), .serial_in_synced(serial_in_synced), .start_detected(start_detected));

// FSM for UART Rx
rx_state rx_fsm (.clk(clk), .reset(reset), .start_detected(start_detected), .sampling_strobe(sampling_strobe), .data_is_available(data_is_available), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage)
`ifdef FORMAL
	, .state(state)
`endif
);

// handles data sampling
SIPO_shift_register SIPO (.clk(sampling_strobe), .serial_in_synced(serial_in_synced), .data_is_available(data_is_available), .received_data(received_data)); 

// computes the signal 'sampling_strobe' which is basically similar to sampling clock
sampling_strobe_generator ssg (.clk(clk), .start_detected(start_detected), .sampling_strobe(sampling_strobe));

endmodule

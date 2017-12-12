module RxUART(clk, serial_in, data_is_available, data_is_valid);  // manages UART Rx deserializer-related control signal

input clk, serial_in;
output reg data_is_available; // if asserted HIGH, it is ok to sample the serial_in
output reg data_is_valid;   // all 8-bit data have been sampled, please note that valid does not mean no data corruption

wire start_detected; // start_bit is detected
wire is_parity_stage;  // is the parity bit being received now ?
wire sampling_strobe; // determines when to sample the incoming Rx

// synchronous detection of start bit (falling edge by UART definition)
detect_start_bit dsb (.clk(clk), .serial_in(serial_in), .start_detected(start_detected));

// FSM for UART Rx
rx_state state (.clk(clk), .start_detected(start_detected), .sampling_strobe(sampling_strobe), .data_is_available(data_is_available), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage));

// computes the signal 'sampling_strobe' which is basically similar to sampling clock
sampling_strobe_generator ssg (.clk(clk), .start_detected(start_detected), .sampling_strobe(sampling_strobe));


`ifdef FORMAL
    cover property (data_is_valid);
`endif

endmodule

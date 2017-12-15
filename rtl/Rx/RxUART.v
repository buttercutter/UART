module RxUART(clk, serial_in, data_is_available, data_is_valid, is_parity_stage, received_data);  // manages UART Rx deserializer-related control signal

input clk, serial_in;
output reg data_is_available; // if asserted HIGH, it is ok to sample the serial_in
output reg data_is_valid;   // all 8-bit data have been sampled, please note that valid does not mean no data corruption
output reg is_parity_stage; // is the parity bit being received now ?
output received_data;   // deserialized data

wire start_detected; // start_bit is detected
wire sampling_strobe; // determines when to sample the incoming Rx

// synchronous detection of start bit (falling edge by UART definition)
detect_start_bit dsb (.clk(clk), .serial_in(serial_in), .start_detected(start_detected));

// FSM for UART Rx
rx_state state (.clk(clk), .start_detected(start_detected), .sampling_strobe(sampling_strobe), .data_is_available(data_is_available), .data_is_valid(data_is_valid), .is_parity_stage(is_parity_stage));

// handles data sampling
SIPO_shift_register SIPO (.clk(sampling_strobe), .serial_in(serial_in_synced), .data_is_available(data_is_available), .received_data(received_data)); 

// computes the signal 'sampling_strobe' which is basically similar to sampling clock
sampling_strobe_generator ssg (.clk(clk), .start_detected(start_detected), .sampling_strobe(sampling_strobe));


`ifdef FORMAL
    cover property (data_is_valid);
`endif

endmodule

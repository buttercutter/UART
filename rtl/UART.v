module UART(clk, reset, serial_out, enable, i_data, o_busy, serial_in, received_data, data_is_valid, rx_error
`ifdef FORMAL
	, state
`endif
);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;

input clk;
input reset; 

// transmitter signals
input enable;
input [(INPUT_DATA_WIDTH-1):0] i_data;
output reg o_busy;
output serial_out;

// receiver signals
input serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
output [3:0] state;
`endif

// UART transmitter
Tx_top tx (.clk(clk), .reset(reset), .enable(enable), .i_data(i_data), .o_busy(o_busy), .serial_out(serial_out));

// UART receiver
Rx_top rx (.clk(clk), .reset(reset), .serial_in(serial_in), .received_data(received_data), .rx_error(rx_error), .data_is_valid(data_is_valid)
`ifdef FORMAL
	, .state(state)
`endif
);

endmodule

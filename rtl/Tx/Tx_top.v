module Tx_top(clk, start, i_data, o_busy, serial_out);   // UART transmitter :  parallel input, serial output (PISO)

input clk;  // 48MHz
// input reset;  // will be added later to clear various registers

input start;     // i_data is valid, so start transmission. This 'start' signal is set to '1' for one short (1 system clock) active HIGH pulse
input[7:0] i_data; 	// parallel input

output reg serial_out;  // serial output from serializer (TxUART)
output reg o_busy;	// busy transmitting bits

wire baud_clk;  // 9600bps baudrate clock
wire enable = start;   	// starts transmission or not
wire start_tx, parity_bit;

TxUART tx (.clk(clk), .baud_clk(baud_clk), .enable(enable), .i_data(i_data), .o_busy(o_busy), .start_tx(start_tx));

baud_generator bg (.clk(clk), .baud_clk(baud_clk));	// to derive the desired baud rate of 9600bps
	
PISO_shift_register PISO (.clk(baud_clk), .valid(start_tx), .data_in({parity_bit, i_data}), .data_out(serial_out)); // .data_in({parity_bit, i_data  --> transmit LSB first

// FIFO tx_fifo (clk, reset, enqueue, dequeue, flush, i_value, almost_full, almost_empty, o_value);

assign parity_bit = ^i_data; // even parity http://www.asic-world.com/examples/verilog/parity.html

endmodule

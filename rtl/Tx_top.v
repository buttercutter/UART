module Tx_top(clk, start, i_data, serial_out);   // UART transmitter :  parallel input, serial output (PISO)

input clk;  // 48MHz
// input reset;  // will be added later to clear various registers
input start;     // i_data is valid, so start transmission. This 'start' signal is set to '1' for one baud clock cycle
input[7:0] i_data;  // parallel input
output serial_out;  // serial output from serializer (TxUART)

wire baud_out;  // 9600bps baudrate clock
wire parity_bit;  // parity bit to be appended to the transmitted data -->  {i_data, parity_bit}

TxUART tx (.clk(baud_out), .start_tx(start), .i_data(i_data), .o_busy(o_busy));

baud_generator bg (.clk(clk), .baud_out(baud_out));

shift_register PISO (.clk(baud_out), .valid(start), .tx_busy(o_busy), .data_in({parity_bit, i_data}), .data_out(serial_out)); // .data_in({parity_bit, i_data  --> transmit LSB first

// FIFO tx_fifo (clk, reset, enqueue, dequeue, flush, i_value, almost_full, almost_empty, o_value);

assign parity_bit = ^i_data; // even parity http://www.asic-world.com/examples/verilog/parity.html

endmodule

`ifdef VERILATOR
	`define SIMULATION   // for verilator simulation only
`endif

module Tx_top
(clk, 
`ifdef SIMULATION
	start, i_data,
`endif
serial_out);   // UART transmitter :  parallel input, serial output (PISO)

input clk;  // 48MHz
// input reset;  // will be added later to clear various registers

`ifdef SIMULATION
	input start;     // i_data is valid, so start transmission. This 'start' signal is set to '1' for one short (1 system clock) active HIGH pulse
	input[7:0] i_data; 	// parallel input
`else
	wire[7:0] message[0:15];
	assign message[0] = "H";
	assign message[1] = "E";
	assign message[2] = "L";
	assign message[3] = "L";
	assign message[4] = "O";
	assign message[5] = "_";
	assign message[6] = "W";
	assign message[7] = "O";
	assign message[8] = "R";
	assign message[9] = "L";
	assign message[10]= "D";
	assign message[11]= "!";
	assign message[12]= "!";
	assign message[13]= " ";
	assign message[14]= "\r";
	assign message[15]= "\n";
	
	wire[3:0] index;
	wire[7:0] i_data = message[index]; 	// equivalent ASCII code in hex radix for each character
`endif

output serial_out;  // serial output from serializer (TxUART)

wire baud_clk;  // 9600bps baudrate clock
wire enable;   	// starts transmission or not
wire o_busy;	// busy transmitting bits
wire start_tx, parity_bit;

TxUART tx (.clk(clk), .baud_clk(baud_clk), .enable(enable), .i_data(i_data), .o_busy(o_busy), .start_tx(start_tx));

baud_generator bg (.clk(clk), .baud_clk(baud_clk));	// to derive the desired baud rate of 9600bps

`ifdef SIMULATION
	assign enable = start;
`else
	enable_generator eg (.clk(clk), .en_out(enable), .index(index));   // transmission is enabled/repeated every 500ms
`endif
	
shift_register PISO (.clk(baud_clk), .valid(start_tx), .tx_busy(o_busy), .data_in({parity_bit, i_data}), .data_out(serial_out)); // .data_in({parity_bit, i_data  --> transmit LSB first

// FIFO tx_fifo (clk, reset, enqueue, dequeue, flush, i_value, almost_full, almost_empty, o_value);

assign parity_bit = ^i_data; // even parity http://www.asic-world.com/examples/verilog/parity.html

endmodule

module Tx_top(clk, reset, enable, i_data, o_busy, serial_out
`ifdef FORMAL
, baud_clk, shift_reg
`endif
);   // UART transmitter :  parallel input, serial output (PISO)

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
parameter PARITY_TYPE = 0;  // 0 = even parity, 1 = odd parity

input clk;  // 48MHz
input reset;  // added to clear various registers

input enable;     // this 'enable transmission' signal is active HIGH
input[(INPUT_DATA_WIDTH-1):0] i_data; 	// parallel input

output serial_out;  // serial output from serializer (TxUART)
output o_busy;	// busy transmitting

`ifdef FORMAL
	output baud_clk;  // default 9600bps baudrate clock
	output [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;  // Tx internal PISO
`else
	wire baud_clk;  // default 9600bps baudrate clock
`endif

wire parity_bit;

// transmitter internal working mechanism
TxUART tx (.clk(clk), .reset(reset), .baud_clk(baud_clk), .enable(enable), .i_data({parity_bit, i_data}), .o_busy(o_busy), .serial_out(serial_out)
`ifdef FORMAL
	, .shift_reg(shift_reg)
`endif
);

// baud rate generator, default = 9600bps
baud_generator bg (.clk(clk), .reset(reset), .baud_clk(baud_clk));

// FIFO tx_fifo (clk, reset, enqueue, dequeue, flush, i_value, almost_full, almost_empty, o_value);

assign parity_bit = ^i_data; // even parity http://www.asic-world.com/examples/verilog/parity.html

`ifdef FORMAL

reg first_clock_passed;

initial first_clock_passed = 0;

always @(posedge clk)
begin
	first_clock_passed <= 1;
end

always @(posedge clk)
begin
	assert(parity_bit == ^i_data);  // for induction purpose
	
	if(first_clock_passed) begin
		if($past(i_data) == i_data) begin
			assert($past(parity_bit) == parity_bit);  // for induction purpose
		end
	end
end

`endif

endmodule

module PISO_shift_register(clk, valid, data_in, data_out);   // PISO shift register specificaly for UART Tx

input clk, valid;	// clock, data is valid, tx is not in idle state
input [8:0] data_in;   // parallel input, 8-bits data + 1-bit parity
output data_out;	// serial output

reg [8:0] data_shift_reg;
reg data_out = 1'b1;   // initially HIGH due to IDLE

always @(posedge clk)
begin
    if (valid)   // only accept input data when data is valid (Tx is in idle state due to o_busy feedback to Tx)
	data_shift_reg <= data_in;   // prepare to start shifting in new chunk of data
    else
	data_shift_reg <= { 1'b1, data_shift_reg[8:1] };   // pushes 1 in such that when tx finishes, a logic level of '1' is transmitted
end

always @(posedge clk)
begin
    if (valid)	// only start shifting out data when Tx is in idle state and data is valid
	data_out <= 1'b0;  // 0-bit represents UART start bit
    else
	data_out <= data_shift_reg[0];  // transmit LSB first according to UART protocol
end

endmodule

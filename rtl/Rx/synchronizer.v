module synchronizer(clk, reset, serial_in, serial_in_synced);  // 3FF synchronizer

input clk, reset, serial_in;
output reg serial_in_synced; // third FF

reg serial_in_reg, serial_in_reg2;

always @(posedge clk)
begin
	if(reset) begin
		serial_in_reg <= 1;  	// first FF
		serial_in_reg2 <= 1;	// second FF
		serial_in_synced <= 1; // third FF
	end
	
	else begin
		serial_in_reg <= serial_in;  	// first FF
		serial_in_reg2 <= serial_in_reg;	// second FF
		serial_in_synced <= serial_in_reg2; // third FF
	end
end

`ifdef FORMAL

initial begin
    assume(serial_in_reg == 1);
    assume(serial_in_reg2 == 1);
    assume(serial_in_synced == 1);
end
`endif

endmodule

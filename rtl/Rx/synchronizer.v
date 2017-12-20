module synchronizer(clk, serial_in, serial_in_synced);  // 3FF synchronizer

input clk, serial_in;
output reg serial_in_synced; // third FF

reg serial_in_reg, serial_in_reg2;

always @(posedge clk)
begin
    serial_in_reg <= serial_in;  	// first FF
    serial_in_reg2 <= serial_in_reg;	// second FF
    serial_in_synced <= serial_in_reg2; // third FF
end

`ifdef FORMAL

initial begin
    assume(serial_in_reg == 1);
    assume(serial_in_reg2 == 1);
    assume(serial_in_synced == 1);
end
`endif

endmodule

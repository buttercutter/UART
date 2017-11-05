module synchronizer(clk, serial_in, serial_in_synced);  // 3FF synchronizer

input clk, serial_in;
output reg serial_in_synced; // third FF

reg serial_in_reg;

always @(posedge clk)
begin
    serial_in_reg <= serial_in;  // first FF
    serial_in_synced <= serial_in_reg;  // second FF
end

endmodule

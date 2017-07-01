// credit: Adapted from http://zipcpu.com/blog/2017/06/02/generating-timing.html

module baud_generator(clk, baud_out);     // we are obtaining baud_out = 9600bps = clk/5000 where clk = 48MHz

input clk;
output baud_out;

reg ck_stb;
reg[31:0] counter = 0;

always @(posedge clk)
    {ck_stb, counter} <= counter + 858993;  // (2^32)/5000 ~= 858993 , actual baudrate = 9599.9949bps
					    // baud_out has a period of (1/9599.9949bps) or 104167ns
assign baud_out = ck_stb;

endmodule

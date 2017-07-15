// credit: Adapted from http://zipcpu.com/blog/2017/06/02/generating-timing.html

module enable_generator(clk, en_out, index);     // we are obtaining en_out = 2Hz = clk/24000000 where clk = 48MHz

input clk;
output en_out;
output [3:0] index;   // range from 0 to 15, this output is for indexing the message string to extract one character for each transmission

reg ck_stb;
reg[45:0] counter = 0;
reg [3:0] index = 0;

always @(posedge clk)
    {ck_stb, counter} <= counter + 2932031;  // (2^46)/24000000 ~= 2932031.007402667 , actual frequency = 1.999999995Hz
															// en_out has a period of (1/1.999999995Hz) or 0.500000001s or 500ms
assign en_out = ck_stb;

always @(posedge en_out)
	 index <= index + 1;

endmodule

// credit: Adapted from http://zipcpu.com/blog/2017/06/02/generating-timing.html

module baud_generator(clk, baud_clk);     // we are obtaining baud_out = 9600bps = clk/5000 where clk = 48MHz

input clk;
output baud_clk = 0;

reg ck_stb;

`ifdef FORMAL
    reg[3:0] counter = 0;
    localparam INCREMENT = 2; // (2^4)/8 ~= 2
`else
    reg[31:0] counter = 0;
    localparam INCREMENT = 858993; // (2^32)/5000 ~= 858993
`endif

always @(posedge clk)
    {ck_stb, counter} <= counter + INCREMENT;  // actual baudrate = 9599.9949bps
					    // baud_out has a period of (1/9599.9949bps) or 104167ns
assign baud_clk = ck_stb;

`ifdef FORMAL

localparam DIVIDE_FACTOR = 8;

reg[($clog2(DIVIDE_FACTOR)-1) : 0] cnt = 0;

always @(posedge clk)
begin
    cnt <= cnt + 1;

    if (baud_clk) begin
	assert((cnt >= (DIVIDE_FACTOR-2)) && (cnt <= (DIVIDE_FACTOR)));
	cnt <= 0;
    end
end

`endif

endmodule

// credit: Adapted from http://zipcpu.com/blog/2017/06/02/generating-timing.html

module baud_generator(clk, baud_clk);     // we are obtaining baud_out = 9600bps = clk/5000 where clk = 48MHz

input clk;
output baud_clk;

reg ck_stb;

`ifdef FORMAL
    parameter DIVIDE_FACTOR = 8;
`else
    parameter DIVIDE_FACTOR = 5000;
`endif

reg[$clog2(DIVIDE_FACTOR):0] cnt;

initial ck_stb = 0;
initial cnt = 0;

always @(posedge clk)
begin
    ck_stb <= (cnt == (DIVIDE_FACTOR - 1)); 
    cnt <= cnt + 1;
end

assign baud_clk = ck_stb;

endmodule

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

reg[$clog2(DIVIDE_FACTOR):0] cnt = 0;

initial baud_clk = 0;

always @(posedge clk)
begin
    ck_stb <= (counter == (DIVIDE_FACTOR - 1)); 
    cnt <= cnt + 1;
end
				    
assign baud_clk = ck_stb;

`ifdef FORMAL

always @(posedge clk)
begin
    if (baud_clk) begin
	assert((cnt >= (DIVIDE_FACTOR-2)) && (cnt <= (DIVIDE_FACTOR)));
	cnt <= 0;
    end
end

`endif

endmodule

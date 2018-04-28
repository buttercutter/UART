module synchronizer(clk, reset, serial_in, serial_in_synced, sampling_strobe);  // 3FF synchronizer

input clk, reset, serial_in, sampling_strobe;
output reg serial_in_synced; // third FF

reg serial_in_reg, serial_in_reg2;

always @(posedge clk)
begin
	if(reset) begin
		serial_in_reg <= 1;  	// first FF
		serial_in_reg2 <= 1;	// second FF
		serial_in_synced <= 1; // third FF
	end
	
	else if(sampling_strobe) begin
		serial_in_reg <= serial_in;  	// first FF
		serial_in_reg2 <= serial_in_reg;	// second FF
		serial_in_synced <= serial_in_reg2; // third FF
	end
end

initial begin
    serial_in_reg = 1;
    serial_in_reg2 = 1;
    serial_in_synced = 1;
end

`ifdef FORMAL
reg first_clock_passed = 0;

always @(posedge clk)	first_clock_passed <= 1;


always @(posedge clk)
begin
	if(reset) begin
		assert(serial_in_reg == 1);
		assert(serial_in_reg2 == 1);
		assert(serial_in_synced == 1);
	end
	
	else if(sampling_strobe) begin
		if(first_clock_passed) begin
			// for induction
			assert(serial_in_reg == $past(serial_in)); 
	 		assert(serial_in_reg2 == $past(serial_in_reg));
	 	end
	end
end
`endif

endmodule

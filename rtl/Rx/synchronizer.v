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

parameter CLOCKS_PER_BIT = 8; // number of system clock in one UART bit, or equivalently 1/600kHz divided by 1/48MHz

reg first_clock_passed = 0;
reg had_reset = 0;  // this signal is for checking if reset signal gets asserted in between two sampling_strobe pulses

always @(posedge clk)	first_clock_passed <= 1;


always @(posedge clk)
begin
	if(first_clock_passed && $past(reset)) begin
		had_reset <= 1;
	
		assert(serial_in_reg == 1);
		assert(serial_in_reg2 == 1);
		assert(serial_in_synced == 1);
	end
	
	else if(first_clock_passed && sampling_strobe) begin
		if(!had_reset) begin // reset signal gets asserted in between two sampling_strobe pulses
			// for induction
			assert(serial_in_reg == $past(serial_in, CLOCKS_PER_BIT)); 
	 		assert(serial_in_reg2 == $past(serial_in_reg, CLOCKS_PER_BIT));
	 	end
	 	
	 	else begin
	 		had_reset <= 0; 
	 	
			assert(serial_in_reg == 1);
			assert(serial_in_reg2 == 1);
			assert(serial_in_synced == 1);	 	
	 	end
	end
end
`endif

endmodule

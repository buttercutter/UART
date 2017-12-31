module sampling_strobe_generator(clk, start_detected, sampling_strobe);  // produces sampling control signal for the incoming Rx

input clk, start_detected;
output reg sampling_strobe;

`ifdef FORMAL
    parameter CLOCKS_PER_BIT = 8; // number of system clock in one UART bit, or equivalently 1/600MHz divided by 1/48MHz
`else
    parameter CLOCKS_PER_BIT = 5000; // number of system clock in one UART bit, or equivalently 1/9600Hz divided by 1/48MHz
`endif

reg [($clog2(CLOCKS_PER_BIT)-1) : 0] counter;

always @(posedge clk)
begin
    if(start_detected)
		counter <= (CLOCKS_PER_BIT >> 1);  // when start bit is detected, we only need to advance half an UART bit to sample at the middle of the UART start bit
	else
   		counter <= counter + 1;  // to count number of system clock that had passed since midpoint-sampling of previous UART bit
end

always @(posedge clk)
begin
    if(counter == (CLOCKS_PER_BIT-1))
		sampling_strobe <= 1;
    else
		sampling_strobe <= 0;
end

`ifdef FORMAL

always @(posedge clk)
begin
    if(start_detected) begin 
    	assert(sampling_strobe == 0);
    end
    
	assert((sampling_strobe & ($past(sampling_strobe))) == 0);  // sampling_strobe is only single pulse '1'
end

`endif

endmodule

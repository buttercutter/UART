module sampling_strobe_generator(clk, start_detected, sampling_strobe);  // produces sampling control signal for the incoming Rx

input clk, start_detected;
output reg sampling_strobe = 0;

localparam CLOCKS_PER_BIT = 5000; // number of system clock in one UART bit, or equivalently 1/9600Hz divided by 1/48MHz

reg [($clog2(CLOCKS_PER_BIT)-1) : 0] counter = 0;

always @(posedge clk)
begin
    if(start_detected)
	counter <= (CLOCKS_PER_BIT >> 1);  // when start bit is detected, we only need to advance half an UART bit to sample at the middle of the UART start bit

    if(counter == CLOCKS_PER_BIT)
	counter <= 0;
    else
    	counter <= counter + 1;  // to count number of system clock that had passed since midpoint-sampling of previous UART bit
end

always @(posedge clk)
begin
    if(counter == CLOCKS_PER_BIT)
	sampling_strobe <= 1;
    else
	sampling_strobe <= 0;
end

endmodule

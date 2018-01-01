module detect_start_bit(clk, serial_in_synced, start_detected); // just a falling edge detector + a counter

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;

input clk, serial_in_synced;
output reg start_detected; 

reg previously_idle;

`ifdef FORMAL
    parameter CLOCKS_PER_BIT = 8; // number of system clock in one UART bit, or equivalently 1/600MHz divided by 1/48MHz
`else
    parameter CLOCKS_PER_BIT = 5000; // number of system clock in one UART bit, or equivalently 1/9600Hz divided by 1/48MHz
`endif

localparam TOTAL_BITS_IN_UART = INPUT_DATA_WIDTH + PARITY_ENABLED + 2;   // 2 = start + stop

reg [($clog2(TOTAL_BITS_IN_UART*CLOCKS_PER_BIT)-1) : 0] clocks_since_start_bit;  // a counter to indicate start bit is only in existence for every (start + data + parity + stop = 11) bits in a UART stream

wire falling_edge = (!serial_in_synced) && (previously_idle);

initial 
begin
	start_detected = 0;
	previously_idle = 1;
	clocks_since_start_bit = 0;
end

always @(posedge clk)
begin
    if((falling_edge) && (clocks_since_start_bit >= TOTAL_BITS_IN_UART*CLOCKS_PER_BIT)) begin
		start_detected <= 1;
		clocks_since_start_bit <= 0;
	end
		
    else begin
		start_detected <= 0;
		clocks_since_start_bit <= clocks_since_start_bit + 1;
	end
end

always @(posedge clk)
begin
    if(serial_in_synced)
		previously_idle <= 1;
    else
		previously_idle <= 0;
end


`ifdef FORMAL

always @(posedge clk) 
begin
	if((clocks_since_start_bit == 0) && ($past(falling_edge) == 0)) begin
		assert(start_detected == 0);  // such that during start up, there is no erronous UART Rx activity
	end
end

`endif

endmodule

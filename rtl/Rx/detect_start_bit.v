module detect_start_bit(clk, reset, serial_in_synced, start_detected
`ifdef FORMAL
	, state
`endif
); // just a falling edge detector + a counter

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit

`ifdef FORMAL
input [($clog2(NUMBER_OF_BITS)-1) : 0] state;
`endif

input clk, reset, serial_in_synced;
output reg start_detected; 

localparam Rx_IDLE       = 4'b0000;
localparam Rx_START_BIT  = 4'b0001;
localparam Rx_DATA_BIT_0 = 4'b0010;
localparam Rx_DATA_BIT_1 = 4'b0011;
localparam Rx_DATA_BIT_2 = 4'b0100;
localparam Rx_DATA_BIT_3 = 4'b0101;
localparam Rx_DATA_BIT_4 = 4'b0110;
localparam Rx_DATA_BIT_5 = 4'b0111;
localparam Rx_DATA_BIT_6 = 4'b1000;
localparam Rx_DATA_BIT_7 = 4'b1001;
localparam Rx_PARITY_BIT = 4'b1010;
localparam Rx_STOP_BIT   = 4'b1011;

reg previously_idle;

`ifdef FORMAL
    parameter CLOCKS_PER_BIT = 8; // number of system clock in one UART bit, or equivalently 1/600MHz divided by 1/48MHz
`else
    parameter CLOCKS_PER_BIT = 5000; // number of system clock in one UART bit, or equivalently 1/9600Hz divided by 1/48MHz
`endif

reg [($clog2(NUMBER_OF_BITS*CLOCKS_PER_BIT)-1) : 0] clocks_since_start_bit;  // a counter to indicate start bit is only in existence for every (start + data + parity + stop = 11) bits in a UART stream

wire falling_edge = (!serial_in_synced) && (previously_idle);

initial 
begin
	start_detected = 0;
	previously_idle = 1;
	clocks_since_start_bit = 0;
end

always @(posedge clk)
begin
	if(reset) begin
		start_detected <= 0;
		clocks_since_start_bit <= 0;		
	end
	
	else begin
		if((falling_edge) && ((clocks_since_start_bit >= NUMBER_OF_BITS*CLOCKS_PER_BIT) || (clocks_since_start_bit == 0))) begin  // (start bit) AND ((the previous UART message had been successfully received ) OR (Rx is idling))
			start_detected <= 1;
			clocks_since_start_bit <= 0;
		end
			
		else if(start_detected) begin
			start_detected <= 1;
			clocks_since_start_bit <= clocks_since_start_bit + 1;
		end

		else begin
			start_detected <= 0;
			clocks_since_start_bit <= 0;
		end
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

reg first_clock_passed;
initial first_clock_passed = 0;

always @(posedge clk)
begin
	first_clock_passed <= 1;
end

always @(posedge clk) 
begin
	if(first_clock_passed) begin
		if((clocks_since_start_bit == 0) && ($past(falling_edge) == 0)) begin
			assert(start_detected == 0);  // such that during start up, there is no erronous UART Rx activity
		end
	
		if((clocks_since_start_bit == 0) && (state == Rx_STOP_BIT)) begin
			assert(&($past(clocks_since_start_bit)) == 1'b1);  // such that it wraps around after reaching max and restarts from zero
		end
	end
end

always @(posedge clk)
begin
	case(state) 
		Rx_IDLE			:	assert(clocks_since_start_bit == 0);
		Rx_START_BIT	:	assert(clocks_since_start_bit == 0);
		Rx_DATA_BIT_0	: 	assert(clocks_since_start_bit == 1);
		Rx_DATA_BIT_1	: 	assert(clocks_since_start_bit == 2);
		Rx_DATA_BIT_2	: 	assert(clocks_since_start_bit == 3);
		Rx_DATA_BIT_3	: 	assert(clocks_since_start_bit == 4);
		Rx_DATA_BIT_4	: 	assert(clocks_since_start_bit == 5);
		Rx_DATA_BIT_5	: 	assert(clocks_since_start_bit == 6);
		Rx_DATA_BIT_6	: 	assert(clocks_since_start_bit == 7);
		Rx_DATA_BIT_7	: 	assert(clocks_since_start_bit == 8);
		Rx_PARITY_BIT	: 	assert(clocks_since_start_bit == 9);
		Rx_STOP_BIT		: 	assert(clocks_since_start_bit == 10);
		
		default			:	assert(clocks_since_start_bit == 0);
	endcase
end

`endif

endmodule

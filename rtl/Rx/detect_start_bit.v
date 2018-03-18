module detect_start_bit(clk, reset, serial_in_synced, start_detected
`ifdef FORMAL
	, state
`endif
); // just (a falling edge detector + a counter) to detect UART start bit correctly

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
localparam ALL_BITS_RECEIVED = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit

`ifdef FORMAL
input [($clog2(ALL_BITS_RECEIVED)-1) : 0] state;
`endif

input clk, reset, serial_in_synced;
output reg start_detected; 

reg previously_idle;

wire falling_edge = (!serial_in_synced) && (previously_idle);

initial 
begin
	start_detected = 0;
	previously_idle = 1;
end

always @(posedge clk)
begin
	if(reset) begin
		start_detected <= 0;		
	end
	
	else begin
		if(falling_edge) begin  // (start bit) 
			start_detected <= 1;
		end
		
		else begin
			start_detected <= 0;
		end
	end
end

always @(posedge clk)
begin
    if(serial_in_synced) begin
		previously_idle <= 1;
	end
	
    else begin
		previously_idle <= 0;
	end
end


`ifdef FORMAL

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

reg first_clock_passed;
initial first_clock_passed = 0;

always @(posedge clk)
begin
	first_clock_passed <= 1;
end

always @(posedge clk) 
begin
	if(($past(first_clock_passed) == 0) && (first_clock_passed)) begin
		assert($past(state) == Rx_IDLE);
	end
end

always @(posedge clk)
begin
	assert((start_detected & $past(start_detected)) == 0);  // 'start_detected' is only a single clock pulse
end

`endif

endmodule

module rx_state(clk, start_detected, sampling_strobe, data_is_available, data_is_valid, is_parity_stage);  // FSM for UART Rx

input clk, start_detected, sampling_strobe;
output reg data_is_available;
output reg is_parity_stage;
output data_is_valid;

reg [3:0] state = 0;

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

assign data_is_valid = (state == Rx_STOP_BIT);  // so as to align with rx_error

always @(posedge clk)
begin
    is_parity_stage  <= (state == Rx_PARITY_BIT);  // parity state
    data_is_available <= ((state >= Rx_DATA_BIT_0) && (state <= Rx_DATA_BIT_7)); // data states
end

always @(posedge clk)
begin
    if (sampling_strobe) begin
    case(state)
	Rx_IDLE 	: state <= (start_detected) ?  Rx_START_BIT : Rx_IDLE;

	Rx_START_BIT	: state <= Rx_DATA_BIT_0;

	Rx_DATA_BIT_0,
	Rx_DATA_BIT_1,
	Rx_DATA_BIT_2,	
	Rx_DATA_BIT_3,
	Rx_DATA_BIT_4,
	Rx_DATA_BIT_5,
	Rx_DATA_BIT_6,
	Rx_DATA_BIT_7	: state <= state + 1'b1;

	Rx_PARITY_BIT 	: state <= Rx_STOP_BIT;

	Rx_STOP_BIT 	: state <= Rx_IDLE;

	default      	: state <= Rx_IDLE;
    endcase
    end
end

endmodule

`define Tx_IDLE 		 4'b0
`define Tx_START_BIT  4'b0001
`define Tx_DATA_BIT_0 4'b0010
`define Tx_DATA_BIT_1 4'b0011
`define Tx_DATA_BIT_2 4'b0100
`define Tx_DATA_BIT_3 4'b0101
`define Tx_DATA_BIT_4 4'b0110
`define Tx_DATA_BIT_5 4'b0111
`define Tx_DATA_BIT_6 4'b1000
`define Tx_DATA_BIT_7 4'b1001
`define Tx_PARITY_BIT 4'b1010
`define Tx_STOP_BIT   4'b1011

module TxUART(clk, baud_clk, enable, i_data, o_busy, start_tx);

input clk, baud_clk, enable;
input[7:0] i_data;
output o_busy;
output start_tx;

reg[3:0] state;
reg start_tx = 0;

always @(posedge clk)   
begin
    if ((enable == 1) && (state == `Tx_IDLE))  	
		start_tx <= 1; 	// 'baud_clk' changes according to 9600Hz , while 'enable' changes according to 1Hz (1s timer)
								// So, start_tx *must* be held high until the clock cycle where both 'baud_clk and !enable'
    else if (state == `Tx_START_BIT)	start_tx <= 0;
end

always @(posedge baud_clk)
begin

    case(state)
	`Tx_IDLE 	: state <= (start_tx) ?  `Tx_START_BIT : `Tx_IDLE;

	`Tx_START_BIT	: state <= `Tx_DATA_BIT_0;

	`Tx_DATA_BIT_0,
	`Tx_DATA_BIT_1,
	`Tx_DATA_BIT_2,	
	`Tx_DATA_BIT_3,
	`Tx_DATA_BIT_4,
	`Tx_DATA_BIT_5,
	`Tx_DATA_BIT_6,
	`Tx_DATA_BIT_7	: state <= state + 1'b1;

	`Tx_PARITY_BIT 	: state <= `Tx_STOP_BIT;

	`Tx_STOP_BIT 	: state <= `Tx_IDLE;

	default      	: state <= `Tx_IDLE;
    endcase
end

assign o_busy = !(state == `Tx_IDLE);  // Tx is busy transmitting when not idling

endmodule

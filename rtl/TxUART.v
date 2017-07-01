`define Tx_IDLE 0
`define Tx_START_BIT 1
`define Tx_DATA_BIT_0 2
`define Tx_DATA_BIT_1 3
`define Tx_DATA_BIT_2 4
`define Tx_DATA_BIT_3 5
`define Tx_DATA_BIT_4 6
`define Tx_DATA_BIT_5 7
`define Tx_DATA_BIT_6 8
`define Tx_DATA_BIT_7 9
`define Tx_PARITY_BIT 10
`define Tx_STOP_BIT 11

module TxUART(clk, start_tx, i_data, o_busy);

input clk, start_tx;
input[7:0] i_data;
output o_busy;

reg[3:0] state;

always @(posedge clk)
begin
    case(state)
	`Tx_IDLE 	: state <= (start_tx == 1) ?  `Tx_START_BIT : `Tx_IDLE;

	`Tx_START_BIT	: state <= `Tx_DATA_BIT_0;

	`Tx_DATA_BIT_0,
	`Tx_DATA_BIT_1,
	`Tx_DATA_BIT_2,	
	`Tx_DATA_BIT_3,
	`Tx_DATA_BIT_4,
	`Tx_DATA_BIT_5,
	`Tx_DATA_BIT_6,
	`Tx_DATA_BIT_7	: state <= state + 1;

	`Tx_PARITY_BIT 	: state <= `Tx_STOP_BIT;

	`Tx_STOP_BIT 	: state <= `Tx_IDLE;

	default      	: state <= `Tx_IDLE;
    endcase
end

assign o_busy = !(state == `Tx_IDLE);  // Tx is busy transmitting when not idling

endmodule

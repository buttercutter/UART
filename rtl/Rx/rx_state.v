module rx_state(clk, reset, start_detected, sampling_strobe, data_is_available, data_is_valid, is_parity_stage, state);  // FSM for UART Rx

parameter INPUT_DATA_WIDTH = 8;
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + 3;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit

input clk, reset, start_detected, sampling_strobe;
output reg data_is_available;   // in data states
output reg is_parity_stage;
output reg data_is_valid;	// finished all data states
output reg [($clog2(NUMBER_OF_BITS)-1) : 0] state;


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

initial begin
    data_is_available = 0;
    is_parity_stage = 0;
    data_is_valid = 0;
    state = 0;
end

always @(posedge clk)
begin
	if(reset) begin
		data_is_valid <= 0;
		is_parity_stage <= 0;
		data_is_available <= 0;
	end
	
	else begin
    	data_is_valid <= (state == Rx_STOP_BIT);  // so as to align with rx_error
    	is_parity_stage  <= (state == Rx_PARITY_BIT);  // parity state
    	data_is_available <= ((state >= Rx_DATA_BIT_0) && (state <= Rx_DATA_BIT_7)); // data states
    end
end

always @(posedge clk)
begin
    if (reset)
        state <= Rx_IDLE;
    
    else begin
        if (sampling_strobe) begin
            case(state)

				Rx_IDLE			: state <= (start_detected) ? Rx_START_BIT : Rx_IDLE;

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
        
        else begin   // start bit falling edge is detected every clock cycle for better Rx synchronization accuracy
        
            if((state == Rx_IDLE) && (start_detected))
	    	    state <= Rx_START_BIT;
        end
    end
end

`ifdef FORMAL
    
    always @(posedge clk) 
    begin
        assert(state <= Rx_STOP_BIT);
    
    	if(((state == Rx_DATA_BIT_0) && ($past(state) == Rx_DATA_BIT_0)) || ((state > Rx_DATA_BIT_0) && (state <= Rx_DATA_BIT_7))) begin
    		assert(data_is_available);
    	end
    	
        //if (state == Rx_STOP_BIT)
            //assume(reset == 0);  // this is to assume for induction test because Tx internal registers are not reset/initialized properly at time = 0, such that data_is_valid signal will not be asserted in the next clock cycle after the "FIRST" stop bit state
    end
`endif

endmodule

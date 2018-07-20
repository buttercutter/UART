module rx_state(clk, reset, start_detected, sampling_strobe, data_is_available, data_is_valid, is_parity_stage, state);  // FSM for UART Rx

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + PARITY_ENABLED + 2;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit

input clk, reset, start_detected, sampling_strobe;
output data_is_available;   // in data states
output is_parity_stage;
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
    data_is_valid = 0;
    state = 0;
end

assign is_parity_stage = (reset) ? 0 : (state == Rx_PARITY_BIT);  // parity state
assign data_is_available = (reset) ? 0 : ((state >= Rx_DATA_BIT_0) && (state <= Rx_DATA_BIT_7)); // (about to enter first data state) OR (data states)

always @(posedge clk)
begin
	if(reset) begin
		data_is_valid <= 0;
	end
	
	else begin
    	data_is_valid <= (state == Rx_PARITY_BIT) && sampling_strobe;  // data_is_valid should only ever be one clock pulse long, because the UART needs to be a component of a larger system.  That system will be running at the system clock rate.  If the "output is valid" line is high more than once per byte, it will read that many copies of the same byte have been read. 
    	
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
    reg first_clock_passed = 0;
    
    always @(posedge clk) 
    begin
    	first_clock_passed <= 1;
   
   		if(first_clock_passed && $past(reset)) assert(state == Rx_IDLE);
    
        if(first_clock_passed) assert(state <= Rx_STOP_BIT);
    
    	if((state >= Rx_DATA_BIT_0) && (state <= Rx_DATA_BIT_7) && (!reset)) begin // for induction
    		assert(data_is_available);
    	end
    	
    	else assert(!data_is_available);
    	
        //if (state == Rx_STOP_BIT)
            //assume(reset == 0);  // this is to assume for induction test because Tx internal registers are not reset/initialized properly at time = 0, such that data_is_valid signal will not be asserted in the next clock cycle after the "FIRST" stop bit state
    end
    
	always @(posedge clk)
	begin
		if(first_clock_passed) begin
			if($past(reset)) begin
				assert(data_is_valid == 0);
				assert(state == Rx_IDLE);
			end
			
			else begin
				assert(data_is_valid == (($past(state) == Rx_PARITY_BIT) && $past(sampling_strobe)));  
			end
		end
	end

`endif

endmodule

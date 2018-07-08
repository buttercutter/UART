`default_nettype none

// for connecting Tx and Rx together
`define LOOPBACK 1

module test_UART(reset_tx, reset_rx, serial_out, enable, i_data, o_busy, received_data, data_is_valid, rx_error);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;
parameter PARITY_TYPE = 0;  // 0 = even parity, 1 = odd parity

//input clk;
input reset_tx, reset_rx;

// transmitter signals
input enable;
input [(INPUT_DATA_WIDTH-1):0] i_data;
output o_busy;
output serial_out;

`ifdef FORMAL
wire baud_clk;
wire [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;  // Tx internal PISO
reg [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] expected_shift_reg;
`endif

// receiver signals
wire serial_in;
output reg data_is_valid;
output reg rx_error;
output reg [(INPUT_DATA_WIDTH-1):0] received_data;

`ifdef FORMAL
localparam NUMBER_OF_BITS = INPUT_DATA_WIDTH + PARITY_ENABLED + 2;   // 1 start bit, 8 data bits, 1 parity bit, 1 stop bit
wire [($clog2(NUMBER_OF_BITS)-1) : 0] state;  // for Rx
wire serial_in_synced, start_detected, sampling_strobe;
`endif

UART uart(.tx_clk(tx_clk), .rx_clk(rx_clk), .reset_tx(reset_tx), .reset_rx(reset_rx), .serial_out(serial_out), .enable(enable), .i_data(i_data), .o_busy(o_busy), .serial_in(serial_in), .received_data(received_data), .data_is_valid(data_is_valid), .rx_error(rx_error)
`ifdef FORMAL
	, .state(state), .baud_clk(baud_clk), .shift_reg(shift_reg), .serial_in_synced(serial_in_synced), .start_detected(start_detected), .sampling_strobe(sampling_strobe)
`endif
);

assign serial_in = serial_out; // tx goes to rx, so that we know that our UART works at least in terms of logic-wise

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

localparam NUMBER_OF_RX_SYNCHRONIZERS = 3; // three FF synhronizers for clock domain crossing
localparam CLOCKS_PER_BIT = 8;

reg had_been_enabled;   // a signal to latch Tx 'enable' signal
reg[($clog2(NUMBER_OF_BITS)-1) : 0] cnt;  // to track the number of transmitter clock cycles (baud_clk) incurred between assertion of 'tx_in_progress' signal from Tx and assertion of 'data_is_valid' signal from Rx

reg tx_in_progress; 
reg first_clock_passed_tx, first_clock_passed_rx;

initial begin
	had_been_enabled = 0;  
	cnt = 0;
	tx_in_progress = 0;
	first_clock_passed_tx = 0;
	first_clock_passed_rx = 0;
end


// refer to https://www.allaboutcircuits.com/technical-articles/the-uart-baud-rate-clock-how-accurate-does-it-need-to-be/ for feasible ratio of tx_clk/rx_clk

localparam rx_clk_increment = 2;  // rx_clk is slower than tx_clk by a factor of 1.015 or equivalently slower than $global_clock by a factor of (1.015*2)
localparam counter_rx_clk_bit_width = 2; // (2^2)/(1.015*2) = 1.97044335 ~= 2
reg	[counter_rx_clk_bit_width-1:0]	counter_rx_clk = 0;
reg rx_clk = 0;

always @($global_clock)  // generation of rx_clk which is 1.5% frequency deviation from tx_clk
begin
	if(reset_rx) begin
		rx_clk <= 0;
		counter_rx_clk <= 0;	
	end
	
	else
		{ rx_clk, counter_rx_clk } <= counter_rx_clk + rx_clk_increment; // the actual rx_clk is slower than tx_clk by a factor 1.015 or 1.5 percent
end

localparam TX_CLK_THRESHOLD = 2;  // divides $global_clock by 2 to obtain ck_stb which is just a clock enable signal

reg [($clog2(TX_CLK_THRESHOLD)-1):0] counter_tx_clk = 0;
reg tx_clk = 0;

always @($global_clock)
begin
	if(reset_tx) counter_tx_clk <= 1; 
	
	else begin
		if(tx_clk)
		  	counter_tx_clk <= 1;    
		else
		  	counter_tx_clk <= counter_tx_clk + 1;
	end	  	
end

always @($global_clock)
begin
	if(reset_tx) tx_clk <= 0;

	else tx_clk <= (counter_tx_clk == TX_CLK_THRESHOLD-1'b1);
end

always @($global_clock)
begin
	assert(counter_tx_clk <= (TX_CLK_THRESHOLD - 1));

	if(first_clock_passed_tx) begin
		if($past(reset_tx)) begin
			assert(tx_clk == 0);
			assert(counter_tx_clk == 1);
		end

		else begin
			assert((tx_clk && $past(tx_clk)) == 0);  // asserts that tx_clk is only single pulse HIGH
			
			assert((($past(counter_tx_clk) - counter_tx_clk) == 1) || ((counter_tx_clk - $past(counter_tx_clk)) == 1));  // to keep the increasing trend for induction test purpose such that tx_clk occurs at the correct period interval 
			
			if($past(counter_tx_clk) == TX_CLK_THRESHOLD-1'b1) // && (counter_tx_clk == 1)) 
				assert(tx_clk);
			else 
				assert(!tx_clk);
		end
	end
end

always @($global_clock)
begin
	assert(counter_rx_clk < (1 << counter_rx_clk_bit_width));

	if(first_clock_passed_rx) begin
		if($past(reset_rx)) begin
			assert(rx_clk == 0);
			assert(counter_rx_clk == 0);
		end

		else begin	
			assert((rx_clk && $past(rx_clk)) == 0);  // asserts that tx_clk is only single pulse HIGH
			
			if($past(reset_rx)) assert(counter_rx_clk == 0);
			
			else begin // to keep the increasing trend for induction test purpose such that tx_clk occurs at the correct period interval 
				if(counter_rx_clk == 0)
					assert(($past(counter_rx_clk) - counter_rx_clk) == rx_clk_increment);
				
				else
					assert((counter_rx_clk - $past(counter_rx_clk)) == rx_clk_increment);  
			end
			
			if((($past(counter_rx_clk) - counter_rx_clk) == rx_clk_increment) && (counter_rx_clk == 0)) 
				assert(rx_clk);
			else 
				assert(!rx_clk);
		end
	end
end


always @(posedge tx_clk)
begin
	first_clock_passed_tx <= 1;
end

always @(posedge rx_clk)
begin
	first_clock_passed_rx <= 1;
end

always @(*) 
begin
	if(!first_clock_passed_tx)  assume(reset_tx);
	
	//else assert(serial_out == 1);
		
	if(!first_clock_passed_rx)	assume(reset_rx);
	
	//else assert(serial_in == 1);
end

wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location_plus_one = stop_bit_location + 1;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location_plus_two = stop_bit_location_plus_one + 1;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] stop_bit_location;
wire [($clog2(NUMBER_OF_BITS)-1) : 0] parity_bit_location = stop_bit_location - 1;

assign stop_bit_location = (cnt < NUMBER_OF_BITS) ? (NUMBER_OF_BITS - 1 - cnt) : 0;  // if not during UART transmission, set to zero as default for no specific reason


always @(posedge tx_clk)
begin
	assert(cnt <= NUMBER_OF_BITS);
	assert(stop_bit_location < NUMBER_OF_BITS);
	
	if(first_clock_passed_tx) begin
		if($past(reset_tx) == 0) begin 
			if(cnt < NUMBER_OF_BITS) begin
				assert(stop_bit_location == (NUMBER_OF_BITS - 1 - cnt));
			end
		end

		if($past(first_clock_passed_tx) == 0) begin
			assert($past(&shift_reg) == 1);
		end
	end
end

always @(posedge tx_clk)
begin
    if(reset_tx) begin
        cnt <= 0;
		tx_in_progress <= 0;
    end

	else if(baud_clk) begin
		if(tx_in_progress | had_been_enabled) begin
			if(cnt < NUMBER_OF_BITS) cnt <= cnt + 1;
			else cnt <= 0;
		end
		
		//else if(enable) cnt <= cnt + 1;
		
		else cnt <= 0;
		
		tx_in_progress <= (had_been_enabled || enable);  // Tx only operates at every rising edge of 'baud_clk' (Tx's clock)
	end   
	
	else begin
	
        if(enable && (!had_been_enabled)) begin
    	    cnt <= 0;  
    	end
    	
        if((cnt == NUMBER_OF_BITS) && !had_been_enabled) begin
        	tx_in_progress <= 0;
        end

		//else tx_in_progress <= had_been_enabled;
    end
end

always @(posedge tx_clk)
begin    
    if((first_clock_passed_tx) && !($past(reset_tx)) && 
	  ((!($past(baud_clk)) && $past(tx_in_progress) && $past(had_been_enabled)) 
    || ($past(tx_in_progress) && $past(had_been_enabled)) 
    || ($past(had_been_enabled) || $past(enable)) && ($past(baud_clk)) && !($past(tx_in_progress)) 
    || (($past(baud_clk)) && $past(had_been_enabled)))) begin  // ((just finished transmitting the END bit, but baud_clk still not asserted yet) OR (still busy transmitting) OR (just enabled) OR (END bit finishes transmission with baud_clk asserted, and Tx is enabled immediately after this))
		assert(tx_in_progress);
	end
	   	
	else begin
		assert(!tx_in_progress);
	end
end

`ifdef LOOPBACK
// In a Tx->Rx joint proof, we want to assert that all the bits received by the receiver at any given point in time are equal to all the bits sent by the transmitter 

always @(posedge tx_clk) begin
	if(first_clock_passed_tx && $past(reset_tx)) begin
		assert(cnt == 0);
	end
end

always @($global_clock) begin  // for induction, checks the relationship between Tx 'cnt' and Rx 'state'
	if(first_clock_passed_tx || first_clock_passed_rx) begin
	
		if((state == Rx_IDLE) && ($past(state) == Rx_IDLE)) begin
			if(serial_in == 1)
				assert(cnt == 0);
			else
				assert(cnt == 1);
		end	
		
		else if((state == Rx_IDLE) && ($past(state) == Rx_STOP_BIT)) begin
			assert(cnt == NUMBER_OF_BITS);
		end
		
		else if((state >= Rx_START_BIT) && (state <= Rx_PARITY_BIT)) begin
			assert(cnt == state);
		end
		
		else begin // (state == Rx_STOP_BIT)
			if(tx_in_progress || !had_been_enabled)
				assert(cnt == state);
			else begin
				assert(cnt == 0);
			end
		end
	end
end


always @($global_clock) begin
	if(first_clock_passed_tx || first_clock_passed_rx) begin
		if(state == Rx_IDLE) begin
			if(($past(reset_rx)) || (($past(state) == Rx_IDLE)) || ($past(state, CLOCKS_PER_BIT) == Rx_STOP_BIT)) begin
				assert(received_data == {INPUT_DATA_WIDTH{1'b0}});
			end
			
			else assert(received_data == i_data);
		end
		
		else if(state == Rx_START_BIT)
			assert(received_data == {INPUT_DATA_WIDTH{1'b0}});
			
		else if(state == Rx_DATA_BIT_0)
			assert(received_data == {INPUT_DATA_WIDTH{1'b0}});  // Rx shift reg is updated one 'sampling_strobe' cycle later than 'serial_in_synced'
			
		else if(state == Rx_STOP_BIT) begin
			if(data_is_valid)
				assert(received_data == i_data);
			else
				assert(received_data == {INPUT_DATA_WIDTH{1'b0}});
		end
	end		
end


generate

genvar cnt_idx;  // for induction, checks the relationship between 'state' and 'received_data'

for(cnt_idx=Rx_DATA_BIT_1; (cnt_idx < Rx_STOP_BIT); cnt_idx=cnt_idx+1) begin

	always @($global_clock) begin
		if(first_clock_passed_tx || first_clock_passed_rx) begin
			if(state == cnt_idx) begin
				assert(received_data == {i_data[cnt_idx-NUMBER_OF_RX_SYNCHRONIZERS:0] , {(INPUT_DATA_WIDTH-cnt_idx+NUMBER_OF_RX_SYNCHRONIZERS-1){1'b0}}});
			end
		end
	end
	
end

endgenerate

`endif

wire [($clog2(INPUT_DATA_WIDTH + NUMBER_OF_BITS + NUMBER_OF_RX_SYNCHRONIZERS) - 1) : 0] i_data_index [(INPUT_DATA_WIDTH-1) : 0];
wire [(INPUT_DATA_WIDTH-1) : 0] Tx_shift_reg_assertion;

wire tx_shift_reg_contains_data_bits = ((tx_in_progress) && (cnt > 1) && (cnt < (INPUT_DATA_WIDTH + PARITY_ENABLED)));  // shift_reg is one clock cycle before the data bits get registered to serial_out
	
// for induction purpose, checks whether the Tx PISO shift_reg is shifting out all 'INPUT_DATA_WIDTH' data bits correctly

generate
	genvar Tx_shift_reg_index;	

	for(Tx_shift_reg_index=(INPUT_DATA_WIDTH - 1); Tx_shift_reg_index >= 0; Tx_shift_reg_index=Tx_shift_reg_index-1) 
	begin : assert_Tx_shift_reg_label

		// predicate logic simplification using deMorgan Theorem
		// if (A and B) assert(C); is the same as assert((!A) || (!B) || C);  

		assign i_data_index[Tx_shift_reg_index] = (Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt)) ? (Tx_shift_reg_index + cnt - 1) : (INPUT_DATA_WIDTH - 1);

		assign Tx_shift_reg_assertion[Tx_shift_reg_index] = (!(Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt))) || (!tx_shift_reg_contains_data_bits) || (shift_reg[Tx_shift_reg_index] == i_data[i_data_index[Tx_shift_reg_index]]);    
		
		always @(posedge tx_clk) begin 			
			assert(Tx_shift_reg_assertion[Tx_shift_reg_index]);
		end
		
		/*
		always @(*) begin
			if(Tx_shift_reg_index <= (INPUT_DATA_WIDTH - cnt)) begin
			
				i_data_index[Tx_shift_reg_index] = Tx_shift_reg_index + cnt - 1;	

				if(tx_shift_reg_contains_data_bits) begin
					Tx_shift_reg_assertion[Tx_shift_reg_index] = (shift_reg[Tx_shift_reg_index] == i_data[i_data_index[Tx_shift_reg_index]]);
					
					assert(Tx_shift_reg_assertion[Tx_shift_reg_index]);
				end
			end
		end*/
	end
endgenerate

generate
	genvar Tx_index;	

	for(Tx_index = 1; (Tx_index > 1) && (Tx_index < (INPUT_DATA_WIDTH + PARITY_ENABLED + 1)); Tx_index=Tx_index+1) 
	begin 

		always@(posedge tx_clk) begin
			if(!reset_tx && tx_in_progress && first_clock_passed_tx) begin
				if(cnt == Tx_index) begin  // during UART data bits transmission
					expected_shift_reg <= {{(Tx_index){1'b0}} , 1'b1, (^i_data), i_data[INPUT_DATA_WIDTH-1:cnt-1]};
					
					assert(shift_reg == $past(expected_shift_reg));
				end
			end
		end
	end
endgenerate
							
always @(posedge tx_clk)
begin
    if(first_clock_passed_tx && $past(reset_tx)) begin
    	assert(&shift_reg == 1);
    	assert(cnt == 0);
    end	
end
			
always @(posedge tx_clk)
begin
	if(first_clock_passed_tx) begin
		if($past(reset_tx)) begin
			assert(!had_been_enabled);
		end   

		else begin
		    if($past(enable) && ((!$past(had_been_enabled)) || ($past(cnt) == NUMBER_OF_BITS))) 
		    	assert(had_been_enabled);
			
			else assert(!had_been_enabled);
		end		
	end	
end	
							
always @($global_clock)
begin
    if(reset_tx) begin
    	had_been_enabled <= 0;
    end   

    else begin
 
        if(enable && (!had_been_enabled)) begin           
    	    had_been_enabled <= 1;
    	    
    	    if((|shift_reg == 0) && (stop_bit_location == 0))  // just finished transmission
    	    	assert(cnt == NUMBER_OF_BITS);
    	    else 
    	    	assert(cnt == 0);
    	    
	    	assert(serial_out == 1);
	    	assert(o_busy == 0);
        end

		else if((!tx_in_progress) && (had_been_enabled)) begin // waiting for the start of UART transmission
			assert(cnt == 0);
			assert(serial_out == 1);
			assert(shift_reg == {1'b1, (^i_data), i_data, 1'b0});  // ^data is even parity bit
			
			assert(o_busy == 1);
		end

		else if(tx_in_progress) begin
			if(cnt == 0) begin
				if(first_clock_passed_tx) begin
			 		if (!$past(enable) && !$past(had_been_enabled)) 
			 			assert(!had_been_enabled);
			 		else
			 			assert(had_been_enabled);
			 	end
			 	
			 	else assert(!had_been_enabled); // not enabled at the beginning of time
			end
			
			else if(((cnt >= 1) && (cnt <= NUMBER_OF_BITS-1)) || ((cnt == NUMBER_OF_BITS) && ($past(cnt) == NUMBER_OF_BITS-1))) assert(had_been_enabled);
		
			if(cnt == 1) begin
				assert(serial_out == 0);  // start bit
				assert(shift_reg == {1'b0, 1'b1, (^i_data), i_data});
				assert(o_busy == 1);
			end
			
			else if((cnt > 1) && (cnt < (INPUT_DATA_WIDTH + PARITY_ENABLED + 1))) begin  // during UART data bits transmission
				
				assert(shift_reg == {1'b1, (^i_data), i_data, 1'b0 } >> cnt);
				if($past(baud_clk)) assert(serial_out == $past(shift_reg[0]));
				assert(shift_reg[stop_bit_location] == 1);					
				assert(o_busy == 1);				
			end
			
			else if(cnt == (INPUT_DATA_WIDTH + PARITY_ENABLED + 1)) begin  // during UART parity bit transmission
			
				//assert((state - cnt + NUMBER_OF_RX_SYNCHRONIZERS) == Rx_PARITY_BIT);

				assert(serial_out == (^i_data));
				assert(shift_reg == 1);
				//assert(data_is_valid == 0);					
				assert(o_busy == 1);				
			end
			
			else if(cnt == NUMBER_OF_BITS) begin  // UART stop bit transmission which signifies the end of UART transmission
				//assert((state - cnt + NUMBER_OF_RX_SYNCHRONIZERS) == Rx_STOP_BIT);
				
				if($past(enable)) had_been_enabled <= 1;
				else had_been_enabled <= 0;
				
				assert(serial_out == 1); // stop bit
				
				if(($past(enable) && !($past(o_busy)) && (had_been_enabled)) | (shift_reg != 0)) begin 	// Tx is requested to start next series of data transmission OR Tx is now being prepared for the next series
					
					assert(shift_reg == {1'b1, (^i_data), i_data, 1'b0} );   // transmit LSB first: 1 = stop bit, parity_bit, data_bits, 0 = start bit 
				end
				
				else begin
					assert(shift_reg == 0);
				end
				
				if($past(shift_reg) == 1) begin
					assert(o_busy);
				end
				
				else begin
					if(($past(enable) && !($past(o_busy)) && (had_been_enabled)) | (shift_reg != 0)) begin
						assert(o_busy);
					end
					
					else begin
						assert(!o_busy);
					end
				end
			end
			
			else begin  // UART Rx internal states
				
				assert(cnt == 0);  // cnt gets reset to zero

				if(state == Rx_IDLE) begin
					assert(data_is_valid == 0);
					
					//if(!$past(tx_in_progress, NUMBER_OF_RX_SYNCHRONIZERS) || !$past(first_clock_passed, NUMBER_OF_RX_SYNCHRONIZERS))
						assert(serial_in_synced == 1);
					//else
						//assert(serial_in_synced == 0);				
				end

				else if(state == Rx_START_BIT) begin
					assert(data_is_valid == 0);
					assert(serial_in_synced == 0);				
				end

				else if((state > Rx_START_BIT) && (state < Rx_PARITY_BIT)) begin // data bits
					assert(data_is_valid == 0);				
				end
	
				else if(state == Rx_PARITY_BIT) begin
					assert(data_is_valid == 0);
					assert(serial_in_synced == ^i_data);			
				end
						
				else begin // if(state == Rx_STOP_BIT) begin  // end of one UART transaction (both transmitting and receiving)
					assert(state == Rx_STOP_BIT);
					
					if(($past(state) == Rx_PARITY_BIT) && (state == Rx_STOP_BIT)) begin
						assert(data_is_valid == 1);
					end
					
					else assert(data_is_valid == 0);
				end
			end
    	end
    	    
    	else begin  // UART Tx is idling, still waiting for ((next enable signal) && (baud_clk))
    	    
    	    if($past(enable) && !($past(had_been_enabled))) begin
	    	    assert(cnt == 0);
	    	end
	    	
    	    assert(serial_out == 1);
    	    
    	    if(!had_been_enabled && first_clock_passed_tx) begin
				if($past(cnt) == NUMBER_OF_BITS) begin  // Tx had just finished
					if($past(reset_tx)) begin
						assert(&shift_reg == 1);
					end					

					else begin
						assert(shift_reg == 0);
					end
				end

				if($past(shift_reg) == 0) begin  // Tx is waiting to be enabled again after a transmission
					if($past(reset_tx)) begin
						assert(&shift_reg == 1);
					end
					
					else begin
						assert(shift_reg == 0);
					end
					
					if((($past(state) == Rx_IDLE) && !$past(start_detected)) || $past(reset_rx)) begin
						assert(state == Rx_IDLE);
					end
					
					else begin
						assert(state != Rx_START_BIT);
					end
				end

				else begin //if(&shift_reg == 1) begin  // Tx is waiting to be enabled for the first time
					assert(cnt == 0);
					
					if(($past(state) == Rx_IDLE) && $past(start_detected) && !$past(reset_rx)) begin
						assert(state == Rx_START_BIT);
					end
					
					else begin
						assert(state == Rx_IDLE);  // rx is idle too since this is a loopback
					end
				end
    	    end
    	end
    end
end

always @(posedge tx_clk)
begin	
	if(!$past(reset_tx) && $past(baud_clk) && first_clock_passed_tx) begin
		if((had_been_enabled) && (!$past(had_been_enabled))) begin  // Tx starts transmission now
			assert(!$past(o_busy));
			assert(o_busy);  
		end

		else if(((had_been_enabled) && ($past(had_been_enabled))) || $past(tx_in_progress)) begin  // Tx is in the midst of transmission
			if(($past(shift_reg) == 0) && (shift_reg == 0)) begin
				assert(!o_busy);
			end
			
			else begin
				assert(o_busy);
			end
		end

		else if((!had_been_enabled) && ($past(had_been_enabled))) begin  // Tx finished transmission
		
			if(first_clock_passed_tx) begin
				assert($past(serial_out) == 1);
			
				assert(($past(o_busy)) && (!o_busy));
						
				if($past(enable)) begin
					assert(o_busy);
				end
			end
		end
		
		else begin  // Tx had not been enabled yet
			//assert(cnt == 0);
			assert(!o_busy);
			assert(serial_out == 1);
		end
	end
end

always @($global_clock)
begin
    if(reset_tx | o_busy) begin
        assume(enable == 0);
    end
	
	if((!data_is_valid) || ((!$past(data_is_valid)) && (data_is_valid)) || (state == Rx_STOP_BIT) || ((data_is_valid) && ($past(state) == Rx_STOP_BIT))) begin
		assume($past(i_data) == i_data);  // must not change until Rx and Tx data comparison is done
	end
end

always @(posedge rx_clk)
begin
    assert(!rx_error);   // no parity error

    if(data_is_valid) begin   // state == Rx_STOP_BIT
        assert(received_data == i_data);
        assert(cnt <= NUMBER_OF_BITS);
    end

	if((!$past(reset_tx)) && (state <= Rx_STOP_BIT) && (first_clock_passed_rx) && (tx_in_progress) && ($past(tx_in_progress)) && ($past(baud_clk))) begin
		assert(cnt - $past(cnt) == 1);
	end
end

`endif

endmodule

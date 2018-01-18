// Credit: Adapted from http://hamsterworks.co.nz/mediawiki/index.php/TinyTx or https://electronics.stackexchange.com/questions/342921/uart-hdl-question

module TxUART(clk, reset, baud_clk, enable, i_data, o_busy, serial_out
`ifdef FORMAL
	, shift_reg
`endif
);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;

input clk, reset, baud_clk, enable;
input[(INPUT_DATA_WIDTH+PARITY_ENABLED-1):0] i_data;
output reg o_busy;      // busy signal for data source that Tx cannot accept data 
output reg serial_out;  // serialized data

`ifdef FORMAL
	output [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;
`endif

reg [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;  // PISO shift reg, start+data+parity+stop

initial 
begin
    o_busy = 0;
    serial_out = 1;
    shift_reg = ~0;
end

always @(posedge clk)   
begin
    if (reset) begin
        shift_reg <= ~0;  // set all bits to 1
    end

    else begin
        if (enable & !o_busy) begin
            shift_reg <= {1'b1, i_data, 1'b0};   // transmit LSB first: 1 = stop bit, 0 = start bit 
        end

        if (baud_clk) begin
            if (o_busy) begin
                shift_reg <= {1'b0, shift_reg[(INPUT_DATA_WIDTH+PARITY_ENABLED+1):1]};  // puts 0 for stop bit detection, see o_busy signal
            end
        end
    end
end 

always @(posedge clk) 
begin
    if(reset) begin 
    	serial_out <= 1;
    end

    else begin
        if (baud_clk) begin
            if (o_busy) begin
	            serial_out <= shift_reg[0]; 
            end	    
        end        
    end
end

always @(posedge clk) 
begin
    if(reset) begin 
    	o_busy <= 0;
    end

    else begin
		o_busy <= ((shift_reg != 0) && !(&shift_reg)) | enable;   // if not reset, ((Tx is busy transmitting when there is pending stop bit) AND (Tx does not just get reset)) OR (Tx is about to transmit)
    end
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
	if(first_clock_passed) begin    // for induction check purpose
		assert($past(o_busy) == 0);  // initially not busy
		assert(&($past(shift_reg)) == 1);  // initially all ones, transmitting ones
	end
end

`endif

endmodule

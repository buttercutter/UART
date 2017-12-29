// Credit: Adapted from http://hamsterworks.co.nz/mediawiki/index.php/TinyTx

module TxUART(clk, reset, baud_clk, enable, i_data, o_busy, serial_out);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;

input clk, reset, baud_clk, enable;
input[(INPUT_DATA_WIDTH+PARITY_ENABLED-1):0] i_data;
output reg o_busy;      // busy signal for data source that Tx cannot accept data 
output reg serial_out;  // serialized data

reg [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg;  // PISO shift reg, start+data+parity+stop

initial 
begin
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
            shift_reg <= {1, i_data, 0};   // transmit LSB first: 1 = stop bit, 0 = start bit 
        end

        if (baud_clk) begin
            if (o_busy) begin
                shift_reg <= {0, shift_reg[(INPUT_DATA_WIDTH+1):1]};  // puts 0 for stop bit detection, see o_busy signal
            end
        end
    end
end 

always @(posedge clk) 
begin
    if (baud_clk) begin
        if (o_busy) begin
	        serial_out <= shift_reg[0]; 
        end	            
    end
end

always @(posedge clk)
begin
    if(reset)
    	o_busy <= 0;
    else	
    	o_busy <= !(shift_reg == 0);  // Tx is busy transmitting when there is pending stop bit
end

`ifdef FORMAL

always @(posedge clk) 
begin
     if(!enable) begin
	assert(shift_reg == ~0);
     end
end

`endif

endmodule

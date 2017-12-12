// Credit: Adapted from http://hamsterworks.co.nz/mediawiki/index.php/TinyTx

module TxUART(clk, baud_clk, enable, i_data, o_busy, serial_out);

parameter INPUT_DATA_WIDTH = 8;
parameter PARITY_ENABLED = 1;

input clk, baud_clk, enable;
input[(INPUT_DATA_WIDTH+PARITY_ENABLED-1):0] i_data;
output o_busy;      // busy signal for data source that Tx cannot accept data 
output serial_out;  // serialized data

reg [(INPUT_DATA_WIDTH+PARITY_ENABLED+1):0] shift_reg = 0;  // PISO shift reg, start+data+parity+stop

always @(posedge clk)   
begin
    if (enable & !o_busy) begin
	shift_reg <= {1, i_data, 0};   // transmit LSB first: 1 = stop bit, 0 = start bit 
    end

    if (baud_clk) begin
        if (o_busy)
	    shift_reg <= {0, shift_reg[(INPUT_DATA_WIDTH+1):1]};  // puts 0 for stop bit detection, see o_busy signal
    end
end

assign serial_out = shift_reg[0];   // save one register by making serial_out a 'wire'

assign o_busy = !(shift_reg == 0);  // Tx is busy transmitting when there is pending stop bit


`ifdef FORMAL
initial begin
    assume(baud_clk == 0);
    assume(enable == 0);
end

cover property (baud_clk);

`endif

endmodule

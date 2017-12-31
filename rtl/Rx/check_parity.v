module check_parity(clk, serial_in_synced, received_data, is_parity_stage, rx_error); // even parity checker

parameter INPUT_DATA_WIDTH = 8;

input clk, serial_in_synced, is_parity_stage;
input [(INPUT_DATA_WIDTH-1) : 0] received_data;
output reg rx_error = 0; 

reg parity_value; // this is being computed from the received 8-bit data
reg parity_bit;  // this bit is received directly through UART

always @(posedge clk)
begin
    if (is_parity_stage) begin
		parity_bit <= serial_in_synced;
		parity_value <= ^(received_data);
		rx_error <= (parity_bit != parity_value);
    end
end

endmodule

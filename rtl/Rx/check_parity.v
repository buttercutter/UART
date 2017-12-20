module check_parity(clk, serial_in_synced, received_data, data_is_valid, is_parity_stage, rx_error); // even parity checker

input clk, serial_in_synced, data_is_valid, is_parity_stage;
input [7:0] received_data;
output reg rx_error = 0; 

reg parity_value; // this is being computed from the received 8-bit data
reg parity_bit;  // this bit is received directly through UART

always @(posedge clk)
begin
    if (is_parity_stage) begin
	parity_bit <= serial_in_synced;
	parity_value <= ^(received_data);
    end
end

always @(posedge clk)
begin
    if ((data_is_valid) && (parity_bit != parity_value))
	rx_error <= 1;
end

endmodule

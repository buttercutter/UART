module check_parity(clk, reset, serial_in_synced, received_data, is_parity_stage, rx_error); // even parity checker

parameter INPUT_DATA_WIDTH = 8;

input clk, reset, serial_in_synced, is_parity_stage;
input [(INPUT_DATA_WIDTH-1) : 0] received_data;
output reg rx_error; 

reg parity_value; // this is being computed from the received 8-bit data
reg parity_bit;  // this bit is received directly through UART

initial begin
	parity_value = 0;
	parity_bit = 0;
	rx_error = 0;
end

always @(posedge clk)
begin
	if(reset) begin
		rx_error <= 0;
	end

    else begin
		rx_error <= (is_parity_stage) && (parity_bit != parity_value);
    end
end

always @(posedge clk)
begin
	parity_bit <= serial_in_synced;
	parity_value <= ^(received_data);
end

endmodule

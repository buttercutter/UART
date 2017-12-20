module SIPO_shift_register(clk, serial_in, data_is_available, received_data);  // manages sampling-related data signal using SIPO shift register

parameter INPUT_DATA_WIDTH = 8;

input clk, serial_in, data_is_available;
output reg [(INPUT_DATA_WIDTH-1):0] received_data; // SIPO

always @(posedge clk)
begin
    if(data_is_available)
    	received_data <= { serial_in , received_data[7:1] };  // LSB received first by UART definition
end

endmodule

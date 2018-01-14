module SIPO_shift_register(clk, sampling_strobe, serial_in_synced, data_is_available, received_data);  // manages sampling-related data signal using SIPO shift register

parameter INPUT_DATA_WIDTH = 8;

input clk, sampling_strobe, serial_in_synced, data_is_available;
output reg [(INPUT_DATA_WIDTH-1):0] received_data; // SIPO

always @(posedge clk)
begin
    if(sampling_strobe && data_is_available)
    	received_data <= { serial_in_synced , received_data[(INPUT_DATA_WIDTH-1):1] };  // LSB received first by UART definition
end

endmodule

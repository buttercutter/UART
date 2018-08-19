module SIPO_shift_register(clk, reset, data_is_valid, sampling_strobe, serial_in_synced, data_is_available, received_data);  // manages sampling-related data signal using SIPO shift register

parameter INPUT_DATA_WIDTH = 8;

input clk, sampling_strobe, serial_in_synced, data_is_available;
input reset, data_is_valid;

output reg [(INPUT_DATA_WIDTH-1):0] received_data; // SIPO

always @(posedge clk)
begin
	if(reset || data_is_valid)
		received_data <= {INPUT_DATA_WIDTH{1'b0}};

    else if(sampling_strobe && data_is_available)
    	received_data <= { serial_in_synced , received_data[(INPUT_DATA_WIDTH-1):1] };  // LSB received first by UART definition
end

initial begin
	received_data = {INPUT_DATA_WIDTH{1'b0}};
end

`ifdef FORMAL

always @(posedge clk)
begin
	if($past(reset) || $past(data_is_valid))
		assert(received_data == {INPUT_DATA_WIDTH{1'b0}});

    else if($past(sampling_strobe) && $past(data_is_available))
    	assert(received_data == { $past(serial_in_synced) , $past(received_data[(INPUT_DATA_WIDTH-1):1] )});
    
    else assert(received_data == $past(received_data));
end

`endif

endmodule

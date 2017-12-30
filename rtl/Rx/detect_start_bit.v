module detect_start_bit(clk, serial_in_synced, start_detected); // just a falling edge detector

input clk, serial_in_synced;
output reg start_detected = 0; 

reg previously_idle = 1;

always @(posedge clk)
begin
    if((!serial_in_synced) && (previously_idle) && (!start_detected))
		start_detected <= 1;
    else
		start_detected <= 0;
end

always @(posedge clk)
begin
    if(serial_in_synced)
		previously_idle <= 1;
    else
		previously_idle <= 0;
end

endmodule

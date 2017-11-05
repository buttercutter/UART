module detect_start_bit(clk, serial_in, start_detected); // just a falling edge detector

input clk, serial_in;
output reg start_detected = 0; 

reg previously_idle = 1;

always @(posedge clk)
begin
    if((!serial_in) && (previously_idle) && (!start_detected))
	start_detected <= 1;
    else
	start_detected <= 0;
end

always @(posedge clk)
begin
    if(serial_in)
	previously_idle <= 1;
    else
	previously_idle <= 0;
end

endmodule

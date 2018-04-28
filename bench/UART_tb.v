module UART_tb;

	parameter CLK_PERIOD_HALF = 5;
	parameter NUM_OF_CLK = 800000;
	parameter INPUT_DATA_WIDTH = 8;

	reg clk, reset, enable;
	reg [(INPUT_DATA_WIDTH-1):0] i_data;
	wire serial_out, o_busy, data_is_valid, rx_error;
	wire [(INPUT_DATA_WIDTH-1):0] received_data;

	test_UART dut (
		.clk(clk), 
		.reset(reset), 
		.serial_out(serial_out), 
		.enable(enable), 
		.i_data(i_data), 
		.o_busy(o_busy), 
		.received_data(received_data), 
		.data_is_valid(data_is_valid), 
		.rx_error(rx_error)
	);

	initial 
	begin 
		clk = 0; 
		reset = 0; 
	 	enable = 0; 
		i_data = {INPUT_DATA_WIDTH{1'b1}};
	end 

	always #(CLK_PERIOD_HALF) clk = !clk;
	
	initial begin
		$dumpfile("UART_tb.vcd");
		$dumpvars;
		
    	@(posedge clk); 
    	enable <= 1;
    	i_data <= 'b10100011;
    	
    	@(posedge clk); 
    	enable <= 0;
		
		#(NUM_OF_CLK) $finish;
	end
	
endmodule

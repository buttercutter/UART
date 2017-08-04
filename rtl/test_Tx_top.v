module test_Tx_top (clk, serial_out);

input clk;	// system clock
output serial_out;	// serialized message bit from UART transmitter

wire o_busy;
wire enable;
wire start;

wire[7:0] message[0:15];	// user-defined message
assign message[0] = "H";
assign message[1] = "E";
assign message[2] = "L";
assign message[3] = "L";
assign message[4] = "O";
assign message[5] = "_";
assign message[6] = "W";
assign message[7] = "O";
assign message[8] = "R";
assign message[9] = "L";
assign message[10]= "D";
assign message[11]= "!";
assign message[12]= "!";
assign message[13]= " ";
assign message[14]= "\r";
assign message[15]= "\n";

wire[3:0] index;
wire[7:0] i_data = message[index]; 	// equivalent ASCII code in hex radix for each character

Tx_top Tx(.clk(clk), .start(start), .i_data(i_data), .o_busy(o_busy), .serial_out(serial_out));

enable_generator eg (.clk(clk), .en_out(enable), .index(index));   // transmission is enabled/repeated every 500ms

assign start = enable && !o_busy;

endmodule

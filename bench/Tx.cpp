#include <verilated.h>          // Defines common routines
//#include <verilatedos.h>
#include "VTx_top.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <string>
#include <math.h>
#include <bitset>

// We could modify message to be sent to device Rx 
#define MESSAGE		"HELLO_WORLD !!"

#define	TRACE_POSEDGE	if (tfp != NULL) tfp->dump(time_ps*10)
#define	TRACE_NEGEDGE	if (tfp != NULL) tfp->dump(time_ps*10)
#define	TRACE_CLOSE	if (tfp != NULL) tfp->close()

// HALF_48MHz_PERIOD = 10416.7ps or 10.4167ns is half of clock period for 48MHz
#define HALF_48MHz_PERIOD 10416.7
// BAUD_OUT_PERIOD = 104167000ps or 104167ns is the clock period for divided baud (9600bps or 9600Hz)
#define BAUD_OUT_PERIOD 104167000
// RX_SAMPLING_PERIOD = 6510417ps or 6510.417ns is the clock period for Rx (over)-sampling clock (9600Hz*16)
#define RX_SAMPLING_PERIOD 6510417
// oversampling factor = 16
#define CLOCKS_PER_BIT 16


#define Tx_IDLE 0
#define Tx_START_BIT 1
#define Tx_DATA_BIT_0 2
#define Tx_DATA_BIT_1 3
#define Tx_DATA_BIT_2 4
#define Tx_DATA_BIT_3 5
#define Tx_DATA_BIT_4 6
#define Tx_DATA_BIT_5 7
#define Tx_DATA_BIT_6 8
#define Tx_DATA_BIT_7 9
#define Tx_PARITY_BIT 10
#define Tx_STOP_BIT 11


VTx_top *uut;                     // Instantiation of module VTx_top (for capturing all the top-level signals defined in the top-level verilog design file, Tx_top.v )
VerilatedVcdC* tfp = NULL;	// Instantiation of module VerilatedVcdC (for vcd waveform)

double time_ps = 0;       	// Current simulation time in picoseconds

// For UART receiver
bool result_is_correct = false;	// indicates if Rx receives all characters correctly according to UART protocol
bool is_data_bit = false;
bool start_bit_detected = false;	// for decoding data bits and parity bit
unsigned int number_of_baud_clocks_passed;
unsigned int number_of_sampling_clocks_passed;


double sc_time_stamp () {       // Called by $time in Verilog
    return time_ps;        // converts to double, to match
    // what SystemC does
}

void cout_debug_msg(void) {
    cout << " clk = " << (int)uut->clk ;
    cout << " baud_out = " << (int)uut->Tx_top__DOT__bg__DOT__ck_stb ;
    cout << " time_ps = " << time_ps;   
    cout << " uut->start = " << (int)uut->start;
    cout << " uut->serial_out = " << (int)uut->serial_out << endl;
    //cout << "-------------------------------------------------------" << endl;
}

class UART_receiver {

    bool previously_idle = false;   // to be used for detecting falling edge 
    std::string rx_decoded_data;    // to store whatever valid *data* bits that rx had received
    unsigned int first_data_bit;    // to store the value of the first *data* bit received
    unsigned int parity_value;

    public:
	double UART_start_time = 0;

	bool start_bit_is_detected(void) {  // scan for UART start bit (or negative edge in the received data line) using 16x oversampling (for start bit edge detection precision).  So, if baudrate=9600bps, Rx sampling clock will be (9600*16)Hz = 153600Hz
		//cout << "bool start_bit_is_detected(void)" << endl;
		// start decoding/checking UART Tx output AFTER serial_out line drops from '1' to '0'
		if (((int)uut->serial_out == 0) && (previously_idle) && (!start_bit_detected))
		{
		    //cout_debug_msg();
		    UART_start_time = time_ps;
		    cout << "start_bit_falling_edge_is_detected at time = " << UART_start_time << endl;
		    return true;
		}

	        if ((int)uut->serial_out == 1) 	// detect '1' or idle from serial_out
		    previously_idle = true;  
	        else
		    previously_idle = false;

	 	return false;
	}

	bool check_output(unsigned int index) {  // check if the Tx UART serializer works correctly
	  					// this function only checks one bit at a time
	// check for parity error, framing error and break condition (once the Tx FIFO is added, buffer underrun error will be checked as well)
	    //cout_debug_msg();
	    unsigned int received_bit = (unsigned int)uut->serial_out;  // serialized bit, extracting the value of serial_out
	    cout << "Successfully read one bit = " << received_bit << " at index = " << index << " at time = " << time_ps << endl;

	// UART Tx is transmitting 11 characters (1 start bit, 8 data bits, 1 parity bit, 1 stop bit)  

	    // decoding starts
	    
	    // UART start bit
	    if (index == 0) {
		//parity_value = 0;
		assert(received_bit == 0);   // framing error check. In reality, verifying the start bit again at the middle of the start bit prevents the receiver from assembling an incorrect data character due to a misdetected low-going noise spike on the data line
		rx_decoded_data.clear();	// resetting for next character
	    }

	    // Eight data bits
	    else if ((index > 0) && (index < 9)) {
		rx_decoded_data.insert(0, to_string(received_bit)); // reconstructing the received data into read-able format
	    	//cout << "rx_decoded_data = " << rx_decoded_data << endl;
		//cout << "to_string(uut->i_data) = " << std::bitset<8>(uut->i_data).to_string() << endl;
	    	if (index == 8) assert(rx_decoded_data == std::bitset<8>(uut->i_data).to_string());   // just to double confirm that device Rx had received correctly the entire data intended to be transmitted by device Tx. In principle, Rx device does not have knowledge about Tx device's input data for transmission (uut->i_data)

		if (index == 1) {
		    first_data_bit = received_bit;
		    //cout << "        first_data_bit = " << first_data_bit << endl;
		}
		else if (index == 2) {
		    //cout << "first_data_bit = " << first_data_bit << endl;
		    //cout << "At index ==2 , received_bit = " << received_bit << endl;
		    parity_value = first_data_bit ^ received_bit;
		}
		else 
		    parity_value = parity_value ^ received_bit;  // even parity calculation

		//cout << "At index = " << index << " , parity_value = " << parity_value << endl;
	    }

	    // parity bit
	    else if (index == 9) {
		//cout << "received_bit = " << received_bit << endl;
		//cout << "parity_value = " << parity_value << endl;
		assert(received_bit == parity_value);   // parity error check

		cout << "Rx had received a character '" << static_cast<char>(std::stoi(rx_decoded_data,nullptr,2)) << "' correctly" << endl;
	    }

	    // stop bit
	    else if (index == 10) 
		assert(received_bit == 1);   // framing error check

	    else {
		cout << "no need to check" << endl;
		return false;
	    }

	    // decoding ends

	    return true;  // what about break condition ?
	    // A "break condition" occurs when the receiver input is at the "space" (logic low, i.e., '0') level for longer than some duration of time, typically, for more than a character time. This is not necessarily an error, but appears to the receiver as a character of all zero bits with a framing error.
	}
};

void update_clk(void) {

	uut->clk = 1; 
	uut->eval(); 
	TRACE_POSEDGE; 	

	time_ps = time_ps + HALF_48MHz_PERIOD; 

	uut->clk = 0; 
	uut->eval(); 
	TRACE_NEGEDGE; 

	time_ps = time_ps + HALF_48MHz_PERIOD; 
}

int main(int argc, char** argv)
{ 
    // turn on trace or not?
    bool vcdTrace = true;

    unsigned int Clock_Count = 0;  // for checking middle of a bit

    Verilated::commandArgs(argc, argv);   // Remember args
    uut = new VTx_top;   // Create instance of UART transmitter device
    UART_receiver UART_rx;  // create new object

    if (vcdTrace)
    {
        Verilated::traceEverOn(true);

        tfp = new VerilatedVcdC;
 	tfp->set_time_unit("1ps");
	tfp->set_time_resolution("100fs");
        uut->trace(tfp, 99);

        std::string vcdname = argv[0];
        vcdname += ".vcd";
        std::cout << vcdname << std::endl;
        tfp->open(vcdname.c_str());
    }

    const char Tx_message[] = MESSAGE;   // message to be sent to device Rx
    unsigned int message_index = 0;

    uut->start = 0;
    //uut->reset = 0;
    uut->i_data = (int)Tx_message[0];   // ascii-equivalent for the character 'H', first char in "HELLO WORLD !!"
    uut->clk = 0;
    uut->eval();

    double time_sampling = 0;
    unsigned int bit_index = 0;
    unsigned int rx_state = 0;

    while (!Verilated::gotFinish())   
    {
	update_clk();  // for dumping undivided clk signals on vcd waveform

	if (message_index == strlen(Tx_message) + 1) break;    // since this is a UART demonstration, we detach UART rx after finished decoding the 14 given characters, in this case "HELLO WORLD !!"

	number_of_baud_clocks_passed = time_ps/BAUD_OUT_PERIOD;
	number_of_sampling_clocks_passed = time_ps/RX_SAMPLING_PERIOD;

	uut->start = 0;
	//if ( number_of_baud_clocks_passed== 42 ) {cout << "At number_of_baud_clocks_passed == 42 , time_ps = " << time_ps << endl; break;}
	if ( (((number_of_baud_clocks_passed-3)%12) == 0) && ((time_ps-(double)number_of_baud_clocks_passed*(double)BAUD_OUT_PERIOD <= (double)BAUD_OUT_PERIOD/2+(double)HALF_48MHz_PERIOD) && (time_ps-(double)number_of_baud_clocks_passed*(double)BAUD_OUT_PERIOD >= (double)BAUD_OUT_PERIOD/2-(double)HALF_48MHz_PERIOD)) ) {  // repeating for (every 12 baud clock cycles, i.e. after transmitting a character) && (at approximate center between two rising edges of baud clock )
	    if (number_of_baud_clocks_passed != 3) message_index = message_index + 1;

	    if (message_index < strlen(Tx_message)) {
	    	uut->i_data = (int)Tx_message[message_index];	// prepare the next character for transmission

	    	uut->start = 1;  // start signal is an active HIGH pulse between time_ps = 360000000 and time_ps = 370000000
	    }
	    //uut->start = (number_of_baud_clocks_passed == 3) ? 1 : 0;  // start signal is only HIGH for 1 baud_out cycle which is (BAUD_OUT_PERIOD/1000)ns or (BAUD_OUT_PERIOD)ps	    
	}
	//if ( (double)number_of_sampling_clocks_passed*(double)RX_SAMPLING_PERIOD - time_sampling < 0) cout << "number_of_sampling_clocks_passed*RX_SAMPLING_PERIOD - time_sampling = " << (double)number_of_sampling_clocks_passed*(double)RX_SAMPLING_PERIOD - time_sampling << "\tnumber_of_sampling_clocks_passed = " << number_of_sampling_clocks_passed << endl;

	if ( (double)number_of_sampling_clocks_passed*(double)RX_SAMPLING_PERIOD - time_sampling == (double)RX_SAMPLING_PERIOD ) {  // always @(posedge sampling_clock) 
		time_sampling = (double)number_of_sampling_clocks_passed*(double)RX_SAMPLING_PERIOD;  // to emulate /*time_ps is exact multiples of RX_SAMPLING_PERIOD*/)
		//cout << "time_sampling = " << time_sampling << "\tnumber_of_sampling_clocks_passed = " << number_of_sampling_clocks_passed << endl;
		//cout << "rx_state = " << rx_state << endl;
		// state machine for Rx
		switch (rx_state) 
		{
		    case Tx_IDLE:
			//cout << "-----------------------------------------------------------------------" << endl;
		    	cout << "Waiting for start bit ..." << endl; 	
			start_bit_detected = UART_rx.start_bit_is_detected();
			//cout << "start_bit_detected = " << start_bit_detected << endl;
			rx_state = (start_bit_detected) ? Tx_START_BIT : Tx_IDLE;  // keep scanning for start bit at every interval of RX_SAMPLING_PERIOD
			break;

		    case Tx_START_BIT:	
			cout << "-----------------------------------------------------------------------" << endl;
		    	cout << "decoding start bit ..." << endl; 
			cout << "Clock_Count = " << Clock_Count << endl;
			bit_index = 0;  // resetting for next character

		    	if ( Clock_Count == (CLOCKS_PER_BIT/2) - 1 ) { // at the *approximate* middle of a bit
			    Clock_Count = 0;  // reset counter, found the middle
	
			    result_is_correct = UART_rx.check_output(0);  // only check/sample *once* for each bit
		    	    //cout << "result_is_correct = " << result_is_correct << endl;

			    bit_index =  bit_index + 1;

			    if (result_is_correct) 
			    	rx_state = Tx_DATA_BIT_0;   // received start bit correctly, so move on to receiving data bits state
		    	}
		    	else Clock_Count = Clock_Count + 1;   // sampling clock count	

			break;		

		    case Tx_DATA_BIT_0:
		    case Tx_DATA_BIT_1:
		    case Tx_DATA_BIT_2:
		    case Tx_DATA_BIT_3:
		    case Tx_DATA_BIT_4:
		    case Tx_DATA_BIT_5:
		    case Tx_DATA_BIT_6:
		    case Tx_DATA_BIT_7:
		        // UART receiver (UART_rx) will check/sample/decode Tx output at (half of one bit interval which is equivalent to BAUD_OUT_PERIOD/2) after every rising edge of baud_out (9600bps)

		    	if ( Clock_Count == CLOCKS_PER_BIT - 1 ) { // at the *approximate* middle of a bit
			    Clock_Count = 0;  // reset counter, found the middle

			    cout << "-----------------------------------------------------------------------" << endl;
		    	    cout << "decoding data bits [" << bit_index << "] ..." << endl;
	
			    result_is_correct = UART_rx.check_output(bit_index);  // only check/sample *once* for each bit
		    	    //cout << "result_is_correct = " << result_is_correct << endl;

			    bit_index =  bit_index + 1;
			    is_data_bit = (bit_index < 9)? true : false; 

			    if ((result_is_correct) && (!is_data_bit)) 
			    	rx_state = Tx_PARITY_BIT;   // finish receiving 8 data bits correctly, so move on to parity state
		    	}
		    	else Clock_Count = Clock_Count + 1;   // sampling clock count

			break;

		    case Tx_PARITY_BIT:

		    	if ( Clock_Count == CLOCKS_PER_BIT - 1 ) { // at the *approximate* middle of a bit
			    Clock_Count = 0;  // reset counter, found the middle

			    cout << "-----------------------------------------------------------------------" << endl;
		    	    cout << "decoding parity bit ..." << endl;
	
			    result_is_correct = UART_rx.check_output(bit_index);  // only check/sample *once* for each bit
		    	    //cout << "result_is_correct = " << result_is_correct << endl;

			    bit_index =  bit_index + 1;

			    if (result_is_correct) 
			    	rx_state = Tx_STOP_BIT;   // finish receiving parity bit correctly, so move on to stop state
		    	}
		    	else Clock_Count = Clock_Count + 1;   // sampling clock count

			break;

		    case Tx_STOP_BIT: 

		    	if ( Clock_Count == CLOCKS_PER_BIT - 1 ) { // at the *approximate* middle of a bit
			    Clock_Count = 0;  // reset counter, found the middle

			    cout << "-----------------------------------------------------------------------" << endl;
		    	    cout << "decoding stop bit ..." << endl;
	
			    result_is_correct = UART_rx.check_output(bit_index);  // only check/sample *once* for each bit
		    	    //cout << "result_is_correct = " << result_is_correct << endl;

			    bit_index =  bit_index + 1;

			    if (result_is_correct) 
			    	rx_state = Tx_IDLE;   // finish receiving stop bit correctly, so back to idle state
		    	}
		    	else Clock_Count = Clock_Count + 1;   // sampling clock count
			
			break;

		    default : 
			rx_state = Tx_IDLE;
			break;
		} 
	}
    }

    uut->final();               // Done simulating

    TRACE_CLOSE;

    delete uut;

    return 0;
}

// Credit: http://www.raspberry-projects.com/pi/programming-in-c/uart-serial-port/using-the-uart
// http://www.cplusplus.com/forum/general/219754/

#include <iostream>
#include <unistd.h>			//Used for UART
#include <fcntl.h>			//Used for UART
#include <termios.h>			//Used for UART
#include <assert.h>
#include <string.h>

using namespace std;

int main(int argc, char** argv)
{
	//-------------------------
	//----- SETUP USART 0 -----
	//-------------------------
	//At bootup, pins 8 and 10 are already set to UART0_TXD, UART0_RXD (ie the alt0 function) respectively
	int uart0_filestream = -1;
	
	//OPEN THE UART
	//The flags (defined in fcntl.h):
	//	Access modes (use 1 of these):
	//		O_RDONLY - Open for reading only.
	//		O_RDWR - Open for reading and writing.
	//		O_WRONLY - Open for writing only.
	//
	//	O_NDELAY / O_NONBLOCK (same function) - Enables nonblocking mode. When set read requests on the file can return immediately with a failure status
	//											if there is no input immediately available (instead of blocking). Likewise, write requests can also return
	//											immediately with a failure status if the output can't be written immediately.
	//
	//	O_NOCTTY - When set and path identifies a terminal device, open() shall not cause the terminal device to become the controlling terminal for the process.
	uart0_filestream = open("/dev/ttyUSB0", O_RDONLY | O_NOCTTY );//| O_NDELAY);		//Open in non blocking read/write mode
	if (uart0_filestream == -1)
	{
		//ERROR - CAN'T OPEN SERIAL PORT
		printf("Error - Unable to open UART.  Ensure it is not in use by another application\n");
	}
	
	//CONFIGURE THE UART
	//The flags (defined in /usr/include/termios.h - see http://pubs.opengroup.org/onlinepubs/007908799/xsh/termios.h.html):
	//	Baud rate:- B1200, B2400, B4800, B9600, B19200, B38400, B57600, B115200, B230400, B460800, B500000, B576000, B921600, B1000000, B1152000, B1500000, B2000000, B2500000, B3000000, B3500000, B4000000
	//	CSIZE:- CS5, CS6, CS7, CS8
	//	CLOCAL - Ignore modem status lines
	//	CREAD - Enable receiver
	//	IGNPAR = Ignore characters with parity errors
	//	ICRNL - Map CR to NL on input (Use for ASCII comms where you want to auto correct end of line characters - don't use for bianry comms!)
	//	PARENB - Parity enable
	//	PARODD - Odd parity (else even)
	struct termios options;
	tcgetattr(uart0_filestream, &options);
	options.c_cflag = B9600 | CS8 | PARENB | CLOCAL | CREAD;		//<Set baud rate
	options.c_iflag &= ~(ICRNL|IGNCR|INLCR);		// CR, NL related
	//options.c_iflag = INPCK;
	//options.c_cflag |= CS8|PARENB; cfsetispeed(&options, B9600); cfsetospeed(&options, B9600);
	//options.c_cflag &= ~(CRTSCTS|CSTOPB|CSIZE); 
	//options.c_oflag = 0;
	//options.c_lflag = 0;
	tcflush(uart0_filestream, TCIFLUSH);
	tcsetattr(uart0_filestream, TCSANOW, &options);

	// Read up to 16 characters from the port if they are there
	unsigned char rx_buffer[16+1];
	unsigned char received_character[1+1];
	int rx_length;
	unsigned int num_of_characters_received = 0;
	bool valid_data = false;

	//----- CHECK FOR ANY RX BYTES -----
	while(rx_length = read(uart0_filestream, (void*)received_character, 1)) 	//Filestream, buffer to store in, number of bytes to read (max));    http://gd.tuwien.ac.at/languages/c/programming-bbrown/c_075.htm
	{
		if (rx_length < 0)
		{	perror ("The following error occurred");
			//cout << "An error occured (will occur if there are no bytes)" << endl;
		}
		else if (rx_length == 0)
		{	perror ("The following error occurred");
			//cout << "No data waiting" << endl;
		}
		else
		{
			assert(rx_length == 1);

			if (received_character[0] == 'H')
			    valid_data = true;			    

			//Bytes received
			if ( valid_data ) {
			    rx_buffer[num_of_characters_received] = received_character[0];
			    rx_buffer[num_of_characters_received+1] = '\0';
			    cout << "rx_buffer = " << rx_buffer;
			    num_of_characters_received++;
			    //if (num_of_characters_received == 15 || num_of_characters_received == 16)
				printf("received_character = %x\n", received_character[0]);
			}
	
			if (num_of_characters_received == 16) {
			    assert(strcmp((const char*)rx_buffer, "HELLO_WORLD!! \r\n")==0);
			    num_of_characters_received = 0;
			    valid_data = false;
			}
		}
	}
	

	//----- CLOSE THE UART -----
	close(uart0_filestream);
}

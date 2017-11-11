This is a UART softcore.

For now, I only have implemented UART transmitter and receiver without FIFO support

Instruction to use this softcore:
1. Modify baud_generator.v such that your system clock will divide nicely into your desired baudrate
2. Modify sampling_strobe_generator.v such that CLOCKS_PER_BIT fits the agreed baudrate configuration

```
Tx_top(clk, start, i_data, o_busy, serial_out);
```

* clk : UART transmitter clock

* start : a signal to trigger the UART data transmission, please check that o_busy signal is LOW before asserting start signal

* i_data : 8-bit data ready to be sent through UART

* o_busy : if asserted HIGH, UART transmitter is busy

* serial_out : serialized output data



```
Rx_top(clk, serial_in, received_data, rx_error, data_is_valid);
```

* clk : UART receiver clock

* serial_in : serialized input data to be processed

* received_data : processed data

* rx_error : error flag indicating parity error

* data_is_valid : valid flag indicating the received_data signal is ready

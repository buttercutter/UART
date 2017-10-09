This is a UART softcore.

For now, I only have implemented UART transmitter without FIFO

Instruction to use this softcore:
1. Modify baud_generator.v such that your system clock will divide nicely into your desired baudrate


```
Tx_top(clk, start, i_data, o_busy, serial_out);
```

* clk : your system clock

* start : a signal to trigger the UART data transmission, please check that o_busy signal is LOW before asserting start signal

* i_data : 8-bit data ready to be sent through UART

* o_busy : if asserted HIGH, UART transmitter is busy

* serial_out : serialized output data

# Hardware/Software Co-Design System

This project builds a simple hardware/software co-design system on the DE1-SoC FPGA using a Nios V processor configured through Intel Quartus Prime and Platform Designer. The hardware includes a soft-core processor, on-chip memory, a JTAG UART for host communication, and parallel I/O peripherals such as LEDs and switches, all connected through an Avalon memory-mapped interconnect.

On the hardware side, Platform Designer is used to generate the system interconnect and memory map, producing a synthesizable top-level module that is loaded onto the FPGA. This establishes the embedded platform that the software runs on.

On the software side, a C program is written in the Ashling RiscFree IDE to directly interact with memory-mapped hardware registers. The main functionality of the code is to control the LEDR outputs, typically by writing to the LED base address to toggle or mirror values and create a blinking effect at a fixed time interval. The program also uses the JTAG UART to print messages to the console, confirming correct execution and providing basic runtime feedback.

Signal Tap Logic Analyzer is used to observe internal hardware signals such as chipselect, writedata, and data_out during execution. This helps verify that the software-generated memory accesses are correctly reaching the hardware peripherals.

Overall, the project demonstrates how embedded C code running on a soft-core processor can directly control FPGA hardware in real time through memory-mapped I/O, while using debugging tools to validate system behaviour.

## Demo
This is the [Demo](https://youtu.be/NZKGb-wHWeI).

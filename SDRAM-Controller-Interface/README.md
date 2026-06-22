# SDRAM Controller and Nios V System Integration
This project focuses on designing and integrating a custom SDRAM controller within a Nios V-based FPGA system on the DE1-SoC platform. The system interfaces with external SDRAM through both low-level memory control signals and an Avalon Memory-Mapped (Avalon-MM) bus, enabling the processor to perform standard read and write operations to off-chip memory.

A key component of the project is the implementation of an SDRAM controller in Verilog, which manages address decoding, bank selection, and timing control signals such as RAS, CAS, and WE. This controller is then integrated as a custom Platform Designer (Qsys) component and connected to a full embedded system including the Nios V processor, on-chip memory, JTAG UART, and a PLL-generated clock network.

The system is designed to correctly handle byte- and word-level memory access through the Avalon interface while ensuring proper synchronization with the SDRAM clock. Additional work includes verifying memory functionality through C-based test programs running on the Nios V processor and validating system behavior using tools such as Signal Tap.

Overall, the project demonstrates a complete embedded hardware-software co-design workflow, combining FPGA-based memory controller design, system integration using Platform Designer, and software-level verification of hardware functionality.

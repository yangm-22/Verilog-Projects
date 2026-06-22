# FPGA-Based Digital Signal Processing System

This project implements a real-time digital signal processing (DSP) system on the DE1-SoC FPGA platform using Verilog. The system processes live audio signals sampled at 8 kHz through the onboard audio codec, supporting both microphone and line-in inputs, and outputs the processed audio through the line-out interface.

Two main DSP modules are developed: a finite impulse response (FIR) filter and an echo effect processor. The FIR filter is designed using MATLAB-generated coefficients and implemented in a parameterized Verilog structure to remove unwanted frequency components from the input signal. The echo module introduces a delayed feedback path to produce a configurable echo effect, demonstrating time-domain signal manipulation.

A multiplexer is integrated into the design to allow selection between the raw audio signal, FIR-filtered output, and echo-processed output, enabling straightforward comparison and debugging of each processing stage. The project also makes use of Quartus LPMs and modular Verilog design practices to support scalability and efficient hardware implementation.

Overall, the system demonstrates practical FPGA-based audio processing by combining real-time data acquisition, digital filtering, and system-level hardware design.

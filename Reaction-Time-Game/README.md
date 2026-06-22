# Reaction Time Game Description
The reaction time system is implemented using a finite state machine (FSM) that controls the sequence of events for each round. After reset or restart, the FSM enters an initialization/blink state, where the HEX displays flash and all outputs and counters are cleared or set to their initial values. This flashing also acts as a “readying” indicator before each round begins.

The FSM then transitions into a random wait state, where the HEX displays are turned off and an LFSR-generated value is used to create a pseudo-random delay. During this time, the system continuously monitors the inputs to detect any early button presses for cheat detection.

Once the delay expires, the FSM moves into the start state, where the HEX displays turn on and the reaction timer begins. At this point, the system also indicates that the round is active, and the display may visually signal readiness (e.g., steady on vs flashing).

In the response state, the FSM waits for KEY0 or KEY3 to be pressed. The first valid input determines the winner and stops the timer. During this stage, the winner indication is shown by flashing the corresponding player’s LED pattern (Player 1 or Player 2), while the other remains off, making it clear who responded faster.

If a button press occurs before the start signal, the FSM enters a cheat state, where no winner is assigned and the HEX displays show a predefined error pattern depending on which user cheated (or both). Finally, the FSM enters a result state, where the outcome is held on the display and win counters are updated. The system remains in this state until KEY2 is pressed to begin the next round.


## Random Number Generator (LFSR) Description

The random number generator used in this design is implemented using a Linear Feedback Shift Register (LFSR), since Verilog’s built-in $random function is not synthesizable on the FPGA. The LFSR produces a pseudo-random sequence of bits by shifting a register value and feeding back a linear combination of selected bits (taps) using XOR/XNOR logic.

In this implementation, a 14-bit LFSR is used to generate a sufficiently long repeating sequence. Specific tap positions are used to improve the period length and randomness quality. On each clock cycle (when enabled), the register shifts and the feedback bit is inserted into the LSB/MSB depending on the chosen LFSR configuration (Fibonacci or Galois).

The raw 14-bit output is then constrained to a usable range (e.g., 1000–5000) so it can be interpreted as a delay value in milliseconds for the reaction timer. Once a valid number falls within this range, a rnd_ready signal is asserted to indicate that a new random delay has been generated and the system can proceed to the next FSM state.

Overall, the LFSR provides a lightweight and hardware-efficient way to generate unpredictable delays, ensuring that players cannot anticipate when the reaction timer will start.

## Demo
This is the [Game Demo](https://youtu.be/y0KdoscWtSw).

This is the [Random Number Generator Demo](https://youtu.be/13BR8hgjCS8).

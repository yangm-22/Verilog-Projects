
# Program Description

When the program starts, all HEX displays are turned off except HEX0. The input to HEX0 is selected using switches SW9 and SW8. If SW9 and SW8 are both low (`00`), the seven-segment decoder displays the value of switches SW3–SW0. If SW9 is low and SW8 is high (`01`), the decoder displays the value of a 4-bit counter that increments each time KEY3 is pressed. If SW9 is high and SW8 is low (`10`), the decoder displays the four most significant bits of a 30-bit counter driven by the 50 MHz system clock. If SW9 and SW8 are both high (`11`), HEX0 is turned off. Pressing KEY0 resets both the 4-bit button counter and the 30-bit clock counter to zero. All other HEX displays remain off at all times.

## Demo
This is the [Demo](https://youtu.be/4vW4gsypdsc).

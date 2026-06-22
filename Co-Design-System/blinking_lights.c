#include "system.h"
#include <unistd.h>
#include <stdio.h>

int main()
{
    char * LEDs = (char *) LEDS_BASE;
    volatile char * SWs = (char *) SWITCHES_BASE;

    printf("Hello World (Group 6 MT3TB4 2026) \n");

    while (1) {
        *LEDs = 0xFF; // turn all LEDs on
        usleep(1000 * 1000);
        *LEDs = 0x00; // turn all LEDs off
        usleep(1000 * 1000);
        //*LEDs = *SWs;
    }
}

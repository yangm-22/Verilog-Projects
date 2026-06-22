#include "system.h"
#include <unistd.h>
#include <stdio.h>

int main()
{
    char * LEDs = (char *) LEDS_BASE;
    volatile char * SWs = (char *) SWITCHES_BASE;

    printf("Hello World (Group 6 MT3TB4 2026) \n");

    while (1) {
        *LEDs = *SWs;
    }

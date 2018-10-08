/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#ifndef __TERMINAL_H
#define __TERMINAL_H

void    terminalUpdate(void);
void    terminalOpen(void);
Int16   terminalRead(void);
UInt16  terminalState(void);
void    terminalAnimate(void);
void    terminalSetAnimate(const UInt16 * animate);

#define KEY_NO          -1
#define KEY_M1          0
#define KEY_M2          1
#define KEY_M3          2
#define KEY_M4          3
#define KEY_M5          4
#define KEY_HELP        5
#define KEY_PLAY        6
#define KEY_STOP        7
#define KEY_PLUS_10     8
#define KEY_MINUS_10    9
#define KEY_PLUS_1      10
#define KEY_MINUS_1     11
#define KEY_TEACHER     12
#define KEY_NEXT        13
#define KEY_PREV        14
#define KEY_X           15

#define LEDON(x)        ledStatic   |=  x; ledFlashing &=  ~x;
#define LEDOFF(x)       ledStatic   &= ~(x); ledFlashing &= ~(x);
#define LEDFLASH(x)     ledFlash    |=  x;
#define LEDFLASHING(x)  ledFlashing |=  x;

#define LED_M1          0x0001
#define LED_M2          0x0002
#define LED_M3          0x0004
#define LED_M4          0x0008
#define LED_M5          0x0010
#define LED_HELP        0x0020
#define LED_V3          0x0100
#define LED_V4          0x0200
#define LED_V5          0x0400
#define LED_V6          0x0800
#define LED_TEACHER     0x1000
#define LED_LEVELS (LED_V3|LED_V4|LED_V5|LED_V6|LED_TEACHER)

extern UInt16 ledFlash;
extern UInt16 ledStatic;
extern UInt16 ledFlashing;

EXPORT const UInt16 stdAnimeL[];
EXPORT const UInt16 stdAnimeR[];
EXPORT const UInt16 stdAnimePP[];
EXPORT const UInt16 stdAnimeM[];
EXPORT const UInt16 stdLevels[];
EXPORT const UInt16 stdPos[];

#endif
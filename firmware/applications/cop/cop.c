/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:   cop.c
*
* Description: Computer Operating Properly (COP) module application
*
* The sample application is available only for INTERNAL MEMORY configuration.
* The OnCE module MUST BE DISABLED. COP module do not provide reset reset 
* generation during debug session (when OnCE module is active). You can 
* disable OnCE port by "CC DIS" jamper on the EVM module (see the EVM's 
* reference manual).
*
*****************************************************************************/

#include "port.h"
#include "io.h"
#include "fcntl.h"
#include "bsp.h"
#include "led.h"
#include "cop.h"


asm void copTimeoutISR(void);

static UWord16 LedFD;


/******************************************************************************
* 
* The following line defines the variable in the ".available" memory segment, 
* that is NOT initialized during SDK startup (see the linker.cmd file). This 
* variable saves the previous state of the COP RESET LED.
*
******************************************************************************/

#define COP_RESET_COUNTER (*((UInt16*) 0x0000))


/******************************************************************************
* 
* Macro to indicate SYSTEM STATUS (Reset Sources)
*
* void DisplaySysStatus (void );
*
* The EVM boards have the different LEDs for various DSP chip. 
* So the application has not the possibility to indicate all 
* states for DSP56F801 and DSP56F803 EVMs.
*
* For ALL platforms:
*
* GREEN LED  - blinks if COP TIMEOUT expired (the blinking frequency is half 
*              of COP TIMEOUT frequency)
*
* For DSP56F805/807 only:
*
* RED LED    - glows if POWER ON RESET expired 
* YELLOW LED - glows if EXTERNAL RESET expired (you pressed RESET button on 
*              the EVM board)
*
******************************************************************************/
#if defined(LED_RED) && defined(LED_YELLOW)

	#define DisplaySysStatus() 													\
	{																			\
		if ( copGetSysStatus(PWR_RESET) ) ioctl(LedFD,  LED_ON,  LED_RED);		\
		if ( copGetSysStatus(EXT_RESET) ) ioctl(LedFD,  LED_ON,  LED_YELLOW);	\
		if ( copGetSysStatus(COP_RESET) ) ioctl(LedFD,  LED_ON,  LED_GREEN);	\
	}
		
#else

	#define DisplaySysStatus() 													\
	{																			\
		if ( copGetSysStatus(COP_RESET) ) ioctl(LedFD,  LED_ON,  LED_GREEN);	\
	}

#endif


/******************************************************************************
* 
*	main() - COP application MAIN function
*
*	The main function displays the reset sources which ensued since board 
*   power on.
*
*   You can use copReload() service to avoid COP TIMEOUT, that is the 
*   watchdog timer.
*
******************************************************************************/
void main(void )
{

	/* Open LED's driver */
	LedFD  = open(BSP_DEVICE_NAME_LED_0,  0);

	/* Check COP TIMEOUT status */
	if ( copGetSysStatus(COP_RESET) )
	{
		/* Clear every second event to provide GREEN LED blinking */
		if (COP_RESET_COUNTER & 0x0001)
		{
			copClrSysStatus(COP_RESET);
		}
	}

	do 
    {
    	/* 
    		To avoid COP reset use the following function call:
    		copReload();   
    	*/

		/* Indicate RESET SOURCE (from System Status register) */
		DisplaySysStatus();
    }
    while (1);

}


/******************************************************************************
* 
*	void copTimeoutISR(void )
*
*	COP module Interrupt Service Routine. The function increments 
*   COP_COUNTER_RESET variable and pass control to the SDK's startup
*   routine. You must write it on the assembler language, because
*   there are nothing which have been initialized after COP reset.
*
******************************************************************************/
asm void copTimeoutISR(void )
{
	move	#-1,x0
	move	x0,m01          /* ; Set the m register to linear addressing */

	move     X:0x0000,X0	/* ; Increment COP_COUNTER_RESET */
	incw     X0
	move     X0,X:0x0000

	jsr 	archStart		/* ; The STARTUP procedure of the SDK */
}
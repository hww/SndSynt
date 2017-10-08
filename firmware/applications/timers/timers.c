/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: timers.c 
*
* Description: ADC device driver
*
* Modules Included: 
*			< Timer1ISR >
*			< Timer2ISR >
*			< main >
*
*****************************************************************************/


#include "port.h"
#include "arch.h"

#include "io.h"
#include "timer.h"
#include "fcntl.h"
#include "led.h"

static int LedFD;

/*****************************************************************************
*
* Module: Timer1ISR
*
* Description: POSIX timer signal function 
*
* Returns: none
*
* Arguments: none
*
* Range Issues: 
*
* Special Issues: 
*
* Test Method: 
*
*****************************************************************************/
static void Timer1ISR(union sigval)
{
#ifdef LED_YELLOW
	ioctl((LedFD),  LED_TOGGLE, LED_YELLOW);
#endif
#ifdef LED_YELLOW2
	ioctl((LedFD),  LED_TOGGLE, LED_YELLOW2);
#endif
}


/*****************************************************************************
*
* Module: Timer2ISR
*
* Description: POSIX timer signal function 
*
* Returns: none
*
* Arguments: none
*
* Range Issues: 
*
* Special Issues: 
*
* Test Method: 
*
*****************************************************************************/
static void Timer2ISR(union sigval)
{		
#ifdef LED_RED
	ioctl(LedFD,  LED_TOGGLE, LED_RED);
#endif
#ifdef LED_RED2
	ioctl(LedFD,  LED_TOGGLE, LED_RED2);
#endif
}


/*****************************************************************************
*
* Module: main
*
* Description: POSIX timer test application 
*
* Returns: none
*
* Arguments: none
*
* Range Issues: 
*
* Special Issues: 
*
* Test Method: 
*
*****************************************************************************/
void main(void)
{
	struct sigevent   Timer1Event;
	struct sigevent   Timer2Event;
	timer_t           Timer1;
	timer_t           Timer2;
	struct itimerspec Timer1Settings;
	struct itimerspec Timer2Settings;
	struct timespec   HalfSecond      = {0, 500000000};
	
	LedFD  = open(BSP_DEVICE_NAME_LED_0,  0);

	Timer1Event.sigev_notify_function = Timer1ISR;

	timer_create(CLOCK_AUX1, &Timer1Event, &Timer1);

	Timer1Settings.it_interval.tv_sec  = 0;
	Timer1Settings.it_interval.tv_nsec = 250000000;
	Timer1Settings.it_value.tv_sec     = 0;
	Timer1Settings.it_value.tv_nsec    = 250000000;

	timer_settime(Timer1, 0, &Timer1Settings, NULL);



	Timer2Event.sigev_notify_function = Timer2ISR;

	timer_create(CLOCK_AUX2, &Timer2Event, &Timer2);


	Timer2Settings.it_interval.tv_sec  = 0;
	Timer2Settings.it_interval.tv_nsec = 125000000;
	Timer2Settings.it_value.tv_sec     = 0;
	Timer2Settings.it_value.tv_nsec    = 125000000;

	timer_settime(Timer2, 0, &Timer2Settings, NULL);

	while(1)
	{
		nanosleep(&HalfSecond, NULL);
		ioctl(LedFD,  LED_TOGGLE, LED_GREEN);
		ioctl(LedFD,  LED_TOGGLE, LED_GREEN2);
	}
}

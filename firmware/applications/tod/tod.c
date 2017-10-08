#include "port.h"
#include "bsp.h"
#include "io.h"
#include "led.h"
#include "tod.h"


#define CLOCK_ALARM 5

static int LedFD;
 
static void ClockInterrupt(void);

static void ClockInterrupt(void)
{
	ioctl(LedFD,  LED_TOGGLE, LED_GREEN);
}

void main (void)
{
	struct timespec   InitialTime;
	struct sigevent   TimerEvent;
	struct itimerspec SetAlarm;
	timer_t           Timer;
	
	LedFD  = open(BSP_DEVICE_NAME_LED_0,  0);
			
	InitialTime.tv_sec = 0;
  	
   	/* Set TOD initial time */
  	clock_settime(CLOCK_TOD, &InitialTime);
  	
  	/* Install TOD interrupt and corresponding callback */
	TimerEvent.sigev_signo           = TOD_ALARM_INTERRUPT;
 	TimerEvent.sigev_notify_function = ClockInterrupt;
  	timer_create (CLOCK_TOD, &TimerEvent, &Timer);
  
  	/* Set up TOD alarm */
 	SetAlarm.it_value.tv_sec    = CLOCK_ALARM;
 	SetAlarm.it_interval.tv_sec = CLOCK_ALARM;
  	timer_settime(Timer, 0, &SetAlarm, NULL); 

	while(1)
	{
				
	}


}

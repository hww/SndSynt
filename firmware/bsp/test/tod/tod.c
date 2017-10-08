#include "port.h"
#include "bsp.h"
#include "tod.h"
#include "timer.h"
#include "test.h"


#define TOD_INITIAL_ALARM   70
#define TOD_SECOND_ALARM     5
#define CLOCK_SECOND_ALARM   5
#define CLOCK_ALARM         70

static void TodInterrupt(void);
static void ClockInterrupt(void);
static void TodTimerISR(void);

static bool             bTodDoneFlag      = false;
static UWord16          TodTimerCount     = 0;
static UWord16          TodInterruptCount = 0;
static struct tm        GetTime;
static struct timespec  GetClockTime;


/*****************************************************************************/
static void TodTimerISR(void)
{
	TodTimerCount += 1;
}

/*****************************************************************************/
static void TodInterrupt(void)
{
	TodInterruptCount += 1;
		
	if(TodInterruptCount == 2)
	{	
		todGetTime(&GetTime);
		bTodDoneFlag = true;
	}
}

/*****************************************************************************/
static void ClockInterrupt(void)
{
	TodInterruptCount += 1;
	
	if(TodInterruptCount == 2)
	{
		clock_gettime(CLOCK_TOD, &GetClockTime);	
		bTodDoneFlag = true;
	}
}

/*****************************************************************************/
void main (void)
{
	int               TodFD;
	struct timespec   InitialTime;
	struct sigevent   TimerEvent;
	struct sigevent   TodCallBack;
	struct sigevent   Timer1Event;
	struct itimerspec Timer1Settings;
	struct itimerspec SetAlarm;
	timer_t           Timer1;
	timer_t           Timer2;
	test_sRec         testRec;
			
	/* Set TOD initial time */
	InitialTime.tv_sec = 0;
	
	TodFD = todOpen(BSP_DEVICE_TIME_OF_DAY, 0, &InitialTime);
	
	/* Set TOD callback for alarm interrupt */
	TodCallBack.sigev_signo           = TOD_ALARM_INTERRUPT;
 	TodCallBack.sigev_notify_function = TodInterrupt;
	
	todEnableCallBacks(TodFD, &TodCallBack);

	/* Enable TOD device */
	todIoctl(TodFD,	TOD_ENABLE, 0);
	
	/* Set Alarm */
	SetAlarm.it_value.tv_sec    = TOD_INITIAL_ALARM; /* Alarm will go off after 1 minute 10 seconds */
 	SetAlarm.it_interval.tv_sec = TOD_SECOND_ALARM;  /* The reload value being set to five
 	                                                    indicates   that after the initial alarm, interrupts
 	                                                    will occur 5 seconds after each minute */ 
 	
	todSetAlarm(TodFD, &SetAlarm);
		
	/* Configure timer for 1 second interrupt */
	Timer1Event.sigev_notify_function = TodTimerISR;

	timer_create(CLOCK_AUX1, &Timer1Event, &Timer1);

	Timer1Settings.it_interval.tv_sec  = 1;
	Timer1Settings.it_interval.tv_nsec = 0;
	Timer1Settings.it_value.tv_sec     = 1;
	Timer1Settings.it_value.tv_nsec    = 0;

	timer_settime(Timer1, 0, &Timer1Settings, NULL);
	
	testStart(&testRec, "This test will take 4 minutes 10 seconds to complete\nTesting TOD Low Level Interface...");
			
	/* Enable Alarm */
	todIoctl(0,	TOD_ENABLE_ALARM_IRQ, 0);
	
	while(1)
	{
		if(bTodDoneFlag == true)
		{
			time_t TimerCount = 0;
			
			TimerCount = mktime(&GetTime);
			
			if((TimerCount >= (TodTimerCount - 1)) & (TimerCount <= (TodTimerCount + 1)))
			{
				testComment(&testRec, "TOD Low Level Test - PASSED");
			}   
   			else
			{
				testFailed(&testRec, "TOD Low Level Test - FAILED");
			}
			
			break;	
		}
	}

	todClose(TodFD);
	
	testEnd(&testRec);

	testStart(&testRec, "Testing TOD High Level Interface...");
	
	bTodDoneFlag       = false;
	InitialTime.tv_sec = 0;
  	
   	/* Set TOD initial time */
  	clock_settime(CLOCK_TOD, &InitialTime);
  	
  	/* Install TOD interrupt and corresponding callback */
	TimerEvent.sigev_signo           = TOD_ALARM_INTERRUPT;
 	TimerEvent.sigev_notify_function = ClockInterrupt;
  	timer_create (CLOCK_TOD, &TimerEvent, &Timer2);
  
  	/* Set up TOD alarm */
 	SetAlarm.it_value.tv_sec    = CLOCK_ALARM;
 	SetAlarm.it_interval.tv_sec = CLOCK_SECOND_ALARM;
  	timer_settime(Timer2, 0, &SetAlarm, NULL); 
	
	/* Reset interrupt counts */
	TodInterruptCount = 0;
	TodTimerCount     = 0;

	while(1)
	{
		if(bTodDoneFlag == true)
		{
			if((GetClockTime.tv_sec >= (TodTimerCount - 1)) & (GetClockTime.tv_sec <= (TodTimerCount + 1)))
			{
				testComment(&testRec, "TOD High Level Test - PASSED");
			}   
   			else
			{
				testFailed(&testRec, "TOD High Level Test - FAILED");
			}
			
			break;	
		}
	}

	testEnd(&testRec);
}

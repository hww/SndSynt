/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   toddrv.c
*
* DESCRIPTION: source file for the TOD device driver
*
*******************************************************************************/
#include "port.h"
#include "arch.h"
#include "assert.h"

#include "bsp.h"
#include "sim.h"
#include "time.h"
#include "tod.h"
#include "const.h"
#include "mempx.h"

/******************************************************************************
* Private TOD #defines
*******************************************************************************/
#define TOD_SECS_ALARM_MASK   0x0010
#define TOD_MINS_ALARM_MASK   0x0020
#define TOD_HRS_ALARM_MASK    0x0040
#define TOD_DAYS_ALARM_MASK   0x0080
#define TOD_CONTROL_REGISTER  0x4004
#define TOD_DAYS_IN_YEAR      365
#define TOD_MAX_DAYS          65535

/******************************************************************************
* TOD private type definitions and structures
*******************************************************************************/
typedef struct {
	UWord16           ControlRegister;
	struct tm         ReloadAlarm;
	union sigval      CallbackArg;
	void            * (*pCallback)(union sigval CallbackArg);
} tod_sTod;

static tod_sTod TodAlarmInterrupt;
static tod_sTod TodOneSecInterrupt;

static UWord16 CalculateControlMask(UWord32);
static void TodAlarmCallBack (void);
static void TodOneSecCallBack(void);

/******************************************************************************/
static UWord16 CalculateControlMask(UWord32 Seconds)
{
	struct tm * pTemp;
	UWord16     ControlRegister = 0;

	pTemp = localtime(&Seconds);

	if(pTemp -> tm_sec > 0)
	{
		periphBitSet(TOD_SECS_ALARM_MASK, &(ControlRegister));                                       
	}
	else
	{
		periphBitClear(TOD_SECS_ALARM_MASK, &(ControlRegister));
	}

	if(pTemp -> tm_min > 0)
	{
		periphBitSet(TOD_MINS_ALARM_MASK, &(ControlRegister));  
	}
	else
	{
		periphBitClear(TOD_MINS_ALARM_MASK, &(ControlRegister));
	}
	
	if(pTemp -> tm_hour > 0)
	{
		periphBitSet(TOD_HRS_ALARM_MASK, &(ControlRegister)); 
	}
	else
	{
		periphBitClear(TOD_HRS_ALARM_MASK, &(ControlRegister)); 
	}

	if(pTemp -> tm_yday > 0)
	{
		periphBitSet(TOD_DAYS_ALARM_MASK, &(ControlRegister)); 
	}
	else
	{
		periphBitClear(TOD_DAYS_ALARM_MASK, &(ControlRegister)); 
	}

	return(ControlRegister | TOD_CONTROL_REGISTER);
}

/******************************************************************************/
static void TodAlarmCallBack(void)
{
	UWord16 ControlRegister = TodAlarmInterrupt.ControlRegister;
	
			
	if (TodAlarmInterrupt.pCallback != NULL)
	{
		TodAlarmInterrupt.pCallback(TodAlarmInterrupt.CallbackArg);
	}

	todIoctl(0,	TOD_LOAD_SECS_ALARM_VALUE, TodAlarmInterrupt.ReloadAlarm.tm_sec); 
	todIoctl(0,	TOD_LOAD_MINS_ALARM_VALUE, TodAlarmInterrupt.ReloadAlarm.tm_min);
	todIoctl(0,	TOD_LOAD_HRS_ALARM_VALUE,  TodAlarmInterrupt.ReloadAlarm.tm_hour);
	todIoctl(0,	TOD_LOAD_DAYS_ALARM_VALUE, TodAlarmInterrupt.ReloadAlarm.tm_yday);
	
	ControlRegister = ControlRegister | (0xFF0F & (todIoctl(0, TOD_READ_CONTROL_REGISTER, NULL)));

	todIoctl(0, TOD_CONFIGURE_CONTROL_REGISTER, ControlRegister);
		
	todIoctl(0,	TOD_CLEAR_ALARM_IRQ, 0);
}

/******************************************************************************/
static void TodOneSecCallBack(void)
{
	if (TodOneSecInterrupt.pCallback != NULL)
	{
		TodOneSecInterrupt.pCallback(TodOneSecInterrupt.CallbackArg);
	}
	
	todIoctl(0, TOD_CLEAR_ONE_SEC_IRQ, 0);
}

/******************************************************************************/
int todOpen(const char * pName, int Flags, void  * pParams)
{
	struct timespec * pTodTime = (struct timespec *)pParams;
	struct tm       * pSetTime;
	UWord16           TodDays = 0;
	UWord16           ControlRegister = 0x0000;
	
	if(pName != BSP_DEVICE_TIME_OF_DAY)
	{
		return (-1); /* not my device */
	}

	/* Clear control register */
	todIoctl(0, TOD_CONFIGURE_CONTROL_REGISTER, ControlRegister);

	pSetTime = localtime(&(pTodTime -> tv_sec));

	todIoctl(0,	TOD_DISABLE, 0);

	todIoctl(0,	TOD_LOAD_CLOCK_SCALER, TodClockScaler);
	
	pSetTime -> tm_sec += 1; 

	todIoctl(0,	TOD_LOAD_SECS_VALUE, pSetTime -> tm_sec); 
	todIoctl(0,	TOD_LOAD_MINS_VALUE, pSetTime -> tm_min);
	todIoctl(0,	TOD_LOAD_HRS_VALUE,  pSetTime -> tm_hour);
		
	TodDays = ((pSetTime -> tm_year) * TOD_DAYS_IN_YEAR) + pSetTime -> tm_yday; 
	
	todIoctl(0,	TOD_LOAD_DAYS_VALUE, TodDays);
	
	return 0;
}

/******************************************************************************/
int todEnableCallBacks(int TodFd, struct sigevent * pParams)
{
	struct sigevent * pEventParams = pParams;
	
	/* install TOD alarm interrupt */
	if(pEventParams -> sigev_signo == TOD_ALARM_INTERRUPT)
	{
		TodAlarmInterrupt.pCallback   = pEventParams -> sigev_notify_function;
		TodAlarmInterrupt.CallbackArg = pEventParams -> sigev_value;
		archInstallISR(&(pArchInterrupts -> TODAlarmInterrupt), TodAlarmCallBack);
	}

	/* install TOD one second interrupt */
	if(pEventParams -> sigev_signo == TOD_ONE_SEC_INTERRUPT)
	{
		TodOneSecInterrupt.pCallback   = pEventParams -> sigev_notify_function;
		TodOneSecInterrupt.CallbackArg = pEventParams -> sigev_value;
		archInstallISR(&(pArchInterrupts -> TODOneSecondInterrupt), TodOneSecCallBack);
	}
	
	return 0;
}

/******************************************************************************/
int todSetAlarm(int TodFd, struct itimerspec * pValue)
{
	struct tm * pSetAlarm;
	UWord16     ControlRegister;
	
	pSetAlarm = localtime(&pValue -> it_value.tv_sec);
	
	/* Write to the Seconds register */
	todIoctl(0,	TOD_LOAD_SECS_ALARM_VALUE, pSetAlarm -> tm_sec); 
	
	/* Write to the Minutes register */
	todIoctl(0,	TOD_LOAD_MINS_ALARM_VALUE, pSetAlarm -> tm_min);
			
	/* Write to the Hour register */
	todIoctl(0,	TOD_LOAD_HRS_ALARM_VALUE, pSetAlarm -> tm_hour);
		
	/* Write to the Days register */
	todIoctl(0,	TOD_LOAD_DAYS_ALARM_VALUE, pSetAlarm -> tm_yday);

	/* Obtain configuration of control register */
	ControlRegister = CalculateControlMask(pValue -> it_value.tv_sec);
	
	/* Read control register */
	ControlRegister = ControlRegister | (0xFF0F &(todIoctl(0, TOD_READ_CONTROL_REGISTER, NULL)));

	/* Write configuration to control register for first alarm value */
	todIoctl(0, TOD_CONFIGURE_CONTROL_REGISTER, ControlRegister);
	
	pSetAlarm = localtime(&pValue -> it_interval.tv_sec);
	memcpy((void *)(&(TodAlarmInterrupt.ReloadAlarm)), pSetAlarm, sizeof(struct tm));
	
	TodAlarmInterrupt.ReloadAlarm.tm_yday = ((TodAlarmInterrupt.ReloadAlarm.tm_year) * TOD_DAYS_IN_YEAR) + 
												TodAlarmInterrupt.ReloadAlarm.tm_yday; 
					
		/* Obtain configuration of control register for reload alarm value */
	TodAlarmInterrupt.ControlRegister = CalculateControlMask(pValue -> it_interval.tv_sec);
		
	return 0;
}
 
/******************************************************************************/
struct tm * todGetTime(struct tm * pGetTime)
{
	/* Initialize structure elements to 0 */
	pGetTime -> tm_sec  = 0;
	pGetTime -> tm_min  = 0;
	pGetTime -> tm_hour = 0;
	pGetTime ->	tm_mday = 0;
	pGetTime -> tm_mon  = 0;
	pGetTime -> tm_year = 0;
	pGetTime -> tm_wday = 0;
	pGetTime ->	tm_yday = 0;
	pGetTime -> tm_isdst= 0;
	
	/* Read the Seconds register */
	pGetTime -> tm_sec = todIoctl(0, TOD_READ_SECS_VALUE, NULL); 

	/* Read the Minutes register */
	pGetTime -> tm_min = todIoctl(0, TOD_READ_MINS_VALUE, NULL);

	/* Read the Hour register */
	pGetTime -> tm_hour = todIoctl(0, TOD_READ_HRS_VALUE, NULL);

	/* Read the Days register */
	pGetTime -> tm_mday = todIoctl(0, TOD_READ_DAYS_VALUE, NULL) + 1;
	
	return pGetTime;
}

/******************************************************************************/
int todClose(int TodFd)
{
	UWord16 ControlRegister = 0x0000;
	
	/* Clear control register */
	todIoctl(0, TOD_CONFIGURE_CONTROL_REGISTER, ControlRegister);
	
	return 0;
}


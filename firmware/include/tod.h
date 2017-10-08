/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000, 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: tod.h
*
* DESCRIPTION: Public header file for the TOD device driver
*
*******************************************************************************/
#ifndef __TOD_H
#define __TOD_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_TIME_OF_DAY
		#error INCLUDE_TIME_OF_DAY must be defined in appconfig.h to initialize the TOD driver
	#endif
#endif


#include "port.h"
#include "time.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_LED)
	#include "io.h"
	#include "fcntl.h"
#endif


#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56F826 processor has a Time of Day (TOD) device implemented as a 
*  sequence of counters to keep track of elapsed time.   
*
******************************************************************************/


/*****************************************************************************
* 
* TODOPEN
*
* int todOpen(const char * pName, int Flags, void  * pParams)
*
* Semantics:
*     Open the particular TOD peripheral for operations. Argument pName is the 
*     particular TOD device name. 
*
* Parameters:
*     pName    - device name. Use BSP_DEVICE_TIME_OF_DAY 
*     OFlags   - open mode flags. Ignored. 
*     pParams  - pointer to struct timespec. Contains the Initial Time for
*                the TOD device in seconds.
*
* Return Value: 
*     TOD device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*     
* struct timespec  InitialTime;
*
* InitialTime.tv_sec = 0;
* 
* todOpen(BSP_DEVICE_TIME_OF_DAY, 0, &InitialTime); 
*
*****************************************************************************/


/*****************************************************************************
* 
* TODSETALARM
*
* int todSetAlarm(int TodFd, struct itimerspec * pValue);
*
* Semantics:
*     This function is used to set up the TOD alarm value.
* 
* Parameters:
*     TodFd    - file descriptor from return of todopen call. 
*     pValue   - pointer to struct itimerspec. Contains the TOD Alarm
*                value in seconds. 
*		
* Example:
* 
* struct itimerspec  SetAlarm;
*
* SetAlarm.it_value.tv_sec    = 5; // first alarm will go off after 5 seconds
* SetAlarm.it_interval.tv_sec = 3; // reload alarm value, alarm will go off
*                                  // 3 seconds after each minute 
* todSetAlarm(TodFd, &SetAlarm);  
* 
*****************************************************************************/


/*****************************************************************************
* 
* TODGETTIME
*
* struct tm *        todGetTime(struct tm * pGetTime);
*
* Semantics:
*     This function is used to get the current time of the TOD device.
* 
* Parameters:
*     pGetTime - a pointer to struct tm. The todGetTime function fills this
*                structure with the current time.
*
* Example:
* 
* struct tm GetTime;
*		
* todGetTime(&GetTime); 
* 
*****************************************************************************/


/*****************************************************************************
*
* TODIOCTL
*
*     int todIoctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*	The TOD supports the following commands:   
*           
*	TOD_ENABLE                              Enable TOD operation          
*	TOD_ALLOW_WRITE_TO_REGISTERS            Allow writes to TOD registers
*	TOD_ENABLE_ALARM_IRQ                    TOD Alarm IRQ enable
*	TOD_DISABLE_ALARM_IRQ                   TOD Alarm IRQ disable
*	TOD_ENABLE_ONE_SEC_IRQ                  TOD One Second IRQ enable 
*	TOD_DISABLE_ONE_SEC_IRQ                 TOD One Second IRQ disable 
*	TOD_ENABLE_SEC_ALARM                    TOD Seconds Alarm enable  
*	TOD_DISABLE_SEC_ALARM                   TOD Seconds Alarm disable
*	TOD_ENABLE_MIN_ALARM                    TOD Minutes Alarm enable
*	TOD_DISABLE_MIN_ALARM                   TOD Minutes Alarm disable
*	TOD_ENABLE_HR_ALARM                     TOD Hours Alarm enable
*	TOD_DISABLE_HR_ALARM                    TOD Hours Alarm disable
*	TOD_ENABLE_DAY_ALARM                    TOD Days Alarm enable
*	TOD_DISABLE_DAY_ALARM                   TOD Days Alarm disable
*	TOD_CLEAR_ALARM_IRQ                     TOD Alarm IRQ clear
*	TOD_CLEAR_ONE_SEC_IRQ                   TOD One Second IRQ clear
*	TOD_LOAD_CLOCK_SCALER                   Scaler to produce 1 Hz clock
*	TOD_LOAD_SECS                           Loads Seconds register 
*	TOD_LOAD_SECS_ALARM                     Loads Seconds Alarm register
*	TOD_LOAD_MINS                           Loads Minutes register
*	TOD_LOAD_MINS_ALARM                     Loads Minutes Alarm register
*	TOD_LOAD_HRS                            Loads Hours register
*	TOD_LOAD_HRS_ALARM                      Loads Hours Alarm register
*	TOD_LOAD_DAYS                           Loads Days register
*	TOD_LOAD_DAYS_ALARM                     Loads Days Alarm register
*	TOD_READ_SECS                           Reads Seconds register
*	TOD_READ_MINS                           Reads Minutes register
*	TOD_READ_HRS                            Reads Hours register
*	TOD_READ_DAYS                           Reads Days register
*	TOD_CONFIGURE_CONTROL_REGISTER          Configure TOD control register
*	TOD_READ_CONTROL_REGISTER               Read Control register
*	TOD_ENABLE_CALLBACKS					Enables interrupts and sets up
*                                            callback functions
*
*	Example:
*
*   // enable TOD operation
*   todIoctl(0,	TOD_ENABLE, 0);
*
*****************************************************************************/


/*****************************************************************************
*
* TODCLOSE
*
* int todClose(int TodFd)
*
* Semantics:
*     Close TOD device.
*
* Parameters:
*     FileDesc - TOD Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/


/*****************************************************************************
* TOD IOCTL Commands 
*****************************************************************************/
#define TOD_ENABLE          
#define TOD_ALLOW_WRITE_TO_REGISTERS
#define TOD_ENABLE_ALARM_IRQ
#define TOD_DISABLE_ALARM_IRQ
#define TOD_ENABLE_ONE_SEC_IRQ
#define TOD_DISABLE_ONE_SEC_IRQ
#define TOD_ENABLE_SEC_ALARM
#define TOD_DISABLE_SEC_ALARM
#define TOD_ENABLE_MIN_ALARM
#define TOD_DISABLE_MIN_ALARM
#define TOD_ENABLE_HR_ALARM
#define TOD_DISABLE_HR_ALARM
#define TOD_ENABLE_DAY_ALARM
#define TOD_DISABLE_DAY_ALARM
#define TOD_CLEAR_ALARM_IRQ
#define TOD_CLEAR_ONE_SEC_IRQ
#define TOD_LOAD_CLOCK_SCALER
#define TOD_LOAD_SECS 
#define TOD_LOAD_SECS_ALARM
#define TOD_LOAD_MINS
#define TOD_LOAD_MINS_ALARM
#define TOD_LOAD_HRS
#define TOD_LOAD_HRS_ALARM
#define TOD_LOAD_DAYS
#define TOD_LOAD_DAYS_ALARM
#define TOD_READ_SECS
#define TOD_READ_MINS
#define TOD_READ_HRS
#define TOD_READ_DAYS
#define TOD_CONFIGURE_CONTROL_REGISTER
#define TOD_READ_CONTROL_REGISTER
#define TOD_ENABLE_CALLBACKS


/*****************************************************************************
* TOD Interrupt #defines
******************************************************************************/
#define TOD_ALARM_INTERRUPT    34
#define TOD_ONE_SEC_INTERRUPT  35

#ifdef __cplusplus
}
#endif

#include "toddrv.h"
													
#endif

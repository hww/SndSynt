/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         toddrv.h
*
* Description:       Header file for the DSP56826 TOD device driver.      
*
* 
*****************************************************************************/
#ifndef __TODDRV_H
#define __TODDRV_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_TIME_OF_DAY
		#error INCLUDE_TIME_OF_DAY must be defined in appconfig.h to initialize the TOD Library
	#endif
#endif

#include "port.h"
#include "io.h"
#include "periph.h"
#include "arch.h"
#include "tod.h"

#ifdef __cplusplus
extern "C" {
#endif

/*****************************************************************************
* Redefine ioctl calls to map to standard driver 
******************************************************************************/
#define todIoctl(Fd, Cmd, pParams)  todIoctl##Cmd(Fd,pParams)

#define todIoctlTOD_ENABLE(Fd, pParams) \
			periphBitSet (0x0001, (UWord16 *)(0x10C0))

#define todIoctlTOD_DISABLE(Fd, pParams) \
			periphBitClear (0x0001, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_ALARM_IRQ(Fd, pParams) \
			periphBitSet (0x0004, (UWord16 *)(0x10C0))

#define todIoctlTOD_DISABLE_ALARM_IRQ(Fd, pParams) \
			periphBitClear (0x0004, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_ONE_SEC_IRQ(Fd, pParams) \
			periphBitSet (0x0008, (UWord16 *)(0x10C0))

#define todIoctlTOD_DIABLE_ONE_SEC_IRQ(Fd, pParams) \
			periphBitClear (0x0008, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_SEC_ALARM(Fd, pParams) \
			periphBitSet (0x0010, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_DISABLE_SEC_ALARM(Fd, pParams) \
			periphBitClear (0x0010, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_MIN_ALARM(Fd, pParams) \
			periphBitSet (0x0020, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_DISABLE_MIN_ALARM(Fd, pParams) \
			periphBitClear (0x0020, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_HR_ALARM(Fd, pParams) \
			periphBitSet (0x0040, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_DISABLE_HR_ALARM(Fd, pParams) \
			periphBitClear (0x0040, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_ENABLE_DAY_ALARM(Fd, pParams) \
			periphBitSet (0x0080, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_DISABLE_DAY_ALARM(Fd, pParams) \
			periphBitClear (0x0080, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_CLEAR_ALARM_IRQ(Fd, pParams) \
			periphBitClear (0x4000, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_CLEAR_ONE_SEC_IRQ(Fd, pParams) \
			periphBitClear (0x8000, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_LOAD_CLOCK_SCALER(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.ClockScalerReg))

#define todIoctlTOD_LOAD_SECS_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.SecondsReg))

#define todIoctlTOD_LOAD_SECS_ALARM_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.SecondsAlarmReg))

#define todIoctlTOD_LOAD_MINS_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.MinutesReg))

#define todIoctlTOD_LOAD_MINS_ALARM_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.MinutesAlarmReg))

#define todIoctlTOD_LOAD_HRS_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.HoursReg))

#define todIoctlTOD_LOAD_HRS_ALARM_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.HoursAlarmReg))

#define todIoctlTOD_LOAD_DAYS_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.DaysReg))

#define todIoctlTOD_LOAD_DAYS_ALARM_VALUE(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.DaysAlarmReg))

#define todIoctlTOD_READ_SECS_VALUE(Fd, pParams) \
			periphMemRead ((UWord16 *)(&ArchIO.Tod.SecondsReg))
			
#define todIoctlTOD_READ_MINS_VALUE(Fd, pParams) \
			periphMemRead ((UWord16 *)(&ArchIO.Tod.MinutesReg))
			
#define todIoctlTOD_READ_HRS_VALUE(Fd, pParams) \
			periphMemRead ((UWord16 *)(&ArchIO.Tod.HoursReg))

#define todIoctlTOD_READ_DAYS_VALUE(Fd, pParams) \
			periphMemRead ((UWord16 *)(&ArchIO.Tod.DaysReg))

#define todIoctlTOD_CONFIGURE_CONTROL_REGISTER(Fd, pParams) \
			periphMemWrite (pParams, (UWord16 *)(&ArchIO.Tod.ControlReg))

#define todIoctlTOD_READ_CONTROL_REGISTER(Fd, pParams) \
			periphMemRead ((UWord16 *)(&ArchIO.Tod.ControlReg))
	

/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT int          todOpen(const char *, int, void  *);
EXPORT int          todSetAlarm(int, struct itimerspec *);
EXPORT struct tm *  todGetTime(struct tm *);
EXPORT int          todEnableCallBacks(int, struct sigevent *);
EXPORT int          todClose(int);


#ifdef __cplusplus
}
#endif

#endif

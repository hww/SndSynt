/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: timerdrv.h
*
* Description: header file for the posix timer driver
*
*****************************************************************************/



#ifndef __TIMERDRV_H
#define __TIMERDRV_H


#include "port.h"
#include "periph.h"
#include "quadraturetimer.h"
#include "time.h"
#include "timer.h"


#ifdef __cplusplus
extern "C" {
#endif



/*** POSIX timer device context ***/
typedef struct 
{
    int                     FileDesc;
    void                    (*pUserFunc)(union sigval);
    Word32                  Counter;
    Word32                  reloadCounterValue;
    Word32                  ResolutionFreq;
    void *                  pUserFuncArg;
    int                    (*pOpen)(const char *, int, qt_sState *);
    int                    (*pSetTime)(clockid_t, const struct itimerspec *);
} posix_tDevice;


typedef struct 
{
	int                    (*pOpen)(const char *, int, void *);
	int                    (*pSetAlarm)(int, const struct itimerspec * pValue);
	struct tm *            (*pGetTime)(struct tm *);
	int                    (*pClose)(int);
	int                    (*pCallBacks)(int, struct sigevent *); 
	time_t                 (*pMakeTime)(struct tm *timeptr);
} posix_tTod;


EXPORT const char* POSIXDeviceList[];

EXPORT const UWord16 timerTickLoadValue;
EXPORT const Word32  timerTickNanoseconds;
EXPORT const Word32  timerTickHZ;
EXPORT const UWord16 timerNanosecPerCount;
EXPORT const qt_eInputSource timerInputSource;


/*****************************************************************************
* Prototypes - See documentation for functional descriptions
******************************************************************************/

EXPORT Result timerCreate(const char * pName);
EXPORT int    timerSetTime(clockid_t, const struct itimerspec *);

/* declared in config.c for OS interfaces */
EXPORT void   timerSleep(Word32 Ticks);
EXPORT void   timerTick(void);



#ifdef __cplusplus
}
#endif

#endif

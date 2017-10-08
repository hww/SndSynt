/****************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*****************************************************************
*
* File Name:         cyclecount.h
* Description:       Support for time measurements
*			
****************************************************************/

#ifndef __CYCLECOUNT_H
#define __CYCLECOUNT_H

#include "test.h"
#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Prefixes for cycleCountReport function */
#define MEAN_TIME_PREFIX   ""
#define MAX_TIME_PREFIX	   ""
#define MIN_TIME_PREFIX    ""
#define CALIBRATION_FAILURE 0xFFFFFFFF

#define CALIBRATION_FAILURE 0xFFFFFFFF

/****************************** testExecTime *******************************
*
*  Function testExecTime computes simple statistic of measured execution
*  time and performs output to console in format supported by regression test
*
*******************************************************************************/
EXPORT void    cycleCountReport (test_sRec *pTest, long int *pIC, int n);


/****************************** testTimerOn ***********************************
*
*  Function testTimerOn performs the initialization of the Quad Timers and enables
*  counting of instruction cycles.
*
*******************************************************************************/
EXPORT void cycleCountStart(const char *pName1, const char *pName2,\
			   int *pFileDesc1, int *pFileDesc2);


/****************************** testTimerOff **********************************
*
*  Function testfEnd disables Quad Timers and returns number of instruction
*  cycles counted by Quad Timers.
*
*******************************************************************************/
EXPORT UWord32 cycleCountStop(int FileDesc1, int FileDesc2, UWord32 calValue);


/****************************** testCalibrate ********************************
*
*  Function testCalibrate returns calibration value which is needed
*  in testfEnd function call.
*
*******************************************************************************/
EXPORT UWord32 cycleCountCalibrate(const char *pName1, const char *pName2);


#ifdef __cplusplus
}
#endif

#endif
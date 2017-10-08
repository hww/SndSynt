/****************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*****************************************************************
*
* File Name:         cyclecount.c
* Description:       Support for time measurements
* Notes: 	     When you use for example Quad Timer A0 and Quad Timer A1 you 
*                    have to add appropriate lines
*                    #define INCLUDE_USER_TIMER_A_0  0
*                    #define INCLUDE_USER_TIMER_A_1  0
*                    into appconfig.h
*			
****************************************************************/


#include "port.h"
#include <stdio.h>
#include <string.h>
#include "bsp.h"
#include "qtimerdrv.h"
#include "test.h"
#include "cyclecount.h"

#define TEST_FOR_CHANNEL_0 0
#define TEST_FOR_CHANNEL_1 0
#define TEST_FOR_CHANNEL_2 0
#define TEST_FOR_CHANNEL_3 0
#define UNINITIALIZED 0

//#define NULL 0

/******************************************************************************
*
*  Function: cycleCountReport
*
*  Description: calculates mean, max., min. execution time, performs output
*               to console in format supported by regression test.
*
*  Arguments:
*		pTest       -(in) pointer to Test structure					
*		pExecTime   -(in) array of measured execution time
*		n           -(in) length of pExecTime
*
*  Returns: none
*
*  Range Issues: none
*
*  Special Issues: none
*
*******************************************************************************/

void    cycleCountReport (test_sRec *pTest, long int *pExecTime, int n)
{
	unsigned int i;
	UWord32 maxExecTime, minExecTime;
	UWord32 sum;

	sum=0;
	maxExecTime=0;
	minExecTime=0xFFFFFFFF;

	for(i=0;i<n;i++)
	{
		sum = sum + pExecTime[i];

		if (maxExecTime<pExecTime[i])
		{
			maxExecTime=pExecTime[i];
		}
		
		if (minExecTime>pExecTime[i])
		{
			minExecTime=pExecTime[i];
		}
		

	}
	sum=sum/n; 
	
/* Printed values are multiplied by 2 because of conversion from
   bus cycles to clock cycles */
	
	printf("%s - !!! ToReport !!! %s%lu \n", pTest -> name, MEAN_TIME_PREFIX, 2*sum);
	printf("%s - !!! ToReport !!! %s%lu \n", pTest -> name, MAX_TIME_PREFIX, 2*maxExecTime );
	printf("%s - !!! ToReport !!! %s%lu \n", pTest -> name, MIN_TIME_PREFIX, 2*minExecTime ); 
}


/* Initialization structures for Quad Timers */
static const qt_sState quadParam1 = {

    /* Mode = */                    qtCount,
    /* InputSource = */             qtPrescalerDiv1,
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtRepeatedly,
    /* CountLength = */             qtPastCompare,
    /* CountDirection = */          qtUp,

    /* OutputMode = */              qtAssertWhileActive, /* qtToggleOnCompare */
    /* OutputPolarity = */          qtNormal,
    /* OutputDisabled = */          0,

    /* Master = */                  0,
    /* OutputOnMaster = */          0,
    /* CoChannelInitialize = */     0,
    /* AssertWhenForced = */        0,

    /* CaptureMode = */             qtDisabled,

    /* CompareValue1 = */           0xFFFF,
    /* CompareValue2 = */           0x0000,
    /* InitialLoadValue = */        0x0000,

    /* CallbackOnCompare = */       { 0, 0 },
    /* CallbackOnOverflow = */      { 0, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};

static qt_sState quadParam2 = {

    /* Mode = */                    qtCascadeCount,		/* qtCountBothEdges */
    /* InputSource = */             qtCounter0Output,
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtRepeatedly,
    /* CountLength = */             qtPastCompare,
    /* CountDirection = */          qtUp,

    /* OutputMode = */              qtAssertWhileActive,
    /* OutputPolarity = */          qtNormal,
    /* OutputDisabled = */          0,

    /* Master = */                  0,
    /* OutputOnMaster = */          0,
    /* CoChannelInitialize = */     0,
    /* AssertWhenForced = */        0,

    /* CaptureMode = */             qtDisabled,

    /* CompareValue1 = */           0xFFFF,
    /* CompareValue2 = */           0x0000,
    /* InitialLoadValue = */        0x0000,

    /* CallbackOnCompare = */       { 0, 0 },
    /* CallbackOnOverflow = */      { 0, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};





/******************************************************************************
*
*  Function: cycleCountStart
*
*  Description: performs the initialization of the Quad Timers and enables
*				counting of instruction cycles.
*
*  Arguments:
* 		pName1 - (in) the first Quad Timer device name: possible values are
*					BSP_DEVICE_NAME_QUAD_TIMER_A_0
*					BSP_DEVICE_NAME_QUAD_TIMER_A_1
*					BSP_DEVICE_NAME_QUAD_TIMER_A_2
*					BSP_DEVICE_NAME_QUAD_TIMER_A_3
*					BSP_DEVICE_NAME_QUAD_TIMER_B_0
*					BSP_DEVICE_NAME_QUAD_TIMER_B_1
*					BSP_DEVICE_NAME_QUAD_TIMER_B_2
*					BSP_DEVICE_NAME_QUAD_TIMER_B_3
*					BSP_DEVICE_NAME_QUAD_TIMER_C_0
*					BSP_DEVICE_NAME_QUAD_TIMER_C_1
*					BSP_DEVICE_NAME_QUAD_TIMER_C_2
*					BSP_DEVICE_NAME_QUAD_TIMER_C_3
*					BSP_DEVICE_NAME_QUAD_TIMER_D_0
*					BSP_DEVICE_NAME_QUAD_TIMER_D_1
*					BSP_DEVICE_NAME_QUAD_TIMER_D_2
*					BSP_DEVICE_NAME_QUAD_TIMER_D_3
*		pName2 - (in) the second Quad Timer device name: possible
*				 values are the same as pName1
*
*  Returns: 
*		pFileDesc1 - (out) pointer to the first Quad Timer device descriptor
*		pFileDesc2 - (out) pointer to the second Quad Timer device descriptor
*           - a NULL (value of zero) pointer is returned if the function fails
*
*  Range Issues:
*
*  Special Issues: pName1 and pName2 must be Quad Timers from the same Quad 
*				   Timer module (A, B, C or D).
*
*******************************************************************************/ 
void cycleCountStart(const char *pName1, const char *pName2,\
			   int *pFileDesc1, int *pFileDesc2)
{
	if (
	    #ifdef BSP_DEVICE_NAME_QUAD_TIMER_A_0
			pName1 == BSP_DEVICE_NAME_QUAD_TIMER_A_0 ||
		#endif
		#ifdef BSP_DEVICE_NAME_QUAD_TIMER_B_0
			pName1 == BSP_DEVICE_NAME_QUAD_TIMER_B_0 ||
		#endif
		#ifdef BSP_DEVICE_NAME_QUAD_TIMER_C_0
			pName1 == BSP_DEVICE_NAME_QUAD_TIMER_C_0 ||
		#endif
		#ifdef BSP_DEVICE_NAME_QUAD_TIMER_D_0
			pName1 == BSP_DEVICE_NAME_QUAD_TIMER_D_0 ||
		#endif
		TEST_FOR_CHANNEL_0
	   )
	{
        quadParam2.InputSource = qtCounter0Output;
	}
    else
	{
	    if (
	        #ifdef BSP_DEVICE_NAME_QUAD_TIMER_A_1
				pName1 == BSP_DEVICE_NAME_QUAD_TIMER_A_1 ||
			#endif
			#ifdef BSP_DEVICE_NAME_QUAD_TIMER_B_1
				pName1 == BSP_DEVICE_NAME_QUAD_TIMER_B_1 ||
			#endif
			#ifdef BSP_DEVICE_NAME_QUAD_TIMER_C_1
				pName1 == BSP_DEVICE_NAME_QUAD_TIMER_C_1 ||
			#endif
			#ifdef BSP_DEVICE_NAME_QUAD_TIMER_D_1
				pName1 == BSP_DEVICE_NAME_QUAD_TIMER_D_1 ||
			#endif
			TEST_FOR_CHANNEL_1
		   )
		{
			quadParam2.InputSource = qtCounter1Output;
		}
		else
		{
			if (
			    #ifdef BSP_DEVICE_NAME_QUAD_TIMER_A_2
					pName1 == BSP_DEVICE_NAME_QUAD_TIMER_A_2 ||
				#endif
				#ifdef BSP_DEVICE_NAME_QUAD_TIMER_B_2
					pName1 == BSP_DEVICE_NAME_QUAD_TIMER_B_2 ||
				#endif
				#ifdef BSP_DEVICE_NAME_QUAD_TIMER_C_2
					pName1 == BSP_DEVICE_NAME_QUAD_TIMER_C_2 ||
				#endif
				#ifdef BSP_DEVICE_NAME_QUAD_TIMER_D_2
					pName1 == BSP_DEVICE_NAME_QUAD_TIMER_D_2 ||
				#endif
				TEST_FOR_CHANNEL_2
			   )
			{
			    quadParam2.InputSource = qtCounter2Output;
			}
			else
			{

				if (
				    #ifdef BSP_DEVICE_NAME_QUAD_TIMER_A_3
						pName1 == BSP_DEVICE_NAME_QUAD_TIMER_A_3 ||
					#endif
					#ifdef BSP_DEVICE_NAME_QUAD_TIMER_B_3
						pName1 == BSP_DEVICE_NAME_QUAD_TIMER_B_3 ||
					#endif
					#ifdef BSP_DEVICE_NAME_QUAD_TIMER_C_3
						pName1 == BSP_DEVICE_NAME_QUAD_TIMER_C_3 ||
					#endif
					#ifdef BSP_DEVICE_NAME_QUAD_TIMER_D_3
						pName1 == BSP_DEVICE_NAME_QUAD_TIMER_D_3 ||
					#endif
					TEST_FOR_CHANNEL_3 
				   )
				{
					quadParam2.InputSource = qtCounter3Output;
				}
			}
		}
	}

    if ( quadParam2.InputSource == UNINITIALIZED)
	{
		*pFileDesc1 = NULL;
		*pFileDesc2 = NULL;
    }
	else
	{
		*pFileDesc1 = open(pName1, 0, &quadParam1);
	    *pFileDesc2 = open(pName2, 0, &quadParam2);

		/* To Enable Counters */
		ioctl(*pFileDesc1, QT_ENABLE, (void*)&quadParam1);
		ioctl(*pFileDesc2, QT_ENABLE, (void*)&quadParam2);
	}
}				





/******************************************************************************
*
*  Function: cycleCountStop
*
*  Description: disables Quad Timers and returns number of instruction
*				cycles counted by Quad Timers.
*
*  Arguments:
*		FileDesc1 - (in) the first Quad Timer device descriptor
*					(obtained from testfInit function)
*		FileDesc2 - (in) the second Quad Timer device descriptor
*					(obtained from testfInit function)
*		cal_value - (in) calibration value returned by testfCalibrate function
*
*  Returns: number of instruction cycles
*
*  Range Issues:
*
*  Special Issues: 
*
*******************************************************************************/
UWord32 cycleCountStop(int FileDesc1, int FileDesc2, UWord32 cal_value)
{
	UWord32 lsw, 
			msw;

    ioctl(FileDesc1, QT_DISABLE, (void*)&quadParam1);
    ioctl(FileDesc2, QT_DISABLE, (void*)&quadParam2);
    lsw = ioctl(FileDesc1, QT_READ_COUNTER_REG, (void*)&quadParam1);
    msw = ioctl(FileDesc2, QT_READ_HOLD_REG, (void*)&quadParam2);
    close(FileDesc1);
    close(FileDesc2);
    return (lsw + msw*65536 - cal_value);
}						




/******************************************************************************
*
*  Function: cycleCountCalibrate
*
*  Description: calls testTimerOn and testTimerOff functions and returns calibration
*				value.
*
*  Arguments:
* 		pName1 - (in) the first Quad Timer device name: possible values are
*					BSP_DEVICE_NAME_QUAD_TIMER_A_0
*					BSP_DEVICE_NAME_QUAD_TIMER_A_1
*					BSP_DEVICE_NAME_QUAD_TIMER_A_2
*					BSP_DEVICE_NAME_QUAD_TIMER_A_3
*					BSP_DEVICE_NAME_QUAD_TIMER_B_0
*					BSP_DEVICE_NAME_QUAD_TIMER_B_1
*					BSP_DEVICE_NAME_QUAD_TIMER_B_2
*					BSP_DEVICE_NAME_QUAD_TIMER_B_3
*					BSP_DEVICE_NAME_QUAD_TIMER_C_0
*					BSP_DEVICE_NAME_QUAD_TIMER_C_1
*					BSP_DEVICE_NAME_QUAD_TIMER_C_2
*					BSP_DEVICE_NAME_QUAD_TIMER_C_3
*					BSP_DEVICE_NAME_QUAD_TIMER_D_0
*					BSP_DEVICE_NAME_QUAD_TIMER_D_1
*					BSP_DEVICE_NAME_QUAD_TIMER_D_2
*					BSP_DEVICE_NAME_QUAD_TIMER_D_3
*		pName2 - (in) the second Quad Timer device name: possible
*				 values are the same as pName1
*
*  Returns: calibration value (it is the number of instruction cycles counted
*							   when there is no code between testfInit and
*							   testfEnd function calls)
*           - if a failure occurs a value of 0xFFFFFFFF is returned
*
*  Range Issues:
*
*  Special Issues: pName1 and pName2 must be Quad Timers from the same Quad 
*				   Timer module (A, B, C or D).
*	
*******************************************************************************/
UWord32 cycleCountCalibrate(const char *pName1, const char *pName2)
{
  UWord32 cal_value;
  int FileDesc1, FileDesc2;

  cycleCountStart(pName1, pName2, &FileDesc1, &FileDesc2);

  if (FileDesc1 != NULL && FileDesc2 != NULL)
  {
     cal_value = (cycleCountStop(FileDesc1, FileDesc2, 0) - (UWord32)1);
  }
  else
  {
	 cal_value = CALIBRATION_FAILURE;
  }

  return (cal_value);
}
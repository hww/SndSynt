/*****************************************************************************
*
* buttondrv.c - Button driver
*
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "time.h"
#include "timespec.h"

#include "bit.h"
#include "periph.h"

#include "bsp.h"
#include "button.h"


button_sButton buttondrvDeviceA = 
		{ 
			{0,0},
			{NULL,NULL},
		};

#ifdef BSP_DEVICE_NAME_BUTTON_B
											
button_sButton buttondrvDeviceB = 
		{ 
			{0,0},
			{NULL,NULL},
		};
											
#endif
								
/*****************************************************************************/
static void buttonISR(button_sButton * pButtonTable)
{
	struct timespec Now;
	struct timespec Milliseconds;
	
	if (pButtonTable->Callback.pCallback != NULL)
	{
	
		/* Debounce the button */
		clock_gettime (CLOCK_REALTIME, &Now);
			
		if (timespecGE (&Now, &(pButtonTable->DebounceTimeExp)))
		{
			/* Add 150ms to current time for debounce period */
			Milliseconds.tv_sec  = 0;
			Milliseconds.tv_nsec = 150000000;  /* 150 ms */
			
			timespecAdd   (&(pButtonTable->DebounceTimeExp), &Now, &Milliseconds);
			
			(*(pButtonTable->Callback.pCallback))(pButtonTable->Callback.pCallbackArg);
		}

		/* otherwise, ignore the interrupt */
	}
}

/*****************************************************************************/
void buttonISRA(void)
{
	buttonISR(&buttondrvDeviceA);
}

/*****************************************************************************/
#ifdef BSP_DEVICE_NAME_BUTTON_B
											
void buttonISRB(void)
{
	buttonISR(&buttondrvDeviceB);
}

#endif

/*****************************************************************************/
int buttonOpen(const char * pName, int OFlags, button_sCallback * pCallbackParam)
{
	button_sButton   * pButtonTable;
			
    if(pName == BSP_DEVICE_NAME_BUTTON_A)
    {
    	pButtonTable = &buttondrvDeviceA;
	}
	else
	{
	
#ifdef BSP_DEVICE_NAME_BUTTON_B
											
    	if(pName == BSP_DEVICE_NAME_BUTTON_B)
    	{
    		pButtonTable = &buttondrvDeviceB;
		}
		else
#endif
		{	
			return -1; /* not my device */
		}
	}

	pButtonTable->DebounceTimeExp.tv_sec  = 0;
	pButtonTable->DebounceTimeExp.tv_nsec = 0;
	pButtonTable->Callback.pCallback      = pCallbackParam->pCallback;
	pButtonTable->Callback.pCallbackArg   = pCallbackParam->pCallbackArg;
	
	return (int)pButtonTable;
}

/*****************************************************************************/
int buttonClose(int FileDesc)
{
	((button_sButton *)FileDesc)->Callback.pCallback = NULL;

	return 0;
}

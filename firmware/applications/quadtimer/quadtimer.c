/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME: quadtimer.c for 56826
*
*******************************************************************************/

#include "port.h"
#include "arch.h"
#include "io.h"
#include "led.h"
#include "qtimerdrv.h"
#include "periph.h"

#include "fcntl.h"
#include "quadraturetimer.h"

#ifdef DSP56826EVM
static void  CallbackOnOverflow(qt_eCallbackType CallbackType, void* pParam);
static void  CallbackOnCompare1(qt_eCallbackType CallbackType, void* pParam);
static void  CallbackOnCompare2(qt_eCallbackType CallbackType, void* pParam);
#endif

#ifdef DSP56827EVM
static void  CallbackOnOverflow(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam);
static void  CallbackOnCompare1(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam);
static void  CallbackOnCompare2(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam);
#endif

const qt_sState quadParam1 = {

    /* Mode = */                    qtCountBothEdges,
    /* InputSource = */             qtPrescalerDiv128,
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtOnce,
    /* CountLength = */             qtPastCompare,
    /* CountDirection = */          qtDown,

    /* OutputMode = */              qtAssertWhileActive,
    /* OutputPolarity = */          qtNormal,
    /* OutputDisabled = */          0,

    /* Master = */                  0,
    /* OutputOnMaster = */          0,
    /* CoChannelInitialize = */     0,
    /* AssertWhenForced = */        0,

    /* CaptureMode = */             qtDisabled,

    /* CompareValue1 = */           0xFFFF,
    /* CompareValue2 = */           0xFFFF,
    /* InitialLoadValue = */        0xFFFE,

    /* CallbackOnCompare = */       { 0, 0 },
    /* CallbackOnOverflow = */      { CallbackOnOverflow, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};

const qt_sState quadParam2 = {

    /* Mode = */                    qtCount,
    /* InputSource = */             qtPrescalerDiv128,
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtOnce,
    /* CountLength = */             qtUntilCompare,
    /* CountDirection = */          qtDown,

    /* OutputMode = */              qtAssertWhileActive,
    /* OutputPolarity = */          qtNormal,
    /* OutputDisabled = */          1,

    /* Master = */                  0,
    /* OutputOnMaster = */          0,
    /* CoChannelInitialize = */     0,
    /* AssertWhenForced = */        0,

    /* CaptureMode = */             qtDisabled,

    /* CompareValue1 = */           0x8000,
    /* CompareValue2 = */           0,
    /* InitialLoadValue = */        0xFFFF,

    /* CallbackOnCompare = */       { CallbackOnCompare1, 0 },
    /* CallbackOnOverflow = */      { 0, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};

const qt_sState quadParam3 = {

    /* Mode = */                    qtCount,
    /* InputSource = */             qtPrescalerDiv128,
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtOnce,
    /* CountLength = */             qtUntilCompare,
    /* CountDirection = */          qtUp,

    /* OutputMode = */              qtAssertWhileActive,
    /* OutputPolarity = */          qtNormal,
    /* OutputDisabled = */          1,

    /* Master = */                  0,
    /* OutputOnMaster = */          0,
    /* CoChannelInitialize = */     0,
    /* AssertWhenForced = */        0,

    /* CaptureMode = */             qtDisabled,

    /* CompareValue1 = */           0x8000,
    /* CompareValue2 = */           0,
    /* InitialLoadValue = */        0,

    /* CallbackOnCompare = */       { CallbackOnCompare2, 0 },
    /* CallbackOnOverflow = */      { 0, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};

Word16  Counter, lastCounter;


UWord16  TimerOverflow;
UWord16  TimerCompare1;
UWord16  TimerCompare2;


static int LedFD;

/*****************************************************************************/
main()
{


    LedFD  = open(BSP_DEVICE_NAME_LED_0,  0);

    ioctl(LedFD,  LED_OFF, LED_GREEN);
#ifdef LED_YELLOW
    ioctl(LedFD,  LED_OFF, LED_YELLOW);
#endif
#ifdef LED_RED
    ioctl(LedFD,  LED_OFF, LED_RED);
#endif
#ifdef LED_GREEN2
    ioctl(LedFD,  LED_OFF, LED_GREEN2);
#endif
#ifdef LED_YELLOW2
    ioctl(LedFD,  LED_OFF, LED_YELLOW2);
#endif
#ifdef LED_RED2
    ioctl(LedFD,  LED_OFF, LED_RED2);
#endif
    Counter = 1; lastCounter = 0;

    TimerOverflow = open(BSP_DEVICE_NAME_QUAD_TIMER_A_0, 0, &quadParam1 );
    TimerCompare1 = open(BSP_DEVICE_NAME_QUAD_TIMER_A_1, 0, &quadParam2 );
    TimerCompare2 = open(BSP_DEVICE_NAME_QUAD_TIMER_A_2, 0, &quadParam3 );

    ioctl(TimerOverflow, QT_DISABLE, (void*)&quadParam1 );
    ioctl(TimerCompare1, QT_DISABLE, (void*)&quadParam2 );
    ioctl(TimerCompare2, QT_DISABLE, (void*)&quadParam3 );

    
    while(1) /* executive loop */
    {
        if( Counter - lastCounter != 0 )
        {
            switch( Counter % 3 )
            {
            case 0:
                ioctl(TimerCompare2, QT_ENABLE, (void*)&quadParam3 );
#ifdef LED_RED
                ioctl(LedFD,  LED_OFF, LED_RED);
#endif
#ifdef LED_RED2
                ioctl(LedFD,  LED_OFF, LED_RED2);
#endif
                ioctl(LedFD,  LED_ON,  LED_GREEN);
#ifdef LED_GREEN2
                ioctl(LedFD,  LED_ON,  LED_GREEN2);
#endif
                break;
            case 1:
                ioctl(TimerCompare1, QT_ENABLE, (void*)&quadParam2 );
                ioctl(LedFD,  LED_OFF, LED_GREEN);
#ifdef LED_GREEN2
				ioctl(LedFD,  LED_OFF, LED_GREEN2);
#endif
#ifdef LED_YELLOW
                ioctl(LedFD,  LED_ON,  LED_YELLOW);
#endif
#ifdef LED_YELLOW2
                ioctl(LedFD,  LED_ON,  LED_YELLOW2);
#endif
                break;
            case 2:
                ioctl(TimerCompare2, QT_ENABLE, (void*)&quadParam3 );
#ifdef LED_YELLOW
                ioctl(LedFD,  LED_OFF, LED_YELLOW);
#endif
#ifdef LED_YELLOW2
                ioctl(LedFD,  LED_OFF, LED_YELLOW2);
#endif
#ifdef LED_RED
                ioctl(LedFD,  LED_ON,  LED_RED);
#endif
#ifdef LED_RED2
                ioctl(LedFD,  LED_ON,  LED_RED2);
#endif
                break;
            }
            lastCounter = Counter;
        }
    }
}


#ifdef DSP56826EVM
/*****************************************************************************/
void  CallbackOnOverflow(qt_eCallbackType CallbackType, void* pParam)
{
    Counter++;
}

/*****************************************************************************/
void  CallbackOnCompare1(qt_eCallbackType CallbackType, void* pParam)
{
    Counter++;
}

/*****************************************************************************/
void  CallbackOnCompare2(qt_eCallbackType CallbackType, void* pParam)
{
    Counter++;
}
#endif

#ifdef DSP56827EVM 
/*****************************************************************************/
void  CallbackOnOverflow(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam)
{
	Counter++;
}

/*****************************************************************************/
void  CallbackOnCompare1(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam)
{
    Counter++;
}

/*****************************************************************************/
void  CallbackOnCompare2(qt_eCallbackType CallbackType, qt_eCompareInterrupt CompareInterrupt, void* pParam)
{
    Counter++;
}
#endif




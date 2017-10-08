#include "port.h"
#include "arch.h"
#include "bsp.h"
#include "quadraturetimer.h"
#include "timerdrv.h"
#include "time.h"
#include "timer.h"
#include "tod.h"

#include "stdlib.h"
#include "assert.h"


extern posix_tDevice * POSIXTimerContext;

extern posix_tTod    * POSIXTodContext;

static struct sigevent RealTimeEvent;
static timer_t         RealTimeTimer;

static struct timespec timerRTElapsedTime = {0, 0};
static struct timespec timerTickDuration;

static void  TimerCallback(qt_eCallbackType CallbackType, void* pVDevice);
static void  timerRealTimeClockISR(union sigval Params); 

static qt_sState POSIXTimerParam = {

    /* Mode = */                    qtCount,
    /* InputSource = */             qtPrescalerDiv1, /* input */
    /* InputPolarity = */           qtNormal,
    /* SecondaryInputSource = */    0,

    /* CountFrequency = */          qtRepeatedly,
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

    /* CompareValue1 = */           0,
    /* CompareValue2 = */           0,
    /* InitialLoadValue = */        0xFFFF,

    /* CallbackOnCompare = */       { TimerCallback, 0 },
    /* CallbackOnOverflow = */      { 0, 0 },
    /* CallbackOnInputEdge = */     { 0, 0 }
};


/*****************************************************************************
*
* Module: TimerCallback
*
* Description: program counter routine for POSIX timer
*
* Returns: none
*
* Arguments: QT callback type, Timer device
*
* Range Issues: 
*
* Special Issues:  For executive loop only, to be optimized in asm
*
* Test Method: 
*
*****************************************************************************/
#if 0

static void  TimerCallback(qt_eCallbackType CallbackType, void* pVDevice)
{
#pragma interrupt
	static const union sigval sig = {0}; /* non OS version */
	register qt_tPOSIXDevice* pDevice = pVDevice;

    if(  --pDevice->Counter == 0 )
    {
        pDevice->Counter = pDevice->reloadCounterValue;
        pDevice->pUserFunc( sig );
    }

}

#else

static asm void TimerCallback(qt_eCallbackType CallbackType, void* pVDevice)
{
	/* 
		Y0  =>  CallbackType (not used in this routine)
		R2  =>  pVDevice
	*/
	lea   (SP)+
	move  A0,x:(SP)+
	move  A1,x:(SP)+
	move  A2,x:(SP)+
	move  Y1,x:(SP)
	move  x:(R2+3),A
	move  x:(R2+2),A0
	move  #1,Y0
	clr   Y1
	sub   Y,A
	move  A1,x:(R2+3)
	move  A0,x:(R2+2)
	bne   ExitTimerCallback
	move  x:(R2+5),A
	move  x:(R2+4),A0
	move  A1,x:(R2+3)
	move  A0,x:(R2+2)
	;
	; call user function
	;
	lea     (SP)+
	move    #UserFuncRtn,Y0          ; Load callback return address
	move    x:(R2+1),R2              ; Load callback address
	move    Y0,x:(SP)+               ; Simulate JSR to callback
	move    SR,x:(SP)+
	
	move    R2,x:(SP)+               ; Create dynamic JSR
	move    SR,x:(SP)
	move    #0,Y0                    ; Load callback parameters
	rts                              ; Call callback procedure
UserFuncRtn:

ExitTimerCallback:
	pop   Y1
	pop   A2
	pop   A1
	pop   A0
	rts

}

#endif




/*****************************************************************************/
#if 0
void timerRealTimeClockISR(union sigval Params) 
{
#pragma interrupt
    
    timerRTElapsedTime.tv_sec  += timerTickDuration.tv_sec;
    timerRTElapsedTime.tv_nsec += timerTickDuration.tv_nsec;
    
    if (timerRTElapsedTime.tv_nsec >= 1000000000)
    {
     	timerRTElapsedTime.tv_nsec -= 1000000000;
	   	timerRTElapsedTime.tv_sec++;
    }
    
        timerTick();
}
#else
asm void timerRealTimeClockISR(union sigval Params)
{
	lea      (SP)+
	move     A0,x:(SP)+
	move     A1,x:(SP)+
	move     A2,x:(SP)+
	move     B0,x:(SP)+
	move     B1,x:(SP)+
	move     B2,x:(SP)
	
#if 0
	/* 
		This code commented out for efficiency under the assumption 
		that a tick is less than one second
	*/
	move     timerRTElapsedTime+1,B   /* tv_sec */
	move     timerRTElapsedTime,B0
	move     timerTickDuration+1,A
	move     timerTickDuration,A0
	add      A,B
	move     B1,timerRTElapsedTime+1
	move     B0,timerRTElapsedTime
#endif

	move     timerRTElapsedTime+3,B
	move     timerRTElapsedTime+2,B0
	move     timerTickDuration+3,A
	move     timerTickDuration+2,A0
	add      A,B
	move     B1,timerRTElapsedTime+3
	move     B0,timerRTElapsedTime+2
	movei    #15258,A
	movei    #-13824,A0
	cmp      A,B
	blt      LessThan1Sec  
	sub      A,B
	move     B1,timerRTElapsedTime+3
	move     B0,timerRTElapsedTime+2
	clr      B
	movei    #1,B0
	move     timerRTElapsedTime+1,A
	move     timerRTElapsedTime,A0
	add      A,B
	move     B1,timerRTElapsedTime+1
	move     B0,timerRTElapsedTime
 LessThan1Sec:

 	jsr      timerTick

	pop      B2
	pop      B1
	pop      B0
	pop      A2
	pop      A1
	pop      A0
	rti   
}
#endif


/*****************************************************************************
*
* Module: SetTime
*
* Description: Set timer values
*
* Returns: none
*
* Arguments:  Timer device handle, assigned initial and period time.
*
* Range Issues: time precision - 10us, initial time ignored 
*
* Special Issues:  For executive loop only 
*
* Test Method: 
*
*****************************************************************************/
#if 0
static int timerSetTime(clockid_t Timer, const struct itimerspec * pTimeValue)
{
	posix_tDevice *         pcurPOSIXDevice    = &POSIXTimerContext[Timer];
	UWord32                 Seconds;
	UWord32                 MilSeconds;
	UWord32                 TenMicroSeconds;
	UWord32                 SecCnt;
	UWord32                 MilSecCnt;
	UWord32                 TenMicroSecCnt;
	UWord16                 Divider;
	UWord16                 Counter;
	UWord32                 tv_sec;
	UWord32                 tv_nsec;

	/* 
		LS010122 - Added check to catch non-conforming calls; 
					this implementation requires that initial and reload values
					be identical
	*/
	assert (pTimeValue->it_value.tv_sec  == pTimeValue->it_interval.tv_sec);
	assert (pTimeValue->it_value.tv_nsec == pTimeValue->it_interval.tv_nsec);
	
	tv_sec  = pTimeValue->it_value.tv_sec;
	tv_nsec = pTimeValue->it_value.tv_nsec;

	Seconds = tv_nsec / 1000000000;

	tv_nsec = tv_nsec - Seconds * 1000000000;

	Seconds = Seconds + tv_sec;

	MilSeconds = tv_nsec / 1000000;

	tv_nsec = tv_nsec - MilSeconds * 1000000;

	TenMicroSeconds = tv_nsec / 10000;


	for(Divider = 0; Divider < 32; Divider++)
	{
		if(Seconds != 0)
		{
			SecCnt = qtINPUT_FREQUENCY * Seconds / (1 << Divider);
		}
		else
		{
			SecCnt = 0;
		}

		if(SecCnt > 0xFFFF)
		{
			continue;
		}

		MilSecCnt = MilSeconds * (qtINPUT_FREQUENCY / 1000) / (1 << Divider);

		if(MilSecCnt > 0xFFFF)
		{
			continue;
		}

		if((SecCnt + MilSecCnt) > 0xFFFF)
		{
			continue;
		}

		TenMicroSecCnt = TenMicroSeconds * (qtINPUT_FREQUENCY / 100000) / (1 << Divider);
		
		if(TenMicroSecCnt > 0xFFFF)
		{
			continue;
		}

		if((SecCnt + MilSecCnt + TenMicroSecCnt) > 0xFFFF)
		{
			continue;
		}

		break;
	}


	if(Divider > 7)
	{
		pcurPOSIXDevice->Counter            = 1 << (Divider - 7);
		pcurPOSIXDevice->reloadCounterValue = 1 << (Divider - 7);

		Divider = 7;
	}
	else
	{
		pcurPOSIXDevice->Counter            = 1;
		pcurPOSIXDevice->reloadCounterValue = 1;
	}

	Counter = SecCnt + MilSecCnt + TenMicroSecCnt;

	// pcurPOSIXDevice->prescaler          = Divider;
	pcurPOSIXDevice->ResolutionFreq        = qtINPUT_FREQUENCY / (1 << Divider) / Counter;
    
    POSIXTimerParam.InitialLoadValue = (Word16)Counter;
    POSIXTimerParam.InputSource = Divider + qtPrescalerDiv1; /* check */
    
	return 0;
}
#else

void QuickDivU32UZ (void);   /* Interface to ARTDIVU32UZ to save space */
void QuickMpyU32U  (void);   /* Interface to ARTMPYU32U  to save space */

static UWord16 SizeOfPOSIXDevice = sizeof(posix_tDevice);

asm int timerSetTime(clockid_t Timer, const struct itimerspec * pTimeValue) 
{ 
; Registers Upon Entry:
;    Y0  -  Timer
;    R2  -  pTimeValue
;
; Register Usage:
;
;    Y0  -  temp
;    A   -  temp
;    B   -  temp
;    R2  -  qt_tPOSIXDevice * pcurPOSIXDevice    = &pTPOSIXDevice[Timer];
;    x:(SP-17) -  UWord32           Seconds;
;    x:(SP-15) -  UWord32           MilSeconds;
;    x:(SP-13) -  UWord32           TenMicroSeconds;
;    x:(SP-11) -  UWord32           SecCnt;
;    x:(SP-9)  -  UWord32           MilSecCnt;
;    x:(SP-7)  -  UWord32           TenMicroSecCnt;
;    x:(SP-5)  -  time_t            tv_sec;
;    x:(SP-3)  -  long              tv_nsec;
;    x:(SP-1)  -  UWord16           Divider
;    x:(SP)    -  UWord16           Counter;
;

		movei    #18,N
		lea      (SP)+N
;
; 	posix_tDevice *         pcurPOSIXDevice    = &POSIXTimerContext[Timer];
;
		move     #SizeOfPOSIXDevice,R3       ;sizeof(posix_tDevice)
		nop
		move     X:(R3),X0

		impy     Y0,X0,Y0
		move     #POSIXTimerContext,R3
		nop
		move     X:(R3),R3
		move     Y0,N
		nop
		lea      (R3)+N
;
;  322: 	tv_sec  = pTimeValue->it_value.tv_sec; 
;
		move     X:(R2+0x0005),B
		move     X:(R2+0x0004),B0
		move     B1,X:(SP-0x0004)
		move     B0,X:(SP-0x0005)	
;
#ifdef PORT_ASSERT_ON_INVALID_PARAMETER
;
;		assert (pTimeValue->it_value.tv_sec  == pTimeValue->it_interval.tv_sec)
;
		move     X:(R2+0x0001),A
		move     X:(R2),A0
		cmp      A,B
		beq      TVSecOK
		debug                        ; it_value.tv_sec != it_interval.tv_sec
TVSecOK:
	
#endif
;
;  323: 	tv_nsec = pTimeValue->it_value.tv_nsec; 
;  324:  
;

		move     X:(R2+0x0007),Y1
		move     X:(R2+0x0006),Y0
		move     Y1,X:(SP-0x0002)
		move     Y0,X:(SP-0x0003)
;
#ifdef PORT_ASSERT_ON_INVALID_PARAMETER
;
;	assert (pTimeValue->it_value.tv_nsec == pTimeValue->it_interval.tv_nsec);
;
		move     X:(R2+0x0003),A
		move     X:(R2+0x0002),A0
		move     Y1,B
		move     Y0,B0
		cmp      A,B
		beq      TVnSecOK
		debug                        ; it_value.tv_nsec != it_interval.tv_nsec
TVnSecOK:
	
#endif
		
		move     R3,R2               ; Use R2 for POSIXTimerContext
;
;  325: 	Seconds = tv_nsec / 1000000000; 
;  326:  
;
		movei    #15258,A
		movei    #-13824,A0
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-16)
		move     Y0,X:(SP-17)
;
;  327: 	tv_nsec = tv_nsec - Seconds * 1000000000; 
;  328:  
;
		move     B1,X:(SP-0x0002)
		move     B0,X:(SP-0x0003)
;
;  331: 	MilSeconds = tv_nsec / 1000000; 
;  332:  
;
		movei    #15,A
		movei    #16960,A0
		move     B1,Y1
		move     B0,Y0
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-0x000e)
		move     Y0,X:(SP-0x000f)
;
;  333: 	tv_nsec = tv_nsec - MilSeconds * 1000000; 
;  334:  
;
		move     B1,X:(SP-0x0002)
		move     B0,X:(SP-0x0003)
;
;  335: 	TenMicroSeconds = tv_nsec / 10000; 
;  336:  
;  337:  
;
		clr      A
		movei    #10000,A0
		move     B1,Y1
		move     B0,Y0
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-0x000c)
		move     Y0,X:(SP-0x000d)
;
;  329: 	Seconds = Seconds + tv_sec; 
;  330:  
;
		move     X:(SP-0x0004),B
		move     X:(SP-0x0005),B0
		move     X:(SP-0x0010),A
		move     X:(SP-0x0011),A0
		add      A,B
		move     B1,X:(SP-0x0010)
		move     B0,X:(SP-0x0011)
;
;  338: 	for(Divider = 0; Divider < 32; Divider++) 
;  339: 	{ 
;
		moves    #0,X:(SP-1)
ContinueForLoop:
;
;  340: 		if(Seconds != 0) 
;  341: 		{ 
;
		move     X:(SP-0x0010),A
		move     X:(SP-0x0011),A0
		tst      A
		beq      SecondsEq0
;
;  342: 			SecCnt = qtINPUT_FREQUENCY * Seconds / (1 << Divider);
;
		move     qtINPUT_FREQUENCY+1,Y1
		move     qtINPUT_FREQUENCY,Y0
		jsr      QuickMpyU32U   
		moves    X:(SP-1),X0
		clr      A
		move     #1,A0
		rep      X0
		asl      A
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-0x000a)
		move     Y0,X:(SP-0x000b)
		bra      CheckSecCnt
;
;  343: 		} 
;  344: 		else 
;  345: 		{ 
;  346: 			SecCnt = 0; 
;  347: 		} 
;  348:  
;
SecondsEq0:
		clr      X0
		move     X0,X:(SP-11)          ; SecCnt = 0;
		move     X0,X:(SP-10)
;
;  349: 		if(SecCnt > 0xFFFF) 
;  350: 		{ 
;  351: 			continue; 
;  352: 		} 
;  353:  
;
CheckSecCnt:
		tstw    X:(SP-10)
		bne     EndForLoop
;
;  354: 		MilSecCnt = MilSeconds * (qtINPUT_FREQUENCY / 1000) 
;  355: 												/ (1 << Divider); 
;  356:  
;
		clr      A
		move     #1000,A0
		move     qtINPUT_FREQUENCY+1,Y1
		move     qtINPUT_FREQUENCY,Y0
		jsr      QuickDivU32UZ
		move     X:(SP-14),A
		move     X:(SP-15),A0
		jsr      QuickMpyU32U
		move     X:(SP-1),X0
		clr      A
		move     #1,A0
		rep      X0
		asl      A
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-0x0008)
		move     Y0,X:(SP-0x0009)

;
;  357: 		if(MilSecCnt > 0xFFFF) 
;  358: 		{ 
;  359: 			continue; 
;  360: 		} 
;  361:  
;
		tstw     Y1
		bne      EndForLoop
;
;  362: 		if((SecCnt + MilSecCnt) > 0xFFFF) 
;  363: 		{ 
;  364: 			continue; 
;  365: 		} 
;  366:  
;
		move     X:(SP-0x000a),A
		move     X:(SP-0x000b),A0
		add      Y,A
		tstw     A1
		bne      EndForLoop
;
;  367: 		TenMicroSecCnt = TenMicroSeconds * (qtINPUT_FREQUENCY  
;  368: 										/ 100000) / (1 << Divider); 
;  369: 		 
;
		movei    #1,A1
		movei    #-31072,A0
		move     qtINPUT_FREQUENCY+1,Y1
		move     qtINPUT_FREQUENCY,Y0
		jsr      QuickDivU32UZ
		
		move     X:(SP-12),A
		move     X:(SP-13),A0
		jsr      QuickMpyU32U
		move     X:(SP-1),X0
		clr      A
		move     #1,A0
		rep      X0
		asl      A
		jsr      QuickDivU32UZ
		move     Y1,X:(SP-0x0006)
		move     Y0,X:(SP-0x0007)
;
;  370: 		if(TenMicroSecCnt > 0xFFFF) 
;  371: 		{ 
;  372: 			continue; 
;  373: 		} 
;  374:  
;
		tstw    Y1
		bne     EndForLoop
;
;  375: 		if((SecCnt + MilSecCnt + TenMicroSecCnt) > 0xFFFF) 
;  376: 		{ 
;  377: 			continue; 
;  378: 		} 
;  379:  
;  380: 		break; 
;
		move     X:(SP-0x000a),A
		move     X:(SP-0x000b),A0
		add      Y,A
		move     X:(SP-8),B
		move     X:(SP-9),B0
		add      A,B
		tstw     B1
		beq      BreakForLoop
;
;  381: 	} 
;  382:  
;  383:  
;

EndForLoop:
		incw     X:(SP-1)
		movei    #32,X0
		cmp      X:(SP-1),X0
		jhi      ContinueForLoop

BreakForLoop:

;  384: 	if(Divider > 7) 
;  385: 	{ 
;
		moves    X:(SP-1),X0
		sub      #0x7,X0
		bls      DividerLE7
;
;  386: 		pcurPOSIXDevice->Counter            = 1 << (Divider - 7); 
;

		clr      B
		movei    #1,B0
		rep      X0
		asl      B
		move     B1,X:(R2+0x0003)
		move     B0,X:(R2+0x0002)
;
;  387: 		pcurPOSIXDevice->reloadCounterValue = 1 << (Divider - 7); 
;  388:  
;
		move     B1,X:(R2+0x0005)
		move     B0,X:(R2+0x0004)
;
;  389: 		Divider = 7; 
;
		move     #7,X:(SP-1)
		bra      EndIfDivider
;
;  390: 	} 
;  391: 	else 
;  392: 	{ 
;  393: 		pcurPOSIXDevice->Counter            = 1; 
;

DividerLE7:

		clr      Y1
		move     #1,Y0
		move     Y0,X:(R2+0x0002)
		move     Y1,X:(R2+0x0003)
;
;  394: 		pcurPOSIXDevice->reloadCounterValue = 1; 
;
		move     Y0,X:(R2+0x0004)
		move     Y1,X:(R2+0x0005)
;
;  395: 	}

EndIfDivider:

;  396:  
;  397: 	Counter = SecCnt + MilSecCnt + TenMicroSecCnt; 
;  398:  
;
		move     X:(SP-0x0008),B
		move     X:(SP-0x0009),B0
		move     X:(SP-0x000a),A
		move     X:(SP-0x000b),A0
		add      A,B
		move     X:(SP-0x0006),A
		move     X:(SP-0x0007),A0
		add      A,B
		move     B0,X:(SP)
	
;
;  400: 	pcurPOSIXDevice->ResolutionFreq  = qtINPUT_FREQUENCY / 
;  401:           										(1 << Divider) / Counter; 
;
		clr      A
		move     #1,A0
		rep      X0
		asl      A
		move     qtINPUT_FREQUENCY+1,Y1
		move     qtINPUT_FREQUENCY,Y0
		jsr      QuickDivU32UZ
		clr      A
		move     X:(SP),A0
		jsr      QuickDivU32UZ
		move     Y1,X:(R2+0x0007)
		move     Y0,X:(R2+0x0006)
;
;  403:     POSIXTimerParam.InitialLoadValue = (Word16)Counter; 
;
		moves    X:(SP),X0
		move     X0,POSIXTimerParam.InitialLoadValue
;
;  404:     POSIXTimerParam.InputSource = Divider + qtPrescalerDiv1; /* check */ 
;  405:      
;
		moves    X:(SP-1),Y0
		add      #0x8,Y0
		move     #4,X0
		asll     Y0,X0,Y0
		move     POSIXTimerParam,X0
		bfclr    #0x00F0,X0
		or       Y0,X0
		move     X0,POSIXTimerParam
;
;  406: 	return 0; 
;
		clr      Y0
;
;  406: } 
		lea      (SP-18)
		rts      
}
#endif

/*****************************************************************************/
int timer_create (  clockid_t          ClockID, 
					struct sigevent *  EventParams, 
					timer_t *          TimerID)
{
	if(ClockID == CLOCK_TOD)
	{
		POSIXTodContext[0].pCallBacks(0, EventParams);
		*TimerID = EventParams -> sigev_signo; 
	}
	else
	{
		posix_tDevice * pcurPOSIXDevice  = &(POSIXTimerContext[ClockID]);

		pcurPOSIXDevice->pUserFuncArg = (void *)pcurPOSIXDevice;
		pcurPOSIXDevice->pUserFunc    = EventParams->sigev_notify_function;

		pcurPOSIXDevice->FileDesc = pcurPOSIXDevice -> pOpen(POSIXDeviceList[ClockID], 0, NULL);
	
		*TimerID = ClockID;
	}
		
    return 0;
}

/*****************************************************************************/
int timer_delete(timer_t TimerID)
{
	if(TimerID == CLOCK_TOD)
	{
		POSIXTodContext[0].pClose(0);	
	}
	else
	{
		qtIoctl(POSIXTimerContext[TimerID].FileDesc, 
   	 			QT_DISABLE, 
   	 			(void*)&POSIXTimerParam,
   	 			POSIXDeviceList[TimerID] );
	}
}

/*****************************************************************************/
int timer_settime (timer_t TimerID, int Flags, 
                        const struct itimerspec * pValue, struct itimerspec * pOvalue)
{
	if(TimerID == TOD_ALARM_INTERRUPT)
	{		
		POSIXTodContext[0].pSetAlarm(0, pValue);
		todIoctl(0,	TOD_ENABLE_ALARM_IRQ, 0);
	}	
	
	else if(TimerID == TOD_ONE_SEC_INTERRUPT) 
	{
		todIoctl(0, TOD_ENABLE_ONE_SEC_IRQ, 0);
	}
	
	else
	{
		POSIXTimerContext[TimerID].pSetTime(TimerID, pValue);
		POSIXTimerParam.CallbackOnCompare.pCallbackArg = POSIXTimerContext[TimerID].pUserFuncArg;
		qtIoctl(POSIXTimerContext[TimerID].FileDesc,QT_ENABLE,(void*)&POSIXTimerParam,POSIXDeviceList[TimerID]);
	}

	return 0;
}

/*****************************************************************************/
int clock_settime(clockid_t ClockID, const struct timespec * tp)
{
	if(ClockID == CLOCK_TOD)
	{
		POSIXTodContext[0].pOpen(CLOCK_TOD, 0, (void *)tp);
		todIoctl(0,	TOD_ENABLE, 0);
	}
		
	return 0;
}

/*****************************************************************************/
int clock_gettime(clockid_t ClockID, struct timespec * tp)
{
	if(ClockID == CLOCK_TOD)
	{
		struct tm GetTime;
		
		POSIXTodContext[0].pGetTime(&GetTime);
		
		tp -> tv_sec  = POSIXTodContext[0].pMakeTime(&GetTime);
		tp -> tv_nsec = 0;
	}
	else
	{
		/* Current implementation returns elapsed time for CLOCK_REALTIME 
			regardless of which clock id is specified.
		*/
        UWord16 tcount;
        /* added result qt value */
	    tcount = qtIoctl(POSIXTimerContext[0].FileDesc, QT_READ_COUNTER_REG, 0,POSIXDeviceList[0] );
		tp -> tv_nsec = timerRTElapsedTime.tv_nsec + (UWord32)tcount * timerNanosecPerCount;
		tp -> tv_sec  = timerRTElapsedTime.tv_sec;
	}
	
	return 0;
}

/*****************************************************************************/
int clock_getres(clockid_t ClockID, struct timespec * Resolution)
{
	Resolution->tv_sec  = 0;
    Resolution->tv_nsec = 1000000000/POSIXTimerContext[ClockID].ResolutionFreq;
    return 0;
}


/*****************************************************************************/
int nanosleep(const struct timespec * rqtp, struct timespec * rmtp)
{
    Word32 Ticks;
    Word32 ms;
    struct timespec Resolution;

    if (rmtp != NULL) {
        return FAIL;
    }

    ms = rqtp->tv_nsec / timerTickNanoseconds;

    if (rqtp->tv_nsec - ms * timerTickNanoseconds > 0) {
        /* ceil function to next millsecond */
        ms++;
    }

    ms += rqtp->tv_sec * timerTickHZ;

    
    clock_getres(CLOCK_REALTIME, &Resolution);

    Ticks = timerTickNanoseconds / Resolution.tv_nsec * ms;
    
    if(Ticks == 0)
    {
        Ticks = 1;
    }

    timerSleep (Ticks);

    return 0;
}


/*****************************************************************************/
Result timerCreate(const char * pName)
{
#if 0
    struct itimerspec TimerSettings;

    RealTimeEvent.sigev_notify_function = timerRealTimeClockISR;

    timer_create(CLOCK_REALTIME, &RealTimeEvent, &RealTimeTimer);

    TimerSettings.it_interval.tv_sec  = 0;
    TimerSettings.it_interval.tv_nsec = 1000000;
    TimerSettings.it_value.tv_sec     = 0;
    TimerSettings.it_value.tv_nsec    = 1000000;
    
    timerTickDuration = TimerSettings.it_interval;

    timer_settime(RealTimeTimer, 0, &TimerSettings, NULL);
#endif

	/* Optimized for fixed resolution calculated in config.c */

    RealTimeEvent.sigev_notify_function = timerRealTimeClockISR;

    timer_create(CLOCK_REALTIME, &RealTimeEvent, &RealTimeTimer);

    timerTickDuration.tv_sec  = 0;
    timerTickDuration.tv_nsec = timerTickNanoseconds;

	POSIXTimerContext[0].Counter            = 1;
	POSIXTimerContext[0].reloadCounterValue = 1;
	POSIXTimerContext[0].ResolutionFreq     = timerTickHZ;
    
    POSIXTimerParam.InputSource             = timerInputSource;
    POSIXTimerParam.InitialLoadValue        = timerTickLoadValue;

	POSIXTimerParam.CallbackOnCompare.pCallbackArg = POSIXTimerContext[0].pUserFuncArg;
    
	qtIoctl(POSIXTimerContext[0].FileDesc, 
    			QT_ENABLE, 
    			(void*)&POSIXTimerParam,
    			POSIXDeviceList[0] );


    return PASS;
}



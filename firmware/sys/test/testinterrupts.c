#include "port.h"
#include "arch.h"
#include "test.h"
#include "timer.h"
#include "stdlib.h"
#include "appconst.h"

/*-----------------------------------------------------------------------*

    testInterrupts.c
	
*------------------------------------------------------------------------*/

Result testInterrupts(test_sRec *);

volatile bool   bInterruptCalled;
volatile bool   bNestedInterruptsWorked;
volatile UInt16 LoopCount = 0;

static asm bool VerifyRegisterValues (UWord16 Value)
{
		cmp   Y0,Y1
		bne   RegNE
		
		move  n,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a2,Y1
		andc  #0x000F,Y1
		move  Y0,X0
		andc  #0x000F,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  b0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  b1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  b2,Y1
		andc  #0x000F,Y1
		move  Y0,X0
		andc  #0x000F,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  r0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r2,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r3,Y1
		cmp   Y0,Y1
		bne   RegNE

		move  m01,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  lc,Y1
		andc  #0x1FFF,Y1
		move  Y0,X0
		andc  #0x1FFF,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  hws,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  hws,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  la,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$30,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$31,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$32,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$33,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$34,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$35,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$36,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x:<$37,Y1
		cmp   Y0,Y1
		bne   RegNE
				
		move  #1,Y0 ; verify succeeded
		rts
		
  RegNE:
  		clr   Y0    ; verify failed
  		rts
  		
}

static asm void SetRegisterValues (UWord16 Value)
{
		move  Y0,n
		move  Y0,x0
		move  Y0,y1
		move  Y0,a0
		move  Y0,a1
		move  Y0,a2
		move  Y0,b0
		move  Y0,b1
		move  Y0,b2
		move  Y0,r0
		move  Y0,r1
		move  Y0,r2
		move  Y0,r3

		move  Y0,m01
		move  Y0,lc

		move  hws,la
		move  hws,la
		move  Y0,hws
		move  Y0,hws	

		move  Y0,la
		
		move  Y0,x:<$30
		move  Y0,x:<$31
		move  Y0,x:<$32
		move  Y0,x:<$33
		move  Y0,x:<$34
		move  Y0,x:<$35
		move  Y0,x:<$36
		move  Y0,x:<$37
		
		rts
}


static asm bool VerifyFastIntRegisterValues (UWord16 Value)
{
		cmp   Y0,Y1
		bne   RegNE
		
		move  n,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  x0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  a2,Y1
		andc  #0x000F,Y1
		move  Y0,X0
		andc  #0x000F,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  b0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  b1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  b2,Y1
		andc  #0x000F,Y1
		move  Y0,X0
		andc  #0x000F,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  r0,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r1,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r2,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  r3,Y1
		cmp   Y0,Y1
		bne   RegNE

		move  lc,Y1
		andc  #0x1FFF,Y1
		move  Y0,X0
		andc  #0x1FFF,X0
		cmp   X0,Y1
		bne   RegNE
		
		move  la,Y1
		cmp   Y0,Y1
		bne   RegNE
		
		move  #1,Y0 ; verify succeeded
		rts
		
  RegNE:
  		clr   Y0    ; verify failed
  		rts
  		
}

static asm void SetFastIntRegisterValues (UWord16 Value)
{
		move  Y0,n
		move  Y0,x0
		move  Y0,y1
		move  Y0,a0
		move  Y0,a1
		move  Y0,a2
		move  Y0,b0
		move  Y0,b1
		move  Y0,b2
		move  Y0,r0
		move  Y0,r1
		move  Y0,r2
		move  Y0,r3

		move  Y0,lc
		move  Y0,la
		
		rts
}


static void ISRTrashRegisters (void)
{
	bInterruptCalled = true;
	
	SetRegisterValues (0x9876);
}


static void ISRTrashFastIntRegisters (void)
{
	bInterruptCalled = true;
	
	SetFastIntRegisterValues (0x9876);
}


static void ISRContainingDoLoop (void)
{
	bInterruptCalled = true;
	
	asm 
	{
		do   #5,EnddoISR
		incw LoopCount
	  EnddoISR:
	};    

}


static void ISRHandler (void)
{
	bInterruptCalled = true;
}


static void Timer1ISR(void)
{
	/* 
		This ISR will be blocked until the Timer2ISR is
		called to demonstrate use of nested interrupts.
	*/

	bInterruptCalled = false;	
	while (!bInterruptCalled)
		continue;
	bNestedInterruptsWorked = true;
}


static void Timer2ISR(void)
{
	bInterruptCalled = true;		
}



Result testInterrupts(test_sRec *pTestRec)
{
	struct sigevent   Timer1Event;
	struct sigevent   Timer2Event;
	timer_t           Timer1;
	timer_t           Timer2;
	struct itimerspec Timer1Settings;
	struct itimerspec Timer2Settings;
	struct timespec   HalfSecond      = {0, 500000000};
	
	testStart (pTestRec, IntTestStartMsg);

	/************************/
	/* Test Basic Interrupt */
	/************************/

	bInterruptCalled = false;
	
	archInstallISR((UWord32 *) 0x0008, ISRHandler);

	asm (swi);
		
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveISR((UWord32 *) 0x0008);


	/************************************/
	/* Test Dispatcher Save and Restore */
	/************************************/

	archInstallISR((UWord32 *) 0x0008, ISRTrashRegisters);

	bInterruptCalled = false;
	
	SetRegisterValues (0x1234);
	
	asm (swi);
	
	if (!VerifyRegisterValues (0x1234)) 
	{
		testFailed(pTestRec, IntDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveISR((UWord32 *) 0x0008);
	
	
	/************************************/
	/* Test Dispatcher HWS Save/Restore */
	/************************************/

	archInstallISR((UWord32 *) 0x0008, ISRContainingDoLoop);

	bInterruptCalled = false;
	
	LoopCount = 0;
	
	asm 
	{
		do   #5,Enddo7
		incw LoopCount
	    swi
	    nop
	    nop
	  Enddo7:
	    nop
	};    

	if (LoopCount != 30) 
	{
		testFailed(pTestRec, IntDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveISR((UWord32 *) 0x0008);
	
	
	/************************************/
	/* Test Dispatcher HWS Save/Restore */
	/************************************/

	archInstallISR((UWord32 *) 0x0008, ISRTrashRegisters);

	bInterruptCalled = false;
	
	asm 
	{
		clr  Y0
		do   #5,Enddo1
		push LC
		push LA
		incw Y0
		do   #3,Enddo2
		nop
		nop
		swi
		nop
		nop
		incw Y0
		nop
		nop
		nop
	  Enddo2:
	  	pop  LA
	  	pop  LC
	    nop
	    nop
	    nop
	  Enddo1:
	    move Y0,LoopCount
	};    

	if (LoopCount != 20) 
	{
		testFailed(pTestRec, IntDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveISR((UWord32 *) 0x0008);
	
	
	/************************/
	/* Test Fast Interrupt  */
	/************************/

	bInterruptCalled = false;
	
	archInstallFastISR((UWord32 *) 0x0008, ISRHandler);

	asm (swi);
		
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveFastISR((UWord32 *) 0x0008);


	/************************************/
	/* Test Fast Dispatcher Save and Restore */
	/************************************/

	archInstallFastISR((UWord32 *) 0x0008, ISRTrashFastIntRegisters);

	bInterruptCalled = false;
	
	SetFastIntRegisterValues (0x1234);
	
	asm (swi);
	
	if (!VerifyFastIntRegisterValues (0x1234)) 
	{
		testFailed(pTestRec, IntFastDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveFastISR((UWord32 *) 0x0008);
	
	
	/************************************/
	/* Test Fast Dispatcher Nested DO */
	/************************************/

	archInstallFastISR((UWord32 *) 0x0008, ISRContainingDoLoop);

	bInterruptCalled = false;
	
	LoopCount = 0;
	
	asm 
	{
		do   #5,Enddo8
		incw LoopCount
	    swi
	    nop
	    nop
	  Enddo8:
	    nop
	};    

	if (LoopCount != 30) 
	{
		testFailed(pTestRec, IntFastDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveFastISR((UWord32 *) 0x0008);
	
	
	/************************************/
	/* Test Dispatcher HWS Save/Restore */
	/************************************/

	archInstallISR((UWord32 *) 0x0008, ISRTrashRegisters);

	bInterruptCalled = false;
	
	asm 
	{
		clr  Y0
		do   #5,Enddo9
		push LC
		push LA
		incw Y0
		do   #3,Enddo10
		nop
		nop
		swi
		nop
		nop
		incw Y0
		nop
		nop
		nop
	  Enddo10:
	  	pop  LA
	  	pop  LC
	    nop
	    nop
	    nop
	  Enddo9:
	    move Y0,LoopCount
	};    

	if (LoopCount != 20) 
	{
		testFailed(pTestRec, IntDispatcherFailed);
	}
	
	if (!bInterruptCalled) 
	{
		testFailed(pTestRec, IntSWIFailedMsg);
	}

	archRemoveISR((UWord32 *) 0x0008);
	



	/*************************************************/
	/* Test archPushAllRegisters/archPopAllRegisters */
	/*************************************************/

	SetRegisterValues (0x5678);
	
	archPushAllRegisters();
	
	SetRegisterValues (0x5432);
	
	if (!VerifyRegisterValues (0x5432)) 
	{
		testFailed(pTestRec, IntPushAllFailed);
	}
	
	archPopAllRegisters();
	
	if (!VerifyRegisterValues (0x5678)) 
	{
		testFailed(pTestRec, IntPushAllFailed);
	}
	
	
	/******************************************************************/
	/* Test archPushAllRegisters/archPopAllRegisters HWS Save/Restore */
	/******************************************************************/

	asm 
	{
		clr  Y0
		do   #5,Enddo3
		push LC
		push LA
		incw Y0
		do   #3,Enddo4
		nop
		nop
		jsr  archPushAllRegisters
		move #3456,Y0
		jsr  SetRegisterValues
		jsr  archPopAllRegisters
		nop
		incw Y0
		nop
		nop
		nop
	  Enddo4:
	  	pop  LA
	  	pop  LC
	    nop
	    nop
	    nop
	  Enddo3:
	    move Y0,LoopCount
	};    

	if (LoopCount != 20) 
	{
		testFailed(pTestRec, IntPushAllFailed);
	}
	
	
	/*************************************************/
	/* Test archPushFastInterruptRegisters/archPopFastInterruptRegisters */
	/*************************************************/

	SetFastIntRegisterValues (0x5678);
	
	archPushFastInterruptRegisters();
	
	SetFastIntRegisterValues (0x5432);
	
	if (!VerifyFastIntRegisterValues (0x5432)) 
	{
		testFailed(pTestRec, IntPushFastInterruptFailed);
	}
	
	archPopFastInterruptRegisters();
	
	if (!VerifyFastIntRegisterValues (0x5678)) 
	{
		testFailed(pTestRec, IntPushFastInterruptFailed);
	}
	
	
	/******************************************************************/
	/* Test archPushFastInterruptRegisters/archPop... HWS Save/Restore */
	/******************************************************************/

	asm 
	{
		clr  Y0
		do   #5,Enddo5
		push LC
		push LA
		incw Y0
		do   #3,Enddo6
		nop
		nop
		jsr  archPushFastInterruptRegisters
		move #3456,Y0
		jsr  SetFastIntRegisterValues
		jsr  archPopFastInterruptRegisters
		nop
		incw Y0
		nop
		nop
		nop
	  Enddo6:
	  	pop  LA
	  	pop  LC
	    nop
	    nop
	    nop
	  Enddo5:
	    move Y0,LoopCount
	};    

	if (LoopCount != 20) 
	{
		testFailed(pTestRec, IntPushFastInterruptFailed);
	}
	
	
	/*************************/
	/* Test Nested Interrupt */
	/*************************/

	bInterruptCalled        = false;
	bNestedInterruptsWorked = false;
	
	Timer1Event.sigev_notify_function = (void *)Timer1ISR;

	timer_create(CLOCK_AUX1, &Timer1Event, &Timer1);

	Timer1Settings.it_interval.tv_sec  = 0;
	Timer1Settings.it_interval.tv_nsec = 250000000;
	Timer1Settings.it_value.tv_sec     = 0;
	Timer1Settings.it_value.tv_nsec    = 250000000;

	timer_settime(Timer1, 0, &Timer1Settings, NULL);


	Timer2Event.sigev_notify_function = (void *)Timer2ISR;

	timer_create(CLOCK_AUX2, &Timer2Event, &Timer2);


	Timer2Settings.it_interval.tv_sec  = 0;
	Timer2Settings.it_interval.tv_nsec = 125000000;
	Timer2Settings.it_value.tv_sec     = 0;
	Timer2Settings.it_value.tv_nsec    = 125000000;

	timer_settime(Timer2, 0, &Timer2Settings, NULL);

	/* This test will hang if it does not work */
	while (!bNestedInterruptsWorked)
		continue;

	timer_delete(Timer1);
	timer_delete(Timer2);
		
	asm(move #0xFFFF,M01); /* reset addressing to linear */	
		
	testEnd (pTestRec);
	
	return PASS;
}






#include "port.h"
#include "arch.h"
#include "assert.h"
#include "periph.h"
#include "mempx.h"
#include "types.h"

arch_sInterrupts * pArchInterrupts = (arch_sInterrupts *) ARCH_INTERRUPTS;

extern UWord16 archISRType[(sizeof(arch_sInterrupts) / sizeof(UWord32) + 15) / 16];
/* ISRType is an array of bits for each interrupt
		0 => Normal interrupt
		1 => Fast interrupt
*/

extern sUserISR archUserISRTable[sizeof(arch_sInterrupts) / sizeof(UWord32)];
/* archUserISRTable has been moved to pramdata.c to save data ram */

extern void * _Xdata_start_addr_in_RAM;
extern void * _Xdata_ROMtoRAM_length;
extern void * _Xdata_start_addr_in_ROM;

extern void * _Xbss_start_addr;
extern void * _Xbss_length;

extern void * _Pdata_start_addr_in_ROM;
extern void * _Pdata_ROMtoRAM_length;
extern void * _Pdata_start_addr_in_RAM;

extern void * _Pbss_start_addr;
extern void * _Pbss_length;

EXPORT void archUnhandledInterrupt (void);


/*****************************************************************************/
asm Flag archGetLimitBit()
{
   move  #0,Y0
   brclr #0x40,SR,LClear
   move  #1,Y0
LClear:
   rts
}
/*****************************************************************************/
asm bool archGetSetSaturationMode (bool saturationMode)
{
   move  #0,X0
   brclr #0x10,OMR,SClear
   move  #1,X0
SClear:

	cmp   #0,Y0
	beq   SatOff
	bfset #0x10,OMR
	move  X0,Y0
	rts
SatOff:
	bfclr #0x10,OMR
	move  X0,Y0
	rts
}


/*****************************************************************************/
asm static bool InstallUserISR(UWord32 * pIntStartAddr, void (*pISR)(void))
{
	/* 
		Return true if Mode=3 and we can put User ISR in Interrupt Vector;
		Otherwise, return false (0) because we cannot modify a single location
		in program flash. 
	*/
	move OMR,Y0        ; Mode = 3?
	andc #$0003,Y0
	beq  Mode0
	
 Mode3:	
	move #$E9C8,y1     ; Load JSR opcode
	move y1,p:(r2)+    ; Create JSR UserISR
	move r3,p:(r2)+
	move #true,Y0
	
  Mode0:
	rts
}


/*****************************************************************************/
UWord16 archInstallISR(UWord32 * pIntStartAddr, void (*pISR)(void))
{
	UWord16 IntNumber;

	/* Interrupt address is not within the vector table address range */
	assert (((UWord16)pIntStartAddr) < ((UWord16)pArchInterrupts + \
										 sizeof(arch_sInterrupts)));

	/* Interrupt address is not on an even address boundary */
	assert ((((UWord16)pIntStartAddr) & 1) == 0);
	
	IntNumber = ((UWord16) pIntStartAddr) >> 1;

	archISRType[IntNumber / 16] &= ~(1 << (IntNumber % 16));
	
	//archUserISRTable[IntNumber].pUserISR  = pISR;
	memWriteP16 ((unsigned short)pISR, (Word16 *)(&archUserISRTable[IntNumber].pUserISR));
	
	return 0;
}


/*****************************************************************************/
UWord16 archRemoveISR (UWord32 * pIntStartAddr)
{
	archInstallISR(pIntStartAddr, archUnhandledInterrupt);

	return 0;
}

/*****************************************************************************/
UWord16 archInstallFastISR(UWord32 * pIntStartAddr, void (*pISR)(void))
{
	UWord16 IntNumber;

	/* Interrupt address is not within the vector table address range */
	assert (((UWord16)pIntStartAddr) < ((UWord16)pArchInterrupts + \
										 sizeof(arch_sInterrupts)));

	/* Interrupt address is not on an even address boundary */
	assert ((((UWord16)pIntStartAddr) & 1) == 0);

	IntNumber = ((UWord16) pIntStartAddr) >> 1;

	archISRType[IntNumber / 16] |= 1 << (IntNumber % 16);
	
	//archUserISRTable[IntNumber].pUserISR  = pISR;
	memWriteP16 ((unsigned short)pISR, (Word16 *)(&archUserISRTable[IntNumber].pUserISR));
	
	return 0;
}

/*****************************************************************************/
UWord16 archInstallSFastISR(UWord32 * pIntStartAddr, void (*pISR)(void))
{
	/* Interrupt address is not within the vector table address range */
	assert (((UWord16)pIntStartAddr) < ((UWord16)pArchInterrupts + \
										 sizeof(arch_sInterrupts)));

	/* Interrupt address is not on an even address boundary */
	assert ((((UWord16)pIntStartAddr) & 1) == 0);

	if (!InstallUserISR(pIntStartAddr, pISR))
	{
		/* Use Fast ISR instead of Super Fast since we cannot modify flash */
		archInstallFastISR(pIntStartAddr, pISR);
		
		/* 
			Note:  To overcome this limitation, define INTERRUPT_VECTOR_ADDR_n in 
			appconfig.h to the address of your ISR;  Your ISR will then be placed 
			directly in the interrupt vector in flash.
		*/
	}
	
	return 0;
}

/*****************************************************************************/
UWord16 archRemoveSFastISR (UWord32 * pIntStartAddr)
{
	archInstallSFastISR(pIntStartAddr, archUnhandledInterrupt);

	return 0;
}

/*****************************************************************************/
void archUnhandledInterrupt (void)
{
	/* The N register contains the unhandled interrupt number (0 - 63) */
	assert (false);
}

/*****************************************************************************/
static void archInitUnhandledISRs(void)
{
	UInt16  NumInterrupts= (UInt16)(sizeof(arch_sInterrupts) / sizeof(UWord32));
 	UInt16  i;
	
	for (i=0;  i < NumInterrupts; i++)
	{
		archInstallISR((UWord32 *)(i*sizeof(UWord32)), archUnhandledInterrupt);
	}
	
	for (i=0; i < sizeof(archISRType) / sizeof(UWord16); i++)
	{
		archISRType[i] = 0;   /* Normal interrupt */
	}
}


/*****************************************************************************/
static void archInitializeRAM(void)
{
	ssize_t   BssLength = (ssize_t)&_Xbss_length;
	UWord16 * BssAddr   = (UWord16 *)&_Xbss_start_addr;
	ssize_t   BssTempLength;

	/* this is to initialize uninitialized X: data section */		
	do
	{
		if(BssLength > PORT_MAX_VECTOR_LEN)
		{
			BssTempLength = PORT_MAX_VECTOR_LEN;
		}
		else
		{
			BssTempLength = BssLength;
		}
		
		memset(BssAddr, 0, BssTempLength);
		
		BssAddr += BssTempLength;
		
	}while((BssLength -= BssTempLength) != 0);
	
	/* this is to initialize initialized X: data section */
	memCopyPtoX( &_Xdata_start_addr_in_RAM,
			&_Xdata_start_addr_in_ROM,
			(UInt16)&_Xdata_ROMtoRAM_length);

	/* this is to initialize uninitialized P: data section */
	memSetP(&_Pbss_start_addr, 0, (ssize_t)&_Pbss_length);
		
	/* this is to initialize initialized P: data section */
	memCopyPtoP( &_Pdata_start_addr_in_RAM,
			&_Pdata_start_addr_in_ROM,
			(UInt16)&_Pdata_ROMtoRAM_length);

}

/*****************************************************************************/
asm void archDelay(UWord16 Ticks)
{
   move    y0,lc
   do      lc,archDelay1
   nop
archDelay1:
	rts
}

/*****************************************************************************/
#define mr15	    $3F
#define argc 0

extern configInitialize(), main(), configFinalize();
extern char * _StackAddr;

/*****************************************************************************/
asm void archStart(void)
{
	bfclr   #$0002,ArchIO.Cop.ControlReg  //; Disable COP

	move    #$0000,ArchIO.Tod.ControlReg  //; Disable TOD
	
	bfset   #$0100,OMR      //; Set CC for 32-bit compares

	move	#-1,x0
	move	x0,m01          //; Set the m register to linear addressing
				
	move	hws,la          //; Clear the hardware stack
	move	hws,la

	move	#_StackAddr,r0  //; Get Stack start address from Linker.cmd file
	nop
	move	r0,x:<mr15      //; set frame pointer to main stack top	
	move	r0,sp           //; set stack pointer too
	move	#0,r1
	move	r1,x:(r0)

	jsr     archInitializeRAM
	
	jsr     configInitialize

	jsr	    main            //; Call the Users program
	
	jsr     configFinalize  //; Flush output, handle end of program
	
	rts
}


asm void archPushAllRegisters(void)
{

; 
; Push ALL registers onto the stack EXCEPT for the following registers:
;
;     PC           => assumed to be global
;     IPR          => assumed to be global
;     SP           => assumed to be global
;     0x38 - 0x3F  => Permanent register file used by CW
;

		lea   (SP)+
		move  n,x:(SP)+
		move  x0,x:(SP)+
		move  y0,x:(SP)+
		move  y1,x:(SP)+
		move  a0,x:(SP)+
		move  a1,x:(SP)+
		move  a2,x:(SP)+
		move  b0,x:(SP)+
		move  b1,x:(SP)+
		move  b2,x:(SP)+
		move  r0,x:(SP)+
		move  r1,x:(SP)+
		move  r2,x:(SP)+
		move  r3,x:(SP)+

		move  omr,x:(SP)+
		move  la,x:(SP)+
		move  m01,x:(SP)+
		move  lc,x:(SP)+

		;
		; save hardware stack
		;
		move  hws,x:(SP)+
		move  hws,x:(SP)+
	
		;
		; Save temporary register file at 0x30 - 0x37 used by compiler
		;
		move  x:<$30,y1
		move  y1,x:(SP)+
		move  x:<$31,y1
		move  y1,x:(SP)+
		move  x:<$32,y1
		move  y1,x:(SP)+
		move  x:<$33,y1
		move  y1,x:(SP)+
		move  x:<$34,y1
		move  y1,x:(SP)+
		move  x:<$35,y1
		move  y1,x:(SP)+
		move  x:<$36,y1
		move  y1,x:(SP)+
		move  x:<$37,y1
		move  y1,x:(SP)+
		
		; 
		; 28 words have been pushed on the stack.
		; To return, we must simulate the original jsr
		;
		move  x:(SP-30),y1   ; copy return address
		move  y1,x:(SP)+
		move  SR,x:(SP)      ; copy SR
		
		rti		
}


asm void archPopAllRegisters(void)
{

; 
; Pop ALL registers from the stack in reverse   
; order from the routine archPushAllRegisters
;
				
		; 
		; To return, we must simulate the original 
		; jsr after popping all registers saved
		;
		; We use the stack space
		; from the call to archPushAllRegisters
		; to store the PC/SR for the RTS instruction 
		;
		pop   y1             ; Pop SR; restore SR from archPushAllRegisters
		pop   y1             ; copy return address
		move  y1,x:(SP-29) 

		;
		; Pop temporary register file used by the compiler
		;
		pop   y1
		move  y1,x:<$37
		pop   y1
		move  y1,x:<$36
		pop   y1
		move  y1,x:<$35
		pop   y1
		move  y1,x:<$34
		pop   y1
		move  y1,x:<$33
		pop   y1
		move  y1,x:<$32
		pop   y1
		move  y1,x:<$31
		pop   y1
		move  y1,x:<$30

		;
		; restore hardware stack
		;
		move  hws,la  ; Clear HWS to ensure proper reload
		move  hws,la
		pop   HWS
		pop   HWS
		
		;
		; restore all saved registers
		;
		pop   lc
		pop   m01
		pop   la
		pop   omr

		pop   r3
		pop   r2
		pop   r1
		pop   r0
		pop   b2
		pop   b1
		pop   b0
		pop   a2
		pop   a1
		pop   a0

		pop   y1
		pop   y0
		pop   x0

		pop   n
		
		rti
}


asm void archPushFastInterruptRegisters(void)
{

;
; Push fast interrupt registers onto the stack;  DOES NOT push the following registers:
;
;     PC          => assumed to be global
;     IPR         => assumed to be global
;     SP          => assumed to be global
;     OMR         => assumed to be global
;     m01         => assumed to be global
;     hws         => assumed to be global
;     0x30 - 0x3F => CW register file
;     

		lea   (SP)+
		move  n,x:(SP)+
		move  x0,x:(SP)+
		move  y0,x:(SP)+
		move  y1,x:(SP)+
		move  a0,x:(SP)+
		move  a1,x:(SP)+
		move  a2,x:(SP)+
		move  b0,x:(SP)+
		move  b1,x:(SP)+
		move  b2,x:(SP)+
		move  r0,x:(SP)+
		move  r1,x:(SP)+
		move  r2,x:(SP)+
		move  r3,x:(SP)+

		move  la,x:(SP)+
		move  lc,x:(SP)+

		; 
		; 16 registers have been pushed on the stack.
		; To return, we must simulate the original jsr
		;
		move  x:(SP-18),y1   ; copy return address
		move  y1,x:(SP)+
		move  SR,x:(SP)      ; copy SR

		rts
}


asm void archPopFastInterruptRegisters(void)
{

; 
; Pop fast interrupt registers from the stack in reverse   
; order from the routine archPushFastInterruptRegisters
;

		; 
		; To return, we must simulate the original 
		; jsr after popping all registers saved
		;
		; We use the stack space
		; from the call to archPushFastInterruptRegisters
		; to store the PC/SR for the RTS instruction 
		;
		pop   y1             ; pop SR; restore SR from archPushFastInterruptRegisters
		pop   y1
		move  y1,x:(SP-17)   ; copy return address 

		pop   lc
		pop   la

		pop   r3
		pop   r2
		pop   r1
		pop   r0
		pop   b2
		pop   b1
		pop   b0
		pop   a2
		pop   a1
		pop   a0

		pop   y1
		pop   y0
		pop   x0

		pop   n
		
		rti
}


#define IPR                       X:$FFFB

extern Word16 configNestedIPRmask[];

asm void archEnterNestedInterruptCommon (void)
{
;
; Upon entry to this routine, the N register must contain
; the number of the interrupt;  this is typically done by the routine
; archEnterNestedInterrupt.  Interrupts must be disabled.
;
		tstw  configNestedIPRmask      ; Q: Nested interrupts enabled?
		beq   EndEnterNestedInterrupt
		
		lea   (SP)+                    ; Save registers used 
		move  x0,x:(SP)+
		move  IPR,x0                   ; Leave IPR in X0 reg
		move  x0,x:(SP)+
		move  y0,x:(SP)+
		move  r2,x:(SP)+

		; 
		; re-enable interrupts if controlled by ITCN
		;
		move  #configNestedIPRmask,R2  ; Get address of table
		;
		; Nest interrupts only if ITCN controls (int #10-63)
		;
		move  N,Y0
		cmp   #10,Y0      
		blt   KeepFastDisabled
		;
		; enable nested interrupts
		;
		move  X:(R2+N),Y0              ; Load nested interrupt mask
		and   Y0,X0                    ; X0 contains IPR
		move  X0,IPR                   ; Set new IPR value

		bfclr #$0200,SR                ; Reenable interrupts
		
KeepFastDisabled:

		; 
		; 4 registers have been pushed on the stack.
		; To return, we must simulate the original jsr
		;
		move  x:(SP-6),y0   ; copy return address
		move  y0,x:(SP)+    
		move  SR,x:(SP)     ; copy SR

EndEnterNestedInterrupt:

		rts
}


asm void archExitNestedInterruptCommon  (void)
{
		tstw  configNestedIPRmask      ; Q: Nested interrupts enabled?
		beq   EndExitNestedInterrupt
		
		; 
		; To return, we must simulate the original 
		; jsr after popping all registers saved
		;
		; We use the stack space
		; from the call to archEnterNestedInterruptCommon
		; to store the PC/SR for the RTS instruction 
		;
		pop   y0            ; copy SR
		move  y0,x:(SP-5)
		pop   y0
		move  y0,x:(SP-5)   ; copy return address 

		pop   r2            ; restore R2
		pop   y0            ; restore Y0

  		bfset #$0200,SR		; disable interrupts	
  			
		pop   x0            ; restore IPR 
		move  x0,IPR

		pop   x0            ; restore x0

EndExitNestedInterrupt:

		rts
}


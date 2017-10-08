/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: qtimerdrv.c 
*
* Description:  - quadrature timer driver
*
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "periph.h"
#include "assert.h"
#include "bsp.h"
#include "quadraturetimer.h"
#include "const.h"
#include "mempx.h"


/*** inner services ***/
static void SetQTParams (qt_sState* pState, qt_tQTConfig* qDevice );
static void QTIsr       (arch_sTimerChannel* base, qt_tQTContext* device);                                                 


/*** Quadrature Timer Super ISRs ***/
#define QTIMER_SUPER_ISR(ISR_NAME,ISR_NUMBER,CALLBACKS,TIMER_ADDR) \
void ISR_NAME (void) \
{ \
/* # pragma interrupt */ \
    asm (lea    (SP)+); \
    asm (move   N,x:(SP)); \
    \
    asm (move   ISR_NUMBER,N); \
    asm (jsr    archEnterNestedInterruptCommon); \
	\
    asm (lea    (SP)+); \
    asm (move   R2,x:(SP)+); \
    asm (move   R3,x:(SP)); \
    asm (move   TIMER_ADDR,R2); \
    asm (move   CALLBACKS,R3); \
    \
    asm (jsr    QTIsr); \
	\
    asm (pop    R3); \
    asm (pop    R2); \
    \
    asm (jsr    archExitNestedInterruptCommon); \
    asm (pop    N); \
    asm (rti); \
}

QTIMER_SUPER_ISR (QTimerSuperISRA0, #34, #qt_ctx_A_0, #ArchIO.TimerA.Channel0);
QTIMER_SUPER_ISR (QTimerSuperISRA1, #35, #qt_ctx_A_1, #ArchIO.TimerA.Channel1);
QTIMER_SUPER_ISR (QTimerSuperISRA2, #36, #qt_ctx_A_2, #ArchIO.TimerA.Channel2);
QTIMER_SUPER_ISR (QTimerSuperISRA3, #37, #qt_ctx_A_3, #ArchIO.TimerA.Channel3);


/*****************************************************************************
*
* Module: QTIsr
*
* Description: Quadrature Isr timer routine
*
* Returns: none
*
* Arguments: device hardware map, device descroptor
*
* Range Issues: 
*
* Special Issues: to be configured statically
*
* Test Method: 
*
*****************************************************************************/
#if 0
void QTIsr(arch_sTimerChannel* base, qt_tQTContext* device) 


{       
    register UWord16 reg;

    reg = base->StatusControlReg;
    if( ((QTB_TCFIE | QTB_TCF) & reg) == (QTB_TCFIE | QTB_TCF) )
    {
        device->CallbackOnCompare.pCallback( qtCompare,                 
                device->CallbackOnCompare.pCallbackArg );                   
        periphBitClear( QTB_TCF, &base->StatusControlReg );             
    }
    if( ((QTB_TOFIE | QTB_TOF) & reg) == (QTB_TOFIE | QTB_TOF) )
    {
        device->CallbackOnOverflow.pCallback( qtOverflow,               
                device->CallbackOnOverflow.pCallbackArg );                  
        periphBitClear( QTB_TOF, &base->StatusControlReg );             
    }
    if( ((QTB_IEFIE | QTB_IEF) & reg) == (QTB_IEFIE | QTB_IEF) )
    {
        device->CallbackOnInputEdge.pCallback( qtInputEdge,             
                device->CallbackOnInputEdge.pCallbackArg );                 
        periphBitClear( QTB_IEF, &base->StatusControlReg );             
    }
}

#else

static asm void QTIsr(arch_sTimerChannel* base, qt_tQTContext* device)                                                 
{
; #pragma interrupt
    /*
        R2        => base
        R3        => device
        
        x:(SP)    => saved R3
        x:(SP-1)  => saved R2
        x:(SP-2)  => saved R1
        x:(SP-3)  => saved Y0
        
    */
    lea     (SP)+                    ; save registers
    move    Y0,x:(SP)+
    move    R1,x:(SP)+
    move    R2,x:(SP)+
    move    R3,x:(SP)
    bftsth  #$4000,x:(R2+7)          ; Q: QTB_TCFIE?
    bcc     TestOverflow
    bfclr   #$8000,x:(R2+7)          ; Q: QTB_TCF? reset it
    bcc     TestOverflow
    ;
    ; call compare callback
    ;
    lea     (SP)+
    move    R3,R1
    move    #CompareCallbackRtn,Y0   ; Load callback return address
    lea     (R1+4)
    move    P:(R1)+,R2              ; Load callback address
    move    Y0,x:(SP)+               ; Simulate JSR to callback
    move    SR,x:(SP)+
    
    move    R2,x:(SP)+               ; Create dynamic JSR
    move    SR,x:(SP)
    move    #0,Y0                    ; Load callback parameters
    move    P:(R1)+,R2
    rts                              ; Call callback procedure
CompareCallbackRtn:
    move    x:(SP-1),R2              ; Restore R2 register
    nop
    
TestOverflow:
    bftsth  #$1000,x:(R2+7)          ; Q: QTB_TOFIE?
    bcc     TestInputEdge
    bfclr   #$2000,x:(R2+7)          ; Q: QTB_TOF? reset it
    bcc     TestInputEdge
    move    x:(SP)+,R3               ; Restore R3 register; inc SP
    ;
    ; call overflow callback
    ;
    move    R3,R1
    move    #OverflowCallbackRtn,Y0  ; Load callback return address
    move    P:(R1)+,R2                ; Load callback address
    move    Y0,x:(SP)+               ; Simulate JSR to callback
    move    SR,x:(SP)+
    
    move    R2,x:(SP)+               ; Create dynamic JSR
    move    SR,x:(SP)
    move    #1,Y0                    ; Load callback parameters
    move    P:(R1)+,R2
    rts                              ; Call callback procedure
OverflowCallbackRtn:
    move    x:(SP-1),R2              ; Restore R2 register
    nop

TestInputEdge:
    bftsth  #$0400,x:(R2+7)          ; Q: QTB_IEFIE?
    bcc     ExitQTIsr
    bfclr   #$0800,x:(R2+7)          ; Q: QTB_IEF? reset it
    bcc     ExitQTIsr
    move    x:(SP)+,R3               ; Restore R3 register; inc SP
    ;
    ; call input edge callback
    ;
    move    R3,R1
    move    #InputEdgeCallbackRtn,Y0            ; Load callback return address
    lea     (R1+2)
    move    P:(R1)+,R2              ; Load callback address
    move    Y0,x:(SP)+               ; Simulate JSR to callback
    move    SR,x:(SP)+
    
    move    R2,x:(SP)+               ; Create dynamic JSR
    move    SR,x:(SP)
    move    #2,Y0                    ; Load callback parameters
    move    P:(R1)+,R2
    rts                              ; Call callback procedure
InputEdgeCallbackRtn:

ExitQTIsr:  
    move    x:(SP-3),Y0              ; restore registers
    move    x:(SP-2),R1
    lea     (SP-4)                   ; pop registers
    rts                              ; exit routine
    
}
#endif

/*** Quadrature timer Normal ISR template ***/
#define INSTQTISR( isr, base, device )                                  \
void isr(void)                                                          \
{                                                                       \
    QTIsr( base,  device);                                              \
} 

/* Quadrature timer isr service routines */
INSTQTISR( QTimerISRA0, &ArchIO.TimerA.Channel0, &qt_ctx_A_0 )
INSTQTISR( QTimerISRA1, &ArchIO.TimerA.Channel1, &qt_ctx_A_1 )
INSTQTISR( QTimerISRA2, &ArchIO.TimerA.Channel2, &qt_ctx_A_2 )
INSTQTISR( QTimerISRA3, &ArchIO.TimerA.Channel3, &qt_ctx_A_3 )


int qtFindDevice(const char * pName)
{
    int            i;
    
    for( i = 0; i < qtNumberOfDevices; i++ )
    {
        if( pName == qtDeviceMap[i].base )
        {
            return (int)&qtDeviceMap[i];
        }
    }
    
    return -1 ; /* Not a QT device */ 
}

/*****************************************************************************
*
* Module: qtOpen
*
* Description: Open the QT device and configure initial parameters.
*
* Returns: device handle or -1 in case of error
*
* Arguments: device name( predefined list should be used )
*            flags for standard open modes
*            iinterface structure (qt_sState) 
*
* Range Issues: none
*
* Special Issues: 
*
* Test Method: Application
*
*****************************************************************************/
int qtOpen(const char * pName, int OFlags, qt_sState * pParams)
{
	int  FileDesc;
	
	FileDesc = qtFindDevice(pName);
	
	if (FileDesc != -1)
	{
		if (pParams != NULL)
		{
    		SetQTParams( pParams,  (qt_tQTConfig *)FileDesc );
    	}
    }

    return FileDesc ;
}


/*****************************************************************************
*
* Module: qtClose
*
* Description: Close the QT device and stop timer.
*
* Returns: status
*
* Arguments: device handle
*
* Range Issues: 
*
* Special Issues: not needed for embedded area (added for compatibility only)
*
* Test Method: none
*
*****************************************************************************/
int qtClose(int FileDesc)
{
    periphMemWrite( 0, &((qt_tQTConfig *)FileDesc)->base->ControlReg );
    return 0;
}



/*****************************************************************************
*
* Module: ioctlQT_ENABLE
*
* Description: enable and start QT device
*
* Returns: none
*
* Arguments: device handle, interface structure
*
* Range Issues: 
*
* Special Issues: 
*
* Test Method: 
*
*****************************************************************************/
UWord16 ioctlQT_ENABLE(int FileDesc, qt_sState * pParams)
{
	if (pParams != NULL)
	{
    	SetQTParams( pParams,  (qt_tQTConfig *)FileDesc );
    }
    
    return 0;
}


/*****************************************************************************
*
* Module: SetQTParams
*
* Description:  encodes interface structure to the device registers
*               and establishes callbacks
*
* Returns: none
*
* Arguments: interface structure, device descriptor
*
* Range Issues: 
*
* Special Issues: 
*
* Test Method: 
*
*****************************************************************************/
#if 0
void SetQTParams( qt_sState * pState, qt_tQTConfig * pDevice )
{
    UWord16              tmp;
    qt_tQTContext      * callback;
    arch_sTimerChannel * pBase = pDevice->base;
    
    periphMemWrite( pState->CompareValue1,    &pBase->CompareReg1 );
    periphMemWrite( pState->CompareValue2,    &pBase->CompareReg2 );
    periphMemWrite( pState->InitialLoadValue, &pBase->LoadReg );
    periphMemWrite( pState->InitialLoadValue, &pBase->CounterReg );

    tmp = 0
        | ( pState->OutputDisabled == 1           ? 0 : QTB_OEN )
        | ( pState->OutputPolarity == qtInverted  ? QTB_OPS : 0 )
        | ( pState->Master                        ? QTB_MSTR : 0 )
        | ( pState->OutputOnMaster                ? QTB_EEOF : 0 )
        |   QTB_CAPTUREMODE( pState->CaptureMode )
        | ( pState->InputPolarity == qtInverted   ? QTB_IPS : 0 )
        | ( pState->CallbackOnInputEdge.pCallback ? QTB_IEFIE : 0 )
        | ( pState->CallbackOnOverflow.pCallback  ? QTB_TOFIE : 0 )
        | ( pState->CallbackOnCompare.pCallback   ? QTB_TCFIE : 0 )
    ;
    periphMemWrite( tmp, &pBase->StatusControlReg );

    tmp = 0
         | QTB_OUTPUTMODE( pState->OutputMode )
         | ( pState->CoChannelInitialize           ? QTB_EXTINIT : 0 )
         | ( pState->CountDirection == qtDown      ? QTB_DIR : 0 )
         | ( pState->CountLength == qtUntilCompare ? QTB_LENGTH : 0 )
         | ( pState->CountFrequency == qtOnce      ? QTB_ONCE : 0 )
         | QTB_SECONDARYSOURCE( pState->SecondaryInputSource ) 
         | QTB_PRIMARYSOURCE( pState->InputSource )
    ;
     
    tmp &= qtExtAMask[pState->Mode];
    tmp |= qtExtAMode[pState->Mode];

    callback = pDevice->ctx;

	memWriteP16 ((UWord16)pState->CallbackOnCompare.pCallback,      (Word16 *)&(callback->CallbackOnCompare.pCallback));
	memWriteP16 ((UWord16)pState->CallbackOnCompare.pCallbackArg,   (Word16 *)&(callback->CallbackOnCompare.pCallbackArg));
    
	memWriteP16 ((UWord16)pState->CallbackOnInputEdge.pCallback,    (Word16 *)&(callback->CallbackOnInputEdge.pCallback));
	memWriteP16 ((UWord16)pState->CallbackOnInputEdge.pCallbackArg, (Word16 *)&(callback->CallbackOnInputEdge.pCallbackArg));
    
	memWriteP16 ((UWord16)pState->CallbackOnOverflow.pCallback,     (Word16 *)&(callback->CallbackOnOverflow.pCallback));
	memWriteP16 ((UWord16)pState->CallbackOnOverflow.pCallbackArg,  (Word16 *)&(callback->CallbackOnOverflow.pCallbackArg));
    
	periphMemWrite( tmp, &pBase->ControlReg );
}
#else

static asm void SetQTParams( qt_sState * pState, qt_tQTConfig * pDevice )
{
; Registers Upon Entry:
;    R2  - pState
;    R3  - pDevice
;
; Register Usage:
;    R2  - pState
;    R3  - pBase
;    R1  - callback
;    X0  - temp
;    Y0  - tmp
;    A0  - *(pState)
;    A1  - *(pState + 1)
;    B1  - temp
;    Y1  - temp
;
;     UWord16              tmp;
;     qt_tQTContext      * callback;

;     callback = pDevice->ctx;

		move    x:(R3+1),R1
		
;     arch_sTimerChannel * pBase = pDevice->base;

		move    x:(R3),R3
		     
;     periphMemWrite( pState->CompareValue1,    &pBase->CompareReg1 );
		
		move    x:(R2+2),X0
		move    X0,x:(R3)
		
;     periphMemWrite( pState->CompareValue2,    &pBase->CompareReg2 );
		
		move    x:(R2+3),X0
		move    X0,x:(R3+1)
		
;     periphMemWrite( pState->InitialLoadValue, &pBase->LoadReg );
		
		move    x:(R2+4),X0
		move    X0,x:(R3+3)
		
;     periphMemWrite( pState->InitialLoadValue, &pBase->CounterReg );
		
		move    X0,x:(R3+5)
		
; 
;     tmp = 0

		clr     Y0               ; tmp = 0
		move    x:(R2),A0        ; *(pState)
		move    x:(R2+1),A1      ; *(pState + 1)
		
;         | ( pState->OutputDisabled == 1           ? 0 : QTB_OEN )

		brset   #0x0010,A1,OutputDisabled
		bfset   #0x0001,Y0
OutputDisabled:

;         | ( pState->OutputPolarity == qtInverted  ? QTB_OPS : 0 )

		brclr   #0x0008,A1,OutputPolarityNormal
		bfset   #0x0002,Y0
OutputPolarityNormal:

;         | ( pState->Master == 1                   ? QTB_MSTR : 0 )

		brclr   #0x0020,A1,Slave
		bfset   #0x0020,Y0
Slave:

;         | ( pState->OutputOnMaster == 1           ? QTB_EEOF : 0 )

		brclr   #0x0040,A1,NoOutput
		bfset   #0x0010,Y0
NoOutput:

;         |   QTB_CAPTUREMODE( pState->CaptureMode )

		move    A1,X0
		andc    #0x0600,X0
		asr     X0
		asr     X0
		asr     X0
		or      X0,Y0
		
;         | ( pState->InputPolarity == qtInverted   ? QTB_IPS : 0 )

		bftstl  #0x0100,A0
		bcs     InputPolarityNormal
		bfset   #0x0200,Y0
InputPolarityNormal:

;         | ( pState->CallbackOnInputEdge.pCallback ? QTB_IEFIE : 0 )

		tstw    x:(R2+9)
		beq     NoCBonInputEdge
		bfset   #0x0400,Y0
NoCBonInputEdge:

;         | ( pState->CallbackOnOverflow.pCallback  ? QTB_TOFIE : 0 )

		tstw    x:(R2+7)
		beq     NoCBonOverflow
		bfset   #0x1000,Y0
NoCBonOverflow:

;         | ( pState->CallbackOnCompare.pCallback   ? QTB_TCFIE : 0 )

		tstw    x:(R2+5)
		beq     NoCBonCompare
		bfset   #0x4000,Y0
NoCBonCompare:

;     ;
;     periphMemWrite( tmp, &pBase->StatusControlReg );

		move    Y0,x:(R3+7)

;     tmp = 0
;          | QTB_OUTPUTMODE( pState->OutputMode )

		move    A1,Y0
		andc    #0x0007,Y0
		
;          | ( pState->CoChannelInitialize == 1      ? QTB_EXTINIT : 0 )

		brclr   #0x0080,A1,SkipInit
		bfset   #0x0008,Y0
SkipInit:

;          | ( pState->CountDirection == qtDown      ? QTB_DIR : 0 )

		bftstl  #0x2000,A0
		bcs     DirectionUp
		bfset   #0x0010,Y0
DirectionUp:

;          | ( pState->CountLength == qtUntilCompare ? QTB_LENGTH : 0 )

		bftstl  #0x1000,A0
		bcs     PastCompare
		bfset   #0x0020,Y0
PastCompare:

;          | ( pState->CountFrequency == qtOnce      ? QTB_ONCE : 0 )

		bftstl  #0x0800,A0
		bcs     Repeatedly
		bfset   #0x0040,Y0
Repeatedly:

;          | QTB_SECONDARYSOURCE( pState->SecondaryInputSource )

		move    A0,X0
		andc    #0x0600,X0
		asr     X0
		asr     X0
		or      X0,Y0
		 
;          | QTB_PRIMARYSOURCE( pState->InputSource )

		move    A0,B1
		andc    #0x00f0,B1
		move    #5,Y1
		asll    B1,Y1,Y1
		or      Y1,Y0
		
;     tmp &= qtExtAMask[pState->Mode];

		andc    #0x000F,A0
		move    A0,N
		move    #qtExtAMask,R0
		nop
		move    x:(R0+N),X0
		and     X0,Y0
		
;     tmp |= qtExtAMode[pState->Mode];

		move    #qtExtAMode,R0
		nop
		move    x:(R0+N),X0
		or      X0,Y0

; 	memWriteP16 ((UWord16)pState->CallbackOnOverflow.pCallback,     (Word16 *)&(callback->CallbackOnOverflow.pCallback));

		move    x:(R2+7),X0
		move    X0,P:(R1)+
		    
; 	memWriteP16 ((UWord16)pState->CallbackOnOverflow.pCallbackArg,  (Word16 *)&(callback->CallbackOnOverflow.pCallbackArg));

		move    x:(R2+8),X0
		move    X0,P:(R1)+
		    
; 	memWriteP16 ((UWord16)pState->CallbackOnInputEdge.pCallback,    (Word16 *)&(callback->CallbackOnInputEdge.pCallback));

		move    x:(R2+9),X0
		move    X0,P:(R1)+
		    
; 	memWriteP16 ((UWord16)pState->CallbackOnInputEdge.pCallbackArg, (Word16 *)&(callback->CallbackOnInputEdge.pCallbackArg));

		move    x:(R2+10),X0
		move    X0,P:(R1)+
		    
; 	memWriteP16 ((UWord16)pState->CallbackOnCompare.pCallback,      (Word16 *)&(callback->CallbackOnCompare.pCallback));

		move    x:(R2+5),X0
		move    X0,P:(R1)+

; 	memWriteP16 ((UWord16)pState->CallbackOnCompare.pCallbackArg,   (Word16 *)&(callback->CallbackOnCompare.pCallbackArg));

		move    x:(R2+6),X0
		move    X0,P:(R1)+
		    
; 	periphMemWrite( tmp, &pBase->ControlReg );

		move    Y0,x:(R3+6)
		
		rts
}
#endif


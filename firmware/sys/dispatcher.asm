		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FastDispatcher
		GLOBAL  DispatchRestore
		XREF    FarchUserISRTable
		


 define IPR                       'x:$FFFB'
 
				
 ; Define SUPPORT_NESTED_INTERRUPTS to 1 or 0, 
 ; in order to support nested interrupts or not
 
 define SUPPORT_NESTED_INTERRUPTS '1' 

 
 ;
 ; Define ASSEMBLE_FAST_VERSION to 1 for the version of the Dispatcher
 ; which is faster, but may take more program space.  Set it to 0 for
 ; a version which is slower, but may take less program space if the
 ; application uses the following routines.  
 ;           
 ;     archPushAllRegisters 
 ;     archPopAllRegisters 
 ;     archPushFastInterruptRegisters 
 ;     archPopFastInterruptRegisters 
 ;     archEnterNestedInterrupt
 ;     archExitNestedInterrupt
 ;     archEnterNestedInterruptCommon 
 ;     archExitNestedInterruptCommon  
 ;
 
 define ASSEMBLE_FAST_VERSION '1'
 
 				
		ORG	P:				 

  if ASSEMBLE_FAST_VERSION==1
 
  ; 
  ; This version implements context switching as inline code.
  ; This code should be logically equivalent to the version below
  ; which uses function calls, but this version is faster.  
  ; Use this version when program space is available and you desire
  ; faster interrupt handling.
  ;
  
FastDispatcher:
		bcc   Dispatcher
		move  x0,x:(SP)+
		move  y0,x:(SP)+
		move  r2,x:(SP)+

  if SUPPORT_NESTED_INTERRUPTS==1
 		
		;
		; enable nested interrupts
		;
		move  #FconfigNestedIPRmask,R2
		move  IPR,X0
		move  X0,X:(SP)+
		tstw  X:(R2)         ; configNestedIPRmask[0] dynamically enables nesting
		beq   KeepFastDisabled
		move  X:(R2+N),Y0
		and   Y0,X0
		move  X0,IPR

		; 
		; re-enable interrupts if controlled by ITCN
		;
		move  N,X0
		cmp   #10,X0         ; all int #s less than 10 are core ints
		blt   KeepFastDisabled
		bfclr #$0200,SR      ; Reenable interrupts
KeepFastDisabled:

  endif
  			
		move  a0,x:(SP)+
		move  a1,x:(SP)+
		move  a2,x:(SP)+
		move  b0,x:(SP)+
		move  b1,x:(SP)+
		move  b2,x:(SP)+
		move  y1,x:(SP)+
		move  r0,x:(SP)+
		move  r1,x:(SP)+
		move  r3,x:(SP)+

		move  la,x:(SP)+
		move  lc,x:(SP)+
		
		; Call the User ISR dynamically
		move  #FastDispatchRestore,y1
		move  #FarchUserISRTable,R2
		move  y1,x:(sp)+
		move  sr,X:(sp)+
		
		lea   (R2)+N        ; Load User ISR address from P Ram
		move  P:(R2)+,R3
		move  R3,X:(sp)+
		
		move  sr,X:(sp)
		rts                 ; Call User ISR

FastDispatchRestore:
	
		; restore all saved registers
		pop lc
		pop la

		pop r3
		pop r1
		pop r0
		pop y1
		pop b2
		pop b1
		pop b0
		pop a2
		pop a1
		pop a0


  if SUPPORT_NESTED_INTERRUPTS==1
 
  		bfset #$0200,SR		;disable interrupts		
		pop x0
		move x0,IPR

  endif
  
		pop r2
		pop y0
		pop x0

		pop n
		
		rti

		
Dispatcher:
		move  x0,x:(SP)+
		move  y0,x:(SP)+
		move  r2,x:(SP)+

  if SUPPORT_NESTED_INTERRUPTS==1
 		
		;
		; enable nested interrupts
		;
		move  #FconfigNestedIPRmask,R2
		move  IPR,X0
		move  X0,X:(SP)+
		tstw  X:(R2)         ; configNestedIPRmask[0] dynamically enables nesting
		beq   KeepDisabled
		move  X:(R2+N),Y0
		and   Y0,X0
		move  X0,IPR
		; 
		; re-enable interrupts if controlled by ITCN
		;
		move  N,X0
		cmp   #10,X0         ; all int #s less than 10 are core ints
		blt   KeepDisabled
		bfclr #$0200,SR      ; Reenable interrupts
KeepDisabled:

  endif
  			
		move  a0,x:(SP)+
		move  a1,x:(SP)+
		move  a2,x:(SP)+
		move  b0,x:(SP)+
		move  b1,x:(SP)+
		move  b2,x:(SP)+
		move  y1,x:(SP)+
		move  r0,x:(SP)+
		move  r1,x:(SP)+
		move  r3,x:(SP)+

		move  omr,x:(SP)+
		move  la,x:(SP)+
		move  m01,x:(SP)+
		move  lc,x:(SP)+

		; save hardware stack
		move  hws,x:(SP)+
		move  hws,x:(SP)+
	
		; Save temporary register file at 0x30 - 0x37 used by compiler
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

		; set consistent state for critical registers
		move  #$FFFF,y1     ; linear addressing
		move  y1,m01
		
		bfclr #$0030,OMR    ; convergent rounding, no saturation mode
		bfset #$0100,OMR    ; Set CC for 32-bit compares
	
		; Call the User ISR dynamically
		move  #DispatchRestore,y1
		move  #FarchUserISRTable,R2
		move  y1,x:(sp)+
		move  sr,X:(sp)+
		
		lea   (R2)+N        ; Load User ISR address from P Ram
		move  P:(R2)+,R3
		move  R3,X:(sp)+
		
		move  sr,X:(sp)
		rts                 ; Call User ISR

DispatchRestore:

		pop  y1
		move y1,x:<$37
		pop  y1
		move y1,x:<$36
		pop  y1
		move y1,x:<$35
		pop  y1
		move y1,x:<$34
		pop  y1
		move y1,x:<$33
		pop  y1
		move y1,x:<$32
		pop  y1
		move y1,x:<$31
		pop  y1
		move y1,x:<$30

		; restore hardware stack
		move  hws,la    ; clear HWS to ensure reload
		move  hws,la
		pop   HWS
		pop   HWS
		
		; restore all saved registers
		pop lc
		pop m01
		pop la
		pop omr

		pop r3
		pop r1
		pop r0
		pop y1
		pop b2
		pop b1
		pop b0
		pop a2
		pop a1
		pop a0

  if SUPPORT_NESTED_INTERRUPTS==1

 		bfset #$0200,SR		;disable interrupts
		pop x0
		move x0,IPR

  endif
  		
		pop r2
		pop y0
		pop x0

		pop n
		
		rti			; restore SR from stack

  else
  
  ; 
  ; This version uses the user interface routines called with a jsr.
  ; This code should be logically equivalent to the above version,
  ; but is slower.  Use this version to test the user interface
  ; routines, or to save program space if the user application
  ; uses the referenced interface routines. 
  ;
  		XREF    FarchEnterNestedInterruptCommon
		XREF    FarchExitNestedInterruptCommon
		XREF    FarchPushAllRegisters
		XREF    FarchPopAllRegisters
		XREF    FarchPushFastInterruptRegisters
		XREF    FarchPopFastInterruptRegisters

FastDispatcher:
		;
		; Upon entry (see Interruptnn.asm files):
		;
		;     N      =>  Contains interrupt number
		;     Carry  =>  0 means Normal ISR, 1 means Fast ISR
		;
		bcc   Dispatcher     ; Q: Is this a Fast or Normal ISR?
		
		;
		; Fast ISR
		;
		
  if SUPPORT_NESTED_INTERRUPTS==1
  
		jsr   FarchEnterNestedInterruptCommon

  endif
  
  		jsr   FarchPushFastInterruptRegisters	
		
		;
		; Call the User ISR dynamically
		;
		jsr   SimulateJsrToISR

		jsr   FarchPopFastInterruptRegisters
		
  if SUPPORT_NESTED_INTERRUPTS==1
  
		jsr   FarchExitNestedInterruptCommon

  endif
  
		pop   n            ; From Interruptnn routine
		pop   n
		
		rti                ; return from interrupt

		
Dispatcher:
		
  if SUPPORT_NESTED_INTERRUPTS==1
  
		jsr   FarchEnterNestedInterruptCommon
  
  endif
  
		jsr   FarchPushAllRegisters
	
		; set consistent state for critical registers
		move  #$FFFF,y1     ; linear addressing
		move  y1,m01
		
		bfclr #$0030,OMR    ; convergent rounding, no saturation mode
		bfset #$0100,OMR    ; Set CC for 32-bit compares
				
		;
		; Call the User ISR dynamically
		;
		jsr   SimulateJsrToISR

		jsr   FarchPopAllRegisters
		
  if SUPPORT_NESTED_INTERRUPTS==1
  
		jsr   FarchExitNestedInterruptCommon
		
  endif
		
		pop   n             ; From Interruptnn routine
		pop   n
		
		rti			        ; return from interrupt

SimulateJsrToISR:
		move  #FarchUserISRTable,R2
		lea   (SP)+         ; Simulate JSR to ISR
		
		lea   (R2)+N        ; Load User ISR address from P Ram
		move  P:(R2)+,R3
		move  R3,X:(sp)+
		
		move  SR,X:(SP)     ; Save SR
		rts                 ; JSR to ISR

  endif
   
		ENDSEC
		END


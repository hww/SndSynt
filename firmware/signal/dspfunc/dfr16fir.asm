	SECTION rtlib
	
	include "portasm.h"
	
	GLOBAL  Fdfr16FIR
	
; 
; The following symbols can be used to exclude portions (using '0') of 
; the FIR implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to FIR will satisfy the
; constraints placed upon the limited implementation.
;
	define  FIR_USE_DUAL_MAC_OPT   '1' 
	define  FIR_USE_MODULO_OPT     '1'
	define  FIR_USE_NO_OPT         '1'
;
; Define tFirStruct offsets
;	
Offset_pC                equ 0           
Offset_pHistory          equ 1      
Offset_n                 equ 2           
Offset_pNextHistoryAddr  equ 3 
Offset_bCanUseModAddr    equ 4  
Offset_bCanUseDualMAC    equ 5
	    
;asm void dfr16FIR (   tFirStruct * pFIR, 
;                      Frac16     * pX, 
;                      Frac16     * pZ, 
;                      UInt16       n)
;{
; See C implementation in dfr16.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pFIR
;		R3    - pX
;		Y0    - n
;		SP-2  - pZ
;
;	Register utilization during execution:
;     R0    - pMem
;     R1    - pX
;     R2    - pFIR
;     R3    - pCoefs
;     Y0    - n
;     X0,Y1 - temp regs for MAC
;     A     - total32
;     B1    - pFir->n
;     SP-2  - pZ
;     DMR0  - modulo count in Case 3

Fdfr16FIR:

	move x:(R2+Offset_pNextHistoryAddr),R0   ; Set R0 to pMem
	cmp  #0,Y0                               ; Ensure n > 0
	ble  ExitFIR

	move R3,R1                               ; move pX to R1
	move x:(R2+Offset_n),B                   ; Set B1 to pFir->n

 if FIR_USE_DUAL_MAC_OPT==1
 
	move x:(R2+Offset_bCanUseDualMAC),X0     ; Q: Dual MAC be used?
	tstw X0
	beq  TryJustModulo
;
;  Case 1: Dual MAC code
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01
	do   Y0,endloop                          ; for loop (n times)
	move X:(R2+Offset_pC),R3                 ; Set pCoefs
	move X:(R1)+,A0                          ; Move input value to history buf
	move A0,X:(R0)+
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1   X:(R3)+,X0             ; Pre-load mac registers
	rep  B1                                  ; Rep MAC pFir->n-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   X:(R3)+,X0
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R3                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R3)
	
endloop:
	bra  ExitFIR
	
  endif
  
TryJustModulo:

  if FIR_USE_MODULO_OPT==1

	move x:(R2+Offset_bCanUseModAddr),X0      ; Q: Can modulo addressing be used?
	tstw X0
	beq  TheHardWay
;
;  Case 2: Use modulo addressing for partial optimization
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01
TryModLoop:
	move X:(R2+Offset_pC),R3                 ; Set pCoefs
	move X:(R1)+,A0                          ; Move input value to history buf
	move A0,X:(R0)+
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1   X:(R3)+,X0             ; Pre-load mac registers
	do   B1,EndModDo                         ; Rep MAC pFir->n-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   
	move X:(R3)+,X0
EndModDo:
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R3                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R3)
	
   decw Y0
   bgt  TryModLoop

   bra  ExitFIR
  else
   bra  TheHardWay
  endif
		
ExitFIR:
	move R0,X:(R2+Offset_pNextHistoryAddr)   ; Preserve history buf pointer

	move #-1,M01                             ; Restore M01 reg due to CW bug
	rts 
	

;
;  Case 3: Cannot use modulo addressing or dual-parallel MAC
;
TheHardWay:
  if FIR_USE_NO_OPT==1
  
	move #-1,M01                             ; Set M01 for linear addressing
HardWayLoop:
	move B1,A                                ; Calculate length before buffer wrap
	move X:(R2+Offset_pHistory),X0
	add  X0,A
	move R0,X0
	sub  X0,A
	move A,DMR0

	move X:(R2+Offset_pC),R3                 ; Set pCoefs
	move X:(R1)+,A0                          ; Move input value to history buf
	move A0,X:(R0)+
	decw DMR0                                ; Q: wrapped
	bgt  HardWay1
	move B,DMR0
	move X:(R2+Offset_pHistory),R0
HardWay1:
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1                          ; Pre-load mac registers
	decw DMR0                              ; Q: wrapped
	bgt  HardWay2
	move B,DMR0
	move X:(R2+Offset_pHistory),R0
HardWay2:
	move X:(R3)+,X0
	decw B                                   ; Subtract one from pFir->n
	do   B1,EndHardDo                        ; Rep MAC pFir->n-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   
	decw DMR0                              ; Q: wrapped
	bgt  HardWay3
	move B,DMR0
	move X:(R2+Offset_pHistory),R0
HardWay3:
	move X:(R3)+,X0
	nop
	nop
EndHardDo:
	incw B                                   ; restore B to pFir->n
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R3                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R3)
	
    decw Y0
    bgt  HardWayLoop
    
  endif
  
  	bra ExitFIR

	ENDSEC

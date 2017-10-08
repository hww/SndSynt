	SECTION rtlib
	
	include "portasm.h"
	
	GLOBAL  Fdfr16FIRInt
	
; 
; The following symbols can be used to exclude portions (using '0') of 
; the FIR implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to FIR will satisfy the
; constraints placed upon the limited implementation.
;
	define  FIRINT_USE_DUAL_MAC_OPT   '1' 
	define  FIRINT_USE_MODULO_OPT     '1'
	define  FIRINT_USE_NO_OPT         '1'
;
; Define dfr16_tFirIntStruct offsets
;	
Offset_pC                equ 0           
Offset_pHistory          equ 1      
Offset_n                 equ 2           
Offset_pNextHistoryAddr  equ 3 
Offset_bCanUseModAddr    equ 4  
Offset_bCanUseDualMAC    equ 5
Offset_Factor            equ 6
Offset_Count             equ 7
	    
;asm UInt16 dfr16FIRInt (dfr16_tFirIntStruct *pFIRINT, 
;                        Frac16              *pX, 
;                        Frac16              *pZ, 
;                        UInt16               n);
;{
; See C implementation in dfr16.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pFIRINT
;		R3    - pX
;		Y0    - n
;		SP-2  - pZ
;
; Register utilization upon entry:
;		Y0    - (n * pFirInt->Factor) = Number of outputs
;
;	Register utilization during execution:
;     R0      - pMem
;     R1      - pX
;     R2      - pFIR
;     R3      - pCoefs
;     Y0,DMR2 - n
;     X0,Y1   - temp regs for MAC
;     A       - total32
;     B1      - pFirInt->Count
;     N       - pFirInt->Factor
;     SP-2    - pZ
;     DMR0    - modulo count in Case 3
;     DMR1    - pX temporary
;     DMR2    - N
;

Fdfr16FIRInt:

	move Y0,DMR2                             ; Save n in DMR2
	move x:(R2+Offset_pNextHistoryAddr),R0   ; Set R0 to pMem
	cmp  #0,Y0                               ; Ensure n > 0
	ble  ExitFIRInt

	move R3,DMR1                             ; move pX to R1
	move R3,R1                               ; save pX in DMR1
	move x:(R2+Offset_Count),B               ; Set B1 to pFirInt->Count

 if FIRINT_USE_DUAL_MAC_OPT==1
 
	move x:(R2+Offset_bCanUseDualMAC),X0     ; Q: Dual MAC be used?
	tstw X0
	beq  TryJustModulo
;
;  Case 1: Dual MAC code
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01
startdo1:                                    ; for loop (n times)
	move X:(R1)+,A0                          ; Move input value to history buf
	move R1,DMR1                             ; save pX
	move A0,X:(R0)+
	move X:(R2+Offset_pC),R3                 ; pCoefs = pFIRINT->pC
	move X:(R2+Offset_Factor),X0
	do   X0,endloop
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1   X:(R3)+,X0             ; Pre-load mac registers
	rep  B1                                  ; Rep MAC pFirInt->Count-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   X:(R3)+,X0
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R1                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R1)
endloop:

	move DMR1,R1                             ; reload pCoefs value
	decw Y0                                  ; end for loop
	bgt  startdo1
	bra  ExitFIRInt
	
  endif
  
TryJustModulo:

  if FIRINT_USE_MODULO_OPT==1

	move x:(R2+Offset_bCanUseModAddr),X0      ; Q: Can modulo addressing be used?
	tstw X0
	beq  TheHardWay
;
;  Case 2: Use modulo addressing for partial optimization
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01
TryModLoop:
	move X:(R1)+,A0                          ; Move input value to history buf
	move R1,DMR1                             ; save pX
	move A0,X:(R0)+
	move X:(R2+Offset_pC),R3                 ; pCoefs = pFIRINT->pC
	move X:(R2+Offset_Factor),X0
	move X0,DMR3                             ; do X0,endloop2
startdo2:
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1   X:(R3)+,X0             ; Pre-load mac registers
	do   B1,EndModDo                         ; Rep MAC pFirInt->Count-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   
	move X:(R3)+,X0
EndModDo:
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R1                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R1)
endloop2:
	decw DMR3                                ; end factor loop 
	move DMR3,X0
	bgt  startdo2                            ; No, so go do another iteration
	
	move DMR1,R1                             ; restore pX
	decw Y0                                  ; n -= 1
	bgt  TryModLoop

;	bra  ExitFIRInt                          ; Fall thru
  else
	bra  TheHardWay
  endif
		
ExitFIRInt:
	move R0,X:(R2+Offset_pNextHistoryAddr)   ; Preserve history buf pointer

	move X:(R2+Offset_Factor),X0             ; return n*factor
	move DMR2,Y0
	impy X0,Y0,A
	move A1,Y0
	
	move #-1,M01                             ; Restore M01 reg due to CW bug
	rts 
	

;
;  Case 3: Cannot use modulo addressing or dual-parallel MAC
;
TheHardWay:
  if FIRINT_USE_NO_OPT==1
  
	move #-1,M01                             ; Set M01 for linear addressing
HardWayLoop:
	move B1,A                                ; Calculate length before buffer wrap
	move X:(R2+Offset_pHistory),X0
	add  X0,A
	move R0,X0
	sub  X0,A
	move A,DMR0

	move X:(R1)+,A0                          ; Move input value to history buf
	move R1,DMR1                             ; save pX
	move A0,X:(R0)+
	decw DMR0                                ; Q: wrapped
	bgt  HardWay1
	move B,DMR0
	move X:(R2+Offset_pHistory),R0
HardWay1:
	move X:(R2+Offset_pC),R3                 ; pCoefs = pFIRINT->pC
	move X:(R2+Offset_Factor),X0
	move X0,DMR3                             ; do X0,endloop3
startdo3:
	clr  A                                   ; total32 = 0
	move X:(R0)+,Y1                          ; Pre-load mac registers
	decw DMR0                                ; Q: wrapped
	bgt  HardWay2
	move B,DMR0
	move X:(R2+Offset_pHistory),R0
HardWay2:
	move X:(R3)+,X0
	decw B                                   ; Subtract one from pFirInt->Count
	do   B1,EndHardDo                        ; Rep MAC pFirInt->Count-1 times
	mac  Y1,X0,A   X:(R0)+,Y1   
	decw DMR0                                ; Q: wrapped
	bgt  HardWay3
	move B,DMR0                              ; restore Count of coefficients
	incw DMR0                                ; add 1 to restore pFirInt->Count
	move X:(R2+Offset_pHistory),R0
HardWay3:
	move X:(R3)+,X0
	nop
	nop
EndHardDo:
	incw B                                   ; restore B to pFirInt->Count
	mac  Y1,X0,A                             ; Last MAC to get addresses right
	rnd  A                                   ; round(A)
	move X:(SP-2),R1                         ; *pZ++ = round(A)
	incw X:(SP-2)
	move A,X:(R1)
	
endloop3:
	decw DMR3                                ; end factor loop 
	move DMR3,X0
	bgt  startdo3                            ; No, so go do another iteration
	
	move DMR1,R1                             ; restore pX

    decw Y0                                  ; n -= 1
    bgt  HardWayLoop
    
  endif
  
  	bra ExitFIRInt

	ENDSEC

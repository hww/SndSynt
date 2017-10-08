
;=========================================================================
; Revision History:
;
; VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
; -------    ----------    -----------      -----      --------
;   0.1      Meera S. P.        -          02-03-2000  Reviewed.
;=========================================================================

;=========================================================================
;asm Result dfr16IIR ( tIirStruct * pIIR, 
;                      Frac16     * pX, 
;                      Frac16     * pZ, 
;                      UInt16       n)
;{
; See C implementation in dfr16.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pIIR
;		R3    - pX
;		Y0    - n
;		SP-2  - pZ
;
;	Register utilization during execution:
;     R0    - Pointer to filter states
;     R1    - Pointer to input buffer
;     R2    - Pointer to pIIR
;		R3    - Pointer to filter coefficients
;		Y0    - Length of input buffer
;     X0,Y1 - temp registers for intermediate calculations
;		A     - Acc
;     B1    - pIIR -> nbiq
;		SP-2  - pZ
;=========================================================================

	SECTION rtlib
	
	include "portasm.h" 
	
	GLOBAL  Fdfr16IIR
;
; Define tFirStruct offsets
;	
Offset_nbiq              equ 0           
Offset_pC                equ 1           
Offset_pHistory          equ 2      
Offset_pNextHistoryAddr  equ 3 
Offset_bCanUseModAddr    equ 4  
Offset_bCanUseDualMAC    equ 5

  DEFINE pZ 'X:(SP-1)'	    
  DEFINE temp_OMR 'X:(SP-2)'
  DEFINE lp_cnt 'X:(SP-3)'

Fdfr16IIR:
	cmp  #PORT_MAX_VECTOR_LEN,Y0                 ; Q: n <= 8191?
	bls  LengthOK
IIR_Fail:	
	move #FAIL,Y0                           ; n > 8191 so return FAIL
	rts
	
LengthOK:
	cmp  #0,Y0                              ; Ensure n > 0
	ble  IIR_Fail                           ; Return FAIL, if length is negative
   move X:(SP-2),B1                        ; B1 = pointer to output buffer
   move #10,N                              ; Allocate a scratch buffer of size 10
   lea  (SP)+N
   move  OMR,temp_OMR                      ; store the status of OMR
   bfclr #$10,OMR                          ; set saturation mode off
   move B1,pZ                              ; pZ = pointer to output buffer
   move X:(R2+Offset_nbiq),B               ; set B1 to pIIR->nbiq
   asl  B                                  ; B = nbiq * 2
   move R3,R1                              ; R1 = *pX (pointer to the input buffer)
	move X:(R2+Offset_pHistory),R0          ; R0 = *pHistory (pointer to the filter states buffer)
	tstw X:(R2+Offset_bCanUseDualMAC)       ; Q: Can dual parallel moves be used?
	beq  TryJustModulo
;
;  Case 1: Dual MAC code
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01                              ; M01 = (nbiq*2 -1)
    move Y0,lp_cnt                           ; Loop count for outer loop 
                                             ; (for no. of inputs samples)
_endl1
	move X:(R2+Offset_pC),R3                 ; R3 - points to filter coeff. buffer
	move X:(R2+Offset_pHistory),R0           ; R0 = pointer to the filter states buffer
	move X:(R2+Offset_nbiq),N                ; N = No. of biquads
	move x:(R1)+,A                           ; A = input sample
	move X:(R0)+,Y1 X:(R3)+,X0               ; Y0 = filter coeff(a1) and Y1 = filter state(w1)
;=====================================================================================
; Here  the power of modulo is not utilized; however we are saving some cycles by 
; re-initializing the States pointer and fetching the first state in parallel with 
; first coefficient. By doing this we can avoid following four statements, which will
; require more cycles than re-initializing states pointer.
;=====================================================================================

;	move X:(SP),B1                           ; store loop count in B1
;	cmp  B1,Y0                               ; compare current loop count with total loop count
;	bne  _start_loop                         ; for first loop fetch history data, then modulo will take care of it
;  move X:(R0)+,Y1

_start_loop:   
	do   N,_endl2                            ; for loop no. of biquad times
	move Y1,N                                ; N = w1
	mac  X0,Y1,A    X:(R0)+,Y1 X:(R3)+,X0    ; Y1 = w2 X0 = coef(a2)
	macr X0,Y1,A    X:(R3)+,Y0               ; a2 * w2 and  Y0 = coef(b0)
	move A,A                                 ; A1 = w0
	move A,X:(R0-2)                          ; move w0 to nextHistoryAdd
   move N,X:(R0-1)                          ; move w1 to nextHistoryAdd
   mpy  A1,Y0,A    X:(R3)+,Y0               ; b0 * w0 and Y0 = coef(b1)
   move N,X0                                ; X0 = w1
   mac  Y0,X0,A    X:(R3)+,Y0               ; b1 * w1 and Y0 = coef(b2)
   macr Y1,Y0,A    X:(R0)+,Y1 X:(R3)+,X0    ; b2 * w2 + A, Y1 = w1 X0 = coef(a1)
_endl2
   move pZ,R3                               ; R3 = pZ
   nop 
   move A,X:(R3)+                           ; move output to *pZ
   move R3,X:(SP-1)                         ; X:(SP-1) = *pZ++
   decw lp_cnt
   bne  _endl1                              ; End of outer loop.

ExitIIR:
   move temp_OMR,OMR                        ; restore OMR
	move #-1,M01                             ; Restore M01 reg 
	move #PASS,Y0                            ; return PASS
   move #-10,N                              ; Restore SP
   lea  (SP)+N
	rts

TryJustModulo:
	tstw x:(R2+Offset_bCanUseModAddr)        ; Q: Can modulo addressing be used?
	beq  TheHardWay
;
;  Case 2: Use modulo addressing for partial optimization
;
	decw B                                   ; Set M01 for modulo addr
	move B1,M01
   move Y0,B1
TryModLoop:
	move X:(R2+Offset_pC),R3                 ; R3 - points to filter coeff. buffer
	move X:(R2+Offset_nbiq),N                ; N = No. of biquads
	move x:(R1)+,A                           ; A = input sample
;	move Y0,nZ                               ; nZ = length of output vector
	move X:(R3)+,X0                          ; move coef to x0
	do   N,_endModDo
	move X:(R0)+,Y1                          ;  move w1 to y1              
	move Y1,N                                ; N = w1
	mac  X0,Y1,A    X:(R3)+,Y1               ; a1 * w1 and Y1 = coef(a2)
	move X:(R0)-,X0                          ; X0 = w2
	macr X0,Y1,A   X:(R3)+,Y0                ; a2 * w2 and Y0 = coef(b0)
	move A,A                                 ; saturate A
	move A1,X:(R0)+                          ; move w0 to nextHistoryAdd
   move N,X:(R0)+                           ; move w1 to nextHistoryAdd
   mpy  A1,Y0,A    X:(R3)+,Y0               ; b0 * w0 and Y0 = coef(b1)
   move N,Y1                                ; Y1 = w1
   mac  Y0,Y1,A    X:(R3)+,Y0               ; b1 * w1 and Y0 = coef(b2)
   macr X0,Y0,A    X:(R3)+,X0               ; move coef to x0
_endModDo
   move pZ,R3                               ; pZ = pointer to output vector
   nop 
   move A,X:(R3)+                           ; *pZ = output value
   move R3,X:(SP-1)                         ; X:(SP-1) = *pZ++

   decw B                                    ;
   bgt  TryModLoop                          ; check for end of loop
	
	bra ExitIIR
	
;
;  Case 3: Cannot use modulo addressing or dual-parallel MAC
;
TheHardWay:
	move #-1,M01                             ; Set M01 for linear addressing
   move Y0,B1                               ; No. of input samples
HardWayLoop:
	move X:(R2+Offset_pC),R3                 ; R3 = points to filter coeff. buffer
	move X:(R2+Offset_pHistory),R0           ; R0 = pointer to filter state buffer
	move X:(R2+Offset_nbiq),X0               ; X0 = No. of biquads
	move x:(R1)+,A                           ; A  = input sample
	move X:(R0)+,Y1                          ; Y1 = filter state(w1)
	do   X0,_endHardDo
	move X:(R3)+,X0                          ; X0 = filter coef(a1)  
	move Y1,N                                ; N = w1
	mac  X0,Y1,A    X:(R3)+,Y1               ; a1 * w1 and Y1 = filter coef(a2)
	move X:(R0)-,X0                          ; X0 = filter state(w2)
	macr X0,Y1,A    X:(R3)+,Y0               ; a2 * w2 and Y0 = filter coef(b0)
	move A,A
	move A1,X:(R0)+                          ; move w0 to nextHistoryAdd
   move N,X:(R0)+                           ; move w1 to nextHistoryAdd
   mpy  A1,Y0,A    X:(R3)+,Y0               ; b0 * w0 and Y0 = filter coef(b1)
   move N,Y1                                ; Y1 = filter state(w1)
   mac  Y0,Y1,A    X:(R3)+,Y0               ; b1 * w1 and Y0 = filter coef(b2)
   macr  X0,Y0,A    X:(R0)+,Y1              ; b2 * w2 and Y1 = filter coef(w1)
_endHardDo
   move X:(SP-1),R3                         ; R3 = pointer to output vecotr
   nop
   move A,X:(R3)+                           ; *pZ = output
   move R3,X:(SP-1)                         ; store *pZ++ to X:(SP-1)
   
   decw B                                   ; (No. of input sample)--
   bgt  HardWayLoop                         ; check for end of loop
	
	jmp ExitIIR
	
	ENDSEC

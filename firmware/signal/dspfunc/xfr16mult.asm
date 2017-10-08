	SECTION rtlib
	
	include "portasm.h"

	GLOBAL  Fxfr16Mult

;
; The implementation of this matrix multiply takes into consideration
; whether the first vector X has been allocated in internal memory.
;
; If X is in internal memory, then the implementation executes code to
; do a rep instruction with a dual-parallel move mac instruction.
;  
; However, if X is in external memory, the implementation uses 
; either an unrolled loop of in-line mac instructions for vector 
; lengths less than or equal to 16, or else a do loop for vector lengths
; greater than 16.  
;

;asm void xfr16Mult (Frac16 *pX, int xrows, int xcols, 
;							Frac16 *pY, int ycols, 
;							Frac16 *pZ)
;{
; Register utilization upon entry:

;		R2    - pX
;		R3    - pY
;		Y0    - xrows
;		Y1    - xcols
;		SP-2  - ycols
;		SP-3  - pZ
;
;	Register utilization during execution:
;     R1    - pYelem
;		R2    - pZ
;		R3    - pXelem
;		Y0    - xrows
;     Y1,X0 - temps for MAC
;		SP-2  - ycols
;		N     - ycols
;		B     - temp
;		DMR2  - jump table address
;		DMR3  - j
;		DMR4  - xcols
;		DMR5  - pX[row]
;		DMR6  - pY
;		DMR7  - i
;
;
;
Fxfr16Mult:
				;
				; Initialization
				;
				move    #$FFFF,M01       ; linear addressing
				move    R2,DMR5        ; pX
				move    Y1,DMR4        ; xcols
				move    R3,DMR6        ; pY
				move    X:(SP-2),N       ; ycols
				;
				; determine most efficient algorithm
				;
				move    Y0,X0            ; save xrows temporarily
				; R2 contains pX         ; Q: Using internal memory?
				jsr     FmemIsIM         ; call memIsIM
				; Y0 now contains the boolean result from memIsIM
				move    X:(SP-3),R2      ; pZ
				tstw    Y0
				move    X0,Y0            ; restore xrows
				beq     UsingExtMem
				;
				; Case 1: Using internal memory so can use rep instruction
				;
C1StartLpI:
				moves   #0,DMR7        ; i
				;jmp     C1EndLpI        ; check eliminated for efficiency
				;
				; for (j=0; j<xrows; j++) 
				;
C1LoopI:
				moves   #0,DMR3        ; j
				;bra     C1EndLpJ        ; check elminated for efficiency
C1LoopJ:
				;
				; pXelem = pX
				; pYelem = pY + j
				; temp   = 0
				; // preload *pXelem & *pYelem for L_mac  
				;
				
				moves   X:(SP-2),X0      ; ycols
				do      X0,C1EndLpJ
				moves   DMR5,R3          ; pXelem = pX
				moves   DMR3,X0          ; j
				add     DMR6,X0          ; pY + j
				move    X0,R1            ; pYelem = pY + j
				clr     B  X:(R3)+,X0    ; temp = 0, pXelem (X0)
				move    X:(R1)+N,Y1      ; pYelem (Y1)
				;
				; REP implementation (when X matrix is in internal memory)
				; 
				move    DMR4,A1
				rep     A1
				mac     Y1,X0,B  X:(R1)+N,Y1  X:(R3)+,X0
				;
				; Now round mac results and store in *pZ
				; 
				rnd     B                ; round(temp)
				move    B,X:(R2)+        ; pZ = round(temp)
				;
				; end of loop j
				; 
				inc     DMR3             ; j++
C1EndLpJ:
				;
				; pX += xcols
				; 
				moves   DMR4,X0          ; xcols
				add     DMR5,X0          ; pX[row]
				move    X0,DMR5          ; pX[row+1]
				; 
				; end of loop i
				; 
				inc     DMR7             ; i++
C1EndLpI:
				moves   DMR7,X0          ; i
				cmp     Y0,X0            ; i < xrows
				blt     C1LoopI          ; loop if i < xrows
				rts                      ; return from Case 1


				;
				; Using external memory so must use DO loop
				; or unrolled loop
				;
UsingExtMem:
				cmp     #16,Y1           ; xcols in unrolled loop range?
				ble     UseUnrolled         
				;
				; Case 2: Use DO loop 
				;
C2StartLpI:
				moves   #0,DMR7          ; i
				;jmp     C2EndLpI        ; check eliminated for efficiency
				;
				; for (j=0; j<xrows; j++) 
				;
C2LoopI:
				moves   #0,DMR3          ; j
				;bra     C2EndLpJ        ; check elminated for efficiency
C2LoopJ:
				;
				; pXelem = pX
				; pYelem = pY + j
				; temp   = 0
				; // preload *pXelem & *pYelem for L_mac  
				;
				moves   DMR5,R3          ; pXelem = pX
				moves   DMR3,X0          ; j
				add     DMR6,X0          ; pY + j
				move    X0,R1            ; pYelem = pY + j
				clr     B  X:(R3)+,X0    ; temp = 0, pXelem (X0)
				move    X:(R1)+N,Y1      ; pYelem (Y1)
				;
				; DO loop implementation (for xcols > 16)
				; 
UseDo:
				move    DMR4,LC
				do      LC,EndDo
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
EndDo:
				;
				; Now round mac results and store in *pZ
				; 
				rnd     B                ; round(temp)
				move    B,X:(R2)+        ; pZ = round(temp)
				;
				; end of loop j
				; 
				inc     DMR3             ; j++
C2EndLpJ:
				moves   DMR3,X0          ; j
				cmp     X:(SP-2),X0      ; j < ycols
				blt     C2LoopJ          ; loop if j < ycols
				;
				; pX += xcols
				; 
				moves   DMR4,X0          ; xcols
				add     DMR5,X0          ; pX[row]
				move    X0,DMR5          ; pX[row+1]
				;
				; end of loop i
				; 
				inc     DMR7             ; i++
C2EndLpI:
				moves   DMR7,X0          ; i
				cmp     Y0,X0            ; i < xrows
				blt     C2LoopI          ; loop if i < xrows
				rts                      ; return from Case 2


				;
				; Case 3: Use unrolled loop 
				;
UseUnrolled:
				asl     Y1               ; calculate case addr
				move    #EndCase,A
				sub     Y1,A
				move    A,DMR2           ; use case addr
				;
				; for (i=0; i<xrows; i++) 
				;
C3StartLpI:
				moves   #0,DMR7          ; i
				;jmp     C3EndLpI        ; check eliminated for efficiency
				;
				; for (j=0; j<xrows; j++) 
				;
C3LoopI:
				moves   #0,DMR3          ; j
				;bra     C3EndLpJ        ; check elminated for efficiency
				;
				; pXelem = pX
				; pYelem = pY + j
				; temp   = 0
				; // preload *pXelem & *pYelem for L_mac  
				;
				move    X:(SP-2),X0
				do      X0,C3EndLpJ
				moves   DMR5,R3          ; pXelem = pX
				moves   DMR3,X0          ; j
				add     DMR6,X0         ; pY + j
				move    X0,R1            ; pYelem = pY + j
				clr     B  X:(R3)+,X0    ; temp = 0, pXelem (X0)
				move    X:(R1)+N,Y1      ; pYelem (Y1)
				;
				; Load jump address which selects
				; between REP, DO, and unrolled loop
				; implementations of inner loop 
				;
				move    DMR2,A1          ; Load jump table addr
				lea     (SP)+            ; Jump to inner loop
				move    A1,X:(SP)+
				move    SR,X:(SP)
				rts
				;
				; Unrolled loop implementation
				;
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0
				mac     Y1,X0,B  X:(R1)+N,Y1
				move    X:(R3)+,X0	
EndCase:
				rnd     B                ; round(temp)
				move    B,X:(R2)+        ; pZ = round(temp)
				;
				; end of loop j
				; 
				inc     DMR3             ; j++
C3EndLpJ:
				;
				; pX += xcols
				; 
				moves   DMR4,X0          ; xcols
				add     DMR5,X0          ; pX[row]
				move    X0,DMR5          ; pX[row+1]
				;
				; end of loop i
				; 
				inc     DMR7             ; i++
C3EndLpI:
				moves   DMR7,X0          ; i
				cmp     Y0,X0            ; i < xrows
				blt     C3LoopI          ; loop if i < xrows
				rts                      ; return

				ENDSEC
 

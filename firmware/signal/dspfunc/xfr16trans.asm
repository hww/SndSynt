	SECTION rtlib
	
	include "portasm.h"

	GLOBAL  Fxfr16Trans

;
;asm void xfr16Trans (Frac16 *pX, int xrows, int xcols, Frac16 *pZ);
;{
; Register utilization upon entry:

;		R2    - pX
;		R3    - pZ
;		Y0    - xrows
;		Y1    - xcols
;
;	Register utilization during execution:
;     R1    - pZtemp
;		R2    - pX
;		R3    - pZ
;		Y0,N  - xrows
;     Y1    - xcols
;     X0    - temp
;
Fxfr16Trans:
				move    Y0,N
OuterLoop:
				move    R3,R1
				lea     (R3+1)
InnerLoop:
				do      Y1,EndOuterLoop
				move    X:(R2)+,X0
				move    X0,X:(R1)+N
EndOuterLoop:
				sub     #1,Y0
				bgt     OuterLoop
				rts     

				ORG	X:

				ENDSEC
				END

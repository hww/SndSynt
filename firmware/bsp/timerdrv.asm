		SECTION rtlib
	
		include "portasm.h"
				
		ORG	P:
	
		GLOBAL    FQuickDivU32UZ
		GLOBAL    FQuickMpyU32U
		XREF      ARTDIVU32UZ
		XREF      ARTMPYU32U

		
FQuickDivU32UZ:
;
; Input Parameters:
;   Y   -  Dividend
;   A   -  Divisor
; Output Parameter:
;   Y   -  Result (Dividend / Divisor)
;   B   -  Remainder
;
	lea     (SP)+
	move    A0,x:(SP)+
	move    A1,x:(SP)    ; Adjust parameters to call C runtime
	move    Y1,A
	move    Y0,A0
	jsr     ARTDIVU32UZ
	lea     (SP-2)        ; pop parameters
	; Result is in Y
	; Remainder is in B
	rts
	
	
FQuickMpyU32U:
;
; Input Parameters:
;   Y   -  Multiplier
;   A   -  Multiplier
; Output Parameter:
;   Y   -  Result (Y*A)
;
	lea     (SP)+
	move    Y0,x:(SP)+
	move    Y1,x:(SP)
	jsr     ARTMPYU32U
	lea     (SP-2)
	move    A1,Y1
	move    A0,Y0
	rts

	ENDSEC
	END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Mult

; void afr32Mult (Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n)
 
;    Register usage:
;       R1 - pZ (output vector)
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       N  - 2
;       A  - temp
;       X0 - temp
;       Y1 - temp
;
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Mult:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndDo
		move    X:(SP-2),R1
		move    #2,N
		do      Y0,EndDo
		move    X:(R2)+,Y1
		move    X:(R3)+,X0
		mpy     Y1,X0,A
		move    A,X:(R1+1)
		move    A0,X:(R1)+N
EndDo:
		rts     

		ENDSEC
		END

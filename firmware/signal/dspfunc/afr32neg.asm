		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Negate

; void  afr32Negate  (Frac32 *pX, Frac32 *pZ, UInt16 n)
; 
;    Register usage:
;       R2 - pX (input vector)
;       R3 - pZ (output vector)
;       Y0 - n  (length of all vectors)
;       N  - 2
;       A  - temp
;
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Negate:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndDo
		move    #2,N
		do      Y0,EndDo
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		neg     A
		move    A,X:(R3+1)
		move    A0,X:(R3)+N
EndDo:
		rts     

		ENDSEC
		END

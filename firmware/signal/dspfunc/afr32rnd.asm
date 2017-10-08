		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Round

; void  afr32Round  (Frac32 *pX, Frac16 *pZ, UInt16 n)
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
Fafr32Round:

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
		rnd     A
		move    A,X:(R3)+
EndDo:
		rts     

		ENDSEC
		END

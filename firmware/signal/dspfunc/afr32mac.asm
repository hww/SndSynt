		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Mac

; void afr32Mac (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
;
;    Register usage:
;       R0 - pY (input vector)
;       R1 - pZ (output vector)
;       R2 - pW (input vector)
;       R3 - pX (input vector)
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       N  - 2
;       A  - temp
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Mac:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndDo
		move    X:(SP-3),R1
		move    X:(SP-2),R0
		move    #2,N
		move    X:(R0)+,Y1
		do      Y0,EndDo
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		move    X:(R3)+,X0
		mac     Y1,X0,A     X:(R0)+,Y1
		move    A,X:(R1+1)
		move    A0,X:(R1)+N
EndDo:
		rts     

		ENDSEC
		END

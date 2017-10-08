		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Add

; void afr32Add (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n)
 
;    Register usage:
;       R1 - pZ (output vector)
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       N  - 2
;       A  - temp
;       B  - temp
;
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Add:

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
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		move    X:(R3+1),B
		move    X:(R3)+N,B0
		add     A,B
		move    B,X:(R1+1)
		move    B0,X:(R1)+N
EndDo:
		rts     

		ENDSEC
		END

		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Sqrt
		XREF    Fmfr32Sqrt

; void afr32Sqrt (Frac32 *pX, Frac16 *pZ, UInt16 n);

;    Register usage:
;       R2 - pX (input vector)
;       R3 - pZ (output vector)
;       Y0 - n  (length of all vectors)
;
		ORG	P:
Fafr32Sqrt:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndSqrt
		lea     (SP+4)
		move    R2,X:(SP-3)
		move    R3,X:(SP-2)
		move    Y0,X:(SP-1)
SqrtLoop:
		move    X:(R2+1),A
		move    X:(R2),A0
		jsr     Fmfr32Sqrt
		move    X:(SP-2),R3
		incw    X:(SP-3)
		incw    X:(SP-3)
		move    X:(SP-3),R2
		move    Y0,X:(R3)
		incw    X:(SP-2)
		decw    X:(SP-1)
		move    X:(SP-1),Y0
		bgt     SqrtLoop
		lea     (SP-4)        ; pop Y0, R2, R3
EndSqrt:
		rts     

		ENDSEC
		END

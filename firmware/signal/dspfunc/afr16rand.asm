		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Rand
		XREF    Fmfr16Rand

; void afr16Rand (Frac16 *pZ, UInt16 n);

;    Register usage:
;       R2 - pZ (output vector)
;       Y0 - n  (length of all vectors)
;
		ORG	P:
Fafr16Rand:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndRand
		lea     (SP+3)
		move    R2,X:(SP-2)
		move    Y0,X:(SP-1)
RandLoop:
		jsr     Fmfr16Rand
		move    X:(SP-2),R2
		incw    X:(SP-2)
		move    Y0,X:(R2)
		decw    X:(SP-1)
		move    X:(SP-1),Y0
		bgt     RandLoop
		lea     (SP-3)
EndRand:
		rts     

		ENDSEC
		END

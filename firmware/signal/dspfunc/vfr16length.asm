		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fvfr16Length
		XREF    Fmfr32Sqrt

; Frac16  vfr16Length (Frac16 *pX, UInt16 n)
;
;    Register usage upon entry:
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;
;    Register usage during execution:
;       R2 - pX 
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       A  - temp
;       Y0 - Output value
;
			ORG	P:
Fvfr16Length:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y0
			bls     ParamsOK
			debug 
			rts  
ParamsOK:

	endif
	
			tstw    Y0
			ble     EndLength
			move    Y0,X0
			clr     A
			move    X:(R2)+,Y0
			rep     X0
			mac     Y0,Y0,A      X:(R2)+,Y0
EndLength:
			jsr     Fmfr32Sqrt
			; result is in Y0
			rts     

			ENDSEC
			END

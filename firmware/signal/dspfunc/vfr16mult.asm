		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fvfr16Mult

; void    vfr16Mult (Frac16 c, Frac16 *pX, Frac16 *pZ, UInt16 n)
;
;    Register usage upon entry:
;       R2 - pX (input vector)
;       R3 - pZ (output vector)
;       Y0 - c
;       Y1 - n  (length of all vectors)
;
;    Register usage during execution:
;       R2 - pX 
;       R3 - pZ
;       Y1 - n  (length of all vectors)
;       Y0 - c
;       A  - temp
;
			ORG	P:
Fvfr16Mult:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y1
			bls     ParamsOK
			debug 
			rts  
ParamsOK:

	endif
	
			tstw    Y1
			ble     EndMult
			move    X:(R2)+,X0
			do      Y1,EndDo
			mpy     Y0,X0,A      X:(R2)+,X0
			move    A,X:(R3)+
EndDo:
EndMult:
			rts     

			ENDSEC
			END

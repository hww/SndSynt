		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Mult

; void afr16Mult (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
 
;    Register usage upon entry:
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;     SP-2 - pZ (output vector)
;       Y0 - n  (length of all vectors)
;
;    Register usage during execution:
;       R1 - pZ
;       R2 - pX 
;       R3 - pY
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       A  - temp
;
			ORG	P:
Fafr16Mult:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y0
			bls     ParamsOK
			debug 
			rts  
ParamsOK:

	endif
	
			tstw    Y0
			ble     EndMult
			move    X:(SP-2),R1
			move    X:(R2)+,X0
			do      Y0,EndDo
			move    X:(R3)+,Y1
			mpy     Y1,X0,A     X:(R2)+,X0
			move    A,X:(R1)+
EndDo:
EndMult:
			rts     

			ENDSEC
			END

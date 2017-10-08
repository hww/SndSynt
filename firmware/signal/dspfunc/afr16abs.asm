		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Abs

; void  afr16Abs  (Frac16 *pX, Frac16 *pZ, UInt16 n)
; 
;    Register usage:
;       R2 - pX (input vector)
;       R3 - pZ (output vector)
;       Y0 - n  (length of all vectors)
;       A  - temp
;
;
; ensure MAX_VECTOR_LEN >= vector length >= 0
;

		GLOBAL Fafr16Abs
		ORG	P:
Fafr16Abs:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw     Y0
		ble     EndDo
		do      Y0,EndDo
		move    X:(R2)+,A
		abs     A
		move    A,X:(R3)+
EndDo:
		rts     

		ENDSEC
		END

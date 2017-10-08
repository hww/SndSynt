		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fvfr16DotProd

; Frac32  vfr16DotProd (Frac16 *pX, Frac16 *pY, UInt16 n)
;
;    Register usage upon entry:
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;
;    Register usage during execution:
;       R2 - pX 
;       R3 - pY
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       A  - Output value
;
			ORG	P:
Fvfr16DotProd:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y0
			bls     ParamsOK
			debug 
			rts  
ParamsOK:

	endif
	
			tstw    Y0
			ble     EndDotProd
			clr     A
			move    X:(R2)+,X0
			move    X:(R3)+,Y1
			do      Y0,EndDo
			mac     Y1,X0,A      X:(R2)+,X0
			move    X:(R3)+,Y1
EndDo:
EndDotProd:
			rts     

			ENDSEC
			END

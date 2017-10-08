		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Mac_r

; void afr16Mac_r (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
; 
;    Register usage upon entry:
;       R2 - pW (input vector)
;       R3 - pX (input vector)
;     SP-2 - pY (input vector)
;     SP-3 - pZ (output vecttor)
;       Y0 - n  (length of all vectors)
;
;    Register usage upon entry:
;       R0 - pY
;       R1 - pZ
;       R2 - pW 
;       R3 - pX
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       A  - temp
;
				ORG	P:
Fafr16Mac_r:

	if ASSERT_ON_INVALID_PARAMETER==1
 
				cmp     #PORT_MAX_VECTOR_LEN,Y0
				bls     ParamsOK
				debug
				rts   
ParamsOK:

	endif
	
				tstw    Y0
				ble     EndMacr
				move    X:(SP-2),R0
				move    X:(SP-3),R1
				move    X:(R0)+,Y1
				do      Y0,EndDo
				move    X:(R2)+,A
				move    X:(R3)+,X0
				macr    Y1,X0,A    X:(R0)+,Y1
				move    A,X:(R1)+
EndDo:
EndMacr:
				rts     

			ENDSEC
			END

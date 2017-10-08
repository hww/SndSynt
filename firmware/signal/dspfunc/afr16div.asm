		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Div

; void    afr16Div    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
; 
;    Register usage:
;       R1 - pZ (output vector)
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       X0 - temp
;       Y0 - n  (length of all vectors)
;       Y1 - temp
;       A  - temp
;
				ORG	P:
Fafr16Div:

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
				move    X:(R2)+,A
				move    X:(R3)+,X0
				do      Y0,EndDo
				move    A,Y1
				abs     A
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,A
				bftsth  #8,SR
				bcc     Positive
				neg     A
Positive:
				move    A0,X:(R1)+
				move    X:(R2)+,A
				move    X:(R3)+,X0
EndDo:
				rts     

				ENDSEC
				END

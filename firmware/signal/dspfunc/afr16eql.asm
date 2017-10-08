		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Equal

; bool afr16Equal (Frac16 *pX, Frac16 *pY, UInt16 n)
; 
;    Register usage:
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       A1 - temp
;
			ORG	P:
Fafr16Equal:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y0
			bls     ParamsOK
			debug
			rts   
ParamsOK:

	endif
			tstw    Y0
			ble     EndDo
			move    Y0,A1
			move    #1,Y0
			move    X:(R2)+,X0
			move    X:(R3)+,Y1
			cmp     Y1,X0
			do      A1,EndDo
			beq     Equal
			move    #0,Y0
			enddo
Equal:
			move    X:(R2)+,X0
			move    X:(R3)+,Y1
			cmp     Y1,X0
EndDo:
			rts     

			ENDSEC
			END

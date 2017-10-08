		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Equal

; bool  afr32Equal  (Frac32 *pX, Frac32 *pY, UInt16 n)
; 
;    Register usage:
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       N  - 2
;       A  - temp
;       B  - temp
;
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Equal:

	if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp     #PORT_MAX_VECTOR_LEN,Y0
		bls     ParamsOK
		debug
		rts   
ParamsOK:

	endif
	
		tstw    Y0
		ble     EndDo
		move    Y0,X0
		move    #1,Y0
		move    #2,N
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		move    X:(R3+1),B
		move    X:(R3)+N,B0
		do      X0,EndDo
		cmp     A,B
		beq     Equal
NotEqual:
		move    #0,Y0
		enddo
Equal:
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		move    X:(R3+1),B
		move    X:(R3)+N,B0
EndDo:
		rts     

		ENDSEC
		END

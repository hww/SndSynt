		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Div

; void afr32Div (Frac32 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
;
;    Register usage:
;       R1 - pZ (output vector)
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       X0 - temp
;       Y1 - temp
;       N  - 2
;       A  - temp
;
; ensure PORT_MAX_VECTOR_LEN >= vector length >= 0
;

		ORG	P:
Fafr32Div:

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
		move    #2,N
		move    X:(R2+1),A
		move    X:(R2)+N,A0
		do      Y0,EndDo
		move    X:(R3)+,X0
		move    A,Y1
		abs     A
		eor     X0,Y1
		bfclr   #1,SR
		rep     #16
		div     X0,A
		bftsth  #8,SR
		bcc     DivDone
		neg     A
DivDone:
		move    A0,X:(R1)+
		move    X:(R2+1),A
		move    X:(R2)+N,A0
EndDo:
		rts     

		ENDSEC
		END

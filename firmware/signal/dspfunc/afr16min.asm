		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Min

; Frac16 afr16Min (Frac16 *pX, UInt16 n, UInt16 *pMaxIndex);
;
;    Register usage upon entry:
;       R2   - pX (input vector)
;       R3   - pMinIndex (pointer to output value; can be NULL)
;       Y0   - n  (length of all vectors)
;
;    Register usage during execution:
;       R0   - pX (increments in loop)
;       R1   - pX of minimum value
;       R2   - pX (original value)
;       R3   - pMinIndex (pointer to output value; can be NULL)
;       Y0   - n  (length of all vectors)
;       A    - Min value
;       B    - temp
;       Y1,X0- Minindex calculation
;
				ORG	P:
Fafr16Min:

	if ASSERT_ON_INVALID_PARAMETER==1
 
				cmp     #PORT_MAX_VECTOR_LEN,Y0
				bls     Param1OK
				debug
				rts   
Param1OK:
				tstw    Y0
				bne     ParamsOK
				debug
				rts   
ParamsOK:

	endif
 	
            move    X:(R2)+,A
            move    R2,R0
            move    R2,R1
				decw    Y0
				beq     EndDo
				do      Y0,EndDo
				move    X:(R0)+,B
				cmp     A,B
				tlt     B,A    R0,R1
EndDo:
				move    A,Y0
				tstw    R3
				beq     EndMin
				move    R2,X0
				move    R1,Y1
				sub     X0,Y1
				move    Y1,X:(R3)
EndMin:
				rts     

		ENDSEC
		END

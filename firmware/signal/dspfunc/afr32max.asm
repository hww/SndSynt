		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr32Max

; Frac32 afr32Max (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex);
;
;    Register usage upon entry:
;       R2   - pX (input vector)
;       R3   - pMaxIndex (pointer to output value; can be NULL)
;       Y0   - n  (length of all vectors)
;
;    Register usage during execution:
;       R0   - pX (increments in loop)
;       R1   - pX of maximum value
;       R2   - pX (original value)
;       R3   - pMaxIndex (pointer to output value; can be NULL)
;       Y0   - n  (length of all vectors)
;       A    - Max value
;       B    - temp
;       N    - 2
;       Y1,X0- Max index calculation
;
				ORG	P:
Fafr32Max:

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
		
				move    #2,N
            move    X:(R2+1),A
            move    X:(R2)+N,A0
            move    R2,R0
            move    R2,R1
				decw    Y0
				beq     EndDo
				do      Y0,EndDo
				move    X:(R0+1),B
				move    X:(R0)+N,B0
				cmp     A,B
				tgt     B,A   R0,R1
EndDo:
				tstw    R3
				beq     EndMax
				move    R2,X0
				move    R1,Y1
				sub     X0,Y1
				asr     Y1
				move    Y1,X:(R3)
EndMax:
				rts     

		ENDSEC
		END

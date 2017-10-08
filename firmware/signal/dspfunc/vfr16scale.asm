		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fvfr16Scale

; void    vfr16Scale (Int16  k, Frac16 *pX, Frac16 *pZ, UInt16 n)
;
;    Register usage upon entry:
;       R2 - pX (input vector)
;       R3 - pZ (output vector)
;       Y0 - k
;       Y1 - n  (length of all vectors)
;
;    Register usage during execution:
;       R2 - pX 
;       R3 - pZ
;       Y1 - n  (length of all vectors)
;       Y0 - k
;       A  - temp
;
			ORG	P:
Fvfr16Scale:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y1
			bls     ParamsOK
			debug 
			rts  
ParamsOK:

	endif
	
			tstw    Y1
			ble     EndScale
			tstw    Y0
			beq     EndScale
			blt     DownScale
UpScale:
			do      Y1,EndUpDo
			move    X:(R2)+,A
			rep     Y0
			asl     A
			move    A,X:(R3)+
EndUpDo:
EndScale:
			rts
			
DownScale:
			move    Y0,A
			neg     A
			move    A,Y0
			do      Y1,EndDownDo
			move    X:(R2)+,A
			rep     Y0
			asr     A
			move    A,X:(R3)+
EndDownDo:
			rts

			ENDSEC
			END

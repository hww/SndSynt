		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fafr16Add

; asm void  afr16Add    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
;
;    Register usage:
;       R1 - pZ (output vector)
;       R2 - pX (input vector)
;       R3 - pY (input vector)
;       Y0 - n  (length of all vectors)
;       X0 - temporary reg to hold y[i]
;       A  - hold y[i], then result of addition
;
;
	Fafr16Add:

	 if ASSERT_ON_INVALID_PARAMETER==1
 
		cmp  #PORT_MAX_VECTOR_LEN,Y0
		bls  ParamsOK
		debug
		rts
;
; pre-load regs
;
	ParamsOK:
	
	 endif
 
		tstw     Y0
		ble     endfunc
		move X:(SP-2),R1
		move X:(R2)+,A
		move X:(R3)+,X0
;
; vector add loop
;
		dec  Y0
		do   Y0,endloop
		add  X0,A  X:(R3)+,X0
		move A,X:(R1)+
		move X:(R2)+,A
	endloop:
;
; add last elements of vector
;
 		add  X0,A
 		move A,X:(R1)
 	endfunc:
		rts

		ORG	X:

		ENDSEC
		END

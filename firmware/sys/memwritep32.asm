		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FmemWriteP32

; void memWriteP32  (Word32 x, Word32 *pX);
; #pragma interrupt  /* Can be used in a pragma interrupt ISR */
;    Register usage:
;       R2 - pX
;       A  - x
;       X0 - temp
;
			ORG	P:
FmemWriteP32:
			push X0
			move A0,X0
			move X0,P:(R2)+
			move A,P:(R2)+
			pop  X0
			rts     

			ENDSEC
			END

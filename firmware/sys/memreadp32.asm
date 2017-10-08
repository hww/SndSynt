		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FmemReadP32

; Word32 memReadP32  (Word32 *pX);
; #pragma interrupt  /* Can be used in a pragma interrupt ISR */
;
;    Register usage:
;       R2 - pX
;       A  - return value
;       X0 - temp
;
			ORG	P:
FmemReadP32:
			push X0
			move P:(R2)+,X0
			move P:(R2)+,A
			move X0,A0
			pop  X0
			rts     

			ENDSEC
			END

		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FmemMemset

; void  * memMemset (void *dest, int c, size_t count);
; #pragma interrupt  /* Can be called from a pragma interrupt ISR */
;
;    Register usage:
;       R2 - dest
;       Y0 - c
;       Y1 - count
;
			ORG	P:
FmemMemset:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y1
			bls     ParamsOK
			debug
			rts   
ParamsOK:

	endif
	
			tstw    Y1
			beq     EndMemset
			rep     Y1
			move    Y0,X:(R2)+
EndMemset:
			; R2 - Contains *dest return value
			rts     

			ENDSEC
			END

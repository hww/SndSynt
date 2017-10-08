		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FmemMemsetP

; void  * memMemsetP (void *dest, int c, size_t count);
; #pragma interrupt  /* Can be used in a pragma interrupt ISR */
;
;    Register usage:
;       R2 - dest
;       Y0 - c
;       Y1 - count
;
			ORG	P:
FmemMemsetP:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y1
			bls     ParamsOK
			debug
			rts   
ParamsOK:

	endif
	
			tstw    Y1
			beq     EndMemsetP
			do      Y1,EndMemsetP
			move    Y0,P:(R2)+
EndMemsetP:
			; R2 - Contains *dest return value
			rts     

			ENDSEC
			END

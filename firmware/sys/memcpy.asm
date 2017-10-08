		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FmemMemcpy

; void *memcpy( void *dest, const void *src, size_t count );
; #pragma interrupt /* Can be called from a pragma interrupt ISR */
;
;    Register usage:
;       R2 - dest
;       R3 - src
;       Y0 - count/temp
;
			ORG	P:
FmemMemcpy:

	if ASSERT_ON_INVALID_PARAMETER==1
 
			cmp     #PORT_MAX_VECTOR_LEN,Y0
			bls     ParamsOK
			debug
			rts   
ParamsOK:

	endif
	
			tstw    Y0
			beq     EndDo
			do      Y0,EndDo
			move    X:(R3)+,Y0
			move    Y0,X:(R2)+
EndDo:
			; R2 - Contains *dest return value
			rts     

			ENDSEC
			END

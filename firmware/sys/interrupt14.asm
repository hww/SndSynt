		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt14
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt14:
		lea    (SP)+
		move   N,x:(SP)+
		move   #14,N
		bftsth #$4000,X:FarchISRType
		jmp    FastDispatcher

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt61
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt61:
		lea    (SP)+
		move   N,x:(SP)+
		move   #61,N
		bftsth #$2000,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


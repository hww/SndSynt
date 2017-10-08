		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt63
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt63:
		lea    (SP)+
		move   N,x:(SP)+
		move   #63,N
		bftsth #$8000,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


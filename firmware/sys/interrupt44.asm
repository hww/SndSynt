		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt44
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt44:
		lea    (SP)+
		move   N,x:(SP)+
		move   #44,N
		bftsth #$1000,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt56
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt56:
		lea    (SP)+
		move   N,x:(SP)+
		move   #56,N
		bftsth #$0100,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


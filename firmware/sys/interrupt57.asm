		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt57
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt57:
		lea    (SP)+
		move   N,x:(SP)+
		move   #57,N
		bftsth #$0200,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


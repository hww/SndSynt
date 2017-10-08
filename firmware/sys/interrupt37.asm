		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt37
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt37:
		lea    (SP)+
		move   N,x:(SP)+
		move   #37,N
		bftsth #$0020,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


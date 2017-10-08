		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt53
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt53:
		lea    (SP)+
		move   N,x:(SP)+
		move   #53,N
		bftsth #$0020,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


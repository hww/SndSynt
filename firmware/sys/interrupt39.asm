		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt39
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt39:
		lea    (SP)+
		move   N,x:(SP)+
		move   #39,N
		bftsth #$0080,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


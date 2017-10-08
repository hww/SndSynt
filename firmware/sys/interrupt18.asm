		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt18
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt18:
		lea    (SP)+
		move   N,x:(SP)+
		move   #18,N
		bftsth #$0004,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


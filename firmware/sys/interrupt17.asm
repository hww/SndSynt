		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt17
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt17:
		lea    (SP)+
		move   N,x:(SP)+
		move   #17,N
		bftsth #$0002,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


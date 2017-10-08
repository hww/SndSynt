		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt19
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt19:
		lea    (SP)+
		move   N,x:(SP)+
		move   #19,N
		bftsth #$0008,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


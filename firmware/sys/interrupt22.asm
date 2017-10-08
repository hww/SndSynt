		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt22
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt22:
		lea    (SP)+
		move   N,x:(SP)+
		move   #22,N
		bftsth #$0040,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


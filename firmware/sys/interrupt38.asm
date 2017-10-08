		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt38
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt38:
		lea    (SP)+
		move   N,x:(SP)+
		move   #38,N
		bftsth #$0040,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt52
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt52:
		lea    (SP)+
		move   N,x:(SP)+
		move   #52,N
		bftsth #$0010,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


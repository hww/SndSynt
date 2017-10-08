		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt54
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt54:
		lea    (SP)+
		move   N,x:(SP)+
		move   #54,N
		bftsth #$0040,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


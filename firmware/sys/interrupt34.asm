		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt34
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt34:
		lea    (SP)+
		move   N,x:(SP)+
		move   #34,N
		bftsth #$0004,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


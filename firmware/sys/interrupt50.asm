		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt50
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt50:
		lea    (SP)+
		move   N,x:(SP)+
		move   #50,N
		bftsth #$0004,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


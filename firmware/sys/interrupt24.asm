		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt24
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt24:
		lea    (SP)+
		move   N,x:(SP)+
		move   #24,N
		bftsth #$0100,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


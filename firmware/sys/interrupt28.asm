		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt28
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt28:
		lea    (SP)+
		move   N,x:(SP)+
		move   #28,N
		bftsth #$1000,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


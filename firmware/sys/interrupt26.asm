		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt26
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt26:
		lea    (SP)+
		move   N,x:(SP)+
		move   #26,N
		bftsth #$0400,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


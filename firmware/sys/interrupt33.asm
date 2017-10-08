		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt33
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt33:
		lea    (SP)+
		move   N,x:(SP)+
		move   #33,N
		bftsth #$0002,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


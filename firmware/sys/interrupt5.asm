		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt5
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt5:
		lea    (SP)+
		move   N,x:(SP)+
		move   #5,N
		bftsth #$0020,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


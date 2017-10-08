		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt35
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt35:
		lea    (SP)+
		move   N,x:(SP)+
		move   #35,N
		bftsth #$0008,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


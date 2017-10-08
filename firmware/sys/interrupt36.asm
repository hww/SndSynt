		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt36
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt36:
		lea    (SP)+
		move   N,x:(SP)+
		move   #36,N
		bftsth #$0010,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


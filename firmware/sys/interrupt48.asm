		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt48
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt48:
		lea    (SP)+
		move   N,x:(SP)+
		move   #48,N
		bftsth #$0001,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


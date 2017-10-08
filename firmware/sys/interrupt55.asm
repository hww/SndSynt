		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt55
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt55:
		lea    (SP)+
		move   N,x:(SP)+
		move   #55,N
		bftsth #$0080,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


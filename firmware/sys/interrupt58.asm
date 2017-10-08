		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt58
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt58:
		lea    (SP)+
		move   N,x:(SP)+
		move   #58,N
		bftsth #$0400,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


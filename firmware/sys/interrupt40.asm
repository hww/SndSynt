		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt40
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt40:
		lea    (SP)+
		move   N,x:(SP)+
		move   #40,N
		bftsth #$0100,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


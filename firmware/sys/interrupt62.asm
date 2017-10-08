		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt62
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt62:
		lea    (SP)+
		move   N,x:(SP)+
		move   #62,N
		bftsth #$4000,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


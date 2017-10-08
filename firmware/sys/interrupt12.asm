		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt12
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt12:
		lea    (SP)+
		move   N,x:(SP)+
		move   #12,N
		bftsth #$1000,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


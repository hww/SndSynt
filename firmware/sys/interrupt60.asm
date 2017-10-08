		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt60
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt60:
		lea    (SP)+
		move   N,x:(SP)+
		move   #60,N
		bftsth #$1000,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt47
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt47:
		lea    (SP)+
		move   N,x:(SP)+
		move   #47,N
		bftsth #$8000,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


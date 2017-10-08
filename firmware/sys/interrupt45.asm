		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt45
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt45:
		lea    (SP)+
		move   N,x:(SP)+
		move   #45,N
		bftsth #$2000,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


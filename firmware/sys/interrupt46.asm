		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt46
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt46:
		lea    (SP)+
		move   N,x:(SP)+
		move   #46,N
		bftsth #$4000,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


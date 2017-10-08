		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt30
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt30:
		lea    (SP)+
		move   N,x:(SP)+
		move   #30,N
		bftsth #$4000,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


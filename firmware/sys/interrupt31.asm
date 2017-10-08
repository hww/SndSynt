		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt31
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt31:
		lea    (SP)+
		move   N,x:(SP)+
		move   #31,N
		bftsth #$8000,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


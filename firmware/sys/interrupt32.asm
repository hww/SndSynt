		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt32
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt32:
		lea    (SP)+
		move   N,x:(SP)+
		move   #32,N
		bftsth #$0001,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


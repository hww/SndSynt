		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt49
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt49:
		lea    (SP)+
		move   N,x:(SP)+
		move   #49,N
		bftsth #$0002,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


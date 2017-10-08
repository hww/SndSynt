		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt43
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt43:
		lea    (SP)+
		move   N,x:(SP)+
		move   #43,N
		bftsth #$0800,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


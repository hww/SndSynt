		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt41
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt41:
		lea    (SP)+
		move   N,x:(SP)+
		move   #41,N
		bftsth #$0200,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


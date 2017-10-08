		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt23
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt23:
		lea    (SP)+
		move   N,x:(SP)+
		move   #23,N
		bftsth #$0080,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


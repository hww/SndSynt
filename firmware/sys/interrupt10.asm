		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt10
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt10:
		lea    (SP)+
		move   N,x:(SP)+
		move   #10,N
		bftsth #$0400,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


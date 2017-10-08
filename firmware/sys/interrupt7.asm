		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt7
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt7:
		lea    (SP)+
		move   N,x:(SP)+
		move   #7,N
		bftsth #$0080,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


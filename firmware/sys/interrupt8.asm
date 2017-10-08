		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt8
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt8:
		lea    (SP)+
		move   N,x:(SP)+
		move   #8,N
		bftsth #$0100,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


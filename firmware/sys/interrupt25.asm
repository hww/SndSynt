		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt25
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt25:
		lea    (SP)+
		move   N,x:(SP)+
		move   #25,N
		bftsth #$0200,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt9
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt9:
		lea    (SP)+
		move   N,x:(SP)+
		move   #9,N
		bftsth #$0200,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


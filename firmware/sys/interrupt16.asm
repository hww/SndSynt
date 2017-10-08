		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt16
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt16:
		lea    (SP)+
		move   N,x:(SP)+
		move   #16,N
		bftsth #$0001,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


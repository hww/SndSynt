		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt20
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt20:
		lea    (SP)+
		move   N,x:(SP)+
		move   #20,N
		bftsth #$0010,X:FarchISRType+1
		jmp    FastDispatcher

		ENDSEC
		END


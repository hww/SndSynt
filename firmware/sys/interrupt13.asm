		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt13
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt13:
		lea    (SP)+
		move   N,x:(SP)+
		move   #13,N
		bftsth #$2000,X:FarchISRType
		jmp    FastDispatcher

		ENDSEC
		END


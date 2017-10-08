		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt29
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt29:
		lea    (SP)+
		move   N,x:(SP)+
		move   #29,N
		bftsth #$2000,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


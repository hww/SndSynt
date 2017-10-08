		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt42
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt42:
		lea    (SP)+
		move   N,x:(SP)+
		move   #42,N
		bftsth #$0400,X:FarchISRType+2
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt51
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt51:
		lea    (SP)+
		move   N,x:(SP)+
		move   #51,N
		bftsth #$0008,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt3
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt3:
		lea    (SP)+
		move   N,x:(SP)+
		move   #3,N
		bftsth #$0008,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


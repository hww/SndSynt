		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt15
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt15:
		lea    (SP)+
		move   N,x:(SP)+
		move   #15,N
		bftsth #$8000,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


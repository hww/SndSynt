		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt4
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt4:
		lea    (SP)+
		move   N,x:(SP)+
		move   #4,N
		bftsth #$0010,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


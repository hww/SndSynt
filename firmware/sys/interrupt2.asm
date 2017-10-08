		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt2
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt2:
		lea    (SP)+
		move   N,x:(SP)+
		move   #2,N
		bftsth #$0004,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


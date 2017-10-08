		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt59
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt59:
		lea    (SP)+
		move   N,x:(SP)+
		move   #59,N
		bftsth #$0800,X:FarchISRType+3
		jmp    FastDispatcher
				 

		ENDSEC
		END


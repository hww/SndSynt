		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt27
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt27:
		lea    (SP)+
		move   N,x:(SP)+
		move   #27,N
		bftsth #$0800,X:FarchISRType+1
		jmp    FastDispatcher
				 

		ENDSEC
		END


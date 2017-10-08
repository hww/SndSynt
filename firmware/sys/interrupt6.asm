		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt6
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt6:
		lea    (SP)+
		move   N,x:(SP)+
		move   #6,N
		bftsth #$0040,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END


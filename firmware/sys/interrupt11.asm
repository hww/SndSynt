		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt11
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt11:
		lea    (SP)+
		move   N,x:(SP)+
		move   #11,N
		bftsth #$0800,X:FarchISRType
		jmp    FastDispatcher


		ENDSEC
		END


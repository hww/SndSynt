		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt21
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines
;
FInterrupt21:
		lea    (SP)+
		move   N,x:(SP)+
		move   #21,N
		bftsth #$0020,X:FarchISRType+1
		jmp    FastDispatcher


		ENDSEC
		END


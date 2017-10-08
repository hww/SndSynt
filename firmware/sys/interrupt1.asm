		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FInterrupt1
		XREF    FarchISRType
		XREF    FastDispatcher
				
		ORG	P:
	
;
; Interrupt routines 
;
FInterrupt1:
		lea    (SP)+
		move   N,x:(SP)+
		move   #1,N
		bftsth #$0002,X:FarchISRType
		jmp    FastDispatcher
				 

		ENDSEC
		END



				SECTION codec
				include "asmdef.h"
				GLOBAL Fmain
				ORG	P:
Fmain:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   #0,X:<mr8
				jsr     FfcodecOpen
_L3:
				jsr     FfcodecWaitBuf
				move    R2,X:(SP)
				moves   #0,X:<mr9
				bra     _L10
_L6:
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				moves   X:<mr8,X0
				move    X0,X:(R0)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				moves   X:<mr8,X0
				move    X0,X:(R0)
				moves   X:<mr8,X0
				add     #256,X0
				move    X0,X:<mr8
				inc     X:<mr9
_L10:
				movei   #320,X0
				cmp     X:<mr9,X0
				bhi     _L6
				bra     _L3


				ORG	X:

				ENDSEC
				END

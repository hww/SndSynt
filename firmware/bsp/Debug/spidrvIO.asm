
				SECTION spidrvIO
				include "asmdef.h"
				GLOBAL FspidrvIOOpen
				ORG	P:
FspidrvIOOpen:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				movec   SP,R0
				lea     (R0-6)
				move    R0,X:(SP-1)
				dec     X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr9
				move    X:(SP),R2
				moves   X:<mr9,R3
				jsr     FspiOpen
				move    Y0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:FspidrvIODevice+1,X0
				bne     _L7
				movei   #FspidrvIODevice,R2
				bra     _L11
_L7:
				moves   X:<mr8,X0
				cmp     X:FspidrvIODevice+3,X0
				bne     _L9
				movei   #FspidrvIODevice+2,R0
				bra     _L10
_L9:
				movei   #65535,R0
_L10:
				movec   R0,R2
_L11:
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

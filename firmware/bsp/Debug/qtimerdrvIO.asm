
				SECTION qtimerdrvIO
				include "asmdef.h"
				GLOBAL FqtdrvIOOpen
				ORG	P:
FqtdrvIOOpen:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				movec   SP,R0
				lea     (R0-8)
				move    R0,X:<mr11
				dec     X:<mr11
				moves   X:<mr11,R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				move    X:(SP),R2
				move    X:(SP-8),Y0
				move    X:(SP-1),R3
				jsr     FqtOpen
				move    Y0,X:<mr10
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:FqtNumberOfDevices,X0
				bge     _L13
				moves   X:<mr8,X0
				asl     X0
				add     #FqtimerdrvIODevice,X0
				move    X0,X:<mr9
_L8:
				moves   X:<mr9,R2
				moves   X:<mr10,Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				bne     _L10
				moves   X:<mr8,X0
				asl     X0
				movec   X0,R2
				nop     
				lea     (R2+FqtimerdrvIODevice)
				bra     _L14
_L10:
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     X:FqtNumberOfDevices,X0
				blt     _L8
_L13:
				movei   #65535,R2
_L14:
				lea     (SP-2)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

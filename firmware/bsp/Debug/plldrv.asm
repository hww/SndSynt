
				SECTION plldrv
				include "asmdef.h"
				GLOBAL FplldrvInitialize
				ORG	P:
FplldrvInitialize:
				moves   Y1,X:<mr4
				movei   #129,X:FArchIO+240
				move    X:(SP-2),X0
				move    X0,X:FArchIO+243
				move    X:(SP-3),X0
				move    X0,X:FArchIO+244
				moves   X:<mr4,X0
				move    X0,X:FArchIO+241
				movec   Y0,X0
				andc    #255,X0
				cmp     #130,X0
				bne     _L13
				moves   #0,X:<mr2
				movei   #16384,X0
				cmp     X:<mr2,X0
				bls     _L13
_L9:
				move    X:FArchIO+242,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				andc    #32,X0
				cmp     #32,X0
				beq     _L13
				inc     X:<mr2
				movei   #16384,X0
				cmp     X:<mr2,X0
				bhi     _L9
_L13:
				move    Y0,X:FArchIO+240
				rts     


				ORG	X:

				ENDSEC
				END

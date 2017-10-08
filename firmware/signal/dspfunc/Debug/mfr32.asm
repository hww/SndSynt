
				SECTION mfr32
				include "asmdef.h"
				GLOBAL Fmfr32SqrtC
				ORG	P:
Fmfr32SqrtC:
				movei   #8,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   #16384,X:<mr3
				moves   #0,X:<mr2
				moves   #0,X:<mr4
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				moves   X:<mr4,X0
				cmp     #14,X0
				bhs     _L15
_L8:
				moves   X:<mr3,X0
				add     X:<mr2,X0
				move    X0,X:<mr2
				moves   X:<mr2,Y0
				moves   X:<mr2,X0
				mpy     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     A,B
				ble     _L12
				moves   X:<mr2,X0
				sub     X:<mr3,X0
				move    X0,X:<mr2
_L12:
				move    X:<mr3,B
				asr     B
				movec   B1,X0
				move    X0,X:<mr3
				inc     X:<mr4
				moves   X:<mr4,X0
				cmp     #14,X0
				blo     _L8
_L15:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    B1,X:(SP-6)
				move    B0,X:(SP-7)
				moves   X:<mr2,X0
				inc     X0
				move    X0,X:<mr5
				moves   X:<mr5,Y0
				moves   X:<mr5,X0
				mpy     Y0,X0,B
				move    X:(SP),A
				move    X:(SP-1),A0
				sub     B,A
				abs     A
				moves   X:<mr2,Y0
				moves   X:<mr2,X0
				mpy     Y0,X0,B
				movec   B1,Y1
				movec   B0,Y0
				move    X:(SP),B
				move    X:(SP-1),B0
				sub     Y,B
				cmp     B,A
				bge     _L20
				moves   X:<mr5,X0
				move    X0,X:<mr2
_L20:
				moves   X:<mr2,Y0
				lea     (SP-8)
				rts     


				ORG	X:

				ENDSEC
				END

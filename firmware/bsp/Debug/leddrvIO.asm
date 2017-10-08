
				SECTION leddrvIO
				include "asmdef.h"
				GLOBAL FleddrvIOOpen
				ORG	P:
FleddrvIOOpen:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),X0
				cmp     #10,X0
				beq     _L4
				movei   #65535,R2
				bra     _L6
_L4:
				move    X:(SP),R2
				movei   #0,Y0
				jsr     FledOpen
				movei   #FleddrvIODevice,R2
_L6:
				lea     (SP)-
				rts     


				GLOBAL FleddrvIOClose
				ORG	P:
FleddrvIOClose:
				movei   #0,Y0
				rts     


				ORG	X:

				ENDSEC
				END

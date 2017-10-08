
				SECTION allinker
				include "asmdef.h"
				GLOBAL FalUnlink
				ORG	P:
FalUnlink:
				tstw    X:(R2+1)
				beq     _L3
				move    X:(R2+1),R0
				move    X:(R2),R1
				move    R1,X:(R0)
_L3:
				tstw    X:(R2)
				beq     _L5
				move    X:(R2+1),R0
				move    X:(R2),R1
				move    R0,X:(R1+1)
_L5:
				movei   #0,X:(R2+1)
				movei   #0,X:(R2)
				rts     


				GLOBAL FalLink
				ORG	P:
FalLink:
				move    X:(R3),R0
				move    R0,X:(R2)
				move    R3,X:(R2+1)
				move    R2,X:(R3)
				tstw    X:(R2)
				beq     _L6
				move    X:(R2),R0
				move    R2,X:(R0+1)
_L6:
				rts     


				ORG	X:

				ENDSEC
				END

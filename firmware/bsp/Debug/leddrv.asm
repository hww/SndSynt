
				SECTION leddrv
				include "asmdef.h"
				GLOBAL FledOpen
				ORG	P:
FledOpen:
				movec   R2,X0
				cmp     #10,X0
				beq     _L3
				movei   #-1,Y0
				bra     _L22
_L3:
				andc    #-2,X:11b3
				orc     #1,X:11b2
				andc    #-2,X:11b1
				andc    #-3,X:11b3
				orc     #2,X:11b2
				andc    #-3,X:11b1
				andc    #-5,X:11b3
				orc     #4,X:11b2
				andc    #-5,X:11b1
				andc    #-9,X:11b3
				orc     #8,X:11b2
				andc    #-9,X:11b1
				andc    #-17,X:11b3
				orc     #16,X:11b2
				andc    #-17,X:11b1
				andc    #-33,X:11b3
				orc     #32,X:11b2
				andc    #-33,X:11b1
				movei   #0,Y0
_L22:
				rts     


				ORG	X:

				ENDSEC
				END

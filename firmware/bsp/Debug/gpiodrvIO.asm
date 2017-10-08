
				SECTION gpiodrvIO
				include "asmdef.h"
				GLOBAL FgpiodrvIOOpen
				ORG	P:
FgpiodrvIOOpen:
				movei   #4512,Y0
				movec   R2,X0
				cmp     X0,Y0
				beq     _L7
				movei   #4528,Y0
				movec   R2,X0
				cmp     X0,Y0
				beq     _L7
				movei   #4544,Y0
				movec   R2,X0
				cmp     X0,Y0
				beq     _L7
				movei   #4560,Y0
				movec   R2,X0
				cmp     X0,Y0
				beq     _L7
				movei   #4576,Y0
				movec   R2,X0
				cmp     X0,Y0
				beq     _L7
				movei   #4592,Y0
				movec   R2,X0
				cmp     X0,Y0
				bne     _L8
_L7:
				movei   #FgpiodrvIODevice,R2
				bra     _L9
_L8:
				movei   #65535,R2
_L9:
				rts     


				GLOBAL FgpiodrvIOClose
				ORG	P:
FgpiodrvIOClose:
				movei   #0,Y0
				rts     


				ORG	X:

				ENDSEC
				END

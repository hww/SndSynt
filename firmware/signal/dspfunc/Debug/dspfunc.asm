
				SECTION dspfunc
				include "asmdef.h"
				GLOBAL FdspfuncInitialize
				ORG	P:
FdspfuncInitialize:
				bfset   #16,OMR
				bfset   #32,OMR
				bfclr   #64,SR
				rts     


				GLOBAL Fimpyuu
				ORG	P:
Fimpyuu:
				push    OMR
				bfclr   #16,OMR
				bfset   #256,OMR
				move    Y0,X0
				andc    #32767,Y0
				mpysu   Y0,Y1,A
				tstw    X0
				bge     _L15
				movei   #32767,X0
				macsu   X0,Y1,A
				clr     B
				move    Y1,B0
				add     B,A
				add     B,A
				asr     A
				bge     _L18
				bfclr   #-32768,A1
				pop     OMR
				rts     


				GLOBAL Fimpysu
				ORG	P:
Fimpysu:
				mpysu   Y0,Y1,A
				asr     A
				rts     


				ORG	X:

				ENDSEC
				END

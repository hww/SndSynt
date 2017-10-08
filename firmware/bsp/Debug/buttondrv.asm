
				SECTION buttondrv
				include "asmdef.h"
				ORG	P:
FbuttonISR:
				movei   #9,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+4)
				beq     _L9
				movec   SP,R2
				lea     (R2-8)
				movei   #0,Y0
				jsr     Fclock_gettime
				movec   SP,R2
				lea     (R2-8)
				move    X:(SP),R3
				jsr     FtimespecGE
				tstw    Y0
				beq     _L9
				movei   #0,X:(SP-4)
				movei   #0,X:(SP-3)
				movei   #53632,X:(SP-2)
				movei   #2288,X0
				move    X0,X:(SP-1)
				movec   SP,R0
				lea     (R0-4)
				push    R0
				movec   SP,R3
				lea     (R3-9)
				move    X:(SP-1),R2
				jsr     FtimespecAdd
				pop     
				move    X:(SP),R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+5),R2
				movei   #_L9,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L9:
				lea     (SP-9)
				rts     


				GLOBAL FbuttonISRA
				ORG	P:
FbuttonISRA:
				movei   #FbuttondrvDeviceA,R2
				jsr     FbuttonISR
				rts     


				GLOBAL FbuttonISRB
				ORG	P:
FbuttonISRB:
				movei   #FbuttondrvDeviceB,R2
				jsr     FbuttonISR
				rts     


				GLOBAL FbuttonOpen
				ORG	P:
FbuttonOpen:
				moves   R2,X:<mr2
				movei   #39,X0
				cmp     X:<mr2,X0
				bne     _L5
				movei   #FbuttondrvDeviceA,R2
				bra     _L9
_L5:
				movei   #40,X0
				cmp     X:<mr2,X0
				bne     _L8
				movei   #FbuttondrvDeviceB,R2
				bra     _L9
_L8:
				movei   #-1,Y0
				bra     _L14
_L9:
				movei   #0,X:(R2)
				movei   #0,X:(R2+1)
				movei   #0,X:(R2+2)
				movei   #0,X:(R2+3)
				move    X:(R3),R0
				move    R0,X:(R2+4)
				move    X:(R3+1),R0
				move    R0,X:(R2+5)
				movec   R2,Y0
_L14:
				rts     


				GLOBAL FbuttonClose
				ORG	P:
FbuttonClose:
				movec   Y0,R2
				nop     
				movei   #0,X:(R2+4)
				movei   #0,Y0
				rts     


				ORG	X:
FbuttondrvDeviceADC			0,0,0,0,0,0
FbuttondrvDeviceBDC			0,0,0,0,0,0

				ENDSEC
				END

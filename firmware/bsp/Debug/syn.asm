
				SECTION syn
				include "asmdef.h"
				GLOBAL FSynSetVol
				ORG	P:
FSynSetVol:
				movei   #4,N
				lea     (SP)+N
				move    R3,X:(SP)
				move    Y0,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #0,A
				movei   #10000,A0
				cmp     A,B
				bgt     _L7
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+21)
				move    X:(SP),R2
				nop     
				move    X:(R2+18),R0
				clr     B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+19)
				bra     _L9
_L7:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+18)
				movei   #0,B
				movei   #10000,B0
				push    B0
				push    B1
				move    X:(SP-4),A
				move    X:(SP-5),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				push    A0
				push    A1
				clr     A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				movec   A0,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+21)
_L9:
				lea     (SP-4)
				rts     


				GLOBAL FSynSetPan
				ORG	P:
FSynSetPan:
				movec   R3,R2
				nop     
				move    Y0,X:(R2+22)
				rts     


				GLOBAL FSynSetPitch
				ORG	P:
FSynSetPitch:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #2,A
				cmp     A,B
				ble     _L5
				movec   R3,R2
				nop     
				movei   #0,X:(R2+10)
				movei   #2,X:(R2+11)
				bra     _L6
_L5:
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   R3,R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
_L6:
				lea     (SP-2)
				rts     


				GLOBAL FSynSetFXMix
				ORG	P:
FSynSetFXMix:
				movec   R3,R2
				nop     
				move    Y0,X:(R2+23)
				rts     


				GLOBAL FSynSetPriority
				ORG	P:
FSynSetPriority:
				movec   R3,R2
				nop     
				move    Y0,X:(R2+17)
				rts     


				GLOBAL FSynGetPriority
				ORG	P:
FSynGetPriority:
				movec   R3,R2
				nop     
				move    X:(R2+17),Y0
				rts     


				GLOBAL FSynStartVoice
				ORG	P:
FSynStartVoice:
				move    X:(SP-2),R0
				move    R0,X:(R3+12)
				move    X:(SP-2),R0
				move    X:(R0+5),X0
				orc     #16,X0
				move    X0,X:(R3)
				move    X:(SP-2),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				move    B1,X:(R3+3)
				move    B0,X:(R3+2)
				move    X:(R3),X0
				andc    #1,X0
				tstw    X0
				beq     _L9
				move    X:(SP-2),R0
				move    X:(R0+7),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				move    B1,X:(R3+7)
				move    B0,X:(R3+6)
				move    X:(R2+1),B
				move    X:(R2),B0
				move    X:(R2+3),A
				move    X:(R2+2),A0
				sub     B,A
				move    A1,X:(R3+9)
				move    A0,X:(R3+8)
				bra     _L10
_L9:
				move    X:(SP-2),R0
				move    X:(R0+3),B
				move    X:(R0+2),B0
				move    X:(SP-2),R0
				move    X:(R0+1),A
				move    X:(R0),A0
				add     A,B
				move    B1,X:(R3+7)
				move    B0,X:(R3+6)
_L10:
				rts     


				GLOBAL FSynStartVoiceParams
				ORG	P:
FSynStartVoiceParams:
				movei   #6,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    Y0,X:(SP-4)
				move    Y1,X:(SP-5)
				move    X:(SP-8),R0
				push    R0
				move    X:(SP-1),R2
				move    X:(SP-2),R3
				jsr     FSynStartVoice
				pop     
				move    X:(SP-9),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+23)
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FSynSetPitch
				move    X:(SP-5),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+22)
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-4),Y0
				move    X:(SP-10),A
				move    X:(SP-11),A0
				jsr     FSynSetVol
				lea     (SP-6)
				rts     


				GLOBAL FSynStopVoice
				ORG	P:
FSynStopVoice:
				movei   #0,X0
				move    X0,X:(R3)
				rts     


				ORG	X:

				ENDSEC
				END

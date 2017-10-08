
				SECTION volume
				include "asmdef.h"
				GLOBAL FSynSetVol
				ORG	P:
FSynSetVol:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
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
				movei   #0,X:(R2+36)
				movei   #0,X:(R2+37)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+38)
				movei   #0,X:(R2+39)
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+14)
				bra     _L9
_L7:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+35)
				move    B0,X:(R2+34)
				movei   #0,B
				movei   #10000,B0
				push    B0
				push    B1
				move    X:(SP-4),A
				move    X:(SP-5),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP),R2
				push    A0
				push    A1
				move    X:(R2+39),A
				move    X:(R2+38),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+37)
				move    A0,X:(R2+36)
_L9:
				lea     (SP-4)
				rts     


				GLOBAL FSyntEnvTimer
				ORG	P:
FSyntEnvTimer:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+35),B
				move    X:(R2+34),B0
				tst     B
				jle     _L27
				move    X:(SP),R2
				movei   #-1,B
				movei   #-10000,B0
				move    X:(R2+35),A
				move    X:(R2+34),A0
				add     A,B
				move    B1,X:(R2+35)
				move    B0,X:(R2+34)
				tst     B
				jgt     _L22
				move    X:(SP),R2
				nop     
				move    X:(R2+33),X0
				cmp     #2,X0
				beq     _L14
				bge     _L9
				cmp     #0,X0
				jeq     _L27
				bge     _L12
				jmp     _L27
_L9:
				cmp     #4,X0
				beq     _L19
				jge     _L27
				bra     _L16
_L12:
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R0
				move    X:(R0+7),Y0
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R0
				move    X:(R0+3),A
				move    X:(R0+2),A0
				move    X:(SP),R2
				jsr     FSynSetVol
				jmp     _L27
_L14:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+36)
				movei   #0,X:(R2+37)
				bra     _L27
_L16:
				move    X:(SP),R2
				nop     
				bftstl  #128,X:(R2+2)
				bhs     _L27
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R0
				move    X:(R0+5),A
				move    X:(R0+4),A0
				move    X:(SP),R2
				movei   #0,Y0
				jsr     FSynSetVol
				bra     _L27
_L19:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+33)
				move    X:(SP),R2
				movei   #0,Y0
				clr     A
				jsr     FSynSetVol
				bra     _L27
_L22:
				move    X:(SP),R2
				move    X:(SP),R0
				move    X:(R0+37),B
				move    X:(R0+36),B0
				move    X:(R2+39),A
				move    X:(R2+38),A0
				add     A,B
				move    B1,X:(R2+39)
				move    B0,X:(R2+38)
				tst     B
				bge     _L25
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+38)
				movei   #0,X:(R2+39)
				bra     _L27
_L25:
				move    X:(SP),R2
				nop     
				move    X:(R2+39),B
				move    X:(R2+38),B0
				tst     B
				ble     _L27
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+38)
				movei   #0,X:(R2+39)
_L27:
				lea     (SP)-
				rts     


				GLOBAL FSynEnvStart
				ORG	P:
FSynEnvStart:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+38)
				movei   #0,X:(R2+39)
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+33)
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R0
				move    X:(R0+6),Y0
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R0
				move    X:(R0+1),A
				move    X:(R0),A0
				move    X:(SP),R2
				jsr     FSynSetVol
				lea     (SP)-
				rts     


				GLOBAL FSynSetPan
				ORG	P:
FSynSetPan:
				move    Y0,X:(R2+15)
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
				move    B1,X:(R2+41)
				move    B0,X:(R2+40)
				lea     (SP-2)
				rts     


				GLOBAL FSynSetFXMix
				ORG	P:
FSynSetFXMix:
				move    Y0,X:(R2+42)
				rts     


				GLOBAL FSynSetPriority
				ORG	P:
FSynSetPriority:
				move    Y0,X:(R2+24)
				rts     


				GLOBAL FSynGetPriority
				ORG	P:
FSynGetPriority:
				move    X:(R2+24),Y0
				rts     


				ORG	X:

				ENDSEC
				END

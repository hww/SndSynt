
				SECTION vfr16
				include "asmdef.h"
				GLOBAL Fvfr16DotProdC
				ORG	P:
Fvfr16DotProdC:
				movei   #2,N
				lea     (SP)+N
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   #0,X:<mr2
				bra     _L8
_L6:
				moves   X:<mr2,N
				move    X:(R2+N),Y1
				moves   X:<mr2,N
				move    X:(R3+N),B1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				inc     X:<mr2
_L8:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L6
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-2)
				rts     


				GLOBAL Fvfr16LengthC
				ORG	P:
Fvfr16LengthC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   Y0,X:<mr9
				movei   #32767,X0
				cmp     X:<mr9,X0
				bhs     _L4
				debug   
_L4:
				movei   #0,X:(SP-2)
				movei   #0,X0
				move    X0,X:(SP-1)
				moves   #0,X:<mr8
				bra     _L9
_L7:
				move    X:(SP),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				move    X:(SP),R0
				moves   X:<mr8,N
				move    X:(R0+N),X0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				mac     Y0,X0,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				inc     X:<mr8
_L9:
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blo     _L7
				move    X:(SP-1),A
				move    X:(SP-2),A0
				jsr     Fmfr32Sqrt
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fvfr16MultC
				ORG	P:
Fvfr16MultC:
				moves   Y1,X:<mr3
				movei   #32767,X0
				cmp     X:<mr3,X0
				bhs     _L4
				debug   
_L4:
				moves   #0,X:<mr2
				bra     _L8
_L6:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				mpy     X0,Y0,B
				movec   B1,X0
				moves   X:<mr2,N
				move    X0,X:(R3+N)
				inc     X:<mr2
_L8:
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blo     _L6
				rts     


				GLOBAL Fvfr16ScaleC
				ORG	P:
Fvfr16ScaleC:
				moves   Y1,X:<mr3
				movei   #32767,X0
				cmp     X:<mr3,X0
				bhs     _L4
				debug   
_L4:
				moves   #0,X:<mr2
				bra     _L17
_L6:
				moves   X:<mr2,N
				move    X:(R2+N),B
				movec   Y0,A
				tstw    A
				beq     _L15
				movei   #16,X0
				blt     _L12
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L9:
				tstw    (R0)-
				beq     _L15
				asl     B
				bra     _L9
_L12:
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L13:
				tstw    (R0)-
				beq     _L15
				asr     B
				bra     _L13
_L15:
				movec   B1,X0
				moves   X:<mr2,N
				move    X0,X:(R3+N)
				inc     X:<mr2
_L17:
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blo     _L6
				rts     


				ORG	X:

				ENDSEC
				END

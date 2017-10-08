
				SECTION afr32
				include "asmdef.h"
				GLOBAL Fafr32AbsC
				ORG	P:
Fafr32AbsC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				abs     B
				move    B1,X:(R3+1)
				move    B0,X:(R3)
				lea     (R3)+
				lea     (R3)+
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32AddC
				ORG	P:
Fafr32AddC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    X:(R3+1),A
				move    X:(R3),A0
				lea     (R3)+
				lea     (R3)+
				add     B,A
				move    X:(SP-2),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-2)
				move    A1,X:(R0+1)
				move    A0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32DivC
				ORG	P:
Fafr32DivC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L9
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    X:(R3),X0
				lea     (R3)+
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X0,X:(R0)
				inc     X:<mr2
_L9:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32EqualC
				ORG	P:
Fafr32EqualC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L8
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    X:(R3+1),A
				move    X:(R3),A0
				lea     (R3)+
				lea     (R3)+
				cmp     A,B
				beq     _L7
				movei   #0,Y0
				bra     _L10
_L7:
				inc     X:<mr2
_L8:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				movei   #1,Y0
_L10:
				rts     


				GLOBAL Fafr32MacC
				ORG	P:
Fafr32MacC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R3),Y1
				lea     (R3)+
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X:(R0),B1
				move    X:(R2+1),A
				move    X:(R2),A0
				lea     (R2+2)
				mac     Y1,B1,A
				move    X:(SP-3),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-3)
				move    A1,X:(R0+1)
				move    A0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32Mac_rC
				ORG	P:
Fafr32Mac_rC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R3),Y1
				lea     (R3)+
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X:(R0),B1
				move    X:(R2+1),A
				move    X:(R2),A0
				lea     (R2+2)
				macr    Y1,B1,A
				movec   A1,X0
				movec   X:(SP-3),R0
				inc     X:(SP-3)
				move    X0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32MaxC
				ORG	P:
Fafr32MaxC:
				movei   #2,N
				lea     (SP)+N
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				tstw    Y0
				bne     _L5
				debug   
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   #0,X:<mr3
				moves   #1,X:<mr2
				bra     _L14
_L9:
				move    X:(R2+1),B
				move    X:(R2),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				cmp     A,B
				ble     _L12
				move    X:(R2+1),B
				move    X:(R2),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr2,X0
				move    X0,X:<mr3
_L12:
				movec   R2,X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				inc     X:<mr2
_L14:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L9
				tstw    R3
				beq     _L17
				moves   X:<mr3,X0
				move    X0,X:(R3)
_L17:
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-2)
				rts     


				GLOBAL Fafr32MinC
				ORG	P:
Fafr32MinC:
				movei   #2,N
				lea     (SP)+N
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				tstw    Y0
				bne     _L5
				debug   
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   #0,X:<mr3
				moves   #1,X:<mr2
				bra     _L14
_L9:
				move    X:(R2+1),B
				move    X:(R2),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				cmp     A,B
				bge     _L12
				move    X:(R2+1),B
				move    X:(R2),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr2,X0
				move    X0,X:<mr3
_L12:
				movec   R2,X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				inc     X:<mr2
_L14:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L9
				tstw    R3
				beq     _L17
				moves   X:<mr3,X0
				move    X0,X:(R3)
_L17:
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-2)
				rts     


				GLOBAL Fafr32MsuC
				ORG	P:
Fafr32MsuC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R3),Y1
				lea     (R3)+
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X:(R0),B1
				move    X:(R2+1),A
				move    X:(R2),A0
				lea     (R2+2)
				mac     -Y1,B1,A
				move    X:(SP-3),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-3)
				move    A1,X:(R0+1)
				move    A0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32Msu_rC
				ORG	P:
Fafr32Msu_rC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R3),Y1
				lea     (R3)+
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X:(R0),B1
				move    X:(R2+1),A
				move    X:(R2),A0
				lea     (R2+2)
				macr    -Y1,B1,A
				movec   A1,X0
				movec   X:(SP-3),R0
				inc     X:(SP-3)
				move    X0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32MultC
				ORG	P:
Fafr32MultC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2),X0
				lea     (R2)+
				move    X:(R3),Y1
				lea     (R3)+
				mpy     Y1,X0,B
				move    X:(SP-2),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-2)
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32Mult_lsC
				ORG	P:
Fafr32Mult_lsC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R3),X0
				lea     (R3)+
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				movec   B1,Y1
				movec   B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    X:(SP-2),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-2)
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32NegateC
				ORG	P:
Fafr32NegateC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				neg     B
				move    B1,X:(R3+1)
				move    B0,X:(R3)
				lea     (R3)+
				lea     (R3)+
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32RoundC
				ORG	P:
Fafr32RoundC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				rnd     B
				move    B,X:(R3)
				lea     (R3)+
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr32SqrtC
				ORG	P:
Fafr32SqrtC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr9
				movei   #32767,X0
				cmp     X:<mr9,X0
				bhs     _L4
				debug   
_L4:
				moves   #0,X:<mr8
				bra     _L8
_L6:
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP)
				move    X:(R0+1),A
				move    X:(R0),A0
				jsr     Fmfr32Sqrt
				movec   X:(SP-1),R0
				inc     X:(SP-1)
				move    Y0,X:(R0)
				inc     X:<mr8
_L8:
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blo     _L6
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fafr32SubC
				ORG	P:
Fafr32SubC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				move    X:(R2+1),B
				move    X:(R2),B0
				lea     (R2+2)
				move    X:(R3+1),A
				move    X:(R3),A0
				lea     (R3)+
				lea     (R3)+
				sub     A,B
				move    X:(SP-2),R1
				movec   R1,R0
				lea     (R1)+
				lea     (R1)+
				move    R1,X:(SP-2)
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				ORG	X:

				ENDSEC
				END

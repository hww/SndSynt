
				SECTION afr16
				include "asmdef.h"
				GLOBAL Fafr16AbsC
				ORG	P:
Fafr16AbsC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),B
				abs     B
				moves   X:<mr2,N
				move    B1,X:(R3+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16AddC
				ORG	P:
Fafr16AddC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),Y1
				moves   X:<mr2,N
				move    X:(R3+N),X0
				add     Y1,X0
				move    X:(SP-2),R0
				moves   X:<mr2,N
				move    X0,X:(R0+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16DivC
				ORG	P:
Fafr16DivC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L9
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),B
				moves   X:<mr2,N
				move    X:(R3+N),X0
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
				move    X:(SP-2),R0
				moves   X:<mr2,N
				move    X0,X:(R0+N)
				inc     X:<mr2
_L9:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16EqualC
				ORG	P:
Fafr16EqualC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L8
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				moves   X:<mr2,N
				move    X:(R3+N),Y1
				cmp     Y1,X0
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


				GLOBAL Fafr16Mac_rC
				ORG	P:
Fafr16Mac_rC:
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
				move    X:(SP),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-1),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R0
				moves   X:<mr8,N
				move    X:(R0+N),X0
				macr    Y0,X0,A
				movec   A1,X0
				move    X:(SP-7),R0
				moves   X:<mr8,N
				move    X0,X:(R0+N)
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


				GLOBAL Fafr16MaxC
				ORG	P:
Fafr16MaxC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				tstw    Y0
				bne     _L5
				debug   
_L5:
				move    X:(R2),X0
				move    X0,X:<mr3
				moves   #0,X:<mr4
				moves   #1,X:<mr2
				bra     _L13
_L9:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				cmp     X:<mr3,X0
				ble     _L12
				moves   X:<mr2,N
				move    X:(R2+N),X0
				move    X0,X:<mr3
				moves   X:<mr2,X0
				move    X0,X:<mr4
_L12:
				inc     X:<mr2
_L13:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L9
				tstw    R3
				beq     _L16
				moves   X:<mr4,X0
				move    X0,X:(R3)
_L16:
				moves   X:<mr3,Y0
				rts     


				GLOBAL Fafr16MinC
				ORG	P:
Fafr16MinC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				tstw    Y0
				bne     _L5
				debug   
_L5:
				move    X:(R2),X0
				move    X0,X:<mr3
				moves   #0,X:<mr4
				moves   #1,X:<mr2
				bra     _L13
_L9:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				cmp     X:<mr3,X0
				bge     _L12
				moves   X:<mr2,N
				move    X:(R2+N),X0
				move    X0,X:<mr3
				moves   X:<mr2,X0
				move    X0,X:<mr4
_L12:
				inc     X:<mr2
_L13:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L9
				tstw    R3
				beq     _L16
				moves   X:<mr4,X0
				move    X0,X:(R3)
_L16:
				moves   X:<mr3,Y0
				rts     


				GLOBAL Fafr16Msu_rC
				ORG	P:
Fafr16Msu_rC:
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
				move    X:(SP),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-1),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R0
				moves   X:<mr8,N
				move    X:(R0+N),X0
				macr    -Y0,X0,A
				movec   A1,X0
				move    X:(SP-7),R0
				moves   X:<mr8,N
				move    X0,X:(R0+N)
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


				GLOBAL Fafr16MultC
				ORG	P:
Fafr16MultC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				moves   X:<mr2,N
				move    X:(R3+N),Y1
				mpy     Y1,X0,B
				movec   B1,X0
				move    X:(SP-2),R0
				moves   X:<mr2,N
				move    X0,X:(R0+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16Mult_rC
				ORG	P:
Fafr16Mult_rC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				moves   X:<mr2,N
				move    X:(R3+N),Y1
				mpyr    Y1,X0,B
				movec   B1,X0
				move    X:(SP-2),R0
				moves   X:<mr2,N
				move    X0,X:(R0+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16NegateC
				ORG	P:
Fafr16NegateC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),B
				neg     B
				moves   X:<mr2,N
				move    B,X:(R3+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				GLOBAL Fafr16RandC
				ORG	P:
Fafr16RandC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				move    R2,X:(SP)
				moves   Y0,X:<mr9
				movei   #32767,X0
				cmp     X:<mr9,X0
				bhs     _L4
				debug   
_L4:
				moves   #0,X:<mr8
				bra     _L8
_L6:
				jsr     Fmfr16Rand
				move    X:(SP),R0
				moves   X:<mr8,N
				move    Y0,X:(R0+N)
				inc     X:<mr8
_L8:
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blo     _L6
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fafr16SqrtC
				ORG	P:
Fafr16SqrtC:
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
				move    X:(SP),R0
				moves   X:<mr8,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				jsr     Fmfr32Sqrt
				move    X:(SP-1),R0
				moves   X:<mr8,N
				move    Y0,X:(R0+N)
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


				GLOBAL Fafr16SubC
				ORG	P:
Fafr16SubC:
				cmp     #32767,Y0
				bls     _L3
				debug   
_L3:
				moves   #0,X:<mr2
				bra     _L7
_L5:
				moves   X:<mr2,N
				move    X:(R2+N),X0
				moves   X:<mr2,N
				move    X:(R3+N),Y1
				sub     Y1,X0
				move    X:(SP-2),R0
				moves   X:<mr2,N
				move    X0,X:(R0+N)
				inc     X:<mr2
_L7:
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
				rts     


				ORG	X:

				ENDSEC
				END

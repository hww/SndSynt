
				SECTION xfr16
				include "asmdef.h"
				GLOBAL Fxfr16MultC
				ORG	P:
Fxfr16MultC:
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr5
				moves   Y1,X:<mr3
				moves   R3,X:<mr6
				moves   #0,X:<mr7
				moves   X:<mr7,X0
				cmp     Y0,X0
				bge     _L22
_L4:
				moves   #0,X:<mr4
				moves   X:<mr4,X0
				cmp     X:(SP-4),X0
				bge     _L19
_L6:
				moves   X:<mr5,R2
				moves   X:<mr4,X0
				add     X:<mr6,X0
				movec   X0,R3
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				bge     _L16
_L11:
				move    X:(R3),B1
				move    X:(R2),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				lea     (R2)+
				movec   R3,X0
				add     X:(SP-4),X0
				movec   X0,R3
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blt     _L11
_L16:
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				movec   X:(SP-5),R0
				inc     X:(SP-5)
				move    B,X:(R0)
				inc     X:<mr4
				moves   X:<mr4,X0
				cmp     X:(SP-4),X0
				blt     _L6
_L19:
				moves   X:<mr3,X0
				add     X:<mr5,X0
				move    X0,X:<mr5
				inc     X:<mr7
				moves   X:<mr7,X0
				cmp     Y0,X0
				blt     _L4
_L22:
				lea     (SP-2)
				rts     


				GLOBAL Fxfr16TransC
				ORG	P:
Fxfr16TransC:
				moves   Y1,X:<mr3
				moves   R3,X:<mr5
				moves   #0,X:<mr4
				moves   X:<mr4,X0
				cmp     Y0,X0
				bge     _L13
_L4:
				moves   X:<mr5,R0
				inc     X:<mr5
				movec   R0,R3
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				bge     _L11
_L7:
				move    X:(R2),X0
				lea     (R2)+
				move    X0,X:(R3)
				movec   R3,X0
				add     Y0,X0
				movec   X0,R3
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blt     _L7
_L11:
				inc     X:<mr4
				moves   X:<mr4,X0
				cmp     Y0,X0
				blt     _L4
_L13:
				rts     


				GLOBAL Fxfr16InvC
				ORG	P:
Fxfr16InvC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #6,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   Y0,X:<mr9
				moves   R3,X:<mr8
				move    X:(SP),R2
				moves   X:<mr9,Y0
				jsr     Fxfr16Det
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				tst     B
				bne     _L5
				clr     A
				jmp     _L52
_L5:
				moves   X:<mr9,X0
				cmp     #3,X0
				beq     _L16
				cmp     #2,X0
				jne     _L51
_L8:
				move    X:(SP),X0
				add     #3,X0
				move    X0,X:(SP)
				move    X:(SP),R0
				moves   X:<mr8,R1
				inc     X:<mr8
				move    X:(R0),X0
				move    X0,X:(R1)
				move    X:(SP),X0
				sub     #2,X0
				move    X0,X:(SP)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				move    X:(R0),B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP),R0
				nop     
				move    X:(R0),B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP),X0
				sub     #2,X0
				move    X0,X:(SP)
				move    X:(SP),R0
				moves   X:<mr8,R1
				move    X:(R0),X0
				move    X0,X:(R1)
				jmp     _L51
_L16:
				move    X:(SP),X0
				add     #4,X0
				move    X0,X:(SP)
				move    X:(SP),X0
				add     #4,X0
				move    X0,X:(SP-1)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R0
				movec   X:(SP-1),R1
				inc     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				inc     X:<mr8
				move    X0,X:(R0)
				move    X:(SP),X0
				sub     #4,X0
				move    X0,X:(SP)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)-
				move    R1,X:(SP)
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				movec   X0,B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP-1),X0
				sub     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R0
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				inc     X:<mr8
				move    X0,X:(R0)
				move    X:(SP),X0
				add     #6,X0
				move    X0,X:(SP)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),X0
				sub     #2,X0
				move    X0,X:(SP)
				move    X:(SP-1),X0
				add     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				movec   X0,B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP),X0
				add     #2,X0
				move    X0,X:(SP)
				move    X:(SP-1),X0
				sub     #5,X0
				move    X0,X:(SP-1)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),X0
				sub     #2,X0
				move    X0,X:(SP)
				move    X:(SP-1),X0
				add     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)-
				move    R1,X:(SP)
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				inc     X:<mr8
				move    X0,X:(R0)
				move    X:(SP-1),X0
				sub     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),X0
				sub     #2,X0
				move    X0,X:(SP)
				move    X:(SP-1),X0
				add     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				movec   X0,B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP-1),X0
				add     #5,X0
				move    X0,X:(SP-1)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R0
				movec   X:(SP-1),R1
				inc     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				inc     X:<mr8
				move    X0,X:(R0)
				move    X:(SP),X0
				sub     #4,X0
				move    X0,X:(SP)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)-
				move    R1,X:(SP)
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				movec   X0,B
				neg     B
				moves   X:<mr8,R0
				inc     X:<mr8
				move    B,X:(R0)
				move    X:(SP-1),X0
				sub     #2,X0
				move    X0,X:(SP-1)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				movec   X:(SP-1),R1
				dec     X:(SP-1)
				move    X:(R1),Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),R0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0),X0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				macr    -Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				inc     X:<mr8
				move    X0,X:(R0)
_L51:
				move    X:(SP-4),A
				move    X:(SP-5),A0
_L52:
				lea     (SP-6)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fxfr16DetC
				ORG	P:
Fxfr16DetC:
				movei   #4,N
				lea     (SP)+N
				cmp     #3,Y0
				ble     _L3
				debug   
_L3:
				cmp     #2,Y0
				bge     _L5
				debug   
_L5:
				cmp     #3,Y0
				beq     _L12
				cmp     #2,Y0
				jne     _L35
_L8:
				movec   R2,X0
				movec   X0,R3
				lea     (R3+3)
				move    X:(R2),Y1
				lea     (R2)+
				move    X:(R3),X0
				lea     (R3)-
				mpy     X0,Y1,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(R3),B1
				move    X:(R2),Y1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				mac     -Y1,B1,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				jmp     _L35
_L12:
				movec   R2,X0
				movec   X0,R3
				lea     (R3+4)
				movec   R3,X0
				add     #4,X0
				move    X0,X:<mr2
				move    X:(R2),Y1
				lea     (R2)+
				move    X:(R3),X0
				lea     (R3)+
				mpy     X0,Y1,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				moves   X:<mr2,R0
				nop     
				move    X:(R0),X0
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				moves   X:<mr2,X0
				sub     #2,X0
				move    X0,X:<mr2
				move    X:(R2),Y1
				lea     (R2)+
				move    X:(R3),X0
				mpy     X0,Y1,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				movec   R3,X0
				movec   X0,R3
				lea     (R3-2)
				moves   X:<mr2,R0
				inc     X:<mr2
				move    X:(R0),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(R3),Y1
				lea     (R3)+
				move    X:(R2),X0
				mpy     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr2,R0
				dec     X:<mr2
				move    X:(R0),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(R3),Y1
				lea     (R3)+
				move    X:(R2),X0
				mpy     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				movec   R2,X0
				movec   X0,R2
				lea     (R2-2)
				moves   X:<mr2,R0
				inc     X:<mr2
				move    X:(R0),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(R2),Y1
				lea     (R2)+
				move    X:(R3),X0
				mpy     X0,Y1,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				movec   R3,X0
				movec   X0,R3
				lea     (R3-2)
				moves   X:<mr2,R0
				inc     X:<mr2
				move    X:(R0),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(R3),Y1
				move    X:(R2),X0
				mpy     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr2,R0
				nop     
				move    X:(R0),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
_L35:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				ORG	X:

				ENDSEC
				END

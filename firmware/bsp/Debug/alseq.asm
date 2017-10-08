
				SECTION alseq
				include "asmdef.h"
				GLOBAL FalSeqGetDeltaTime
				ORG	P:
FalSeqGetDeltaTime:
				move    X:<mr8,N
				push    N
				movei   #5,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				jsr     FalSeqGet8
				clr     B
				movec   Y0,B0
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				movei   #0,A
				movei   #128,A0
				movec   B1,Y1
				movec   B0,Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				beq     _L6
				andc    #0,X:(SP-1)
				andc    #127,X:(SP-2)
_L4:
				move    X:(SP),R2
				jsr     FalSeqGet8
				move    Y0,X:<mr8
				andc    #127,Y0
				clr     B
				movec   Y0,B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				asl     B
				asl     B
				asl     B
				asl     B
				asl     B
				asl     B
				asl     B
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     B,A
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				bftstl  #128,X:<mr8
				bhs     _L4
_L6:
				move    X:(SP-1),A
				move    X:(SP-2),A0
				lea     (SP-5)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqNew
				ORG	P:
FalSeqNew:
				movei   #7,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				move    X:(SP),R0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				movei   #0,B
				movei   #4,B0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     A,B
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				movec   SP,R2
				lea     (R2-4)
				jsr     FalSeqGet32
				move    A1,X:(SP-5)
				move    A0,X:(SP-6)
				movei   #0,B
				movei   #4,B0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     A,B
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				movec   SP,R2
				lea     (R2-4)
				jsr     FalSeqGet16
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+12)
				movei   #-1,B
				movei   #-2,B0
				move    X:(SP-5),A
				move    X:(SP-6),A0
				add     A,B
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     A,B
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				movec   SP,R2
				lea     (R2-4)
				jsr     FalSeqGet32
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+9)
				move    A0,X:(R2+8)
				move    X:(SP-3),B
				move    X:(SP-4),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				move    X:(SP),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+6)
				movei   #0,X:(R2+7)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+13)
				lea     (SP-7)
				rts     


				GLOBAL FalSeqNextEvent
				ORG	P:
FalSeqNextEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #4,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    R3,X:(SP)
				moves   X:<mr9,X0
				add     #4,X0
				move    X0,X:(SP-1)
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+1)
				movei   #0,X:(R2+2)
_L5:
				moves   X:<mr9,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				jsr     FalSeqGetDeltaTime
				move    X:(SP-2),B
				move    X:(SP-3),B0
				add     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    Y0,X:<mr8
				movei   #127,X0
				cmp     X:<mr8,X0
				bhs     _L12
				moves   X:<mr8,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr8,X0
				moves   X:<mr9,R2
				nop     
				move    X0,X:(R2+13)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+4)
				bra     _L14
_L12:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+13),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr8,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+4)
_L14:
				move    X:(SP),R2
				nop     
				move    X:(R2+3),X0
				andc    #240,X0
				move    X0,X:<mr10
				moves   X:<mr10,X0
				cmp     #240,X0
				beq     _L21
				cmp     #208,X0
				beq     _L19
				cmp     #192,X0
				jne     _L42
_L19:
				move    X:(SP),R0
				movei   #2,X0
				move    X0,X:(R0)
				jmp     _L44
_L21:
				move    X:(SP),R2
				nop     
				move    X:(R2+3),X0
				move    X0,X:<mr10
				moves   X:<mr10,X0
				cmp     #255,X0
				bne     _L39
_L24:
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+5)
				moves   X:<mr8,X0
				cmp     #47,X0
				beq     _L34
				cmp     #81,X0
				bne     _L36
_L29:
				move    X:(SP),R0
				movei   #4,X0
				move    X0,X:(R0)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+6)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+7)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+8)
				bra     _L44
_L34:
				move    X:(SP),R0
				movei   #6,X0
				move    X0,X:(R0)
				bra     _L44
_L36:
				move    X:(SP),R0
				movei   #1,X0
				move    X0,X:(R0)
				move    X:(SP-1),R0
				move    X:(SP),R2
				clr     B
				move    X:(R2+5),B0
				move    X:(R0+1),A
				move    X:(R0),A0
				add     A,B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				bra     _L44
_L39:
				move    X:(SP),R0
				movei   #1,X0
				move    X0,X:(R0)
				move    X:(SP-1),R0
				move    X:(SP),R2
				clr     B
				move    X:(R2+4),B0
				move    X:(R0+1),A
				move    X:(R0),A0
				add     A,B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				bra     _L44
_L42:
				move    X:(SP),R0
				movei   #2,X0
				move    X0,X:(R0)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+5)
_L44:
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				jeq     _L5
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+2)
				move    B0,X:(R2+1)
				moves   X:<mr9,R2
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    X:(R2+7),A
				move    X:(R2+6),A0
				add     A,B
				move    B1,X:(R2+7)
				move    B0,X:(R2+6)
				lea     (SP-4)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqGetTicks
				ORG	P:
FalSeqGetTicks:
				move    X:(R2+7),A
				move    X:(R2+6),A0
				rts     


				GLOBAL FalSeqTicksToSec
				ORG	P:
FalSeqTicksToSec:
				rts     


				GLOBAL FalSeqSecToTicks
				ORG	P:
FalSeqSecToTicks:
				rts     


				GLOBAL FalSeqNewMarker
				ORG	P:
FalSeqNewMarker:
				movei   #31,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				move    B1,X:(SP-29)
				move    B0,X:(SP-30)
				movei   #0,X:(SP-28)
				movei   #0,X:(SP-27)
				movei   #0,X:(SP-11)
				movei   #0,X:(SP-10)
				movei   #0,X:(SP-4)
				move    X:(SP),R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(SP-12)
				move    B0,X:(SP-13)
				bra     _L9
_L8:
				movec   SP,R2
				lea     (R2-17)
				movec   SP,R3
				lea     (R3-26)
				jsr     FalSeqNextEvent
_L9:
				move    X:(SP-10),B
				move    X:(SP-11),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     A,B
				blo     _L8
				movec   SP,R2
				move    X:(SP-1),R3
				jsr     FalSeqGetLoc
				lea     (SP-31)
				rts     


				GLOBAL FalSeqSetLoc
				ORG	P:
FalSeqSetLoc:
				move    X:(R3+1),B
				move    X:(R3),B0
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(R3+3),B
				move    X:(R3+2),B0
				move    B1,X:(R2+7)
				move    B0,X:(R2+6)
				move    X:(R3+6),X0
				move    X0,X:(R2+13)
				rts     


				GLOBAL FalSeqGetLoc
				ORG	P:
FalSeqGetLoc:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-1),R0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				move    X:(SP),R2
				nop     
				move    X:(R2+7),B
				move    X:(R2+6),B0
				move    X:(SP-1),R2
				nop     
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				movec   SP,R2
				lea     (R2-3)
				jsr     FalSeqGetDeltaTime
				move    X:(SP),R2
				nop     
				move    X:(R2+7),B
				move    X:(R2+6),B0
				add     B,A
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+5)
				move    A0,X:(R2+4)
				move    X:(SP),R2
				nop     
				move    X:(R2+13),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+6)
				lea     (SP-4)
				rts     


				ORG	X:

				ENDSEC
				END

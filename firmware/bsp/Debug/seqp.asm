
				SECTION seqp
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
				jne     _L41
_L19:
				move    X:(SP),R0
				movei   #2,X0
				move    X0,X:(R0)
				jmp     _L43
_L21:
				move    X:(SP),R2
				nop     
				move    X:(R2+3),X0
				move    X0,X:<mr10
				moves   X:<mr10,X0
				cmp     #255,X0
				bne     _L38
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
				bne     _L35
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
				bra     _L43
_L34:
				move    X:(SP),R0
				movei   #5,X0
				move    X0,X:(R0)
_L35:
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
				bra     _L43
_L38:
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
				bra     _L43
_L41:
				move    X:(SP),R0
				movei   #2,X0
				move    X0,X:(R0)
				move    X:(SP-1),R2
				jsr     FalSeqGet8
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+5)
_L43:
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


				GLOBAL FalCents2Ratio
				ORG	P:
FalCents2Ratio:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   B0,Y1
				movei   #60,Y0
				jsr     FalGetLinearRate
				lea     (SP-2)
				rts     


				ORG	P:
FalGetLinearRate:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #6,N
				lea     (SP)+N
				moves   Y0,X:<mr10
				moves   Y1,X:<mr11
				moves   X:<mr11,X0
				add     #1200,X0
				move    X0,X:<mr11
				move    X:<mr11,B
				movec   B1,B0
				movec   B2,B1
				asl     B
				movei   #100,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L5
				neg     B
_L5:
				movec   B0,X0
				move    X0,X:(SP-2)
				movei   #100,Y1
				moves   X:<mr11,Y0
				jsr     ARTREMS16Z
				move    Y0,X:<mr9
				moves   X:<mr10,Y0
				move    X:(SP-2),X0
				add     Y0,X0
				sub     #12,X0
				move    X0,X:<mr10
				movei   #12,Y1
				moves   X:<mr10,Y0
				jsr     ARTREMU16Z
				move    Y0,X:(SP-3)
				movei   #12,Y1
				moves   X:<mr10,Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:<mr8
				move    X:(SP-3),X0
				lsl     X0
				movec   X0,R0
				move    X:(R0+#Fratestable+1),B
				move    X:(R0+#Fratestable),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				tstw    X:<mr9
				beq     _L15
				movei   #100,X0
				sub     X:<mr9,X0
				clr     B
				movec   X0,B0
				push    B0
				push    B1
				move    X:(SP-6),A
				move    X:(SP-7),A0
				jsr     ARTMPYU32U
				pop     
				pop     
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				clr     B
				moves   X:<mr9,X0
				move    X0,B0
				push    B0
				push    B1
				move    X:(SP-5),X0
				lsl     X0
				movei   #Fratestable+2,R0
				movec   X0,N
				lea     (R0)+N
				move    X:(R0+1),A
				move    X:(R0),A0
				jsr     ARTMPYU32U
				pop     
				pop     
				move    X:(SP-4),B
				move    X:(SP-5),B0
				add     B,A
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				movei   #0,B
				movei   #100,B0
				push    B0
				push    B1
				move    X:(SP-6),A
				move    X:(SP-7),A0
				jsr     ARTDIVU32UZ
				pop     
				pop     
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
_L15:
				moves   X:<mr8,X0
				cmp     #9,X0
				bhs     _L22
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr8,X0
				cmp     #9,X0
				bhs     _L21
_L18:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,B2
				asr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #9,X0
				blo     _L18
_L21:
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
_L22:
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpNew
				ORG	P:
FalSeqpNew:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				nop     
				movei   #32767,X:(R2+13)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+16)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+2)
				movei   #0,X:(R2+3)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+8)
				movei   #0,X:(R2+9)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+40)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+41)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+8),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+42)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+15)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+14)
				moves   X:<mr9,Y0
				movei   #12,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+34)
				move    X:(SP-1),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				movec   B0,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				movei   #36,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+35)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+36)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+37)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+38)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+39)
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				bge     _L26
				movei   #36,Y0
				moves   X:<mr8,X0
				impy    Y0,X0,X0
				move    X0,X:<mr10
_L22:
				move    X:(SP),R2
				moves   X:<mr10,Y0
				move    X:(R2+35),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+38)
				jsr     FalLink
				moves   X:<mr10,X0
				add     #36,X0
				move    X0,X:<mr10
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blt     _L22
_L26:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+12)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				movec   B0,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				movei   #13,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+25)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				move    X:(SP),R0
				move    X:(R0+25),R3
				move    X:<mr9,B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				jsr     FalEvtqNew
				move    X:(SP),R0
				move    X:FalGlobals,R1
				move    R1,X:(R0)
				movei   #FalSeqpHandler,R0
				move    X:(SP),R1
				nop     
				move    X:(R1),R2
				nop     
				move    R0,X:(R2+7)
				move    X:(SP),R0
				move    X:(SP),R1
				nop     
				move    X:(R1),R2
				nop     
				move    R0,X:(R2+6)
				jsr     FmidiOpen
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpDelete
				ORG	P:
FalSeqpDelete:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+34),R2
				jsr     FmemFreeEM
				move    X:(SP),R2
				nop     
				move    X:(R2+35),R2
				jsr     FmemFreeEM
				move    X:(SP),R2
				nop     
				move    X:(R2+25),R2
				jsr     FmemFreeEM
				jsr     FmidiClose
				lea     (SP)-
				rts     


				GLOBAL FalSeqpSetSeq
				ORG	P:
FalSeqpSetSeq:
				move    R3,X:(R2+1)
				rts     


				GLOBAL FalSeqpGetSeq
				ORG	P:
FalSeqpGetSeq:
				move    X:(R2+1),R2
				rts     


				GLOBAL FalSeqpPlay
				ORG	P:
FalSeqpPlay:
				movei   #10,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+10)
				movei   #0,X:(R2+11)
				movei   #17,X:(SP-9)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movec   SP,R3
				lea     (R3-9)
				clr     A
				jsr     FalEvtqPostEvent
				lea     (SP-10)
				rts     


				GLOBAL FalSeqpStop
				ORG	P:
FalSeqpStop:
				movei   #0,X:(R2+10)
				movei   #0,X:(R2+11)
				rts     


				GLOBAL FalSeqpGetState
				ORG	P:
FalSeqpGetState:
				move    X:(R2+11),A
				move    X:(R2+10),A0
				rts     


				GLOBAL FalSeqpSetBank
				ORG	P:
FalSeqpSetBank:
				move    R3,X:(R2+4)
				rts     


				GLOBAL FalSeqpSetTempo
				ORG	P:
FalSeqpSetTempo:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+12),B
				movec   B1,B0
				movec   B2,B1
				push    B0
				push    B1
				move    X:(SP-3),A
				move    X:(SP-4),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+7)
				move    A0,X:(R2+6)
				lea     (SP-3)
				rts     


				GLOBAL FalSeqpGetTempo
				ORG	P:
FalSeqpGetTempo:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+12),B
				movec   B1,B0
				movec   B2,B1
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetVol
				ORG	P:
FalSeqpGetVol:
				move    X:(R2+13),Y0
				rts     


				GLOBAL FalSeqpSetVol
				ORG	P:
FalSeqpSetVol:
				move    Y0,X:(R2+13)
				rts     


				GLOBAL FalSeqpLoop
				ORG	P:
FalSeqpLoop:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    R3,X:(R2+43)
				move    X:(SP-4),R0
				move    R0,X:(R2+44)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(R2+47)
				move    B0,X:(R2+46)
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpSetChlProgram
				ORG	P:
FalSeqpSetChlProgram:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+34),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    Y1,X:(R0+N)
				move    X:(R2+4),X0
				movec   X0,R0
				lea     (R0+5)
				moves   X:<mr2,N
				move    X:(R0+N),R1
				movei   #12,X0
				impy    Y0,X0,X0
				move    X:(R2+34),R0
				movec   X0,N
				move    R1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlProgram
				ORG	P:
FalSeqpGetChlProgram:
				move    X:(R2+34),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    X:(R0+N),B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				rts     


				GLOBAL FalSeqpSetChlFXMix
				ORG	P:
FalSeqpSetChlFXMix:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+34),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+7)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlFXMix
				ORG	P:
FalSeqpGetChlFXMix:
				move    X:(R2+34),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+7)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlVol
				ORG	P:
FalSeqpSetChlVol:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+34),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+6)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlVol
				ORG	P:
FalSeqpGetChlVol:
				move    X:(R2+34),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+6)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlPan
				ORG	P:
FalSeqpSetChlPan:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+34),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+4)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlPan
				ORG	P:
FalSeqpGetChlPan:
				move    X:(R2+34),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+4)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlPriority
				ORG	P:
FalSeqpSetChlPriority:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+34),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+5)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlPriority
				ORG	P:
FalSeqpGetChlPriority:
				move    X:(R2+34),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+5)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSendMidi
				ORG	P:
FalSeqpSendMidi:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #14,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   Y1,X:<mr10
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				ble     _L10
				movei   #2,X:(SP-13)
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-11)
				move    X:(SP-2),X0
				move    X0,X:(SP-10)
				moves   X:<mr10,X0
				move    X0,X:(SP-9)
				move    X:(SP-20),X0
				move    X0,X:(SP-8)
				move    X:(SP),B
				move    X:(SP-1),B0
				push    B0
				push    B1
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movec   SP,R3
				lea     (R3-13)
				jsr     FalEvtqPostEvent
				jmp     _L41
_L10:
				move    X:(SP-2),X0
				andc    #240,X0
				move    X0,X:(SP-4)
				move    X:(SP-2),X0
				andc    #15,X0
				move    X0,X:<mr9
				moves   X:<mr8,R2
				movei   #12,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,Y0
				move    X:(R2+34),X0
				add     X0,Y0
				move    Y0,X:<mr11
				move    X:(SP-4),X0
				cmp     #176,X0
				beq     _L32
				bge     _L21
				cmp     #144,X0
				beq     _L27
				bge     _L19
				cmp     #128,X0
				beq     _L30
				jmp     _L41
_L19:
				cmp     #160,X0
				jeq     _L41
				jmp     _L41
_L21:
				cmp     #208,X0
				jeq     _L41
				bge     _L25
				cmp     #192,X0
				beq     _L34
				jmp     _L41
_L25:
				cmp     #224,X0
				beq     _L36
				bra     _L41
_L27:
				tstw    X:(SP-20)
				beq     _L30
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpKeyOn
				pop     
				bra     _L41
_L30:
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpKeyOff
				pop     
				bra     _L41
_L32:
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpControlChange
				pop     
				bra     _L41
_L34:
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpSetChlProgram
				bra     _L41
_L36:
				move    X:(SP-20),Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				add     X:<mr10,X0
				add     #-8192,X0
				move    X0,X:(SP-3)
				moves   X:<mr11,R2
				move    X:(SP-3),Y0
				move    X:(R2+2),X0
				impy    Y0,X0,Y0
				movei   #13,X0
				asrr    Y0,X0,X0
				bge     _L40
				bcc     _L40
				inc     X0
_L40:
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr11,R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
_L41:
				lea     (SP-14)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpSwitchEvent:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr8,X0
				cmp     #17,X0
				jgt     _L26
				asl     X0
				add     #_L5,X0
				push    X0
				push    SR
				rti     
				jmp     _L22
				jmp     _L26
				jmp     _L7
				jmp     _L6
				jmp     _L9
				jmp     _L12
				jmp     _L18
				jmp     _L14
				jmp     _L16
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L26
				jmp     _L20
_L6:
				move    X:(SP),R2
				jsr     FalSeqpPlayer
_L7:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				push    X0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),Y1
				move    X:(SP-1),R2
				clr     A
				jsr     FalSeqpSendMidi
				pop     
				jmp     _L26
_L9:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),B0
				move    B0,B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				clr     A
				movec   X0,A0
				add     B,A
				move    X:(SP-1),R2
				clr     B
				move    X:(R2+8),B0
				add     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),R2
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalSeqpSetTempo
				jmp     _L26
_L12:
				move    X:(SP),R2
				jsr     FalSeqpStop
				jmp     _L26
_L14:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R3
				move    X:(SP),R2
				movei   #1,Y0
				jsr     FalSeqpEnvVolHandler
				jmp     _L26
_L16:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R3
				move    X:(SP),R2
				jsr     FalSeqpEnvPanHandler
				jmp     _L26
_L18:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R3
				move    X:(SP),R2
				jsr     FalSeqpFreeVoice
				bra     _L26
_L20:
				move    X:(SP),R2
				jsr     FalSeqpPlayer
				bra     _L26
_L22:
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+12),Y0
				movei   #4,X0
				asrr    Y0,X0,X0
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				move    X:(SP-1),R3
				jsr     FalEvtqPostEvent
				move    X:(SP-1),R2
				jsr     FmidiGetMsg
				tstw    Y0
				beq     _L26
_L24:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				push    X0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),Y1
				move    X:(SP-1),R2
				clr     A
				jsr     FalSeqpSendMidi
				pop     
				move    X:(SP-1),R2
				jsr     FmidiGetMsg
				tstw    Y0
				bne     _L24
_L26:
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpHandler
				ORG	P:
FalSeqpHandler:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				move    X:(SP-1),R0
				move    X:(R0+9),A
				move    X:(R0+8),A0
				jsr     FalMicroTimeAdd
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),A
				move    X:(R2+8),A0
				move    X:(SP-1),R2
				jsr     FalSeqpEnvTimers
_L5:
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+16)
				move    X:(SP-1),R2
				jsr     FalSeqpSwitchEvent
				move    X:(SP-1),R2
				nop     
				move    X:(R2+31),B
				move    X:(R2+30),B0
				tst     B
				ble     _L9
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+16)
				jsr     FalEvtqNextEvent
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+9)
				move    A0,X:(R2+8)
				bra     _L10
_L9:
				debug   
_L10:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				beq     _L5
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				bge     _L13
				debug   
_L13:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),A
				move    X:(R2+8),A0
				lea     (SP-2)
				rts     


				ORG	P:
FalSeqpPlayer:
				movei   #13,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP-1)
_L3:
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP-1),R2
				jsr     FalSeqNextEvent
				move    X:(SP-10),B
				move    X:(SP-11),B0
				tst     B
				bne     _L7
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP),R2
				jsr     FalSeqpSwitchEvent
				bra     _L10
_L7:
				movei   #3,X:(SP-12)
				move    X:(SP-10),B
				move    X:(SP-11),B0
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),B
				move    X:(R2+6),B0
				movec   B0,X0
				clr     B
				movec   X0,B0
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalEvtqPostEvent
_L10:
				move    X:(SP-10),B
				move    X:(SP-11),B0
				tst     B
				beq     _L3
				lea     (SP-13)
				rts     


				ORG	P:
FalSeqpControlChange:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   Y0,X:<mr8
				move    Y1,X:(SP-1)
				move    X:(SP-1),X0
				cmp     #30,X0
				bge     _L11
				cmp     #10,X0
				beq     _L22
				bge     _L7
				cmp     #7,X0
				beq     _L17
				jmp     _L31
_L7:
				cmp     #16,X0
				beq     _L27
				jlt     _L31
				cmp     #20,X0
				bge     _L29
				jmp     _L31
_L11:
				cmp     #91,X0
				jeq     _L30
				bge     _L15
				cmp     #64,X0
				beq     _L29
				jmp     _L31
_L15:
				cmp     #93,X0
				beq     _L31
				bra     _L31
_L17:
				moves   X:<mr8,Y0
				move    X:(SP),R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlVol
				move    X:(SP),R2
				nop     
				move    X:(R2+36),R2
				moves   X:<mr8,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-2)
				tstw    X:(SP-2)
				beq     _L31
				move    X:(SP),R2
				move    X:(SP-2),R3
				jsr     FalSeqpVolMix
				bra     _L31
_L22:
				moves   X:<mr8,Y0
				move    X:(SP-7),Y1
				move    X:(SP),R2
				jsr     FalSeqpSetChlPan
				move    X:(SP),R2
				nop     
				move    X:(R2+36),R2
				moves   X:<mr8,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-2)
				tstw    X:(SP-2)
				beq     _L31
				move    X:(SP),R2
				move    X:(SP-2),R3
				jsr     FalSeqpPanMix
				bra     _L31
_L27:
				moves   X:<mr8,Y0
				move    X:(SP),R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlPriority
				bra     _L31
_L29:
				move    X:(SP-7),X0
				move    X:(SP),R2
				nop     
				move    X:(R2+34),Y0
				movec   Y0,X:(SP-3)
				movei   #12,Y1
				moves   X:<mr8,Y0
				impy    Y1,Y0,Y0
				movec   X:(SP-3),R0
				lea     (R0+8)
				movec   Y0,N
				move    X0,X:(R0+N)
_L30:
				moves   X:<mr8,Y0
				move    X:(SP),R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlFXMix
_L31:
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpGetFreeVoice:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				move    X:(R2+38),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L7
				move    X:(SP),R2
				jsr     FalUnlink
				moves   X:<mr8,X0
				movec   X0,R3
				lea     (R3+36)
				move    X:(SP),R2
				jsr     FalLink
				move    X:(SP),R2
				bra     _L8
_L7:
				movei   #0,R2
_L8:
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpFreeVoice:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpCheckVoice
				tstw    Y0
				beq     _L5
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R3
				jsr     FalSynStopVoice
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R3
				jsr     FalSynFreeVoice
_L5:
				move    X:(SP-1),R2
				jsr     FalUnlink
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+38)
				move    X:(SP-1),R2
				jsr     FalLink
				lea     (SP-2)
				rts     


				ORG	P:
FalSeqpCheckVoice:
				movec   R3,R2
				nop     
				tstw    X:(R2+2)
				movei   #0,Y0
				beq     _L3
				movei   #1,Y0
_L3:
				rts     


				ORG	P:
FalSeqpKeyOn:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #9,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				moves   X:<mr9,R2
				movei   #12,Y0
				move    X:(SP),X0
				impy    Y0,X0,Y0
				move    X:(R2+34),X0
				add     X0,Y0
				move    Y0,X:(SP-8)
				move    X:(SP-8),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-7)
				move    X:(SP-7),R2
				move    X:(SP-8),R0
				move    X:(R0+5),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-6)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-2)
				move    X:(SP-7),R2
				move    X:(SP-1),Y0
				jsr     FalSeqpGetSound
				move    R2,X:<mr11
				tstw    R2
				jeq     _L29
				moves   X:<mr11,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:<mr10
				moves   X:<mr10,R0
				move    X:(SP-15),Y0
				move    X:(R0),X0
				cmp     X0,Y0
				jlo     _L29
				moves   X:<mr9,R2
				jsr     FalSeqpGetFreeVoice
				move    R2,X:<mr8
				tstw    R2
				jeq     _L29
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R2
				move    X:(SP-6),Y0
				moves   X:<mr8,R3
				jsr     FalSynAllocVoice
				cmp     #1,Y0
				jne     _L28
				moves   X:<mr8,R0
				move    R0,X:(SP-5)
				moves   X:<mr11,R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+6)
				move    X:(SP),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+29)
				move    X:(SP-1),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+30)
				moves   X:<mr11,R2
				movei   #258,Y0
				move    X:(R2+5),X0
				impy    Y0,X0,X0
				move    X:(SP-7),R0
				movei   #258,Y1
				move    X:(R0),Y0
				impy    Y1,Y0,Y0
				mpy     Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+34)
				moves   X:<mr11,R2
				move    X:(SP-7),R0
				move    X:(R0+1),Y0
				move    X:(R2+4),X0
				add     X0,Y0
				asr     Y0
				moves   X:<mr8,R2
				nop     
				move    Y0,X:(R2+35)
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpPanMix
				moves   X:<mr10,R2
				move    X:(SP-15),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				bls     _L20
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:(SP-15)
_L20:
				move    X:(SP-15),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+31)
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpStartEnvelope
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpVolMix
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),Y0
				movei   #60,X0
				sub     Y0,X0
				add     X:(SP-1),X0
				move    X0,X:(SP-1)
				move    X:(SP-1),Y0
				moves   X:<mr10,R2
				nop     
				move    X:(R2+5),Y1
				jsr     FalGetLinearRate
				move    A1,X:(SP-3)
				move    A0,X:(SP-4)
				move    X:(SP-3),A
				move    X:(SP-4),A0
				move    X:(SP-2),R2
				move    X:(SP-5),R3
				jsr     FalSynSetPitch
				moves   X:<mr11,R2
				nop     
				move    X:(R2+3),R0
				push    R0
				move    X:(SP-3),R2
				move    X:(SP-6),R3
				jsr     FalSynStartVoice
				pop     
				bra     _L29
_L28:
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpFreeVoice
_L29:
				lea     (SP-9)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpKeyOff:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+36),R2
				move    X:(SP),Y0
				move    X:(SP-1),Y1
				jsr     FalSeqpFindVoiceChlKey
				move    R2,X:(SP-2)
				tstw    X:(SP-2)
				beq     _L7
				move    X:(SP-2),R2
				nop     
				movei   #3,X:(R2+12)
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movei   #7,Y0
				jsr     FalEvtqFlushType
				moves   X:<mr8,R2
				move    X:(SP-2),R3
				movei   #0,Y0
				jsr     FalSeqpEnvVolHandler
_L7:
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpGetSound:
				moves   R2,X:<mr3
				moves   X:<mr3,R0
				move    X:(R0+13),X0
				move    X0,X:<mr4
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				bge     _L12
_L5:
				moves   X:<mr2,X0
				add     X:<mr3,X0
				movec   X0,R0
				move    X:(R0+14),R3
				move    X:(R3+2),R2
				nop     
				move    X:(R2+2),X0
				cmp     Y0,X0
				bhi     _L10
				move    X:(R2+3),X0
				cmp     Y0,X0
				blo     _L10
				movec   R3,R2
				bra     _L13
_L10:
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				blt     _L5
_L12:
				movei   #0,R2
_L13:
				rts     


				GLOBAL FalSeqpEnvelope
				ORG	P:
FalSeqpEnvelope:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   #1,X:<mr8
				tstw    X:(SP-2)
				beq     _L11
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				bftstl  #256,X0
				blo     _L11
				move    X:(SP),R2
				move    X:(SP-1),R0
				move    X:(R2+5),Y0
				move    X:(R0+2),X0
				cmp     X0,Y0
				blo     _L20
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+1),Y0
				move    X:(R0+2),X0
				cmp     X0,Y0
				bne     _L9
				moves   #0,X:<mr8
				bra     _L20
_L9:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+5)
				bra     _L20
_L11:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				bftstl  #512,X0
				blo     _L18
				move    X:(SP),R2
				move    X:(SP-1),R0
				move    X:(R2+5),Y0
				move    X:(R0+4),X0
				cmp     X0,Y0
				blo     _L20
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+3),Y0
				move    X:(R0+4),X0
				cmp     X0,Y0
				bne     _L16
				moves   #0,X:<mr8
				bra     _L20
_L16:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+5)
				bra     _L20
_L18:
				move    X:(SP),R2
				move    X:(SP-1),R0
				move    X:(R0+5),Y0
				move    X:(R2+5),X0
				dec     Y0
				cmp     Y0,X0
				blo     _L20
				moves   #0,X:<mr8
_L20:
				tstw    X:<mr8
				beq     _L25
				movei   #0,B
				movei   #1000,B0
				push    B0
				push    B1
				move    X:(SP-3),Y0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+5),Y1
				movec   Y1,X0
				inc     Y1
				move    Y1,X:(R2+5)
				lsl     X0
				movec   Y0,R0
				lea     (R0+7)
				movec   X0,N
				move    X:(R0+N),B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				move    X:(SP-1),Y0
				move    X:(SP),R2
				nop     
				move    X:(R2+5),X0
				lsl     X0
				movec   Y0,R0
				lea     (R0+6)
				movec   X0,N
				move    X:(R0+N),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+4)
				move    X:(SP),R0
				movei   #3,X0
				move    X0,X:(R0)
				bra     _L26
_L25:
				move    X:(SP),R0
				movei   #2,X0
				move    X0,X:(R0)
_L26:
				moves   X:<mr8,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpSendEnvMsg
				ORG	P:
FalSeqpSendEnvMsg:
				movei   #14,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    Y0,X:(SP-4)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				bge     _L4
				debug   
_L4:
				tstw    X:(SP-1)
				beq     _L8
				move    X:(SP-4),X0
				move    X0,X:(SP-13)
				move    X:(SP-1),R0
				move    R0,X:(SP-12)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movec   SP,R3
				lea     (R3-13)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalEvtqPostEvent
_L8:
				lea     (SP-14)
				rts     


				ORG	P:
FalSeqpEnvTimers:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+36),R0
				move    R0,X:(SP-2)
				tstw    X:(SP-2)
				beq     _L10
_L4:
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+19)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+25)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
				move    X:(SP-2),R2
				nop     
				move    X:(R2+17),X0
				cmp     #3,X0
				bne     _L8
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+14)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
_L8:
				move    X:(SP-2),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-2)
				tstw    X:(SP-2)
				bne     _L4
_L10:
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpNearesVolPoint
				ORG	P:
FalSeqpNearesVolPoint:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #5,N
				lea     (SP)+N
				moves   R2,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+36),R0
				move    R0,X:(SP)
				movei   #65535,X:(SP-4)
				movei   #32767,X:(SP-3)
				moves   #0,X:<mr8
				tstw    X:(SP)
				beq     _L11
_L6:
				move    X:(SP),R2
				nop     
				move    X:(R2+20),B
				move    X:(R2+19),B0
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				tstw    X:(SP)
				bne     _L6
_L11:
				tstw    X:<mr8
				beq     _L13
				moves   X:<mr8,R2
				nop     
				move    X:(R2+20),A
				move    X:(R2+19),A0
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				movei   #7,Y0
				jsr     FalSeqpSendEnvMsg
_L13:
				moves   X:<mr8,R2
				lea     (SP-5)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpNearesPanPoint
				ORG	P:
FalSeqpNearesPanPoint:
				movei   #4,N
				lea     (SP)+N
				moves   R2,X:<mr2
				moves   X:<mr2,R0
				move    X:(R0+36),R2
				movei   #65535,X:(SP-3)
				movei   #32767,X:(SP-2)
				tstw    R2
				beq     _L10
_L5:
				move    X:(R2+26),B
				move    X:(R2+25),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movec   R2,R3
				move    X:(R2),R2
				tstw    R2
				bne     _L5
_L10:
				movec   R3,R2
				lea     (SP-4)
				rts     


				ORG	P:
FalSeqpEnvVolHandler:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+16)
				jeq     _L25
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpCheckVoice
				tstw    Y0
				jeq     _L25
				moves   #1,X:<mr9
				move    X:(SP-1),R2
				nop     
				move    X:(R2+12),X0
				cmp     #3,X0
				bne     _L8
				move    X:(SP),R2
				nop     
				move    X:(R2+34),X0
				move    X:(SP-1),R2
				movei   #12,Y1
				move    X:(R2+29),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+8)
				movec   Y0,N
				tstw    X:(R0+N)
				bne     _L8
				moves   #0,X:<mr9
_L8:
				moves   X:<mr9,X0
				move    X0,X:<mr8
				tstw    X:(SP-2)
				beq     _L15
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+17)
				move    X:(SP-1),R0
				move    X:(R0+6),R1
				nop     
				move    X:(R1),R3
				moves   X:<mr8,Y0
				jsr     FalSeqpEnvelope
				move    Y0,X:<mr10
				move    X:(SP-1),R2
				nop     
				move    X:(R2+20),B
				move    X:(R2+19),B0
				tst     B
				bne     _L15
				tstw    X:<mr10
				beq     _L15
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R0
				move    X:(SP-1),R1
				move    X:(R1+16),Y0
				move    X:(R0+21),X0
				mpy     Y0,X0,B
				movec   B1,Y0
				move    X:(SP-1),R3
				clr     A
				jsr     FalSynSetVol
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+17)
				move    X:(SP-1),R0
				move    X:(R0+6),R1
				nop     
				move    X:(R1),R3
				moves   X:<mr8,Y0
				jsr     FalSeqpEnvelope
_L15:
				tstw    X:<mr8
				jne     _L23
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+15),B
				move    X:(R2+14),B0
				move    X:(R0+20),A
				move    X:(R0+19),A0
				cmp     A,B
				ble     _L18
				move    X:(SP-1),R2
				nop     
				move    X:(R2+20),B
				move    X:(R2+19),B0
				tst     B
				bne     _L22
_L18:
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+16)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				move    X:(SP-1),R2
				nop     
				move    B1,X:(R2+20)
				move    B0,X:(R2+19)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+21)
				bra     _L23
_L22:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+16),B0
				move    B0,B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+15),A
				move    X:(R2+14),A0
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-1),R2
				push    A0
				push    A1
				move    X:(R2+20),A
				move    X:(R2+19),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,A0
				movec   A0,X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+16)
_L23:
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R0
				move    X:(SP-1),R1
				move    X:(R1+16),Y0
				move    X:(R0+21),X0
				mpy     Y0,X0,B
				movec   B1,Y0
				move    X:(SP-1),R0
				move    X:(R0+20),A
				move    X:(R0+19),A0
				move    X:(SP-1),R3
				jsr     FalSynSetVol
				bra     _L27
_L25:
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpFreeVoice
				debug   
_L27:
				move    X:(SP),R2
				jsr     FalSeqpNearesVolPoint
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpEnvPanHandler:
				move    X:<mr8,N
				push    N
				movei   #11,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+16)
				bne     _L4
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpFreeVoice
_L4:
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpCheckVoice
				tstw    Y0
				beq     _L14
				move    X:(SP-1),R2
				nop     
				move    X:(R2+23),X0
				cmp     #3,X0
				bne     _L7
				move    X:(SP),R2
				nop     
				move    X:(R2+34),X0
				move    X:(SP-1),R2
				movei   #12,Y1
				move    X:(R2+29),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+8)
				movec   Y0,N
				tstw    X:(R0+N)
				beq     _L8
_L7:
				movei   #1,X0
				bra     _L9
_L8:
				movei   #0,X0
_L9:
				move    X0,X:<mr8
_L10:
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+23)
				move    X:(SP-1),R0
				move    X:(R0+6),R1
				move    X:(R1+1),R3
				moves   X:<mr8,Y0
				jsr     FalSeqpEnvelope
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R0
				move    X:(R0+27),Y0
				move    X:(SP-1),R3
				jsr     FalSynSetPan
				move    X:(SP-1),R2
				nop     
				move    X:(R2+26),B
				move    X:(R2+25),B0
				tst     B
				beq     _L10
				move    X:(SP-1),R2
				move    X:(SP),R0
				move    X:(R0+3),B
				move    X:(R0+2),B0
				move    X:(R2+26),A
				move    X:(R2+25),A0
				add     A,B
				move    B1,X:(R2+26)
				move    B0,X:(R2+25)
_L14:
				move    X:(SP),R2
				jsr     FalSeqpNearesPanPoint
				move    R2,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L19
				movei   #8,X:(SP-10)
				move    X:(SP-1),R0
				move    R0,X:(SP-9)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+26)
				movec   SP,R3
				lea     (R3-10)
				move    X:(SP-1),R0
				move    X:(SP),R1
				move    X:(R1+3),B
				move    X:(R1+2),B0
				move    X:(R0+26),A
				move    X:(R0+25),A0
				sub     B,A
				jsr     FalEvtqPostEvent
_L19:
				lea     (SP-11)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpStartEnvelope:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				movei   #32767,X:(R2+16)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),R0
				move    X:(R0+6),Y0
				jsr     FalMiliToMicro
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+15)
				move    A0,X:(R2+14)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+12)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),R0
				move    X:(R0+7),X0
				bftstl  #1024,X0
				blo     _L10
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+22)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+17)
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R0
				move    X:(R0+6),R1
				nop     
				move    X:(R1),R0
				move    X:(R0+6),Y0
				move    X:(SP-1),R3
				clr     A
				jsr     FalSynSetVol
				move    X:(SP),R2
				move    X:(SP-1),R3
				movei   #1,Y0
				jsr     FalSeqpEnvVolHandler
_L10:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),R0
				move    X:(R0+7),X0
				bftstl  #2048,X0
				blo     _L14
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+28)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+23)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpEnvPanHandler
_L14:
				lea     (SP-2)
				rts     


				ORG	P:
FalSeqpVolMix:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				movei   #258,Y0
				move    X:(R2+31),X0
				impy    Y0,X0,X0
				move    X:(SP),R2
				nop     
				move    X:(R2+34),Y0
				movec   Y0,X:(SP-2)
				move    X:(SP-1),R2
				movei   #12,Y1
				move    X:(R2+29),Y0
				impy    Y1,Y0,Y0
				movec   X:(SP-2),R0
				lea     (R0+6)
				movec   Y0,N
				move    X:(R0+N),Y1
				movei   #258,Y0
				impy    Y1,Y0,Y0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+34),Y0
				moves   X:<mr8,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				moves   X:<mr8,Y0
				move    X:(SP-1),R3
				jsr     FalSynSetGain
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpPanMix:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),R0
				move    X:(R0+34),X0
				move    X:(SP-1),R0
				movei   #12,Y1
				move    X:(R0+29),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+4)
				movec   Y0,N
				move    X:(R0+N),Y0
				move    X:(R2+35),X0
				add     X0,Y0
				lsr     Y0
				move    Y0,X:<mr8
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R3
				moves   X:<mr8,Y0
				jsr     FalSynSetPan
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSeqpFindVoiceChl:
				tstw    R2
				beq     _L6
_L2:
				move    X:(R2+29),X0
				cmp     Y0,X0
				beq     _L6
_L4:
				move    X:(R2),R2
				tstw    R2
				bne     _L2
_L6:
				rts     


				ORG	P:
FalSeqpFindVoiceChlKey:
				moves   Y1,X:<mr2
				tstw    R2
				beq     _L8
_L3:
				move    X:(R2+29),X0
				cmp     Y0,X0
				bne     _L6
				move    X:(R2+30),X0
				cmp     X:<mr2,X0
				beq     _L8
_L6:
				move    X:(R2),R2
				tstw    R2
				bne     _L3
_L8:
				rts     


				ORG	X:
Fratestable     DC			0,16,-3184,16,-2661,17,1790,19
				DC			10403,20,23425,21,-24418,22,-1775,23
				DC			26111,25,-5984,26,-32194,28,13368,30
				DC			0,32

				ENDSEC
				END

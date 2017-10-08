
				SECTION alevents
				include "asmdef.h"
				GLOBAL FalEvtqNew
				ORG	P:
FalEvtqNew:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+2)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+3)
				move    X:(SP),R0
				movei   #0,X0
				move    X0,X:(R0)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+1)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+4)
				movei   #0,X:(R2+5)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				ble     _L11
_L8:
				movei   #-1,B
				movei   #-1,B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movec   B0,Y0
				movei   #13,X0
				impy    Y0,X0,X0
				add     X:(SP-1),X0
				movec   X0,R2
				move    X:(SP),R3
				jsr     FalLink
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				bgt     _L8
_L11:
				lea     (SP-4)
				rts     


				GLOBAL FalEvtqNextEvent
				ORG	P:
FalEvtqNextEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    R3,X:(SP)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:<mr8
				tstw    X:<mr8
				beq     _L14
				moves   X:<mr8,X0
				movec   X0,R3
				lea     (R3+4)
				move    X:(SP),R2
				movei   #9,Y0
				jsr     FmemMemcpy
				moves   X:<mr8,R2
				jsr     FalUnlink
				moves   X:<mr8,R2
				moves   X:<mr9,R3
				jsr     FalLink
				moves   X:<mr9,R2
				movei   #-1,B
				movei   #-1,B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L13
_L10:
				move    X:(SP-1),R2
				moves   X:<mr8,R0
				move    X:(R0+3),B
				move    X:(R0+2),B0
				move    X:(R2+3),A
				move    X:(R2+2),A0
				sub     B,A
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				tstw    X:(SP-1)
				bne     _L10
_L13:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),A
				move    X:(R2+2),A0
				bra     _L15
_L14:
				clr     A
_L15:
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalEvtqPostEvent
				ORG	P:
FalEvtqPostEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    R3,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr8
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-3)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				tst     B
				bge     _L6
				debug   
_L6:
				tstw    X:<mr8
				jeq     _L22
				move    X:(SP-1),B
				move    X:(SP-2),B0
				moves   X:<mr8,R2
				nop     
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				move    X:(SP),R3
				movei   #9,Y0
				jsr     FmemMemcpy
				tstw    X:(SP-3)
				bne     _L14
				moves   X:<mr8,R2
				jsr     FalUnlink
				moves   X:<mr9,X0
				movec   X0,R3
				lea     (R3+2)
				moves   X:<mr8,R2
				jsr     FalLink
				bra     _L20
_L13:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-3)
_L14:
				move    X:(SP-3),R0
				nop     
				tstw    X:(R0)
				beq     _L16
				move    X:(SP-3),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				move    X:(SP-1),A
				move    X:(SP-2),A0
				cmp     A,B
				blt     _L13
_L16:
				move    X:(SP-3),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				move    X:(SP-1),A
				move    X:(SP-2),A0
				cmp     A,B
				ble     _L18
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP-3)
_L18:
				moves   X:<mr8,R2
				jsr     FalUnlink
				moves   X:<mr8,R2
				move    X:(SP-3),R3
				jsr     FalLink
_L20:
				moves   X:<mr9,R2
				movei   #0,B
				movei   #1,B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				bra     _L23
_L22:
				debug   
_L23:
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalEvtqFlush
				ORG	P:
FalEvtqFlush:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L8
_L4:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				move    X:(SP),R2
				jsr     FalUnlink
				move    X:(SP),R2
				moves   X:<mr8,R3
				jsr     FalLink
				tstw    X:(SP)
				bne     _L4
_L8:
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+2)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+3)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+4)
				movei   #0,X:(R2+5)
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalEvtqFlushType
				ORG	P:
FalEvtqFlushType:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   Y0,X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L11
_L4:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr9
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				cmp     X:<mr10,X0
				bne     _L9
				move    X:(SP),R2
				jsr     FalUnlink
				move    X:(SP),R2
				moves   X:<mr8,R3
				jsr     FalLink
				moves   X:<mr8,R2
				movei   #-1,B
				movei   #-1,B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
_L9:
				moves   X:<mr9,R0
				move    R0,X:(SP)
				tstw    X:(SP)
				bne     _L4
_L11:
				lea     (SP)-
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalEvtqFlushVoice
				ORG	P:
FalEvtqFlushVoice:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   R3,X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L14
_L4:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr9
				move    X:(SP),R2
				nop     
				move    X:(R2+5),X0
				cmp     X:<mr10,X0
				bne     _L12
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				cmp     #8,X0
				beq     _L9
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				cmp     #9,X0
				beq     _L9
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				cmp     #26,X0
				bne     _L12
_L9:
				move    X:(SP),R2
				jsr     FalUnlink
				move    X:(SP),R2
				moves   X:<mr8,R3
				jsr     FalLink
				moves   X:<mr8,R2
				movei   #-1,B
				movei   #-1,B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
_L12:
				moves   X:<mr9,R0
				move    R0,X:(SP)
				tstw    X:(SP)
				bne     _L4
_L14:
				lea     (SP)-
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

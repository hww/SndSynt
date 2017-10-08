
				SECTION seqfile
				include "asmdef.h"
				GLOBAL FalSeqGet8
				ORG	P:
FalSeqGet8:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				push    B0
				push    B1
				movei   #0,A
				movei   #1,A0
				add     A,B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				pop     B1
				pop     B0
				tfr     B,A
				jsr     Fsdram_read16
				andc    #255,Y0
				lea     (SP)-
				rts     


				GLOBAL FalSeqGet16
				ORG	P:
FalSeqGet16:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				push    B0
				push    B1
				movei   #0,A
				movei   #1,A0
				add     A,B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				pop     B1
				pop     B0
				tfr     B,A
				jsr     Fsdram_read16
				movei   #8,X0
				asll    Y0,X0,X0
				move    X0,X:<mr8
				move    X:(SP),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				push    B0
				push    B1
				movei   #0,A
				movei   #1,A0
				add     A,B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				pop     B1
				pop     B0
				tfr     B,A
				jsr     Fsdram_read16
				andc    #255,Y0
				add     X:<mr8,Y0
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqGet32
				ORG	P:
FalSeqGet32:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				jsr     FalSeqGet16
				movec   Y0,B0
				move    B0,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP),R2
				jsr     FalSeqGet16
				clr     B
				movec   Y0,B0
				move    X:(SP-1),A
				move    X:(SP-2),A0
				add     A,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),A
				move    X:(SP-2),A0
				lea     (SP-3)
				rts     


				GLOBAL FalSeqFileNew
				ORG	P:
FalSeqFileNew:
				move    X:<mr8,N
				push    N
				movei   #7,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				moves   Y0,X:<mr8
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(SP-5)
				move    B0,X:(SP-6)
				movec   SP,R2
				lea     (R2-6)
				jsr     FalSeqGet16
				move    X:(SP),R0
				nop     
				move    Y0,X:(R0)
				movec   SP,R2
				lea     (R2-6)
				jsr     FalSeqGet16
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+1)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				cmp     #21297,X0
				bne     _L13
				move    X:(SP-5),B
				move    X:(SP-6),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				tstw    X:<mr8
				beq     _L10
_L8:
				movei   #0,B
				movei   #8,B0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     A,B
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				tstw    X:<mr8
				bne     _L8
_L10:
				move    X:(SP-3),B
				move    X:(SP-4),B0
				move    B1,X:(SP-5)
				move    B0,X:(SP-6)
				movec   SP,R2
				lea     (R2-6)
				jsr     FalSeqGet32
				move    X:(SP-1),B
				move    X:(SP-2),B0
				add     B,A
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				movec   SP,R2
				lea     (R2-6)
				jsr     FalSeqGet32
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+5)
				move    A0,X:(R2+4)
_L13:
				lea     (SP-7)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqFileLoad
				ORG	P:
FalSeqFileLoad:
				move    X:<mr8,N
				push    N
				movei   #5,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				movei   #1,X0
				push    X0
				move    X:(SP-1),R2
				jsr     Fopen
				pop     
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L5
				clr     A
				jmp     _L13
_L5:
				movec   SP,R0
				lea     (R0-4)
				push    R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #3,Y1
				jsr     FfileioIoctl
				pop     
				move    X:(SP-3),B
				move    X:(SP-4),B0
				tst     B
				bne     _L8
				clr     A
				bra     _L13
_L8:
				movei   #0,X0
				push    X0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #1,Y1
				jsr     FfileioIoctl
				pop     
				move    X:(SP-3),B
				move    X:(SP-4),B0
				push    B0
				push    B1
				moves   X:<mr8,Y0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				jsr     Fsdram_load_file
				lea     (SP-2)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #_L11,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L11:
				move    X:(SP-3),A
				move    X:(SP-4),A0
_L13:
				lea     (SP-5)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

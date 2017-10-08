
				SECTION midi
				include "asmdef.h"
				GLOBAL FmidiOpen
				ORG	P:
FmidiOpen:
				movei   #3,N
				lea     (SP)+N
				movei   #0,X:(SP-2)
				movei   #0,X0
				move    X0,X:(SP-1)
				movei   #14,X0
				move    X0,X:(SP)
				tstw    X:FbUartIsOpened
				bne     _L10
				movec   SP,R0
				lea     (R0-2)
				push    R0
				movei   #9,X0
				push    X0
				movei   #29,R2
				jsr     Fopen
				lea     (SP-2)
				move    Y0,X:FmidiUart
				movei   #-1,X0
				cmp     X:FmidiUart,X0
				bne     _L8
				debug   
_L8:
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				clr     B
				movec   B0,X0
				movec   X0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				movei   #1,X:FbUartIsOpened
_L10:
				movei   #0,X:Fmsgidx
				lea     (SP-3)
				rts     


				GLOBAL FmidiClose
				ORG	P:
FmidiClose:
				movei   #0,X:FbUartIsOpened
				move    X:FmidiUart,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				movei   #_L3,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L3:
				rts     


				GLOBAL FmidiGetBytes
				ORG	P:
FmidiGetBytes:
				move    X:<mr8,N
				push    N
				moves   Y0,X:<mr8
				moves   X:<mr8,X0
				sub     X:Fmsgidx,X0
				move    X0,X:<mr8
				tstw    X0
				beq     _L8
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_GET_READ_SIZE
				moves   X:<mr8,X0
				cmp     Y0,X0
				bls     _L5
				movei   #0,Y0
				bra     _L9
_L5:
				move    X:FmidiUart,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				move    X:Fmsgidx,X0
				movec   X0,R2
				nop     
				lea     (R2+Fmsgbuf)
				moves   X:<mr8,Y1
				movei   #_L6,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L6:
				moves   X:<mr8,X0
				add     X:Fmsgidx,X0
				move    X0,X:Fmsgidx
_L8:
				movei   #1,Y0
_L9:
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FmidiGetMsg
				ORG	P:
FmidiGetMsg:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				tstw    X:FbUartIsOpened
				bne     _L4
				movei   #0,Y0
				jmp     _L63
_L4:
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_GET_READ_SIZE
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L7
				movei   #0,Y0
				jmp     _L63
_L7:
				tstw    X:Fmsgidx
				bne     _L20
_L8:
				movei   #0,X:Fmsgidx
				tstw    X:<mr8
				bne     _L11
				movei   #0,Y0
				jmp     _L63
_L11:
				move    X:FmidiUart,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				move    X:FmidiUart,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				nop     
				lea     (R2)-
				movei   #1,Y1
				movei   #_L12,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L12:
				movei   #128,X0
				cmp     X:(SP-1),X0
				bls     _L16
				move    X:(SP-1),X0
				inc     X:Fmsgidx
				move    X:Fmsgidx,R0
				nop     
				move    X0,X:(R0+#Fmsgbuf)
				bra     _L17
_L16:
				move    X:(SP-1),X0
				move    X:Fmsgidx,R0
				nop     
				move    X0,X:(R0+#Fmsgbuf)
_L17:
				dec     X:<mr8
				movei   #128,X0
				cmp     X:Fmsgbuf,X0
				bhi     _L8
				inc     X:Fmsgidx
_L20:
				move    X:Fmsgbuf,X0
				move    X0,X:<mr9
				movei   #240,X0
				cmp     X:<mr9,X0
				bls     _L23
				andc    #240,X:<mr9
_L23:
				moves   X:<mr9,X0
				cmp     #208,X0
				beq     _L50
				bge     _L35
				cmp     #160,X0
				beq     _L48
				bge     _L31
				cmp     #144,X0
				beq     _L48
				jge     _L59
				cmp     #128,X0
				beq     _L48
				jmp     _L59
_L31:
				cmp     #192,X0
				beq     _L50
				jge     _L59
				cmp     #176,X0
				beq     _L48
				bra     _L59
_L35:
				cmp     #243,X0
				beq     _L56
				bge     _L43
				cmp     #240,X0
				beq     _L52
				bge     _L41
				cmp     #224,X0
				beq     _L48
				bra     _L59
_L41:
				cmp     #242,X0
				bge     _L54
				bra     _L59
_L43:
				cmp     #254,X0
				bge     _L46
				cmp     #247,X0
				beq     _L58
				bra     _L59
_L46:
				cmp     #256,X0
				bge     _L59
				bra     _L58
_L48:
				movei   #3,Y0
				jsr     FmidiGetBytes
				tstw    Y0
				bne     _L59
				movei   #0,Y0
				bra     _L63
_L50:
				movei   #2,Y0
				jsr     FmidiGetBytes
				tstw    Y0
				bne     _L59
				movei   #0,Y0
				bra     _L63
_L52:
				movei   #0,X:Fmsgidx
				bra     _L59
_L54:
				movei   #3,Y0
				jsr     FmidiGetBytes
				tstw    Y0
				bne     _L59
				movei   #0,Y0
				bra     _L63
_L56:
				movei   #2,Y0
				jsr     FmidiGetBytes
				tstw    Y0
				bne     _L59
				movei   #0,Y0
				bra     _L63
_L58:
				movei   #0,X:Fmsgidx
_L59:
				tstw    X:Fmsgidx
				jeq     _L4
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				movei   #Fmsgbuf,R3
				move    X:Fmsgidx,Y0
				jsr     FmemMemcpy
				movei   #0,X:Fmsgidx
				movei   #1,Y0
_L63:
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
FbUartIsOpened  BSC			1
Fmsgidx         BSC			1
Fmsgbuf         BSC			3
FmidiUart       BSC			1

				ENDSEC
				END

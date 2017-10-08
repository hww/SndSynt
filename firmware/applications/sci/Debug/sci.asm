
				SECTION sci
				include "asmdef.h"
				GLOBAL Fmain
				ORG	P:
Fmain:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #7,N
				lea     (SP)+N
				moves   #0,X:<mr9
				bra     _L5
_L3:
				moves   X:<mr9,X0
				moves   X:<mr9,R0
				nop     
				move    X0,X:(R0+#FBuffer)
				inc     X:<mr9
_L5:
				movei   #257,X0
				cmp     X:<mr9,X0
				bhi     _L3
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				movei   #5,X0
				move    X0,X:(SP-1)
				movec   SP,R0
				lea     (R0-3)
				push    R0
				movei   #3,X0
				push    X0
				movei   #29,R2
				jsr     Fopen
				lea     (SP-2)
				move    Y0,X:<mr8
				movei   #-1,X0
				cmp     X:<mr8,X0
				bne     _L12
				debug   
_L12:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				clr     B
				movec   B0,X0
				movec   X0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				lea     (R2-4)
				movei   #1,Y1
				movei   #_L14,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L14:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				clr     B
				movec   B0,X0
				movec   X0,R2
				jsr     FioctlSCI_DATAFORMAT_RAW
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				lea     (R2-6)
				movei   #1,Y1
				movei   #_L17,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L17:
				movei   #88,X0
				cmp     X:(SP-4),X0
				bne     _L22
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-6),R2
				movei   #257,Y1
				movei   #_L20,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L20:
				jmp     _L12
_L22:
				movei   #80,X0
				cmp     X:(SP-4),X0
				jne     _L12
				move    X:(SP-6),R0
				move    R0,X:(SP)
				moves   #0,X:<mr9
				bra     _L31
_L26:
				move    X:(SP),R2
				jsr     FmemReadP16
				move    Y0,X:(SP-5)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				lea     (R2-5)
				movei   #1,Y1
				movei   #_L28,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L28:
				inc     X:<mr9
				move    X:(SP),R0
				nop     
				lea     (R0)+
				move    R0,X:(SP)
_L31:
				movei   #257,X0
				cmp     X:<mr9,X0
				bhi     _L26
				jmp     _L12


				ORG	X:
FBuffer         BSC			257

				ENDSEC
				END

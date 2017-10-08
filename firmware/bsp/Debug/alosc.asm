
				SECTION alosc
				include "asmdef.h"
				GLOBAL FinitOsc
				ORG	P:
FinitOsc:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #7,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   R3,X:<mr9
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #0,X:(SP-6)
				movei   #0,X:(SP-5)
				movei   #20,Y1
				move    X:(SP-2),Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:<mr10
				tstw    X:FfreeOscStateList
				jeq     _L43
				move    X:FfreeOscStateList,R0
				move    R0,X:<mr8
				move    X:FfreeOscStateList,R0
				nop     
				move    X:(R0),R1
				move    R1,X:FfreeOscStateList
				move    X:(SP-1),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+1)
				move    X:(SP),R0
				moves   X:<mr8,R1
				move    R1,X:(R0)
				movei   #0,B
				movei   #1000,B0
				push    B0
				push    B1
				move    X:(SP-16),X0
				inc     X0
				clr     B
				movec   X0,B0
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-5)
				move    A0,X:(SP-6)
				move    X:(SP-1),X0
				cmp     #3,X0
				jeq     _L30
				bge     _L15
				cmp     #1,X0
				beq     _L17
				bge     _L22
				jmp     _L43
_L15:
				cmp     #5,X0
				jge     _L43
				jmp     _L37
_L17:
				move    X:(SP-13),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+4)
				moves   X:<mr10,X0
				add     #4,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr9,R0
				clr     B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				jmp     _L43
_L22:
				moves   X:<mr10,X0
				inc     X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+4)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+2)
				move    X:(SP-13),X0
				move    X0,X:<mr11
				move    X:<mr11,B
				neg     B
				movec   B1,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr11,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+6),B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				jmp     _L43
_L30:
				moves   X:<mr10,X0
				inc     X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+4)
				move    X:(SP-13),X0
				move    X0,X:(SP-4)
				move    X:(SP-4),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+5)
				move    X:(SP-4),X0
				asl     X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				bra     _L43
_L37:
				moves   X:<mr10,X0
				inc     X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+4)
				move    X:(SP-13),X0
				move    X0,X:(SP-3)
				move    X:(SP-3),B
				neg     B
				movec   B1,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+5)
				move    X:(SP-3),X0
				asl     X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L43:
				move    X:(SP-5),A
				move    X:(SP-6),A0
				lea     (SP-7)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FupdateOsc
				ORG	P:
FupdateOsc:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   R3,X:<mr9
				move    X:(SP),R0
				move    R0,X:(SP-1)
				movei   #20000,X:(SP-3)
				movei   #0,X:(SP-2)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),X0
				cmp     #3,X0
				jeq     _L34
				bge     _L9
				cmp     #1,X0
				beq     _L11
				jge     _L26
				jmp     _L53
_L9:
				cmp     #5,X0
				jge     _L53
				jmp     _L44
_L11:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),X0
				inc     X0
				move    X0,X:(R2+4)
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+4),Y0
				move    X:(R0+3),X0
				cmp     X0,Y0
				blo     _L14
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+4)
_L14:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L16
				neg     B
_L16:
				movec   B0,X0
				asl     X0
				move    X0,X:<mr8
				movei   #16384,X0
				cmp     X:<mr8,X0
				bne     _L20
				moves   #-16384,X:<mr8
				bra     _L22
_L20:
				movei   #49152,X0
				cmp     X:<mr8,X0
				bne     _L22
				moves   #16384,X:<mr8
_L22:
				moves   X:<mr8,Y0
				jsr     Ftfr16SinPIx
				move    Y0,X:<mr8
				move    X:(SP-1),R2
				moves   X:<mr8,Y0
				move    X:(R2+5),X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:<mr8,B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				jmp     _L53
_L26:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+2)
				bne     _L30
				move    X:(SP-1),R2
				nop     
				movei   #1,X:(R2+2)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				bra     _L32
_L30:
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+2)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L32:
				move    X:(SP-1),R2
				clr     B
				move    X:(R2+3),B0
				push    B0
				push    B1
				move    X:(SP-4),A
				move    X:(SP-5),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				jmp     _L53
_L34:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),X0
				inc     X0
				move    X0,X:(R2+4)
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+4),Y0
				move    X:(R0+3),X0
				cmp     X0,Y0
				bls     _L37
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+4)
_L37:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L39
				neg     B
_L39:
				movec   B0,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),Y0
				moves   X:<mr8,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				sub     X:<mr8,X0
				move    X0,X:<mr8
				move    X:<mr8,B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				bra     _L53
_L44:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),X0
				inc     X0
				move    X0,X:(R2+4)
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+4),Y0
				move    X:(R0+3),X0
				cmp     X0,Y0
				bls     _L47
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+4)
_L47:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L49
				neg     B
_L49:
				movec   B0,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),Y0
				moves   X:<mr8,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				add     X:<mr8,X0
				move    X0,X:<mr8
				move    X:<mr8,B
				movec   B1,B0
				movec   B2,B1
				moves   X:<mr9,R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L53:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FstopOsc
				ORG	P:
FstopOsc:
				move    X:FfreeOscStateList,R0
				move    R0,X:(R2)
				move    R2,X:FfreeOscStateList
				rts     


				GLOBAL FcreateAllOsc
				ORG	P:
FcreateAllOsc:
				movei   #FoscStates,R0
				move    R0,X:FfreeOscStateList
				movei   #FoscStates,R2
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     #31,X0
				bge     _L9
_L5:
				moves   X:<mr2,Y0
				inc     Y0
				movei   #3,X0
				asll    Y0,X0,X0
				add     #FoscStates,X0
				move    X0,X:(R2)
				move    X:(R2),R2
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     #31,X0
				blt     _L5
_L9:
				movei   #0,X:(R2)
				rts     


				ORG	X:
FoscStates      BSC			256
FfreeOscStateListBSC			1

				ENDSEC
				END

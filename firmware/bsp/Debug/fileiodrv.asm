
				SECTION fileiodrv
				include "asmdef.h"
				ORG	P:
FfileioOpen:
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
				moves   R2,X:<mr10
				movei   #S25,R3
				moves   X:<mr10,R2
				movei   #5,Y0
				jsr     Fstrncmp
				tstw    Y0
				jne     _L58
				move    X:(SP-13),X0
				cmp     #2,X0
				bne     _L7
				moves   #FFileIO,X:<mr9
				moves   #FfileDriverWrite,X:<mr11
				bra     _L9
_L7:
				movei   #FFileIO+8,R0
				move    R0,X:<mr9
				moves   #FfileDriverRead,X:<mr11
_L9:
				moves   X:<mr9,R0
				move    X:(SP-13),X0
				move    X0,X:(R0)
				moves   X:<mr9,R2
				nop     
				movei   #0,X:(R2+2)
				moves   X:<mr9,R2
				nop     
				movei   #0,X:(R2+4)
				movei   #0,X:(R2+5)
				moves   X:<mr9,R2
				nop     
				movei   #0,X:(R2+6)
				movei   #0,X:(R2+7)
				movei   #0,X0
				push    X0
				movei   #4560,R2
				jsr     Fopen
				pop     
				move    Y0,X:FPortD
				andc    #-97,X:11d3
				orc     #96,X:11d2
				orc     #64,X:11d1
				andc    #-33,X:11d1
				movei   #0,X:(SP-2)
				movei   #0,X0
				move    X0,X:(SP-1)
				movei   #15,X0
				move    X0,X:(SP)
				tstw    X:FbUartIsOpened
				bne     _L30
				movec   SP,R0
				lea     (R0-2)
				push    R0
				movei   #3,X0
				push    X0
				movei   #30,R2
				jsr     Fopen
				lea     (SP-2)
				move    Y0,X:<mr8
				movei   #-1,X0
				cmp     X:<mr8,X0
				bne     _L25
				debug   
_L25:
				movei   #1,X:FbUartIsOpened
				moves   X:<mr8,X0
				move    X0,X:FFileIO+9
				moves   X:<mr8,X0
				move    X0,X:FFileIO+1
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				clr     B
				movec   B0,X0
				movec   X0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				bra     _L31
_L30:
				move    X:FFileIO+1,X0
				move    X0,X:<mr8
_L31:
				movei   #79,X:(SP-5)
				movei   #S26,R3
				moves   X:<mr10,R2
				movei   #18,Y0
				jsr     Fstrncmp
				tstw    Y0
				jeq     _L45
				moves   X:<mr10,R2
				jsr     Fstrlen
				sub     #4,Y0
				move    Y0,X:(SP-3)
				movei   #78,X:(SP-4)
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
				movei   #3,Y1
				movei   #_L36,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L36:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+5)
				movei   #1,Y1
				movei   #_L38,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L38:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #S27,R2
				movei   #1,Y1
				movei   #_L40,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L40:
				moves   X:<mr10,R2
				jsr     Fstrlen
				sub     #6,Y0
				move    Y0,X:(SP-6)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+6)
				move    X:(SP-6),Y1
				movei   #_L43,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L43:
				bra     _L51
_L45:
				moves   X:<mr10,R2
				jsr     Fstrlen
				sub     #18,Y0
				move    Y0,X:(SP-3)
				movei   #83,X:(SP-4)
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
				movei   #3,Y1
				movei   #_L48,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L48:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+18)
				move    X:(SP-3),Y1
				movei   #_L50,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L50:
_L51:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				nop     
				lea     (R2-13)
				movei   #1,Y1
				movei   #_L52,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L52:
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
				moves   X:<mr9,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				movei   #2,Y1
				movei   #_L55,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L55:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				clr     B
				movec   B0,X0
				movec   X0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				bra     _L59
_L58:
				movei   #-1,R2
				bra     _L62
_L59:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				movei   #-1,A
				movei   #-1,A0
				cmp     A,B
				bne     _L61
				movei   #-1,R2
				bra     _L62
_L61:
				moves   X:<mr11,R2
_L62:
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


				ORG	P:
FfileioClose:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   Y0,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:<mr8
				movei   #67,X0
				move    X0,X:(SP-1)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				nop     
				lea     (R2)-
				movei   #2,Y1
				movei   #_L6,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L6:
				move    X:FPortD,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				move    X:FPortD,R2
				nop     
				move    X:(R2+1),Y0
				movei   #_L8,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L8:
				movei   #1,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FfileioRead:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #10,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				moves   Y1,X:<mr11
				move    X:(SP),R0
				move    R0,X:(SP-9)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:<mr8
				moves   #127,X:<mr9
				movei   #S35,R0
				nop     
				move    X:(R0)+,X0
				move    X0,X:(SP-8)
				move    X:(R0)+,X0
				move    X0,X:(SP-7)
				move    X:(R0),X0
				move    X0,X:(SP-6)
				move    X:(SP-1),R0
				move    R0,X:<mr10
				movei   #0,X:(SP-4)
				move    X:(SP-9),R2
				move    X:(SP-9),R0
				move    X:(R0+7),B
				move    X:(R0+6),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
_L9:
				movei   #127,X0
				cmp     X:<mr11,X0
				bls     _L11
				moves   X:<mr11,X0
				move    X0,X:<mr9
_L11:
				move    X:(SP-9),R2
				nop     
				move    X:(R2+2),X0
				cmp     #1,X0
				jne     _L22
				moves   X:<mr9,X0
				lsl     X0
				move    X0,X:(SP-6)
				move    X:(SP-6),B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     A,B
				bls     _L15
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movec   B0,X0
				move    X0,X:(SP-6)
_L15:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				lea     (R2-8)
				movei   #3,Y1
				movei   #_L16,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L16:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_DATAFORMAT_RAW
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr9,Y1
				moves   X:<mr10,R2
				movei   #_L19,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L19:
				move    Y0,X:(SP-5)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				bra     _L29
_L22:
				moves   X:<mr9,X0
				move    X0,X:(SP-6)
				move    X:(SP-6),B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     A,B
				bls     _L25
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movec   B0,X0
				move    X0,X:(SP-6)
_L25:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   SP,R2
				lea     (R2-8)
				movei   #3,Y1
				movei   #_L26,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L26:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr9,Y1
				moves   X:<mr10,R2
				movei   #_L28,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L28:
				move    Y0,X:(SP-5)
_L29:
				move    X:(SP-5),X0
				add     X:(SP-4),X0
				move    X0,X:(SP-4)
				moves   X:<mr9,X0
				add     X:<mr10,X0
				move    X0,X:<mr10
				moves   X:<mr11,X0
				sub     X:<mr9,X0
				move    X0,X:<mr11
				tstw    X0
				movei   #0,Y0
				beq     _L33
				movei   #1,Y0
_L33:
				clr     B
				move    X:(SP-4),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     A,B
				movei   #0,X0
				bhs     _L35
				movei   #1,X0
_L35:
				and     Y0,X0
				tstw    X0
				jne     _L9
				move    X:(SP-9),R2
				clr     B
				move    X:(SP-4),B0
				move    X:(R2+7),A
				move    X:(R2+6),A0
				add     A,B
				move    B1,X:(R2+7)
				move    B0,X:(R2+6)
				move    X:(SP-4),Y0
				lea     (SP-10)
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
FfileioWrite:
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
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				moves   Y1,X:<mr11
				move    X:(SP),R0
				move    R0,X:(SP-6)
				movei   #S57,R0
				nop     
				move    X:(R0)+,X0
				move    X0,X:(SP-5)
				move    X:(R0)+,X0
				move    X0,X:(SP-4)
				move    X:(R0),X0
				move    X0,X:(SP-3)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:<mr8
				moves   #127,X:<mr9
				move    X:(SP-1),R0
				move    R0,X:<mr10
				moves   X:<mr11,X0
				move    X0,X:(SP-2)
_L8:
				movei   #127,X0
				cmp     X:<mr11,X0
				bls     _L10
				moves   X:<mr11,X0
				move    X0,X:<mr9
_L10:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+2),X0
				cmp     #1,X0
				bne     _L19
				moves   X:<mr9,X0
				lsl     X0
				move    X0,X:(SP-3)
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
				movei   #3,Y1
				movei   #_L13,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L13:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_DATAFORMAT_RAW
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr9,Y1
				moves   X:<mr10,R2
				movei   #_L16,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L16:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				bra     _L24
_L19:
				moves   X:<mr9,X0
				move    X0,X:(SP-3)
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
				movei   #3,Y1
				movei   #_L21,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L21:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				moves   X:<mr9,Y1
				moves   X:<mr10,R2
				movei   #_L23,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L23:
_L24:
				moves   X:<mr9,X0
				add     X:<mr10,X0
				move    X0,X:<mr10
				moves   X:<mr11,X0
				sub     X:<mr9,X0
				move    X0,X:<mr11
				tstw    X0
				jne     _L8
				move    X:(SP-6),R2
				clr     B
				move    X:(SP-2),B0
				move    X:(R2+7),A
				move    X:(R2+6),A0
				add     A,B
				move    B1,X:(R2+7)
				move    B0,X:(R2+6)
				move    X:(SP-6),R2
				clr     B
				move    X:(SP-2),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(SP-2),Y0
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


				GLOBAL FfileioIoctl
				ORG	P:
FfileioIoctl:
				moves   Y1,X:<mr2
				movec   Y0,R2
				move    X:(SP-2),R3
				moves   X:<mr2,X0
				cmp     #3,X0
				beq     _L15
				bge     _L9
				cmp     #1,X0
				beq     _L13
				bge     _L11
				bra     _L18
_L9:
				cmp     #5,X0
				bge     _L18
				bra     _L17
_L11:
				movei   #1,X:(R2+2)
				bra     _L18
_L13:
				movei   #0,X:(R2+2)
				bra     _L18
_L15:
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(R3+1)
				move    B0,X:(R3)
				bra     _L18
_L17:
				move    X:(R2+7),B
				move    X:(R2+6),B0
				move    B1,X:(R3+1)
				move    B0,X:(R3)
_L18:
				movei   #0,Y0
				rts     


				GLOBAL FfileioDevCreat
				ORG	P:
FfileioDevCreat:
				movei   #FfileioOpen,R2
				jsr     FioDrvInstall
				movei   #1,Y0
				rts     


				ORG	X:
FInterfaceVT    DC			FfileioClose,FbUartIsOpened,FfileDriverWrite,FFileIO
FbUartIsOpened  BSC			1
FfileDriverWriteDC			FInterfaceVT,FfileioIoctl
FfileDriverRead DC			FInterfaceVT,FfileioIoctl
S25             DC			'\','\','P','C','\',0
S26             DC			'\','\','P','C','\','E','m','b'
				DC			'e','d','d','e','d',' ','S','D'
				DC			'K','\',0
S27             DC			':',0
S35             DC			82,127,0
S57             DC			87,127,0
FPortD          BSC			1
FFileIO         BSC			16

				ENDSEC
				END

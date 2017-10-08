
				SECTION spidrv
				include "asmdef.h"
				ORG	P:
FSlaveSelect0:
				andc    #-17,X:11b1
				rts     


				ORG	P:
FSlaveDeselect0:
				orc     #16,X:11b1
				rts     


				ORG	P:
FSlaveSelect1:
				andc    #-129,X:11f1
				rts     


				ORG	P:
FSlaveDeselect1:
				orc     #128,X:11f1
				rts     


				GLOBAL FspiOpen
				ORG	P:
FspiOpen:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr10
				moves   R3,X:<mr8
				moves   X:<mr10,X0
				cmp     #31,X0
				jne     _L31
				movei   #FspidrvDevice,R0
				move    R0,X:(SP)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+7)
				andc    #-513,X:FArchIO
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				jne     _L23
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+1)
				andc    #-17,X:11b3
				orc     #16,X:11b2
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+2)
				bne     _L14
				movei   #FSlaveSelect0,R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+4)
				movei   #FSlaveDeselect0,R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+5)
				bra     _L16
_L14:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+4)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+5)
_L16:
				bfclr   #2,X:FArchIO+320
				move    X:(SP),R2
				nop     
				move    X:(R2+5),R0
				movei   #_L18,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L18:
				bfclr   #4,X:FArchIO+435
				movei   #80,X:FArchIO+320
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+321
				bfset   #2,X:FArchIO+320
				jmp     _L61
_L23:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+1)
				bfclr   #2,X:FArchIO+320
				bfset   #4,X:FArchIO+435
				movei   #64,X:FArchIO+320
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+321
				bfset   #2,X:FArchIO+320
				move    X:FArchIO+322,X0
				move    X0,X:<mr9
				jmp     _L61
_L31:
				moves   X:<mr10,X0
				cmp     #32,X0
				jne     _L60
				movei   #FspidrvDevice+8,R0
				move    R0,X:(SP)
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+7)
				bfset   #112,X:FArchIO+499
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				jne     _L52
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+1)
				andc    #-129,X:11f3
				orc     #128,X:11f2
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+2)
				bne     _L43
				movei   #FSlaveSelect1,R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+4)
				movei   #FSlaveDeselect1,R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+5)
				bra     _L45
_L43:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+4)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+5)
_L45:
				bfclr   #2,X:FArchIO+336
				move    X:(SP),R2
				nop     
				move    X:(R2+5),R0
				movei   #_L47,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L47:
				bfclr   #128,X:FArchIO+499
				movei   #80,X:FArchIO+336
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+337
				bfset   #2,X:FArchIO+336
				bra     _L61
_L52:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+1)
				bfclr   #2,X:FArchIO+336
				bfset   #128,X:FArchIO+499
				movei   #64,X:FArchIO+336
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+337
				bfset   #2,X:FArchIO+336
				move    X:FArchIO+338,X0
				move    X0,X:<mr9
				bra     _L61
_L60:
				movei   #-1,Y0
				bra     _L64
_L61:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+6)
				move    X:(SP),R0
				movei   #0,X0
				move    X0,X:(R0)
				move    X:(SP),Y0
_L64:
				lea     (SP)-
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FspiClose
				ORG	P:
FspiClose:
				movei   #0,Y0
				rts     


				GLOBAL FspiRead
				ORG	P:
FspiRead:
				moves   Y1,X:<mr3
				movec   Y0,R3
				moves   #1,X:<mr2
				move    X:(R3+1),X0
				cmp     #1,X0
				bne     _L7
				movec   Y0,R0
				move    X:(R0+3),X0
				move    X0,X:(R2)
				bra     _L24
_L7:
				tstw    X:(R3+7)
				bne     _L17
				tstw    X:(R3+1)
				bne     _L17
				moves   #0,X:<mr2
				bra     _L15
_L11:
				bftsth  #8192,X:FArchIO+320
				bcc     _L11
				move    X:FArchIO+322,X0
				moves   X:<mr2,N
				move    X0,X:(R2+N)
				inc     X:<mr2
_L15:
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blo     _L11
				bra     _L24
_L17:
				moves   #0,X:<mr2
				bra     _L23
_L19:
				bftsth  #8192,X:FArchIO+336
				bcc     _L19
				move    X:FArchIO+338,X0
				moves   X:<mr2,N
				move    X0,X:(R2+N)
				inc     X:<mr2
_L23:
				moves   X:<mr2,X0
				cmp     X:<mr3,X0
				blo     _L19
_L24:
				moves   X:<mr2,Y0
				rts     


				ORG	P:
FSendBits:
				moves   #0,X:<mr2
				tstw    X:(R2+7)
				bne     _L8
				move    Y0,X:FArchIO+323
_L4:
				bftsth  #8192,X:FArchIO+320
				bcc     _L4
				move    X:FArchIO+322,X0
				move    X0,X:<mr2
				bra     _L13
_L8:
				move    X:(R2+7),X0
				cmp     #1,X0
				bne     _L13
				move    Y0,X:FArchIO+339
_L10:
				bftsth  #8192,X:FArchIO+336
				bcc     _L10
				move    X:FArchIO+338,X0
				move    X0,X:<mr2
_L13:
				moves   X:<mr2,Y0
				rts     


				GLOBAL FspiWrite
				ORG	P:
FspiWrite:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				moves   Y1,X:<mr10
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-1),R0
				move    R0,X:<mr9
				move    X:(SP-2),R2
				nop     
				move    X:(R2+1),X0
				cmp     #1,X0
				bne     _L6
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),R0
				movei   #_L6,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L6:
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+6)
				bne     _L13
				tstw    X:<mr10
				beq     _L23
_L8:
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				move    X:(SP-2),R2
				jsr     FSendBits
				move    X:(SP-2),R2
				nop     
				move    Y0,X:(R2+3)
				inc     X:<mr9
				dec     X:<mr10
				tstw    X:<mr10
				bne     _L8
				bra     _L23
_L13:
				tstw    X:<mr10
				beq     _L23
_L14:
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X0,X:<mr8
				move    X:(SP-2),R2
				moves   X:<mr8,Y0
				jsr     FSendBits
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				andc    #-256,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+3)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				move    X:(SP-2),R2
				moves   X:<mr8,Y0
				jsr     FSendBits
				move    Y0,X:<mr8
				move    X:(SP-2),R2
				moves   X:<mr8,Y1
				andc    #255,Y1
				move    X:(R2+3),X0
				or      X0,Y1
				move    X:(SP-2),R2
				nop     
				move    Y1,X:(R2+3)
				inc     X:<mr9
				dec     X:<mr10
				tstw    X:<mr10
				bne     _L14
_L23:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+1),X0
				cmp     #1,X0
				bne     _L25
				move    X:(SP-2),R2
				nop     
				move    X:(R2+5),R0
				movei   #_L25,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L25:
				moves   X:<mr10,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
FPortF          BSC			1
FPortB          BSC			1
FspidrvDevice   BSC			16

				ENDSEC
				END

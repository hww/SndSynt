
				SECTION terminal
				include "asmdef.h"
				GLOBAL FterminalUpdate
				ORG	P:
FterminalUpdate:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				lea     (SP)+
				move    X:FkbdPhase,Y0
				andc    #3,Y0
				movei   #4,X0
				lsll    Y0,X0,X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				lsr     X0
				lsr     X0
				move    X0,X:<mr8
				moves   X:<mr8,X0
				movei   #15,Y0
				lsll    Y0,X0,X0
				move    X0,X:<mr11
				moves   X:<mr9,X0
				orc     #128,X0
				move    X0,X:FArchIO+433
				movei   #240,X:FArchIO+434
				move    X:FArchIO+433,Y0
				not     Y0
				andc    #15,Y0
				moves   X:<mr8,X0
				lsll    Y0,X0,X0
				move    X0,X:<mr10
				move    X:FkbdState,X0
				move    X0,X:(SP)
				moves   X:<mr11,X0
				not     X0
				move    X:FkbdState,Y0
				and     Y0,X0
				moves   X:<mr10,Y1
				move    X:FkbdDelay,Y0
				and     Y0,Y1
				or      X0,Y1
				move    Y1,X:FkbdState
				moves   X:<mr11,Y0
				not     Y0
				move    X:FkbdDelay,X0
				and     X0,Y0
				moves   X:<mr10,X0
				or      X0,Y0
				move    Y0,X:FkbdDelay
				move    X:(SP),X0
				not     X0
				move    X:FkbdState,Y0
				and     X0,Y0
				move    X:FkbdTrig,X0
				or      X0,Y0
				move    Y0,X:FkbdTrig
				movei   #255,X:FArchIO+434
				moves   X:<mr9,Y1
				orc     #64,Y1
				moves   X:<mr8,X0
				move    X:FledState,Y0
				lsrr    Y0,X0,X0
				not     X0
				andc    #15,X0
				or      Y1,X0
				move    X0,X:FArchIO+433
				inc     X:FkbdPhase
				move    X:FkbdPhase,X0
				andc    #63,X0
				tstw    X0
				bne     _L16
				jsr     FterminalAnimate
_L16:
				lea     (SP)-
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FterminalOpen
				ORG	P:
FterminalOpen:
				movei   #8,N
				lea     (SP)+N
				movei   #0,X:FArchIO+435
				movei   #192,X:FArchIO+433
				movei   #255,X:FArchIO+434
				movei   #0,X:FkbdPhase
				movei   #0,X:FledStatic
				movei   #0,X:FledFlash
				movei   #0,X:FledAnimation
				movei   #FterminalUpdate,R0
				move    R0,X:FtermTimerEvent+3
				movei   #FtermTimerEvent,R2
				movei   #FtermTimer,R3
				movei   #1,Y0
				jsr     Ftimer_create
				movei   #0,X:(SP-7)
				movei   #0,X:(SP-6)
				movei   #33920,X:(SP-5)
				movei   #30,X:(SP-4)
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				movei   #30,B
				movei   #-31616,B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				movec   SP,R2
				lea     (R2-7)
				move    X:FtermTimer,Y0
				movei   #0,Y1
				movei   #0,R3
				jsr     Ftimer_settime
				lea     (SP-8)
				rts     


				GLOBAL FterminalRead
				ORG	P:
FterminalRead:
				tstw    X:FkbdTrig
				bne     _L3
				movei   #-1,Y0
				bra     _L12
_L3:
				moves   #1,X:<mr3
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     #16,X0
				bhs     _L12
_L6:
				move    X:FkbdTrig,Y1
				moves   X:<mr3,X0
				and     X0,Y1
				tstw    Y1
				beq     _L9
				moves   X:<mr3,Y0
				not     Y0
				move    X:FkbdTrig,X0
				and     X0,Y0
				move    Y0,X:FkbdTrig
				moves   X:<mr2,Y0
				bra     _L12
_L9:
				moves   X:<mr3,X0
				lsl     X0
				move    X0,X:<mr3
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     #16,X0
				blo     _L6
_L12:
				rts     


				GLOBAL FterminalState
				ORG	P:
FterminalState:
				move    X:FkbdState,Y0
				rts     


				GLOBAL FterminalAnimate
				ORG	P:
FterminalAnimate:
				moves   #0,X:<mr2
				tstw    X:FledAnimation
				beq     _L7
				move    X:FledAnimation,X0
				movec   X0,R0
				nop     
				lea     (R0)+
				move    X:FcurFrame,R1
				movec   R1,N
				move    X:(R0+N),X0
				move    X0,X:<mr2
				inc     X:FcurFrame
				move    X:FledAnimation,R0
				move    X:FcurFrame,Y0
				move    X:(R0),X0
				cmp     X0,Y0
				blo     _L7
				movei   #0,X:FcurFrame
_L7:
				moves   X:<mr2,Y0
				move    X:FledStatic,X0
				or      X0,Y0
				move    X:FledFlash,X0
				eor     X0,Y0
				move    Y0,X:FledState
				movei   #0,X:FledFlash
				rts     


				GLOBAL FterminalSetAnimate
				ORG	P:
FterminalSetAnimate:
				move    R2,X:FledAnimation
				movei   #0,X:FcurFrame
				rts     


				ORG	X:
FstdAnimeR      DC			5,256,512,1024,2048,4096
FstdAnimeL      DC			5,4096,2048,1024,512,256
FstdAnimePP     DC			8,256,512,1024,2048,4096,2048,1024
				DC			512
FstdAnimeM      DC			4,4352,2560,1024,2560
FstdLevels      DC			0,256,768,1792,3840,7936
FstdPos         DC			0,256,512,1024,2048,4096
FtermTimer      BSC			1
FtermTimerEvent BSC			4
FledFlashing    BSC			1
FledStatic      BSC			1
FledFlash       BSC			1
FcurFrame       BSC			1
FledAnimation   BSC			1
FkbdPhase       BSC			1
FledState       BSC			1
FkbdDelay       BSC			1
FkbdTrig        BSC			1
FkbdState       BSC			1

				ENDSEC
				END

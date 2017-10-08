
				SECTION toddrv
				include "asmdef.h"
				ORG	P:
FCalculateControlMask:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   #0,X:<mr8
				movec   SP,R2
				nop     
				lea     (R2)-
				jsr     Flocaltime
				move    R2,X:(SP-2)
				move    X:(SP-2),R0
				nop     
				tstw    X:(R0)
				ble     _L7
				orc     #16,X:<mr8
				bra     _L8
_L7:
				andc    #-17,X:<mr8
_L8:
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+1)
				ble     _L11
				orc     #32,X:<mr8
				bra     _L12
_L11:
				andc    #-33,X:<mr8
_L12:
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+2)
				ble     _L15
				orc     #64,X:<mr8
				bra     _L16
_L15:
				andc    #-65,X:<mr8
_L16:
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+7)
				ble     _L19
				orc     #128,X:<mr8
				bra     _L20
_L19:
				andc    #-129,X:<mr8
_L20:
				moves   X:<mr8,Y0
				orc     #16388,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FTodAlarmCallBack:
				move    X:<mr8,N
				push    N
				move    X:FTodAlarmInterrupt,X0
				move    X0,X:<mr8
				tstw    X:FTodAlarmInterrupt+11
				beq     _L5
				movei   #FTodAlarmInterrupt+10,R0
				nop     
				move    X:(R0),X0
				push    X0
				move    X:FTodAlarmInterrupt+11,R1
				movei   #_L4,R2
				push    R2
				push    SR
				push    R1
				push    SR
				rts     
_L4:
				pop     
_L5:
				move    X:FTodAlarmInterrupt+1,X0
				move    X0,X:FArchIO+195
				move    X:FTodAlarmInterrupt+2,X0
				move    X0,X:FArchIO+197
				move    X:FTodAlarmInterrupt+3,X0
				move    X0,X:FArchIO+199
				move    X:FTodAlarmInterrupt+8,X0
				move    X0,X:FArchIO+201
				move    X:FArchIO+192,Y0
				andc    #-241,Y0
				moves   X:<mr8,X0
				or      X0,Y0
				move    Y0,X:<mr8
				moves   X:<mr8,X0
				move    X0,X:FArchIO+192
				andc    #-16385,X:FArchIO+192
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FTodOneSecCallBack:
				tstw    X:FTodOneSecInterrupt+11
				beq     _L4
				movei   #FTodOneSecInterrupt+10,R0
				nop     
				move    X:(R0),X0
				push    X0
				move    X:FTodOneSecInterrupt+11,R1
				movei   #_L3,R2
				push    R2
				push    SR
				push    R1
				push    SR
				rts     
_L3:
				pop     
_L4:
				andc    #32767,X:FArchIO+192
				rts     


				GLOBAL FtodOpen
				ORG	P:
FtodOpen:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R0
				move    R0,X:<mr10
				moves   #0,X:<mr9
				moves   #0,X:<mr11
				move    X:(SP),X0
				cmp     #33,X0
				beq     _L7
				movei   #-1,Y0
				bra     _L18
_L7:
				moves   X:<mr11,X0
				move    X0,X:FArchIO+192
				moves   X:<mr10,R2
				jsr     Flocaltime
				move    R2,X:<mr8
				andc    #-2,X:FArchIO+192
				move    X:FTodClockScaler,X0
				move    X0,X:FArchIO+193
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				inc     X0
				move    X0,X:(R0)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:FArchIO+194
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+196
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:FArchIO+198
				moves   X:<mr8,R2
				movei   #365,Y0
				move    X:(R2+5),X0
				impy    Y0,X0,Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),X0
				add     X0,Y0
				move    Y0,X:<mr9
				moves   X:<mr9,X0
				move    X0,X:FArchIO+200
				movei   #0,Y0
_L18:
				lea     (SP-2)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FtodEnableCallBacks
				ORG	P:
FtodEnableCallBacks:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				cmp     #34,X0
				bne     _L7
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),R0
				move    R0,X:FTodAlarmInterrupt+11
				move    X:(SP-1),R2
				nop     
				lea     (R2)+
				movei   #FTodAlarmInterrupt+10,R0
				move    X:(R2),X0
				move    X0,X:(R0)
				move    X:FpArchInterrupts,X0
				movec   X0,R2
				lea     (R2+66)
				movei   #FTodAlarmCallBack,R3
				jsr     FarchInstallISR
_L7:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				cmp     #35,X0
				bne     _L11
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),R0
				move    R0,X:FTodOneSecInterrupt+11
				move    X:(SP-1),R2
				nop     
				lea     (R2)+
				movei   #FTodOneSecInterrupt+10,R0
				move    X:(R2),X0
				move    X0,X:(R0)
				move    X:FpArchInterrupts,X0
				movec   X0,R2
				lea     (R2+64)
				movei   #FTodOneSecCallBack,R3
				jsr     FarchInstallISR
_L11:
				movei   #0,Y0
				lea     (SP-2)
				rts     


				GLOBAL FtodSetAlarm
				ORG	P:
FtodSetAlarm:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				jsr     Flocaltime
				move    R2,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:FArchIO+195
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FArchIO+197
				move    X:(SP),R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:FArchIO+199
				move    X:(SP),R2
				nop     
				move    X:(R2+7),X0
				move    X0,X:FArchIO+201
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),A
				move    X:(R2+4),A0
				jsr     FCalculateControlMask
				move    Y0,X:<mr9
				move    X:FArchIO+192,Y0
				andc    #-241,Y0
				moves   X:<mr9,X0
				or      X0,Y0
				move    Y0,X:<mr9
				moves   X:<mr9,X0
				move    X0,X:FArchIO+192
				moves   X:<mr8,R2
				jsr     Flocaltime
				move    R2,X:(SP)
				movei   #FTodAlarmInterrupt+1,R2
				move    X:(SP),R3
				movei   #9,Y0
				jsr     FmemMemcpy
				movei   #365,Y0
				move    X:FTodAlarmInterrupt+6,X0
				impy    Y0,X0,X0
				add     X:FTodAlarmInterrupt+8,X0
				move    X0,X:FTodAlarmInterrupt+8
				moves   X:<mr8,R0
				move    X:(R0+1),A
				move    X:(R0),A0
				jsr     FCalculateControlMask
				move    Y0,X:FTodAlarmInterrupt
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FtodGetTime
				ORG	P:
FtodGetTime:
				movei   #0,X:(R2)
				movei   #0,X:(R2+1)
				movei   #0,X:(R2+2)
				movei   #0,X:(R2+3)
				movei   #0,X:(R2+4)
				movei   #0,X:(R2+5)
				movei   #0,X:(R2+6)
				movei   #0,X:(R2+7)
				movei   #0,X:(R2+8)
				move    X:FArchIO+194,X0
				move    X0,X:(R2)
				move    X:FArchIO+196,X0
				move    X0,X:(R2+1)
				move    X:FArchIO+198,X0
				move    X0,X:(R2+2)
				move    X:FArchIO+200,X0
				inc     X0
				move    X0,X:(R2+3)
				rts     


				GLOBAL FtodClose
				ORG	P:
FtodClose:
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				move    X0,X:FArchIO+192
				movei   #0,Y0
				rts     


				ORG	X:
FTodOneSecInterruptBSC			12
FTodAlarmInterruptBSC			12

				ENDSEC
				END

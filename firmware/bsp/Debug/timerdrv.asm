
				SECTION timerdrv
				include "asmdef.h"
				ORG	P:
FTimerCallback:
				lea     (SP)+
				move    A0,X:(SP)+
				move    A1,X:(SP)+
				move    A2,X:(SP)+
				move    Y1,X:(SP)
				move    X:(R2+3),A
				move    X:(R2+2),A0
				movei   #1,Y0
				clr     Y1
				sub     Y,A
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				bne     _L27
				move    X:(R2+5),A
				move    X:(R2+4),A0
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				lea     (SP)+
				move    #_L27,Y0
				move    X:(R2+1),R2
				move    Y0,X:(SP)+
				move    SR,X:(SP)+
				move    R2,X:(SP)+
				move    SR,X:(SP)
				movei   #0,Y0
				rts     
				pop     Y1
				pop     A2
				pop     A1
				pop     A0
				rts     


				ORG	P:
FtimerRealTimeClockISR:
				lea     (SP)+
				move    A0,X:(SP)+
				move    A1,X:(SP)+
				move    A2,X:(SP)+
				move    B0,X:(SP)+
				move    B1,X:(SP)+
				move    B2,X:(SP)
				move    X:FtimerRTElapsedTime+3,B
				move    X:FtimerRTElapsedTime+2,B0
				move    X:FtimerTickDuration+3,A
				move    X:FtimerTickDuration+2,A0
				add     A,B
				move    B1,X:FtimerRTElapsedTime+3
				move    B0,X:FtimerRTElapsedTime+2
				movei   #15258,A
				movei   #-13824,A0
				cmp     A,B
				blt     _L29
				sub     A,B
				move    B1,X:FtimerRTElapsedTime+3
				move    B0,X:FtimerRTElapsedTime+2
				clr     B
				movei   #1,B0
				move    X:FtimerRTElapsedTime+1,A
				move    X:FtimerRTElapsedTime,A0
				add     A,B
				move    B1,X:FtimerRTElapsedTime+1
				move    B0,X:FtimerRTElapsedTime
				jsr     FtimerTick
				pop     B2
				pop     B1
				pop     B0
				pop     A2
				pop     A1
				pop     A0
				rti     


				GLOBAL FtimerSetTime
				ORG	P:
FtimerSetTime:
				movei   #18,N
				lea     (SP)+N
				movei   #FSizeOfPOSIXDevice,R3
				nop     
				move    X:(R3),X0
				impy    Y0,X0,Y0
				movei   #FPOSIXTimerContext,R3
				nop     
				move    X:(R3),R3
				move    Y0,N
				nop     
				lea     (R3)+N
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(R2+1),A
				move    X:(R2),A0
				cmp     A,B
				beq     _L22
				debug   
				move    X:(R2+7),Y1
				move    X:(R2+6),Y0
				move    Y1,X:(SP-2)
				move    Y0,X:(SP-3)
				move    X:(R2+3),A
				move    X:(R2+2),A0
				move    Y1,B
				move    Y0,B0
				cmp     A,B
				beq     _L33
				debug   
				move    R3,R2
				movei   #15258,A
				movei   #-13824,A0
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-16)
				move    Y0,X:(SP-17)
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #15,A
				movei   #16960,A0
				move    B1,Y1
				move    B0,Y0
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-14)
				move    Y0,X:(SP-15)
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				clr     A
				movei   #10000,A0
				move    B1,Y1
				move    B0,Y0
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-12)
				move    Y0,X:(SP-13)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    X:(SP-16),A
				move    X:(SP-17),A0
				add     A,B
				move    B1,X:(SP-16)
				move    B0,X:(SP-17)
				movei   #0,X:(SP-1)
				move    X:(SP-16),A
				move    X:(SP-17),A0
				tst     A
				beq     _L81
				move    X:FqtINPUT_FREQUENCY+1,Y1
				move    X:FqtINPUT_FREQUENCY,Y0
				jsr     FQuickMpyU32U
				moves   X:(SP-1),X0
				clr     A
				movei   #1,A0
				rep     X0
				asl     A
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-10)
				move    Y0,X:(SP-11)
				bra     _L84
				clr     X0
				move    X0,X:(SP-11)
				move    X0,X:(SP-10)
				tstw    X:(SP-10)
				jne     _L135
				clr     A
				movei   #1000,A0
				move    X:FqtINPUT_FREQUENCY+1,Y1
				move    X:FqtINPUT_FREQUENCY,Y0
				jsr     FQuickDivU32UZ
				move    X:(SP-14),A
				move    X:(SP-15),A0
				jsr     FQuickMpyU32U
				move    X:(SP-1),X0
				clr     A
				movei   #1,A0
				rep     X0
				asl     A
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-8)
				move    Y0,X:(SP-9)
				tstw    Y1
				bne     _L135
				move    X:(SP-10),A
				move    X:(SP-11),A0
				add     Y,A
				tstw    A1
				bne     _L135
				movei   #1,A1
				movei   #-31072,A0
				move    X:FqtINPUT_FREQUENCY+1,Y1
				move    X:FqtINPUT_FREQUENCY,Y0
				jsr     FQuickDivU32UZ
				move    X:(SP-12),A
				move    X:(SP-13),A0
				jsr     FQuickMpyU32U
				move    X:(SP-1),X0
				clr     A
				movei   #1,A0
				rep     X0
				asl     A
				jsr     FQuickDivU32UZ
				move    Y1,X:(SP-6)
				move    Y0,X:(SP-7)
				tstw    Y1
				bne     _L135
				move    X:(SP-10),A
				move    X:(SP-11),A0
				add     Y,A
				move    X:(SP-8),B
				move    X:(SP-9),B0
				add     A,B
				tstw    B1
				beq     _L139
				incw    X:(SP-1)
				movei   #32,X0
				cmp     X:(SP-1),X0
				jhi     _L65
				moves   X:(SP-1),X0
				sub     #7,X0
				bls     _L152
				clr     B
				movei   #1,B0
				rep     X0
				asl     B
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				movei   #7,X:(SP-1)
				bra     _L158
				clr     Y1
				movei   #1,Y0
				move    Y0,X:(R2+2)
				move    Y1,X:(R2+3)
				move    Y0,X:(R2+4)
				move    Y1,X:(R2+5)
				move    X:(SP-8),B
				move    X:(SP-9),B0
				move    X:(SP-10),A
				move    X:(SP-11),A0
				add     A,B
				move    X:(SP-6),A
				move    X:(SP-7),A0
				add     A,B
				move    B0,X:(SP)
				clr     A
				movei   #1,A0
				rep     X0
				asl     A
				move    X:FqtINPUT_FREQUENCY+1,Y1
				move    X:FqtINPUT_FREQUENCY,Y0
				jsr     FQuickDivU32UZ
				clr     A
				move    X:(SP),A0
				jsr     FQuickDivU32UZ
				move    Y1,X:(R2+7)
				move    Y0,X:(R2+6)
				moves   X:(SP),X0
				move    X0,X:FPOSIXTimerParam+4
				moves   X:(SP-1),Y0
				add     #8,Y0
				movei   #4,X0
				asll    Y0,X0,Y0
				move    X:FPOSIXTimerParam,X0
				bfclr   #240,X0
				or      Y0,X0
				move    X0,X:FPOSIXTimerParam
				clr     Y0
				lea     (SP-18)
				rts     


				GLOBAL Ftimer_create
				ORG	P:
Ftimer_create:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr9
				moves   R2,X:<mr8
				moves   R3,X:<mr10
				movei   #33,X0
				cmp     X:<mr9,X0
				bne     _L7
				move    X:FPOSIXTodContext,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,Y0
				moves   X:<mr8,R2
				movei   #_L4,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L4:
				moves   X:<mr8,R0
				moves   X:<mr10,R1
				move    X:(R0),X0
				move    X0,X:(R1)
				bra     _L13
_L7:
				movei   #11,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,X0
				add     X:FPOSIXTimerContext,X0
				move    X0,X:(SP)
				move    X:(SP),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+8)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+1)
				move    X:(SP),R2
				nop     
				move    X:(R2+9),R0
				moves   X:<mr9,R1
				nop     
				move    X:(R1+#FPOSIXDeviceList),R2
				movei   #0,Y0
				movei   #0,R3
				movei   #_L11,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L11:
				move    X:(SP),R0
				nop     
				move    Y0,X:(R0)
				moves   X:<mr10,R0
				moves   X:<mr9,X0
				move    X0,X:(R0)
_L13:
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftimer_delete
				ORG	P:
Ftimer_delete:
				move    X:<mr8,N
				push    N
				moves   Y0,X:<mr8
				movei   #33,X0
				cmp     X:<mr8,X0
				bne     _L6
				move    X:FPOSIXTodContext,R2
				nop     
				move    X:(R2+3),R0
				movei   #0,Y0
				movei   #_L4,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L4:
				bra     _L7
_L6:
				moves   X:<mr8,R0
				nop     
				move    X:(R0+#FPOSIXDeviceList),R2
				nop     
				andc    #8191,X:(R2+6)
_L7:
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftimer_settime
				ORG	P:
Ftimer_settime:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr8
				move    R2,X:(SP)
				movei   #34,X0
				cmp     X:<mr8,X0
				bne     _L7
				move    X:FPOSIXTodContext,R2
				nop     
				move    X:(R2+1),R0
				movei   #0,Y0
				move    X:(SP),R2
				movei   #_L4,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L4:
				orc     #4,X:10c0
				bra     _L14
_L7:
				movei   #35,X0
				cmp     X:<mr8,X0
				bne     _L10
				orc     #8,X:10c0
				bra     _L14
_L10:
				move    X:FPOSIXTimerContext,X0
				movei   #11,Y1
				moves   X:<mr8,Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+10)
				movec   Y0,N
				move    X:(R0+N),R1
				moves   X:<mr8,Y0
				move    X:(SP),R2
				movei   #_L11,R0
				push    R0
				push    SR
				push    R1
				push    SR
				rts     
_L11:
				move    X:FPOSIXTimerContext,X0
				movei   #11,Y1
				moves   X:<mr8,Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+8)
				movec   Y0,N
				move    X:(R0+N),R1
				move    R1,X:FPOSIXTimerParam+6
				moves   X:<mr8,R0
				nop     
				move    X:(R0+#FPOSIXDeviceList),R2
				jsr     FqtFindDevice
				movei   #FPOSIXTimerParam,R2
				jsr     FioctlQT_ENABLE
_L14:
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fclock_settime
				ORG	P:
Fclock_settime:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    X:(SP),X0
				cmp     #33,X0
				bne     _L6
				move    X:FPOSIXTodContext,R0
				nop     
				move    X:(R0),R1
				move    X:(SP-1),R3
				movei   #33,R2
				movei   #0,Y0
				movei   #_L4,R0
				push    R0
				push    SR
				push    R1
				push    SR
				rts     
_L4:
				orc     #1,X:10c0
_L6:
				movei   #0,Y0
				lea     (SP-2)
				rts     


				GLOBAL Fclock_gettime
				ORG	P:
Fclock_gettime:
				move    X:<mr8,N
				push    N
				movei   #11,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    X:(SP),X0
				cmp     #33,X0
				bne     _L8
				move    X:FPOSIXTodContext,R2
				nop     
				move    X:(R2+2),R0
				movec   SP,R2
				lea     (R2-10)
				movei   #_L4,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L4:
				move    X:FPOSIXTodContext,R2
				nop     
				move    X:(R2+5),R0
				movec   SP,R2
				lea     (R2-10)
				movei   #_L5,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L5:
				move    X:(SP-1),R0
				move    A1,X:(R0+1)
				move    A0,X:(R0)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+2)
				movei   #0,X:(R2+3)
				bra     _L11
_L8:
				move    X:FPOSIXDeviceList,R2
				nop     
				move    X:(R2+5),X0
				move    X0,X:<mr8
				move    X:FtimerNanosecPerCount,Y0
				moves   X:<mr8,X0
				move    X:FtimerRTElapsedTime+3,B
				move    X:FtimerRTElapsedTime+2,B0
				mac     Y0,X0,B
				asr     B
				move    X:(SP-1),R2
				nop     
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				move    X:(SP-1),R0
				move    X:FtimerRTElapsedTime+1,B
				move    X:FtimerRTElapsedTime,B0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L11:
				movei   #0,Y0
				lea     (SP-11)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fclock_getres
				ORG	P:
Fclock_getres:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    X:(SP-1),R0
				clr     B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				move    X:FPOSIXTimerContext,X0
				movei   #11,Y1
				move    X:(SP),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+6)
				movec   Y0,N
				lea     (R0)+N
				move    X:(R0+1),B
				move    X:(R0),B0
				push    B0
				push    B1
				movei   #15258,A
				movei   #-13824,A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+3)
				move    A0,X:(R2+2)
				movei   #0,Y0
				lea     (SP-2)
				rts     


				GLOBAL Fnanosleep
				ORG	P:
Fnanosleep:
				movei   #10,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L4
				movei   #-1,Y0
				jmp     _L14
_L4:
				move    X:FtimerTickNanoseconds+1,B
				move    X:FtimerTickNanoseconds,B0
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+3),A
				move    X:(R2+2),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    A1,X:(SP-6)
				move    A0,X:(SP-7)
				move    X:FtimerTickNanoseconds+1,B
				move    X:FtimerTickNanoseconds,B0
				push    B0
				push    B1
				move    X:(SP-8),A
				move    X:(SP-9),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				sub     A,B
				tst     B
				ble     _L7
				movei   #0,B
				movei   #1,B0
				move    X:(SP-6),A
				move    X:(SP-7),A0
				add     A,B
				move    B1,X:(SP-6)
				move    B0,X:(SP-7)
_L7:
				move    X:FtimerTickHZ+1,B
				move    X:FtimerTickHZ,B0
				push    B0
				push    B1
				move    X:(SP-2),R0
				move    X:(R0+1),A
				move    X:(R0),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP-6),B
				move    X:(SP-7),B0
				add     B,A
				move    A1,X:(SP-6)
				move    A0,X:(SP-7)
				movec   SP,R2
				lea     (R2-5)
				movei   #0,Y0
				jsr     Fclock_getres
				move    X:(SP-2),B
				move    X:(SP-3),B0
				push    B0
				push    B1
				move    X:FtimerTickNanoseconds+1,A
				move    X:FtimerTickNanoseconds,A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				push    A0
				push    A1
				move    X:(SP-8),A
				move    X:(SP-9),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-8)
				move    A0,X:(SP-9)
				move    X:(SP-8),B
				move    X:(SP-9),B0
				tst     B
				bne     _L12
				movei   #1,X:(SP-9)
				movei   #0,X:(SP-8)
_L12:
				move    X:(SP-8),A
				move    X:(SP-9),A0
				jsr     FtimerSleep
				movei   #0,Y0
_L14:
				lea     (SP-10)
				rts     


				GLOBAL FtimerCreate
				ORG	P:
FtimerCreate:
				movei   #FtimerRealTimeClockISR,R0
				move    R0,X:FRealTimeEvent+3
				movei   #FRealTimeEvent,R2
				movei   #FRealTimeTimer,R3
				movei   #0,Y0
				jsr     Ftimer_create
				movei   #0,X:FtimerTickDuration
				movei   #0,X:FtimerTickDuration+1
				move    X:FtimerTickNanoseconds+1,B
				move    X:FtimerTickNanoseconds,B0
				move    B1,X:FtimerTickDuration+3
				move    B0,X:FtimerTickDuration+2
				move    X:FPOSIXTimerContext,R2
				nop     
				movei   #1,X:(R2+2)
				movei   #0,X:(R2+3)
				move    X:FPOSIXTimerContext,R2
				nop     
				movei   #1,X:(R2+4)
				movei   #0,X:(R2+5)
				move    X:FtimerTickHZ+1,B
				move    X:FtimerTickHZ,B0
				move    X:FPOSIXTimerContext,R2
				nop     
				move    B1,X:(R2+7)
				move    B0,X:(R2+6)
				move    X:FtimerInputSource,Y0
				andc    #15,Y0
				movei   #4,X0
				lsll    Y0,X0,Y0
				move    X:FPOSIXTimerParam,X0
				andc    #-241,X0
				or      Y0,X0
				move    X0,X:FPOSIXTimerParam
				move    X:FtimerTickLoadValue,X0
				move    X0,X:FPOSIXTimerParam+4
				move    X:FPOSIXTimerContext,R2
				nop     
				move    X:(R2+8),R0
				move    R0,X:FPOSIXTimerParam+6
				move    X:FPOSIXDeviceList,R2
				jsr     FqtFindDevice
				movei   #FPOSIXTimerParam,R2
				jsr     FioctlQT_ENABLE
				movei   #0,Y0
				rts     


				ORG	X:
FtimerRTElapsedTimeDC			0,0,0,0
FPOSIXTimerParamDC			12417,16,0,0,-1,FTimerCallback,.debug_TimerCallback,.line_TimerCallback
				DC			FtimerRealTimeClockISR,FtimerTickDuration,FtimerTick
FSizeOfPOSIXDeviceDC			11
FtimerTickDurationBSC			4
FRealTimeTimer  BSC			1
FRealTimeEvent  BSC			4

				ENDSEC
				END

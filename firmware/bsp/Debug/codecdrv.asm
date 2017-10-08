
				SECTION codecdrv
				include "asmdef.h"
				GLOBAL Fsimple_ssiInitialize
				ORG	P:
Fsimple_ssiInitialize:
				orc     #63,X:FArchIO+451
				orc     #63,X:FArchIO+450
				move    X:(R2+5),X0
				move    X0,X:FArchIO+229
				move    X:(R2+4),X0
				move    X0,X:FArchIO+228
				move    X:(R2+2),X0
				move    X0,X:FArchIO+226
				move    X:(R2+3),X0
				move    X0,X:FArchIO+227
				move    X:(R2+7),X0
				move    X0,X:FArchIO+231
				move    X:(R2+9),X0
				move    X0,X:FArchIO+233
				rts     


				GLOBAL FcodecDevCreate
				ORG	P:
FcodecDevCreate:
				lea     (SP)+
				move    R3,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:FCodec
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FCodec+1
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:FCodec+2
				move    X:(SP),R2
				nop     
				move    X:(R2+3),R0
				move    R0,X:FCodec+3
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				move    X0,X:FCodec+4
				move    X:(SP),R2
				nop     
				move    X:(R2+6),X0
				move    X0,X:FCodec+6
				move    X:(SP),R2
				nop     
				move    X:(R2+7),X0
				move    X0,X:FCodec+7
				move    X:(SP),R2
				nop     
				move    X:(R2+5),X0
				move    X0,X:FCodec+5
				movei   #FcodecOpen,R2
				jsr     FioDrvInstall
				movei   #0,Y0
				lea     (SP)-
				rts     


				GLOBAL FcodecOpen
				ORG	P:
FcodecOpen:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),X0
				cmp     #11,X0
				beq     _L4
				movei   #65535,R2
				jmp     _L21
_L4:
				movei   #0,X:FCodec+8
				movei   #0,X:FCodec+10
				bftstl  #8,X:(SP-4)
				blo     _L8
				movei   #0,X0
				bra     _L9
_L8:
				movei   #1,X0
_L9:
				move    X0,X:FCodec+9
				move    X:FCodec+1,Y1
				move    X:FCodec,Y0
				jsr     FfifoCreate
				move    R2,X:FCodec+11
				move    X:FCodec+1,Y1
				move    X:FCodec,Y0
				jsr     FfifoCreate
				move    R2,X:FCodec+12
				movei   #0,X0
				push    X0
				movei   #4560,R2
				jsr     Fopen
				pop     
				move    Y0,X:(SP-1)
				andc    #-8,X:11d3
				orc     #7,X:11d2
				andc    #-2,X:11d1
				movei   #511,Y0
				jsr     Fcodec_send_cfg
				movei   #1023,Y0
				jsr     Fcodec_send_cfg
				movei   #1030,Y0
				jsr     Fcodec_send_cfg
				movei   #1682,Y0
				jsr     Fcodec_send_cfg
				movei   #FcodecdrvDriver,R2
_L21:
				lea     (SP-2)
				rts     


				GLOBAL FcodecClose
				ORG	P:
FcodecClose:
				jsr     FDisableCodec
				move    X:FCodec+11,R2
				jsr     FfifoDestroy
				move    X:FCodec+12,R2
				jsr     FfifoDestroy
				movei   #0,Y0
				rts     


				GLOBAL FcodecRead
				ORG	P:
FcodecRead:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				moves   R2,X:<mr10
				moves   Y1,X:<mr9
				move    X:(SP),R0
				move    R0,X:(SP-1)
				moves   #0,X:<mr8
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+8)
				bne     _L7
				jsr     FEnableCodec
				move    X:(SP-1),R2
				nop     
				movei   #1,X:(R2+8)
_L7:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+9)
				beq     _L11
_L8:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+11),R2
				moves   X:<mr9,Y0
				moves   X:<mr10,R3
				jsr     FfifoExtract
				move    Y0,X:<mr8
				tstw    X:<mr8
				beq     _L8
				bra     _L12
_L11:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+11),R2
				moves   X:<mr9,Y0
				moves   X:<mr10,R3
				jsr     FfifoExtract
				move    Y0,X:<mr8
_L12:
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FcodecWrite
				ORG	P:
FcodecWrite:
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
				moves   Y1,X:<mr9
				moves   #0,X:<mr8
				move    X:(SP-1),R0
				move    R0,X:<mr10
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+8)
				bne     _L8
				jsr     FEnableCodec
				move    X:(SP-2),R2
				nop     
				movei   #1,X:(R2+8)
_L8:
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+9)
				beq     _L12
_L9:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+12),R2
				moves   X:<mr8,X0
				add     X:<mr10,X0
				movec   X0,R3
				moves   X:<mr9,Y0
				sub     X:<mr8,Y0
				jsr     FfifoInsert
				add     X:<mr8,Y0
				move    Y0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blo     _L9
				bra     _L13
_L12:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+12),R2
				moves   X:<mr9,Y0
				moves   X:<mr10,R3
				jsr     FfifoInsert
				move    Y0,X:<mr8
_L13:
				moves   X:<mr8,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
Fcodec_send_cfg:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr9
				movei   #0,X0
				push    X0
				movei   #4560,R2
				jsr     Fopen
				pop     
				move    Y0,X:(SP)
				andc    #-2,X:11d1
				orc     #4,X:11d1
				moves   #15,X:<mr8
				bra     _L15
_L7:
				andc    #-2,X:11d1
				moves   X:<mr8,X0
				moves   X:<mr9,Y0
				lsrr    Y0,X0,X0
				andc    #1,X0
				tstw    X0
				beq     _L11
				orc     #2,X:11d1
				bra     _L12
_L11:
				andc    #-3,X:11d1
_L12:
				orc     #1,X:11d1
				nop     
				dec     X:<mr8
_L15:
				tstw    X:<mr8
				bge     _L7
				andc    #-5,X:11d1
				nop     
				orc     #4,X:11d1
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FcodecIoctl
				ORG	P:
FcodecIoctl:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-6),R0
				move    R0,X:<mr8
				move    X:(SP-1),X0
				cmp     #9,X0
				beq     _L16
				cmp     #3,X0
				bne     _L17
_L7:
				jsr     FDisableCodec
				move    X:(SP-2),R2
				nop     
				move    X:(R2+11),R2
				jsr     FfifoDestroy
				move    X:(SP-2),R2
				nop     
				move    X:(R2+12),R2
				jsr     FfifoDestroy
				moves   X:<mr8,R0
				nop     
				move    X:(R0),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y1
				jsr     FfifoCreate
				move    X:(SP-2),R0
				move    R2,X:(R0+11)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y1
				jsr     FfifoCreate
				move    X:(SP-2),R0
				move    R2,X:(R0+12)
				move    X:(SP-2),R2
				nop     
				movei   #0,X:(R2+10)
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+8)
				beq     _L17
				jsr     FEnableCodec
				bra     _L17
_L16:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),Y0
				jsr     Fcodec_send_cfg
_L17:
				movei   #0,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FEnableCodec:
				orc     #16,X:FArchIO+227
				rts     


				ORG	P:
FDisableCodec:
				andc    #-17,X:FArchIO+227
				rts     


				ORG	P:
FStereoISR:
				lea     (SP)+
				orc     #1,X:11d1
				move    X:FCodec+10,X0
				cmp     X:FCodec+4,X0
				bne     _L7
				movei   #0,X:FCodec+10
				tstw    X:FCodec+8
				beq     _L7
				move    X:FCodec+11,R2
				move    X:FCodec+2,R3
				move    X:FCodec+4,Y0
				jsr     FfifoInsert
				move    X:FCodec+12,R2
				move    X:FCodec+3,R3
				move    X:FCodec+4,Y0
				jsr     FfifoExtract
_L7:
				move    X:FArchIO+226,X0
				move    X0,X:(SP)
				move    X:FArchIO+225,X0
				move    X:FCodec+2,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X0,X:(R0+N)
				move    X:FCodec+3,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X:(R0+N),X0
				move    X0,X:FArchIO+224
				inc     X:FCodec+10
				move    X:FArchIO+225,X0
				move    X:FCodec+2,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X0,X:(R0+N)
				move    X:FCodec+3,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X:(R0+N),X0
				move    X0,X:FArchIO+224
				inc     X:FCodec+10
				andc    #-2,X:11d1
				lea     (SP)-
				rts     


				ORG	P:
FMonoISR:
				lea     (SP)+
				orc     #1,X:11d1
				move    X:FCodec+10,X0
				cmp     X:FCodec+4,X0
				bne     _L7
				movei   #0,X:FCodec+10
				tstw    X:FCodec+8
				beq     _L7
				move    X:FCodec+11,R2
				move    X:FCodec+2,R3
				move    X:FCodec+4,Y0
				jsr     FfifoInsert
				move    X:FCodec+12,R2
				move    X:FCodec+3,R3
				move    X:FCodec+4,Y0
				jsr     FfifoExtract
_L7:
				move    X:FArchIO+226,X0
				move    X0,X:(SP)
				move    X:FArchIO+225,B
				asr     B
				movec   B1,X0
				move    X:FCodec+2,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X0,X:(R0+N)
				move    X:FCodec+3,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X:(R0+N),X0
				move    X0,X:FArchIO+224
				move    X:FCodec+2,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:FArchIO+225,B
				asr     B
				movec   B1,X0
				add     Y0,X0
				move    X:FCodec+2,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X0,X:(R0+N)
				move    X:FCodec+3,R0
				move    X:FCodec+10,R1
				movec   R1,N
				move    X:(R0+N),X0
				move    X0,X:FArchIO+224
				inc     X:FCodec+10
				andc    #-2,X:11d1
				lea     (SP)-
				rts     


				ORG	X:
FInterfaceVT    DC			FcodecClose,FcodecdrvDriver,FCodec,Fsimple_ssiInitialize
FcodecdrvDriver DC			FInterfaceVT,FcodecIoctl
FCodec          BSC			13

				ENDSEC
				END

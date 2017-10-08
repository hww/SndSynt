
				SECTION scidrv
				include "asmdef.h"
				GLOBAL FsciOpen
				ORG	P:
FsciOpen:
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
				movec   SP,R0
				lea     (R0-8)
				move    R0,X:<mr11
				dec     X:<mr11
				moves   X:<mr11,R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				move    X:(SP),X0
				cmp     #29,X0
				bne     _L8
				moves   #FSciDevice,X:<mr8
				movei   #FscidrvIODevice,R0
				move    R0,X:<mr10
				bra     _L13
_L8:
				move    X:(SP),X0
				cmp     #30,X0
				bne     _L12
				movei   #FSciDevice+31,R0
				move    R0,X:<mr8
				movei   #FscidrvIODevice+2,R0
				move    R0,X:<mr10
				bra     _L13
_L12:
				movei   #65535,R2
				jmp     _L38
_L13:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr9
				moves   X:<mr8,R2
				move    X:(SP-1),R3
				jsr     FsciSetConfig
				moves   X:<mr8,R2
				nop     
				movei   #32768,X:(R2+3)
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				moves   X:<mr8,R0
				move    X:(R0+9),Y0
				movei   #0,Y1
				jsr     FfifoInit
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				moves   X:<mr8,R0
				move    X:(R0+20),Y0
				movei   #0,Y1
				jsr     FfifoInit
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+28)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+6)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+8)
				bftstl  #8,X:(SP-8)
				blo     _L31
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+2)
				bne     _L26
				movei   #Fsci0ReceiverISR,R0
				push    R0
				move    X:FpArchInterrupts,X0
				movec   X0,R2
				lea     (R2+100)
				movei   #Fsci0TransmitterISR,R3
				jsr     FsciHWInstallISR
				pop     
				bra     _L28
_L26:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),X0
				cmp     #1,X0
				bne     _L28
				movei   #Fsci1ReceiverISR,R0
				push    R0
				move    X:FpArchInterrupts,X0
				movec   X0,R2
				lea     (R2+92)
				movei   #Fsci1TransmitterISR,R3
				jsr     FsciHWInstallISR
				pop     
_L28:
				moves   X:<mr8,R2
				nop     
				orc     #16384,X:(R2+3)
				moves   X:<mr9,Y0
				jsr     FsciHWClearRxInterrupts
				moves   X:<mr9,Y0
				jsr     FsciHWEnableRxInterrupts
_L31:
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+2)
				bne     _L34
				orc     #512,X:FArchIO
				bra     _L36
_L34:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),X0
				cmp     #1,X0
				bne     _L36
				orc     #512,X:FArchIO
_L36:
				moves   X:<mr9,Y0
				jsr     FsciHWEnableDevice
				moves   X:<mr10,R2
_L38:
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


				ORG	P:
FsciClose:
				move    X:<mr8,N
				push    N
				moves   Y0,X:<mr8
				moves   X:<mr8,Y0
				jsr     FsciDeviceOff
				moves   X:<mr8,R2
				nop     
				bftstl  #16384,X:(R2+3)
				blo     _L5
				movei   #0,X0
				push    X0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				add     X:FpArchInterrupts,X0
				movec   X0,R2
				movei   #0,R3
				jsr     FsciHWInstallISR
				pop     
_L5:
				movei   #0,Y0
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FsciRead
				ORG	P:
FsciRead:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				move    X:(SP),R0
				move    R0,X:<mr9
				move    X:(SP-2),X0
				move    X0,X:<mr10
				moves   #0,X:<mr8
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-3)
				moves   X:<mr9,R2
				nop     
				bftstl  #16384,X:(R2+3)
				blo     _L17
				move    X:(SP-3),Y0
				jsr     FsciHWDisableRxInterrupts
				moves   X:<mr9,X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				jsr     FfifoNum
				move    Y0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:(SP-2),X0
				blo     _L11
				move    X:(SP-2),X0
				move    X0,X:<mr8
_L11:
				moves   X:<mr9,X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				move    X:(SP-1),R3
				moves   X:<mr8,Y0
				jsr     FfifoExtract
				move    Y0,X:<mr10
				moves   X:<mr9,X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				jsr     FfifoNum
				moves   X:<mr9,R2
				nop     
				move    X:(R2+28),X0
				cmp     X0,Y0
				bhs     _L14
				moves   X:<mr9,R2
				nop     
				orc     #2,X:(R2+29)
_L14:
				moves   X:<mr9,R2
				nop     
				movei   #0,X:(R2+5)
				move    X:(SP-3),Y0
				jsr     FsciHWEnableRxInterrupts
				bra     _L31
_L17:
				moves   X:<mr9,R2
				nop     
				movei   #0,X:(R2+5)
				moves   #0,X:<mr10
				moves   X:<mr10,X0
				cmp     X:(SP-2),X0
				bhs     _L31
				moves   X:<mr10,X0
				add     X:(SP-1),X0
				move    X0,X:<mr11
_L21:
				movei   #11008,Y0
				move    X:(SP-3),Y1
				jsr     FsciHWWaitStatusRegister
				moves   X:<mr9,R2
				jsr     FsciHWReceiveByte
				move    Y0,X:<mr8
				moves   X:<mr9,R2
				nop     
				bftstl  #16,X:(R2+29)
				bhs     _L27
				moves   X:<mr8,Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				move    X0,X:<mr8
				movei   #11008,Y0
				move    X:(SP-3),Y1
				jsr     FsciHWWaitStatusRegister
				moves   X:<mr9,R2
				jsr     FsciHWReceiveByte
				andc    #255,Y0
				moves   X:<mr8,X0
				or      X0,Y0
				move    Y0,X:<mr8
_L27:
				moves   X:<mr11,R0
				moves   X:<mr8,X0
				move    X0,X:(R0)
				inc     X:<mr11
				inc     X:<mr10
				moves   X:<mr10,X0
				cmp     X:(SP-2),X0
				blo     _L21
_L31:
				moves   X:<mr10,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FsciWrite
				ORG	P:
FsciWrite:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP-2),X0
				move    X0,X:<mr9
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr10
				moves   X:<mr8,R2
				nop     
				bftstl  #16384,X:(R2+3)
				jlo     _L27
				tstw    X:<mr9
				jeq     _L41
				moves   X:<mr10,Y0
				jsr     FsciHWDisableTxInterrupts
				moves   X:<mr8,R2
				nop     
				bftstl  #2,X:(R2+18)
				jhs     _L24
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				move    X:(SP-1),R3
				moves   X:<mr9,Y0
				jsr     FfifoInsert
				move    Y0,X:<mr9
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				movec   SP,R3
				lea     (R3-3)
				movei   #1,Y0
				jsr     FfifoExtract
				moves   X:<mr8,R2
				nop     
				bftstl  #16,X:(R2+29)
				bhs     _L15
				moves   X:<mr8,R2
				nop     
				orc     #1,X:(R2+18)
				move    X:(SP-3),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+19)
				move    X:(SP-3),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X0,X:(SP-3)
_L15:
				movei   #32768,Y0
				moves   X:<mr10,Y1
				jsr     FsciHWWaitStatusRegister
				moves   X:<mr8,R2
				move    X:(SP-3),Y0
				jsr     FsciHWSendByte
				moves   X:<mr8,R2
				nop     
				orc     #2,X:(R2+18)
				moves   X:<mr8,R2
				nop     
				bftstl  #16,X:(R2+18)
				blo     _L22
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				jsr     FfifoNum
				tstw    Y0
				bne     _L22
				moves   X:<mr10,Y0
				jsr     FsciHWEnableTxCompleteInterrupt
				jmp     _L41
_L22:
				moves   X:<mr10,Y0
				jsr     FsciHWEnableTxReadyInterrupt
				bra     _L41
_L24:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				move    X:(SP-1),R3
				moves   X:<mr9,Y0
				jsr     FfifoInsert
				move    Y0,X:<mr9
				moves   X:<mr10,Y0
				jsr     FsciHWEnableTxReadyInterrupt
				bra     _L41
_L27:
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-2),X0
				bhs     _L40
				moves   X:<mr9,X0
				add     X:(SP-1),X0
				move    X0,X:<mr11
_L30:
				moves   X:<mr11,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-3)
				movei   #32768,Y0
				moves   X:<mr10,Y1
				jsr     FsciHWWaitStatusRegister
				moves   X:<mr8,R2
				nop     
				bftstl  #16,X:(R2+29)
				bhs     _L36
				moves   X:<mr8,R2
				move    X:(SP-3),Y0
				movei   #8,X0
				lsrr    Y0,X0,Y0
				jsr     FsciHWSendByte
				movei   #32768,Y0
				moves   X:<mr10,Y1
				jsr     FsciHWWaitStatusRegister
				andc    #255,X:(SP-3)
_L36:
				moves   X:<mr8,R2
				move    X:(SP-3),Y0
				jsr     FsciHWSendByte
				inc     X:<mr11
				inc     X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-2),X0
				blo     _L30
_L40:
				movei   #16384,Y0
				moves   X:<mr10,Y1
				jsr     FsciHWWaitStatusRegister
_L41:
				moves   X:<mr9,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				ORG	P:
FioctlSCI_DATAFORMAT_EIGHTBITCHARS:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr8
				moves   X:<mr8,R0
				move    R0,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableInterrupts
				move    X:(SP),R2
				nop     
				orc     #16,X:(R2+18)
				move    X:(SP),R2
				nop     
				orc     #16,X:(R2+29)
				moves   X:<mr8,Y0
				jsr     FsciWriteClear
				moves   X:<mr8,Y0
				jsr     FsciReadClear
				move    X:(SP),R2
				jsr     FsciRestoreInterrupts
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_DATAFORMAT_RAW
				ORG	P:
FioctlSCI_DATAFORMAT_RAW:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr8
				moves   X:<mr8,R0
				move    R0,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableInterrupts
				move    X:(SP),R2
				nop     
				andc    #65519,X:(R2+18)
				move    X:(SP),R2
				nop     
				andc    #65519,X:(R2+29)
				moves   X:<mr8,Y0
				jsr     FsciWriteClear
				moves   X:<mr8,Y0
				jsr     FsciReadClear
				move    X:(SP),R2
				jsr     FsciRestoreInterrupts
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_DEVICE_RESET
				ORG	P:
FioctlSCI_DEVICE_RESET:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr8
				move    R2,X:(SP)
				moves   X:<mr8,Y0
				jsr     FsciDeviceOff
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FsciSetConfig
				moves   X:<mr8,Y0
				jsr     FsciDeviceOn
				movei   #0,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_SET_READ_LENGTH
				ORG	P:
FioctlSCI_SET_READ_LENGTH:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				moves   R2,X:<mr8
				move    X:(SP),R0
				move    R0,X:(SP-1)
				moves   X:<mr8,R0
				move    X:(SP-1),R2
				move    X:(R0),Y0
				move    X:(R2+20),X0
				cmp     X0,Y0
				bhs     _L5
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				bra     _L6
_L5:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+20),X0
_L6:
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+28)
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				jsr     FfifoNum
				move    X:(SP-1),R2
				nop     
				move    X:(R2+28),X0
				cmp     X0,Y0
				bhs     _L10
				move    X:(SP-1),R2
				nop     
				orc     #2,X:(R2+29)
				bra     _L11
_L10:
				move    X:(SP-1),R2
				nop     
				andc    #65533,X:(R2+29)
_L11:
				movei   #0,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_GET_STATUS
				ORG	P:
FioctlSCI_GET_STATUS:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				moves   #0,X:<mr8
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableInterrupts
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+5)
				beq     _L7
				orc     #64,X:<mr8
_L7:
				move    X:(SP-1),R2
				nop     
				bftstl  #2,X:(R2+18)
				blo     _L9
				orc     #16,X:<mr8
_L9:
				move    X:(SP-1),R2
				nop     
				bftstl  #2,X:(R2+29)
				blo     _L11
				orc     #32,X:<mr8
_L11:
				move    X:(SP-1),R2
				jsr     FsciRestoreInterrupts
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_GET_EXCEPTION
				ORG	P:
FioctlSCI_GET_EXCEPTION:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				moves   #0,X:<mr8
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableInterrupts
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+5)
				move    X:(SP-1),R2
				jsr     FsciRestoreInterrupts
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FioctlSCI_GET_READ_SIZE
				ORG	P:
FioctlSCI_GET_READ_SIZE:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				moves   Y0,X:<mr8
				moves   X:<mr8,R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableRxInterrupts
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				jsr     FfifoNum
				move    Y0,X:<mr9
				moves   X:<mr8,R2
				jsr     FsciRestoreInterrupts
				moves   X:<mr9,Y0
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FsciDevCreate
				ORG	P:
FsciDevCreate:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:FSciDriver
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:FSciDevice+9
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:FSciDevice+10
				move    X:(SP),R2
				nop     
				move    X:(R2+3),X0
				move    X0,X:FSciDevice+20
				move    X:(SP),R2
				nop     
				move    X:(R2+4),R0
				move    R0,X:FSciDevice+21
				move    X:(SP),R2
				nop     
				move    X:(R2+5),X0
				move    X0,X:FSciDevice+40
				move    X:(SP),R2
				nop     
				move    X:(R2+6),R0
				move    R0,X:FSciDevice+41
				move    X:(SP),R2
				nop     
				move    X:(R2+7),X0
				move    X0,X:FSciDevice+51
				move    X:(SP),R2
				nop     
				move    X:(R2+8),R0
				move    R0,X:FSciDevice+52
				movei   #FsciOpen,R2
				jsr     FioDrvInstall
				movei   #0,Y0
				lea     (SP)-
				rts     


				ORG	P:
FsciSetConfig:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),X0
				cmp     #16,X0
				bls     _L4
				debug   
_L4:
				move    X:(SP),R0
				nop     
				move    X:(R0),Y0
				move    X:(SP-1),R2
				jsr     FsciHWConfigure
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+5)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				bftstl  #4096,X0
				blo     _L12
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				bftstl  #512,X0
				blo     _L10
				move    X:(SP),R2
				nop     
				movei   #255,X:(R2+4)
				bra     _L16
_L10:
				move    X:(SP),R2
				nop     
				movei   #511,X:(R2+4)
				bra     _L16
_L12:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				bftstl  #512,X0
				blo     _L15
				move    X:(SP),R2
				nop     
				movei   #127,X:(R2+4)
				bra     _L16
_L15:
				move    X:(SP),R2
				nop     
				movei   #255,X:(R2+4)
_L16:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L20
				move    X:(SP),R2
				nop     
				movei   #256,X:(R2+18)
				move    X:(SP),R2
				nop     
				movei   #256,X:(R2+29)
				bra     _L22
_L20:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+18)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+29)
_L22:
				lea     (SP-2)
				rts     


				GLOBAL FsciReadClear
				ORG	P:
FsciReadClear:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				jsr     FsciHWDisableRxInterrupts
				move    X:(SP-1),R2
				nop     
				andc    #65532,X:(R2+29)
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				movei   #0,Y0
				jsr     FfifoClear
				moves   X:<mr8,Y0
				jsr     FsciHWClearRxInterrupts
				move    X:(SP-1),R2
				nop     
				bftstl  #16384,X:(R2+3)
				blo     _L12
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+28)
				beq     _L11
				move    X:(SP-1),R2
				nop     
				orc     #2,X:(R2+29)
_L11:
				moves   X:<mr8,Y0
				jsr     FsciHWEnableRxInterrupts
_L12:
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FsciWriteClear
				ORG	P:
FsciWriteClear:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FsciHWDisableTxInterrupts
				move    X:(SP-1),R2
				nop     
				andc    #65532,X:(R2+18)
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				movei   #0,Y0
				jsr     FfifoClear
				lea     (SP-2)
				rts     


				GLOBAL FsciDeviceOff
				ORG	P:
FsciDeviceOff:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				jsr     FsciHWDisableInterrupts
				moves   X:<mr8,Y0
				jsr     FsciHWClearRxInterrupts
				moves   X:<mr8,Y0
				jsr     FsciHWDisableDevice
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FsciDeviceOn
				ORG	P:
FsciDeviceOn:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr9
				moves   X:<mr9,R0
				move    R0,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				jsr     FsciHWEnableDevice
				moves   X:<mr9,Y0
				jsr     FsciWriteClear
				moves   X:<mr9,Y0
				jsr     FsciReadClear
				moves   X:<mr8,Y0
				jsr     FsciHWClearRxInterrupts
				move    X:(SP),R2
				jsr     FsciRestoreInterrupts
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FsciRestoreInterrupts:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				move    X:(SP),R2
				nop     
				bftstl  #16384,X:(R2+3)
				blo     _L9
				moves   X:<mr8,Y0
				jsr     FsciHWEnableRxInterrupts
				move    X:(SP),R2
				nop     
				bftstl  #2,X:(R2+18)
				blo     _L8
				moves   X:<mr8,Y0
				jsr     FsciHWEnableTxCompleteInterrupt
				bra     _L9
_L8:
				moves   X:<mr8,Y0
				jsr     FsciHWEnableTxReadyInterrupt
_L9:
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FsciHWDisableInterrupts:
				movec   Y0,R0
				move    X:(R0+1),X0
				andc    #65295,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWEnableRxInterrupts:
				movec   Y0,R0
				move    X:(R0+1),X0
				orc     #48,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWDisableRxInterrupts:
				movec   Y0,R0
				move    X:(R0+1),X0
				andc    #65487,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWEnableTxCompleteInterrupt:
				movec   Y0,R0
				move    X:(R0+1),X0
				orc     #64,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWEnableTxReadyInterrupt:
				movec   Y0,R0
				move    X:(R0+1),X0
				orc     #128,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWDisableTxInterrupts:
				movec   Y0,R0
				move    X:(R0+1),X0
				andc    #65343,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWConfigure:
				move    X:FSciDriver,R0
				move    X:(R2+2),R1
				movec   R1,N
				movec   Y0,R1
				move    X:(R0+N),X0
				move    X0,X:(R1)
				move    X:(R2),X0
				andc    #-256,X0
				movec   Y0,R0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWDisableDevice:
				movec   Y0,R0
				move    X:(R0+1),X0
				andc    #65523,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWEnableDevice:
				movec   Y0,R0
				move    X:(R0+1),X0
				orc     #12,X0
				move    X0,X:(R0+1)
				rts     


				ORG	P:
FsciHWClearRxInterrupts:
				movec   Y0,R0
				move    X:(R0+2),X0
				move    X0,X:<mr2
				movec   Y0,R0
				move    X:(R0+3),X0
				move    X0,X:<mr2
				movec   Y0,R0
				movei   #0,X0
				move    X0,X:(R0+2)
				rts     


				ORG	P:
FsciHWInstallISR:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FarchInstallISR
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				move    X:(SP-1),R3
				jsr     FarchInstallISR
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				move    X:(SP-4),R3
				jsr     FarchInstallISR
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+6)
				move    X:(SP-4),R3
				jsr     FarchInstallISR
				lea     (SP-2)
				rts     


				ORG	P:
FsciHWReceiveByte:
				move    X:(R2),X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				movec   X0,R0
				move    X:(R0+2),Y0
				andc    #3840,Y0
				move    X:(R2+5),X0
				or      X0,Y0
				move    Y0,X:(R2+5)
				moves   X:<mr3,X0
				movec   X0,R0
				move    X:(R0+3),X0
				move    X0,X:<mr2
				moves   X:<mr3,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+2)
				tstw    X:<mr2
				bne     _L8
				bftstl  #512,X:(R2+5)
				blo     _L8
				orc     #2,X:(R2+5)
_L8:
				move    X:(R2+4),Y0
				moves   X:<mr2,X0
				and     X0,Y0
				move    Y0,X:<mr2
				bftstl  #256,X:(R2+29)
				blo     _L13
				bftstl  #256,X:<mr2
				bhs     _L13
				bftstl  #512,X:(R2+5)
				bhs     _L13
				orc     #4,X:(R2+5)
_L13:
				moves   X:<mr2,Y0
				rts     


				ORG	P:
FsciHWSendByte:
				lea     (SP)+
				move    X:(R2),X0
				move    X0,X:<mr2
				moves   X:<mr2,X0
				movec   X0,R0
				move    X:(R0+2),X0
				move    X0,X:(SP)
				bftstl  #16,X:(R2+18)
				bhs     _L8
				bftstl  #256,X:(R2+18)
				blo     _L7
				orc     #256,Y0
				bra     _L8
_L7:
				andc    #65279,Y0
_L8:
				move    X:(R2+4),X0
				and     Y0,X0
				movec   X0,Y0
				moves   X:<mr2,X0
				movec   X0,R0
				move    Y0,X:(R0+3)
				lea     (SP)-
				rts     


				ORG	P:
FsciHWWaitStatusRegister:
				moves   Y1,X:<mr2
_L2:
				moves   X:<mr2,X0
				movec   X0,R0
				move    X:(R0+2),X0
				and     Y0,X0
				tstw    X0
				beq     _L2
				rts     


				ORG	P:
Fsci0ReceiverISR:
				movei   #FSciDevice,R2
				jsr     FsciHWReceiver
				rts     


				ORG	P:
Fsci0TransmitterISR:
				movei   #FSciDevice,R2
				jsr     FsciHWTransmitter
				rts     


				ORG	P:
Fsci1ReceiverISR:
				movei   #FSciDevice+31,R2
				jsr     FsciHWReceiver
				rts     


				ORG	P:
Fsci1TransmitterISR:
				movei   #FSciDevice+31,R2
				jsr     FsciHWTransmitter
				rts     


				ORG	P:
FsciHWReceiver:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				jsr     FsciHWReceiveByte
				move    Y0,X:(SP-1)
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+29)
				blo     _L8
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+30)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				movec   SP,R3
				nop     
				lea     (R3)-
				movei   #1,Y0
				jsr     FfifoInsert
				cmp     #1,Y0
				beq     _L16
				move    X:(SP),R2
				nop     
				orc     #8,X:(R2+5)
				bra     _L16
_L8:
				move    X:(SP),R2
				nop     
				move    X:(R2+29),X0
				andc    #1,X0
				tstw    X0
				beq     _L14
				move    X:(SP),R2
				move    X:(SP-1),Y0
				andc    #255,Y0
				move    X:(R2+30),X0
				or      X0,Y0
				move    Y0,X:(SP-1)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				movec   SP,R3
				nop     
				lea     (R3)-
				movei   #1,Y0
				jsr     FfifoInsert
				cmp     #1,Y0
				beq     _L12
				move    X:(SP),R2
				nop     
				orc     #8,X:(R2+5)
_L12:
				move    X:(SP),R2
				nop     
				andc    #65534,X:(R2+29)
				bra     _L16
_L14:
				move    X:(SP-1),Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+30)
				move    X:(SP),R2
				nop     
				orc     #1,X:(R2+29)
_L16:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+8)
				beq     _L20
				move    X:(SP),R2
				nop     
				tstw    X:(R2+5)
				beq     _L20
				move    X:(SP),R2
				nop     
				move    X:(R2+8),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+5),Y0
				movei   #_L19,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L19:
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+5)
_L20:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+28)
				beq     _L25
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+21)
				jsr     FfifoNum
				move    X:(SP),R2
				nop     
				move    X:(R2+28),X0
				cmp     X0,Y0
				blo     _L25
				move    X:(SP),R2
				nop     
				andc    #65533,X:(R2+29)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+6)
				beq     _L25
				move    X:(SP),R2
				nop     
				move    X:(R2+6),R0
				movei   #_L25,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L25:
				lea     (SP-2)
				rts     


				ORG	P:
FsciHWTransmitter:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+18)
				bhs     _L5
				move    X:(SP),R2
				nop     
				move    X:(R2+18),X0
				andc    #1,X0
				tstw    X0
				bne     _L16
_L5:
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				movec   SP,R3
				nop     
				lea     (R3)-
				movei   #1,Y0
				jsr     FfifoExtract
				cmp     #1,Y0
				beq     _L11
				moves   X:<mr8,Y0
				jsr     FsciHWDisableTxInterrupts
				move    X:(SP),R2
				nop     
				andc    #65533,X:(R2+18)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+7)
				jeq     _L26
				move    X:(SP),R2
				nop     
				move    X:(R2+7),R0
				movei   #_L10,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L10:
				jmp     _L26
_L11:
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+18)
				bhs     _L19
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+19)
				move    X:(SP-1),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X0,X:(SP-1)
				move    X:(SP),R2
				nop     
				orc     #1,X:(R2+18)
				bra     _L19
_L16:
				move    X:(SP),R2
				nop     
				move    X:(R2+18),X0
				andc    #1,X0
				tstw    X0
				beq     _L19
				move    X:(SP),R2
				nop     
				move    X:(R2+19),X0
				andc    #255,X0
				move    X0,X:(SP-1)
				move    X:(SP),R2
				nop     
				andc    #65534,X:(R2+18)
_L19:
				move    X:(SP),R2
				move    X:(SP-1),Y0
				jsr     FsciHWSendByte
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+18)
				bhs     _L23
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+18)
				bhs     _L26
				move    X:(SP),R2
				nop     
				move    X:(R2+18),X0
				andc    #1,X0
				tstw    X0
				bne     _L26
_L23:
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+10)
				jsr     FfifoNum
				tstw    Y0
				bne     _L26
				moves   X:<mr8,Y0
				jsr     FsciHWDisableTxInterrupts
				moves   X:<mr8,Y0
				jsr     FsciHWEnableTxCompleteInterrupt
_L26:
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
FInterfaceVT    DC			FsciClose,FSciDevice,FArchIO,FscidrvIODevice
FSciDevice      DC			FArchIO,FscidrvIODevice,FsciOpen,FsciSetConfig,FfifoInit,Fsci0ReceiverISR,FpArchInterrupts,Fsci0TransmitterISR
				DC			FsciHWInstallISR,Fsci1ReceiverISR,Fsci1TransmitterISR,FsciHWClearRxInterrupts,FsciHWEnableRxInterrupts,FsciHWEnableDevice,.debug_sciOpen,.line_sciOpen
				DC			FsciDeviceOff,.debug_sciClose,.line_sciClose,FsciHWDisableRxInterrupts,FfifoNum,FfifoExtract,FsciHWWaitStatusRegister,FsciHWReceiveByte
				DC			.debug_sciRead,.line_sciRead,FsciHWDisableTxInterrupts,FfifoInsert,FsciHWSendByte,FsciHWEnableTxCompleteInterrupt,FsciHWEnableTxReadyInterrupt,.debug_sciWrite
				DC			.line_sciWrite,FioctlSCI_DATAFORMAT_EIGHTBITCHARS,FsciHWDisableInterrupts,FsciWriteClear,FsciReadClear,FsciRestoreInterrupts,.debug_ioctlSCI_DATAFORMAT_EIGHTBITCHARS,.line_ioctlSCI_DATAFORMAT_EIGHTBITCHARS
				DC			FioctlSCI_DATAFORMAT_RAW,.debug_ioctlSCI_DATAFORMAT_RAW,.line_ioctlSCI_DATAFORMAT_RAW,FioctlSCI_DEVICE_RESET,FsciDeviceOn,.debug_ioctlSCI_DEVICE_RESET,.line_ioctlSCI_DEVICE_RESET,FioctlSCI_SET_READ_LENGTH
				DC			.debug_ioctlSCI_SET_READ_LENGTH,.line_ioctlSCI_SET_READ_LENGTH,FioctlSCI_GET_STATUS,.debug_ioctlSCI_GET_STATUS,.line_ioctlSCI_GET_STATUS,FioctlSCI_GET_EXCEPTION,.debug_ioctlSCI_GET_EXCEPTION,.line_ioctlSCI_GET_EXCEPTION
				DC			FioctlSCI_GET_READ_SIZE,.debug_ioctlSCI_GET_READ_SIZE,.line_ioctlSCI_GET_READ_SIZE,FsciDevCreate,FSciDriver,FioDrvInstall
FscidrvIODevice DC			FInterfaceVT,FsciWrite,FsciRead,FsciClose,FSciDevice,FArchIO
FSciDriver      BSC			1

				ENDSEC
				END

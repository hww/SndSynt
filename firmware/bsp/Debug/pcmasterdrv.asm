
				SECTION pcmasterdrv
				include "asmdef.h"
				ORG	P:
FsciException:
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FsciReadClear
				rts     


				GLOBAL FpcmasterdrvInit
				ORG	P:
FpcmasterdrvInit:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R0
				move    R0,X:FPCMasterComm
				movei   #0,X:FSciConfig
				movei   #0,X:FSciConfig+1
				movei   #8,X:FSciConfig+2
				movei   #FSciConfig,R0
				push    R0
				movei   #8,X0
				push    X0
				movei   #29,R2
				jsr     Fopen
				lea     (SP-2)
				move    Y0,X:FSciFD
				movei   #-1,X0
				cmp     X:FSciFD,X0
				bne     _L9
				movei   #-1,Y0
				jmp     _L21
_L9:
				movei   #1,X:FinChar
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				movei   #FinChar,R2
				jsr     FioctlSCI_SET_READ_LENGTH
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				movei   #0,R2
				jsr     FioctlSCI_DATAFORMAT_EIGHTBITCHARS
				movei   #FpcmasterdrvIsr,R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),R1
				move    R0,X:(R1+6)
				movei   #FpcmasterdrvIsr,R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),R1
				move    R0,X:(R1+7)
				movei   #FsciException,R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),R1
				move    R0,X:(R1+8)
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FsciDeviceOn
				movei   #0,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+5),R0
				movei   #0,X0
				move    X0,X:(R0)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0)
				movei   #255,X:FpcmdrvAppCmdSts
				movei   #0,Y0
_L21:
				lea     (SP)-
				rts     


				ORG	P:
FcmdReadMem:
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				movei   #8,X0
				lsll    Y0,X0,Y0
				add     Y0,Y1
				move    Y1,R2
				move    X0,Y0
				move    X:Flength,X0
				lsr     X0
				do      X0,_L18
				move    X:(R2)+,A1
				move    A1,A0
				bfclr   #-256,A0
				move    A0,X:(R3)+
				bfclr   #255,A1
				lsrr    A1,Y0,A
				move    A1,X:(R3)+
				rts     


				ORG	P:
FcmdScopeInit:
				move    X:(R2)+,LC
				move    LC,X:(R3)+
				movei   #8,X0
				do      LC,_L12
				move    X:(R2)+,A1
				move    A1,X:(R3)+
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				lsll    Y0,X0,Y0
				add     Y1,Y0
				move    Y0,X:(R3)+
				rts     


				ORG	P:
FcmdReadScope:
				move    X:(R2)+,LC
				clr     Y1
				do      LC,_L24
				move    X:(R2)+,X0
				add     X0,Y1
				lsr     X0
				move    X:(R2)+,R1
				movei   #8,Y0
				push    X0
				move    X:(R1)+,A1
				move    A1,A0
				bfclr   #255,A1
				bfclr   #-256,A0
				move    A0,X:(R3)+
				lsrr    A1,Y0,A
				move    A1,X:(R3)+
				pop     A
				dec     A
				tst     A
				push    A
				bgt     _L10
				pop     A
				nop     
				inc     Y1
				move    Y1,X:Flength
				rts     


				ORG	P:
FcmdWriteMem:
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				movei   #8,X0
				lsll    Y0,X0,Y0
				add     Y0,Y1
				move    Y1,R2
				move    X:Flength,Y0
				lsr     Y0
				do      Y0,_L15
				move    X:(R3)+,Y0
				move    X:(R3)+,Y1
				lsll    Y1,X0,Y1
				add     Y1,Y0
				move    Y0,X:(R2)+
				rts     


				ORG	P:
FcmdWriteMemMask:
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				movei   #8,X0
				lsll    Y0,X0,Y0
				add     Y0,Y1
				move    Y1,R1
				move    X:Flength,Y0
				lsr     Y0
				do      Y0,_L28
				move    X:(R2)+,Y0
				move    X:(R2)+,Y1
				lsll    Y1,X0,Y1
				add     Y1,Y0
				move    Y0,A1
				move    X:(R3)+,Y0
				move    X:(R3)+,Y1
				lsll    Y1,X0,Y1
				add     Y1,Y0
				move    Y0,B1
				and     A1,Y0
				neg     B
				dec     B
				move    B1,Y1
				move    X:(R1),A1
				and     A1,Y1
				or      Y1,Y0
				move    Y0,X:(R1)+
				rts     


				ORG	P:
FcmdCallAppCmd:
				move    X:(R2)+,A
				lsr     A
				jeq     _L14
				move    X:(R2)+,X0
				move    X0,X:(R3)+
				movei   #8,X0
				do      A,_L13
				move    X:(R2)+,Y0
				move    X:(R2)+,Y1
				lsll    Y1,X0,Y1
				add     Y1,Y0
				move    Y0,X:(R3)+
				rts     
				move    X:(R2)+,X0
				move    X0,X:(R3)+
				rts     


				ORG	P:
FcmdRecInit:
				move    X:(R2)+,A
				move    A,X:(R3)+
				movei   #8,X0
				do      #4,_L10
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				lsll    Y0,X0,Y0
				add     Y1,Y0
				move    Y0,X:(R3)+
				move    X:(R2)+,A
				move    A,X:(R3)+
				move    X:(R2)+,A
				move    A,X:(R3)+
				do      #2,_L20
				move    X:(R2)+,Y1
				move    X:(R2)+,Y0
				lsll    Y0,X0,Y0
				add     Y1,Y0
				move    Y0,X:(R3)+
				rts     


				ORG	P:
FreadSample:
				move    X:(R2)+,LC
				do      LC,_L17
				move    X:(R2)+,X0
				lsr     X0
				move    X:(R2)+,R1
				movei   #8,Y0
				push    X0
				move    X:(R1)+,A1
				move    A1,X:(R3)+
				pop     A
				dec     A
				tst     A
				push    A
				bgt     _L8
				pop     A
				nop     
				rts     


				ORG	P:
FsendResponse:
				lea     (SP)+
				move    R2,X:(SP)
				bfset   #4096,X:Fstatus
				move    X:(SP),R0
				move    X:FPCMasterComm,R1
				nop     
				move    X:(R1),R2
				move    X:(R0),X0
				move    X0,X:(R2)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:Flength
				movei   #0,X:Fpos
				movei   #43,X:FinChar
				move    X:FSciFD,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				movei   #FinChar,R2
				movei   #1,Y1
				movei   #_L8,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L8:
				movei   #0,X:FcheckSum
				lea     (SP)-
				rts     


				GLOBAL FpcmasterdrvRecorder
				ORG	P:
FpcmasterdrvRecorder:
				movei   #3,N
				lea     (SP)+N
				bftstl  #512,X:Fstatus
				jlo     _L116
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+29),Y0
				move    X:(R1+3),X0
				cmp     X0,Y0
				jne     _L115
				move    X:Fstatus,X0
				andc    #15,X0
				cmp     #8,X0
				jeq     _L63
				bge     _L9
				cmp     #5,X0
				jeq     _L37
				jge     _L116
				cmp     #4,X0
				bge     _L11
				jmp     _L116
_L9:
				cmp     #10,X0
				jge     _L116
				jmp     _L89
_L11:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-2)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),X0
				movec   X0,R2
				nop     
				lea     (R2+9)
				move    X:FPCMasterComm,R0
				move    X:FPCMasterComm,R1
				move    X:(R1+4),R3
				move    X:(R3+26),Y0
				move    X:(R0+2),X0
				add     X0,Y0
				movec   Y0,R3
				jsr     FreadSample
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y0
				move    X:(R0+26),X0
				add     X0,Y0
				move    Y0,X:(R0+26)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+26),Y0
				move    X:(R1+1),X0
				cmp     X0,Y0
				blo     _L17
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+26)
_L17:
				bftstl  #256,X:Fstatus
				jhs     _L30
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				bne     _L24
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+7),X0
				cmp     X0,Y0
				blo     _L24
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+30),Y0
				move    X:(R1+7),X0
				cmp     X0,Y0
				bhs     _L24
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L31
_L24:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #2,X0
				bne     _L31
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+7),X0
				cmp     X0,Y0
				bhi     _L31
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+30),Y0
				move    X:(R1+7),X0
				cmp     X0,Y0
				bls     _L31
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L31
_L30:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+28),X0
				dec     X0
				move    X0,X:(R0+28)
_L31:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+28)
				bne     _L34
				bfclr   #768,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #1,X0
				move    X0,X:(R0+28)
_L34:
				move    X:(SP-2),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+29)
				jmp     _L116
_L37:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-2)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),X0
				movec   X0,R2
				nop     
				lea     (R2+9)
				move    X:FPCMasterComm,R0
				move    X:FPCMasterComm,R1
				move    X:(R1+4),R3
				move    X:(R3+26),Y0
				move    X:(R0+2),X0
				add     X0,Y0
				movec   Y0,R3
				jsr     FreadSample
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y0
				move    X:(R0+26),X0
				add     X0,Y0
				move    Y0,X:(R0+26)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+26),Y0
				move    X:(R1+1),X0
				cmp     X0,Y0
				blo     _L43
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+26)
_L43:
				bftstl  #256,X:Fstatus
				jhs     _L56
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				bne     _L50
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+7),X0
				cmp     X0,Y0
				blt     _L50
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+30),Y0
				move    X:(R1+7),X0
				cmp     X0,Y0
				bge     _L50
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L57
_L50:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #2,X0
				bne     _L57
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+7),X0
				cmp     X0,Y0
				bgt     _L57
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+30),Y0
				move    X:(R1+7),X0
				cmp     X0,Y0
				ble     _L57
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L57
_L56:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+28),X0
				dec     X0
				move    X0,X:(R0+28)
_L57:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+28)
				bne     _L60
				bfclr   #768,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #1,X0
				move    X0,X:(R0+28)
_L60:
				move    X:(SP-2),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+29)
				jmp     _L116
_L63:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),X0
				movec   X0,R2
				nop     
				lea     (R2+9)
				move    X:FPCMasterComm,R0
				move    X:FPCMasterComm,R1
				move    X:(R1+4),R3
				move    X:(R3+26),Y0
				move    X:(R0+2),X0
				add     X0,Y0
				movec   Y0,R3
				jsr     FreadSample
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y0
				move    X:(R0+26),X0
				add     X0,Y0
				move    Y0,X:(R0+26)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+26),Y0
				move    X:(R1+1),X0
				cmp     X0,Y0
				blo     _L69
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+26)
_L69:
				bftstl  #256,X:Fstatus
				jhs     _L82
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				bne     _L76
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:(R0+8),A
				move    X:(R0+7),A0
				cmp     A,B
				blo     _L76
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+31),B
				move    X:(R0+30),B0
				move    X:(R1+8),A
				move    X:(R1+7),A0
				cmp     A,B
				bhs     _L76
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				jmp     _L83
_L76:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #2,X0
				bne     _L83
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:(R0+8),A
				move    X:(R0+7),A0
				cmp     A,B
				bhi     _L83
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+31),B
				move    X:(R0+30),B0
				move    X:(R1+8),A
				move    X:(R1+7),A0
				cmp     A,B
				bls     _L83
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L83
_L82:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+28),X0
				dec     X0
				move    X0,X:(R0+28)
_L83:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+28)
				bne     _L86
				bfclr   #768,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #1,X0
				move    X0,X:(R0+28)
_L86:
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+29)
				jmp     _L116
_L89:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP)
				move    X:(SP),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),X0
				movec   X0,R2
				nop     
				lea     (R2+9)
				move    X:FPCMasterComm,R0
				move    X:FPCMasterComm,R1
				move    X:(R1+4),R3
				move    X:(R3+26),Y0
				move    X:(R0+2),X0
				add     X0,Y0
				movec   Y0,R3
				jsr     FreadSample
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y0
				move    X:(R0+26),X0
				add     X0,Y0
				move    Y0,X:(R0+26)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+26),Y0
				move    X:(R1+1),X0
				cmp     X0,Y0
				blo     _L95
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+26)
_L95:
				bftstl  #256,X:Fstatus
				jhs     _L108
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #1,X0
				bne     _L102
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:(R0+8),A
				move    X:(R0+7),A0
				cmp     A,B
				blt     _L102
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+31),B
				move    X:(R0+30),B0
				move    X:(R1+8),A
				move    X:(R1+7),A0
				cmp     A,B
				bge     _L102
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				jmp     _L109
_L102:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				move    X:(R0),X0
				cmp     #2,X0
				bne     _L109
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:(R0+8),A
				move    X:(R0+7),A0
				cmp     A,B
				bgt     _L109
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R0+31),B
				move    X:(R0+30),B0
				move    X:(R1+8),A
				move    X:(R1+7),A0
				cmp     A,B
				ble     _L109
				bfset   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				dec     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bra     _L109
_L108:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+28),X0
				dec     X0
				move    X0,X:(R0+28)
_L109:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+28)
				bne     _L112
				bfclr   #768,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #1,X0
				move    X0,X:(R0+28)
_L112:
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+29)
				bra     _L116
_L115:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+29),X0
				inc     X0
				move    X0,X:(R0+29)
_L116:
				lea     (SP-3)
				rts     


				ORG	P:
FmessageData:
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				tstw    X:(SP)
				jne     _L300
				bftstl  #16,X:Fstatus
				jlo     _L308
				move    X:Fpos,X0
				cmp     X:Flength,X0
				beq     _L17
				move    X:FinChar,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:Fpos,R0
				movec   R0,N
				move    X0,X:(R1+N)
				move    X:FinChar,X0
				add     X:FcheckSum,X0
				move    X0,X:FcheckSum
				inc     X:Fpos
				bftstl  #64,X:Fstatus
				jlo     _L308
				move    X:FinChar,X0
				add     #2,X0
				move    X0,X:Flength
				bfclr   #64,X:Fstatus
				move    X:FPCMasterComm,R2
				move    X:Flength,Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				jls     _L308
				bfclr   #48,X:Fstatus
				movei   #131,X:Fresponse
				movei   #1,X:Fresponse+1
				movei   #Fresponse,R2
				jsr     FsendResponse
				jmp     _L308
_L17:
				move    X:FinChar,X0
				add     X:FcheckSum,X0
				move    X0,X:FcheckSum
				move    X:FcheckSum,X0
				andc    #255,X0
				tstw    X0
				jne     _L295
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),X0
				cmp     #192,X0
				jeq     _L161
				bge     _L33
				cmp     #8,X0
				jeq     _L165
				bge     _L29
				cmp     #2,X0
				jeq     _L259
				bge     _L27
				cmp     #1,X0
				jge     _L250
				jmp     _L292
_L27:
				cmp     #4,X0
				jge     _L292
				jmp     _L267
_L29:
				cmp     #16,X0
				jeq     _L275
				jge     _L292
				cmp     #10,X0
				jge     _L292
				jmp     _L184
_L33:
				cmp     #198,X0
				jeq     _L153
				bge     _L41
				cmp     #195,X0
				jeq     _L63
				bge     _L39
				cmp     #194,X0
				jge     _L112
				jmp     _L78
_L39:
				cmp     #197,X0
				jge     _L55
				jmp     _L133
_L41:
				cmp     #210,X0
				beq     _L50
				jge     _L292
				cmp     #209,X0
				jlt     _L292
_L45:
				movei   #2,X:Flength
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2)+
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R3
				nop     
				lea     (R3)+
				jsr     FcmdReadMem
				movei   #0,X:Fresponse
				movei   #3,X:Fresponse+1
				jmp     _L297
_L50:
				movei   #4,X:Flength
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2)+
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R3
				nop     
				lea     (R3)+
				jsr     FcmdReadMem
				movei   #0,X:Fresponse
				movei   #5,X:Fresponse+1
				jmp     _L297
_L55:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+5),R0
				nop     
				tstw    X:(R0)
				bne     _L59
				movei   #136,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L59:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+5),R2
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R3
				nop     
				lea     (R3)+
				jsr     FcmdReadScope
				movei   #0,X:Fresponse
				move    X:Flength,X0
				move    X0,X:Fresponse+1
				jmp     _L297
_L63:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+3)
				bne     _L67
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L67:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				tstw    X:(R0)
				beq     _L75
				bftstl  #512,X:Fstatus
				bhs     _L72
				movei   #2,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L72:
				movei   #1,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L75:
				movei   #136,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L78:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+3)
				bne     _L82
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L82:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				tstw    X:(R0)
				jeq     _L109
				bftstl  #256,X:Fstatus
				jhs     _L106
				bfclr   #256,X:Fstatus
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+3),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+29)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP-1)
				move    X:Fstatus,X0
				andc    #15,X0
				cmp     #8,X0
				beq     _L99
				bge     _L93
				cmp     #5,X0
				beq     _L97
				bge     _L102
				cmp     #4,X0
				bge     _L95
				bra     _L102
_L93:
				cmp     #10,X0
				bge     _L102
				bra     _L101
_L95:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				bra     _L102
_L97:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				bra     _L102
_L99:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
				bra     _L102
_L101:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
_L102:
				bfset   #512,X:Fstatus
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L106:
				movei   #1,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L109:
				movei   #136,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L112:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+3)
				bne     _L116
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L116:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+9)
				beq     _L130
				bftstl  #512,X:Fstatus
				blo     _L127
				bftstl  #256,X:Fstatus
				blo     _L122
				movei   #2,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L122:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+2),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+28)
				bfset   #256,X:Fstatus
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L127:
				movei   #2,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L130:
				movei   #136,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L133:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+3)
				bne     _L137
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L137:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				tstw    X:(R0+9)
				jeq     _L150
				bftstl  #256,X:Fstatus
				jhs     _L147
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+2),X0
				andc    #255,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+1)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+2),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+2)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y1
				move    X:(R0+26),Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:(SP-2)
				move    X:(SP-2),X0
				andc    #255,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+3)
				move    X:(SP-2),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+4)
				movei   #0,X:Fresponse
				movei   #5,X:Fresponse+1
				jmp     _L297
_L147:
				movei   #135,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L150:
				movei   #136,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L153:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+8)
				bne     _L157
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L157:
				move    X:FpcmdrvAppCmdSts,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+1)
				movei   #0,X:Fresponse
				movei   #2,X:Fresponse+1
				jmp     _L297
_L161:
				jsr     FcmdGetInfo
				movei   #0,X:Fresponse
				movei   #36,X:Fresponse+1
				jmp     _L297
_L165:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				tstw    X:(R2+2)
				beq     _L167
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),X0
				cmp     #8,X0
				bls     _L170
_L167:
				movei   #133,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L170:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				move    X:FPCMasterComm,R0
				move    X:(R0+5),R3
				jsr     FcmdScopeInit
				movei   #0,X:(SP-2)
				bra     _L180
_L173:
				move    X:FPCMasterComm,R2
				move    X:(SP-2),Y0
				lsl     Y0
				move    X:(R2+5),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				tstw    X:(R2+1)
				beq     _L175
				move    X:FPCMasterComm,R2
				move    X:(SP-2),Y0
				lsl     Y0
				move    X:(R2+5),X0
				add     X0,Y0
				movec   Y0,R2
				movei   #2,Y1
				move    X:(R2+1),Y0
				jsr     ARTREMS16Z
				tstw    Y0
				beq     _L179
_L175:
				movei   #134,X:Fresponse
				movei   #1,X:Fresponse+1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+5),R0
				movei   #0,X0
				move    X0,X:(R0)
				jmp     _L297
_L179:
				inc     X:(SP-2)
_L180:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+5),R0
				move    X:(SP-2),Y0
				move    X:(R0),X0
				cmp     X0,Y0
				blo     _L173
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L184:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+3)
				bne     _L188
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L188:
				bfclr   #768,X:Fstatus
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				tstw    X:(R2+17)
				beq     _L191
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+17),X0
				cmp     #8,X0
				bls     _L194
_L191:
				movei   #133,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L194:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				move    X:FPCMasterComm,R0
				move    X:(R0+4),R3
				jsr     FcmdRecInit
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				nop     
				tstw    X:(R0)
				beq     _L203
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+5),X0
				cmp     #2,X0
				beq     _L202
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+5),X0
				cmp     #4,X0
				beq     _L202
				movei   #134,X:Fresponse
				movei   #1,X:Fresponse+1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+9)
				jmp     _L297
_L202:
				move    X:Fstatus,Y1
				andc    #-16,Y1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+5),Y0
				lsl     Y0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+6),X0
				add     X0,Y0
				or      Y1,Y0
				move    Y0,X:Fstatus
_L203:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+17)
				move    X:FPCMasterComm,R0
				move    X:(R0+4),X0
				movec   X0,R3
				lea     (R3+9)
				jsr     FcmdScopeInit
				movei   #0,X:(SP-2)
				bra     _L213
_L206:
				move    X:FPCMasterComm,R2
				move    X:(SP-2),Y0
				lsl     Y0
				move    X:(R2+4),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				tstw    X:(R2+10)
				beq     _L208
				move    X:FPCMasterComm,R2
				move    X:(SP-2),Y0
				lsl     Y0
				move    X:(R2+4),X0
				add     X0,Y0
				movec   Y0,R2
				movei   #2,Y1
				move    X:(R2+10),Y0
				jsr     ARTREMS16Z
				tstw    Y0
				beq     _L212
_L208:
				movei   #134,X:Fresponse
				movei   #1,X:Fresponse+1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+9)
				jmp     _L297
_L212:
				inc     X:(SP-2)
_L213:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+9),X0
				cmp     X0,Y0
				blo     _L206
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+3),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+29)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #1,X0
				move    X0,X:(R0+28)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+26)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+27)
				movei   #0,X:(SP-2)
				bra     _L222
_L220:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				move    X:(SP-2),Y0
				lsl     Y0
				move    X:(R2+4),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+10),Y0
				move    X:(R0+27),X0
				add     X0,Y0
				move    Y0,X:(R0+27)
				inc     X:(SP-2)
_L222:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-2),Y0
				move    X:(R0+9),X0
				cmp     X0,Y0
				blo     _L220
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+27),X0
				lsr     X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+27)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R1
				move    X:(R1+27),Y0
				move    X:(R0+1),X0
				impy    Y0,X0,X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+1)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:FPCMasterComm,R2
				move    X:(R0+1),Y0
				move    X:(R2+3),X0
				cmp     X0,Y0
				jhi     _L246
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X:(R0+4),R1
				move    R1,X:(SP-1)
				move    X:Fstatus,X0
				andc    #15,X0
				cmp     #8,X0
				beq     _L239
				bge     _L233
				cmp     #5,X0
				beq     _L237
				bge     _L242
				cmp     #4,X0
				bge     _L235
				bra     _L242
_L233:
				cmp     #10,X0
				bge     _L242
				bra     _L241
_L235:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				bra     _L242
_L237:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    X0,X:(R0+30)
				bra     _L242
_L239:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
				bra     _L242
_L241:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				move    B1,X:(R0+31)
				move    B0,X:(R0+30)
_L242:
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				bfset   #512,X:Fstatus
				jmp     _L297
_L246:
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+4),R0
				movei   #0,X0
				move    X0,X:(R0+9)
				movei   #133,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L250:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:Flength
				move    X:Flength,Y0
				move    X:FPCMasterComm,R2
				add     #2,Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				bhi     _L256
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R3
				nop     
				lea     (R3)+
				jsr     FcmdReadMem
				movei   #0,X:Fresponse
				move    X:Flength,X0
				inc     X0
				move    X0,X:Fresponse+1
				jmp     _L297
_L256:
				movei   #132,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L259:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:Flength
				move    SR,X:(SP-2)
				bfset   #768,SR
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R3
				lea     (R3+5)
				jsr     FcmdWriteMem
				move    X:(SP-2),SR
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L267:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:Flength
				move    SR,X:(SP-2)
				bfset   #768,SR
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				move    X:FPCMasterComm,R0
				move    X:Flength,Y0
				move    X:(R0),X0
				add     Y0,X0
				movec   X0,R3
				lea     (R3+5)
				jsr     FcmdWriteMemMask
				move    X:(SP-2),SR
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L275:
				move    X:FPCMasterComm,R2
				nop     
				tstw    X:(R2+8)
				bne     _L279
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				jmp     _L297
_L279:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				move    X:FPCMasterComm,R0
				move    X:(R2+1),Y0
				move    X:(R0+8),X0
				cmp     X0,Y0
				bls     _L283
				movei   #133,X:Fresponse
				movei   #1,X:Fresponse+1
				bra     _L297
_L283:
				movei   #254,X0
				cmp     X:FpcmdrvAppCmdSts,X0
				bne     _L287
				movei   #135,X:Fresponse
				movei   #1,X:Fresponse+1
				bra     _L297
_L287:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),X0
				movec   X0,R2
				nop     
				lea     (R2)+
				move    X:FPCMasterComm,R0
				move    X:(R0+7),R3
				jsr     FcmdCallAppCmd
				movei   #254,X:FpcmdrvAppCmdSts
				movei   #0,X:Fresponse
				movei   #1,X:Fresponse+1
				bra     _L297
_L292:
				movei   #129,X:Fresponse
				movei   #1,X:Fresponse+1
				bra     _L297
_L295:
				movei   #130,X:Fresponse
				movei   #1,X:Fresponse+1
_L297:
				bfclr   #48,X:Fstatus
				movei   #Fresponse,R2
				jsr     FsendResponse
				bra     _L308
_L300:
				bfset   #16,X:Fstatus
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:FinChar,X0
				move    X0,X:(R1)
				move    X0,X:FcheckSum
				movei   #1,X:Fpos
				movei   #2,X:Flength
				movei   #192,X0
				cmp     X:FinChar,X0
				bhi     _L307
				move    X:FinChar,Y0
				andc    #48,Y0
				movei   #3,X0
				lsrr    Y0,X0,X0
				inc     X0
				move    X0,X:Flength
				bra     _L308
_L307:
				bfset   #64,X:Fstatus
_L308:
				lea     (SP-3)
				rts     


				ORG	P:
FcmdGetInfo:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				movei   #1,X:(R2+1)
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				movei   #4,X:(R2+2)
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				movei   #2,X:(R2+3)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+9),X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+4)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+10),X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+5)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+1),X0
				sub     #2,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+6)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+3),X0
				andc    #255,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+7)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+3),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+8)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+6),X0
				andc    #255,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+9)
				move    X:FPCMasterComm,R2
				nop     
				move    X:(R2+6),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X0,X:(R2+10)
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     #25,X0
				bge     _L16
_L13:
				moves   X:<mr2,X0
				add     X:FPCMasterComm,X0
				movec   X0,R2
				nop     
				move    X:(R2+11),Y1
				move    X:FPCMasterComm,R0
				moves   X:<mr2,Y0
				move    X:(R0),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    Y1,X:(R2+11)
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     #25,X0
				blt     _L13
_L16:
				rts     


				GLOBAL FpcmasterdrvIsr
				ORG	P:
FpcmasterdrvIsr:
				bfset   #256,SR
				bfclr   #512,SR
				bftstl  #4096,X:Fstatus
				jlo     _L25
				move    X:Fpos,X0
				cmp     X:Flength,X0
				jhi     _L23
				move    X:FSciFD,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				move    X:FPCMasterComm,R1
				move    X:Fpos,X0
				move    X:(R1),Y1
				add     Y1,X0
				movec   X0,R2
				movei   #1,Y1
				movei   #_L6,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L6:
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:Fpos,R0
				movec   R0,N
				move    X:(R1+N),X0
				cmp     #43,X0
				beq     _L11
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:Fpos,R0
				movec   R0,N
				move    X:(R1+N),X0
				add     X:FcheckSum,X0
				move    X0,X:FcheckSum
				inc     X:Fpos
				bra     _L17
_L11:
				bftstl  #8192,X:Fstatus
				blo     _L16
				bfclr   #8192,X:Fstatus
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:Fpos,R0
				movec   R0,N
				move    X:(R1+N),X0
				add     X:FcheckSum,X0
				move    X0,X:FcheckSum
				inc     X:Fpos
				bra     _L17
_L16:
				bfset   #8192,X:Fstatus
_L17:
				move    X:Fpos,X0
				cmp     X:Flength,X0
				jne     _L38
				bftstl  #16384,X:Fstatus
				jhs     _L38
				move    X:FcheckSum,B
				neg     B
				movec   B1,X0
				andc    #255,X0
				move    X0,X:FcheckSum
				move    X:FcheckSum,X0
				move    X:FPCMasterComm,R0
				nop     
				move    X:(R0),R1
				move    X:Fpos,R0
				movec   R0,N
				move    X0,X:(R1+N)
				bfset   #16384,X:Fstatus
				bra     _L38
_L23:
				bfclr   #20480,X:Fstatus
_L24:
				bra     _L38
_L25:
				move    X:FSciFD,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				move    X:FSciFD,R2
				nop     
				move    X:(R2+1),Y0
				movei   #FinChar,R2
				movei   #1,Y1
				movei   #_L26,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L26:
				bftstl  #32,X:Fstatus
				bhs     _L33
				movei   #43,X0
				cmp     X:FinChar,X0
				bne     _L31
				bfset   #32,X:Fstatus
				bra     _L38
_L31:
				movei   #0,Y0
				jsr     FmessageData
				bra     _L38
_L33:
				movei   #43,X0
				cmp     X:FinChar,X0
				bne     _L36
				movei   #0,Y0
				jsr     FmessageData
				bra     _L37
_L36:
				movei   #1,Y0
				jsr     FmessageData
_L37:
				bfclr   #32,X:Fstatus
_L38:
				rts     


				ORG	X:
Fresponse       BSC			2
FPCMasterComm   BSC			1
FcheckSum       BSC			1
Flength         BSC			1
Fpos            BSC			1
FinChar         BSC			1
Fstatus         BSC			1
FSciConfig      BSC			3
FSciFD          BSC			1
FpcmdrvAppCmdStsBSC			1

				ENDSEC
				END

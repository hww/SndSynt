
				SECTION qtimerdrv
				include "asmdef.h"
				GLOBAL FQTimerSuperISRA0
				ORG	P:
FQTimerSuperISRA0:
				lea     (SP)+
				move    N,X:(SP)
				movei   #34,N
				jsr     FarchEnterNestedInterruptCommon
				lea     (SP)+
				move    R2,X:(SP)+
				move    R3,X:(SP)
				movei   #FArchIO+160,R2
				movei   #Fqt_ctx_A_0,R3
				jsr     FQTIsr
				pop     R3
				pop     R2
				jsr     FarchExitNestedInterruptCommon
				pop     N
				rti     
				rts     


				GLOBAL FQTimerSuperISRA1
				ORG	P:
FQTimerSuperISRA1:
				lea     (SP)+
				move    N,X:(SP)
				movei   #35,N
				jsr     FarchEnterNestedInterruptCommon
				lea     (SP)+
				move    R2,X:(SP)+
				move    R3,X:(SP)
				movei   #FArchIO+168,R2
				movei   #Fqt_ctx_A_1,R3
				jsr     FQTIsr
				pop     R3
				pop     R2
				jsr     FarchExitNestedInterruptCommon
				pop     N
				rti     
				rts     


				GLOBAL FQTimerSuperISRA2
				ORG	P:
FQTimerSuperISRA2:
				lea     (SP)+
				move    N,X:(SP)
				movei   #36,N
				jsr     FarchEnterNestedInterruptCommon
				lea     (SP)+
				move    R2,X:(SP)+
				move    R3,X:(SP)
				movei   #FArchIO+176,R2
				movei   #Fqt_ctx_A_2,R3
				jsr     FQTIsr
				pop     R3
				pop     R2
				jsr     FarchExitNestedInterruptCommon
				pop     N
				rti     
				rts     


				GLOBAL FQTimerSuperISRA3
				ORG	P:
FQTimerSuperISRA3:
				lea     (SP)+
				move    N,X:(SP)
				movei   #37,N
				jsr     FarchEnterNestedInterruptCommon
				lea     (SP)+
				move    R2,X:(SP)+
				move    R3,X:(SP)
				movei   #FArchIO+184,R2
				movei   #Fqt_ctx_A_3,R3
				jsr     FQTIsr
				pop     R3
				pop     R2
				jsr     FarchExitNestedInterruptCommon
				pop     N
				rti     
				rts     


				ORG	P:
FQTIsr:
				lea     (SP)+
				move    Y0,X:(SP)+
				move    R1,X:(SP)+
				move    R2,X:(SP)+
				move    R3,X:(SP)
				bftsth  #16384,X:(R2+7)
				bcc     _L24
				bfclr   #-32768,X:(R2+7)
				bcc     _L24
				lea     (SP)+
				move    R3,R1
				move    #_L22,Y0
				lea     (R1+4)
				movem   P:(R1)+,R2
				move    Y0,X:(SP)+
				move    SR,X:(SP)+
				move    R2,X:(SP)+
				move    SR,X:(SP)
				movei   #0,Y0
				movem   P:(R1)+,R2
				rts     
				move    X:(SP-1),R2
				nop     
				bftsth  #4096,X:(R2+7)
				bcc     _L41
				bfclr   #8192,X:(R2+7)
				bcc     _L41
				move    X:(SP)+,R3
				move    R3,R1
				move    #_L39,Y0
				movem   P:(R1)+,R2
				move    Y0,X:(SP)+
				move    SR,X:(SP)+
				move    R2,X:(SP)+
				move    SR,X:(SP)
				movei   #1,Y0
				movem   P:(R1)+,R2
				rts     
				move    X:(SP-1),R2
				nop     
				bftsth  #1024,X:(R2+7)
				bcc     _L57
				bfclr   #2048,X:(R2+7)
				bcc     _L57
				move    X:(SP)+,R3
				move    R3,R1
				move    #_L57,Y0
				lea     (R1+2)
				movem   P:(R1)+,R2
				move    Y0,X:(SP)+
				move    SR,X:(SP)+
				move    R2,X:(SP)+
				move    SR,X:(SP)
				movei   #2,Y0
				movem   P:(R1)+,R2
				rts     
				move    X:(SP-3),Y0
				move    X:(SP-2),R1
				lea     (SP-4)
				rts     


				GLOBAL FQTimerISRA0
				ORG	P:
FQTimerISRA0:
				movei   #FArchIO+160,R2
				movei   #Fqt_ctx_A_0,R3
				jsr     FQTIsr
				rts     


				GLOBAL FQTimerISRA1
				ORG	P:
FQTimerISRA1:
				movei   #FArchIO+168,R2
				movei   #Fqt_ctx_A_1,R3
				jsr     FQTIsr
				rts     


				GLOBAL FQTimerISRA2
				ORG	P:
FQTimerISRA2:
				movei   #FArchIO+176,R2
				movei   #Fqt_ctx_A_2,R3
				jsr     FQTIsr
				rts     


				GLOBAL FQTimerISRA3
				ORG	P:
FQTimerISRA3:
				movei   #FArchIO+184,R2
				movei   #Fqt_ctx_A_3,R3
				jsr     FQTIsr
				rts     


				GLOBAL FqtFindDevice
				ORG	P:
FqtFindDevice:
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:FqtNumberOfDevices,X0
				bge     _L9
				moves   X:<mr2,X0
				asl     X0
				movec   X0,R3
				lea     (R3+FqtDeviceMap)
_L4:
				movec   R2,Y0
				move    X:(R3),X0
				cmp     X0,Y0
				bne     _L6
				moves   X:<mr2,Y0
				asl     Y0
				add     #FqtDeviceMap,Y0
				bra     _L10
_L6:
				movec   R3,X0
				movec   X0,R3
				lea     (R3+2)
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:FqtNumberOfDevices,X0
				blt     _L4
_L9:
				movei   #-1,Y0
_L10:
				rts     


				GLOBAL FqtOpen
				ORG	P:
FqtOpen:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				jsr     FqtFindDevice
				move    Y0,X:<mr8
				movei   #-1,X0
				cmp     X:<mr8,X0
				beq     _L6
				tstw    X:(SP-1)
				beq     _L6
				moves   X:<mr8,R3
				move    X:(SP-1),R2
				jsr     FSetQTParams
_L6:
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FqtClose
				ORG	P:
FqtClose:
				movec   Y0,R0
				nop     
				move    X:(R0),R2
				nop     
				movei   #0,X:(R2+6)
				movei   #0,Y0
				rts     


				GLOBAL FioctlQT_ENABLE
				ORG	P:
FioctlQT_ENABLE:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L4
				move    X:(SP),R3
				move    X:(SP-1),R2
				jsr     FSetQTParams
_L4:
				movei   #0,Y0
				lea     (SP-2)
				rts     


				ORG	P:
FSetQTParams:
				move    X:(R3+1),R1
				move    X:(R3),R3
				move    X:(R2+2),X0
				move    X0,X:(R3)
				move    X:(R2+3),X0
				move    X0,X:(R3+1)
				move    X:(R2+4),X0
				move    X0,X:(R3+3)
				move    X0,X:(R3+5)
				clr     Y0
				move    X:(R2),A0
				move    X:(R2+1),A1
				brset   #16,A1,_L15
				bfset   #1,Y0
				brclr   #8,A1,_L17
				bfset   #2,Y0
				brclr   #32,A1,_L19
				bfset   #32,Y0
				brclr   #64,A1,_L21
				bfset   #16,Y0
				move    A1,X0
				andc    #1536,X0
				asr     X0
				asr     X0
				asr     X0
				or      X0,Y0
				bftstl  #256,A0
				bcs     _L30
				bfset   #512,Y0
				tstw    X:(R2+9)
				beq     _L33
				bfset   #1024,Y0
				tstw    X:(R2+7)
				beq     _L36
				bfset   #4096,Y0
				tstw    X:(R2+5)
				beq     _L39
				bfset   #16384,Y0
				move    Y0,X:(R3+7)
				move    A1,Y0
				andc    #7,Y0
				brclr   #128,A1,_L44
				bfset   #8,Y0
				bftstl  #8192,A0
				bcs     _L47
				bfset   #16,Y0
				bftstl  #4096,A0
				bcs     _L50
				bfset   #32,Y0
				bftstl  #2048,A0
				bcs     _L53
				bfset   #64,Y0
				move    A0,X0
				andc    #1536,X0
				asr     X0
				asr     X0
				or      X0,Y0
				move    A0,B1
				andc    #240,B1
				movei   #5,Y1
				asll    B1,Y1,Y1
				or      Y1,Y0
				andc    #15,A0
				move    A0,N
				movei   #FqtExtAMask,R0
				nop     
				move    X:(R0+N),X0
				and     X0,Y0
				movei   #FqtExtAMode,R0
				nop     
				move    X:(R0+N),X0
				or      X0,Y0
				move    X:(R2+7),X0
				movem   X0,P:(R1)+
				move    X:(R2+8),X0
				movem   X0,P:(R1)+
				move    X:(R2+9),X0
				movem   X0,P:(R1)+
				move    X:(R2+10),X0
				movem   X0,P:(R1)+
				move    X:(R2+5),X0
				movem   X0,P:(R1)+
				move    X:(R2+6),X0
				movem   X0,P:(R1)+
				move    Y0,X:(R3+6)
				rts     


				ORG	X:

				ENDSEC
				END


				SECTION alseqp
				include "asmdef.h"
				GLOBAL FalCents2Ratio
				ORG	P:
FalCents2Ratio:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   B0,Y1
				movei   #60,Y0
				jsr     FalGetLinearRate
				lea     (SP-2)
				rts     


				GLOBAL FalGetLinearRate
				ORG	P:
FalGetLinearRate:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #6,N
				lea     (SP)+N
				moves   Y0,X:<mr10
				moves   Y1,X:<mr11
				moves   X:<mr11,X0
				add     #1200,X0
				move    X0,X:<mr11
				move    X:<mr11,B
				movec   B1,B0
				movec   B2,B1
				asl     B
				movei   #100,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L5
				neg     B
_L5:
				movec   B0,X0
				move    X0,X:(SP-2)
				movei   #100,Y1
				moves   X:<mr11,Y0
				jsr     ARTREMS16Z
				move    Y0,X:<mr9
				moves   X:<mr10,Y0
				move    X:(SP-2),X0
				add     Y0,X0
				sub     #12,X0
				move    X0,X:<mr10
				movei   #12,Y1
				moves   X:<mr10,Y0
				jsr     ARTREMU16Z
				move    Y0,X:(SP-3)
				movei   #12,Y1
				moves   X:<mr10,Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:<mr8
				move    X:(SP-3),X0
				lsl     X0
				movec   X0,R0
				move    X:(R0+#Fratestable+1),B
				move    X:(R0+#Fratestable),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				tstw    X:<mr9
				beq     _L15
				movei   #100,X0
				sub     X:<mr9,X0
				clr     B
				movec   X0,B0
				push    B0
				push    B1
				move    X:(SP-6),A
				move    X:(SP-7),A0
				jsr     ARTMPYU32U
				pop     
				pop     
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				clr     B
				moves   X:<mr9,X0
				move    X0,B0
				push    B0
				push    B1
				move    X:(SP-5),X0
				lsl     X0
				movei   #Fratestable+2,R0
				movec   X0,N
				lea     (R0)+N
				move    X:(R0+1),A
				move    X:(R0),A0
				jsr     ARTMPYU32U
				pop     
				pop     
				move    X:(SP-4),B
				move    X:(SP-5),B0
				add     B,A
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				movei   #0,B
				movei   #100,B0
				push    B0
				push    B1
				move    X:(SP-6),A
				move    X:(SP-7),A0
				jsr     ARTDIVU32UZ
				pop     
				pop     
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
_L15:
				moves   X:<mr8,X0
				cmp     #9,X0
				bhs     _L22
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr8,X0
				cmp     #9,X0
				bhs     _L21
_L18:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,B2
				asr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #9,X0
				blo     _L18
_L21:
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
_L22:
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpNew
				ORG	P:
FalSeqpNew:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				nop     
				movei   #32767,X:(R2+13)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+20)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+2)
				movei   #0,X:(R2+3)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+8)
				movei   #0,X:(R2+9)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+62)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+63)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+8),R0
				move    X:(SP),R2
				move    R0,X:(R2+64)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+19)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+18)
				moves   X:<mr9,Y0
				movei   #12,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+56)
				move    X:(SP-1),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				movec   B0,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				movei   #32,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+57)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+58)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+59)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+60)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+61)
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				bge     _L26
				moves   X:<mr8,Y0
				movei   #5,X0
				asll    Y0,X0,X0
				move    X0,X:<mr10
_L22:
				move    X:(SP),R2
				moves   X:<mr10,Y0
				move    X:(R2+57),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+60)
				jsr     FalLink
				moves   X:<mr10,X0
				add     #32,X0
				move    X0,X:<mr10
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     X:<mr9,X0
				blt     _L22
_L26:
				move    X:(SP),R2
				nop     
				movei   #65535,X:(R2+12)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				movec   B0,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				movei   #13,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+29)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				move    X:(SP),R0
				move    X:(R0+29),R3
				move    X:<mr9,B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				jsr     FalEvtqNew
				moves   X:<mr9,Y0
				movei   #13,Y1
				jsr     FmemCallocEM
				move    X:(SP),R0
				move    R2,X:(R0+47)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				move    X:(SP),R0
				move    X:(R0+47),R3
				move    X:<mr9,B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				jsr     FalEvtqNew
				move    X:(SP),R0
				move    X:FalGlobals,R1
				move    R1,X:(R0)
				movei   #FalSeqpHandler,R0
				move    X:(SP),R1
				nop     
				move    X:(R1),R2
				nop     
				move    R0,X:(R2+7)
				move    X:(SP),R0
				move    X:(SP),R1
				nop     
				move    X:(R1),R2
				nop     
				move    R0,X:(R2+6)
				movei   #FalSeqpFrameHandler,R0
				move    X:(SP),R1
				nop     
				move    X:(R1),R2
				nop     
				move    R0,X:(R2+12)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+15)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+14)
				jsr     FmidiOpen
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpDelete
				ORG	P:
FalSeqpDelete:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+56),R2
				jsr     FmemFreeEM
				move    X:(SP),R2
				nop     
				move    X:(R2+57),R2
				jsr     FmemFreeEM
				move    X:(SP),R2
				nop     
				move    X:(R2+29),R2
				jsr     FmemFreeEM
				jsr     FmidiClose
				lea     (SP)-
				rts     


				GLOBAL FalSeqpSetSeq
				ORG	P:
FalSeqpSetSeq:
				move    R3,X:(R2+1)
				rts     


				GLOBAL FalSeqpGetSeq
				ORG	P:
FalSeqpGetSeq:
				move    X:(R2+1),R2
				rts     


				GLOBAL FalSeqpPlay
				ORG	P:
FalSeqpPlay:
				movei   #10,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				movei   #0,A
				movei   #1,A0
				cmp     A,B
				beq     _L6
				move    X:(SP),R2
				nop     
				movei   #1,X:(R2+10)
				movei   #0,X:(R2+11)
				movei   #18,X:(SP-9)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				movec   SP,R3
				lea     (R3-9)
				movei   #0,A
				movei   #10000,A0
				jsr     FalEvtqPostEvent
_L6:
				lea     (SP-10)
				rts     


				GLOBAL FalSeqpStop
				ORG	P:
FalSeqpStop:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+10)
				movei   #0,X:(R2+11)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L9
_L5:
				move    X:(SP),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				beq     _L7
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpVoiceOff
_L7:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				tstw    X:(SP)
				bne     _L5
_L9:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				movei   #3,Y0
				jsr     FalEvtqFlushType
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				movei   #5,Y0
				jsr     FalEvtqFlushType
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpGetState
				ORG	P:
FalSeqpGetState:
				move    X:(R2+11),A
				move    X:(R2+10),A0
				rts     


				GLOBAL FalSeqpSetBank
				ORG	P:
FalSeqpSetBank:
				move    R3,X:(R2+4)
				rts     


				GLOBAL FalSeqpSetTempo
				ORG	P:
FalSeqpSetTempo:
				move    X:<mr8,N
				push    N
				movei   #13,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				move    X:(SP),R2
				nop     
				move    X:(R2+15),X0
				move    X0,X:<mr8
				move    X:(SP-1),B
				move    X:(SP-2),B0
				asr     B
				asr     B
				move    B1,X:(SP-11)
				move    B0,X:(SP-12)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+17)
				move    B0,X:(R2+16)
				move    X:(SP-11),B
				move    X:(SP-12),B0
				move    B1,X:(SP-9)
				move    B0,X:(SP-10)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(SP-7)
				move    B0,X:(SP-8)
				tstw    X:<mr8
				ble     _L11
_L8:
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    X:(SP-7),A
				move    X:(SP-8),A0
				sub     B,A
				move    A1,X:(SP-7)
				move    A0,X:(SP-8)
				dec     X:<mr8
				tstw    X:<mr8
				bgt     _L8
_L11:
				move    X:(SP-7),B
				move    X:(SP-8),B0
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    B1,X:(SP-11)
				move    B0,X:(SP-12)
				move    X:(SP-11),B
				move    X:(SP-12),B0
				move    B1,X:(SP-5)
				move    B0,X:(SP-6)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				tstw    X:<mr8
				bge     _L19
_L16:
				move    X:(SP-5),B
				move    X:(SP-6),B0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				add     A,B
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				inc     X:<mr8
				tstw    X:<mr8
				blt     _L16
_L19:
				move    X:(SP-3),B
				move    X:(SP-4),B0
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-5),B
				move    X:(SP-6),B0
				move    B1,X:(SP-11)
				move    B0,X:(SP-12)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+12),B
				movec   B1,B0
				movec   B2,B1
				push    B0
				push    B1
				move    X:(SP-3),A
				move    X:(SP-4),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+7)
				move    A0,X:(R2+6)
				lea     (SP-13)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpSetTempoX
				ORG	P:
FalSeqpSetTempoX:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+15)
				move    X:(SP),R2
				nop     
				move    X:(R2+17),A
				move    X:(R2+16),A0
				move    X:(SP),R2
				jsr     FalSeqpSetTempo
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpGetTempo
				ORG	P:
FalSeqpGetTempo:
				move    X:(R2+17),A
				move    X:(R2+16),A0
				rts     


				GLOBAL FalSeqpGetVol
				ORG	P:
FalSeqpGetVol:
				move    X:(R2+13),Y0
				rts     


				GLOBAL FalSeqpSetVol
				ORG	P:
FalSeqpSetVol:
				move    Y0,X:(R2+13)
				rts     


				GLOBAL FalSeqpLoop
				ORG	P:
FalSeqpLoop:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    R3,X:(R2+65)
				move    X:(SP-4),R0
				move    R0,X:(R2+66)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(R2+69)
				move    B0,X:(R2+68)
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpSendMidi
				ORG	P:
FalSeqpSendMidi:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #14,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   Y1,X:<mr10
				move    X:(SP-2),X0
				andc    #240,X0
				move    X0,X:(SP-4)
				move    X:(SP-2),X0
				andc    #15,X0
				move    X0,X:<mr9
				moves   X:<mr8,R2
				moves   X:<mr9,X0
				movei   #1,Y0
				lsll    Y0,X0,Y0
				move    X:(R2+12),X0
				and     X0,Y0
				tstw    Y0
				jeq     _L42
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				ble     _L13
				movei   #2,X:(SP-13)
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-11)
				move    X:(SP-2),X0
				move    X0,X:(SP-10)
				moves   X:<mr10,X0
				move    X0,X:(SP-9)
				move    X:(SP-20),X0
				move    X0,X:(SP-8)
				move    X:(SP),B
				move    X:(SP-1),B0
				push    B0
				push    B1
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				movec   SP,R3
				lea     (R3-13)
				jsr     FalEvtqPostEvent
				jmp     _L42
_L13:
				moves   X:<mr8,R2
				movei   #12,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,Y0
				move    X:(R2+56),X0
				add     X0,Y0
				move    Y0,X:<mr11
				move    X:(SP-4),X0
				cmp     #176,X0
				beq     _L33
				bge     _L22
				cmp     #144,X0
				beq     _L28
				bge     _L20
				cmp     #128,X0
				beq     _L31
				jmp     _L42
_L20:
				cmp     #160,X0
				jeq     _L42
				jmp     _L42
_L22:
				cmp     #208,X0
				jeq     _L42
				bge     _L26
				cmp     #192,X0
				beq     _L35
				jmp     _L42
_L26:
				cmp     #224,X0
				beq     _L37
				jmp     _L42
_L28:
				tstw    X:(SP-20)
				beq     _L31
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpKeyOn
				pop     
				bra     _L42
_L31:
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpKeyOff
				pop     
				bra     _L42
_L33:
				move    X:(SP-20),X0
				push    X0
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpControlChange
				pop     
				bra     _L42
_L35:
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				moves   X:<mr10,Y1
				jsr     FalSeqpSetChlProgram
				bra     _L42
_L37:
				move    X:(SP-20),Y0
				movei   #7,X0
				lsll    Y0,X0,X0
				add     X:<mr10,X0
				add     #-8192,X0
				move    X0,X:(SP-3)
				moves   X:<mr11,R2
				move    X:(SP-3),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				asr     B
				bge     _L40
				adc     Y,B
				sub     Y,B
_L40:
				moves   X:<mr11,R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
				moves   X:<mr8,R2
				moves   X:<mr9,Y0
				jsr     FalSeqpChangePitch
_L42:
				lea     (SP-14)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpSwitchEvent
				ORG	P:
FalSeqpSwitchEvent:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr8,X0
				cmp     #18,X0
				jgt     _L29
				asl     X0
				add     #_L5,X0
				push    X0
				push    SR
				rti     
				jmp     _L25
				jmp     _L29
				jmp     _L7
				jmp     _L6
				jmp     _L9
				jmp     _L9
				jmp     _L14
				jmp     _L29
				jmp     _L19
				jmp     _L21
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L29
				jmp     _L23
_L6:
				move    X:(SP),R2
				jsr     FalSeqpPlayer
_L7:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				push    X0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),Y1
				move    X:(SP-1),R2
				clr     A
				jsr     FalSeqpSendMidi
				pop     
				jmp     _L29
_L9:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+6),B0
				move    B0,B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				clr     A
				movec   X0,A0
				add     B,A
				move    X:(SP-1),R2
				clr     B
				move    X:(R2+8),B0
				add     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),R2
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalSeqpSetTempo
				moves   X:<mr8,X0
				cmp     #5,X0
				jne     _L29
				move    X:(SP),R2
				jsr     FalSeqpPlayer
				jmp     _L29
_L14:
				move    X:(SP),R2
				jsr     FalSeqpStop
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+3),B
				move    X:(R0+2),B0
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    B1,X:(R0+5)
				move    B0,X:(R0+4)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				clr     B
				move    B1,X:(R0+7)
				move    B0,X:(R0+6)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				movei   #0,X0
				move    X0,X:(R0+13)
				jmp     _L29
_L19:
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpEnvVolEvent
				jmp     _L29
_L21:
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpEnvPanEvent
				bra     _L29
_L23:
				move    X:(SP),R2
				jsr     FalSeqpPlayer
				bra     _L29
_L25:
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+12),Y0
				movei   #5,X0
				asrr    Y0,X0,X0
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				move    X:(SP-1),R3
				jsr     FalEvtqPostEvent
				move    X:(SP-1),R2
				jsr     FmidiGetMsg
				tstw    Y0
				beq     _L29
_L27:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),X0
				push    X0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),Y1
				move    X:(SP-1),R2
				clr     A
				jsr     FalSeqpSendMidi
				pop     
				move    X:(SP-1),R2
				jsr     FmidiGetMsg
				tstw    Y0
				bne     _L27
_L29:
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpHandler
				ORG	P:
FalSeqpHandler:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				move    X:(SP-1),R0
				move    X:(R0+9),A
				move    X:(R0+8),A0
				jsr     FalMicroTimeAdd
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),A
				move    X:(R2+8),A0
				move    X:(SP-1),R2
				jsr     FalSeqpEnvTimers
_L5:
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+20)
				move    X:(SP-1),R2
				jsr     FalSeqpSwitchEvent
				move    X:(SP-1),R2
				nop     
				move    X:(R2+35),B
				move    X:(R2+34),B0
				tst     B
				ble     _L9
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+20)
				jsr     FalEvtqNextEvent
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+9)
				move    A0,X:(R2+8)
				bra     _L10
_L9:
				debug   
_L10:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				beq     _L5
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				bge     _L13
				debug   
_L13:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+9),A
				move    X:(R2+8),A0
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpFrameHandler
				ORG	P:
FalSeqpFrameHandler:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R0
				move    R0,X:(SP-1)
_L3:
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+38)
				move    X:(SP-1),R2
				jsr     FalSeqpVibOscEvent
				move    X:(SP-1),R2
				nop     
				move    X:(R2+53),B
				move    X:(R2+52),B0
				tst     B
				beq     _L7
				move    X:(SP-1),X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+38)
				jsr     FalEvtqNextEvent
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+37)
				move    A0,X:(R2+36)
				bra     _L9
_L7:
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+36)
				movei   #0,X:(R2+37)
				bra     _L10
_L9:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+37),B
				move    X:(R2+36),B0
				tst     B
				beq     _L3
_L10:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+37),B
				move    X:(R2+36),B0
				tst     B
				bge     _L12
				debug   
_L12:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+37),A
				move    X:(R2+36),A0
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpPlayer
				ORG	P:
FalSeqpPlayer:
				movei   #13,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP-1)
				movei   #0,X:(SP-11)
				movei   #0,X:(SP-10)
				jmp     _L23
_L5:
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP-1),R2
				jsr     FalSeqNextEvent
				move    X:(SP-10),B
				move    X:(SP-11),B0
				tst     B
				bne     _L9
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP),R2
				jsr     FalSeqpSwitchEvent
				bra     _L15
_L9:
				move    X:(SP-12),X0
				cmp     #2,X0
				bne     _L11
				movei   #3,X:(SP-12)
_L11:
				move    X:(SP-12),X0
				cmp     #4,X0
				bne     _L13
				movei   #5,X:(SP-12)
_L13:
				move    X:(SP-10),B
				move    X:(SP-11),B0
				push    B0
				push    B1
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),A
				move    X:(R2+6),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalEvtqPostEvent
_L15:
				move    X:(SP),R0
				tstw    X:(R0+66)
				beq     _L23
				move    X:(SP),R0
				move    X:(R0+66),R1
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    X:(R1+1),B
				move    X:(R1),B0
				move    X:(R0+5),A
				move    X:(R0+4),A0
				cmp     A,B
				bne     _L23
				move    X:(SP),R0
				move    X:(R0+69),B
				move    X:(R0+68),B0
				tst     B
				bne     _L21
				movei   #0,X0
				push    X0
				move    X:(SP-1),R2
				clr     A
				movei   #176,Y0
				movei   #123,Y1
				jsr     FalSeqpSendMidi
				pop     
				move    X:(SP),R2
				jsr     FalSeqpStop
				bra     _L23
_L21:
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R2
				move    X:(SP),R0
				move    X:(R0+65),R3
				jsr     FalSeqSetLoc
				move    X:(SP),R0
				movei   #-1,B
				movei   #-1,B0
				move    X:(R0+69),A
				move    X:(R0+68),A0
				add     A,B
				move    B1,X:(R0+69)
				move    B0,X:(R0+68)
_L23:
				move    X:(SP),R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				movei   #0,A
				movei   #1,A0
				cmp     A,B
				bne     _L25
				move    X:(SP-10),B
				move    X:(SP-11),B0
				tst     B
				jeq     _L5
_L25:
				lea     (SP-13)
				rts     


				GLOBAL FalSeqpGetFreeVoice
				ORG	P:
FalSeqpGetFreeVoice:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				move    X:(R2+60),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L7
				move    X:(SP),R2
				jsr     FalUnlink
				moves   X:<mr8,X0
				movec   X0,R3
				lea     (R3+58)
				move    X:(SP),R2
				jsr     FalLink
				move    X:(SP),R2
				bra     _L8
_L7:
				movei   #0,R2
_L8:
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpFreeVoice
				ORG	P:
FalSeqpFreeVoice:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpCheckVoice
				tstw    Y0
				beq     _L5
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R3
				jsr     FalSynStopVoice
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R3
				jsr     FalSynFreeVoice
_L5:
				move    X:(SP-1),R2
				jsr     FalUnlink
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+60)
				move    X:(SP-1),R2
				jsr     FalLink
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpCheckVoice
				ORG	P:
FalSeqpCheckVoice:
				movec   R3,R2
				nop     
				bftstl  #32,X:(R2+4)
				movei   #0,Y0
				blo     _L3
				movei   #1,Y0
_L3:
				rts     


				GLOBAL FalSeqpFlushEventsOfVoice
				ORG	P:
FalSeqpFlushEventsOfVoice:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+31),X0
				andc    #1,X0
				tstw    X0
				beq     _L5
				move    X:(SP),R2
				move    X:(R2+64),R0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+30),R2
				movei   #_L4,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L4:
				move    X:(SP-1),R2
				nop     
				andc    #-2,X:(R2+31)
_L5:
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				move    X:(SP-1),R3
				jsr     FalEvtqFlushVoice
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				move    X:(SP-1),R3
				jsr     FalEvtqFlushVoice
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpKeyOn
				ORG	P:
FalSeqpKeyOn:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #5,N
				lea     (SP)+N
				moves   R2,X:<mr9
				moves   Y0,X:<mr11
				moves   Y1,X:<mr10
				moves   X:<mr9,R2
				movei   #12,Y0
				moves   X:<mr11,X0
				impy    Y0,X0,Y0
				move    X:(R2+56),X0
				add     X0,Y0
				move    Y0,X:(SP-4)
				move    X:(SP-4),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-3)
				tstw    R1
				jeq     _L33
				move    X:(SP-3),R2
				move    X:(SP-4),R0
				move    X:(R0+5),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-2)
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),X0
				cmp     #127,X0
				beq     _L7
				moves   X:<mr9,R2
				nop     
				move    X:(R2+14),X0
				add     X:<mr10,X0
				move    X0,X:<mr10
_L7:
				move    X:(SP-3),R2
				moves   X:<mr10,Y0
				move    X:(SP-11),Y1
				jsr     FalSeqpGetSound
				move    R2,X:(SP-1)
				tstw    R2
				jeq     _L33
				moves   X:<mr9,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:<mr8
				moves   X:<mr8,R2
				moves   X:<mr11,Y0
				moves   X:<mr10,Y1
				jsr     FalSeqpFindVoiceChlKey
				move    R2,X:<mr8
				tstw    R2
				beq     _L13
_L10:
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpVoiceOff
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr8
				moves   X:<mr8,R2
				moves   X:<mr11,Y0
				moves   X:<mr10,Y1
				jsr     FalSeqpFindVoiceChlKey
				move    R2,X:<mr8
				tstw    R2
				bne     _L10
_L13:
				moves   X:<mr9,R2
				jsr     FalSeqpGetFreeVoice
				move    R2,X:<mr8
				tstw    R2
				jeq     _L33
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R2
				move    X:(SP-2),Y0
				moves   X:<mr8,R3
				jsr     FalSynAllocVoice
				move    Y0,X:(SP)
				move    X:(SP),X0
				cmp     #1,X0
				jne     _L32
				move    X:(SP-3),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+8)
				move    X:(SP-1),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+7)
				moves   X:<mr11,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+27)
				moves   X:<mr10,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+28)
				move    X:(SP-11),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+29)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),R0
				move    X:(R0+6),X0
				cmp     #32000,X0
				bne     _L24
				moves   X:<mr8,R2
				nop     
				movei   #-32768,X:(R2+6)
				bra     _L27
_L24:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),R0
				move    X:(R0+6),B
				neg     B
				movec   B1,B
				movei   #32000,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L26
				neg     B
_L26:
				movec   B0,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+6)
_L27:
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpStartEnvelope
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpStartOsc
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpSetPitch
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),R0
				push    R0
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R2
				moves   X:<mr8,R3
				jsr     FalSynStartVoice
				pop     
				bra     _L33
_L32:
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSeqpFreeVoice
_L33:
				lea     (SP-5)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpVoiceOff
				ORG	P:
FalSeqpVoiceOff:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				movei   #3,X:(R2+14)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpVolMix
				lea     (SP-2)
				rts     


				GLOBAL FalSeqpKeyOff
				ORG	P:
FalSeqpKeyOff:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   Y0,X:<mr9
				moves   Y1,X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+56),X0
				movei   #12,Y1
				moves   X:<mr9,Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				nop     
				lea     (R0)+
				movec   Y0,N
				move    X:(R0+N),X0
				cmp     #127,X0
				beq     _L4
				moves   X:<mr8,R2
				nop     
				move    X:(R2+14),X0
				add     X:<mr10,X0
				move    X0,X:<mr10
_L4:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:(SP)
				move    X:(SP),R2
				moves   X:<mr9,Y0
				moves   X:<mr10,Y1
				jsr     FalSeqpFindVoiceChlKey
				move    R2,X:(SP)
				tstw    R2
				beq     _L12
_L6:
				movei   #12,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+56),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				tstw    X:(R2+8)
				bne     _L9
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpVoiceOff
				bra     _L10
_L9:
				move    X:(SP),R2
				nop     
				movei   #2,X:(R2+14)
_L10:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				move    X:(SP),R2
				moves   X:<mr9,Y0
				moves   X:<mr10,Y1
				jsr     FalSeqpFindVoiceChlKey
				move    R2,X:(SP)
				tstw    R2
				bne     _L6
_L12:
				lea     (SP)-
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpGetSound
				ORG	P:
FalSeqpGetSound:
				moves   R2,X:<mr4
				moves   Y1,X:<mr3
				moves   X:<mr4,R0
				move    X:(R0+9),X0
				move    X0,X:<mr5
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr5,X0
				bge     _L14
_L5:
				moves   X:<mr2,X0
				add     X:<mr4,X0
				movec   X0,R0
				move    X:(R0+10),R3
				move    X:(R3+2),R2
				nop     
				move    X:(R2+2),X0
				cmp     Y0,X0
				bhi     _L12
				move    X:(R2+3),X0
				cmp     Y0,X0
				blo     _L12
				move    X:(R2),X0
				cmp     X:<mr3,X0
				bhi     _L12
				move    X:(R2+1),X0
				cmp     X:<mr3,X0
				blo     _L12
				movec   R3,R2
				bra     _L15
_L12:
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr5,X0
				blt     _L5
_L14:
				movei   #0,R2
_L15:
				rts     


				GLOBAL FalSeqpEnvelope
				ORG	P:
FalSeqpEnvelope:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   #1,X:<mr8
				tstw    X:(SP-2)
				beq     _L11
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				bftstl  #256,X0
				blo     _L11
				move    X:(SP-1),R2
				move    X:(SP-6),R0
				move    X:(R2+3),Y0
				move    X:(R0+2),X0
				cmp     X0,Y0
				jlo     _L22
				move    X:(SP-6),R2
				move    X:(SP-6),R0
				move    X:(R2+1),Y0
				move    X:(R0+2),X0
				cmp     X0,Y0
				bne     _L9
				moves   #0,X:<mr8
				bra     _L22
_L9:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+3)
				bra     _L22
_L11:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				bftstl  #512,X0
				blo     _L19
				move    X:(SP-1),R2
				move    X:(SP-6),R0
				move    X:(R2+3),Y0
				move    X:(R0+4),X0
				cmp     X0,Y0
				blo     _L22
				move    X:(SP-6),R2
				move    X:(SP-6),R0
				move    X:(R2+3),Y0
				move    X:(R0+4),X0
				cmp     X0,Y0
				bne     _L17
				moves   #0,X:<mr8
				move    X:(SP),R2
				nop     
				movei   #3,X:(R2+14)
				bra     _L22
_L17:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+3),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+3)
				bra     _L22
_L19:
				move    X:(SP-1),R2
				move    X:(SP-6),R0
				move    X:(R0+5),Y0
				move    X:(R2+3),X0
				dec     Y0
				cmp     Y0,X0
				blo     _L22
				moves   #0,X:<mr8
				move    X:(SP),R2
				nop     
				movei   #3,X:(R2+14)
_L22:
				tstw    X:<mr8
				beq     _L28
				movei   #0,B
				movei   #1000,B0
				push    B0
				push    B1
				move    X:(SP-8),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+3),Y1
				movec   Y1,X0
				inc     Y1
				move    Y1,X:(R2+3)
				lsl     X0
				movec   Y0,R0
				lea     (R0+7)
				movec   X0,N
				clr     B
				move    X:(R0+N),B0
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				move    X:(SP-1),R0
				move    A1,X:(R0+1)
				move    A0,X:(R0)
				move    X:(SP-1),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				tst     B
				bne     _L26
				move    X:(SP-1),R0
				movei   #0,B
				movei   #19999,B0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L26:
				move    X:(SP-6),Y0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),X0
				lsl     X0
				movec   Y0,R0
				lea     (R0+6)
				movec   X0,N
				move    X:(R0+N),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+2)
				bra     _L29
_L28:
				move    X:(SP-1),R0
				clr     B
				move    B1,X:(R0+1)
				move    B0,X:(R0)
_L29:
				move    X:(SP-1),R0
				move    X:(R0+1),A
				move    X:(R0),A0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpEnvTimers
				ORG	P:
FalSeqpEnvTimers:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:(SP-2)
				tstw    X:(SP-2)
				jeq     _L18
_L4:
				move    X:(SP-2),R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr9
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+19)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+23)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
				move    X:(SP-2),R2
				nop     
				bftstl  #16,X:(R2+4)
				bhs     _L11
				moves   X:<mr8,R2
				move    X:(SP-2),R3
				jsr     FalSeqpFlushEventsOfVoice
				moves   X:<mr8,R2
				move    X:(SP-2),R3
				jsr     FalSeqpFreeVoice
				bra     _L16
_L11:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				bne     _L16
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+16)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FalMicroTimeSub
				move    X:(SP-2),R2
				nop     
				move    X:(R2+4),X0
				andc    #192,X0
				cmp     #192,X0
				bne     _L16
				moves   X:<mr8,R2
				move    X:(SP-2),R3
				jsr     FalSeqpFlushEventsOfVoice
				moves   X:<mr8,R2
				move    X:(SP-2),R3
				jsr     FalSeqpFreeVoice
_L16:
				moves   X:<mr9,R0
				move    R0,X:(SP-2)
				tstw    X:(SP-2)
				jne     _L4
_L18:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpEnvVolEvent
				ORG	P:
FalSeqpEnvVolEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				moves   R3,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+56),X0
				move    X:(SP),R2
				movei   #12,Y1
				move    X:(R2+27),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+8)
				movec   Y0,N
				tstw    X:(R0+N)
				bne     _L5
				move    X:(SP),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				beq     _L6
_L5:
				movei   #1,X0
				bra     _L7
_L6:
				movei   #0,X0
_L7:
				move    X0,X:<mr10
				move    X:(SP),R2
				nop     
				move    X:(R2+7),R0
				nop     
				move    X:(R0),R1
				push    R1
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+19)
				move    X:(SP-1),R2
				moves   X:<mr10,Y0
				jsr     FalSeqpEnvelope
				pop     
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpVolMix
				move    X:(SP-1),B
				move    X:(SP-2),B0
				tst     B
				beq     _L12
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				moves   X:<mr9,R3
				move    X:(SP-1),A
				move    X:(SP-2),A0
				jsr     FalEvtqPostEvent
_L12:
				move    X:(SP-1),A
				move    X:(SP-2),A0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpEnvPanEvent
				ORG	P:
FalSeqpEnvPanEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				moves   R3,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+56),X0
				move    X:(SP),R2
				movei   #12,Y1
				move    X:(R2+27),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+8)
				movec   Y0,N
				tstw    X:(R0+N)
				bne     _L5
				move    X:(SP),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				beq     _L6
_L5:
				movei   #1,X0
				bra     _L7
_L6:
				movei   #0,X0
_L7:
				move    X0,X:<mr10
				move    X:(SP),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+1),R1
				push    R1
				move    X:(SP-1),X0
				movec   X0,R3
				lea     (R3+23)
				move    X:(SP-1),R2
				moves   X:<mr10,Y0
				jsr     FalSeqpEnvelope
				pop     
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				tst     B
				beq     _L12
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpPanMix
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				moves   X:<mr9,R3
				move    X:(SP-1),A
				move    X:(SP-2),A0
				jsr     FalEvtqPostEvent
_L12:
				move    X:(SP-1),A
				move    X:(SP-2),A0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpStartEnvelope
				ORG	P:
FalSeqpStartEnvelope:
				movei   #13,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				movei   #32767,X:(R2+18)
				move    X:(SP-1),R2
				nop     
				movei   #1,X:(R2+14)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+7),X0
				bftstl  #1024,X0
				blo     _L14
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				nop     
				move    X:(R0),Y0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+5),X0
				lsl     X0
				movec   Y0,R0
				lea     (R0+5)
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FalMiliToMicro
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+17)
				move    A0,X:(R2+16)
				movei   #8,X:(SP-12)
				move    X:(SP-1),R0
				move    R0,X:(SP-11)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+22)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+6),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+21)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+19)
				movei   #0,X:(R2+20)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpVolMix
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP),R2
				jsr     FalSeqpEnvVolEvent
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L18
_L14:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+6),Y0
				jsr     FalMiliToMicro
				move    X:(SP-1),R2
				nop     
				move    A1,X:(R2+17)
				move    A0,X:(R2+16)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+19)
				movei   #0,X:(R2+20)
				move    X:(SP-1),R2
				nop     
				movei   #127,X:(R2+21)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpVolMix
_L18:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+7),X0
				bftstl  #2048,X0
				blo     _L27
				movei   #9,X:(SP-12)
				move    X:(SP-1),R0
				move    R0,X:(SP-11)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+26)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+1),R2
				nop     
				move    X:(R2+6),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+25)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+23)
				movei   #0,X:(R2+24)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpPanMix
				movec   SP,R3
				lea     (R3-12)
				move    X:(SP),R2
				jsr     FalSeqpEnvPanEvent
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L30
_L27:
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+23)
				movei   #0,X:(R2+24)
				move    X:(SP-1),R2
				nop     
				movei   #64,X:(R2+25)
				move    X:(SP),R2
				move    X:(SP-1),R3
				jsr     FalSeqpPanMix
_L30:
				lea     (SP-13)
				rts     


				GLOBAL FalSeqpVolMix
				ORG	P:
FalSeqpVolMix:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #5,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				movei   #258,Y0
				move    X:(R2+29),X0
				impy    Y0,X0,X0
				move    X:(SP),R2
				nop     
				move    X:(R2+56),Y0
				movec   Y0,X:(SP-4)
				move    X:(SP-1),R2
				movei   #12,Y1
				move    X:(R2+27),Y0
				impy    Y1,Y0,Y0
				movec   X:(SP-4),R0
				lea     (R0+6)
				movec   Y0,N
				move    X:(R0+N),Y1
				movei   #258,Y0
				impy    Y1,Y0,Y0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+8),R1
				nop     
				move    X:(R1),Y0
				move    X:(R0+5),X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				moves   X:<mr8,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP),R2
				nop     
				move    X:(R2+13),Y0
				moves   X:<mr8,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+20),B
				move    X:(R2+19),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				jne     _L14
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+17),B
				move    X:(R2+16),B0
				move    X:(R0+20),A
				move    X:(R0+19),A0
				cmp     A,B
				ble     _L10
				move    X:(SP-1),R2
				nop     
				move    X:(R2+20),B
				move    X:(R2+19),B0
				tst     B
				bne     _L13
_L10:
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+18)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+17),B
				move    X:(R2+16),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				bra     _L14
_L13:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+18),B0
				move    B0,B
				move    X:(SP-1),R2
				nop     
				move    X:(R2+17),A
				move    X:(R2+16),A0
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-1),R2
				push    A0
				push    A1
				move    X:(R2+20),A
				move    X:(R2+19),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,A0
				movec   A0,X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+18)
_L14:
				move    X:(SP-1),R2
				movei   #258,Y0
				move    X:(R2+21),X0
				impy    Y0,X0,Y0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+18),X0
				mpy     X0,Y0,B
				movec   B1,X0
				move    X0,X:<mr10
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				moves   X:<mr8,Y0
				move    X:(SP-1),R3
				jsr     FalSynSetGain
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				moves   X:<mr10,Y0
				move    X:(SP-1),R3
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalSynSetVol
				lea     (SP-5)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpPanMix
				ORG	P:
FalSeqpPanMix:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+7),R0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+8),R1
				move    X:(R1+1),Y0
				move    X:(R0+4),X0
				add     X0,Y0
				add     #-64,Y0
				move    Y0,X:<mr10
				move    X:(SP),R2
				nop     
				move    X:(R2+56),X0
				move    X:(SP-1),R2
				movei   #12,Y1
				move    X:(R2+27),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+4)
				movec   Y0,N
				move    X:(R0+N),X0
				add     X:<mr10,X0
				add     #-64,X0
				move    X0,X:<mr9
				move    X:(SP-1),R2
				nop     
				move    X:(R2+25),Y0
				moves   X:<mr9,X0
				add     Y0,X0
				add     #-64,X0
				move    X0,X:<mr8
				movei   #127,X0
				cmp     X:<mr8,X0
				bge     _L8
				moves   #127,X:<mr8
				bra     _L10
_L8:
				tstw    X:<mr8
				bge     _L10
				moves   #0,X:<mr8
_L10:
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-1),R0
				move    X:(R0+24),A
				move    X:(R0+23),A0
				move    X:(SP-1),R3
				moves   X:<mr8,Y0
				jsr     FalSynSetPan
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpFindVoiceChl
				ORG	P:
FalSeqpFindVoiceChl:
				tstw    R2
				beq     _L6
_L2:
				move    X:(R2+27),X0
				cmp     Y0,X0
				beq     _L6
_L4:
				move    X:(R2),R2
				tstw    R2
				bne     _L2
_L6:
				rts     


				GLOBAL FalSeqpFindVoiceChlKey
				ORG	P:
FalSeqpFindVoiceChlKey:
				moves   Y1,X:<mr2
				tstw    R2
				beq     _L9
_L3:
				move    X:(R2+27),X0
				cmp     Y0,X0
				bne     _L7
				move    X:(R2+28),X0
				cmp     X:<mr2,X0
				bne     _L7
				move    X:(R2+14),X0
				cmp     #3,X0
				bne     _L9
_L7:
				move    X:(R2),R2
				tstw    R2
				bne     _L3
_L9:
				rts     


				GLOBAL FalSeqpSetPitch
				ORG	P:
FalSeqpSetPitch:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    R3,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+7),R0
				move    X:(R0+2),R1
				move    R1,X:(SP-1)
				move    X:(SP),R2
				nop     
				move    X:(R2+28),X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+5),B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP),R2
				nop     
				move    X:(R2+13),A
				move    X:(R2+12),A0
				add     B,A
				moves   X:<mr9,R2
				nop     
				move    X:(R2+56),X0
				move    X:(SP),R2
				movei   #12,Y1
				move    X:(R2+27),Y0
				impy    Y1,Y0,Y0
				movec   X0,R0
				lea     (R0+10)
				movec   Y0,N
				lea     (R0)+N
				move    X:(R0+1),B
				move    X:(R0),B0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+4),Y0
				movei   #60,X0
				sub     Y0,X0
				add     X:<mr8,X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movec   B0,Y1
				jsr     FalGetLinearRate
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R2
				move    X:(SP),R3
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalSynSetPitch
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpChangePitch
				ORG	P:
FalSeqpChangePitch:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   Y0,X:<mr9
				moves   X:<mr8,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:(SP)
_L3:
				moves   X:<mr9,Y0
				move    X:(SP),R2
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L8
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpSetPitch
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				bra     _L3
_L8:
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSeqpStartOsc
				ORG	P:
FalSeqpStartOsc:
				movei   #14,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+8),R0
				move    R0,X:(SP-2)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+31)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+12)
				movei   #0,X:(R2+13)
				move    X:(SP-2),R2
				nop     
				tstw    X:(R2+4)
				jeq     _L25
				move    X:(SP-2),R2
				nop     
				move    X:(R2+7),X0
				push    X0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+6),X0
				push    X0
				move    X:(SP-2),R2
				nop     
				move    X:(R2+62),R0
				move    X:(SP-3),X0
				movec   X0,R2
				nop     
				lea     (R2+30)
				move    X:(SP-3),X0
				movec   X0,R3
				lea     (R3+12)
				move    X:(SP-4),R1
				move    X:(R1+4),Y0
				move    X:(SP-4),R1
				move    X:(R1+5),Y1
				movei   #_L7,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L7:
				lea     (SP-2)
				move    A1,X:(SP-12)
				move    A0,X:(SP-13)
				move    X:(SP-1),R2
				nop     
				orc     #1,X:(R2+31)
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				move    X:(SP-12),A
				move    X:(SP-13),A0
				cmp     A,B
				ble     _L15
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+38)
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    X:(R1+15),A
				move    X:(R1+14),A0
				jsr     FalEvtqPostEvent
				move    X:(SP-12),B
				move    X:(SP-13),B0
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				nop     
				move    B1,X:(R2+15)
				move    B0,X:(R2+14)
				move    X:(SP),R2
				nop     
				movei   #26,X:(R2+38)
				move    X:(SP-1),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+39)
				bra     _L25
_L15:
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				tst     B
				bne     _L20
				move    X:(SP-12),B
				move    X:(SP-13),B0
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				nop     
				move    B1,X:(R2+15)
				move    B0,X:(R2+14)
				move    X:(SP),R2
				nop     
				movei   #26,X:(R2+38)
				move    X:(SP-1),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+39)
				bra     _L25
_L20:
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				move    X:(SP-12),A
				move    X:(SP-13),A0
				cmp     A,B
				bne     _L22
				movei   #0,X:(SP-13)
				movei   #0,X:(SP-12)
_L22:
				movei   #26,X:(SP-11)
				move    X:(SP-1),R0
				move    R0,X:(SP-10)
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				movec   SP,R3
				lea     (R3-11)
				move    X:(SP-12),A
				move    X:(SP-13),A0
				jsr     FalEvtqPostEvent
_L25:
				lea     (SP-14)
				rts     


				GLOBAL FalSeqpVibOscEvent
				ORG	P:
FalSeqpVibOscEvent:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				moves   R3,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP)
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+4)
				blo     _L10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+63),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+30),R2
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+12)
				movei   #_L5,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L5:
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				moves   X:<mr8,R2
				move    X:(SP),R3
				jsr     FalSeqpSetPitch
				move    X:(SP-1),B
				move    X:(SP-2),B0
				tst     B
				beq     _L11
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+48)
				moves   X:<mr9,R3
				move    X:(SP-1),A
				move    X:(SP-2),A0
				jsr     FalEvtqPostEvent
				move    X:(SP-1),A
				move    X:(SP-2),A0
				bra     _L11
_L10:
				clr     A
_L11:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
Fratestable     DC			0,16,-3184,16,-2661,17,1790,19
				DC			10403,20,23425,21,-24418,22,-1775,23
				DC			26111,25,-5984,26,-32194,28,13368,30
				DC			0,32

				ENDSEC
				END

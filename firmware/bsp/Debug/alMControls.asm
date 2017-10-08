
				SECTION alMControls
				include "asmdef.h"
				GLOBAL FalSeqpControlChange
				ORG	P:
FalSeqpControlChange:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				moves   Y0,X:<mr9
				move    Y1,X:(SP)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+58),R0
				move    R0,X:(SP-1)
				move    X:(SP),X0
				cmp     #64,X0
				jeq     _L44
				bge     _L17
				cmp     #11,X0
				beq     _L30
				bge     _L13
				cmp     #7,X0
				beq     _L30
				bge     _L11
				cmp     #6,X0
				jge     _L59
				jmp     _L74
_L11:
				cmp     #10,X0
				jge     _L36
				jmp     _L74
_L13:
				cmp     #38,X0
				jeq     _L61
				jge     _L74
				cmp     #16,X0
				jeq     _L42
				jmp     _L74
_L17:
				cmp     #99,X0
				jeq     _L66
				bge     _L25
				cmp     #93,X0
				jeq     _L74
				bge     _L23
				cmp     #91,X0
				jeq     _L51
				jmp     _L74
_L23:
				cmp     #98,X0
				jge     _L63
				jmp     _L74
_L25:
				cmp     #123,X0
				jeq     _L53
				jge     _L74
				cmp     #101,X0
				jeq     _L72
				jge     _L74
				jmp     _L69
_L30:
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlVol
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				jeq     _L74
_L32:
				moves   X:<mr8,R2
				move    X:(SP-1),R3
				jsr     FalSeqpVolMix
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				bne     _L32
				jmp     _L74
_L36:
				moves   X:<mr9,Y0
				move    X:(SP-7),Y1
				moves   X:<mr8,R2
				jsr     FalSeqpSetChlPan
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				jeq     _L74
_L38:
				moves   X:<mr8,R2
				move    X:(SP-1),R3
				jsr     FalSeqpPanMix
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				bne     _L38
				jmp     _L74
_L42:
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlPriority
				jmp     _L74
_L44:
				move    X:(SP-7),X0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+56),Y0
				movec   Y0,X:(SP-2)
				movei   #12,Y1
				moves   X:<mr9,Y0
				impy    Y1,Y0,Y0
				movec   X:(SP-2),R0
				lea     (R0+8)
				movec   Y0,N
				move    X0,X:(R0+N)
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				jeq     _L74
_L46:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+14),X0
				cmp     #2,X0
				bne     _L48
				moves   X:<mr8,R2
				move    X:(SP-1),R3
				jsr     FalSeqpVoiceOff
_L48:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				move    X:(SP-1),R2
				moves   X:<mr9,Y0
				jsr     FalSeqpFindVoiceChl
				move    R2,X:(SP-1)
				tstw    R2
				bne     _L46
				jmp     _L74
_L51:
				moves   X:<mr9,Y0
				moves   X:<mr8,R2
				move    X:(SP-7),Y1
				jsr     FalSeqpSetChlFXMix
				jmp     _L74
_L53:
				tstw    X:(SP-1)
				jeq     _L74
_L54:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+14),X0
				cmp     #3,X0
				beq     _L56
				moves   X:<mr8,R2
				move    X:(SP-1),R3
				jsr     FalSeqpVoiceOff
_L56:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				tstw    X:(SP-1)
				bne     _L54
				jmp     _L74
_L59:
				movei   #127,X0
				push    X0
				moves   X:<mr9,Y0
				move    X:(SP-8),Y1
				movei   #7,X0
				lsll    Y1,X0,Y1
				moves   X:<mr8,R2
				jsr     FalContrDataEntryPointer
				pop     
				jmp     _L74
_L61:
				movei   #16256,X0
				push    X0
				moves   X:<mr9,Y0
				move    X:(SP-8),Y1
				moves   X:<mr8,R2
				jsr     FalContrDataEntryPointer
				pop     
				bra     _L74
_L63:
				movei   #16383,X:FrpnNum
				move    X:FnrpnNum,Y0
				andc    #16256,Y0
				move    X:(SP-7),X0
				andc    #127,X0
				add     Y0,X0
				move    X0,X:FnrpnNum
				bra     _L74
_L66:
				movei   #16383,X:FrpnNum
				move    X:FnrpnNum,Y1
				andc    #127,Y1
				move    X:(SP-7),Y0
				andc    #127,Y0
				movei   #7,X0
				lsll    Y0,X0,X0
				add     Y1,X0
				move    X0,X:FnrpnNum
				bra     _L74
_L69:
				movei   #16383,X:FnrpnNum
				move    X:FrpnNum,Y0
				andc    #16256,Y0
				move    X:(SP-7),X0
				andc    #127,X0
				add     Y0,X0
				move    X0,X:FrpnNum
				bra     _L74
_L72:
				movei   #16383,X:FnrpnNum
				move    X:FrpnNum,Y1
				andc    #127,Y1
				move    X:(SP-7),Y0
				andc    #127,Y0
				movei   #7,X0
				lsll    Y0,X0,X0
				add     Y1,X0
				move    X0,X:FrpnNum
_L74:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalContrDataEntryPointer:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				moves   Y1,X:<mr11
				moves   #0,X:<mr8
				movei   #0,X:(SP-2)
				moves   #0,X:<mr10
				moves   X:<mr11,X0
				andc    #127,X0
				move    X0,X:<mr9
				movei   #16383,X0
				cmp     X:FnrpnNum,X0
				jeq     _L58
				move    X:(SP),R2
				nop     
				move    X:(R2+4),R0
				move    X:FinsNum,Y0
				move    X:(R0),X0
				cmp     X0,Y0
				bhs     _L12
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				movec   X0,R0
				lea     (R0+3)
				move    X:FinsNum,R1
				movec   R1,N
				move    X:(R0+N),R1
				move    R1,X:<mr8
				moves   X:<mr8,R2
				move    X:FsndNum,Y0
				move    X:(R2+9),X0
				cmp     X0,Y0
				bhs     _L12
				moves   X:<mr8,X0
				movec   X0,R0
				lea     (R0+10)
				move    X:FsndNum,R1
				movec   R1,N
				move    X:(R0+N),R1
				move    R1,X:(SP-2)
				move    X:(SP-2),R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:<mr10
_L12:
				move    X:FnrpnNum,X0
				cmp     #18,X0
				jgt     _L58
				asl     X0
				add     #_L14,X0
				push    X0
				push    SR
				rti     
				jmp     _L15
				jmp     _L18
				jmp     _L21
				jmp     _L23
				jmp     _L26
				jmp     _L28
				jmp     _L31
				jmp     _L34
				jmp     _L36
				jmp     _L46
				jmp     _L48
				jmp     _L57
				jmp     _L50
				jmp     _L52
				jmp     _L54
				jmp     _L38
				jmp     _L40
				jmp     _L42
				jmp     _L44
_L15:
				movei   #FinsNum,R2
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				move    X:(SP-1),Y0
				move    X:FinsNum,Y1
				move    X:(SP),R2
				jsr     FalSeqpSetChlProgram
				jmp     _L58
_L18:
				movei   #127,X0
				cmp     X:(SP-9),X0
				jeq     _L58
				movei   #258,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,X0
				moves   X:<mr8,R0
				nop     
				move    X0,X:(R0)
				jmp     _L58
_L21:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2)+
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L23:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+8)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				move    X:(SP-1),Y0
				move    X:FinsNum,Y1
				move    X:(SP),R2
				jsr     FalSeqpSetChlProgram
				jmp     _L58
_L26:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L28:
				movei   #FsndNum,R2
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				movei   #0,X:Fdetune
				jmp     _L58
_L31:
				movei   #127,X0
				cmp     X:(SP-9),X0
				jeq     _L58
				movei   #258,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+5)
				jmp     _L58
_L34:
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L36:
				move    X:(SP-2),X0
				movec   X0,R2
				nop     
				lea     (R2+6)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L38:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L40:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L42:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+5)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				jmp     _L58
_L44:
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+6)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				bra     _L58
_L46:
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				bra     _L58
_L48:
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				bra     _L58
_L50:
				moves   X:<mr10,R2
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				bra     _L58
_L52:
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2)+
				moves   X:<mr9,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				bra     _L58
_L54:
				movei   #Fdetune,R2
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
				move    X:Fdetune,X0
				add     #-200,X0
				moves   X:<mr10,R2
				nop     
				move    X0,X:(R2+5)
				bra     _L58
_L57:
				moves   X:<mr10,X0
				movec   X0,R2
				nop     
				lea     (R2+4)
				moves   X:<mr11,Y0
				move    X:(SP-9),Y1
				jsr     FalDataEntry
_L58:
				lea     (SP-3)
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
FalDataEntry:
				moves   Y1,X:<mr2
				tstw    R2
				beq     _L4
				moves   X:<mr2,X0
				move    X:(R2),Y1
				and     Y1,X0
				or      Y0,X0
				move    X0,X:(R2)
_L4:
				rts     


				ORG	X:
Fdetune         BSC			1
FsndNum         BSC			1
FinsNum         BSC			1
FrpnNum         BSC			1
FnrpnNum        BSC			1

				ENDSEC
				END

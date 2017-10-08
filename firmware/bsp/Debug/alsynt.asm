
				SECTION alsynt
				include "asmdef.h"
				GLOBAL FalSynMakeVolumes
				ORG	P:
FalSynMakeVolumes:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R3
				movei   #FvolTable,R2
				movei   #21,X0
				movei   #2,N
				move    X:(R3+17),A
				move    X:(R3+16),A0
				move    X:(R3+19),B
				move    X:(R3+18),B0
				move    X:(R3+21),Y1
				move    X:(R3+20),Y0
				tstw    Y1
				bgt     _L26
				blt     _L19
				do      X0,_L18
				move    A,X:(R2+1)
				move    A0,X:(R2)+N
				nop     
				jmp     _L32
_L19:
				do      X0,_L25
				move    A,X:(R2+1)
				move    A0,X:(R2)+N
				add     Y,A
				cmp     B,A
				tlt     B,A
				jmp     _L32
_L26:
				do      X0,_L32
				move    A,X:(R2+1)
				move    A0,X:(R2)+N
				add     Y,A
				cmp     A,B
				tlt     B,A
_L32:
				movei   #FvolTable+1,R2
				movei   #FpanTable,R1
				move    X:(R3+28),Y1
				move    X:(R3+27),Y0
				movei   #21,X0
				do      X0,_L43
				move    X:(R2)+N,X0
				mpyr    Y0,X0,A
				mpyr    Y1,X0,B
				move    B,X:(R1+1)
				move    A,X:(R1)+N
				lea     (SP)-
				rts     


				ORG	P:
FalSynMixVoice:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				movei   #2,N
				movei   #-1,M01
				move    X:(SP),R3
				move    X:(SP-2),Y0
				move    X:(R3+22),Y1
				movei   #FpanTable,R0
				movei   #FvolTable,R1
				move    X:Fcash_2,R2
				move    X:(SP-1),R3
				tstw    Y1
				beq     _L40
_L13:
				cmp     Y0,Y1
				bgt     _L17
				move    Y1,X0
				bra     _L18
_L17:
				move    Y0,X0
_L18:
				sub     X0,Y1
				sub     X0,Y0
				move    Y1,A1
				move    Y0,A0
				move    X:(R0+1),Y1
				move    X:(R0),Y0
				do      X0,_L36
				move    X:(R2)+,X0
				move    X:(R3+1),B
				move    X:(R3),B0
				mac     Y0,X0,B
				move    B,X:(R3+1)
				move    B0,X:(R3)+N
				move    X:(R3+1),B
				move    X:(R3),B0
				mac     Y1,X0,B
				move    B,X:(R3+1)
				move    B0,X:(R3)+N
				move    A0,Y0
				move    A1,Y1
				tstw    Y1
				bne     _L43
_L40:
				movei   #32,Y1
				lea     (R0)+N
				lea     (R1)+N
_L43:
				tstw    Y0
				bgt     _L13
				move    X:(SP),R3
				move    Y1,X:(R3+22)
				move    X:(R1+1),Y1
				move    X:(R1),Y0
				move    Y1,X:(R3+17)
				move    Y0,X:(R3+16)
				lea     (SP-3)
				rts     


				ORG	P:
FalSynRenderVoice:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    X:(SP),R3
				move    X:(SP-1),X0
				move    X:(R3+14),Y0
				move    X:(R3+15),Y1
				mpysu   X0,Y0,B
				asr     B
				impy    Y1,X0,Y1
				add     Y1,B
				move    X:(R3+6),Y0
				move    X:(R3+4),Y1
				andc    #3,Y1
				move    Y0,X:(SP-3)
				move    Y1,X:(SP-2)
				add     Y,B
				move    B0,X:(R3+6)
				move    B1,Y0
				move    B1,B0
				clr     B1
				move    X:(R3+5),A1
				move    X:(R3+4),A0
				andc    #-4,A0
				add     A,B
				move    B0,X:(R3+4)
				move    B1,X:(R3+5)
				movei   #2,X0
				asrr    Y0,X0,Y0
				inc     Y0
				inc     Y0
				move    X:Fcash_1,R2
				jsr     Fsdram_load_64
				move    X:Fcash_1,Y0
				add     X:(SP-2),Y0
				move    Y0,R2
				move    X:Fcash_2,R1
				move    X:(SP-3),Y1
				move    X:(R3+14),Y0
				move    X:(R3+15),N
				move    X:(SP-1),X0
				do      X0,_L54
				move    X:(R2),X0
				not     Y1
				mpysu   X0,Y1,B
				move    X:(R2+1),X0
				not     Y1
				macsu   X0,Y1,B
				asr     B
				rnd     B
				lea     (R2)+N
				add     Y0,Y1
				bcc     _L53
				lea     (R2)+
_L53:
				move    B,X:(R1)+
				lea     (SP-4)
				rts     


				ORG	P:
FalSynMix32To16:
				movei   #2,N
				do      Y0,_L11
				move    X:(R3+1),A
				move    X:(R3)+N,A0
				rnd     A
				move    A,X:(R2)+
				move    X:(R3+1),A
				move    X:(R3)+N,A0
				rnd     A
				move    A,X:(R2)+
				rts     


				ORG	P:
FalSynAddChannel:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr9
				tstw    X:<mr9
				jeq     _L29
_L3:
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    X:(R0+9),A
				move    X:(R0+8),A0
				cmp     A,B
				bne     _L5
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+6)
				bne     _L6
_L5:
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    X:(R0+9),A
				move    X:(R0+8),A0
				cmp     A,B
				bls     _L11
_L6:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+4),X0
				andc    #1,X0
				tstw    X0
				beq     _L9
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R0+11),B
				move    X:(R0+10),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				sub     B,A
				move    A1,X:(R2+5)
				move    A0,X:(R2+4)
				bra     _L11
_L9:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R3
				move    X:(SP),R2
				jsr     FalSynStopVoice
				jmp     _L29
_L11:
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R0+5),B
				move    X:(R0+4),B0
				move    X:(R2+9),A
				move    X:(R2+8),A0
				sub     B,A
				move    A0,A
				move    X:(SP-1),R2
				clr     B
				move    X:(R2+6),B0
				sub     B,A
				move    X:(SP-1),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				push    B0
				push    B1
				jsr     ARTDIVU32UZ
				pop     
				pop     
				movei   #0,B
				movei   #1,B0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				clr     B
				moves   X:<mr9,X0
				move    X0,B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				cmp     B,A
				bhs     _L14
				move    X:(SP-2),B
				move    X:(SP-3),B0
				bra     _L15
_L14:
				clr     A
				moves   X:<mr9,X0
				move    X0,A0
				tfr     A,B
_L15:
				movec   B0,X0
				move    X0,X:<mr8
				tstw    X:<mr8
				bne     _L19
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R3
				move    X:(SP),R2
				jsr     FalSynStopVoice
				bra     _L29
_L19:
				move    X:(SP-1),R2
				moves   X:<mr8,Y0
				jsr     FalSynRenderVoice
				move    X:(SP-1),R2
				jsr     FalSynMakeVolumes
				move    X:(SP-1),R2
				move    X:(SP-8),R3
				moves   X:<mr8,Y0
				jsr     FalSynMixVoice
				move    X:(SP-1),R2
				nop     
				move    X:(R2+21),B
				move    X:(R2+20),B0
				tst     B
				beq     _L26
				move    X:(SP-1),R2
				move    X:(SP-1),R0
				move    X:(R2+19),B
				move    X:(R2+18),B0
				move    X:(R0+17),A
				move    X:(R0+16),A0
				cmp     A,B
				bne     _L26
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+20)
				movei   #0,X:(R2+21)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+4),X0
				orc     #128,X0
				move    X0,X:(R0+4)
_L26:
				moves   X:<mr9,X0
				sub     X:<mr8,X0
				move    X0,X:<mr9
				moves   X:<mr8,X0
				lsl     X0
				lsl     X0
				add     X:(SP-8),X0
				move    X0,X:(SP-8)
				tstw    X:<mr9
				jne     _L3
_L29:
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalAudioFrame
				ORG	P:
FalAudioFrame:
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
				moves   R2,X:<mr9
				move    R3,X:(SP)
				move    Y0,X:(SP-1)
				moves   #0,X:<mr11
				tstw    X:(SP-1)
				jeq     _L37
_L4:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				tst     B
				jne     _L11
				moves   X:<mr9,R2
				nop     
				tstw    X:(R2+7)
				beq     _L10
				moves   X:<mr9,R2
				nop     
				move    X:(R2+7),R0
				moves   X:<mr9,R2
				nop     
				move    X:(R2+6),R2
				movei   #_L7,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L7:
				moves   X:<mr9,R2
				nop     
				move    A1,X:(R2+9)
				move    A0,X:(R2+8)
				movei   #0,B
				movei   #100,B0
				push    B0
				push    B1
				moves   X:<mr9,R2
				nop     
				move    X:(R2+9),A
				move    X:(R2+8),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				movei   #0,B
				movei   #3125,B0
				push    B0
				push    B1
				jsr     ARTDIVS32UZ
				pop     
				pop     
				moves   X:<mr9,R2
				nop     
				move    A1,X:(R2+11)
				move    A0,X:(R2+10)
				bra     _L11
_L10:
				clr     B
				move    X:(SP-1),B0
				moves   X:<mr9,R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
_L11:
				moves   X:<mr9,R2
				clr     B
				move    X:(SP-1),B0
				move    X:(R2+11),A
				move    X:(R2+10),A0
				cmp     B,A
				bhs     _L13
				moves   X:<mr9,R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				bra     _L14
_L13:
				clr     A
				move    X:(SP-1),A0
				tfr     A,B
_L14:
				movec   B0,X0
				move    X0,X:(SP-3)
				move    X:(SP),R0
				move    R0,X:(SP-2)
				moves   X:<mr9,R2
				clr     B
				move    X:(SP-3),B0
				move    X:(R2+11),A
				move    X:(R2+10),A0
				sub     B,A
				move    A1,X:(R2+11)
				move    A0,X:(R2+10)
				move    X:(SP-1),X0
				sub     X:(SP-3),X0
				move    X0,X:(SP-1)
				move    X:(SP-3),Y1
				lsl     Y1
				move    X:(SP),X0
				add     X0,Y1
				move    Y1,X:(SP)
				jmp     _L35
_L20:
				movei   #640,X0
				cmp     X:(SP-3),X0
				bls     _L22
				move    X:(SP-3),X0
				bra     _L23
_L22:
				movei   #640,X0
_L23:
				move    X0,X:<mr11
				moves   X:<mr9,R2
				nop     
				move    X:(R2+18),R2
				moves   X:<mr11,Y1
				lsl     Y1
				lsl     Y1
				movei   #0,Y0
				jsr     FmemMemset
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:<mr8
				tstw    X:<mr8
				beq     _L32
_L27:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+4),X0
				bftstl  #16,X0
				blo     _L30
				moves   X:<mr9,R2
				nop     
				move    X:(R2+18),R0
				push    R0
				moves   X:<mr11,Y0
				moves   X:<mr9,R2
				moves   X:<mr8,R3
				jsr     FalSynAddChannel
				pop     
_L30:
				moves   X:<mr10,R0
				move    R0,X:<mr8
				tstw    X:<mr8
				bne     _L27
_L32:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+18),R3
				moves   X:<mr11,Y0
				move    X:(SP-2),R2
				jsr     FalSynMix32To16
				moves   X:<mr11,X0
				lsl     X0
				add     X:(SP-2),X0
				move    X0,X:(SP-2)
				move    X:(SP-3),X0
				sub     X:<mr11,X0
				move    X0,X:(SP-3)
_L35:
				tstw    X:(SP-3)
				jne     _L20
				tstw    X:(SP-1)
				jne     _L4
_L37:
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


				GLOBAL FalSynUpdate
				ORG	P:
FalSynUpdate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				jsr     FfcodecWaitBuf
				move    R2,X:(SP-1)
				move    X:(SP-1),R3
				move    X:(SP),R2
				movei   #640,Y0
				jsr     FalAudioFrame
				move    X:(SP),R2
				jsr     FalSynPanSlide
				move    X:(SP),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				tst     B
				beq     _L11
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+14)
				movei   #0,A
				movei   #20000,A0
				jsr     FalMicroTimeSub
				move    X:(SP),R2
				nop     
				move    X:(R2+15),B
				move    X:(R2+14),B0
				tst     B
				bne     _L11
				move    X:(SP),R2
				nop     
				move    X:(R2+12),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+6),R2
				movei   #_L10,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L10:
				move    X:(SP),R2
				nop     
				move    A1,X:(R2+15)
				move    A0,X:(R2+14)
_L11:
				lea     (SP-4)
				rts     


				GLOBAL FalSynNew
				ORG	P:
FalSynNew:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				jsr     FfcodecOpen
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+16)
				move    X:(SP),R2
				nop     
				move    X:(R2+16),Y0
				movei   #29,Y1
				jsr     FmemCallocIM
				move    X:(SP),R0
				move    R2,X:(R0+17)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+17)
				jeq     _L25
				move    X:(SP),R2
				nop     
				move    X:(R2+17),R2
				move    X:(SP),R0
				movei   #7,Y0
				move    X:(R0+16),X0
				impy    Y0,X0,Y1
				movei   #0,Y0
				jsr     FmemMemset
				moves   #0,X:<mr8
				movei   #29,Y0
				moves   X:<mr8,X0
				impy    Y0,X0,X0
				move    X0,X:<mr9
				bra     _L13
_L10:
				move    X:(SP),R2
				moves   X:<mr9,Y0
				move    X:(R2+17),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP),R3
				jsr     FalLink
				moves   X:<mr9,X0
				add     #29,X0
				move    X0,X:<mr9
				inc     X:<mr8
_L13:
				move    X:(SP),R2
				moves   X:<mr8,Y0
				move    X:(R2+16),X0
				cmp     X0,Y0
				blo     _L10
				movei   #1280,Y0
				jsr     FmemMallocEM
				move    R2,X:Fcash_1
				tstw    X:Fcash_1
				beq     _L25
				movei   #640,Y0
				jsr     FmemMallocEM
				move    R2,X:Fcash_2
				tstw    X:Fcash_2
				beq     _L25
				movei   #2560,Y0
				jsr     FmemMallocEM
				move    X:(SP),R0
				move    R2,X:(R0+18)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+18)
				beq     _L25
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+14)
				movei   #0,X:(R2+15)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+10)
				movei   #0,X:(R2+11)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+7)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+12)
				movei   #1,Y0
				bra     _L27
_L25:
				move    X:(SP),R2
				jsr     FalSynDelete
				movei   #0,Y0
_L27:
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynDelete
				ORG	P:
FalSynDelete:
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+17)
				beq     _L4
				move    X:(SP),R2
				nop     
				move    X:(R2+17),R2
				jsr     FmemFreeEM
_L4:
				tstw    X:Fcash_1
				beq     _L6
				move    X:Fcash_1,R2
				jsr     FmemFreeEM
_L6:
				tstw    X:Fcash_2
				beq     _L8
				move    X:Fcash_2,R2
				jsr     FmemFreeEM
_L8:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+18)
				beq     _L10
				move    X:(SP),R2
				nop     
				move    X:(R2+18),R2
				jsr     FmemFreeEM
_L10:
				lea     (SP)-
				rts     


				GLOBAL FalSynAddPlayer
				ORG	P:
FalSynAddPlayer:
				move    R3,X:(R2+6)
				rts     


				GLOBAL FalSynSetVol
				ORG	P:
FalSynSetVol:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R3,X:<mr8
				moves   Y0,X:<mr9
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-2)
				move    X:<mr9,B
				movec   B1,B0
				move    B0,B
				move    X:(SP-2),R2
				nop     
				move    B1,X:(R2+19)
				move    B0,X:(R2+18)
				move    X:(SP-2),R2
				nop     
				andc    #32767,X:(R2+17)
				andc    #0,X:(R2+16)
				move    X:(SP-2),R2
				nop     
				movei   #32,X:(R2+22)
				tstw    X:<mr9
				bne     _L9
				moves   X:<mr8,R2
				nop     
				orc     #64,X:(R2+4)
				bra     _L10
_L9:
				moves   X:<mr8,R2
				nop     
				andc    #-65,X:(R2+4)
_L10:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,A
				movei   #1000,A0
				cmp     A,B
				bge     _L15
				move    X:(SP-2),R2
				nop     
				movei   #0,X:(R2+20)
				movei   #0,X:(R2+21)
				move    X:(SP-2),R2
				nop     
				move    X:(R2+19),B
				move    X:(R2+18),B0
				move    X:(SP-2),R2
				nop     
				move    B1,X:(R2+17)
				move    B0,X:(R2+16)
				moves   X:<mr8,R2
				nop     
				orc     #128,X:(R2+4)
				bra     _L17
_L15:
				movei   #0,B
				movei   #1000,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-2),R2
				move    X:(SP-2),R0
				move    X:(R0+17),B
				move    X:(R0+16),B0
				movec   B1,Y1
				movec   B0,Y0
				move    X:(R2+19),B
				move    X:(R2+18),B0
				sub     Y,B
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-2),R2
				nop     
				move    A1,X:(R2+21)
				move    A0,X:(R2+20)
				moves   X:<mr8,R2
				nop     
				andc    #-129,X:(R2+4)
_L17:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSynPanSlide:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				jeq     _L18
_L4:
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+4),X0
				bftstl  #16,X0
				blo     _L16
				move    X:(SP),R2
				nop     
				tstw    X:(R2+25)
				beq     _L16
				move    X:(SP),R2
				move    X:(SP),R0
				move    X:(R0+25),Y0
				move    X:(R2+23),X0
				add     X0,Y0
				move    Y0,X:(R2+23)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+25)
				ble     _L12
				move    X:(SP),R2
				move    X:(SP),R0
				move    X:(R2+23),Y0
				move    X:(R0+24),X0
				cmp     X0,Y0
				blo     _L15
				move    X:(SP),R2
				nop     
				move    X:(R2+24),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+23)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+25)
				bra     _L15
_L12:
				move    X:(SP),R2
				move    X:(SP),R0
				move    X:(R2+23),Y0
				move    X:(R0+24),X0
				cmp     X0,Y0
				bgt     _L15
				move    X:(SP),R2
				nop     
				move    X:(R2+24),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+23)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+25)
_L15:
				move    X:(SP),R2
				jsr     FalSynMixPanGain
_L16:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				tstw    X:(SP)
				jne     _L4
_L18:
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FalSynMixPanGain:
				move    X:(R2+23),Y0
				movei   #8,X0
				asrr    Y0,X0,X0
				move    X0,X:<mr3
				movei   #128,X0
				sub     X:<mr3,X0
				move    X0,X:<mr2
				movei   #127,X0
				cmp     X:<mr2,X0
				bge     _L5
				moves   #127,X:<mr2
_L5:
				movei   #258,Y0
				moves   X:<mr3,X0
				impy    Y0,X0,X0
				move    X0,X:<mr3
				movei   #258,Y0
				moves   X:<mr2,X0
				impy    Y0,X0,X0
				move    X0,X:<mr2
				moves   X:<mr3,Y0
				move    X:(R2+26),X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:(R2+28)
				moves   X:<mr2,Y0
				move    X:(R2+26),X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:(R2+27)
				rts     


				GLOBAL FalSynSetPan
				ORG	P:
FalSynSetPan:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R3,X:<mr9
				moves   Y0,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-2)
				moves   X:<mr8,Y0
				movei   #8,X0
				asll    Y0,X0,X0
				move    X0,X:<mr8
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+24)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,A
				movei   #20000,A0
				cmp     A,B
				bge     _L9
				move    X:(SP-2),R2
				nop     
				movei   #0,X:(R2+25)
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+23)
				bra     _L10
_L9:
				movei   #0,B
				movei   #20000,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-2),R2
				nop     
				move    X:(R2+23),Y0
				moves   X:<mr8,X0
				sub     Y0,X0
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				movec   A0,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+25)
_L10:
				move    X:(SP-2),R2
				jsr     FalSynMixPanGain
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynSetGain
				ORG	P:
FalSynSetGain:
				movei   #2,N
				lea     (SP)+N
				move    R3,X:(SP)
				move    Y0,X:(SP-1)
				move    X:(SP-1),X0
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    X0,X:(R0+26)
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R2
				jsr     FalSynMixPanGain
				lea     (SP-2)
				rts     


				GLOBAL FalSynSetPitch
				ORG	P:
FalSynSetPitch:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movec   R3,R2
				nop     
				move    X:(R2+6),X0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
				neg     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #2,A
				cmp     A,B
				ble     _L6
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				movei   #2,B
				move    B1,X:(R0+15)
				move    B0,X:(R0+14)
				bra     _L10
_L6:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bne     _L9
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				movei   #0,B
				movei   #1,B0
				move    B1,X:(R0+15)
				move    B0,X:(R0+14)
				bra     _L10
_L9:
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    B1,X:(R0+15)
				move    B0,X:(R0+14)
_L10:
				lea     (SP-2)
				rts     


				GLOBAL FalSynSetFXMix
				ORG	P:
FalSynSetFXMix:
				rts     


				GLOBAL FalSynSetPriority
				ORG	P:
FalSynSetPriority:
				movec   R3,R2
				nop     
				move    Y0,X:(R2+5)
				rts     


				GLOBAL FalSynGetPriority
				ORG	P:
FalSynGetPriority:
				movec   R3,R2
				nop     
				move    X:(R2+5),Y0
				rts     


				GLOBAL FalSynStartVoice
				ORG	P:
FalSynStartVoice:
				move    X:(R3+2),R2
				move    X:(SP-2),R0
				move    R0,X:(R3+3)
				move    X:(SP-2),R0
				move    X:(R0+7),Y0
				andc    #1,Y0
				move    X:(R3+4),X0
				or      X0,Y0
				move    Y0,X:(R3+4)
				move    X:(R3+4),X0
				orc     #16,X0
				move    X0,X:(R3+4)
				move    X:(SP-2),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(R3+4),X0
				andc    #1,X0
				tstw    X0
				beq     _L11
				move    X:(SP-2),R0
				move    X:(SP-2),R1
				move    X:(R1+1),B
				move    X:(R1),B0
				move    X:(R0+11),A
				move    X:(R0+10),A0
				add     A,B
				move    B1,X:(R2+9)
				move    B0,X:(R2+8)
				move    X:(SP-2),R0
				move    X:(SP-2),R1
				move    X:(R1+9),B
				move    X:(R1+8),B0
				move    X:(R0+11),A
				move    X:(R0+10),A0
				sub     B,A
				movei   #0,B
				movei   #1,B0
				add     A,B
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
				move    X:(SP-2),R0
				move    X:(R0+13),B
				move    X:(R0+12),B0
				move    B1,X:(R2+13)
				move    B0,X:(R2+12)
				bra     _L12
_L11:
				move    X:(SP-2),R0
				move    X:(R0+3),B
				move    X:(R0+2),B0
				move    X:(SP-2),R0
				move    X:(R0+1),A
				move    X:(R0),A0
				add     A,B
				movei   #-1,A
				movei   #-2,A0
				add     B,A
				move    A1,X:(R2+9)
				move    A0,X:(R2+8)
_L12:
				rts     


				GLOBAL FalSynStartVoiceParams
				ORG	P:
FalSynStartVoiceParams:
				movei   #6,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    Y0,X:(SP-4)
				move    Y1,X:(SP-5)
				move    X:(SP-8),R0
				push    R0
				move    X:(SP-1),R2
				move    X:(SP-2),R3
				jsr     FalSynStartVoice
				pop     
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-9),Y0
				jsr     FalSynSetFXMix
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FalSynSetPitch
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-5),Y0
				move    X:(SP-10),A
				move    X:(SP-11),A0
				jsr     FalSynSetPan
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-4),Y0
				move    X:(SP-10),A
				move    X:(SP-11),A0
				jsr     FalSynSetVol
				lea     (SP-6)
				rts     


				GLOBAL FalSynStopVoice
				ORG	P:
FalSynStopVoice:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				andc    #-17,X:(R2+4)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R2
				jsr     FalUnlink
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R2
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+4)
				jsr     FalLink
				lea     (SP-2)
				rts     


				GLOBAL FalSynAllocVoice
				ORG	P:
FalSynAllocVoice:
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
				moves   R2,X:<mr9
				moves   R3,X:<mr11
				moves   Y0,X:<mr10
				movei   #65535,X:(SP-2)
				movei   #32767,X0
				move    X0,X:(SP-1)
				moves   #0,X:<mr8
				moves   X:<mr9,R0
				nop     
				tstw    X:(R0)
				beq     _L9
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr8
				moves   X:<mr8,R2
				jsr     FalUnlink
				moves   X:<mr9,X0
				movec   X0,R3
				lea     (R3+2)
				moves   X:<mr8,R2
				jsr     FalLink
				jmp     _L27
_L9:
				moves   X:<mr9,R2
				nop     
				tstw    X:(R2+4)
				beq     _L14
				moves   X:<mr9,R2
				nop     
				move    X:(R2+4),R0
				move    R0,X:<mr8
				moves   X:<mr8,R2
				jsr     FalUnlink
				moves   X:<mr9,X0
				movec   X0,R3
				lea     (R3+2)
				moves   X:<mr8,R2
				jsr     FalLink
				bra     _L27
_L14:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				beq     _L22
_L16:
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+5),X0
				cmp     X:<mr10,X0
				bhi     _L20
				move    X:(SP),R2
				nop     
				move    X:(R2+17),B
				move    X:(R2+16),B0
				move    X:(SP-1),A
				move    X:(SP-2),A0
				cmp     A,B
				bge     _L20
				move    X:(SP),R2
				nop     
				move    X:(R2+17),B
				move    X:(R2+16),B0
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP),R0
				move    R0,X:<mr8
_L20:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				tstw    X:(SP)
				bne     _L16
_L22:
				tstw    X:<mr8
				beq     _L26
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+4),X0
				andc    #-49,X0
				move    X0,X:(R0+4)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				movei   #0,X0
				move    X0,X:(R0+2)
				bra     _L27
_L26:
				movei   #0,Y0
				bra     _L32
_L27:
				moves   X:<mr8,R0
				moves   X:<mr11,R2
				nop     
				move    R0,X:(R2+2)
				moves   X:<mr10,X0
				moves   X:<mr11,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr11,R0
				moves   X:<mr11,R2
				nop     
				move    X:(R2+2),R1
				move    R0,X:(R1+2)
				moves   X:<mr11,R2
				nop     
				movei   #32,X:(R2+4)
				movei   #1,Y0
_L32:
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


				GLOBAL FalSynFreeVoice
				ORG	P:
FalSynFreeVoice:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R2
				jsr     FalUnlink
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R2
				move    X:(SP),R3
				jsr     FalLink
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+2)
				move    X:(SP-1),R2
				nop     
				andc    #-49,X:(R2+4)
				lea     (SP-2)
				rts     


				ORG	X:
Fcash_2         BSC			1
Fcash_1         BSC			1
FpanTable       BSC			42
FvolTable       BSC			42

				ENDSEC
				END

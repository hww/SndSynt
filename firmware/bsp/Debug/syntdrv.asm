
				SECTION syntdrv
				include "asmdef.h"
				ORG	P:
FalSynMixVolume:
				move    X:(R3+20),Y0
				move    X:(R3+19),X0
				mpyr    Y0,X0,B
				move    X:(R3+24),Y0
				movei   #64,Y1
				cmp     Y0,Y1
				beq     _L10
				movei   #127,Y1
				sub     Y0,Y1
_L10:
				movei   #16,X0
				impy    Y0,X0,Y0
				impy    Y1,X0,Y1
				move    B1,X0
				mpyr    Y0,X0,A
				move    A,X:(R3+14)
				mpyr    Y1,X0,A
				move    A,X:(R3+15)
				move    X:(R3+25),Y0
				movei   #127,Y1
				sub     Y0,Y1
				movei   #258,X0
				impy    Y0,X0,Y0
				impy    Y1,X0,Y1
				move    X:(R3+14),X0
				mpyr    Y0,X0,A
				move    A,X:(R3+16)
				mpyr    Y1,X0,A
				move    A,X:(R3+14)
				move    X:(R3+15),X0
				mpyr    Y0,X0,A
				move    A,X:(R3+17)
				mpyr    Y1,X0,A
				move    A,X:(R3+15)
				rts     


				ORG	P:
FalMixLeft:
				movei   #4,N
				do      X0,_L9
				move    X:(R2)+,X0
				move    X:(R1+1),B
				move    X:(R1),B0
				mac     Y0,X0,B
				move    B,X:(R1+1)
				move    B0,X:(R1)+N
				rts     


				ORG	P:
FalMixRight:
				movei   #2,N
				lea     (R1)+N
				movei   #4,N
				do      X0,_L11
				move    X:(R2)+,X0
				move    X:(R1+1),B
				move    X:(R1),B0
				mac     Y1,X0,B
				move    B,X:(R1+1)
				move    B0,X:(R1)+N
				rts     


				ORG	P:
FalMixStereo:
				cmp     #0,Y0
				bne     _L7
				cmp     #0,Y1
				beq     _L24
				jsr     FalMixRight
				bra     _L24
_L7:
				cmp     #0,Y1
				bne     _L11
				jsr     FalMixLeft
				bra     _L24
_L11:
				movei   #2,N
				do      X0,_L24
				move    X:(R2)+,X0
				move    X:(R1+1),B
				move    X:(R1),B0
				mac     Y0,X0,B
				move    B,X:(R1+1)
				move    B0,X:(R1)+N
				move    X:(R1+1),B
				move    X:(R1),B0
				mac     Y1,X0,B
				move    B,X:(R1+1)
				move    B0,X:(R1)+N
_L24:
				rts     


				ORG	P:
FalSynMixChanel:
				movei   #5,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				move    X:(SP),R0
				move    X:(SP-1),R3
				move    X:(SP-2),X0
				move    X:(R3+12),Y0
				move    X:(R3+13),Y1
				mpysu   X0,Y0,B
				asr     B
				impy    Y1,X0,Y1
				add     Y1,B
				move    X:(R3+6),Y0
				move    X:(R3+4),Y1
				andc    #3,Y1
				move    Y0,X:(SP-4)
				move    Y1,X:(SP-3)
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
				move    X:(R0+13),R2
				jsr     Fsdram_load_64
				move    X:(SP-3),Y0
				move    X:(R0+13),Y1
				add     Y1,Y0
				move    Y0,R2
				move    X:(R0+14),R1
				move    X:(SP-4),Y1
				move    X:(R3+12),Y0
				move    X:(R3+13),N
				move    X:(SP-2),X0
				do      X0,_L55
				move    X:(R2),X0
				not     Y1
				mpysu   X0,Y1,B
				move    X:(R2+1),X0
				not     Y1
				macsu   X0,Y1,B
				rnd     B
				lea     (R2)+N
				add     Y0,Y1
				bcc     _L54
				lea     (R2)+
_L54:
				move    B,X:(R1)+
				move    X:(R3+25),X0
				cmp     #0,X0
				beq     _L84
				cmp     #127,X0
				beq     _L75
				move    X:(R0+14),R2
				move    X:(SP-7),R1
				move    X:(R3+15),Y0
				move    X:(R3+14),Y1
				move    X:(SP-2),X0
				jsr     FalMixStereo
				move    X:(R0+14),R2
				move    X:(SP-7),R1
				movei   #1280,N
				nop     
				lea     (R1)+N
				move    X:(R3+17),Y0
				move    X:(R3+16),Y1
				move    X:(SP-2),X0
				jsr     FalMixStereo
				bra     _L90
_L75:
				move    X:(R0+14),R2
				move    X:(SP-7),R1
				movei   #1280,N
				nop     
				lea     (R1)+N
				move    X:(R3+17),Y0
				move    X:(R3+16),Y1
				move    X:(SP-2),X0
				jsr     FalMixStereo
				bra     _L90
_L84:
				move    X:(R0+14),R2
				move    X:(SP-7),R1
				move    X:(R3+15),Y0
				move    X:(R3+14),Y1
				move    X:(SP-2),X0
				jsr     FalMixStereo
_L90:
				lea     (SP-5)
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
FalSynMix32To16FX:
				move    R2,R0
				movei   #16383,M01
				movei   #2,N
				do      Y0,_L13
				move    X:(R3+1),A
				move    X:(R3)+N,A0
				rnd     A
				movem   A,P:(R0)+
				move    X:(R3+1),A
				move    X:(R3)+N,A0
				rnd     A
				movem   A,P:(R0)+
				move    R0,Y0
				rts     


				ORG	P:
FalSynMix16To32FX:
				move    R3,R0
				movei   #16383,M01
				movei   #2,N
				do      Y1,_L17
				movem   P:(R0)+,X0
				move    X:(R2+1),A
				move    X:(R2),A0
				mac     Y0,X0,A
				move    A,X:(R2+1)
				move    A0,X:(R2)+N
				movem   P:(R0)+,X0
				move    X:(R2+1),A
				move    X:(R2),A0
				mac     Y0,X0,A
				move    A,X:(R2+1)
				move    A0,X:(R2)+N
				move    R0,Y0
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
				jeq     _L25
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
				move    X:(R2+3),X0
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
				movei   #0,X:(R2+3)
				jmp     _L25
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
				move    X:(R2+13),B
				move    X:(R2+12),B0
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
				bne     _L21
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+3)
				move    X:(SP-1),R2
				jsr     FalUnlink
				move    X:(SP),X0
				movec   X0,R3
				lea     (R3+4)
				move    X:(SP-1),R2
				jsr     FalLink
				bra     _L25
_L21:
				move    X:(SP-8),R0
				push    R0
				move    X:(SP-1),R2
				move    X:(SP-2),R3
				moves   X:<mr8,Y0
				jsr     FalSynMixChanel
				pop     
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
_L25:
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
				movei   #8,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    R3,X:(SP)
				move    Y0,X:(SP-1)
				movei   #0,X:(SP-6)
				jmp     _L55
_L4:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				bge     _L6
				debug   
_L6:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				tst     B
				jne     _L13
				moves   X:<mr9,R2
				nop     
				tstw    X:(R2+7)
				beq     _L12
				moves   X:<mr9,R2
				nop     
				move    X:(R2+7),R0
				moves   X:<mr9,R2
				nop     
				move    X:(R2+6),R2
				movei   #_L9,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L9:
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
				bra     _L13
_L12:
				clr     B
				move    X:(SP-1),B0
				moves   X:<mr9,R2
				nop     
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
_L13:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+9),B
				move    X:(R2+8),B0
				tst     B
				bge     _L15
				debug   
_L15:
				moves   X:<mr9,R2
				clr     B
				move    X:(SP-1),B0
				move    X:(R2+11),A
				move    X:(R2+10),A0
				cmp     B,A
				bhs     _L18
				moves   X:<mr9,R2
				nop     
				move    X:(R2+11),B
				move    X:(R2+10),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
				bra     _L19
_L18:
				clr     B
				move    X:(SP-1),B0
				move    B1,X:(SP-3)
				move    B0,X:(SP-4)
_L19:
				move    X:(SP-3),B
				move    X:(SP-4),B0
				movec   B0,X0
				move    X0,X:(SP-7)
				move    X:(SP),R0
				move    R0,X:(SP-5)
				moves   X:<mr9,R2
				clr     B
				move    X:(SP-7),B0
				move    X:(R2+11),A
				move    X:(R2+10),A0
				sub     B,A
				move    A1,X:(R2+11)
				move    A0,X:(R2+10)
				move    X:(SP-1),X0
				sub     X:(SP-7),X0
				move    X0,X:(SP-1)
				move    X:(SP-7),Y1
				lsl     Y1
				move    X:(SP),X0
				add     X0,Y1
				move    Y1,X:(SP)
				jmp     _L54
_L25:
				movei   #320,X0
				cmp     X:(SP-7),X0
				bls     _L28
				move    X:(SP-7),X0
				move    X0,X:(SP-2)
				bra     _L29
_L28:
				movei   #320,X:(SP-2)
_L29:
				move    X:(SP-2),X0
				move    X0,X:(SP-6)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+15),R2
				move    X:(SP-6),Y1
				lsl     Y1
				lsl     Y1
				movei   #0,Y0
				jsr     FmemMemset
				moves   X:<mr9,R2
				nop     
				move    X:(R2+16),R2
				move    X:(SP-6),Y1
				lsl     Y1
				lsl     Y1
				movei   #0,Y0
				jsr     FmemMemset
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:<mr10
				bra     _L38
_L34:
				moves   X:<mr10,R2
				nop     
				bftstl  #16,X:(R2+3)
				blo     _L37
				moves   X:<mr9,R2
				moves   X:<mr10,R3
				jsr     FalSynMixVolume
				moves   X:<mr9,R2
				nop     
				move    X:(R2+15),R0
				push    R0
				move    X:(SP-7),Y0
				moves   X:<mr9,R2
				moves   X:<mr10,R3
				jsr     FalSynAddChannel
				pop     
_L37:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),R1
				move    R1,X:<mr10
_L38:
				tstw    X:<mr10
				bne     _L34
				moves   X:<mr9,R2
				nop     
				tstw    X:(R2+17)
				beq     _L51
				moves   #0,X:<mr11
				bra     _L49
_L42:
				moves   X:<mr9,R2
				moves   X:<mr9,X0
				movec   X0,R0
				lea     (R0+19)
				moves   X:<mr11,N
				move    X:(R0+N),Y0
				move    X:(R2+18),X0
				add     X0,Y0
				move    Y0,X:<mr8
				bra     _L45
_L44:
				moves   X:<mr8,X0
				add     #-16384,X0
				move    X0,X:<mr8
_L45:
				movei   #49152,X0
				cmp     X:<mr8,X0
				bhi     _L44
				moves   X:<mr9,R2
				nop     
				move    X:(R2+16),R2
				moves   X:<mr8,R3
				moves   X:<mr9,X0
				movec   X0,R0
				lea     (R0+23)
				moves   X:<mr11,N
				move    X:(R0+N),Y0
				move    X:(SP-6),Y1
				jsr     FalSynMix16To32FX
				moves   X:<mr9,R2
				nop     
				move    X:(R2+15),R2
				moves   X:<mr8,R3
				move    X:(SP-6),Y1
				movei   #32767,Y0
				jsr     FalSynMix16To32FX
				inc     X:<mr11
_L49:
				moves   X:<mr9,R2
				moves   X:<mr11,Y0
				move    X:(R2+17),X0
				cmp     X0,Y0
				blo     _L42
				moves   X:<mr9,R2
				nop     
				move    X:(R2+18),R2
				moves   X:<mr9,R0
				move    X:(R0+16),R3
				move    X:(SP-6),Y0
				jsr     FalSynMix32To16FX
				moves   X:<mr9,R2
				nop     
				move    Y0,X:(R2+18)
_L51:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+15),R3
				move    X:(SP-6),Y0
				move    X:(SP-5),R2
				jsr     FalSynMix32To16
				move    X:(SP-6),X0
				lsl     X0
				add     X:(SP-5),X0
				move    X0,X:(SP-5)
				move    X:(SP-7),X0
				sub     X:(SP-6),X0
				move    X0,X:(SP-7)
_L54:
				tstw    X:(SP-7)
				jne     _L25
_L55:
				tstw    X:(SP-1)
				jne     _L4
				lea     (SP-8)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynVolumeSlide
				ORG	P:
FalSynVolumeSlide:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr8
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP)
				tstw    X:(SP)
				jeq     _L20
_L4:
				move    X:(SP),R2
				nop     
				move    X:(R2+23),B
				move    X:(R2+22),B0
				tst     B
				jeq     _L18
				move    X:(SP),R2
				nop     
				bftstl  #16,X:(R2+3)
				jlo     _L18
				move    X:(SP),R2
				nop     
				move    X:(R2+20),B
				movec   B1,B0
				move    B0,B
				move    X:(SP),R2
				clr     A
				move    X:(R2+18),A0
				add     B,A
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				move    X:(SP),R2
				nop     
				move    X:(R2+23),B
				move    X:(R2+22),B0
				move    X:(SP-1),A
				move    X:(SP-2),A0
				add     A,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				move    B1,B0
				movec   B0,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+20)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				movec   B0,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+18)
				move    X:(SP),R2
				nop     
				move    X:(R2+23),B
				move    X:(R2+22),B0
				tst     B
				ble     _L15
				move    X:(SP),R2
				move    X:(SP),R0
				move    X:(R2+20),Y0
				move    X:(R0+21),X0
				cmp     X0,Y0
				blo     _L18
				move    X:(SP),R2
				nop     
				move    X:(R2+21),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+20)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+22)
				movei   #0,X:(R2+23)
				bra     _L18
_L15:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+20)
				bgt     _L18
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+20)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+22)
				movei   #0,X:(R2+23)
_L18:
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP)
				tstw    X:(SP)
				jne     _L4
_L20:
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynUpdate
				ORG	P:
FalSynUpdate:
				move    X:<mr8,N
				push    N
				movei   #11,N
				lea     (SP)+N
				moves   R2,X:<mr8
				movei   #0,X:(SP-2)
				movei   #0,X0
				move    X0,X:(SP-1)
				jsr     FfcodecWaitBuf
				move    R2,X:(SP)
				movec   SP,R2
				lea     (R2-10)
				movei   #0,Y0
				jsr     Fclock_gettime
				moves   X:<mr8,R2
				jsr     FalSynVolumeSlide
				move    X:(SP),R3
				moves   X:<mr8,R2
				movei   #640,Y0
				jsr     FalAudioFrame
				movec   SP,R2
				lea     (R2-6)
				movei   #0,Y0
				jsr     Fclock_gettime
				move    X:(SP-7),B
				move    X:(SP-8),B0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				sub     B,A
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				nop     
				lea     (SP-11)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynNew
				ORG	P:
FalSynNew:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   R3,X:<mr10
				jsr     FfcodecOpen
				movei   #16,Y0
				movei   #27,Y1
				jsr     FmemCallocIM
				move    X:(SP),R0
				move    R2,X:(R0+12)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+12)
				jeq     _L38
				move    X:(SP),R2
				nop     
				move    X:(R2+12),R2
				movei   #0,Y0
				movei   #96,Y1
				jsr     FmemMemset
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     #16,X0
				bhs     _L13
				movei   #27,Y0
				moves   X:<mr8,X0
				impy    Y0,X0,X0
				move    X0,X:<mr9
_L9:
				move    X:(SP),R2
				moves   X:<mr9,Y0
				move    X:(R2+12),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP),R3
				jsr     FalLink
				moves   X:<mr9,X0
				add     #27,X0
				move    X0,X:<mr9
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #16,X0
				blo     _L9
_L13:
				movei   #640,Y0
				jsr     FmemMallocEM
				move    X:(SP),R0
				move    R2,X:(R0+13)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+13)
				jeq     _L38
				movei   #320,Y0
				jsr     FmemMallocEM
				move    X:(SP),R0
				move    R2,X:(R0+14)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+14)
				jeq     _L38
				movei   #2560,Y0
				jsr     FmemMallocEM
				move    X:(SP),R0
				move    R2,X:(R0+15)
				move    X:(SP),R2
				nop     
				tstw    X:(R2+15)
				jeq     _L38
				move    X:(SP),R2
				nop     
				move    X:(R2+15),X0
				add     #1280,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+16)
				moves   #65535,X:<mr8
				movei   #49152,X0
				cmp     X:<mr8,X0
				bhi     _L25
_L22:
				moves   X:<mr8,R2
				movei   #0,Y0
				jsr     FmemWriteP16
				dec     X:<mr8
				movei   #49152,X0
				cmp     X:<mr8,X0
				bls     _L22
_L25:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				movec   X:(SP-1),R0
				inc     X:(SP-1)
				move    X:(R0),X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+17)
				inc     X:(SP-1)
				move    X:(SP),R2
				nop     
				movei   #49152,X:(R2+18)
				moves   #0,X:<mr8
				bra     _L34
_L31:
				movec   X:(SP-1),R0
				inc     X:(SP-1)
				move    X:(R0),Y1
				moves   X:<mr8,Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    Y1,X:(R2+19)
				movec   X:(SP-1),R0
				inc     X:(SP-1)
				move    X:(R0),Y1
				moves   X:<mr8,Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    Y1,X:(R2+23)
				inc     X:<mr8
_L34:
				move    X:(SP),R2
				moves   X:<mr8,Y0
				move    X:(R2+17),X0
				cmp     X0,Y0
				blo     _L31
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+10)
				movei   #0,X:(R2+11)
				move    X:(SP),R2
				nop     
				movei   #0,X:(R2+7)
				movei   #1,Y0
				bra     _L40
_L38:
				move    X:(SP),R2
				jsr     FalSynDelete
				movei   #0,Y0
_L40:
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
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
				tstw    X:(R2+12)
				beq     _L4
				move    X:(SP),R2
				nop     
				move    X:(R2+12),R2
				jsr     FmemFreeEM
_L4:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+13)
				beq     _L6
				move    X:(SP),R2
				nop     
				move    X:(R2+13),R2
				jsr     FmemFreeEM
_L6:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+14)
				beq     _L8
				move    X:(SP),R2
				nop     
				move    X:(R2+14),R2
				jsr     FmemFreeEM
_L8:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+15)
				beq     _L10
				move    X:(SP),R2
				nop     
				move    X:(R2+15),R2
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
				movei   #5,N
				lea     (SP)+N
				moves   R3,X:<mr9
				moves   Y0,X:<mr8
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-2)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,A
				movei   #20000,A0
				cmp     A,B
				bge     _L7
				move    X:(SP-2),R2
				nop     
				movei   #0,X:(R2+22)
				movei   #0,X:(R2+23)
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+20)
				bra     _L8
_L7:
				movei   #0,B
				movei   #20000,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    A1,X:(SP-3)
				move    A0,X:(SP-4)
				move    X:(SP-2),R2
				nop     
				move    X:(R2+20),Y0
				moves   X:<mr8,X0
				sub     Y0,X0
				movec   X0,B
				movec   B1,B0
				move    B0,B
				move    X:(SP-3),A
				move    X:(SP-4),A0
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTDIVS32UZ
				pop     
				pop     
				move    X:(SP-2),R2
				nop     
				move    A1,X:(R2+23)
				move    A0,X:(R2+22)
_L8:
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+21)
				move    X:(SP-2),R2
				nop     
				movei   #0,X:(R2+18)
				lea     (SP-5)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalSynSetGain
				ORG	P:
FalSynSetGain:
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    Y0,X:(R0+19)
				rts     


				GLOBAL FalSynGetGain
				ORG	P:
FalSynGetGain:
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    X:(R0+19),Y0
				rts     


				GLOBAL FalSynSetPan
				ORG	P:
FalSynSetPan:
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    Y0,X:(R0+24)
				rts     


				GLOBAL FalSynSetPitch
				ORG	P:
FalSynSetPitch:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #2,A
				cmp     A,B
				ble     _L5
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				movei   #2,B
				move    B1,X:(R0+13)
				move    B0,X:(R0+12)
				bra     _L9
_L5:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bne     _L8
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				movei   #0,B
				movei   #1,B0
				move    B1,X:(R0+13)
				move    B0,X:(R0+12)
				bra     _L9
_L8:
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    B1,X:(R0+13)
				move    B0,X:(R0+12)
_L9:
				lea     (SP-2)
				rts     


				GLOBAL FalSynSetFXMix
				ORG	P:
FalSynSetFXMix:
				movec   R3,R2
				nop     
				move    X:(R2+2),R0
				move    Y0,X:(R0+25)
				rts     


				GLOBAL FalSynSetPriority
				ORG	P:
FalSynSetPriority:
				movec   R3,R2
				nop     
				move    Y0,X:(R2+4)
				rts     


				GLOBAL FalSynGetPriority
				ORG	P:
FalSynGetPriority:
				movec   R3,R2
				nop     
				move    X:(R2+4),Y0
				rts     


				GLOBAL FalSynStartVoice
				ORG	P:
FalSynStartVoice:
				moves   R3,X:<mr2
				moves   X:<mr2,R0
				move    X:(R0+2),R2
				move    X:(SP-2),R0
				moves   X:<mr2,R1
				move    R0,X:(R1+3)
				move    X:(SP-2),R0
				move    X:(R0+5),X0
				orc     #16,X0
				move    X0,X:(R2+3)
				move    X:(SP-2),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(R2+3),X0
				andc    #1,X0
				tstw    X0
				beq     _L11
				move    X:(SP-2),R0
				move    X:(R0+7),R3
				move    X:(SP-2),R0
				move    X:(R0+1),B
				move    X:(R0),B0
				move    X:(R3+3),A
				move    X:(R3+2),A0
				add     A,B
				move    B1,X:(R2+9)
				move    B0,X:(R2+8)
				move    X:(R3+1),B
				move    X:(R3),B0
				move    X:(R3+3),A
				move    X:(R3+2),A0
				sub     B,A
				movei   #0,B
				movei   #1,B0
				add     A,B
				move    B1,X:(R2+11)
				move    B0,X:(R2+10)
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
				movei   #-1,A0
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
				jsr     FalSynSetPan
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-4),Y0
				move    X:(SP-10),A
				move    X:(SP-11),A0
				jsr     FalSynSetVol
				move    X:(SP),R2
				move    X:(SP-1),R3
				movei   #32767,Y0
				jsr     FalSynSetGain
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
				move    X:(R2+2),R0
				move    X:(R0+3),X0
				andc    #16,X0
				move    X0,X:(R0+3)
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
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr10
				moves   R3,X:<mr9
				move    Y0,X:(SP)
				moves   #127,X:<mr8
				moves   X:<mr10,R0
				nop     
				tstw    X:(R0)
				beq     _L8
				moves   X:<mr10,R0
				nop     
				move    X:(R0),R1
				moves   X:<mr9,R2
				nop     
				move    R1,X:(R2+2)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),R2
				jsr     FalUnlink
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R2
				moves   X:<mr10,X0
				movec   X0,R3
				lea     (R3+2)
				jsr     FalLink
				bra     _L24
_L8:
				moves   X:<mr10,R2
				nop     
				tstw    X:(R2+4)
				beq     _L13
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),R0
				moves   X:<mr9,R2
				nop     
				move    R0,X:(R2+2)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),R2
				jsr     FalUnlink
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R2
				moves   X:<mr10,X0
				movec   X0,R3
				lea     (R3+2)
				jsr     FalLink
				bra     _L24
_L13:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L20
_L15:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),X0
				cmp     X:<mr8,X0
				bhs     _L18
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),X0
				move    X0,X:<mr8
				move    X:(SP-1),R0
				move    R0,X:<mr11
_L18:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R1
				move    R1,X:(SP-1)
				tstw    X:(SP-1)
				bne     _L15
_L20:
				move    X:(SP),X0
				cmp     X:<mr8,X0
				blo     _L23
				moves   X:<mr11,R0
				moves   X:<mr9,R2
				nop     
				move    R0,X:(R2+2)
				bra     _L24
_L23:
				movei   #0,Y0
				bra     _L28
_L24:
				move    X:(SP),X0
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R0
				move    X0,X:(R0+2)
				move    X:(SP),X0
				moves   X:<mr9,R2
				nop     
				move    X0,X:(R2+4)
				moves   X:<mr9,R0
				moves   X:<mr9,R2
				nop     
				move    X:(R2+2),R1
				move    R0,X:(R1+26)
				movei   #1,Y0
_L28:
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
				lea     (SP-2)
				rts     


				ORG	X:

				ENDSEC
				END

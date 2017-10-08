
				SECTION dfr16
				include "asmdef.h"
				GLOBAL Fdfr16CFFTCreateFFT_SIZE_8
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_8:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_8
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_8
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_8:
				movei   #8,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable8,R0
				move    R0,X:(R2+2)
				movei   #3,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_16
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_16:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_16
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_16
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_16:
				movei   #16,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable16,R0
				move    R0,X:(R2+2)
				movei   #4,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_32
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_32:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_32
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_32
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_32:
				movei   #32,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable32,R0
				move    R0,X:(R2+2)
				movei   #5,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_64
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_64:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_64
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_64
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_64:
				movei   #64,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable64,R0
				move    R0,X:(R2+2)
				movei   #6,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_128
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_128:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_128
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_128
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_128:
				movei   #128,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable128,R0
				move    R0,X:(R2+2)
				movei   #7,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_256
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_256:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_256
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_256
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_256:
				movei   #256,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable256,R0
				move    R0,X:(R2+2)
				movei   #8,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_512
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_512:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_512
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_512
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_512:
				movei   #512,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable512,R0
				move    R0,X:(R2+2)
				movei   #9,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_1024
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_1024:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_1024
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_1024
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_1024:
				movei   #1024,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable1024,R0
				move    R0,X:(R2+2)
				movei   #10,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTCreateFFT_SIZE_2048
				ORG	P:
Fdfr16CFFTCreateFFT_SIZE_2048:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #4,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16CFFTInitFFT_SIZE_2048
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16CFFTInitFFT_SIZE_2048
				ORG	P:
Fdfr16CFFTInitFFT_SIZE_2048:
				movei   #2048,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16CFFTTwiddleFactorTable2048,R0
				move    R0,X:(R2+2)
				movei   #11,X:(R2+3)
				rts     


				GLOBAL Fdfr16CFFTDestroy
				ORG	P:
Fdfr16CFFTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeIM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16CFFTC
				ORG	P:
Fdfr16CFFTC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #27,N
				lea     (SP)+N
				moves   R2,X:<mr10
				move    R3,X:(SP)
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-11)
				movei   #0,X:(SP-7)
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:(SP-7)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-13)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #4,X0
				clr     B
				movec   X0,B0
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP),R0
				move    R0,X:(SP-14)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				tst     B
				beq     _L15
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP),R2
				move    X:(SP-33),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-26)
				move    X:(SP-33),R0
				move    R0,X:(SP-14)
				movei   #-1,X0
				cmp     X:(SP-26),X0
				bne     _L15
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				jmp     _L212
_L15:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-9)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L29
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-10)
				move    X:(SP-10),X0
				asl     X0
				add     X:(SP-14),X0
				move    X0,X:(SP-6)
				bra     _L28
_L21:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L23
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L26
_L23:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L29
_L26:
				move    X:(SP-6),X0
				add     #2,X0
				move    X0,X:(SP-6)
				inc     X:(SP-10)
_L28:
				moves   X:<mr10,R2
				move    X:(SP-10),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L21
_L29:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				tstw    X0
				bne     _L31
				tstw    X:(SP-12)
				jeq     _L48
_L31:
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L60
_L33:
				move    X:(SP-21),X0
				move    X0,X:(SP-23)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-22)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     A,B
				asr     B
				bge     _L38
				adc     Y,B
				sub     Y,B
_L38:
				rnd     B
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				sub     A,B
				rnd     B
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     B,A
				asr     A
				bge     _L43
				adc     Y,A
				sub     Y,A
_L43:
				rnd     A
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				sub     A,B
				rnd     B
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L33
				jmp     _L60
_L48:
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L60
_L50:
				move    X:(SP-21),X0
				move    X0,X:(SP-23)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-22)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     A,B
				rnd     B
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     B,A
				rnd     A
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L50
_L60:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-16)
				movei   #0,X:(SP-25)
				jmp     _L140
_L63:
				movei   #0,X:(SP-12)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L76
				movei   #0,X:(SP-10)
				move    X:(SP-10),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-5)
				bra     _L75
_L68:
				move    X:(SP-5),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L70
				move    X:(SP-5),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L73
_L70:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L76
_L73:
				move    X:(SP-5),X0
				add     #2,X0
				move    X0,X:(SP-5)
				inc     X:(SP-10)
_L75:
				moves   X:<mr10,R2
				move    X:(SP-10),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L68
_L76:
				movei   #0,X:(SP-23)
				move    X:(SP-9),X0
				asr     X0
				bge     _L80
				bcc     _L80
				inc     X0
_L80:
				move    X0,X:(SP-9)
				move    X:(SP-9),X0
				move    X0,X:(SP-22)
				movei   #2,X0
				movec   X0,B
				move    X:(SP-25),A
				tstw    A
				beq     _L91
				movei   #16,X0
				blt     _L88
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L85:
				tstw    (R0)-
				beq     _L91
				asl     B
				bra     _L85
_L88:
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L89:
				tstw    (R0)-
				beq     _L91
				asr     B
				bra     _L89
_L91:
				movec   B1,X0
				move    X0,X:(SP-8)
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-8),X0
				jge     _L139
				move    X:(SP-21),X0
				asl     X0
				move    X0,X:<mr11
_L95:
				movei   #0,X:(SP-24)
				move    X:(SP-24),X0
				cmp     X:(SP-9),X0
				jge     _L134
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:<mr8
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:<mr9
_L99:
				tstw    X:(SP-16)
				bne     _L101
				tstw    X:(SP-12)
				jeq     _L117
_L101:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				moves   X:<mr8,R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				asr     B
				bge     _L107
				adc     Y,B
				sub     Y,B
_L107:
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				move    X:(SP-15),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				asr     B
				bge     _L114
				adc     Y,B
				sub     Y,B
_L114:
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
				jmp     _L128
_L117:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				moves   X:<mr8,R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				move    X:(SP-15),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
_L128:
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				inc     X:(SP-23)
				moves   X:<mr8,X0
				add     #2,X0
				move    X0,X:<mr8
				inc     X:(SP-22)
				inc     X:(SP-24)
				move    X:(SP-24),X0
				cmp     X:(SP-9),X0
				jlt     _L99
_L134:
				move    X:(SP-22),X0
				move    X0,X:(SP-23)
				move    X:(SP-9),X0
				add     X:(SP-22),X0
				move    X0,X:(SP-22)
				moves   X:<mr11,X0
				add     #2,X0
				move    X0,X:<mr11
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-8),X0
				jlt     _L95
_L139:
				inc     X:(SP-25)
_L140:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-25),X0
				sub     #2,Y0
				cmp     Y0,X0
				jlt     _L63
				movei   #0,X:(SP-12)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L154
				movei   #0,X:(SP-10)
				move    X:(SP-10),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-4)
				bra     _L153
_L146:
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L148
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L151
_L148:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L154
_L151:
				move    X:(SP-4),X0
				add     #2,X0
				move    X0,X:(SP-4)
				inc     X:(SP-10)
_L153:
				moves   X:<mr10,R2
				move    X:(SP-10),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L146
_L154:
				movei   #0,X:(SP-23)
				movei   #1,X:(SP-22)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-9)
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L198
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-3)
				move    X:(SP-21),X0
				asl     X0
				move    X0,X:(SP-2)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-1)
_L162:
				tstw    X:(SP-16)
				bne     _L164
				tstw    X:(SP-12)
				jeq     _L180
_L164:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-3),R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				asr     B
				bge     _L170
				adc     Y,B
				sub     Y,B
_L170:
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-15),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				asr     B
				bge     _L177
				adc     Y,B
				sub     Y,B
_L177:
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
				jmp     _L191
_L180:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-3),R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-15),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
_L191:
				move    X:(SP-1),X0
				add     #4,X0
				move    X0,X:(SP-1)
				move    X:(SP-23),X0
				add     #2,X0
				move    X0,X:(SP-23)
				move    X:(SP-3),X0
				add     #4,X0
				move    X0,X:(SP-3)
				move    X:(SP-22),X0
				add     #2,X0
				move    X0,X:(SP-22)
				move    X:(SP-2),X0
				add     #2,X0
				move    X0,X:(SP-2)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L162
_L198:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #8,X0
				move    X0,X:(SP-16)
				tstw    X:(SP-16)
				bne     _L204
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-33),R2
				move    X:(SP-33),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-26)
				movei   #-1,X0
				cmp     X:(SP-26),X0
				bne     _L204
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				bra     _L212
_L204:
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-16)
				tstw    X:(SP-16)
				beq     _L208
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L212
_L208:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L210
				move    X:(SP-11),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L211
_L210:
				movei   #0,Y0
_L211:
_L212:
				lea     (SP-27)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_8
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_8:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_8
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_8
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_8:
				movei   #4,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable8,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable8br,R0
				move    R0,X:(R2+3)
				movei   #2,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_16
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_16:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_16
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_16
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_16:
				movei   #8,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable16,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable16br,R0
				move    R0,X:(R2+3)
				movei   #3,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_32
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_32:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_32
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_32
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_32:
				movei   #16,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable32,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable32br,R0
				move    R0,X:(R2+3)
				movei   #4,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_64
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_64:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_64
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_64
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_64:
				movei   #32,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable64,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable64br,R0
				move    R0,X:(R2+3)
				movei   #5,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_128
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_128:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_128
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_128
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_128:
				movei   #64,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable128,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable128br,R0
				move    R0,X:(R2+3)
				movei   #6,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_256
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_256:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_256
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_256
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_256:
				movei   #128,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable256,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable256br,R0
				move    R0,X:(R2+3)
				movei   #7,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_512
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_512:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_512
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_512
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_512:
				movei   #256,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable512,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable512br,R0
				move    R0,X:(R2+3)
				movei   #8,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_1024
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_1024:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_1024
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_1024
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_1024:
				movei   #512,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable1024,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable1024br,R0
				move    R0,X:(R2+3)
				movei   #9,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTCreateFFT_SIZE_2048
				ORG	P:
Fdfr16RFFTCreateFFT_SIZE_2048:
				movei   #2,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #5,Y0
				jsr     FmemMallocIM
				move    R2,X:(SP-1)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				jsr     Fdfr16RFFTInitFFT_SIZE_2048
				move    X:(SP-1),R2
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16RFFTInitFFT_SIZE_2048
				ORG	P:
Fdfr16RFFTInitFFT_SIZE_2048:
				movei   #1024,X:(R2+1)
				move    Y0,X:(R2)
				movei   #Fdfr16RFFTTwiddleTable2048,R0
				move    R0,X:(R2+2)
				movei   #Fdfr16RFFTTwiddleTable2048br,R0
				move    R0,X:(R2+3)
				movei   #10,X:(R2+4)
				rts     


				GLOBAL Fdfr16RFFTDestroy
				ORG	P:
Fdfr16RFFTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeIM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16RFFTC
				ORG	P:
Fdfr16RFFTC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #37,N
				lea     (SP)+N
				moves   R2,X:<mr10
				move    R3,X:(SP)
				movei   #0,X:(SP-36)
				movei   #0,X:(SP-16)
				movei   #0,X:(SP-15)
				movei   #0,X:(SP-14)
				move    X:(SP),R0
				move    R0,X:(SP-23)
				move    X:(SP-43),R0
				move    R0,X:(SP-22)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:(SP-19)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-21)
				move    X:(SP-14),Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:(SP-14)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-21)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    R0,X:(SP-20)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-19)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L27
				movei   #0,X:(SP-16)
				movei   #0,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-23),X0
				move    X0,X:(SP-9)
				bra     _L26
_L19:
				move    X:(SP-9),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L21
				move    X:(SP-9),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L24
_L21:
				movei   #1,X:(SP-16)
				inc     X:(SP-15)
				bra     _L27
_L24:
				move    X:(SP-9),X0
				add     #2,X0
				move    X0,X:(SP-9)
				inc     X:(SP-17)
_L26:
				moves   X:<mr10,R2
				move    X:(SP-17),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L19
_L27:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				tstw    X0
				bne     _L29
				tstw    X:(SP-16)
				jeq     _L46
_L29:
				movei   #0,X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jge     _L58
_L31:
				move    X:(SP-30),X0
				move    X0,X:(SP-33)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-30),X0
				move    X0,X:(SP-32)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-23),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-28)
				move    A0,X:(SP-29)
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-23),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				add     A,B
				asr     B
				bge     _L36
				adc     Y,B
				sub     Y,B
_L36:
				rnd     B
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-23),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-28)
				move    A0,X:(SP-29)
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-23),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				add     B,A
				asr     A
				bge     _L41
				adc     Y,A
				sub     Y,A
_L41:
				rnd     A
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jlt     _L31
				jmp     _L58
_L46:
				movei   #0,X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jge     _L58
_L48:
				move    X:(SP-30),X0
				move    X0,X:(SP-33)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-30),X0
				move    X0,X:(SP-32)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-23),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-28)
				move    A0,X:(SP-29)
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-23),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				add     A,B
				rnd     B
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-23),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-28)
				move    A0,X:(SP-29)
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-23),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				add     B,A
				rnd     A
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-28),B
				move    X:(SP-29),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jlt     _L48
_L58:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-25)
				movei   #0,X:(SP-35)
				jmp     _L138
_L61:
				movei   #0,X:(SP-16)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L74
				movei   #0,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-8)
				bra     _L73
_L66:
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L68
				move    X:(SP-8),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L71
_L68:
				movei   #1,X:(SP-16)
				inc     X:(SP-15)
				bra     _L74
_L71:
				move    X:(SP-8),X0
				add     #2,X0
				move    X0,X:(SP-8)
				inc     X:(SP-17)
_L73:
				moves   X:<mr10,R2
				move    X:(SP-17),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L66
_L74:
				movei   #0,X:(SP-33)
				move    X:(SP-19),X0
				asr     X0
				bge     _L78
				bcc     _L78
				inc     X0
_L78:
				move    X0,X:(SP-19)
				move    X:(SP-19),X0
				move    X0,X:(SP-32)
				movei   #2,X0
				movec   X0,B
				move    X:(SP-35),A
				tstw    A
				beq     _L89
				movei   #16,X0
				blt     _L86
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L83:
				tstw    (R0)-
				beq     _L89
				asl     B
				bra     _L83
_L86:
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L87:
				tstw    (R0)-
				beq     _L89
				asr     B
				bra     _L87
_L89:
				movec   B1,X0
				move    X0,X:(SP-31)
				movei   #0,X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-31),X0
				jge     _L137
				move    X:(SP-30),X0
				asl     X0
				move    X0,X:<mr11
_L93:
				movei   #0,X:(SP-34)
				move    X:(SP-34),X0
				cmp     X:(SP-19),X0
				jge     _L132
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:<mr8
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:<mr9
_L97:
				tstw    X:(SP-25)
				bne     _L99
				tstw    X:(SP-16)
				jeq     _L115
_L99:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-24)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				moves   X:<mr8,R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-26),B
				move    X:(SP-27),B0
				move    X:(SP-28),A
				move    X:(SP-29),A0
				add     A,B
				asr     B
				bge     _L105
				adc     Y,B
				sub     Y,B
_L105:
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				move    X:(SP-24),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-28),B
				move    X:(SP-29),B0
				move    X:(SP-26),A
				move    X:(SP-27),A0
				add     A,B
				asr     B
				bge     _L112
				adc     Y,B
				sub     Y,B
_L112:
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
				jmp     _L126
_L115:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-24)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				moves   X:<mr8,R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-26),B
				move    X:(SP-27),B0
				move    X:(SP-28),A
				move    X:(SP-29),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				move    X:(SP-24),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-28),B
				move    X:(SP-29),B0
				move    X:(SP-26),A
				move    X:(SP-27),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
_L126:
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				inc     X:(SP-33)
				moves   X:<mr8,X0
				add     #2,X0
				move    X0,X:<mr8
				inc     X:(SP-32)
				inc     X:(SP-34)
				move    X:(SP-34),X0
				cmp     X:(SP-19),X0
				jlt     _L97
_L132:
				move    X:(SP-32),X0
				move    X0,X:(SP-33)
				move    X:(SP-19),X0
				add     X:(SP-32),X0
				move    X0,X:(SP-32)
				moves   X:<mr11,X0
				add     #2,X0
				move    X0,X:<mr11
				inc     X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-31),X0
				jlt     _L93
_L137:
				inc     X:(SP-35)
_L138:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),Y0
				move    X:(SP-35),X0
				sub     #2,Y0
				cmp     Y0,X0
				jlo     _L61
				movei   #0,X:(SP-16)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L152
				movei   #0,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-7)
				bra     _L151
_L144:
				move    X:(SP-7),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L146
				move    X:(SP-7),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L149
_L146:
				movei   #1,X:(SP-16)
				inc     X:(SP-15)
				bra     _L152
_L149:
				move    X:(SP-7),X0
				add     #2,X0
				move    X0,X:(SP-7)
				inc     X:(SP-17)
_L151:
				moves   X:<mr10,R2
				move    X:(SP-17),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L144
_L152:
				movei   #0,X:(SP-33)
				movei   #1,X:(SP-32)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-19)
				movei   #0,X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jge     _L196
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-6)
				move    X:(SP-30),X0
				asl     X0
				move    X0,X:(SP-5)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-4)
_L160:
				tstw    X:(SP-25)
				bne     _L162
				tstw    X:(SP-16)
				jeq     _L178
_L162:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-24)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-5),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				move    X:(SP-5),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-6),R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-26),B
				move    X:(SP-27),B0
				move    X:(SP-28),A
				move    X:(SP-29),A0
				add     A,B
				asr     B
				bge     _L168
				adc     Y,B
				sub     Y,B
_L168:
				rnd     B
				move    X:(SP-4),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				rnd     B
				move    X:(SP-6),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-5),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-24),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-5),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-28),B
				move    X:(SP-29),B0
				move    X:(SP-26),A
				move    X:(SP-27),A0
				add     A,B
				asr     B
				bge     _L175
				adc     Y,B
				sub     Y,B
_L175:
				rnd     B
				move    X:(SP-4),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				rnd     B
				move    X:(SP-6),R2
				nop     
				move    B,X:(R2+1)
				jmp     _L189
_L178:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-24)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-5),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				move    X:(SP-5),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-6),R0
				move    X:(R0+1),Y0
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-26),B
				move    X:(SP-27),B0
				move    X:(SP-28),A
				move    X:(SP-29),A0
				add     A,B
				rnd     B
				move    X:(SP-4),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-6),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-5),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-24),Y0
				move    X:(R2+1),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-5),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-28),B
				move    X:(SP-29),B0
				move    X:(SP-26),A
				move    X:(SP-27),A0
				add     A,B
				rnd     B
				move    X:(SP-4),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-6),R2
				nop     
				move    B,X:(R2+1)
_L189:
				move    X:(SP-4),X0
				add     #4,X0
				move    X0,X:(SP-4)
				move    X:(SP-33),X0
				add     #2,X0
				move    X0,X:(SP-33)
				move    X:(SP-6),X0
				add     #4,X0
				move    X0,X:(SP-6)
				move    X:(SP-32),X0
				add     #2,X0
				move    X0,X:(SP-32)
				move    X:(SP-5),X0
				add     #2,X0
				move    X0,X:(SP-5)
				inc     X:(SP-30)
				move    X:(SP-30),X0
				cmp     X:(SP-19),X0
				jlt     _L160
_L196:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-22),R2
				move    X:(SP-22),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-36)
				movei   #-1,X0
				cmp     X:(SP-36),X0
				bne     _L200
				move    X:(SP-14),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				jmp     _L292
_L200:
				movei   #0,X:(SP-16)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L213
				movei   #0,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-3)
				bra     _L212
_L205:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L207
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L210
_L207:
				movei   #1,X:(SP-16)
				inc     X:(SP-15)
				bra     _L213
_L210:
				move    X:(SP-3),X0
				add     #2,X0
				move    X0,X:(SP-3)
				inc     X:(SP-17)
_L212:
				moves   X:<mr10,R2
				move    X:(SP-17),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L205
_L213:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-25)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:(SP-19)
				move    X:(SP-22),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-13)
				move    X:(SP-22),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:(SP-11)
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-29)
				movei   #0,X:(SP-28)
				move    X:(SP-11),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-26)
				move    A0,X:(SP-27)
				tstw    X:(SP-25)
				bne     _L222
				tstw    X:(SP-16)
				beq     _L229
_L222:
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				asr     B
				bge     _L224
				adc     Y,B
				sub     Y,B
_L224:
				rnd     B
				move    X:(SP-22),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     B,A
				asr     A
				bge     _L227
				adc     Y,A
				sub     Y,A
_L227:
				rnd     A
				move    X:(SP-22),R2
				nop     
				move    A,X:(R2+1)
				bra     _L231
_L229:
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				rnd     B
				move    X:(SP-22),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     B,A
				rnd     A
				move    X:(SP-22),R2
				nop     
				move    A,X:(R2+1)
_L231:
				movei   #1,X:(SP-18)
				move    X:(SP-18),X0
				asl     X0
				add     X:(SP-22),X0
				move    X0,X:(SP-2)
				move    X:(SP-18),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-1)
				jmp     _L280
_L235:
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				asr     Y0
				bge     _L238
				bcc     _L238
				inc     Y0
_L238:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+1),X0
				asr     X0
				bge     _L241
				bcc     _L241
				inc     X0
_L241:
				add     X0,Y0
				move    Y0,X:(SP-11)
				move    X:(SP-2),R2
				nop     
				move    X:(R2+1),X0
				sub     X:(SP-11),X0
				move    X0,X:(SP-10)
				move    X:(SP-2),R0
				nop     
				move    X:(R0),Y0
				asr     Y0
				bge     _L246
				bcc     _L246
				inc     Y0
_L246:
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    X:(R0+N),X0
				asr     X0
				bge     _L249
				bcc     _L249
				inc     X0
_L249:
				add     X0,Y0
				move    Y0,X:(SP-13)
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    X:(R0+N),X0
				sub     X:(SP-13),X0
				move    X0,X:(SP-12)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-12),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				move    X:(SP-11),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-26)
				move    B0,X:(SP-27)
				tstw    X:(SP-25)
				bne     _L255
				tstw    X:(SP-16)
				beq     _L262
_L255:
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				asr     B
				bge     _L257
				adc     Y,B
				sub     Y,B
_L257:
				rnd     B
				move    X:(SP-2),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     B,A
				asr     A
				bge     _L260
				adc     Y,A
				sub     Y,A
_L260:
				rnd     A
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    A,X:(R0+N)
				bra     _L264
_L262:
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				rnd     B
				move    X:(SP-2),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-13),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     B,A
				rnd     A
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				move    X:(SP-22),R0
				movec   X0,N
				move    A,X:(R0+N)
_L264:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-11),X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-28)
				move    B0,X:(SP-29)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				move    X:(SP-12),X0
				move    X:(SP-28),B
				move    X:(SP-29),B0
				mac     Y0,X0,B
				move    B1,X:(SP-26)
				move    B0,X:(SP-27)
				tstw    X:(SP-25)
				bne     _L268
				tstw    X:(SP-16)
				beq     _L275
_L268:
				move    X:(SP-10),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				asr     B
				bge     _L270
				adc     Y,B
				sub     Y,B
_L270:
				rnd     B
				move    X:(SP-2),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-10),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				asr     B
				bge     _L273
				adc     Y,B
				sub     Y,B
_L273:
				rnd     B
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				bra     _L277
_L275:
				move    X:(SP-10),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				add     A,B
				rnd     B
				move    X:(SP-2),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-10),Y0
				jsr     FL_deposit_h
				move    X:(SP-26),B
				move    X:(SP-27),B0
				sub     A,B
				rnd     B
				move    X:(SP-19),X0
				sub     X:(SP-18),X0
				asl     X0
				add     X:(SP-22),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
_L277:
				move    X:(SP-2),X0
				add     #2,X0
				move    X0,X:(SP-2)
				move    X:(SP-1),X0
				add     #2,X0
				move    X0,X:(SP-1)
				inc     X:(SP-18)
_L280:
				move    X:(SP-19),Y0
				asr     Y0
				bge     _L283
				bcc     _L283
				inc     Y0
_L283:
				move    X:(SP-18),X0
				cmp     Y0,X0
				jle     _L235
				move    X:(SP-14),Y0
				jsr     FarchGetSetSaturationMode
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-25)
				tstw    X:(SP-25)
				beq     _L288
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),X0
				inc     X0
				movec   X0,B0
				movec   B0,Y0
				bra     _L292
_L288:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L290
				move    X:(SP-15),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L291
_L290:
				movei   #0,Y0
_L291:
_L292:
				lea     (SP-37)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16CIFFTDestroy
				ORG	P:
Fdfr16CIFFTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeIM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16CIFFTC
				ORG	P:
Fdfr16CIFFTC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #27,N
				lea     (SP)+N
				moves   R2,X:<mr10
				move    R3,X:(SP)
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-11)
				movei   #0,X:(SP-7)
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:(SP-7)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-13)
				move    X:(SP),R0
				move    R0,X:(SP-14)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #4,X0
				clr     B
				movec   X0,B0
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				tst     B
				beq     _L15
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP),R2
				move    X:(SP-33),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-26)
				move    X:(SP-33),R0
				move    R0,X:(SP-14)
				movei   #-1,X0
				cmp     X:(SP-26),X0
				bne     _L15
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				jmp     _L213
_L15:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-9)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L29
				movei   #0,X:(SP-12)
				movei   #0,X:(SP-10)
				move    X:(SP-10),X0
				cmp     X:(SP-9),X0
				bge     _L29
				move    X:(SP-10),X0
				asl     X0
				add     X:(SP-14),X0
				move    X0,X:(SP-6)
_L21:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L23
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L26
_L23:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L29
_L26:
				move    X:(SP-6),X0
				add     #2,X0
				move    X0,X:(SP-6)
				inc     X:(SP-10)
				move    X:(SP-10),X0
				cmp     X:(SP-9),X0
				blt     _L21
_L29:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				tstw    X0
				bne     _L31
				tstw    X:(SP-12)
				jeq     _L48
_L31:
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L60
_L33:
				move    X:(SP-21),X0
				move    X0,X:(SP-23)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-22)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     A,B
				asr     B
				bge     _L38
				adc     Y,B
				sub     Y,B
_L38:
				rnd     B
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				sub     A,B
				rnd     B
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     B,A
				asr     A
				bge     _L43
				adc     Y,A
				sub     Y,A
_L43:
				rnd     A
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				sub     A,B
				rnd     B
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L33
				jmp     _L60
_L48:
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L60
_L50:
				move    X:(SP-21),X0
				move    X0,X:(SP-23)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-22)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-14),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     A,B
				rnd     B
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-22),X0
				asl     X0
				move    X:(SP-33),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-23),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-19)
				move    A0,X:(SP-20)
				move    X:(SP-22),X0
				asl     X0
				add     X:(SP-14),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				add     B,A
				rnd     A
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-19),B
				move    X:(SP-20),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L50
_L60:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-16)
				movei   #0,X:(SP-25)
				jmp     _L141
_L63:
				movei   #0,X:(SP-12)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L76
				movei   #0,X:(SP-10)
				move    X:(SP-10),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-5)
				bra     _L75
_L68:
				move    X:(SP-5),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L70
				move    X:(SP-5),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L73
_L70:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L76
_L73:
				move    X:(SP-5),X0
				add     #2,X0
				move    X0,X:(SP-5)
				inc     X:(SP-10)
_L75:
				moves   X:<mr10,R2
				move    X:(SP-10),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L68
_L76:
				movei   #0,X:(SP-23)
				move    X:(SP-9),X0
				asr     X0
				bge     _L80
				bcc     _L80
				inc     X0
_L80:
				move    X0,X:(SP-9)
				move    X:(SP-9),X0
				move    X0,X:(SP-22)
				movei   #2,X:(SP-8)
				move    X:(SP-8),B
				move    X:(SP-25),A
				tstw    A
				beq     _L92
				movei   #16,X0
				blt     _L89
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L86:
				tstw    (R0)-
				beq     _L92
				asl     B
				bra     _L86
_L89:
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L90:
				tstw    (R0)-
				beq     _L92
				asr     B
				bra     _L90
_L92:
				movec   B1,X0
				move    X0,X:(SP-8)
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-8),X0
				jge     _L140
				move    X:(SP-21),X0
				asl     X0
				move    X0,X:<mr11
_L96:
				movei   #0,X:(SP-24)
				move    X:(SP-24),X0
				cmp     X:(SP-9),X0
				jge     _L135
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:<mr8
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:<mr9
_L100:
				tstw    X:(SP-16)
				bne     _L102
				tstw    X:(SP-12)
				jeq     _L118
_L102:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				asr     B
				bge     _L108
				adc     Y,B
				sub     Y,B
_L108:
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-15),Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				asr     B
				bge     _L115
				adc     Y,B
				sub     Y,B
_L115:
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
				jmp     _L129
_L118:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-15),Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+2),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
_L129:
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				inc     X:(SP-23)
				moves   X:<mr8,X0
				add     #2,X0
				move    X0,X:<mr8
				inc     X:(SP-22)
				inc     X:(SP-24)
				move    X:(SP-24),X0
				cmp     X:(SP-9),X0
				jlt     _L100
_L135:
				move    X:(SP-22),X0
				move    X0,X:(SP-23)
				move    X:(SP-9),X0
				add     X:(SP-22),X0
				move    X0,X:(SP-22)
				moves   X:<mr11,X0
				add     #2,X0
				move    X0,X:<mr11
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-8),X0
				jlt     _L96
_L140:
				inc     X:(SP-25)
_L141:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),Y0
				move    X:(SP-25),X0
				sub     #2,Y0
				cmp     Y0,X0
				jlt     _L63
				movei   #0,X:(SP-12)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L155
				movei   #0,X:(SP-10)
				move    X:(SP-10),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-4)
				bra     _L154
_L147:
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L149
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L152
_L149:
				movei   #1,X:(SP-12)
				inc     X:(SP-11)
				bra     _L155
_L152:
				move    X:(SP-4),X0
				add     #2,X0
				move    X0,X:(SP-4)
				inc     X:(SP-10)
_L154:
				moves   X:<mr10,R2
				move    X:(SP-10),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L147
_L155:
				movei   #0,X:(SP-23)
				movei   #1,X:(SP-22)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-9)
				movei   #0,X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jge     _L199
				move    X:(SP-22),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-3)
				move    X:(SP-21),X0
				asl     X0
				move    X0,X:(SP-2)
				move    X:(SP-23),Y0
				asl     Y0
				move    X:(SP-33),X0
				add     X0,Y0
				move    Y0,X:(SP-1)
_L163:
				tstw    X:(SP-16)
				bne     _L165
				tstw    X:(SP-12)
				jeq     _L181
_L165:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				asr     B
				bge     _L171
				adc     Y,B
				sub     Y,B
_L171:
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-15),Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				asr     B
				bge     _L178
				adc     Y,B
				sub     Y,B
_L178:
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
				jmp     _L192
_L181:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(SP-15)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-17),B
				move    X:(SP-18),B0
				move    X:(SP-19),A
				move    X:(SP-20),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-15),Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-17)
				move    A0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-19),B
				move    X:(SP-20),B0
				mac     Y0,X0,B
				move    B1,X:(SP-19)
				move    B0,X:(SP-20)
				move    X:(SP-19),B
				move    X:(SP-20),B0
				move    X:(SP-17),A
				move    X:(SP-18),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-17),B
				move    X:(SP-18),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
_L192:
				move    X:(SP-1),X0
				add     #4,X0
				move    X0,X:(SP-1)
				move    X:(SP-23),X0
				add     #2,X0
				move    X0,X:(SP-23)
				move    X:(SP-3),X0
				add     #4,X0
				move    X0,X:(SP-3)
				move    X:(SP-22),X0
				add     #2,X0
				move    X0,X:(SP-22)
				move    X:(SP-2),X0
				add     #2,X0
				move    X0,X:(SP-2)
				inc     X:(SP-21)
				move    X:(SP-21),X0
				cmp     X:(SP-9),X0
				jlt     _L163
_L199:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #8,X0
				move    X0,X:(SP-16)
				tstw    X:(SP-16)
				bne     _L205
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-33),R2
				move    X:(SP-33),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-26)
				movei   #-1,X0
				cmp     X:(SP-26),X0
				bne     _L205
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				bra     _L213
_L205:
				move    X:(SP-7),Y0
				jsr     FarchGetSetSaturationMode
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-16)
				tstw    X:(SP-16)
				beq     _L209
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L213
_L209:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L211
				move    X:(SP-11),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L212
_L211:
				movei   #0,Y0
_L212:
_L213:
				lea     (SP-27)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16RIFFTDestroy
				ORG	P:
Fdfr16RIFFTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeIM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16RIFFTC
				ORG	P:
Fdfr16RIFFTC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #37,N
				lea     (SP)+N
				moves   R2,X:<mr10
				move    R3,X:(SP)
				movei   #0,X:(SP-36)
				movei   #0,X:(SP-22)
				movei   #0,X:(SP-15)
				movei   #0,X:(SP-12)
				move    X:(SP-43),R0
				move    R0,X:(SP-21)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:(SP-18)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-20)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-19)
				move    X:(SP-22),Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:(SP-22)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L26
				movei   #0,X:(SP-15)
				move    X:(SP),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L15
				move    X:(SP),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L26
_L15:
				movei   #0,X:(SP-16)
				move    X:(SP-16),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				move    Y0,X:(SP-11)
				bra     _L25
_L18:
				move    X:(SP-11),R2
				nop     
				move    X:(R2+2),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L20
				move    X:(SP-11),R2
				nop     
				move    X:(R2+3),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L23
_L20:
				movei   #1,X:(SP-15)
				inc     X:(SP-12)
				bra     _L26
_L23:
				move    X:(SP-11),X0
				add     #2,X0
				move    X0,X:(SP-11)
				inc     X:(SP-16)
_L25:
				moves   X:<mr10,R2
				move    X:(SP-16),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L18
_L26:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				tstw    X0
				bne     _L28
				tstw    X:(SP-15)
				jeq     _L103
_L28:
				move    X:(SP),R2
				nop     
				move    X:(R2+1),Y0
				asr     Y0
				bge     _L31
				bcc     _L31
				inc     Y0
_L31:
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				asr     X0
				bge     _L34
				bcc     _L34
				inc     X0
_L34:
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),Y0
				asr     Y0
				bge     _L38
				bcc     _L38
				inc     Y0
_L38:
				move    X:(SP),R0
				nop     
				move    X:(R0),X0
				asr     X0
				bge     _L41
				bcc     _L41
				inc     X0
_L41:
				sub     Y0,X0
				move    X:(SP-21),R2
				nop     
				move    X0,X:(R2+1)
				move    X:(SP-21),R0
				move    X:(SP-24),X0
				move    X0,X:(R0)
				movei   #1,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-20),X0
				move    X0,X:(SP-10)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-9)
				jmp     _L84
_L47:
				move    X:(SP-17),X0
				dec     X0
				move    X0,X:(SP-14)
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				dec     X0
				move    X0,X:(SP-13)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				sub     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L56
				adc     Y,B
				sub     Y,B
_L56:
				rnd     B
				move    X:(SP-9),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-25)
				move    B0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+3),Y0
				move    X:(R2+3),X0
				sub     Y0,X0
				move    X0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L64
				adc     Y,B
				sub     Y,B
_L64:
				rnd     B
				move    X:(SP-9),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),A
				neg     A
				movec   A1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L72
				adc     Y,B
				sub     Y,B
_L72:
				rnd     B
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-10),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-25)
				move    B0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+3),Y0
				move    X:(R2+3),X0
				sub     Y0,X0
				move    X0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L80
				adc     Y,B
				sub     Y,B
_L80:
				rnd     B
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-10),X0
				add     #2,X0
				move    X0,X:(SP-10)
				move    X:(SP-9),X0
				add     #2,X0
				move    X0,X:(SP-9)
				inc     X:(SP-17)
_L84:
				move    X:(SP-18),Y0
				asr     Y0
				bge     _L87
				bcc     _L87
				inc     Y0
_L87:
				move    X:(SP-17),X0
				cmp     Y0,X0
				jlt     _L47
				move    X:(SP-18),X0
				asr     X0
				bge     _L91
				bcc     _L91
				inc     X0
_L91:
				asl     X0
				move    X:(SP),R0
				movec   X0,N
				move    X:(R0+N),Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L94
				bcc     _L94
				inc     X0
_L94:
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    Y0,X:(R0+N)
				move    X:(SP),Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L98
				bcc     _L98
				inc     X0
_L98:
				asl     X0
				movec   Y0,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    X:(R0+N),B
				neg     B
				movec   B1,Y1
				move    X:(SP-21),Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L101
				bcc     _L101
				inc     X0
_L101:
				asl     X0
				movec   Y0,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    Y1,X:(R0+N)
				jmp     _L157
_L103:
				move    X:(SP),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(R0),X0
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP),R0
				move    X:(SP),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(R0),X0
				sub     Y0,X0
				move    X:(SP-21),R2
				nop     
				move    X0,X:(R2+1)
				move    X:(SP-21),R0
				move    X:(SP-24),X0
				move    X0,X:(R0)
				movei   #1,X:(SP-17)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-20),X0
				move    X0,X:(SP-8)
				move    X:(SP-17),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-7)
				jmp     _L139
_L110:
				move    X:(SP-17),X0
				dec     X0
				move    X0,X:(SP-14)
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				dec     X0
				move    X0,X:(SP-13)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				sub     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				move    X:(SP-7),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-25)
				move    B0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+3),Y0
				move    X:(R2+3),X0
				sub     Y0,X0
				move    X0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				move    X:(SP-7),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),A
				neg     A
				movec   A1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+2),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    Y0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				add     B,A
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				move    X:(R0+1),B
				neg     B
				movec   B1,Y0
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-8),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				mpy     Y0,X0,A
				sub     A,B
				move    B1,X:(SP-25)
				move    B0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-13),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-14),Y0
				asl     Y0
				move    X:(SP),X0
				add     X0,Y0
				movec   Y0,R0
				move    X:(R0+3),Y0
				move    X:(R2+3),X0
				sub     Y0,X0
				move    X0,X:(SP-24)
				move    X:(SP-24),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				move    X:(SP-18),X0
				sub     X:(SP-17),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-8),X0
				add     #2,X0
				move    X0,X:(SP-8)
				move    X:(SP-7),X0
				add     #2,X0
				move    X0,X:(SP-7)
				inc     X:(SP-17)
_L139:
				move    X:(SP-18),Y0
				asr     Y0
				bge     _L142
				bcc     _L142
				inc     Y0
_L142:
				move    X:(SP-17),X0
				cmp     Y0,X0
				jlt     _L110
				move    X:(SP-18),X0
				asr     X0
				bge     _L146
				bcc     _L146
				inc     X0
_L146:
				asl     X0
				move    X:(SP),R0
				movec   X0,N
				move    X:(R0+N),Y0
				asl     Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L149
				bcc     _L149
				inc     X0
_L149:
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    Y0,X:(R0+N)
				move    X:(SP),Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L153
				bcc     _L153
				inc     X0
_L153:
				asl     X0
				movec   Y0,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    X:(R0+N),Y0
				movei   #-2,X0
				impy    Y0,X0,Y1
				move    X:(SP-21),Y0
				move    X:(SP-18),X0
				asr     X0
				bge     _L156
				bcc     _L156
				inc     X0
_L156:
				asl     X0
				movec   Y0,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    Y1,X:(R0+N)
_L157:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-18)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L171
				movei   #0,X:(SP-15)
				movei   #0,X:(SP-16)
				move    X:(SP-16),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-6)
				bra     _L170
_L163:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L165
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L168
_L165:
				movei   #1,X:(SP-15)
				inc     X:(SP-12)
				bra     _L171
_L168:
				move    X:(SP-6),X0
				add     #2,X0
				move    X0,X:(SP-6)
				inc     X:(SP-16)
_L170:
				moves   X:<mr10,R2
				move    X:(SP-16),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L163
_L171:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				tstw    X0
				bne     _L173
				tstw    X:(SP-15)
				jeq     _L190
_L173:
				movei   #0,X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jge     _L202
_L175:
				move    X:(SP-31),X0
				move    X0,X:(SP-33)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-31),X0
				move    X0,X:(SP-32)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				add     A,B
				asr     B
				bge     _L180
				adc     Y,B
				sub     Y,B
_L180:
				rnd     B
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				add     B,A
				asr     A
				bge     _L185
				adc     Y,A
				sub     Y,A
_L185:
				rnd     A
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jlt     _L175
				jmp     _L202
_L190:
				movei   #0,X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jge     _L202
_L192:
				move    X:(SP-31),X0
				move    X0,X:(SP-33)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				add     X:(SP-31),X0
				move    X0,X:(SP-32)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				add     A,B
				rnd     B
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    X:(R0+N),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				move    X:(SP-21),R0
				movec   X0,N
				move    B,X:(R0+N)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-27)
				move    A0,X:(SP-28)
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				add     B,A
				rnd     A
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    A,X:(R2+1)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-27),B
				move    X:(SP-28),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				movec   X0,R2
				nop     
				move    B,X:(R2+1)
				inc     X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jlt     _L192
_L202:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-24)
				movei   #0,X:(SP-35)
				jmp     _L282
_L205:
				movei   #0,X:(SP-15)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L218
				movei   #0,X:(SP-16)
				move    X:(SP-16),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-5)
				bra     _L217
_L210:
				move    X:(SP-5),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L212
				move    X:(SP-5),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L215
_L212:
				movei   #1,X:(SP-15)
				inc     X:(SP-12)
				bra     _L218
_L215:
				move    X:(SP-5),X0
				add     #2,X0
				move    X0,X:(SP-5)
				inc     X:(SP-16)
_L217:
				moves   X:<mr10,R2
				move    X:(SP-16),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L210
_L218:
				movei   #0,X:(SP-33)
				move    X:(SP-18),X0
				asr     X0
				bge     _L222
				bcc     _L222
				inc     X0
_L222:
				move    X0,X:(SP-18)
				move    X:(SP-18),X0
				move    X0,X:(SP-32)
				movei   #2,X0
				movec   X0,B
				move    X:(SP-35),A
				tstw    A
				beq     _L233
				movei   #16,X0
				blt     _L230
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L227:
				tstw    (R0)-
				beq     _L233
				asl     B
				bra     _L227
_L230:
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L231:
				tstw    (R0)-
				beq     _L233
				asr     B
				bra     _L231
_L233:
				movec   B1,X0
				move    X0,X:(SP-23)
				movei   #0,X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-23),X0
				jge     _L281
				move    X:(SP-31),X0
				asl     X0
				move    X0,X:<mr11
_L237:
				movei   #0,X:(SP-34)
				move    X:(SP-34),X0
				cmp     X:(SP-18),X0
				jge     _L276
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:<mr8
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:<mr9
_L241:
				tstw    X:(SP-24)
				bne     _L243
				tstw    X:(SP-15)
				jeq     _L259
_L243:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-29)
				move    B0,X:(SP-30)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L249
				adc     Y,B
				sub     Y,B
_L249:
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-29),A
				move    X:(SP-30),A0
				movec   A0,Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-27),B
				move    X:(SP-28),B0
				move    X:(SP-25),A
				move    X:(SP-26),A0
				add     A,B
				asr     B
				bge     _L256
				adc     Y,B
				sub     Y,B
_L256:
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
				jmp     _L270
_L259:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-29)
				move    B0,X:(SP-30)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				movec   R0,X0
				add     X:<mr11,X0
				movec   X0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-29),A
				move    X:(SP-30),A0
				movec   A0,Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				moves   X:<mr11,R0
				move    X:(R2+3),X0
				movec   X0,N
				move    X:(R0+N),Y0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-27),B
				move    X:(SP-28),B0
				move    X:(SP-25),A
				move    X:(SP-26),A0
				add     A,B
				rnd     B
				moves   X:<mr9,R2
				nop     
				move    B,X:(R2+1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				asl     B
				sub     A,B
				rnd     B
				moves   X:<mr8,R2
				nop     
				move    B,X:(R2+1)
_L270:
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				inc     X:(SP-33)
				moves   X:<mr8,X0
				add     #2,X0
				move    X0,X:<mr8
				inc     X:(SP-32)
				inc     X:(SP-34)
				move    X:(SP-34),X0
				cmp     X:(SP-18),X0
				jlt     _L241
_L276:
				move    X:(SP-32),X0
				move    X0,X:(SP-33)
				move    X:(SP-18),X0
				add     X:(SP-32),X0
				move    X0,X:(SP-32)
				moves   X:<mr11,X0
				add     #2,X0
				move    X0,X:<mr11
				inc     X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-23),X0
				jlt     _L237
_L281:
				inc     X:(SP-35)
_L282:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),Y0
				move    X:(SP-35),X0
				sub     #2,Y0
				cmp     Y0,X0
				jlo     _L205
				movei   #0,X:(SP-15)
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L296
				movei   #0,X:(SP-16)
				move    X:(SP-16),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-4)
				bra     _L295
_L288:
				move    X:(SP-4),R0
				nop     
				move    X:(R0),Y0
				jsr     Fabs
				cmp     #8192,Y0
				bge     _L290
				move    X:(SP-4),R2
				nop     
				move    X:(R2+1),Y0
				jsr     Fabs
				cmp     #8192,Y0
				blt     _L293
_L290:
				movei   #1,X:(SP-15)
				inc     X:(SP-12)
				bra     _L296
_L293:
				move    X:(SP-4),X0
				add     #2,X0
				move    X0,X:(SP-4)
				inc     X:(SP-16)
_L295:
				moves   X:<mr10,R2
				move    X:(SP-16),Y0
				move    X:(R2+1),X0
				cmp     X0,Y0
				blo     _L288
_L296:
				movei   #0,X:(SP-33)
				movei   #1,X:(SP-32)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),X0
				lsr     X0
				move    X0,X:(SP-18)
				movei   #0,X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jge     _L340
				move    X:(SP-32),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-3)
				move    X:(SP-31),X0
				asl     X0
				move    X0,X:(SP-2)
				move    X:(SP-33),X0
				asl     X0
				add     X:(SP-21),X0
				move    X0,X:(SP-1)
_L304:
				tstw    X:(SP-24)
				bne     _L306
				tstw    X:(SP-15)
				jeq     _L322
_L306:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-29)
				move    B0,X:(SP-30)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				asr     B
				bge     _L312
				adc     Y,B
				sub     Y,B
_L312:
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-29),A
				move    X:(SP-30),A0
				movec   A0,Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-27),B
				move    X:(SP-28),B0
				move    X:(SP-25),A
				move    X:(SP-26),A0
				add     A,B
				asr     B
				bge     _L319
				adc     Y,B
				sub     Y,B
_L319:
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
				jmp     _L333
_L322:
				move    X:(SP-3),R0
				nop     
				move    X:(R0),B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-29)
				move    B0,X:(SP-30)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R0
				nop     
				move    X:(R0),X0
				mpy     X0,Y0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),Y0
				movec   B1,X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-25),B
				move    X:(SP-26),B0
				move    X:(SP-27),A
				move    X:(SP-28),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R0
				nop     
				move    B,X:(R0)
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R0
				nop     
				move    B,X:(R0)
				moves   X:<mr10,R2
				move    X:(SP-2),Y0
				move    X:(R2+3),X0
				add     X0,Y0
				movec   Y0,R2
				nop     
				move    X:(R2+1),B
				neg     B
				move    X:(SP-29),A
				move    X:(SP-30),A0
				movec   A0,Y0
				movec   B1,X0
				mpy     Y0,X0,B
				neg     B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-25)
				move    A0,X:(SP-26)
				moves   X:<mr10,R2
				nop     
				move    X:(R2+3),R0
				move    X:(SP-2),R1
				movec   R1,N
				move    X:(R0+N),Y0
				move    X:(SP-3),R2
				nop     
				move    X:(R2+1),X0
				move    X:(SP-27),B
				move    X:(SP-28),B0
				mac     Y0,X0,B
				move    B1,X:(SP-27)
				move    B0,X:(SP-28)
				move    X:(SP-27),B
				move    X:(SP-28),B0
				move    X:(SP-25),A
				move    X:(SP-26),A0
				add     A,B
				rnd     B
				move    X:(SP-1),R2
				nop     
				move    B,X:(R2+1)
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				jsr     FL_deposit_h
				move    X:(SP-25),B
				move    X:(SP-26),B0
				asl     B
				sub     A,B
				rnd     B
				move    X:(SP-3),R2
				nop     
				move    B,X:(R2+1)
_L333:
				move    X:(SP-1),X0
				add     #4,X0
				move    X0,X:(SP-1)
				move    X:(SP-33),X0
				add     #2,X0
				move    X0,X:(SP-33)
				move    X:(SP-3),X0
				add     #4,X0
				move    X0,X:(SP-3)
				move    X:(SP-32),X0
				add     #2,X0
				move    X0,X:(SP-32)
				move    X:(SP-2),X0
				add     #2,X0
				move    X0,X:(SP-2)
				inc     X:(SP-31)
				move    X:(SP-31),X0
				cmp     X:(SP-18),X0
				jlt     _L304
_L340:
				moves   X:<mr10,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-21),R2
				move    X:(SP-21),R3
				jsr     Fdfr16CbitrevC
				move    Y0,X:(SP-36)
				movei   #-1,X0
				cmp     X:(SP-36),X0
				bne     _L344
				move    X:(SP-22),Y0
				jsr     FarchGetSetSaturationMode
				movei   #-1,Y0
				bra     _L352
_L344:
				move    X:(SP-22),Y0
				jsr     FarchGetSetSaturationMode
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				andc    #1,X0
				move    X0,X:(SP-24)
				tstw    X:(SP-24)
				beq     _L348
				moves   X:<mr10,R2
				nop     
				move    X:(R2+4),X0
				inc     X0
				movec   X0,B0
				movec   B0,Y0
				bra     _L352
_L348:
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				bftstl  #2,X0
				blo     _L350
				move    X:(SP-12),B
				movec   B1,B0
				movec   B0,Y0
				bra     _L351
_L350:
				movei   #0,Y0
_L351:
_L352:
				lea     (SP-37)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16CbitrevC
				ORG	P:
Fdfr16CbitrevC:
				movei   #5,N
				lea     (SP)+N
				tstw    Y0
				beq     _L3
				cmp     #8192,Y0
				bls     _L4
_L3:
				movei   #-1,Y0
				jmp     _L25
_L4:
				moves   #0,X:<mr4
				moves   #0,X:<mr3
				jmp     _L21
_L7:
				moves   X:<mr3,X0
				cmp     X:<mr4,X0
				blt     _L14
				moves   X:<mr4,X0
				asl     X0
				movec   X0,N
				move    X:(R2+N),X0
				move    X0,X:<mr5
				moves   X:<mr3,X0
				asl     X0
				movec   X0,N
				move    X:(R2+N),Y1
				moves   X:<mr4,X0
				asl     X0
				movec   X0,N
				move    Y1,X:(R3+N)
				moves   X:<mr5,Y1
				moves   X:<mr3,X0
				asl     X0
				movec   X0,N
				move    Y1,X:(R3+N)
				moves   X:<mr4,X0
				asl     X0
				movec   R2,Y1
				add     Y1,X0
				movec   X0,R0
				move    X:(R0+1),X0
				move    X0,X:<mr6
				moves   X:<mr3,X0
				asl     X0
				movec   R2,Y1
				add     Y1,X0
				movec   X0,R0
				move    X:(R0+1),X0
				movec   X0,X:(SP-3)
				moves   X:<mr4,Y1
				asl     Y1
				movec   R3,X:(SP)
				movec   X:(SP),X0
				add     X0,Y1
				movec   Y1,R0
				movec   X:(SP-3),X0
				move    X0,X:(R0+1)
				moves   X:<mr6,X0
				movec   X0,X:(SP-4)
				moves   X:<mr3,Y1
				asl     Y1
				movec   R3,X:(SP-1)
				movec   X:(SP-1),X0
				add     X0,Y1
				movec   Y1,R0
				movec   X:(SP-4),X0
				move    X0,X:(R0+1)
_L14:
				movec   Y0,B
				asr     B
				movec   B1,X0
				move    X0,X:<mr2
				moves   X:<mr3,X0
				cmp     X:<mr2,X0
				blt     _L19
_L16:
				moves   X:<mr3,X0
				sub     X:<mr2,X0
				move    X0,X:<mr3
				move    X:<mr2,B
				asr     B
				movec   B1,X0
				move    X0,X:<mr2
				moves   X:<mr3,X0
				cmp     X:<mr2,X0
				bge     _L16
_L19:
				moves   X:<mr2,X0
				add     X:<mr3,X0
				move    X0,X:<mr3
				moves   X:<mr4,X0
				inc     X0
				move    X0,X:<mr4
_L21:
				moves   X:<mr4,Y1
				movec   Y0,X0
				dec     X0
				cmp     X0,Y1
				jlo     _L7
				movec   R2,Y1
				movec   Y0,X0
				lsl     X0
				movec   Y1,R0
				lea     (R0-2)
				movec   X0,N
				move    X:(R0+N),Y1
				movec   R3,X:(SP-2)
				movec   Y0,X0
				lsl     X0
				movec   X:(SP-2),R0
				lea     (R0-2)
				movec   X0,N
				move    Y1,X:(R0+N)
				movec   R2,Y1
				movec   Y0,X0
				lsl     X0
				movec   Y1,R0
				nop     
				lea     (R0)-
				movec   X0,N
				move    X:(R0+N),X0
				movec   R3,Y1
				lsl     Y0
				movec   Y1,R0
				nop     
				lea     (R0)-
				movec   Y0,N
				move    X0,X:(R0+N)
				movei   #0,Y0
_L25:
				lea     (SP-5)
				rts     


				GLOBAL Fdfr16FIRCreate
				ORG	P:
Fdfr16FIRCreate:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   Y0,X:<mr8
				movei   #8,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L16
				moves   X:<mr8,Y0
				jsr     FmemMallocIM
				move    X:(SP-1),R0
				nop     
				move    R2,X:(R0)
				moves   X:<mr8,Y0
				jsr     FmemMallocAlignedEM
				move    X:(SP-1),R0
				move    R2,X:(R0+1)
				move    X:(SP-1),R0
				nop     
				tstw    X:(R0)
				beq     _L10
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L10
				move    X:(SP-1),R2
				move    X:(SP),R3
				moves   X:<mr8,Y0
				jsr     Fdfr16FIRInit
				bra     _L16
_L10:
				move    X:(SP-1),R0
				nop     
				tstw    X:(R0)
				beq     _L12
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R2
				jsr     FmemFreeIM
_L12:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L14
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemFreeEM
_L14:
				move    X:(SP-1),R2
				jsr     FmemFreeEM
				movei   #0,X:(SP-1)
_L16:
				move    X:(SP-1),R2
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16FIRInit
				ORG	P:
Fdfr16FIRInit:
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
				moves   R3,X:<mr11
				move    Y0,X:(SP-1)
				move    X:(SP),R0
				move    R0,X:<mr8
				tstw    X:(SP)
				bne     _L5
				debug   
_L5:
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				bne     _L7
				debug   
_L7:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				bne     _L9
				debug   
_L9:
				move    X:(SP-1),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+2)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),R2
				move    X:(SP-1),Y0
				jsr     FmemIsAligned
				moves   X:<mr8,R2
				nop     
				move    Y0,X:(R2+4)
				movei   #0,X:(SP-2)
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+4)
				beq     _L15
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				jsr     FmemIsIM
				tstw    Y0
				beq     _L15
				movei   #1,X:(SP-2)
_L15:
				move    X:(SP-2),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+3)
				moves   X:<mr8,R0
				move    X:(SP-1),Y0
				move    X:(R0),X0
				add     X0,Y0
				dec     Y0
				move    Y0,X:<mr10
				moves   #0,X:<mr9
				bra     _L23
_L20:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				movei   #0,X0
				move    X0,X:(R0)
				moves   X:<mr11,R0
				inc     X:<mr11
				moves   X:<mr10,R1
				dec     X:<mr10
				move    X:(R0),X0
				move    X0,X:(R1)
				inc     X:<mr9
_L23:
				moves   X:<mr8,R2
				moves   X:<mr9,Y0
				move    X:(R2+2),X0
				cmp     X0,Y0
				blo     _L20
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+3)
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


				GLOBAL Fdfr16FIRDestroy
				ORG	P:
Fdfr16FIRDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L8
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				beq     _L5
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				jsr     FmemFreeIM
_L5:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				beq     _L7
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemFreeEM
_L7:
				move    X:(SP),R2
				jsr     FmemFreeEM
_L8:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16FIRHistory
				ORG	P:
Fdfr16FIRHistory:
				move    X:(R2+1),R0
				move    R0,X:(R2+3)
				moves   #0,X:<mr2
				bra     _L6
_L4:
				move    X:(R3),X0
				lea     (R3)+
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				move    X0,X:(R0)
				inc     X:<mr2
_L6:
				moves   X:<mr2,Y0
				move    X:(R2+2),X0
				cmp     X0,Y0
				blo     _L4
				move    X:(R2+1),R0
				move    R0,X:(R2+3)
				rts     


				GLOBAL Fdfr16FIRC
				ORG	P:
Fdfr16FIRC:
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr7
				moves   R3,X:<mr6
				moves   X:<mr7,R3
				move    X:(R3+3),R2
				move    X:(R3+2),X0
				move    X:(R3+1),Y1
				add     Y1,X0
				dec     X0
				move    X0,X:<mr4
				moves   #0,X:<mr5
				moves   X:<mr5,X0
				cmp     Y0,X0
				bhs     _L22
_L7:
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(R3),R0
				move    R0,X:<mr3
				moves   X:<mr6,R0
				inc     X:<mr6
				move    X:(R0),X0
				move    X0,X:(R2)
				lea     (R2)+
				movec   R2,X0
				cmp     X:<mr4,X0
				bls     _L12
				move    X:(R3+1),R2
_L12:
				moves   #0,X:<mr2
				bra     _L18
_L14:
				moves   X:<mr3,R0
				inc     X:<mr3
				move    X:(R2),X0
				lea     (R2)+
				movec   X0,B1
				move    X:(R0),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movec   R2,X0
				cmp     X:<mr4,X0
				bls     _L17
				move    X:(R3+1),R2
_L17:
				inc     X:<mr2
_L18:
				moves   X:<mr2,X0
				move    X:(R3+2),Y1
				cmp     Y1,X0
				blo     _L14
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				movec   X:(SP-4),R0
				inc     X:(SP-4)
				move    B,X:(R0)
				inc     X:<mr5
				moves   X:<mr5,X0
				cmp     Y0,X0
				blo     _L7
_L22:
				move    R2,X:(R3+3)
				lea     (SP-2)
				rts     


				GLOBAL Fdfr16FIRs
				ORG	P:
Fdfr16FIRs:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				movec   SP,R0
				lea     (R0-2)
				push    R0
				movec   SP,R3
				lea     (R3-2)
				move    X:(SP-1),R2
				movei   #1,Y0
				jsr     Fdfr16FIR
				pop     
				move    X:(SP-2),Y0
				lea     (SP-3)
				rts     


				GLOBAL Fdfr16FIRDecCreate
				ORG	P:
Fdfr16FIRDecCreate:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				moves   Y1,X:<mr8
				move    X:(SP),R2
				move    X:(SP-1),Y0
				jsr     Fdfr16FIRCreate
				move    R2,X:(SP-2)
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr8,X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+7)
				move    X:(SP-2),R2
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16FIRDecInit
				ORG	P:
Fdfr16FIRDecInit:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   Y1,X:<mr8
				move    X:(SP),R2
				move    X:(SP-1),R3
				move    X:(SP-2),Y0
				jsr     Fdfr16FIRInit
				moves   X:<mr8,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr8,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+7)
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16FIRDec
				ORG	P:
Fdfr16FIRDec:
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
				moves   R3,X:<mr10
				move    Y0,X:(SP-1)
				move    X:(SP),R0
				move    R0,X:<mr8
				moves   X:<mr8,R2
				moves   X:<mr8,R0
				move    X:(R0+2),Y0
				move    X:(R2+1),X0
				add     X0,Y0
				dec     Y0
				move    Y0,X:(SP-2)
				moves   #0,X:<mr11
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-1),X0
				bhs     _L18
_L7:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),X0
				dec     X0
				move    X0,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+7)
				bne     _L13
				moves   X:<mr8,R2
				nop     
				move    X:(R2+6),X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+7)
				moves   X:<mr10,R0
				inc     X:<mr10
				move    X:(R0),Y0
				move    X:(SP),R2
				jsr     Fdfr16FIRs
				movec   X:(SP-9),R0
				inc     X:(SP-9)
				move    Y0,X:(R0)
				inc     X:<mr11
				bra     _L16
_L13:
				moves   X:<mr10,R0
				inc     X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R3
				movec   R3,R1
				lea     (R3)+
				move    R3,X:(R2+3)
				move    X:(R0),X0
				move    X0,X:(R1)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),X0
				cmp     X:(SP-2),X0
				bls     _L16
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+3)
_L16:
				inc     X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-1),X0
				blo     _L7
_L18:
				moves   X:<mr11,Y0
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


				GLOBAL Fdfr16FIRIntCreate
				ORG	P:
Fdfr16FIRIntCreate:
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
				moves   Y0,X:<mr11
				moves   Y1,X:<mr8
				movei   #8,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L18
				moves   X:<mr8,Y0
				add     X:<mr11,Y0
				moves   X:<mr8,Y1
				dec     Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:<mr9
				moves   X:<mr8,Y0
				moves   X:<mr9,X0
				impy    Y0,X0,X0
				move    X0,X:<mr10
				moves   X:<mr10,Y0
				jsr     FmemMallocIM
				move    X:(SP-1),R0
				nop     
				move    R2,X:(R0)
				moves   X:<mr9,Y0
				jsr     FmemMallocAlignedEM
				move    X:(SP-1),R0
				move    R2,X:(R0+1)
				move    X:(SP-1),R0
				nop     
				tstw    X:(R0)
				beq     _L12
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L12
				move    X:(SP-1),R2
				move    X:(SP),R3
				moves   X:<mr11,Y0
				moves   X:<mr8,Y1
				jsr     Fdfr16FIRIntInit
				bra     _L18
_L12:
				move    X:(SP-1),R0
				nop     
				tstw    X:(R0)
				beq     _L14
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R2
				jsr     FmemFreeIM
_L14:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L16
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemFreeEM
_L16:
				move    X:(SP-1),R2
				jsr     FmemFreeEM
				movei   #0,X:(SP-1)
_L18:
				move    X:(SP-1),R2
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


				GLOBAL Fdfr16FIRIntInit
				ORG	P:
Fdfr16FIRIntInit:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #7,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    Y0,X:(SP-2)
				moves   Y1,X:<mr10
				move    X:(SP),R0
				move    R0,X:<mr11
				tstw    X:(SP)
				bne     _L5
				debug   
_L5:
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				bne     _L7
				debug   
_L7:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				bne     _L9
				debug   
_L9:
				moves   X:<mr10,X0
				moves   X:<mr11,R2
				nop     
				move    X0,X:(R2+6)
				moves   X:<mr10,Y0
				add     X:(SP-2),Y0
				moves   X:<mr10,Y1
				dec     Y0
				jsr     ARTDIVU16UZ
				moves   X:<mr11,R2
				nop     
				move    Y0,X:(R2+7)
				moves   X:<mr11,R2
				moves   X:<mr10,Y0
				move    X:(R2+7),X0
				impy    Y0,X0,X0
				moves   X:<mr11,R2
				nop     
				move    X0,X:(R2+2)
				moves   X:<mr11,R2
				nop     
				move    X:(R2+1),R2
				moves   X:<mr11,R0
				move    X:(R0+7),Y0
				jsr     FmemIsAligned
				moves   X:<mr11,R2
				nop     
				move    Y0,X:(R2+4)
				movei   #0,X:(SP-3)
				moves   X:<mr11,R2
				nop     
				tstw    X:(R2+4)
				beq     _L17
				moves   X:<mr11,R0
				nop     
				move    X:(R0),R2
				jsr     FmemIsIM
				tstw    Y0
				beq     _L17
				movei   #1,X:(SP-3)
_L17:
				move    X:(SP-3),X0
				moves   X:<mr11,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr11,R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr11,R2
				nop     
				move    R0,X:(R2+3)
				movei   #0,X:(SP-6)
				bra     _L23
_L21:
				moves   X:<mr11,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				movei   #0,X0
				move    X0,X:(R0)
				inc     X:(SP-6)
_L23:
				moves   X:<mr11,R2
				move    X:(SP-6),Y0
				move    X:(R2+7),X0
				cmp     X0,Y0
				blo     _L21
				moves   X:<mr11,R0
				moves   X:<mr11,R2
				nop     
				move    X:(R2+7),Y0
				move    X:(R0),X0
				add     X0,Y0
				dec     Y0
				move    Y0,X:(SP-4)
				move    X:(SP-2),X0
				move    X0,X:(SP-6)
				bra     _L39
_L27:
				move    X:(SP-6),X0
				add     X:(SP-1),X0
				dec     X0
				move    X0,X:<mr8
				moves   X:<mr10,Y0
				add     X:(SP-6),Y0
				moves   X:<mr10,Y1
				dec     Y0
				jsr     ARTDIVU16UZ
				move    Y0,X:(SP-5)
				moves   #0,X:<mr9
				bra     _L34
_L31:
				moves   X:<mr8,R0
				movec   X:(SP-4),R1
				dec     X:(SP-4)
				move    X:(R0),X0
				move    X0,X:(R1)
				moves   X:<mr8,X0
				sub     X:<mr10,X0
				move    X0,X:<mr8
				inc     X:<mr9
_L34:
				moves   X:<mr9,X0
				cmp     X:(SP-5),X0
				blo     _L31
				moves   X:<mr11,R2
				move    X:(SP-5),Y0
				move    X:(R2+7),X0
				cmp     X0,Y0
				bhs     _L37
				movec   X:(SP-4),R0
				dec     X:(SP-4)
				movei   #0,X0
				move    X0,X:(R0)
_L37:
				moves   X:<mr11,R2
				nop     
				move    X:(R2+7),X0
				lsl     X0
				add     X:(SP-4),X0
				move    X0,X:(SP-4)
				dec     X:(SP-6)
_L39:
				move    X:(SP-2),Y0
				sub     X:<mr10,Y0
				move    X:(SP-6),X0
				cmp     Y0,X0
				bhi     _L27
				moves   X:<mr11,R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr11,R2
				nop     
				move    R0,X:(R2+3)
				lea     (SP-7)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16FIRIntC
				ORG	P:
Fdfr16FIRIntC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr9
				moves   R3,X:<mr8
				moves   X:<mr9,R3
				moves   #0,X:<mr7
				jmp     _L27
_L5:
				move    X:(R3+3),R0
				move    R0,X:<mr6
				move    X:(R3+7),X0
				move    X:(R3+1),Y1
				add     Y1,X0
				dec     X0
				move    X0,X:<mr4
				moves   X:<mr8,R0
				inc     X:<mr8
				moves   X:<mr6,R1
				inc     X:<mr6
				move    X:(R0),X0
				move    X0,X:(R1)
				moves   X:<mr6,X0
				cmp     X:<mr4,X0
				bls     _L10
				move    X:(R3+1),R0
				move    R0,X:<mr6
_L10:
				move    X:(R3),R0
				move    R0,X:<mr3
				moves   #0,X:<mr5
				bra     _L24
_L13:
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   X:<mr6,R2
				moves   #0,X:<mr2
				bra     _L21
_L17:
				moves   X:<mr3,R0
				inc     X:<mr3
				move    X:(R2),X0
				lea     (R2)+
				movec   X0,B1
				move    X:(R0),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movec   R2,X0
				cmp     X:<mr4,X0
				bls     _L20
				move    X:(R3+1),R2
_L20:
				inc     X:<mr2
_L21:
				moves   X:<mr2,X0
				move    X:(R3+7),Y1
				cmp     Y1,X0
				blo     _L17
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				movec   X:(SP-6),R0
				inc     X:(SP-6)
				move    B,X:(R0)
				inc     X:<mr5
_L24:
				moves   X:<mr5,X0
				move    X:(R3+6),Y1
				cmp     Y1,X0
				blo     _L13
				moves   X:<mr6,R0
				move    R0,X:(R3+3)
				inc     X:<mr7
_L27:
				moves   X:<mr7,X0
				cmp     Y0,X0
				jlo     _L5
				move    X:(R3+6),X0
				impy    Y0,X0,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16IIRCreate
				ORG	P:
Fdfr16IIRCreate:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   Y0,X:<mr8
				movei   #6,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-1)
				tstw    X:(SP-1)
				beq     _L17
				move    X:(SP-1),R0
				moves   X:<mr8,X0
				move    X0,X:(R0)
				moves   X:<mr8,Y0
				lsl     Y0
				jsr     FmemMallocAlignedEM
				move    X:(SP-1),R0
				move    R2,X:(R0+2)
				movei   #5,Y0
				moves   X:<mr8,X0
				impy    Y0,X0,Y0
				jsr     FmemMallocIM
				move    X:(SP-1),R0
				move    R2,X:(R0+1)
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L11
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+2)
				beq     _L11
				move    X:(SP-1),R2
				move    X:(SP),R3
				moves   X:<mr8,Y0
				jsr     Fdfr16IIRInit
				bra     _L17
_L11:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+1)
				beq     _L13
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemFreeIM
_L13:
				move    X:(SP-1),R2
				nop     
				tstw    X:(R2+2)
				beq     _L15
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),R2
				jsr     FmemFreeEM
_L15:
				move    X:(SP-1),R2
				jsr     FmemFreeEM
				movei   #0,X:(SP-1)
_L17:
				move    X:(SP-1),R2
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16IIRInit
				ORG	P:
Fdfr16IIRInit:
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
				moves   R3,X:<mr9
				moves   Y0,X:<mr11
				tstw    X:(SP)
				bne     _L4
				debug   
_L4:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				bne     _L6
				debug   
_L6:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+2)
				bne     _L8
				debug   
_L8:
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:(SP-1)
				move    X:(SP),R0
				moves   X:<mr11,X0
				move    X0,X:(R0)
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R2
				moves   X:<mr11,Y0
				lsl     Y0
				jsr     FmemIsAligned
				move    X:(SP),R2
				nop     
				move    Y0,X:(R2+4)
				moves   #0,X:<mr10
				move    X:(SP),R2
				nop     
				tstw    X:(R2+4)
				beq     _L15
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemIsIM
				tstw    Y0
				beq     _L15
				moves   #1,X:<mr10
_L15:
				moves   X:<mr10,X0
				move    X:(SP),R2
				nop     
				move    X0,X:(R2+5)
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+3)
				moves   #0,X:<mr8
				bra     _L21
_L19:
				move    X:(SP),R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				movei   #0,X0
				move    X0,X:(R0)
				inc     X:<mr8
_L21:
				move    X:(SP),R0
				nop     
				move    X:(R0),Y0
				lsl     Y0
				moves   X:<mr8,X0
				cmp     Y0,X0
				blo     _L19
				moves   #0,X:<mr8
				bra     _L26
_L24:
				moves   X:<mr9,R0
				inc     X:<mr9
				movec   X:(SP-1),R1
				inc     X:(SP-1)
				move    X:(R0),X0
				move    X0,X:(R1)
				inc     X:<mr8
_L26:
				move    X:(SP),R0
				movei   #5,Y0
				move    X:(R0),X0
				impy    Y0,X0,Y0
				moves   X:<mr8,X0
				cmp     Y0,X0
				blo     _L24
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				move    X:(SP),R2
				nop     
				move    R0,X:(R2+3)
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


				GLOBAL Fdfr16IIRDestroy
				ORG	P:
Fdfr16IIRDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L8
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				beq     _L5
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R2
				jsr     FmemFreeIM
_L5:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+2)
				beq     _L7
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R2
				jsr     FmemFreeEM
_L7:
				move    X:(SP),R2
				jsr     FmemFreeEM
_L8:
				lea     (SP)-
				rts     


				GLOBAL Fdfr16IIRC
				ORG	P:
Fdfr16IIRC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #10,N
				lea     (SP)+N
				moves   R2,X:<mr8
				move    R3,X:(SP)
				move    Y0,X:(SP-1)
				movei   #32767,X0
				cmp     X:(SP-1),X0
				bhs     _L4
				movei   #-1,Y0
				jmp     _L32
_L4:
				movei   #0,X:(SP-9)
				move    X:(SP-9),X0
				cmp     X:(SP-1),X0
				jhs     _L30
_L6:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),R0
				move    R0,X:<mr9
				movei   #0,X:(SP-5)
				movei   #0,X:(SP-4)
				move    X:(SP),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(SP)
				move    X:(R0),X0
				move    X0,X:(SP-6)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+3)
				movei   #0,X:(SP-8)
				jmp     _L26
_L12:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				move    X:(R0),X0
				move    X0,X:<mr10
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)-
				move    R1,X:(R2+3)
				move    X:(R0),X0
				move    X0,X:(SP-7)
				moves   X:<mr9,R0
				inc     X:<mr9
				moves   X:<mr10,Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				moves   X:<mr9,R0
				inc     X:<mr9
				move    X:(SP-7),Y0
				move    X:(R0),X0
				move    X:(SP-4),B
				move    X:(SP-5),B0
				mac     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP-6),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				rnd     B
				move    B,X:<mr11
				moves   X:<mr9,R0
				inc     X:<mr9
				moves   X:<mr11,Y0
				move    X:(R0),X0
				mpy     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				moves   X:<mr9,R0
				inc     X:<mr9
				moves   X:<mr10,Y0
				move    X:(R0),X0
				move    X:(SP-4),B
				move    X:(SP-5),B0
				mac     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				moves   X:<mr9,R0
				inc     X:<mr9
				move    X:(SP-7),Y0
				move    X:(R0),X0
				move    X:(SP-4),B
				move    X:(SP-5),B0
				mac     Y0,X0,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				moves   X:<mr11,X0
				move    X0,X:(R0)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+3),R1
				movec   R1,R0
				lea     (R1)+
				move    R1,X:(R2+3)
				moves   X:<mr10,X0
				move    X0,X:(R0)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				rnd     B
				move    B,X:(SP-6)
				inc     X:(SP-8)
_L26:
				moves   X:<mr8,R0
				move    X:(SP-8),Y0
				move    X:(R0),X0
				cmp     X0,Y0
				jlo     _L12
				movec   X:(SP-16),R0
				inc     X:(SP-16)
				move    X:(SP-6),X0
				move    X0,X:(R0)
				inc     X:(SP-9)
				move    X:(SP-9),X0
				cmp     X:(SP-1),X0
				jlo     _L6
_L30:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    R0,X:(R2+3)
				movei   #0,Y0
_L32:
				lea     (SP-10)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16AutoCorrC
				ORG	P:
Fdfr16AutoCorrC:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   R3,X:<mr8
				moves   Y1,X:<mr5
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				moves   #0,X:<mr7
				movei   #32767,X0
				cmp     X:(SP-5),X0
				blo     _L7
				cmp     #3,Y0
				bhs     _L7
				moves   X:<mr5,X0
				lsl     X0
				dec     X0
				cmp     #32767,X0
				bls     _L8
_L7:
				movei   #-1,Y0
				jmp     _L65
_L8:
				moves   X:<mr5,X0
				dec     X0
				move    X0,X:<mr3
				tstw    X:<mr3
				jlt     _L36
_L10:
				cmp     #2,Y0
				beq     _L20
				cmp     #1,Y0
				beq     _L16
				tstw    Y0
				bne     _L24
_L14:
				moves   #32767,X:<mr6
				bra     _L24
_L16:
				movei   #1,B
				moves   X:<mr5,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L18
				neg     B
_L18:
				movec   B0,X0
				move    X0,X:<mr6
				bra     _L24
_L20:
				move    X:(SP-5),X0
				sub     X:<mr3,X0
				move    X0,X:<mr6
				movei   #1,B
				moves   X:<mr6,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L23
				neg     B
_L23:
				movec   B0,X0
				move    X0,X:<mr6
_L24:
				moves   #0,X:<mr2
				movec   R2,X0
				add     X:<mr3,X0
				add     X:<mr2,X0
				movec   X0,R3
				bra     _L30
_L27:
				moves   X:<mr2,N
				move    X:(R2+N),B1
				move    X:(R3),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				lea     (R3)+
				inc     X:<mr2
_L30:
				moves   X:<mr3,X0
				inc     X0
				moves   X:<mr5,Y1
				sub     X0,Y1
				moves   X:<mr2,X0
				cmp     Y1,X0
				bls     _L27
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				moves   X:<mr6,X0
				movec   B1,Y1
				mpyr    Y1,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				moves   X:<mr7,N
				move    X0,X:(R0+N)
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr7
				dec     X:<mr3
				tstw    X:<mr3
				jge     _L10
_L36:
				moves   #1,X:<mr3
				jmp     _L63
_L38:
				cmp     #2,Y0
				beq     _L48
				cmp     #1,Y0
				beq     _L44
				tstw    Y0
				bne     _L52
_L42:
				moves   #32767,X:<mr6
				bra     _L52
_L44:
				movei   #1,B
				moves   X:<mr5,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L46
				neg     B
_L46:
				movec   B0,X0
				move    X0,X:<mr6
				bra     _L52
_L48:
				move    X:(SP-5),X0
				sub     X:<mr3,X0
				move    X0,X:<mr6
				movei   #1,B
				moves   X:<mr6,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L51
				neg     B
_L51:
				movec   B0,X0
				move    X0,X:<mr6
_L52:
				moves   #0,X:<mr2
				movec   R2,X0
				add     X:<mr3,X0
				add     X:<mr2,X0
				move    X0,X:<mr4
				bra     _L58
_L55:
				moves   X:<mr4,R0
				moves   X:<mr2,N
				move    X:(R2+N),B1
				move    X:(R0),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				inc     X:<mr4
				inc     X:<mr2
_L58:
				moves   X:<mr3,X0
				inc     X0
				moves   X:<mr5,Y1
				sub     X0,Y1
				moves   X:<mr2,X0
				cmp     Y1,X0
				bls     _L55
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				moves   X:<mr6,X0
				movec   B1,Y1
				mpyr    Y1,X0,B
				movec   B1,X0
				moves   X:<mr8,R0
				moves   X:<mr7,N
				move    X0,X:(R0+N)
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr7
				inc     X:<mr3
_L63:
				moves   X:<mr3,X0
				cmp     X:<mr5,X0
				jlo     _L38
				movei   #0,Y0
_L65:
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fdfr16CorrC
				ORG	P:
Fdfr16CorrC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   R2,X:<mr7
				moves   R3,X:<mr6
				moves   Y1,X:<mr8
				moves   #0,X:<mr9
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP-8),X0
				add     X:<mr8,X0
				dec     X0
				cmp     #32767,X0
				bls     _L6
				movei   #-1,Y0
				jmp     _L83
_L6:
				moves   X:<mr8,X0
				cmp     X:(SP-8),X0
				bhi     _L8
				moves   X:<mr8,X0
				bra     _L9
_L8:
				move    X:(SP-8),X0
_L9:
				move    X0,X:<mr10
				moves   X:<mr8,X0
				dec     X0
				move    X0,X:<mr5
				tstw    X:<mr5
				jle     _L46
_L12:
				moves   X:<mr5,X0
				inc     X0
				moves   X:<mr8,Y1
				sub     X0,Y1
				moves   X:<mr10,X0
				dec     X0
				cmp     X0,Y1
				bls     _L14
				moves   X:<mr10,X0
				dec     X0
				bra     _L15
_L14:
				moves   X:<mr5,Y1
				inc     Y1
				moves   X:<mr8,X0
				sub     Y1,X0
_L15:
				move    X0,X:<mr4
				cmp     #2,Y0
				beq     _L28
				cmp     #1,Y0
				beq     _L22
				tstw    Y0
				bne     _L34
_L20:
				moves   #32767,X:<mr3
				bra     _L34
_L22:
				move    X:(SP-8),X0
				add     X:<mr8,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     #1,X0
				move    X0,X:<mr3
				movei   #1,B
				moves   X:<mr3,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L26
				neg     B
_L26:
				movec   B0,X0
				move    X0,X:<mr3
				bra     _L34
_L28:
				move    X:(SP-8),X0
				add     X:<mr8,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     #1,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     X:<mr5,X0
				move    X0,X:<mr3
				movei   #1,B
				moves   X:<mr3,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L33
				neg     B
_L33:
				movec   B0,X0
				move    X0,X:<mr3
_L34:
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				bgt     _L41
				moves   X:<mr5,X0
				add     X:<mr7,X0
				add     X:<mr2,X0
				movec   X0,R2
_L37:
				moves   X:<mr6,R0
				moves   X:<mr2,N
				move    X:(R0+N),B1
				move    X:(R2),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				lea     (R2)+
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				ble     _L37
_L41:
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				moves   X:<mr3,X0
				movec   B1,Y1
				mpyr    Y1,X0,B
				movec   B1,X0
				move    X:(SP-7),R0
				moves   X:<mr9,N
				move    X0,X:(R0+N)
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr9
				dec     X:<mr5
				tstw    X:<mr5
				jgt     _L12
_L46:
				moves   #0,X:<mr5
				jmp     _L81
_L48:
				moves   X:<mr5,X0
				inc     X0
				move    X:(SP-8),Y1
				sub     X0,Y1
				moves   X:<mr10,X0
				dec     X0
				cmp     X0,Y1
				bls     _L50
				moves   X:<mr10,X0
				dec     X0
				bra     _L51
_L50:
				moves   X:<mr5,Y1
				inc     Y1
				move    X:(SP-8),X0
				sub     Y1,X0
_L51:
				move    X0,X:<mr4
				cmp     #2,Y0
				beq     _L64
				cmp     #1,Y0
				beq     _L58
				tstw    Y0
				bne     _L70
_L56:
				moves   #32767,X:<mr3
				bra     _L70
_L58:
				move    X:(SP-8),X0
				add     X:<mr8,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     #1,X0
				move    X0,X:<mr3
				movei   #1,B
				moves   X:<mr3,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L62
				neg     B
_L62:
				movec   B0,X0
				move    X0,X:<mr3
				bra     _L70
_L64:
				move    X:(SP-8),X0
				add     X:<mr8,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     #1,X0
				move    X0,X:<mr3
				moves   X:<mr3,X0
				sub     X:<mr5,X0
				move    X0,X:<mr3
				movei   #1,B
				moves   X:<mr3,X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L69
				neg     B
_L69:
				movec   B0,X0
				move    X0,X:<mr3
_L70:
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				bgt     _L77
				moves   X:<mr5,X0
				add     X:<mr6,X0
				add     X:<mr2,X0
				movec   X0,R3
_L73:
				moves   X:<mr7,R0
				moves   X:<mr2,N
				move    X:(R0+N),B1
				move    X:(R3),Y1
				move    X:(SP),A
				move    X:(SP-1),A0
				mac     Y1,B1,A
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				lea     (R3)+
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     X:<mr4,X0
				ble     _L73
_L77:
				move    X:(SP),B
				move    X:(SP-1),B0
				rnd     B
				moves   X:<mr3,X0
				movec   B1,Y1
				mpyr    Y1,X0,B
				movec   B1,X0
				move    X:(SP-7),R0
				moves   X:<mr9,N
				move    X0,X:(R0+N)
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				inc     X:<mr9
				inc     X:<mr5
_L81:
				moves   X:<mr5,X0
				cmp     X:(SP-8),X0
				jlo     _L48
				movei   #0,Y0
_L83:
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

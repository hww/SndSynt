
				SECTION basic_op
				include "asmdef.h"
				GLOBAL Fsature
				ORG	P:
Fsature:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #0,A
				movei   #32767,A0
				cmp     A,B
				ble     _L6
				movei   #1,X:FOverflow
				moves   #32767,X:<mr8
				bra     _L12
_L6:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #-1,A
				movei   #-32768,A0
				cmp     A,B
				bge     _L10
				movei   #1,X:FOverflow
				moves   #-32768,X:<mr8
				bra     _L12
_L10:
				movei   #0,X:FOverflow
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     Fextract_l
				move    Y0,X:<mr8
_L12:
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fadd
				ORG	P:
Fadd:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP-1),B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP),A
				movec   A1,A0
				movec   A2,A1
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     Fsature
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fsub
				ORG	P:
Fsub:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP-1),B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP),A
				movec   A1,A0
				movec   A2,A1
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     Fsature
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fabs_s
				ORG	P:
Fabs_s:
				cmp     #-32768,Y0
				bne     _L4
				moves   #32767,X:<mr2
				bra     _L8
_L4:
				tstw    Y0
				bge     _L7
				movec   Y0,B
				neg     B
				movec   B1,X0
				move    X0,X:<mr2
				bra     _L8
_L7:
				move    Y0,X:<mr2
_L8:
				moves   X:<mr2,Y0
				rts     


				GLOBAL Fshl
				ORG	P:
Fshl:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   Y0,X:<mr10
				moves   Y1,X:<mr9
				tstw    X:<mr9
				bge     _L5
				move    X:<mr9,B
				neg     B
				movec   B1,Y1
				moves   X:<mr10,Y0
				jsr     Fshr
				move    Y0,X:<mr8
				bra     _L16
_L5:
				moves   X:<mr9,Y0
				movei   #0,A
				movei   #1,A0
				jsr     ARTLSHFTU32U
				move    X:<mr10,B
				movec   B1,B0
				movec   B2,B1
				push    A0
				push    A1
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr9,X0
				cmp     #15,X0
				ble     _L8
				tstw    X:<mr10
				bne     _L9
_L8:
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   B0,X0
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				move    X:(SP),A
				move    X:(SP-1),A0
				cmp     B,A
				beq     _L15
_L9:
				movei   #1,X:FOverflow
				tstw    X:<mr10
				ble     _L12
				movei   #32767,X0
				bra     _L13
_L12:
				movei   #-32768,X0
_L13:
				move    X0,X:<mr8
				bra     _L16
_L15:
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     Fextract_l
				move    Y0,X:<mr8
_L16:
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fshr
				ORG	P:
Fshr:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				moves   Y0,X:<mr10
				moves   Y1,X:<mr9
				tstw    X:<mr9
				bge     _L5
				move    X:<mr9,B
				neg     B
				movec   B1,Y1
				moves   X:<mr10,Y0
				jsr     Fshl
				move    Y0,X:<mr8
				bra     _L15
_L5:
				moves   X:<mr9,X0
				cmp     #15,X0
				blt     _L11
				tstw    X:<mr10
				bge     _L8
				movei   #-1,X0
				bra     _L9
_L8:
				movei   #0,X0
_L9:
				move    X0,X:<mr8
				bra     _L15
_L11:
				tstw    X:<mr10
				bge     _L14
				moves   X:<mr10,Y0
				not     Y0
				moves   X:<mr9,X0
				asrr    Y0,X0,X0
				not     X0
				move    X0,X:<mr8
				bra     _L15
_L14:
				moves   X:<mr9,X0
				moves   X:<mr10,Y0
				asrr    Y0,X0,X0
				move    X0,X:<mr8
_L15:
				moves   X:<mr8,Y0
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fmult
				ORG	P:
Fmult:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP-1),Y0
				move    X:(SP),X0
				mpy     Y0,X0,B
				asr     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #-1,B
				movei   #-32768,B0
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				and     B1,Y1
				movec   B0,B1
				and     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
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
				asr     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #1,B
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				and     B1,Y1
				movec   B0,B1
				and     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				tst     B
				beq     _L6
				orc     #65535,X:(SP-2)
_L6:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     Fsature
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_mult
				ORG	P:
FL_mult:
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				bfclr   #16,OMR
				move    X:(SP-1),Y0
				move    X:(SP),X0
				mpy     Y0,X0,B
				asr     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #16384,A
				cmp     A,B
				beq     _L7
				movei   #0,B
				movei   #2,B0
				push    B0
				push    B1
				move    X:(SP-4),A
				move    X:(SP-5),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L9
_L7:
				movei   #1,X:FOverflow
				movei   #65535,X:(SP-3)
				movei   #32767,X:(SP-2)
_L9:
				bfset   #16,OMR
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL Fnegate
				ORG	P:
Fnegate:
				cmp     #-32768,Y0
				bne     _L3
				movei   #32767,X0
				bra     _L4
_L3:
				movec   Y0,B
				neg     B
				movec   B1,X0
_L4:
				move    X0,X:<mr2
				moves   X:<mr2,Y0
				rts     


				GLOBAL Fextract_h
				ORG	P:
Fextract_h:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,B0
				movec   B0,X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fextract_l
				ORG	P:
Fextract_l:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movec   B0,X0
				move    X0,X:<mr2
				moves   X:<mr2,Y0
				lea     (SP-2)
				rts     


				GLOBAL Fround
				ORG	P:
Fround:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movei   #0,B
				movei   #-32768,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add
				lea     (SP-2)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     Fextract_h
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_mac
				ORG	P:
FL_mac:
				movei   #8,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_mult
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add
				lea     (SP-2)
				move    A1,X:(SP-6)
				move    A0,X:(SP-7)
				move    X:(SP-6),A
				move    X:(SP-7),A0
				lea     (SP-8)
				rts     


				GLOBAL FL_msu
				ORG	P:
FL_msu:
				movei   #8,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_mult
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_sub
				lea     (SP-2)
				move    A1,X:(SP-6)
				move    A0,X:(SP-7)
				move    X:(SP-6),A
				move    X:(SP-7),A0
				lea     (SP-8)
				rts     


				GLOBAL FL_macNs
				ORG	P:
FL_macNs:
				movei   #6,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_mult
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add_c
				lea     (SP-2)
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				rts     


				GLOBAL FL_msuNs
				ORG	P:
FL_msuNs:
				movei   #6,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_mult
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),B
				move    X:(SP-5),B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_sub_c
				lea     (SP-2)
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				rts     


				GLOBAL FL_add
				ORG	P:
FL_add:
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				movei   #-32768,A
				movec   B1,Y1
				movec   B0,Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				bne     _L10
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				movei   #-32768,A
				movec   B1,Y1
				movec   B0,Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				beq     _L10
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L7
				movei   #-32768,B
				bra     _L8
_L7:
				movei   #32767,B
				movei   #-1,B0
_L8:
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #1,X:FOverflow
_L10:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL FL_sub
				ORG	P:
FL_sub:
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				movei   #-32768,A
				movec   B1,Y1
				movec   B0,Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				beq     _L10
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				movei   #-32768,A
				movec   B1,Y1
				movec   B0,Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				beq     _L10
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L7
				movei   #-32768,B
				bra     _L8
_L7:
				movei   #32767,B
				movei   #-1,B0
_L8:
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #1,X:FOverflow
_L10:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL FL_add_c
				ORG	P:
FL_add_c:
				movei   #6,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   #0,X:<mr2
				move    X:(SP-8),B
				move    X:(SP-9),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				add     A,B
				move    X:FCarry,A
				movec   A1,A0
				movec   A2,A1
				add     A,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP-8),B
				move    X:(SP-9),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				ble     _L11
				move    X:(SP-8),B
				move    X:(SP-9),B0
				tst     B
				ble     _L11
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				bge     _L11
				movei   #1,X:FOverflow
				moves   #0,X:<mr2
				bra     _L24
_L11:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L17
				move    X:(SP-8),B
				move    X:(SP-9),B0
				tst     B
				bge     _L17
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				ble     _L17
				movei   #1,X:FOverflow
				moves   #1,X:<mr2
				bra     _L24
_L17:
				move    X:(SP-8),B
				move    X:(SP-9),B0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				tst     B
				bge     _L22
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				ble     _L22
				movei   #0,X:FOverflow
				moves   #1,X:<mr2
				bra     _L24
_L22:
				movei   #0,X:FOverflow
				moves   #0,X:<mr2
_L24:
				tstw    X:FCarry
				beq     _L34
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #32767,A
				movei   #-1,A0
				cmp     A,B
				bne     _L29
				movei   #1,X:FOverflow
				moves   X:<mr2,X0
				move    X0,X:FCarry
				bra     _L35
_L29:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #-1,A
				movei   #-1,A0
				cmp     A,B
				bne     _L32
				movei   #1,X:FCarry
				bra     _L35
_L32:
				moves   X:<mr2,X0
				move    X0,X:FCarry
				bra     _L35
_L34:
				moves   X:<mr2,X0
				move    X0,X:FCarry
_L35:
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				rts     


				GLOBAL FL_sub_c
				ORG	P:
FL_sub_c:
				move    X:<mr8,N
				push    N
				movei   #6,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   #0,X:<mr8
				tstw    X:FCarry
				beq     _L13
				movei   #0,X:FCarry
				move    X:(SP-9),B
				move    X:(SP-10),B0
				movei   #-32768,A
				cmp     A,B
				beq     _L8
				move    X:(SP-9),B
				move    X:(SP-10),B0
				neg     B
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add_c
				lea     (SP-2)
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				jmp     _L36
_L8:
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				sub     B,A
				move    A1,X:(SP-4)
				move    A0,X:(SP-5)
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				jle     _L36
				movei   #1,X:FOverflow
				movei   #0,X:FCarry
				jmp     _L36
_L13:
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				sub     B,A
				movei   #-1,B
				movei   #-1,B0
				add     A,B
				move    B1,X:(SP-4)
				move    B0,X:(SP-5)
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				sub     B,A
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				bge     _L21
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				ble     _L21
				move    X:(SP-9),B
				move    X:(SP-10),B0
				tst     B
				bge     _L21
				movei   #1,X:FOverflow
				moves   #0,X:<mr8
				bra     _L31
_L21:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				ble     _L27
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L27
				move    X:(SP-9),B
				move    X:(SP-10),B0
				tst     B
				ble     _L27
				movei   #1,X:FOverflow
				moves   #1,X:<mr8
				bra     _L31
_L27:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				tst     B
				ble     _L31
				move    X:(SP-9),B
				move    X:(SP-10),B0
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				eor     B1,Y1
				movec   B0,B1
				eor     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				tst     B
				ble     _L31
				movei   #0,X:FOverflow
				moves   #1,X:<mr8
_L31:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #-32768,A
				cmp     A,B
				bne     _L35
				movei   #1,X:FOverflow
				moves   X:<mr8,X0
				move    X0,X:FCarry
				bra     _L36
_L35:
				moves   X:<mr8,X0
				move    X0,X:FCarry
_L36:
				move    X:(SP-4),A
				move    X:(SP-5),A0
				lea     (SP-6)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_negate
				ORG	P:
FL_negate:
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #-32768,A
				cmp     A,B
				bne     _L4
				movei   #32767,B
				movei   #-1,B0
				bra     _L5
_L4:
				move    X:(SP),A
				move    X:(SP-1),A0
				neg     A
				tfr     A,B
_L5:
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL Fmult_r
				ORG	P:
Fmult_r:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP-1),Y0
				move    X:(SP),X0
				mpy     Y0,X0,B
				asr     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #0,B
				movei   #16384,B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				andc    #32768,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
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
				asr     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				movei   #1,B
				move    X:(SP-2),Y1
				move    X:(SP-3),Y0
				and     B1,Y1
				movec   B0,B1
				and     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				tst     B
				beq     _L8
				orc     #65535,X:(SP-2)
_L8:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     Fsature
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_shl
				ORG	P:
FL_shl:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   Y0,X:<mr8
				movei   #0,Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:<mr9
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				tstw    X:<mr8
				bgt     _L7
				move    X:<mr8,B
				neg     B
				movec   B1,Y0
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FL_shr
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L20
_L7:
				tstw    X:<mr8
				ble     _L20
_L8:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #16383,A
				movei   #-1,A0
				cmp     A,B
				ble     _L12
				movei   #1,X:FOverflow
				movei   #65535,X:(SP-3)
				movei   #32767,X:(SP-2)
				bra     _L20
_L12:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #-16384,A
				cmp     A,B
				bge     _L16
				movei   #1,X:FOverflow
				movei   #0,X:(SP-3)
				movei   #32768,X:(SP-2)
				bra     _L20
_L16:
				movei   #0,B
				movei   #2,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     ARTMPYS32U
				pop     
				pop     
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				dec     X:<mr8
				tstw    X:<mr8
				bgt     _L8
_L20:
				moves   X:<mr9,Y0
				jsr     FarchGetSetSaturationMode
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_shr
				ORG	P:
FL_shr:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   Y0,X:<mr8
				movei   #0,Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:<mr9
				tstw    X:<mr8
				bge     _L6
				move    X:<mr8,B
				neg     B
				movec   B1,Y0
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     FL_shl
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L16
_L6:
				moves   X:<mr8,X0
				cmp     #31,X0
				blt     _L12
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L9
				movei   #-1,X0
				bra     _L10
_L9:
				movei   #0,X0
_L10:
				movec   X0,B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				bra     _L16
_L12:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L15
				moves   X:<mr8,Y0
				move    X:(SP),X0
				not     X0
				movec   X0,B
				movec   X:(SP-1),B0
				notc    B0
				tfr     B,A
				jsr     ARTRSHFTS32U
				notc    A1
				notc    A0
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				bra     _L16
_L15:
				moves   X:<mr8,Y0
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     ARTRSHFTS32U
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
_L16:
				moves   X:<mr9,Y0
				jsr     FarchGetSetSaturationMode
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fshr_r
				ORG	P:
Fshr_r:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				moves   Y0,X:<mr10
				moves   Y1,X:<mr9
				moves   X:<mr9,X0
				cmp     #15,X0
				ble     _L5
				moves   #0,X:<mr8
				bra     _L9
_L5:
				moves   X:<mr10,Y0
				moves   X:<mr9,Y1
				jsr     Fshr
				move    Y0,X:<mr8
				tstw    X:<mr9
				ble     _L9
				moves   X:<mr9,X0
				dec     X0
				movei   #1,Y0
				lsll    Y0,X0,Y0
				moves   X:<mr10,X0
				and     X0,Y0
				tstw    Y0
				beq     _L9
				inc     X:<mr8
_L9:
				moves   X:<mr8,Y0
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fmac_r
				ORG	P:
Fmac_r:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP),A
				move    X:(SP-1),A0
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_mac
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movei   #0,B
				movei   #-32768,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add
				lea     (SP-2)
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     Fextract_h
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fmsu_r
				ORG	P:
Fmsu_r:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    Y0,X:(SP-2)
				move    Y1,X:(SP-3)
				move    X:(SP),A
				move    X:(SP-1),A0
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     FL_msu
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movei   #0,B
				movei   #-32768,B0
				push    B0
				push    B1
				move    X:(SP-2),A
				move    X:(SP-3),A0
				jsr     FL_add
				lea     (SP-2)
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),A
				move    X:(SP-1),A0
				jsr     Fextract_h
				move    Y0,X:<mr8
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_deposit_h
				ORG	P:
FL_deposit_h:
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    X:(SP),B
				movec   B1,B0
				move    B0,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),A
				move    X:(SP-2),A0
				lea     (SP-3)
				rts     


				GLOBAL FL_deposit_l
				ORG	P:
FL_deposit_l:
				movei   #2,N
				lea     (SP)+N
				movec   Y0,B
				movec   B1,B0
				movec   B2,B1
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-2)
				rts     


				GLOBAL FL_shr_r
				ORG	P:
FL_shr_r:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   Y0,X:<mr8
				movei   #0,Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:<mr9
				moves   X:<mr8,X0
				cmp     #31,X0
				ble     _L6
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				bra     _L10
_L6:
				move    X:(SP),A
				move    X:(SP-1),A0
				moves   X:<mr8,Y0
				jsr     FL_shr
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				tstw    X:<mr8
				ble     _L10
				moves   X:<mr8,Y0
				dec     Y0
				movei   #0,A
				movei   #1,A0
				jsr     ARTLSHFTU32U
				move    X:(SP),Y1
				move    X:(SP-1),Y0
				and     A1,Y1
				movec   A0,A1
				and     A1,Y0
				tfr     Y1,A
				movec   Y0,A0
				tst     A
				beq     _L10
				movei   #0,B
				movei   #1,B0
				move    X:(SP-2),A
				move    X:(SP-3),A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
_L10:
				moves   X:<mr9,Y0
				jsr     FarchGetSetSaturationMode
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FL_abs
				ORG	P:
FL_abs:
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #-32768,A
				cmp     A,B
				bne     _L5
				movei   #65535,X:(SP-3)
				movei   #32767,X:(SP-2)
				bra     _L9
_L5:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L8
				move    X:(SP),B
				move    X:(SP-1),B0
				neg     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				bra     _L9
_L8:
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
_L9:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL FL_sat
				ORG	P:
FL_sat:
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				tstw    X:FOverflow
				beq     _L10
				tstw    X:FCarry
				beq     _L7
				movei   #0,X:(SP-3)
				movei   #32768,X:(SP-2)
				bra     _L8
_L7:
				movei   #65535,X:(SP-3)
				movei   #32767,X:(SP-2)
_L8:
				movei   #0,X:FCarry
				movei   #0,X:FOverflow
_L10:
				move    X:(SP-2),A
				move    X:(SP-3),A0
				lea     (SP-4)
				rts     


				GLOBAL Fnorm_s
				ORG	P:
Fnorm_s:
				tstw    Y0
				bne     _L4
				moves   #0,X:<mr2
				bra     _L14
_L4:
				cmp     #-1,Y0
				bne     _L7
				moves   #15,X:<mr2
				bra     _L14
_L7:
				tstw    Y0
				bge     _L9
				not     Y0
_L9:
				moves   #0,X:<mr2
				cmp     #16384,Y0
				bge     _L14
_L11:
				asl     Y0
				inc     X:<mr2
				cmp     #16384,Y0
				blt     _L11
_L14:
				moves   X:<mr2,Y0
				rts     


				GLOBAL Fdiv_s
				ORG	P:
Fdiv_s:
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
				moves   Y0,X:<mr11
				moves   Y1,X:<mr10
				moves   #0,X:<mr8
				moves   X:<mr11,X0
				cmp     X:<mr10,X0
				bgt     _L6
				tstw    X:<mr11
				blt     _L6
				tstw    X:<mr10
				bge     _L8
_L6:
				moves   X:<mr10,X0
				push    X0
				moves   X:<mr11,X0
				push    X0
				movei   #S334,R0
				push    R0
				jsr     Fprintf
				lea     (SP-3)
				movei   #0,Y0
				jsr     Fexit
_L8:
				tstw    X:<mr10
				bne     _L11
				movei   #S335,R0
				push    R0
				jsr     Fprintf
				pop     
				movei   #0,Y0
				jsr     Fexit
_L11:
				tstw    X:<mr11
				bne     _L14
				moves   #0,X:<mr8
				jmp     _L28
_L14:
				moves   X:<mr11,X0
				cmp     X:<mr10,X0
				bne     _L17
				moves   #32767,X:<mr8
				bra     _L28
_L17:
				moves   X:<mr11,Y0
				jsr     FL_deposit_l
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				moves   X:<mr10,Y0
				jsr     FL_deposit_l
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     #15,X0
				bge     _L28
_L21:
				moves   X:<mr8,X0
				asl     X0
				move    X0,X:<mr8
				move    X:(SP-2),B
				move    X:(SP-3),B0
				asl     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    X:(SP),A
				move    X:(SP-1),A0
				cmp     A,B
				blt     _L26
				move    X:(SP),B
				move    X:(SP-1),B0
				push    B0
				push    B1
				move    X:(SP-4),A
				move    X:(SP-5),A0
				jsr     FL_sub
				lea     (SP-2)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				moves   X:<mr8,Y0
				movei   #1,Y1
				jsr     Fadd
				move    Y0,X:<mr8
_L26:
				inc     X:<mr9
				moves   X:<mr9,X0
				cmp     #15,X0
				blt     _L21
_L28:
				moves   X:<mr8,Y0
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


				GLOBAL Fnorm_l
				ORG	P:
Fnorm_l:
				move    X:<mr8,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bne     _L5
				moves   #0,X:<mr8
				bra     _L17
_L5:
				move    X:(SP),B
				move    X:(SP-1),B0
				movei   #-1,A
				movei   #-1,A0
				cmp     A,B
				bne     _L8
				moves   #31,X:<mr8
				bra     _L17
_L8:
				move    X:(SP),B
				move    X:(SP-1),B0
				tst     B
				bge     _L10
				move    X:(SP),X0
				not     X0
				movec   X0,B
				movec   X:(SP-1),B0
				notc    B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
_L10:
				moves   #0,X:<mr8
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #16384,A
				cmp     A,B
				bge     _L16
_L13:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				asl     B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				inc     X:<mr8
				move    X:(SP-2),B
				move    X:(SP-3),B0
				movei   #16384,A
				cmp     A,B
				blt     _L13
_L16:
				move    X:(SP-2),B
				move    X:(SP-3),B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
_L17:
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
FOverflow       BSC			1
FCarry          BSC			1
S334            DC			'D','i','v','i','s','i','o','n'
				DC			' ','E','r','r','o','r',' ','v'
				DC			'a','r','1','=','%','d',' ',' '
				DC			'v','a','r','2','=','%','d',10
				DC			0
S335            DC			'D','i','v','i','s','i','o','n'
				DC			' ','b','y',' ','0',',',' ','F'
				DC			'a','t','a','l',' ','e','r','r'
				DC			'o','r',' ',10,0

				ENDSEC
				END

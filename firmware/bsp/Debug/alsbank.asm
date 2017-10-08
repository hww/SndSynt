
				SECTION alsbank
				include "asmdef.h"
				ORG	P:
Fsnd_idx_wave:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				bftstl  #32768,X:(R2+5)
				bhs     _L6
				move    X:(SP),R0
				move    R0,X:(SP-1)
				move    X:(R0+1),B
				move    X:(R0),B0
				movei   #0,B2
				asr     B
				move    X:(SP-1),R0
				move    B1,X:(R0+1)
				move    B0,X:(R0)
				move    X:(SP),R2
				nop     
				move    X:(R2+3),B
				move    X:(R2+2),B0
				movei   #0,B2
				asr     B
				move    X:(SP),R2
				nop     
				move    B1,X:(R2+3)
				move    B0,X:(R2+2)
				move    X:(SP),R2
				nop     
				orc     #32768,X:(R2+5)
_L6:
				lea     (SP-2)
				rts     


				ORG	P:
Fsnd_idx_sound:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr9
				moves   X:<mr9,R2
				nop     
				bftstl  #32768,X:(R2+7)
				bhs     _L14
				moves   X:<mr9,R2
				movei   #258,Y0
				move    X:(R2+5),X0
				impy    Y0,X0,X0
				moves   X:<mr9,R2
				nop     
				move    X0,X:(R2+5)
				moves   X:<mr9,R0
				move    R0,X:(SP)
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     #4,X0
				bge     _L12
_L7:
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				beq     _L9
				move    X:(SP),R0
				move    X:Fctl_org,Y0
				move    X:(R0),X0
				add     X0,Y0
				move    Y0,X:(R0)
_L9:
				move    X:(SP),R0
				nop     
				lea     (R0)+
				move    R0,X:(SP)
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #4,X0
				blt     _L7
_L12:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+3),R2
				jsr     Fsnd_idx_wave
				moves   X:<mr9,R2
				nop     
				orc     #32768,X:(R2+7)
_L14:
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
Fsnd_idx_inst:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr9
				moves   X:<mr9,R2
				nop     
				move    X:(R2+9),X0
				move    X0,X:<mr8
				moves   X:<mr9,X0
				add     #10,X0
				move    X0,X:(SP)
				moves   X:<mr9,R2
				nop     
				bftstl  #32768,X:(R2+3)
				bhs     _L13
				moves   X:<mr9,R0
				movei   #258,Y0
				move    X:(R0),X0
				impy    Y0,X0,X0
				moves   X:<mr9,R0
				nop     
				move    X0,X:(R0)
				tstw    X:<mr8
				beq     _L12
_L7:
				move    X:(SP),R0
				move    X:Fctl_org,Y0
				move    X:(R0),X0
				add     X0,Y0
				move    Y0,X:(R0)
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				jsr     Fsnd_idx_sound
				move    X:(SP),R0
				nop     
				lea     (R0)+
				move    R0,X:(SP)
				dec     X:<mr8
				tstw    X:<mr8
				bne     _L7
_L12:
				moves   X:<mr9,R2
				nop     
				orc     #32768,X:(R2+3)
_L13:
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
Fsnd_idx_bank:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				lea     (SP)+
				moves   R2,X:<mr9
				moves   X:<mr9,R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr8
				moves   X:<mr9,R2
				nop     
				bftstl  #32768,X:(R2+1)
				bhs     _L17
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:(SP)
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				beq     _L8
				inc     X:<mr8
				bra     _L9
_L8:
				move    X:(SP),R0
				nop     
				lea     (R0)+
				move    R0,X:(SP)
_L9:
				tstw    X:<mr8
				beq     _L16
_L10:
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				beq     _L13
				move    X:(SP),R0
				move    X:Fctl_org,Y0
				move    X:(R0),X0
				add     X0,Y0
				move    Y0,X:(R0)
				move    X:(SP),R0
				nop     
				move    X:(R0),R2
				jsr     Fsnd_idx_inst
_L13:
				move    X:(SP),R0
				nop     
				lea     (R0)+
				move    R0,X:(SP)
				dec     X:<mr8
				tstw    X:<mr8
				bne     _L10
_L16:
				moves   X:<mr9,R2
				nop     
				orc     #32768,X:(R2+1)
_L17:
				lea     (SP)-
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FalBnkfNew
				ORG	P:
FalBnkfNew:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   R2,X:<mr9
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				moves   X:<mr9,R2
				nop     
				move    X:(R2+5),X0
				move    X0,X:<mr8
				moves   X:<mr9,X0
				move    X0,X:Fctl_org
				move    X:(SP),B
				move    X:(SP-1),B0
				move    B1,X:Ftbl_org+1
				move    B0,X:Ftbl_org
				tstw    X:<mr8
				beq     _L12
				moves   X:<mr9,X0
				add     #6,X0
				move    X0,X:(SP-2)
_L7:
				move    X:(SP-2),R0
				move    X:Fctl_org,Y0
				move    X:(R0),X0
				add     X0,Y0
				move    X:(SP-2),R0
				nop     
				move    Y0,X:(R0)
				move    X:(SP-2),R0
				nop     
				move    X:(R0),R2
				jsr     Fsnd_idx_bank
				inc     X:(SP-2)
				dec     X:<mr8
				tstw    X:<mr8
				bne     _L7
_L12:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fsnd_load_bank
				ORG	P:
Fsnd_load_bank:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #6,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				move    A1,X:(SP-2)
				move    A0,X:(SP-3)
				movei   #1,X0
				push    X0
				move    X:(SP-1),R2
				jsr     Fopen
				pop     
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L5
				clr     A
				jmp     _L16
_L5:
				movec   SP,R0
				lea     (R0-5)
				push    R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #3,Y1
				jsr     FfileioIoctl
				pop     
				move    X:(SP-4),B
				move    X:(SP-5),B0
				movei   #0,B2
				asr     B
				movec   B0,X0
				move    X0,X:<mr9
				movei   #0,X0
				push    X0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #2,Y1
				jsr     FfileioIoctl
				pop     
				tstw    X:<mr9
				beq     _L13
				moves   X:<mr9,Y0
				jsr     FmemMallocEM
				move    X:(SP-1),R0
				nop     
				move    R2,X:(R0)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-1),R1
				nop     
				move    X:(R1),R2
				moves   X:<mr9,Y1
				movei   #_L11,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L11:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),R2
				move    X:(SP-2),A
				move    X:(SP-3),A0
				moves   X:<mr9,Y0
				jsr     Fsdram_load
_L13:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #_L14,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L14:
				clr     B
				moves   X:<mr9,X0
				move    X0,B0
				tfr     B,A
_L16:
				lea     (SP-6)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fsnd_load_tbl
				ORG	P:
Fsnd_load_tbl:
				move    X:<mr8,N
				push    N
				movei   #7,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				movei   #1,X0
				push    X0
				move    X:(SP-1),R2
				jsr     Fopen
				pop     
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L5
				clr     A
				jmp     _L14
_L5:
				movec   SP,R0
				lea     (R0-4)
				push    R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #3,Y1
				jsr     FfileioIoctl
				pop     
				move    X:(SP-3),B
				move    X:(SP-4),B0
				movei   #0,B2
				asr     B
				move    B1,X:(SP-5)
				move    B0,X:(SP-6)
				move    X:(SP-5),B
				move    X:(SP-6),B0
				tst     B
				bne     _L9
				clr     A
				bra     _L14
_L9:
				movei   #0,X0
				push    X0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #2,Y1
				jsr     FfileioIoctl
				pop     
				move    X:(SP-5),B
				move    X:(SP-6),B0
				push    B0
				push    B1
				moves   X:<mr8,Y0
				move    X:(SP-3),A
				move    X:(SP-4),A0
				jsr     Fsdram_load_file
				lea     (SP-2)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+1),Y0
				movei   #_L12,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L12:
				move    X:(SP-5),A
				move    X:(SP-6),A0
_L14:
				lea     (SP-7)
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
Ftbl_org        BSC			2
Fctl_org        BSC			1

				ENDSEC
				END

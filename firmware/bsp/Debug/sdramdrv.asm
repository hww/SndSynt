
				SECTION sdramdrv
				include "asmdef.h"
				GLOBAL Fsdram_init
				ORG	P:
Fsdram_init:
				move    X:ff74,Y0
				nop     
				nop     
				movei   #4096,X:ff78
				nop     
				nop     
				movei   #0,X:ff76
				nop     
				nop     
				movei   #0,X:ff76
				nop     
				nop     
				movei   #2176,X:ff75
				nop     
				nop     
				movei   #0,X:ff77
				movei   #0,X:Fsucess
				rts     


				GLOBAL Fsdram_read16
				ORG	P:
Fsdram_read16:
				movei   #4096,X:ff78
				move    A0,X:ff71
				move    A1,X:ff7a
				nop     
				nop     
				move    X:ff74,Y0
				movei   #0,X:ff77
				rts     


				GLOBAL Fsdram_read32
				ORG	P:
Fsdram_read32:
				movei   #4096,X:ff78
				move    A0,X:ff71
				move    A1,X:ff72
				nop     
				nop     
				move    X:ff74,A0
				move    A1,X:ff7a
				nop     
				nop     
				move    X:ff74,A1
				movei   #0,X:ff77
				rts     


				GLOBAL Fsdram_write16
				ORG	P:
Fsdram_write16:
				movei   #4096,X:ff78
				move    A0,X:ff71
				move    A1,X:ff7b
				move    Y0,X:ff74
				movei   #0,X:ff77
				rts     


				GLOBAL Fsdram_write32
				ORG	P:
Fsdram_write32:
				move    X:(SP-3),B0
				move    X:(SP-2),B1
				movei   #4096,X:ff78
				move    A0,X:ff71
				move    A1,X:ff73
				move    B0,X:ff74
				move    A1,X:ff7b
				move    B1,X:ff74
				movei   #0,X:ff77
				rts     


				GLOBAL Fsdram_load
				ORG	P:
Fsdram_load:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    R2,X:(SP-2)
				moves   Y0,X:<mr8
_L2:
				move    X:(SP),B
				move    X:(SP-1),B0
				push    B0
				push    B1
				movei   #0,A
				movei   #1,A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				pop     B1
				pop     B0
				tfr     B,A
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    X:(R0),Y0
				jsr     Fsdram_write16
				dec     X:<mr8
				tstw    X:<mr8
				bne     _L2
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fsdram_save
				ORG	P:
Fsdram_save:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    R2,X:(SP-2)
				moves   Y0,X:<mr8
_L2:
				move    X:(SP),B
				move    X:(SP-1),B0
				push    B0
				push    B1
				movei   #0,A
				movei   #1,A0
				add     A,B
				move    B1,X:(SP-2)
				move    B0,X:(SP-3)
				pop     B1
				pop     B0
				tfr     B,A
				jsr     Fsdram_read16
				movec   X:(SP-2),R0
				inc     X:(SP-2)
				move    Y0,X:(R0)
				dec     X:<mr8
				tstw    X:<mr8
				bne     _L2
				move    X:(SP),A
				move    X:(SP-1),A0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fsdram_load_64
				ORG	P:
Fsdram_load_64:
				move    Y0,X0
				movei   #4,Y0
				clr     Y1
				move    X:Flast_addressh,B
				move    X:Flast_addressl,B0
				cmp     A,B
				bne     _L12
				cmp     X:Flast_size,X0
				bne     _L12
				inc     X:Fsucess
				rts     
_L12:
				move    A0,X:Flast_addressl
				move    A1,X:Flast_addressh
				move    X0,X:Flast_size
				movei   #4096,X:ff78
				tstw    X0
				beq     _L41
				do      X0,_L41
				move    A0,X:ff71
				move    A1,X:ff72
				nop     
				nop     
				move    X:ff74,X0
				move    A1,X:ff72
				move    X0,X:(R2)+
				nop     
				nop     
				move    X:ff74,X0
				move    A1,X:ff72
				move    X0,X:(R2)+
				nop     
				nop     
				move    X:ff74,X0
				move    A1,X:ff7a
				move    X0,X:(R2)+
				nop     
				nop     
				move    X:ff74,X0
				move    X0,X:(R2)+
				add     Y,A
_L41:
				movei   #0,X:ff77
				rts     


				GLOBAL Fsdram_load_file
				ORG	P:
Fsdram_load_file:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   Y0,X:<mr9
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				movei   #127,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-2)
				tstw    X:(SP-2)
				bne     _L5
				movei   #0,Y0
				jmp     _L15
_L5:
				moves   #127,X:<mr8
_L6:
				move    X:(SP-7),B
				move    X:(SP-8),B0
				movei   #0,A
				movei   #127,A0
				cmp     A,B
				bhs     _L8
				move    X:(SP-7),B
				move    X:(SP-8),B0
				movec   B0,X0
				move    X0,X:<mr8
_L8:
				moves   X:<mr9,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-2),R2
				moves   X:<mr8,Y1
				movei   #_L9,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L9:
				move    X:(SP),A
				move    X:(SP-1),A0
				move    X:(SP-2),R2
				moves   X:<mr8,Y0
				jsr     Fsdram_load
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				clr     B
				moves   X:<mr8,X0
				move    X0,B0
				move    X:(SP-7),A
				move    X:(SP-8),A0
				sub     B,A
				move    A1,X:(SP-7)
				move    A0,X:(SP-8)
				move    X:(SP-7),B
				move    X:(SP-8),B0
				tst     B
				bne     _L6
				move    X:(SP-2),R2
				jsr     FmemFreeEM
				movei   #1,Y0
_L15:
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:
Fsucess         BSC			1
Flast_size      BSC			1
Flast_addressh  BSC			1
Flast_addressl  BSC			1

				ENDSEC
				END

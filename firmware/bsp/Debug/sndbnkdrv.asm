
				SECTION sndbnkdrv
				include "asmdef.h"
				GLOBAL Fsnd_idx_pointers
				ORG	P:
Fsnd_idx_pointers:
				movec   R2,R3
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				bhs     _L8
_L4:
				movec   R2,X0
				move    X:(R3),Y1
				add     Y1,X0
				move    X0,X:(R3)
				lea     (R3)+
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L4
_L8:
				rts     


				GLOBAL Fsnd_idx_all_banks
				ORG	P:
Fsnd_idx_all_banks:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				move    R2,X:(SP)
				move    X:(SP),R2
				nop     
				move    X:(R2+1),X0
				move    X0,X:<mr8
				tstw    X:<mr8
				beq     _L5
				move    X:(SP),X0
				movec   X0,R2
				nop     
				lea     (R2+2)
				moves   X:<mr8,Y0
				jsr     Fsnd_idx_pointers
_L5:
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				ORG	X:

				ENDSEC
				END

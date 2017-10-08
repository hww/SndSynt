
				SECTION mfr16
				include "asmdef.h"
				GLOBAL Fmfr16Rand
				ORG	P:
Fmfr16Rand:
				move    X:<mr8,N
				push    N
				movei   #0,Y0
				jsr     FarchGetSetSaturationMode
				move    Y0,X:<mr8
				movei   #31821,Y0
				move    X:FLastRandomNumber,X0
				impy    Y0,X0,X0
				add     #13849,X0
				move    X0,X:FLastRandomNumber
				moves   X:<mr8,Y0
				jsr     FarchGetSetSaturationMode
				move    X:FLastRandomNumber,Y0
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Fmfr16SetRandSeed
				ORG	P:
Fmfr16SetRandSeed:
				lea     (SP)+
				move    Y0,X:(SP)
				move    X:(SP),X0
				move    X0,X:FLastRandomNumber
				lea     (SP)-
				rts     


				ORG	X:
FLastRandomNumberDC			21845

				ENDSEC
				END

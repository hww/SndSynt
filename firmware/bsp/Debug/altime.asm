
				SECTION altime
				include "asmdef.h"
				GLOBAL FalMicroTimeSub
				ORG	P:
FalMicroTimeSub:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(R2+1),A
				move    X:(R2),A0
				sub     B,A
				move    A1,X:(R2+1)
				move    A0,X:(R2)
				move    X:(R2+1),B
				move    X:(R2),B0
				tst     B
				bge     _L5
				movei   #0,X:(R2)
				movei   #0,X:(R2+1)
_L5:
				lea     (SP-2)
				rts     


				GLOBAL FalMicroTimeAdd
				ORG	P:
FalMicroTimeAdd:
				movei   #2,N
				lea     (SP)+N
				move    A1,X:(SP)
				move    A0,X:(SP-1)
				move    X:(SP),B
				move    X:(SP-1),B0
				move    X:(R2+1),A
				move    X:(R2),A0
				add     A,B
				move    B1,X:(R2+1)
				move    B0,X:(R2)
				move    X:(R2+1),B
				move    X:(R2),B0
				movei   #15258,A
				movei   #-13825,A0
				cmp     A,B
				ble     _L5
				movei   #-15259,B
				movei   #13825,B0
				move    X:(R2+1),A
				move    X:(R2),A0
				add     A,B
				move    B1,X:(R2+1)
				move    B0,X:(R2)
_L5:
				lea     (SP-2)
				rts     


				GLOBAL FalMiliToMicro
				ORG	P:
FalMiliToMicro:
				lea     (SP)+
				move    Y0,X:(SP)
				movei   #0,B
				movei   #1000,B0
				push    B0
				push    B1
				move    X:(SP-2),B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				jsr     ARTMPYS32U
				pop     
				pop     
				lea     (SP)-
				rts     


				ORG	X:

				ENDSEC
				END

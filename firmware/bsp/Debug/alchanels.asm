
				SECTION alchanels
				include "asmdef.h"
				GLOBAL FalSeqpSetChlProgram
				ORG	P:
FalSeqpSetChlProgram:
				moves   Y1,X:<mr2
				move    X:(R2+4),R0
				moves   X:<mr2,X0
				move    X:(R0),Y1
				cmp     Y1,X0
				bhs     _L9
				move    X:(R2+4),X0
				movec   X0,R0
				lea     (R0+3)
				moves   X:<mr2,N
				tstw    X:(R0+N)
				bne     _L5
				moves   #0,X:<mr2
_L5:
				movei   #12,X0
				impy    Y0,X0,X0
				move    X:(R2+56),Y1
				add     Y1,X0
				movec   X0,R3
				moves   X:<mr2,X0
				move    X0,X:(R3+1)
				move    X:(R2+4),X0
				movec   X0,R0
				lea     (R0+3)
				moves   X:<mr2,N
				move    X:(R0+N),R1
				move    R1,X:(R3)
				move    X:(R3),R0
				move    X:(R0+8),X0
				move    X0,X:(R3+2)
_L9:
				rts     


				GLOBAL FalSeqpGetChlProgram
				ORG	P:
FalSeqpGetChlProgram:
				move    X:(R2+56),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				nop     
				lea     (R0)+
				movec   X0,N
				move    X:(R0+N),B
				movec   B1,B0
				movec   B2,B1
				tfr     B,A
				rts     


				GLOBAL FalSeqpSetChlFXMix
				ORG	P:
FalSeqpSetChlFXMix:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+56),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+7)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlFXMix
				ORG	P:
FalSeqpGetChlFXMix:
				move    X:(R2+56),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+7)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlVol
				ORG	P:
FalSeqpSetChlVol:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+56),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+6)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlVol
				ORG	P:
FalSeqpGetChlVol:
				move    X:(R2+56),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+6)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlPan
				ORG	P:
FalSeqpSetChlPan:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+56),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+4)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlPan
				ORG	P:
FalSeqpGetChlPan:
				move    X:(R2+56),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+4)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				GLOBAL FalSeqpSetChlPriority
				ORG	P:
FalSeqpSetChlPriority:
				lea     (SP)+
				moves   Y1,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+56),X0
				movec   X0,X:(SP)
				movei   #12,X0
				impy    Y0,X0,X0
				movec   X:(SP),R0
				lea     (R0+5)
				movec   X0,N
				move    Y1,X:(R0+N)
				lea     (SP)-
				rts     


				GLOBAL FalSeqpGetChlPriority
				ORG	P:
FalSeqpGetChlPriority:
				move    X:(R2+56),Y1
				movei   #12,X0
				impy    Y0,X0,X0
				movec   Y1,R0
				lea     (R0+5)
				movec   X0,N
				move    X:(R0+N),Y0
				rts     


				ORG	X:

				ENDSEC
				END

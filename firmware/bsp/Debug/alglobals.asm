
				SECTION alglobals
				include "asmdef.h"
				GLOBAL FalInit
				ORG	P:
FalInit:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				jsr     Fsdram_init
				move    X:(SP),R0
				move    R0,X:FalGlobals
				move    X:FalGlobals,R2
				move    X:(SP-1),R3
				jsr     FalSynNew
				lea     (SP-2)
				rts     


				GLOBAL FalClose
				ORG	P:
FalClose:
				move    X:FalGlobals,R2
				jsr     FalSynDelete
				rts     


				ORG	X:
FalGlobals      BSC			1

				ENDSEC
				END


				SECTION appconfig
				include "asmdef.h"
				GLOBAL FUserPreMain
				ORG	P:
FUserPreMain:
				rts     


				GLOBAL FUserPostMain
				ORG	P:
FUserPostMain:
				jsr     Ffflush
_L2:
				debug   
				bra     _L2


				ORG	X:

				ENDSEC
				END

		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  FPConstData16
		GLOBAL  FPData16
		GLOBAL  FPConstData32
		GLOBAL  FPData32

			ORG	P:
FPConstData16:
			dc   $1234
			dc   $5678
			dc   $4321
			dc   $8765

FPConstData32:
			dc   $5678
			dc   $1234
			dc   $6789
			dc   $2345
			dc   $789A
			dc   $3456
			dc   $89AB
			dc   $4567
			dc   $9ABC
			dc   $5678
			dc   $ABCD
			dc   $6789
			dc   $BCDE
			dc   $789A
			dc   $CDEF
			dc   $89AB

FPData16:
			dc   0,0,0,0

	
FPData32:
			dc   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

			ENDSEC
			END

#include "port.h"
#include "test.h"

/*-----------------------------------------------------------------------*

    test.c
	
*------------------------------------------------------------------------*/

Result testmfr16(void);
Result testmfr32(void);
Result testafr16(void);
Result testafr32(void);
Result testtfr16(void);
Result testvfr16(void);
Result testxfr16(void);

int main(void)
{
	int res = 0;

	res |= testmfr16();

	res |= testmfr32();
		
	res |= testafr16();

	res |= testafr32();
	
	res |= testtfr16();

	res |= testvfr16();

	res |= testxfr16();
		
   return res;
   
   
}





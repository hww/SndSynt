#include "port.h"
#include "test.h"

/*-----------------------------------------------------------------------*

    testmain.c
	
*------------------------------------------------------------------------*/

Result testdfr16(void);

int main(void)
{
	int res = 0;

	res |= testdfr16();
		
	return res;
}





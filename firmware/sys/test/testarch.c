#include "port.h"
#include "arch.h"
#include "test.h"
#include "periph.h"
#include "appconst.h"

/*-----------------------------------------------------------------------*

    testarch.c
	
*------------------------------------------------------------------------*/

Result testarch(test_sRec *);

Result testarch(test_sRec *pTestRec)
{
   Flag  f;
	Int16 i16;
#define MAX_16 32767

archDisableInt();

	testStart (pTestRec, ArchTestStartMsg);

archEnableInt();

	/******************/
   /* Test Limit Bit */
	/******************/

   archResetLimitBit ();

	i16 = MAX_16;

   f = archGetLimitBit();

	if (f != 0) 
	{
		testFailed(pTestRec, ArchResetLimitFailedMsg);
	}

	i16++;

	f = archGetLimitBit();

	if (f != 1) 
	{
		testFailed(pTestRec, ArchGetLimitFailedMsg);
	}
	
	testEnd (pTestRec);
	
   return PASS;
}






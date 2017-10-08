#include "port.h"
#include "test.h"

/*-----------------------------------------------------------------------*

    testsys.c
	
*------------------------------------------------------------------------*/

Result testarch        (test_sRec *pTestRec);
Result testInterrupts  (test_sRec *pTestRec);
Result testproto       (test_sRec *pTestRec);
Result testTimespec    (test_sRec *pTestRec);
Result testmem(test_sRec *);
int main(void)
{
	int res = 0;
	test_sRec testRec;

	res |= testarch (&testRec);
	
	res |= testInterrupts (&testRec);
	
	res |= testproto (&testRec);

	res |= testTimespec (&testRec);
	res |=  testmem(&testRec);
	return 0;
}






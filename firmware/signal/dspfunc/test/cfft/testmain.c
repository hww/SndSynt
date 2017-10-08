/********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*********************************************************************
*
* File Name: testmain.c
*
* Description: Includes main() function.
*
* Modules Included: main
*
* Author(s): Prasad N R and Sandeep S
*
* Date: 27 Jan 2000
*
********************************************************************/

#include "port.h"
#include "test.h"
#include "stackcheck.h"


Result testBitRev16(void); 
Result testCfft16(void);
void   testStack(void);

void testStack (void)
{
	test_sRec testRec;

	testStart (&testRec, "Testing stack size...");

//	sprintf(s, "Stack size reached %d out of %d", 
//					stackcheckSizeUsed(), 
//					stackcheckSizeAllocated());
//	testComment(&testRec, s);
	
	if (stackcheckSizeUsed() >= stackcheckSizeAllocated())
	{
		testFailed(&testRec, "Stack overflow");
	}
	
	testEnd(&testRec);
}

 
int main(void)
{
	int       res = 0;
	 
	res |= testBitRev16(); 
	res |= testCfft16();

	testStack();
	
   return res;
}





#include "port.h"
#include "arch.h"
#include "test.h"
#include "timespec.h"
#include "stdio.h"
#include "appconst.h"

/*-----------------------------------------------------------------------*

    testproto.c  -  test Prototype.h file
	
*------------------------------------------------------------------------*/

Result testTimespec(test_sRec *);

Result testTimespec(test_sRec *pTestRec)
{
	struct timespec  T1, T2, T3;
	
	testStart (pTestRec, TimeSpecTestStartMsg);

	/**********************/
   /* Test timespecAdd    */
	/**********************/

	T1.tv_sec  = 1;
	T1.tv_nsec = 0;
	
	T2.tv_sec  = 0;
	T2.tv_nsec = 1000000000;
	
	timespecAdd (&T3, &T1, &T2);

	if (T3.tv_sec != 2 || T3.tv_nsec != 0) 
	{
		testFailed(pTestRec, TimeSpecTestAdd1Msg);
	}

	T1.tv_sec  = 111111;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = 222222;
	T2.tv_nsec = 990000000;
	
	timespecAdd (&T3, &T1, &T2);

	if (T3.tv_sec != 333334 || T3.tv_nsec != 980000000) 
	{
		testFailed(pTestRec, TimeSpecTestAdd2Msg);
	}

	T1.tv_sec  = -111111;
	T1.tv_nsec = -990000000;
	
	T2.tv_sec  = -222222;
	T2.tv_nsec = -990000000;
	
	timespecAdd (&T3, &T1, &T2);

	if (T3.tv_sec != -333334 || T3.tv_nsec != -980000000) 
	{
		testFailed(pTestRec, TimeSpecTestAdd3Msg);
	}

	T1.tv_sec  = 123456789;
	T1.tv_nsec = -990000000;
	
	T2.tv_sec  = 987654321;
	T2.tv_nsec = -990000000;
	
	timespecAdd (&T3, &T1, &T2);

	if (T3.tv_sec != 1111111108 || T3.tv_nsec != 20000000) 
	{
		testFailed(pTestRec, TimeSpecTestAdd4Msg);
	}

	T1.tv_sec  = -123456789;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = -987654321;
	T2.tv_nsec = 990000000;
	
	timespecAdd (&T3, &T1, &T2);

	if (T3.tv_sec != -1111111108 || T3.tv_nsec != -20000000) 
	{
		testFailed(pTestRec, TimeSpecTestAdd5Msg);
	}


	/**********************/
   /* Test timespecSub    */
	/**********************/

	T1.tv_sec  = 1;
	T1.tv_nsec = 0;
	
	T2.tv_sec  = 0;
	T2.tv_nsec = 1000000000;
	
	timespecSub (&T3, &T1, &T2);

	if (T3.tv_sec != 0 || T3.tv_nsec != 0) 
	{
		testFailed(pTestRec, TimeSpecTestSub1Msg);
	}

	T1.tv_sec  = 111111;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = 222222;
	T2.tv_nsec = 990000000;
	
	timespecSub (&T3, &T1, &T2);

	if (T3.tv_sec != -111111 || T3.tv_nsec != 0) 
	{
		testFailed(pTestRec, TimeSpecTestSub2Msg);
	}

	T1.tv_sec  = -111111;
	T1.tv_nsec = -990000000;
	
	T2.tv_sec  = -222222;
	T2.tv_nsec = -990000000;
	
	timespecSub (&T3, &T1, &T2);

	if (T3.tv_sec != 111111 || T3.tv_nsec != 0) 
	{
		testFailed(pTestRec, TimeSpecTestSub3Msg);
	}

	T1.tv_sec  = 123456789;
	T1.tv_nsec = -990000001;
	
	T2.tv_sec  = 987654321;
	T2.tv_nsec = -990000000;
	
	timespecSub (&T3, &T1, &T2);

	if (T3.tv_sec != -864197532 || T3.tv_nsec != -1) 
	{
		testFailed(pTestRec, TimeSpecTestSub4Msg);
	}

	T1.tv_sec  = -123456789;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = -987654321;
	T2.tv_nsec = 990000001;
	
	timespecSub (&T3, &T1, &T2);

	if (T3.tv_sec != 864197531 || T3.tv_nsec != 999999999) 
	{
		testFailed(pTestRec, TimeSpecTestSub5Msg);
	}


	/**********************/
   /* Test timespecGE    */
	/**********************/

	T1.tv_sec  = 1;
	T1.tv_nsec = 0;
	
	T2.tv_sec  = 0;
	T2.tv_nsec = 1000000000;
	
	if (timespecGE(&T2,&T1) || !timespecGE(&T1, &T2)) 
	{
		testFailed(pTestRec, TimeSpecTestGE1Msg);
	}

	T1.tv_sec  = 111111;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = 111111;
	T2.tv_nsec = 990000000;
	
	if (!timespecGE(&T1,&T2)) 
	{
		testFailed(pTestRec, TimeSpecTestGE2Msg);
	}

	T1.tv_sec  = -111111;
	T1.tv_nsec = -990000000;
	
	T2.tv_sec  = -222222;
	T2.tv_nsec = -990000000;
	
	if (timespecGE(&T2,&T1) || !timespecGE(&T1,&T2)) 
	{
		testFailed(pTestRec, TimeSpecTestGE3Msg);
	}

	T1.tv_sec  = 123456789;
	T1.tv_nsec = -990000001;
	
	T2.tv_sec  = 987654321;
	T2.tv_nsec = -990000000;
	
	if (timespecGE(&T1,&T2) || !timespecGE(&T2,&T1)) 
	{
		testFailed(pTestRec, TimeSpecTestGE4Msg);
	}

	T1.tv_sec  = -987654321;
	T1.tv_nsec = 990000000;
	
	T2.tv_sec  = -987654321;
	T2.tv_nsec = 990000001;
	
	if (timespecGE(&T1,&T2) || !timespecGE(&T2,&T1)) 
	{
		testFailed(pTestRec, TimeSpecTestGE5Msg);
	}


	testEnd (pTestRec);
	
	return PASS;
}






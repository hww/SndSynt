#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "vfr16.h"
#include "test.h"
#include "assert.h"

/*-----------------------------------------------------------------------*

    testvfr16.c
	
*------------------------------------------------------------------------*/

EXPORT Result testvfr16(void);

Result testvfr16(void)
{
   Frac16         x[10];
   Frac16         y[10];
   Frac16         z16;
   Frac32         z32;
   UInt16         i;
   Result         res;

	test_sRec      testRec;

	testStart (&testRec, "testvfr16");
	
	/******************/
   /* Test vfr16Add */
	/******************/

	testComment (&testRec, "Test vfr16Add");
	
	for (i=0; i<10; i++) 
	{
		x[i] = 0x2000;
		y[i] = 0x2000;
	}
	
	vfr16Add (x, y, y, 10);
	
	for (i=0; i<10; i++) 
	{
		if (y[i] != 0x4000) 
		{
			testFailed(&testRec, "vfr16Add failed");
		}
	}
		
	
	vfr16Add (y, y, y, 10);
	
	for (i=0; i<10; i++) 
	{
		if (y[i] != 0x7FFF) 
		{
			testFailed(&testRec, "vfr16Add failed to saturate");;
		}
	}


	/******************/
   /* Test vfr16Sub */
	/******************/

	testComment (&testRec, "Test vfr16Sub");
	
	for (i=0; i<10; i++) 
	{
		x[i] = 0x2000;
		y[i] = 0x4000;
	}
	
	vfr16Sub (x, y, y, 10);
	
	for (i=0; i<10; i++) 
	{
		if (y[i] != 0xE000) 
		{
			testFailed(&testRec, "vfr16Sub failed");
		}
	}
		
	for (i=0; i<4; i++)
	{
		vfr16Sub (y, x, y, 10);
	}
		
	for (i=0; i<10; i++) 
	{
		if (y[i] != 0x8000) 
		{
			testFailed(&testRec, "vfr16Sub failed to saturate");;
		}
	}


	/*******************/
   /* Test vfr16Equal */
	/*******************/

	testComment (&testRec, "Test vfr16Equal");
	
	for (i=0; i<10; i++) 
	{
		x[i] = 0x1234;
		y[i] = 0x1234;
	}
	
	if (!vfr16Equal (x, y, 10))
	{
		testFailed(&testRec, "vfr16Equal failed");
	}
	
	y[3] = 0x4321;
	
	if (vfr16Equal (x, y, 10))
	{
		testFailed(&testRec, "vfr16Equal failed");
	}

	
	/*********************/
   /* Test vfr16DotProd */
	/*********************/

	testComment (&testRec, "Test vfr16DotProd");
	
	for (i=0; i<4; i++) 
	{
		x[i] = 0x4000;
		y[i] = 0x0800;
	}
	
	z32 = vfr16DotProd (x, y, 4);
	
	if (z32 != 0x10000000)
	{
		testFailed(&testRec, "vfr16DotProd failed");
	}
	
	
	/*********************/
   /* Test vfr16Length  */
	/*********************/

	testComment (&testRec, "Test vfr16Length");
	
	for (i=0; i<2; i++) 
	{
		x[i] = 0x2000;
	}
	
	z16 = vfr16Length (x, 2);
	
	if (z16 != 0x2D41)
	{
		testFailed(&testRec, "vfr16Length failed");
	}
	
	/*********************/
   /* Test vfr16Mult    */
	/*********************/

	testComment (&testRec, "Test vfr16Mult");
	
	for (i=0; i<4; i++) 
	{
		x[i] = 0x4646;
	}
	
	vfr16Mult (0x4000, x, y, 4);
	
	for (i=0; i<4; i++)
	{
		if (y[i] != 0x2323)
		{
			testFailed(&testRec, "vfr16Mult failed");
		}
	}
	

	/*********************/
   /* Test vfr16Scale   */
	/*********************/

	testComment (&testRec, "Test vfr16Scale");
	
	for (i=0; i<7; i++) 
	{
		x[i] = 0x1111;
	}
	
	vfr16Scale (2, x, y, 7);
	
	for (i=0; i<4; i++)
	{
		if (y[i] != 0x4444)
		{
			testFailed(&testRec, "vfr16Scale failed");
		}
	}
	
	vfr16Scale (-2, y, y, 7);
	
	for (i=0; i<7; i++)
	{
		if (y[i] != 0x1111)
		{
			testFailed(&testRec, "vfr16Scale failed");
		}
	}
	
	/* Make sure Scale saturates both ways */
	
	vfr16Scale (3, y, y, 7);
	
	for (i=0; i<7; i++)
	{
		if (y[i] != 0x7FFF)
		{
			testFailed(&testRec, "vfr16Scale failed to saturate");
		}
	}
	
	vfr16Scale (-15, y, y, 7);
	
	for (i=0; i<7; i++)
	{
		if (y[i] != 0x0000)
		{
			testFailed(&testRec, "vfr16Scale failed on zero");
		}
	}

	for (i=0; i<7; i++) 
	{
		x[i] = 0xE00E;
	}
	
	vfr16Scale (4, x, y, 7);
	
	for (i=0; i<7; i++)
	{
		if (y[i] != 0x8000)
		{
			testFailed(&testRec, "vfr16Scale failed to saturate");
		}
	}
	
	vfr16Scale (-15, y, y, 7);
	
	for (i=0; i<7; i++)
	{
		if (y[i] != 0xFFFF)
		{
			testFailed(&testRec, "vfr16Scale failed on -1/32768");
		}
	}

	

	testEnd(&testRec);

   return PASS;
}






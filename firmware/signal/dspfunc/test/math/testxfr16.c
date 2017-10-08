#include <stdio.h>
#include "dspfunc.h"
#include "mem.h"
#include "test.h"

#undef PRINT_RESULTS

EXPORT Result testxfr16 (void);

Result testxfr16 (void)
{
#define XROWS   2
#define XCOLS   3
#define YROWS   XCOLS
#define YCOLS   4
#define ZROWS   XROWS
#define ZCOLS   YCOLS

	Frac16 x[XROWS][XCOLS];
	Frac16 x2[XROWS][XCOLS];
	Frac16 y[YROWS][YCOLS];
	Frac16 *w;                     /* Same as X in internal memory */
	Frac16 z[ZROWS][ZCOLS];        /* Results in assembly */
	Frac16 zres[ZROWS][ZCOLS]       /* Matrix mult results */
		= {0x3400, 0x1A00, 0x0680, 0x0068,
			0x3400, 0x1A00, 0x0680, 0x0068};
	int    i, j;
	Frac16 temp;

	test_sRec      testRec;

	/* DSP Function Library initialization must have been performed */
	
	testStart (&testRec, "testxfr16");
	
	/***********************/
   /* Initialize matrix X */
	/***********************/
	
	w = (Frac16 *)memMallocIM(sizeof(x)/sizeof(Frac16));
	
	for (i=0; i<XROWS; i++)
	{
		temp = 0x4000;
		
		for (j=0; j<XCOLS; j++)
		{
			x[i][j] = temp;
			*(w + i*XCOLS + j) = temp;
			temp    = mult(temp, temp);
		}
	}

	for (i=0; i<XROWS; i++)
	{
		for (j=0; j<XCOLS; j++)
		{
			if (x[i][j] != *(w + i*XCOLS + j)) 
			{
				testFailed(&testRec, "!!! Internal matrix initialization failed");
			}
		}
	}
	
#ifdef PRINT_RESULTS
	printf("Matrix x = \n");
	for (i=0; i<XROWS; i++)
	{
		for (j=0; j<XCOLS; j++)
		{
			printf ("%x ", x[i][j]);
		}
		printf("\n");
	}
	printf("\n");
#endif

	/***********************/
   /* Initialize matrix Y */
	/***********************/

	for (i=0; i<YROWS; i++)
	{
		temp = 0x4000;
		
		for (j=0; j<YCOLS; j++)
		{
			y[i][j] = temp;
			temp    = mult(temp, temp);
		}
	}

#ifdef PRINT_RESULTS
	printf("Matrix y = \n");
	for (i=0; i<YROWS; i++)
	{
		for (j=0; j<YCOLS; j++)
		{
			printf ("%x ", y[i][j]);
		}
		printf("\n");
	}
	printf("\n");
#endif


	/**************************************/
   /* Test matrix add and equal          */
	/**************************************/
	testComment (&testRec, "Testing xfr16Add");
	
	xfr16Add ((Frac16 *)x, XROWS, XCOLS, (Frac16 *)x, (Frac16 *)x2);
	
	if (xfr16Equal ((Frac16 *)x, XROWS, XCOLS, (Frac16 *)x2))
	{
		testFailed (&testRec, "Matrix equality failed");
	}
	
	/**************************************/
   /* Test matrix sub                    */
	/**************************************/
	testComment (&testRec, "Testing xfr16Sub");
	
	xfr16Sub ((Frac16 *)x2, XROWS, XCOLS, (Frac16 *)x, (Frac16 *)x2);
	
	for (i=0; i<XROWS; i++)
	{
		for (j=0; j<XCOLS; j++)
		{
			if (j==0)
			{
				if (x2[i][j] != 0x3fff)
				{
					testFailed(&testRec, "Matrix add did not saturate");
				}
				x2[i][j] = 0x4000;
			}
			else
			{
				if (x2[i][j] != x[i][j]) {
					testFailed (&testRec, "!!! Matrix add/sub failed !!!");
				}
			}
		}
	}
	
	testComment (&testRec, "Testing xfr16Equal");
	
	if (!xfr16Equal ((Frac16 *)x, XROWS, XCOLS, (Frac16 *)x2))
	{
		testFailed (&testRec, "Matrix equality failed");
	}
	

	/**************************************/
   /* Test external data matrix multiply */
	/**************************************/
	testComment (&testRec, "Testing xfr16Mult for external memory");
	
	xfr16Mult ((Frac16 *)x, XROWS, XCOLS, (Frac16 *)y, YCOLS, (Frac16 *)z);
	
	for (i=0; i<ZROWS; i++)
	{
		for (j=0; j<ZCOLS; j++)
		{
			if (z[i][j] != zres[i][j]) {
				testFailed (&testRec, "!!! External matrix multiply failed !!!");
			}
		}
	}

#ifdef PRINT_RESULTS
	printf ("\nExternal data matrix multiply result = \n");
	for (i=0; i<ZROWS; i++)
	{
		for (j=0; j<ZCOLS; j++)
		{
			printf ("%x ", z[i][j]);
		}
		printf("\n");
	}
#endif	
	
	/**************************************/
   /* Test internal data matrix multiply */
	/**************************************/
	testComment (&testRec, "Testing xfr16Mult for internal memory");

	xfr16Mult ((Frac16 *)w, XROWS, XCOLS, (Frac16 *)y, YCOLS, (Frac16 *)z);
	
	for (i=0; i<ZROWS; i++)
	{
		for (j=0; j<ZCOLS; j++)
		{
			if (z[i][j] != zres[i][j]) {
				testFailed (&testRec, "!!! Internal matrix multiply failed !!!");
			}
		}
	}
	
#ifdef PRINT_RESULTS
	printf ("\nInternal data matrix multiply result = \n");
	for (i=0; i<ZROWS; i++)
	{
		for (j=0; j<ZCOLS; j++)
		{
			printf ("%x ", z[i][j]);
		}
		printf("\n");
	}
#endif 	
	
	/********************************************/
   /* Test large external data matrix multiply */
	/********************************************/
	{
		Frac16 lx[2][20];
		Frac16 ly[20][2];
		Frac16 lz[2][2];
		Frac16 lzres[2][2] = { 0x0a00, 0x0500, 0x0500, 0x0280};
		Frac16 temp = 0x1000;
		
		for (i=0; i<2; i++)
		{
			temp = shr(temp, 1);
			
			for (j=0; j<20; j++)
			{
				lx[i][j] = temp;
				ly[j][i] = temp;
			}
		}
		
	  	testComment (&testRec, "Testing xfr16Mult for big matrix in external memory");
			
		xfr16Mult ((Frac16 *)lx, 2, 20, (Frac16 *)ly, 2, (Frac16 *)lz);
	
		for (i=0; i<2; i++)
		{
			for (j=0; j<2; j++)
			{
				if (lz[i][j] != lzres[i][j]) 
				{
					testFailed (&testRec, "!!! Long external matrix multiply failed !!!");
				}
			}
		}
	
#if 0
		printf ("\nLong external data matrix multiply result = \n");
		for (i=0; i<2; i++)
		{
			for (j=0; j<2; j++)
			{
				printf ("%x ", lz[i][j]);
			}
		printf("\n");
		}
#endif 
	}	

	/********************************************/
   /* Test matrix transpose                    */
	/********************************************/
	{
		Frac16 x44[4][4] = { 1,  2,  3,  4,
								  	5,  6,  7,  8,
								   9, 10, 11, 12,
								  13, 14, 15, 16 };
		Frac16 z44[4][4];
		Frac16 z44Res[4][4] = { 1, 5,  9, 13,
										2, 6, 10, 14,
										3, 7, 11, 15,
										4, 8, 12, 16 };
										
		Frac16 x24[2][4] = { 1, 2, 3, 4,
									5, 6, 7, 8 };
		Frac16 z42[4][2];
		Frac16 z42Res[4][2] = { 1, 5,
										2, 6,
										3, 7,
										4, 8 };

		int i, j;
		
	  	testComment (&testRec, "Testing xfr16Trans");

		xfr16Trans( (Frac16 *)x44, 4, 4, (Frac16 *)z44);
		
		if( !xfr16Equal ((Frac16 *)z44, 4, 4, (Frac16 *)z44Res) ) 
		{
			testFailed(&testRec, "xfr16Trans 4x4");
		}

		xfr16Trans( (Frac16 *)x24, 2, 4, (Frac16 *)z42);
		
		if( !xfr16Equal ((Frac16 *)z42, 4, 2, (Frac16 *)z42Res) ) 
		{
			testFailed(&testRec, "xfr16Trans 4x2");
		}
	}


	/********************************************/
   /* Test matrix determinant                  */
	/********************************************/
	{
		Frac16 x[2][2] = { 3000, 4000, -2000, 50 };
		Frac16 x2[3][3] = { 305, -800, 1320, 2800, 1535, 1186, 612, 8900, 0 };
		int i,j;
		Frac32 result;

	  	testComment (&testRec, "Testing xfr16Det");

		result = xfr16Det( (Frac16 *)x, 2 );
		if( result != 16300000 ) {
      	testFailed(&testRec, "xfr16Det 2x2");
		}
      
		result = xfr16Det( (Frac16 *)x2, 3 );
		if( result != 1700091 ) {
      	testFailed(&testRec, "xfr16Det 3x3");
		}
	}
	
	/********************************************/
   /* Test matrix inverse                      */
	/********************************************/
	{
		Frac16 x[2][2] = { 3000, 4000, -2000, 50 };
		Frac16 x2[3][3] = { 305, -800, 1320, 2800, 1535, 1186, 612, 8900, 0 };
		Frac16 z[2][2];
		Frac16 z2[3][3];
		Frac16 zres[2][2] = { 50, -4000, 2000, 3000 };
		Frac16 z2res[3][3] = { -322, 359, -91, 22, -25, 102, 732, -98, 83 };

		int i,j;
		Frac32 result;
		
	  	testComment (&testRec, "Testing xfr16Inv");

		result = xfr16Inv( (Frac16 *)x, 2, (Frac16 *)z );
		if( result != 16300000 ) {
			testFailed(&testRec, "xfr16Inv 2x2 determinant");
		}

		if( xfr16Equal((Frac16 *)z, 2, 2, (Frac16 *)zres) == false ) {
			testFailed(&testRec, "xfr16Inv 2x2");
		}

#if 0
		for(i=0; i < 2; i++)
		{
			for( j=0; j < 2; j++)
				printf("%d ",z[i][j]);
			printf("\n");
		}
#endif

		result = xfr16Inv( (Frac16 *)x2, 3, (Frac16 *)z2 );
		if( result != 1700091 ) {
			testFailed(&testRec, "xfr16Inv 3x3 determinant");
		}
      
		if( xfr16Equal((Frac16 *)z2, 3, 3, (Frac16 *)z2res) == false ) {
			testFailed(&testRec, "xfr16Inv 3x3");
		}
	}
	
	
	testEnd (&testRec);
	
	return PASS;
}

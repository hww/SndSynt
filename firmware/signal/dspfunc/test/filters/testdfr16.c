#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "dfr16.h"
#include "dfr16priv.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"

EXPORT void   dfr16FIRC(dfr16_tFirStruct *, Frac16 *, Frac16 *, UInt16);
EXPORT UInt16 dfr16FIRIntC(dfr16_tFirIntStruct *pFIRINT, Frac16 *pX, Frac16 *pZ, UInt16 n);
EXPORT Result dfr16AutoCorrC(UInt16, Frac16 *, Frac16 *, UInt16, UInt16);
EXPORT Result dfr16CorrC(UInt16, Frac16 *, Frac16 *, Frac16 *, UInt16, UInt16);
EXPORT Result dfr16IIRC(dfr16_tIirStruct *, Frac16 *, Frac16 *, UInt16);

EXPORT Result testdfr16(void);

/*-----------------------------------------------------------------------*

    testdfr16.c
	
*------------------------------------------------------------------------*/

#undef PRINT_RESULTS


const Frac16 FirCoefs[] = {
	FRAC16(0.0026868866),  	FRAC16(0.0006820376), 	FRAC16(-0.0030727922), 	FRAC16(-0.0032504199), 
	FRAC16(0.0024948977),  	FRAC16(0.0055995793), 	FRAC16(-0.0005578898), 	FRAC16(-0.0078069903),
	FRAC16(-0.0037212502),  FRAC16(0.0085197836),  	FRAC16(0.0096489396), 	FRAC16(-0.0056197005),
	FRAC16(-0.0162840914), 	FRAC16(-0.0016015832),  FRAC16(0.0204732753),  	FRAC16(0.0142358113),
	FRAC16(-0.0195537023), 	FRAC16(-0.0306247957),  FRAC16(0.0086750304),  	FRAC16(0.0490698069),
	FRAC16(0.0173309185), 	FRAC16(-0.0654983670), 	FRAC16(-0.0749460831),  FRAC16(0.0772542581),
	FRAC16(0.3071701527),  	FRAC16(0.4186406732),  	FRAC16(0.3071701527),
	FRAC16(0.0772542581), 	FRAC16(-0.0749460831), 	FRAC16(-0.0654983670),  FRAC16(0.0173309185),
	FRAC16(0.0490698069),  	FRAC16(0.0086750304), 	FRAC16(-0.0306247957), 	FRAC16(-0.0195537023),
	FRAC16(0.0142358113),  	FRAC16(0.0204732753), 	FRAC16(-0.0016015832), 	FRAC16(-0.0162840914),
	FRAC16(-0.0056197005),  FRAC16(0.0096489396),  	FRAC16(0.0085197836), 	FRAC16(-0.0037212502),
	FRAC16(-0.0078069903), 	FRAC16(-0.0005578898),  FRAC16(0.0055995793),  	FRAC16(0.0024948977),
	FRAC16(-0.0032504199), 	FRAC16(-0.0030727922),  FRAC16(0.0006820376),  	FRAC16(0.0026868866)
};

const Frac16 sinWave[] =
{
	FRAC16(0),
	FRAC16(0.382683432),
	FRAC16(0.707106781),
	FRAC16(0.923879533),
	FRAC16(1),
	FRAC16(0.923879533),
	FRAC16(0.707106781),
	FRAC16(0.382683432),
	FRAC16(0),
	FRAC16(-0.382683432),
	FRAC16(-0.707106781),
	FRAC16(-0.923879533),
	FRAC16(-1),
	FRAC16(-0.923879533),
	FRAC16(-0.707106781),
	FRAC16(-0.382683432)
};



/* Testing of IIR Filter is done for 3 biquads*/
#define SCALE_FACT_IIR 2
#define NUM_SAMPLES_IIR 16	   

const Frac16 IirCoefs[] = {FRAC16(-0.65989516115372),
									FRAC16(0.12268070452601),
									FRAC16(0.11569569111675),
									FRAC16(0.23139364818967),
									FRAC16(0.11569620406586),
									FRAC16(-0.74778917825849),
                           FRAC16(0.27221493792500),
                           FRAC16(0.1308519097316),
                           FRAC16(0.26221188600122), 
                           FRAC16(0.13136196387213),
                           FRAC16(-0.97203670514256),
                           FRAC16(0.65372761795475),
                           FRAC16(0.17075525591212),
                           FRAC16(0.34084416601338),
                           FRAC16(0.17009149088669)};

const Frac16 EXP_IIR_OUT[] = {0,32,178,476,860,1214,1436,1467,1286,918,
                              410,-155,-702,-1133,-1404,-1444};
                              
                              
#define CORR_NX      5   /* Length of input vector */
#define CORR_NY      3   /* Length of output vector */
#define CORR_OPTIONS CORR_RAW  /* CORR_RAW =0, CORR_BIAS = 1, CORR_UNBIAS = 2*/

#define AUTO_CORR_NX      5           /* Length of input vector */
#define AUTO_CORR_NZ      9           /* Length of output vector*/
#define AUTO_CORR_OPTIONS CORR_RAW    /* CORR_RAW = 0, CORR_BIAS = 1, CORR_UNBIAS = 2*/

const Frac16 FirResults[] = { -30192, -31192, -30250, -23152, -12530, 0, 12530, 23152, 30192,
					31192, 30250, 23152, 12530, 0, -12530, -23152 };
const Frac16 FirDecResults[] = { -31192, -23152, 0, 23152, 31192, 23152, 0, -23152};
const Frac16 FirIntResults[] = { 13656, 11584, 9124, 6269, 3204, 0, -3204,
										 -6269, -9124, -11584, -13656, -15135,
										 -16108, -16382, -16108, -15135, -13656,
										 -11584, -9124, -6269, -3204, 0, 3204,
										 6269, 9124, 11584, 13656, 15135, 16108,
										 16382, 16108, 15135};
const Frac16 FirInt3Results[] = { -7700, -6628, -5476, -4167, -2805, -1446, 0,
										 1446, 2805, 4167, 5476, 6628,
										 7700, 8673, 9443, 10060, 10549,
										 10819, 10889, 10819, 10549, 10060, 9443,
										 8673, 7700, 6628, 5476, 4167, 2805,
										 1446, 0, -1446};


#if 1
// This code as kept for performance comparison reasons
static dfr16_tFirStruct * dfr16FIRIntCreateOld  (Frac16 *pC, UInt16 n, UInt16 f)
{
	dfr16_tFirStruct * pFirInt;

	pFirInt = dfr16FIRCreate (pC,  n);

	((dfr16_tFirStructPriv *)pFirInt) -> Factor     = f;
	((dfr16_tFirStructPriv *)pFirInt) -> Count      = n / f;

	return pFirInt;
}


static void dfr16FIRIntInitOld  (dfr16_tFirIntStruct *pFIRInt, Frac16 *pC, UInt16 n, UInt16 f)
{
	dfr16FIRInit (pFIRInt, pC, n);

	((dfr16_tFirStructPriv *)pFIRInt) -> Factor     = f;
	((dfr16_tFirStructPriv *)pFIRInt) -> Count      = n / f;
}


static UInt16  dfr16FIRIntOld (dfr16_tFirStruct *pFIRINT, Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16   i, j;
	Frac16 * pMemEnd;
	UInt16   outcnt;
	Frac16   tempbuf[4];

	if (((dfr16_tFirStructPriv *)pFIRINT) -> Factor <= 4)
	{
		/* Optimize interpolation within temporary buffer */

		for (i = 0; i < n; i++)
		{
			tempbuf[1] = 0; //*pX;
			tempbuf[2] = 0; //*pX;
			tempbuf[3] = 0; //*pX;
			tempbuf[0] = *pX++;
			
			dfr16FIR (pFIRINT, tempbuf, pZ, ((dfr16_tFirStructPriv *)pFIRINT)->Factor);

			pZ += ((dfr16_tFirStructPriv *)pFIRINT) -> Factor;
		}
	}
	else 
	{
		/* Interpolate with each sample individually */
		for (i = 0; i < n; i++)
		{
			*pZ++ = dfr16FIRs (pFIRINT, *pX);

			for (j = 0; j < ((dfr16_tFirStructPriv *)pFIRINT) -> Factor - 1; j++)
			{
				*pZ++ = dfr16FIRs (pFIRINT, *pX);
			}
			pX++;
		}
	}
	
	return n * ((dfr16_tFirStructPriv *)pFIRINT) -> Factor;
}
#endif

					
Result testdfr16(void)
{
	UInt16         i, j;

	/* Local declarations for FIR filter tests */   
	#define NUM_SAMPLES 100
	   
	Frac16                z1[NUM_SAMPLES];
	Frac16                z2[NUM_SAMPLES];
	Frac16                z3[NUM_SAMPLES];
	Frac16                x [NUM_SAMPLES];
	char                  s[100];
	dfr16_tFirStruct    * pFir;
	UInt16                sinIndex;
	Result                res;
	UInt16                tempIndex;

	dfr16_tFirDecStruct * pFirDec;
	dfr16_tFirIntStruct * pFirInt;
	UInt16                numres;

	test_sRec             testRec;

	testStart (&testRec, "testdfr16");

	/* Set up sin table for use by all FIR tests */
	sinIndex = 0;
	for (i=0; i<NUM_SAMPLES; i++) {
		x[i] = sinWave[sinIndex++];
			
		/* Change made below to circumvent CodeWarrior bug */
		sinIndex %= 16;  // (sizeof(sinWave)/sizeof(Frac16));
	}

	/*************************************************************/
	/* dfr16FIR Case 0:                                          */
	/* Test dfr16FIR implementation in C                         */
	/*************************************************************/

	{		
		/* 
		// Test FIRCreate 
		*/
		testComment(&testRec, "Test FIR in C");
		
		pFir = dfr16FIRCreate ((Frac16 *)(&FirCoefs[0]), sizeof(FirCoefs)/sizeof(Frac16));
	
		/* 
		// Test FIR 
		*/
		dfr16FIRC (pFir, &x[0], z1, NUM_SAMPLES);
		
#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=NUM_SAMPLES - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif 

		j =0;
		for (i=NUM_SAMPLES - sizeof(FirResults)/sizeof(Frac16); i<NUM_SAMPLES; i++) 
		{
			if (z1[i] != FirResults[j++]) 
			{
				testFailed (&testRec, "C version of FIR failed");
				break;
			}
		}
	
		/* 
		// Test FIRHistory 
		*/
		tempIndex = NUM_SAMPLES - (sizeof(FirCoefs)/sizeof(Frac16)) - 1;
		
		//assert (tempIndex >= 0);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		dfr16FIRC (pFir, &x[tempIndex+1], &z1[0], 1);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		z1[1] = dfr16FIRs (pFir, x[tempIndex+1]);

#ifdef PRINT_RESULTS
		testComment(&testRec, "dfr16FIRs must equal dfr16FIRC in the next two samples:");
		
		sprintf(s, "%d == %d", z1[0], z1[1]);
		testComment(&testRec, s);
#endif 

		if (z1[0] != z1[1])
		{
			testFailed(&testRec, "dfr16FIRs did not equal dfr16FIRC for one sample");
		}

		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDestroy (pFir);
	}

	/*************************************************************/
	/* dfr16FIR Case 1:                                          */
   /* Test dfr16FIR using modulo addressing and internal memory */
	/*************************************************************/

	{
		/* 
		// Test FIRCreate 
		*/
		testComment(&testRec, "Test FIR with modulo addressing in internal memory");
		
		pFir = dfr16FIRCreate ((Frac16 *)(&FirCoefs[0]), sizeof(FirCoefs)/sizeof(Frac16));
	
		if (!((dfr16_tFirStructPriv *)pFir) -> bCanUseModAddr || !((dfr16_tFirStructPriv *)pFir) -> bCanUseDualMAC)
		{
			testFailed(&testRec, "FirCreate for internal memory failed");
		}
			
		/* 
		// Test FIR 
		*/
		dfr16FIR (pFir, x, z1, NUM_SAMPLES);

#ifdef PRINT_RESULTS		
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=NUM_SAMPLES - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j =0;
		for (i=NUM_SAMPLES - sizeof(FirResults)/sizeof(Frac16); i<NUM_SAMPLES; i++) 
		{
			if (z1[i] != FirResults[j++]) 
			{
				testFailed (&testRec, "ASM version of FIR failed in Case 1");
				break;
			}
		}
	
		
		/* 
		// Test FIRHistory 
		*/
		tempIndex = NUM_SAMPLES - (sizeof(FirCoefs)/sizeof(Frac16)) - 1;
		
		//assert (tempIndex >= 0);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		dfr16FIR (pFir, &x[tempIndex+1], &z1[0], 1);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		z1[1] = dfr16FIRs (pFir, x[tempIndex+1]);

		if (z1[0] != z1[1])
		{
			testFailed(&testRec, "dfr16FIRs did not equal dfr16FIR for one sample");
		}

		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDestroy (pFir);
	}

	/*************************************************************/
	/* dfr16FIR Case 2:                                          */
    /* Test dfr16Fir using modulo addressing and external memory */
	/*************************************************************/

	{
		/* 
		// Test FIRCreate 
		*/
		testComment(&testRec, "Test FIR with modulo addressing in external memory");
		
		pFir = dfr16FIRCreate ((Frac16 *)(&FirCoefs[0]), sizeof(FirCoefs)/sizeof(Frac16));

		((dfr16_tFirStructPriv *)pFir) -> bCanUseDualMAC = false;

		if (!((dfr16_tFirStructPriv *)pFir) -> bCanUseModAddr)
		{
			testFailed(&testRec, "FirCreate for external memory failed");
		}
			
	
		/* 
		// Test FIR 
		*/
		dfr16FIR (pFir, x, z2, NUM_SAMPLES);

		j =0;
		for (i=NUM_SAMPLES - sizeof(FirResults)/sizeof(Frac16); i<NUM_SAMPLES; i++) 
		{
			if (z2[i] != FirResults[j++]) 
			{
				testFailed (&testRec, "ASM version of FIR failed in case 2");
				break;
			}
		}
	
		
		/* 
		// Test FIRHistory 
		*/
		tempIndex = NUM_SAMPLES - (sizeof(FirCoefs)/sizeof(Frac16)) - 1;
		
		//assert (tempIndex >= 0);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		dfr16FIR (pFir, &x[tempIndex+1], &z2[0], 1);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		z2[1] = dfr16FIRs (pFir, x[tempIndex+1]);

		if (z2[0] != z2[1])
		{
			testFailed(&testRec, "dfr16FIRs did not equal dfr16FIR for one sample");
		}

		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDestroy (pFir);
		
		/*
		// Compare results against previous version
		*/
		for (tempIndex=0; tempIndex<NUM_SAMPLES; tempIndex++)
		{
			if (z1[tempIndex] != z2[tempIndex])
			{
				testFailed(&testRec, "Case 1 <> Case 2");
				break;
			}
		}
	}
	
	/*************************************************************/
	/* dfr16FIR Case 3:                                          */
	/* Test dfr16Fir using linear addressing and external memory */
	/*************************************************************/

	{
		/* 
		// Test FIRCreate 
		*/
		testComment(&testRec, "Test FIR with linear addressing in external memory");
		
		pFir = dfr16FIRCreate ((Frac16 *)(&FirCoefs[0]), sizeof(FirCoefs)/sizeof(Frac16));

		((dfr16_tFirStructPriv *)pFir) -> bCanUseDualMAC = false;
		((dfr16_tFirStructPriv *)pFir) -> bCanUseModAddr = false;
		
		/* 
		// Test FIR 
		*/
		dfr16FIR (pFir, x, z3, NUM_SAMPLES);

		j =0;
		for (i=NUM_SAMPLES - sizeof(FirResults)/sizeof(Frac16); i<NUM_SAMPLES; i++) 
		{
			if (z3[i] != FirResults[j++]) 
			{
				testFailed (&testRec, "ASM version of FIR failed in case 3");
				break;
			}
		}
			
		/* 
		// Test FIRHistory 
		*/
		tempIndex = NUM_SAMPLES - (sizeof(FirCoefs)/sizeof(Frac16)) - 1;
		
		//assert (tempIndex >= 0);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		dfr16FIR (pFir, &x[tempIndex+1], &z3[0], 1);
		
		dfr16FIRHistory (pFir, &x[tempIndex]);

		z3[1] = dfr16FIRs (pFir, x[tempIndex+1]);

		if (z3[0] != z3[1])
		{
			testFailed(&testRec, "dfr16FIRs did not equal dfr16FIR for one sample");
		}

		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDestroy (pFir);
		
		/*
		// Compare results against previous version
		*/
		for (tempIndex=0; tempIndex<NUM_SAMPLES; tempIndex++)
		{
			if (z1[tempIndex] != z3[tempIndex])
			{
				testFailed(&testRec, "Case 1 <> Case 3");
				break;
			}
		}

	}
	
	/*************************************************************/
	/* dfr16FIRDec:                                              */
	/* Test dfr16FirDec by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRDecCreate 
		*/
		testComment(&testRec, "Test FIRDEC by factor of 2");
		
		pFirDec = dfr16FIRDecCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRDec
		*/
		numres = dfr16FIRDec (pFirDec, x, z1, NUM_SAMPLES);
		
		if (numres != NUM_SAMPLES/2)
		{
			testFailed (&testRec, "FIRDec did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - sizeof(sinWave)/sizeof(Frac16)/2; i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j =0;
		for (i=numres - sizeof(FirDecResults)/sizeof(Frac16); i<numres; i++) 
		{

			if (z1[i] != FirDecResults[j++]) 
			{
				testFailed (&testRec, "FIRDec failed with decimation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDecDestroy (pFirDec);
	}
	
	/*************************************************************/
	/* dfr16FIRDec:                                              */
	/* Test dfr16FirDec by a factor of 2 with odd number samples */
	/*************************************************************/

	{
		/* 
		// Test FIRDecCreate 
		*/
		testComment(&testRec, "Test FIRDEC with odd number samples");
		
		pFirDec = dfr16FIRDecCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRDec
		*/
		numres = 0;
		for (i=0; i<NUM_SAMPLES; i++)
		{
			j = dfr16FIRDec (pFirDec, &x[i], &z1[numres], 1);
			numres += j;
		}
		
		if (numres != NUM_SAMPLES/2)
		{
			testFailed (&testRec, "FIRDec did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - sizeof(sinWave)/sizeof(Frac16)/2; i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j =0;
		for (i=numres - sizeof(FirDecResults)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirDecResults[j++]) 
			{
				testFailed (&testRec, "FIRDec failed using odd number of samples");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRDecDestroy (pFirDec);
	}

	/*************************************************************/
	/* dfr16FIRIntC:                                              */
	/* Test dfr16FirIntC by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRIntC by factor of 2");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRIntC
		*/
		numres = dfr16FIRIntC (pFirInt, x, z1, NUM_SAMPLES/2);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRIntC did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirIntResults)/sizeof(Frac16); i<numres; i++) 
		{

			if (z1[i] != FirIntResults[j++]) 
			{
				testFailed (&testRec, "FIRIntC failed with interpolation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}
	
	/*************************************************************/
	/* dfr16FIRInt:                                              */
	/* Test dfr16FirInt by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 2");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/2);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirIntResults)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirIntResults[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

#if 0
// Kept for performance comparison
	/*************************************************************/
	/* dfr16FIRIntOld:                                              */
	/* Test dfr16FirIntOld by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 2");
		
		pFirInt = dfr16FIRIntCreateOld ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRIntOld (pFirInt, x, z1, NUM_SAMPLES/2);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirIntResults)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirIntResults[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}
#endif

	
	/*************************************************************/
	/* dfr16FIRIntC:                                              */
	/* Test dfr16FirIntC by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRIntC by factor of 2");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRIntC
		*/
		numres = dfr16FIRIntC (pFirInt, x, z1, NUM_SAMPLES/2);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRIntC did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirIntResults)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirIntResults[j++]) 
			{
				testFailed (&testRec, "FIRIntC failed with interpolation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}
	
	/*************************************************************/
	/* dfr16FIRInt:                                              */
	/* Test dfr16FirInt by a factor of 2                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 2");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										2);

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/2);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirIntResults)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirIntResults[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 2");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

	/*************************************************************/
	/* dfr16FIRIntC:                                              */
	/* Test dfr16FirIntC by a factor of 3                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRIntC by factor of 3");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										3);

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRIntC (pFirInt, x, z1, NUM_SAMPLES/3);
		
		if (numres != (NUM_SAMPLES/3)*3)
		{
			testFailed (&testRec, "FIRIntC did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirInt3Results)/sizeof(Frac16); i<numres; i++) 
		{

			if (z1[i] != FirInt3Results[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 3");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

	/*************************************************************/
	/* dfr16FIRInt:                                              */
	/* Test dfr16FirInt by a factor of 3 in internal memory      */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 3 with modulo addressing in internal memory");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										3);

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseDualMAC)
		{
			testFailed (&testRec, "FIRInt did not allocate internal memory");
		}

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseModAddr)
		{
			testFailed (&testRec, "FIRInt did not allocate aligned memory");
		}

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/3);
		
		if (numres != (NUM_SAMPLES/3)*3)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirInt3Results)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirInt3Results[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 3");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

	/*************************************************************/
	/* dfr16FIRInt:                                              */
	/* Test dfr16FirInt by a factor of 3 in external memory      */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 3 with modulo addressing in external memory");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										3);

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseDualMAC)
		{
			testFailed (&testRec, "FIRInt did not allocate internal memory");
		}

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseModAddr)
		{
			testFailed (&testRec, "FIRInt did not allocate aligned memory");
		}

		/* De-optimize algorithm intentionally for testing */
		((dfr16_tFirStructPriv *)pFirInt) -> bCanUseDualMAC = false;
		
		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/3);
		
		if (numres != (NUM_SAMPLES/3)*3)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirInt3Results)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirInt3Results[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 3");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

	/*******************************************************************/
	/* dfr16FIRInt:                                                    */
	/* Test dfr16FirInt by a factor of 3 in external, unaligned memory */
	/*******************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 3 with linear addressing in external memory");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										3);

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseDualMAC)
		{
			testFailed (&testRec, "FIRInt did not allocate internal memory");
		}

		if (!((dfr16_tFirStructPriv *)pFirInt) -> bCanUseModAddr)
		{
			testFailed (&testRec, "FIRInt did not allocate aligned memory");
		}

		/* De-optimize algorithm intentionally for testing */
		((dfr16_tFirStructPriv *)pFirInt) -> bCanUseDualMAC = false;
		((dfr16_tFirStructPriv *)pFirInt) -> bCanUseModAddr = false;
		
		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/3);
		
		if (numres != (NUM_SAMPLES/3)*3)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres - 2*sizeof(sinWave)/sizeof(Frac16); i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		j = 0;
		for (i=numres - sizeof(FirInt3Results)/sizeof(Frac16); i<numres; i++) 
		{
			if (z1[i] != FirInt3Results[j++]) 
			{
				testFailed (&testRec, "FIRInt failed with interpolation factor 3");
				break;
			}
		}
			
		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}

		
	/*************************************************************/
	/* dfr16FIRInt:                                              */
	/* Test dfr16FirInt by a factor of 4                         */
	/*************************************************************/

	{
		/* 
		// Test FIRIntCreate 
		*/
		testComment(&testRec, "Test FIRInt by factor of 4");
		
		pFirInt = dfr16FIRIntCreate ((Frac16 *)(&FirCoefs[0]), 
										sizeof(FirCoefs)/sizeof(Frac16),
										4);

		/* 
		// Test FIRInt
		*/
		numres = dfr16FIRInt (pFirInt, x, z1, NUM_SAMPLES/4);
		
		if (numres != NUM_SAMPLES)
		{
			testFailed (&testRec, "FIRInt did not return correct number of samples");
		}

#ifdef PRINT_RESULTS
		testComment(&testRec, "The following samples should be a sine wave");
		
		for (i=numres/2; i<numres; i++) {
			sprintf(s, "%d", z1[i]);
			testComment(&testRec, s);
		}
#endif

		/* 
		// Test FIRDestroy 
		*/
		dfr16FIRIntDestroy (pFirInt);
	}
	

		testComment(&testRec, "Testing Cross Correlation");
/************************************************************
* Test Corr                                                 *
*************************************************************/
/**********************************************************************
* Revision History:                                                   *
*                                                                     *
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS       *
* -------    ----------    -----------      -----      --------       *
*   0.1      Meera S. P.        -          25-01-2000   Reviewed      * 
*                                                                     *
**********************************************************************/

/********************************************************************************
* File Name : testdfr16.c                                                       *
*                                                                               *
* Description:                                                                  *
* This routine tests the first nz points of cross-correlation of a vector of    *
* fractional data values. The testing is done for C code and corresponding ASM  *
* code for all the 3 options viz. CORR_RAW, CORR_BIAS, and CORR_UNBIAS          *
*                                                                               *
* Inputs :                                                                      *
*                                                                               *
*        1) options - Selects between raw, biased, and unbiased auto correlation*
*        2) pX      - Pointer to the input vector                               *
*        3) pZ      - Pointer to output vector                                  *
*        4) nX      - Length of the input vector                                *
*        5) nZ      - Length of the output vector                               *
*                                                                               *
* Outputs :                                                                     *
*                                                                               *
*         FAIL(-1) - if length of output vector is greater than 8191            *
*         PASS(0)  - if length of output vector is not greater than 8191        *
********************************************************************************/
	
	{
		UInt16 i;
		UInt16 j;
		UInt16 ret_val;
    
		Frac16 px[CORR_NX] = {0x4000, 0x4200, 0x6100, 0x6400, 0x1400};
		Frac16 py[CORR_NY] = {0x2000, 0x2400, 0x7222};
		Frac16 pz[CORR_NX+CORR_NY-1];
		Frac16 exp_out_opt1[CORR_NX+CORR_NY-1] = {0x0500, 0x1ea0, 0x4634, 0x7ffe, 0x790d, 0x4cd9, 0x3911};
		Frac16 exp_out_opt2[CORR_NX+CORR_NY-1] = {0xb7, 0x460, 0xa07, 0x1249, 0x114b, 0xafa, 0x827};
		Frac16 exp_out_opt3[CORR_NX+CORR_NY-1] = {0x1ab, 0x7a8, 0xe0a, 0x1555, 0x114b, 0xccf, 0xb6a};
		int    OPTIONS = CORR_RAW;

		testComment(&testRec,"Testing C code for option CORR_RAW");
			
		ret_val = dfr16CorrC(OPTIONS, px, py, pz, CORR_NX, CORR_NY);
     
		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
			if(pz[i] != exp_out_opt1[i])
			{
				testFailed(&testRec, "corr failed in C version with option CORR_RAW");    
				break;
			}
           
		testComment(&testRec,"Testing ASM code for option CORR_RAW");
		     
		ret_val = dfr16Corr(OPTIONS, px, py, pz, CORR_NX, CORR_NY);

		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
			if(pz[i] != exp_out_opt1[i])
			{
				testFailed(&testRec,"corr failed in ASM version");
				break;
			}
			
		OPTIONS = CORR_BIAS;

		testComment(&testRec,"Testing C code for option CORR_BIAS");
		     
		ret_val = dfr16CorrC(OPTIONS, px, py, pz, CORR_NX, CORR_NY);
		
		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
        { 
			if(pz[i] != exp_out_opt2[i])
			{
				testFailed(&testRec,"corr failed in C version with option CORR_BIAS");
				break;
			}
		}
         
		testComment(&testRec,"Testing ASM code for option CORR_BIAS");
		     
		ret_val = dfr16Corr(OPTIONS, px, py, pz, CORR_NX, CORR_NY);
		
		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
			if(pz[i] != exp_out_opt2[i])
			{
				testFailed(&testRec,"corr failed in ASM version with option CORR_BIAS");
				break;
			}
			

		OPTIONS = CORR_UNBIAS;
		
		testComment(&testRec,"Testing C code for option CORR_UNBIAS");
		    
		ret_val = dfr16CorrC(OPTIONS, px, py, pz, CORR_NX, CORR_NY);
		
		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
			if(pz[i] != exp_out_opt3[i])
			{
				testFailed(&testRec,"corr failed in C version with option CORR_UNBIAS");
				break;
			}
			
		testComment(&testRec,"Testing ASM code for option CORR_UNBIAS");
		     
		ret_val = dfr16Corr(OPTIONS, px, py, pz, CORR_NX, CORR_NY);
		
		for (i = 0;i < CORR_NX+CORR_NY-1; i++)
			if(pz[i] != exp_out_opt3[i])
			{
			testFailed(&testRec,"corr failed in ASM version with option CORR_UNBIAS");
            	break;
			}
    }
	
/*********************************************************************
* Test AutoCorr                                                      *
*********************************************************************/

/**********************************************************************
* Revision History:                                                   *
*                                                                     *
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS       *
* -------    ----------    -----------      -----      --------       *
*   0.1      Meera S. P.        -          25-01-2000   Reviewed      * 
*                                                                     *
**********************************************************************/

/********************************************************************************
* File Name : testdfr16.c                                                       *
*                                                                               *
* Description:                                                                  *
* This routine tests the first nz points of auto-correlation of a vector of     *
* fractional data values. The testing is done for C code and corresponding ASM  *
* code for all the 3 options viz. CORR_RAW, CORR_BIAS, and CORR_UNBIAS          *
*                                                                               *
* Inputs :                                                                      *
*                                                                               *
*        1) options - Selects between raw, biased, and unbiased auto correlation*
*        2) pX      - Pointer to the input vector                               *
*        3) pZ      - Pointer to output vector                                  *
*        4) nX      - Length of the input vector                                *
*        5) nZ      - Length of the output vector                               *
*                                                                               *
* Outputs :                                                                     *
*                                                                               *
*         FAIL(-1) - if length of output vector is greater than 8191            *
*         PASS(0)  - if length of output vector is not greater than 8191        *
********************************************************************************/
	 

	testComment(&testRec,"Testing AUTO CORRELATION");
	
	{
		UInt16 i;
		UInt16 j;
		UInt16 ret_val;
    
		Frac16 px[AUTO_CORR_NX] = { 0x4000, 0x4200, 0x6100, 0x1400, 0x3241};
		Frac16 pz[AUTO_CORR_NZ];
		
		Frac16 exp_acorr_out1[AUTO_CORR_NZ] = {0x1921, 0x23ea, 0x60e4, 0x6a05, 0x7ffe, 0x6a05, 0x60e4,0x23ea,0x1921};
		Frac16 exp_acorr_out2[AUTO_CORR_NZ] = {0x506,0x72f,0x1361,0x1534,0x1999,0x1534,0x1361,0x72f,0x506};
		Frac16 exp_acorr_out3[AUTO_CORR_NZ] = {0x506,0x5fc,0xdd7,0xd41,0x0e38,0xd41,0xdd7,0x5fc,0x506};
		int    OPTIONS = CORR_RAW;

		testComment(&testRec,"Testing C code for option CORR_RAW");
		
		ret_val = dfr16AutoCorrC(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
     
		for (i = 0;i < AUTO_CORR_NZ; i++)
			if(pz[i] != exp_acorr_out1[i])
			{
				testFailed(&testRec, "autocorr failed in C version with option CORR_RAW");    
				break;
			}
           
		testComment(&testRec,"Testing ASM code for option CORR_RAW");
		
		     
		ret_val = dfr16AutoCorr(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
      exp_acorr_out1[0] = 0x1921;  // the value gets corrupted
      
		for (i = 0;i < AUTO_CORR_NZ; i++)
			if(pz[i] != exp_acorr_out1[i])
			{
				testFailed(&testRec,"autocorr failed in ASM version");
				break;
			}
			
		OPTIONS = CORR_BIAS;

		testComment(&testRec,"Testing C code for option CORR_BIAS");
		     
		ret_val = dfr16AutoCorrC(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
		
		for (i = 0;i < AUTO_CORR_NZ; i++)
        {
			if(pz[i] != exp_acorr_out2[i])
			{
				testFailed(&testRec,"autocorr failed in C version with option CORR_BIAS");
				break;
			}
		}
         
		testComment(&testRec,"Testing ASM code for option CORR_BIAS");
		     
		ret_val = dfr16AutoCorr(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
		
		for (i = 0;i < AUTO_CORR_NZ; i++)
			if(pz[i] != exp_acorr_out2[i])
			{
				testFailed(&testRec,"autocorr failed in ASM version with option CORR_BIAS");
				break;
			}
			

		OPTIONS = CORR_UNBIAS;
		
		testComment(&testRec,"Testing C code for option CORR_UNBIAS");
		    
		ret_val = dfr16AutoCorrC(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
		
		for (i = 0;i < AUTO_CORR_NZ; i++)
			if(pz[i] != exp_acorr_out3[i])
			{
				testFailed(&testRec,"autocorr failed in C version with option CORR_UNBIAS");
				break;
			}
			
		testComment(&testRec,"Testing ASM code for option CORR_UNBIAS");
		     
		ret_val = dfr16AutoCorr(OPTIONS, px, pz, AUTO_CORR_NX, AUTO_CORR_NZ);
		
		for (i = 0;i < AUTO_CORR_NZ; i++)
			if(pz[i] != exp_acorr_out3[i])
			{
			testFailed(&testRec,"autocorr failed in ASM version with option CORR_UNBIAS");
            	break;
			}

    }
 testComment(&testRec,"Test IIR C Code");

/**********************************************************************
* Revision History:                                                   *
*                                                                     *
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS       *
* -------    ----------    -----------      -----      --------       *
*   0.1      Meera S. P.        -          27-02-2000   For Review    * 
*                                                                     *
**********************************************************************/
/********************************************************************************
* File Name : testdfr16.c                                                       *
*                                                                               *
*                                                                               *
* Description:                                                                  *
* This routine tests a Infinite Impulse Response (IIR) filter for a vector of   *
* fractional data values using a cascade filter of biquad coefficients.         *
*                                                                               *
* There are 4 test codes corresponding to testing C code for IIR, testing ASM   *
* code for modulo addressing in internal memory, testing ASM code for modulo    *
* addressing in external memory and testing ASM code for linear addresssing in  *
* external memory respectively.                                                 *
* Inputs :                                                                      *
*                                                                               *
*         1) pIIR - Pointer to the data structre pIIR                           *
*         2) pX   - Pointer to the input vector                                 *
*         3) pZ   - Pointer to output vector                                    *
*         4) n    - Length of the input and output vector                       *
*                                                                               *
* Outputs :                                                                     *
*                                                                               *
*         FAIL(-1) - if length of input and output vecotor is greater than 8191 *
*         PASS(0)  - if length of input and output vecotor is not greater than  *
*                    8191                                                       *
********************************************************************************/

   	/*************************************************************/
	   /* Test IIR Filter                                           */
	   /*************************************************************/

	{  
		dfr16_tIirStruct   * pIir;
		UInt16  tempIndex;
		UInt16  sinIndex = 0;
		Result  res = PASS;
	   Frac16  x[NUM_SAMPLES_IIR];
      Frac16  zIIR[NUM_SAMPLES_IIR];
       


		/* 
		// Test IIRCreate 
		*/
		pIir = dfr16IIRCreate ((Frac16 *)(&IirCoefs[0]), sizeof(IirCoefs)/(sizeof(Frac16)*FILT_COEF_PER_BIQ));
		
		if(pIir == NULL)
		{
			testFailed(&testRec,"IIR Create Failed");
		}

     /* scale down the input by SCALE_FACT_IIR */
		for (i=0; i<NUM_SAMPLES_IIR; i++) 
		{
			x[i] = sinWave[sinIndex++]/SCALE_FACT_IIR;
			
			sinIndex %= 16;  
		}
		
		/* 
		// Test IIR 
		*/
		res = dfr16IIRC (pIir, x, zIIR, NUM_SAMPLES_IIR);
		
		if (res != PASS)
		{
			testFailed(&testRec, "dfr16IIR did not return PASS");
		}

		

		/* scale up the output by SCALE_FACT_IIR */
   	for(i = 0;i < NUM_SAMPLES_IIR;i++)	
   	{
			zIIR[i] = zIIR[i] * SCALE_FACT_IIR;	
		}
		
		for (i=NUM_SAMPLES_IIR - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES_IIR; i++) 
		{     
   		if (zIIR[i]+1 >= EXP_IIR_OUT[i] && zIIR[i]-1 <= EXP_IIR_OUT[i])
   		{
   			res = PASS;
	   	}
   		else
   		{
   			res = FAIL;
	      	break;
   	 	}
		}

      if(res == FAIL) 
         testFailed(&testRec,"wrong results of dfr16IIR");
	
			dfr16IIRDestroy (pIir);
	}


	testComment(&testRec,"Test IIR ASM code with modulo addressing in internal memory");

	/*************************************************************/
	/* Test IIR Filter ASM code for case 1                       */
	/*************************************************************/

	{  
		dfr16_tIirStruct   * pIir;
		UInt16  tempIndex;
		UInt16  sinIndex = 0;
		Result  res = PASS;
	   Frac16  x[NUM_SAMPLES_IIR];
      Frac16  zIIR[NUM_SAMPLES_IIR]; 


		/* 
		// Test IIRCreate 
		*/
		pIir = dfr16IIRCreate ((Frac16 *)(&IirCoefs[0]), sizeof(IirCoefs)/(sizeof(Frac16)*FILT_COEF_PER_BIQ));
		
		if(pIir == NULL)
		{
			testFailed(&testRec,"IIR Create Failed");
		}

	   if (!pIir -> bCanUseModAddr || !pIir -> bCanUseDualMAC)
		{
			testFailed(&testRec, "IirCreate for internal memory failed");
		}

     /* scale down the input by SCALE_FACT_IIR */
		for (i=0; i<NUM_SAMPLES_IIR; i++) 
		{
			x[i] = sinWave[sinIndex++]/SCALE_FACT_IIR;
			
			sinIndex %= 16;  
		}
		
		/* 
		// Test IIR 
		*/
		res = dfr16IIR (pIir, x, zIIR, NUM_SAMPLES_IIR);
		
		if (res != PASS)
		{
			testFailed(&testRec, "dfr16IIR did not return PASS");
		}

		

		/* scale up the output by SCALE_FACT_IIR */
   	for(i = 0;i < NUM_SAMPLES_IIR;i++)	
   	{
			zIIR[i] = zIIR[i] * SCALE_FACT_IIR;	
		}
		for (i=NUM_SAMPLES_IIR - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES_IIR; i++) 
		{     
   		if (zIIR[i]+1 >= EXP_IIR_OUT[i] && zIIR[i]-1 <= EXP_IIR_OUT[i])
   		{
   			res = PASS;
	   	}
   		else
   		{
   			res = FAIL;
	      	break;
   	 	}
		}

      if(res == FAIL) 
         testFailed(&testRec,"dfr16IIR did not return PASS");
	
			dfr16IIRDestroy (pIir);
	}

	testComment(&testRec,"Test IIR ASM code with modulo addressing in external memory");

	/*************************************************************/
	/* Test IIR Filter ASM code for case 2                       */
	/*************************************************************/

	{  
		dfr16_tIirStruct   * pIir;
		UInt16  tempIndex;
		UInt16  sinIndex = 0;
		Result  res = PASS;
	   Frac16  x[NUM_SAMPLES_IIR];
      Frac16  zIIR[NUM_SAMPLES_IIR];       


		/* 
		// Test IIRCreate 
		*/
		pIir = dfr16IIRCreate ((Frac16 *)(&IirCoefs[0]), sizeof(IirCoefs)/(sizeof(Frac16)*FILT_COEF_PER_BIQ));

		if (!pIir -> bCanUseModAddr)
		{
			testFailed(&testRec, "IirCreate for external memory failed");
		}
		
		if(pIir == NULL)
		{
			testFailed(&testRec,"IIR Create Failed");
		}

     /* scale down the input by SCALE_FACT_IIR */
		for (i=0; i<NUM_SAMPLES_IIR; i++) 
		{
			x[i] = sinWave[sinIndex++]/SCALE_FACT_IIR;
			
			sinIndex %= 16;  
		}

		pIir -> bCanUseDualMAC = false;
		
		/* 
		// Test IIR 
		*/
		res = dfr16IIR (pIir, x, zIIR, NUM_SAMPLES_IIR);
		
		if (res != PASS)
		{
			testFailed(&testRec, "dfr16IIR did not return PASS");
		}

		

		/* scale up the output by SCALE_FACT_IIR */
   	for(i = 0;i < NUM_SAMPLES_IIR;i++)	
   	{
			zIIR[i] = zIIR[i] * SCALE_FACT_IIR;	
		}
		for (i=NUM_SAMPLES_IIR - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES_IIR; i++) 
		{     
   		if (zIIR[i]+1 >= EXP_IIR_OUT[i] && zIIR[i]-1 <= EXP_IIR_OUT[i])
   		{
   			res = PASS;
	   	}
   		else
   		{
   			res = FAIL;
	      	break;
   	 	}
		}

      if(res == FAIL) 
			testFailed(&testRec, "dfr16IIR did not return PASS");
	
			dfr16IIRDestroy (pIir);
	}

	testComment(&testRec,"Test IIR ASM code with linear addressing in external memory");
	
   /*************************************************************/
	/* Test IIR Filter ASM code for case 3                       */
	/*************************************************************/

	{  
		dfr16_tIirStruct   * pIir;
		UInt16  tempIndex;
		UInt16  sinIndex = 0;
		Result  res = PASS;
	   Frac16  x[NUM_SAMPLES_IIR];
      Frac16  zIIR[NUM_SAMPLES_IIR];

		/* 
		// Test IIRCreate 
		*/
		pIir = dfr16IIRCreate ((Frac16 *)(&IirCoefs[0]), sizeof(IirCoefs)/(sizeof(Frac16)*FILT_COEF_PER_BIQ));
		
		if(pIir == NULL)
		{
			testFailed(&testRec,"IIR Create Failed");
		}

     /* scale down the input by SCALE_FACT_IIR */
		for (i=0; i<NUM_SAMPLES_IIR; i++) 
		{
			x[i] = sinWave[sinIndex++]/SCALE_FACT_IIR;
			
			sinIndex %= 16;  
		}

		pIir -> bCanUseDualMAC = false;
		pIir -> bCanUseModAddr = false;

		/* 
		// Test IIR 
		*/
		res = dfr16IIR (pIir, x, zIIR, NUM_SAMPLES_IIR);
		
		if (res != PASS)
		{
			testFailed(&testRec, "dfr16IIR did not return PASS");
		}

		

		/* scale up the output by SCALE_FACT_IIR */
   	for(i = 0;i < NUM_SAMPLES_IIR;i++)	
   	{
			zIIR[i] = zIIR[i] * SCALE_FACT_IIR;	
		}
		for (i=NUM_SAMPLES_IIR - sizeof(sinWave)/sizeof(Frac16); i<NUM_SAMPLES_IIR; i++) 
		{     
   		if (zIIR[i]+1 >= EXP_IIR_OUT[i] && zIIR[i]-1 <= EXP_IIR_OUT[i])
   		{
   			res = PASS;
	   	}
   		else
   		{
   			res = FAIL;
	      	break;
   	 	}
		}

      if(res == FAIL) 
			testFailed(&testRec, "dfr16IIR did not return PASS");
	
			dfr16IIRDestroy (pIir);
	}
    
	testEnd(&testRec);

	return PASS;
}






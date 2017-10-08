/* File : testtfr16.c */

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "tfr16.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"
#include "mem.h"

/*-----------------------------------------------------------------------*

    testtfr16.c
	
*------------------------------------------------------------------------*/


EXPORT Result testtfr16(void);

void   tfr16SineWaveGenIDTLC  (tfr16_tSineWaveGenIDTL  *,  Frac16 *, UInt16);
void   tfr16SineWaveGenRDTLC  (tfr16_tSineWaveGenRDTL  *,  Frac16 *, UInt16);
void   tfr16SineWaveGenRDITLC (tfr16_tSineWaveGenRDITL *,  Frac16 *, UInt16);
void   tfr16SineWaveGenPAMC   (tfr16_tSineWaveGenPAM *,    Frac16 *, UInt16);
void   tfr16SineWaveGenDOMC   (tfr16_tSineWaveGenDOM *,    Frac16 *, UInt16);

void   tfr16SineWaveGenRDITLQC(tfr16_tSineWaveGenRDITLQ *, Frac16 *, UInt16);
Frac16 tfr16WaveGenRDITLQC    (tfr16_tWaveGenRDITLQ     *, Frac16);
Frac16 tfr16SinPIxLUTC        (tfr16_tSinPIxLUT         *, Frac16);
Frac16 tfr16CosPIxLUTC        (tfr16_tCosPIxLUT         *, Frac16);

Result testtfr16(void)
{

	test_sRec      testRec;

	testStart (&testRec, "testtfr16");
	testComment(&testRec,"Testing Fractional Trignometric Functions...");
/*******************************************************************/
/* Test tfr16SinPIx                                                */
/********************************************************************/

{
    Frac16 x16[] = {FRAC16(0),FRAC16(0.1),FRAC16(0.2),FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
                    FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),FRAC16(0.9),FRAC16(1),FRAC16(-1),
   			        FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.6),FRAC16(-0.5),
   				     FRAC16(-0.4),FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };

    Frac16 exp_z[] = {FRAC16(0),FRAC16(0.30901699437495),FRAC16(0.58778525229247),FRAC16(0.80901699437495),
                      FRAC16(0.95105651629515),FRAC16(1),FRAC16(0.95105651629515),FRAC16(0.80901699437495),
                      FRAC16(0.58778525229247),FRAC16(0.30901699437495),FRAC16(1.224646799147353e-16),
                      FRAC16(-1.224646799147353e-16), FRAC16(-0.30901699437495),FRAC16(-0.58778525229247), 
                      FRAC16(-0.80901699437495),FRAC16(-0.95105651629515),FRAC16(-1), FRAC16(-0.95105651629515),
                      FRAC16(-0.80901699437495), FRAC16(-0.58778525229247), FRAC16(-0.30901699437495)};
                            
    Frac16 z16;                            
    Result res;
    UInt16 i;
   
    for(i = 0; i < 21; i++)
    {
        z16 = tfr16SinPIx(x16[i]);
    	  if (exp_z[i]<=z16+3 && exp_z[i] >= z16-3) 
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
	 {
        testFailed(&testRec,"tfr16SinPIx did not return PASS");
    }   
    else
    {
        testComment(&testRec,"tfr16SinPIx Passed");
    }
   	
   
}

/*******************************************************************
* Test tfr16CosPIx
********************************************************************/

{
    Frac16 x16[] = {FRAC16(0),FRAC16(0.1),FRAC16(0.2),FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
   			        FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),FRAC16(0.9),FRAC16(1),FRAC16(-1),
   				     FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.6),FRAC16(-0.5),
   				     FRAC16(-0.4),FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };
   Frac16 z16;
  
   Frac16 exp_z[] = {FRAC16(1.00000000000000),FRAC16(0.95105651629515),FRAC16(0.80901699437495),
                     FRAC16(0.58778525229247),FRAC16(0.30901699437495),FRAC16(0.00000000000000),
                     FRAC16(-0.30901699437495),FRAC16(-0.58778525229247),FRAC16(-0.80901699437495),
   		   			FRAC16(-0.95105651629515),FRAC16(-1.00000000000000),FRAC16(-1.00000000000000),
   						FRAC16(-0.95105651629515),FRAC16(-0.80901699437495),FRAC16(-0.58778525229247),
   						FRAC16(-0.30901699437495),FRAC16(0.00000000000000),FRAC16(0.30901699437495),
   						FRAC16(0.58778525229247),FRAC16(0.80901699437495),FRAC16(0.95105651629515)};
 
    Result res;
    UInt16 i;
   
    for(i = 0; i < 21; i++)
    {
        z16 = tfr16CosPIx(x16[i]);
		  if (exp_z[i]<=z16+4 && exp_z[i] >= z16-4) 
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
	 {
        testFailed(&testRec,"tfr16CosPIx did not return PASS");
    }
    else 
    {
        testComment(&testRec,"tfr16CosPIx Passed");
    }
   
}

/*******************************************************************
* Test tfr16AsinOverPI
********************************************************************/

{
    Frac16 x16[] = {FRAC16(0),FRAC16(0.1),FRAC16(0.2),FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
   			        FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),FRAC16(0.9),FRAC16(1),FRAC16(-1),
   				     FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.6),FRAC16(-0.5),
   				     FRAC16(-0.4),FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };
   Frac16 z16;
   Frac16 exp_z[] = {FRAC16(0),FRAC16(0.03188428042926),FRAC16(0.06409421684897),
                     FRAC16(0.09698668402068),FRAC16(0.13098988043445),FRAC16(0.16666666666667),
                     FRAC16(0.20483276469913),FRAC16(0.24681668889336),FRAC16(0.29516723530087),
                     FRAC16(0.35643370687129),FRAC16(0.50000000000000),FRAC16(-0.50000000000000),
                     FRAC16(-0.35643370687129),FRAC16(-0.29516723530087),FRAC16(-0.24681668889336),
                     FRAC16(-0.20483276469913),FRAC16(-0.16666666666667),FRAC16(-0.13098988043445),
                     FRAC16(-0.09698668402068),FRAC16(-0.06409421684897),FRAC16(-0.03188428042926)};
   Result res;
   UInt16 i;
   
   for(i = 0; i < 21; i++)
   {
       z16 = tfr16AsinOverPI(x16[i]);
		 if (exp_z[i]<=z16+2 && exp_z[i] >= z16-2) 
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
    {
        testFailed(&testRec,"tfr16AsinOverPI did not return PASS");
    }
    else 
    {
        testComment(&testRec,"tfr16AsinOverPI Passed");
    }
}

/*******************************************************************
* Test tfr16AcosOverPI
********************************************************************/

{
    Frac16 x16[] = {FRAC16(0),FRAC16(0.1),FRAC16(0.2),FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
   		           FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),FRAC16(0.9),FRAC16(1),FRAC16(-1),
   					  FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.6),FRAC16(-0.5),
   					  FRAC16(-0.4),FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };
    Frac16 z16;
    Frac16 exp_z[] = {FRAC16(0.50000000000000),FRAC16(0.46811571957074),FRAC16(0.43590578315103),
                      FRAC16(0.40301331597932),FRAC16(0.36901011956555),FRAC16(0.33333333333333),
                      FRAC16(0.29516723530087),FRAC16(0.25318331110664),FRAC16(0.20483276469913),
                      FRAC16(0.14356629312871),FRAC16(0),FRAC16(1.00000000000000),
                      FRAC16(0.85643370687129),FRAC16(0.79516723530087),FRAC16(0.74681668889337),
                      FRAC16(0.70483276469913),FRAC16(0.66666666666667),FRAC16(0.63098988043445),
                      FRAC16(0.59698668402068),FRAC16(0.56409421684897),FRAC16(0.53188428042926)
                     };
    Result res;
    UInt16 i;
   
    for(i = 0; i < 21; i++)
    {
	     z16 = tfr16AcosOverPI(x16[i]);
		  if (exp_z[i]<=z16+2 && exp_z[i] >= z16-2) 
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
    {
        testFailed(&testRec,"tfr16AcosOverPI did not return PASS");
    }
    else 
    {
        testComment(&testRec,"tfr16AcosOverPI Passed");
    }
}

/*******************************************************************
* Test tfr16AtanOverPI
********************************************************************/

{
    Frac16 x16[] = {FRAC16(0),FRAC16(0.1),FRAC16(0.2),FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
     			        FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),FRAC16(0.9),FRAC16(1),FRAC16(-1),
   				     FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.6),FRAC16(-0.5),
   				     FRAC16(-0.4),FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };
    Frac16 z16;
    Frac16 exp_z[] = {FRAC16(0),FRAC16(0.03172551743055),FRAC16(0.06283295818900),
                      FRAC16(0.09277357907774),FRAC16(0.12111894159084),FRAC16(0.14758361765043),
                      FRAC16(0.17202086962263),FRAC16(0.19440011221421),FRAC16(0.21477671252272),
                      FRAC16(0.23326229164343),FRAC16(0.25000000000000),FRAC16(-0.25000000000000),
                      FRAC16(-0.23326229164343),FRAC16(-0.21477671252272),FRAC16(-0.19440011221421),
                      FRAC16(-0.17202086962263),FRAC16(-0.14758361765043),FRAC16(-0.12111894159084),
                      FRAC16(-0.09277357907774),FRAC16(-0.06283295818900),FRAC16(-0.03172551743055)};
    Result res;
    UInt16 i;
   
    for(i = 0; i < 21; i++)
    {
	     z16 = tfr16AtanOverPI(x16[i]);
		  if (exp_z[i]<=z16+2 && exp_z[i] >= z16-2) 
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
    {
        testFailed(&testRec,"tfr16AtanOverPI did not return PASS");
    }
    else 
    {
        testComment(&testRec,"tfr16AtanOverPI Passed");
    }

}

/*******************************************************************
* Test tfr16Atan2OverPI
********************************************************************/

{
    Frac16 x16[] = {
                    FRAC16(0),FRAC16(0.1),FRAC16(0.2),
                    FRAC16(0.3),FRAC16(0.4),FRAC16(0.5),
   			        FRAC16(0.6),FRAC16(0.7),FRAC16(0.8),
   				     FRAC16(0.9),FRAC16(1),FRAC16(-1),
   				     FRAC16(-0.9),FRAC16(-0.8),FRAC16(-0.7),
   				     FRAC16(-0.6),FRAC16(-0.5),FRAC16(-0.4),
   				     FRAC16(-0.3),FRAC16(-0.2),FRAC16(-0.1) };
    Frac16 y16[] = {
                    FRAC16(0.0),FRAC16(1.0),FRAC16(0.9),
                    FRAC16(0.8),FRAC16(0.7),FRAC16(0.6),
                    FRAC16(0.5),FRAC16(0.4),FRAC16(0.3),
                    FRAC16(0.2),FRAC16(0.1),FRAC16(-0.2),
                    FRAC16(-0.6),FRAC16(0.9),FRAC16(-0.1),
                    FRAC16(-0.5),FRAC16(-0.2),FRAC16(0.4),
                    FRAC16(-0.8),FRAC16(-0.7),FRAC16(-0.3)
                   };
    Frac16 z16;
    Frac16 exp_z[] = {
                      FRAC16(0),FRAC16(0.46827448256945),FRAC16(0.43039551272694),
                      FRAC16(0.38579974878009),FRAC16(0.33475065946143),FRAC16(0.27885793837630),
                      FRAC16(0.22114206162370),FRAC16(0.16524934053857),FRAC16(0.11420025121991),
                      FRAC16(0.06960448727306),FRAC16(0.03172551743055),FRAC16(0.06283295818900),
                      FRAC16(0.18716704181100),FRAC16(-0.26870255924128),FRAC16(0.04516723530087),
                      FRAC16(0.22114206162370),FRAC16(0.12111894159084),FRAC16(-0.25000000000000),
                      FRAC16(0.38579974878009),FRAC16(0.41141446721710),FRAC16(0.39758361765043)};
    Result res;
    UInt16 i;
   
    for(i = 0; i < 21; i++)
    {
	     z16 = tfr16Atan2OverPI(y16[i],x16[i]);
		  if (exp_z[i]<=z16+3 && exp_z[i] >= z16-3) 
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
    {
        testFailed(&testRec,"tfr16Atan2OverPI did not return PASS");
    }
    else 
    {
        testComment(&testRec,"tfr16Atan2OverPI Passed");
    }
}


/*******************************************************************
* Test sineWaveGenIDTL
********************************************************************/

#define IDTL_SINE_TABLE_LEN 100
#define IDTL_NUM_SAMPLES     30
{
	Frac16                   sineTable [IDTL_SINE_TABLE_LEN];
	int                      i;
	tfr16_tSineWaveGenIDTL * pSWG;
	Frac16                 * pSineTable;
	Frac16                   idtlValues[IDTL_NUM_SAMPLES];
	Frac16                   oneIDTLValue;
	tfr16_tSineWaveGenIDTL   swgState;
	bool                     bPassed = true;
	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<IDTL_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	
	pSWG = tfr16SineWaveGenIDTLCreate(&sineTable[0],
												 IDTL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	tfr16SineWaveGenIDTL(pSWG, &idtlValues[0], 30);

	tfr16SineWaveGenIDTLDestroy(pSWG);

	pSWG = tfr16SineWaveGenIDTLCreate(&sineTable[0],
												 IDTL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	for (i=0; i<30; i++) 
	{
		tfr16SineWaveGenIDTLC(pSWG, &oneIDTLValue, 1);
		
		if (oneIDTLValue != idtlValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenIDTL != tfr16SineWaveGenIDTLC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenIDTLDestroy(pSWG);

	/* Test aligned sine wave table */
	
	pSineTable = memMallocAlignedEM (sizeof(sineTable));
	
	assert (pSineTable != NULL);
	
	memcpy (pSineTable, &sineTable[0], sizeof(sineTable));
	
	tfr16SineWaveGenIDTLInit ( &swgState,
										pSineTable,
										IDTL_SINE_TABLE_LEN,
										100,
										1000,
										0x2000);

	tfr16SineWaveGenIDTL(&swgState, &idtlValues[0], 30);

	tfr16SineWaveGenIDTLInit ( &swgState,
								pSineTable,
								IDTL_SINE_TABLE_LEN,
								100,
								1000,
								0x2000);

	for (i=0; i<30; i++) 
	{
		tfr16SineWaveGenIDTLC(&swgState, &oneIDTLValue, 1);
		
		if (oneIDTLValue != idtlValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenIDTL != tfr16SineWaveGenIDTLC (aligned)");
			bPassed = false;
			break;
		}
	}
	
	if (idtlValues[0] != 0x000c)
	{
		testComment(&testRec, "tfr16SineWaveGenIDTL phase shift failed");
	}
	
	memFreeEM (pSineTable);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenIDTL Passed");
	}
}	

/*******************************************************************
* Test sineWaveGenRDTL
********************************************************************/

#define RDTL_SINE_TABLE_LEN 100
#define RDTL_NUM_SAMPLES     30
{
	Frac16                   sineTable [RDTL_SINE_TABLE_LEN];
	int                      i;
	tfr16_tSineWaveGenRDTL * pSWG;
	Frac16                 * pSineTable;
	Frac16                   rdtlValues[RDTL_NUM_SAMPLES];
	Frac16                   oneRDTLValue;
	bool                     bPassed = true;
	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<RDTL_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16SineWaveGenRDTLCreate(&sineTable[0],
												 RDTL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	tfr16SineWaveGenRDTL(pSWG, &rdtlValues[0], 30);

	tfr16SineWaveGenRDTLDestroy(pSWG);

	pSWG = tfr16SineWaveGenRDTLCreate(&sineTable[0],
												 RDTL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	for (i=0; i<30; i++) 
	{
		tfr16SineWaveGenRDTLC(pSWG, &oneRDTLValue, 1);
		
		if (oneRDTLValue != rdtlValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenRDTL != tfr16SineWaveGenRDTLC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenRDTLDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenRDTL Passed");
	}
	
}


/*******************************************************************
* Test sineWaveGenRDITL
********************************************************************/

#define RDITL_SINE_TABLE_LEN 100
#define RDITL_NUM_SAMPLES     30
{
	Frac16                   sineTable [RDITL_SINE_TABLE_LEN];
	int                      i;
	tfr16_tSineWaveGenRDITL * pSWG;
	Frac16                 * pSineTable;
	Frac16                   rditlValues[RDITL_NUM_SAMPLES];
	Frac16                   oneRDITLValue;
	bool                     bPassed = true;
	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<RDITL_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16SineWaveGenRDITLCreate(&sineTable[0],
												 RDITL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	tfr16SineWaveGenRDITL(pSWG, &rditlValues[0], 30);

	tfr16SineWaveGenRDITLDestroy(pSWG);

	pSWG = tfr16SineWaveGenRDITLCreate(&sineTable[0],
												 RDITL_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	for (i=0; i<30; i++) 
	{
		tfr16SineWaveGenRDITLC(pSWG, &oneRDITLValue, 1);
		
		if (oneRDITLValue != rditlValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenRDITL != tfr16SineWaveGenRDITLC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenRDITLDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenRDITL Passed");
	}
	
}


/*******************************************************************
* Test sineWaveGenDOM
********************************************************************/

#define DOM_NUM_SAMPLES     20
{
	tfr16_tSineWaveGenDOM   * pSWG;
	Frac16                    domValues[DOM_NUM_SAMPLES];
	Frac16                    oneDOMValue;
	Frac16                    InitialPhasePIx  = 8192;
	Frac16                    Amplitude        = 32767; 
	UInt16                    SineFreq         = 1000;
	UInt16                    SampleFreq       = 32000;
	bool                      bPassed          = true;
	int                       i;

	pSWG = tfr16SineWaveGenDOMCreate(SineFreq, SampleFreq, InitialPhasePIx, Amplitude);
	
	tfr16SineWaveGenDOM(pSWG, (Frac16 *)&domValues, DOM_NUM_SAMPLES);

	tfr16SineWaveGenDOMDestroy(pSWG);

	pSWG = tfr16SineWaveGenDOMCreate(SineFreq, SampleFreq, InitialPhasePIx, Amplitude);

	for(i = 0; i < DOM_NUM_SAMPLES; i++)
	{
		tfr16SineWaveGenDOMC(pSWG, &oneDOMValue, 1);

		if (oneDOMValue != domValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenDOM != tfr16SineWaveGenDOMC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenDOMDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenDOM Passed");
	}
}

/*******************************************************************
* Test sineWaveGenPAM
********************************************************************/

#define PAM_NUM_SAMPLES     20
{
	tfr16_tSineWaveGenPAM   * pSWG;
	Frac16                    pamValues[PAM_NUM_SAMPLES];
	Frac16                    onePAMValue;
	Frac16                    InitialPhasePIx  = 8192;
	Frac16                    Amplitude        = 32767; 
	UInt16                    SineFreq         = 1000;
	UInt16                    SampleFreq       = 32000;
	bool                      bPassed          = true;
	int                       i;

	pSWG = tfr16SineWaveGenPAMCreate(SineFreq, SampleFreq, InitialPhasePIx, Amplitude);
	
	tfr16SineWaveGenPAM(pSWG, (Frac16 *)&pamValues, PAM_NUM_SAMPLES);

	tfr16SineWaveGenPAMDestroy(pSWG);

	pSWG = tfr16SineWaveGenPAMCreate(SineFreq, SampleFreq, InitialPhasePIx, Amplitude);

	for(i = 0; i < PAM_NUM_SAMPLES; i++)
	{
		tfr16SineWaveGenPAMC(pSWG, &onePAMValue, 1);

		if (onePAMValue != pamValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenPAM != tfr16SineWaveGenPAMC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenPAMDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenPAM Passed");
	}
}

/*******************************************************************
* Test tfr16SineWaveGenRDITLQ
********************************************************************/
#define RDITLQ_SINE_TABLE_LEN 100
#define RDITLQ_NUM_SAMPLES     30
{
	Frac16                     sineTable [RDITLQ_SINE_TABLE_LEN];
	int                        i;
	tfr16_tSineWaveGenRDITLQ * pSWG;
	Frac16                   * pSineTable;
	Frac16                     rditlqValues[RDITL_NUM_SAMPLES];
	Frac16                     oneRDITLQValue;
	bool                       bPassed = true;
	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<RDITLQ_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16SineWaveGenRDITLQCreate(&sineTable[0],
												 RDITLQ_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	tfr16SineWaveGenRDITLQ(pSWG, &rditlqValues[0], 30);

	tfr16SineWaveGenRDITLQDestroy(pSWG);

	pSWG = tfr16SineWaveGenRDITLQCreate(&sineTable[0],
												 RDITLQ_SINE_TABLE_LEN,
												 100,
												 1000,
												 0);

	for (i=0; i<30; i++) 
	{
		tfr16SineWaveGenRDITLQC(pSWG, &oneRDITLQValue, 1);
		
		if (oneRDITLQValue != rditlqValues[i])
		{
			testFailed(&testRec, "tfr16SineWaveGenRDITLQ != tfr16SineWaveGenRDITLQC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SineWaveGenRDITLQDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SineWaveGenRDITLQ Passed");
	}
	
}


/*******************************************************************
* Test tfr16WaveGenRDITLQ
********************************************************************/
#define RDITLQ_WAVE_SINE_TABLE_LEN 100
#define RDITLQ_WAVE_NUM_SAMPLES     30
{
	Frac16                     sineTable [RDITLQ_WAVE_SINE_TABLE_LEN];
	int                        i;
	tfr16_tWaveGenRDITLQ     * pSWG;
	Frac16                   * pSineTable;
	Frac16                     rditlqwaveValues[RDITLQ_WAVE_NUM_SAMPLES];
	Frac16                     oneRDITLQWaveValue;
	bool                       bPassed = true;
	Frac16                     InitialPhasePIx = 0;
	Frac16                     PhaseIncrement  = 1024;

	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<RDITLQ_WAVE_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16WaveGenRDITLQCreate(&sineTable[0],
									 RDITLQ_WAVE_SINE_TABLE_LEN,
								 	 InitialPhasePIx);


	for(i = 0; i < 30; i++)
	{
		rditlqwaveValues[i] = tfr16WaveGenRDITLQ(pSWG, PhaseIncrement);
	}

	tfr16WaveGenRDITLQDestroy(pSWG);

	pSWG = tfr16WaveGenRDITLQCreate(&sineTable[0],
									 RDITLQ_WAVE_SINE_TABLE_LEN,
									 InitialPhasePIx);

	for (i=0; i < 30; i++) 
	{
		oneRDITLQWaveValue = tfr16WaveGenRDITLQC(pSWG, PhaseIncrement);
		
		if (oneRDITLQWaveValue != rditlqwaveValues[i])
		{
			testFailed(&testRec, "tfr16WaveGenRDITLQ != tfr16WaveGenRDITLQC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16WaveGenRDITLQDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16WaveGenRDITLQ Passed");
	}
	
}

/*******************************************************************
* Test tfr16SinPIxLUT
********************************************************************/
#define SINPIX_SINE_TABLE_LEN 100
#define SINPIX_NUM_SAMPLES     30
{
	Frac16                     sineTable [SINPIX_SINE_TABLE_LEN];
	int                        i;
	tfr16_tSinPIxLUT         * pSWG;
	Frac16                   * pSineTable;
	Frac16                     sinpixValues[SINPIX_NUM_SAMPLES];
	Frac16                     oneSINPIxValue;
	bool                       bPassed = true;
	Frac16                     InitialPhasePIx = 0;
	Frac16                     PhaseIncrement  = 1024;

	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<SINPIX_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16SinPIxLUTCreate(&sineTable[0],
								 SINPIX_SINE_TABLE_LEN);


	for(i = 0; i < 30; i++)
	{
		sinpixValues[i] = tfr16SinPIxLUT(pSWG, PhaseIncrement);
	}

	tfr16SinPIxLUTDestroy(pSWG);

	pSWG = tfr16SinPIxLUTCreate(&sineTable[0],
								 SINPIX_SINE_TABLE_LEN);

	for (i=0; i < 30; i++) 
	{
		oneSINPIxValue = tfr16SinPIxLUTC(pSWG, PhaseIncrement);
		
		if (oneSINPIxValue != sinpixValues[i])
		{
			testFailed(&testRec, "tfr16SinPIxLUT != tfr16SinPIxLUTC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16SinPIxLUTDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16SinPIxLUT Passed");
	}
	
}

/*******************************************************************
* Test tfr16CosPIxLUT
********************************************************************/
#define COSPIX_SINE_TABLE_LEN 100
#define COSPIX_NUM_SAMPLES     30
{
	Frac16                     sineTable [COSPIX_SINE_TABLE_LEN];
	int                        i;
	tfr16_tCosPIxLUT         * pSWG;
	Frac16                   * pSineTable;
	Frac16                     cospixValues[COSPIX_NUM_SAMPLES];
	Frac16                     oneCosPIxValue;
	bool                       bPassed = true;
	Frac16                     InitialPhasePIx = 0;
	Frac16                     PhaseIncrement  = 1024;

	
	/* Initialize dummy sine table with arbitrary values */
	for (i=0; i<COSPIX_SINE_TABLE_LEN; i++)
	{
		sineTable[i] = (Frac16)i;
	}

	/* Test non-aligned sine wave table */
	pSWG = tfr16CosPIxLUTCreate(&sineTable[0],
								 COSPIX_SINE_TABLE_LEN);


	for(i = 0; i < 30; i++)
	{
		cospixValues[i] = tfr16CosPIxLUT(pSWG, PhaseIncrement);
	}

	tfr16CosPIxLUTDestroy(pSWG);

	pSWG = tfr16CosPIxLUTCreate(&sineTable[0],
								 COSPIX_SINE_TABLE_LEN);

	for (i=0; i < 30; i++) 
	{
		oneCosPIxValue = tfr16CosPIxLUTC(pSWG, PhaseIncrement);
		
		if (oneCosPIxValue != cospixValues[i])
		{
			testFailed(&testRec, "tfr16CosPIxLUT != tfr16CosPIxLUTC (non-aligned)");
			bPassed = false;
			break;
		}
	}
	
	tfr16CosPIxLUTDestroy(pSWG);

	if (bPassed)
	{
		testComment(&testRec,"tfr16CosPIxLUT Passed");
	}
	
}

	testEnd(&testRec);

	return PASS;
}
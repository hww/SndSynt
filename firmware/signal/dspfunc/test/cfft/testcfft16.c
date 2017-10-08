/********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*********************************************************************
*
* File Name: testCfft16.c
*
* Description: Includes test function for bitreverse and complex
*              FFT and IFFT.
*
* Modules Included: testBitRev16 - Tests bit reverse function
*                   testCfft16   - Tests Cfft
*                   testCfft16_for_all_options - Tests Cfft for N = 32
*                                                for all options
*                   testCIfft16_for_all_options - Tests Cifft for N = 32
*                                                for all options
*
* Author(s): Prasad N R
*
* Date: 27 Jan 2000
*
********************************************************************/

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "dfr16.h"
#include "dfr16priv.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"
#include "input_cfft.h"
#include "mem.h"




EXPORT Result dfr16CFFTC (dfr16_tCFFTStruct *, CFrac16 *, CFrac16 *);
EXPORT Result dfr16CIFFTC (dfr16_tCFFTStruct *, CFrac16 *, CFrac16 *);
EXPORT Result dfr16RFFTC (dfr16_tRFFTStruct *, Frac16 *, dfr16_sInplaceCRFFT *);
EXPORT Result dfr16RIFFTC(dfr16_tRFFTStruct *, dfr16_sInplaceCRFFT *, Frac16 *);
EXPORT Result testBitRev16 (void);
EXPORT Result testCfft16(void);
EXPORT Result testCfft16_for_all_options(void);
EXPORT Result testCIfft16_for_all_options (void);


/*--------------------------------------------------------------
* Revision History:
*
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
* -------    ----------    -----------      -----      --------
*   0.1      Sandeep Sehgal    -          31-01-2000   For review.
*   1.0           -            -          16-02-2000   Reviewed and 
*                                                      baselined.
* 
*-------------------------------------------------------------*/
/*--------------------------------------------------------------
*
* FUNCTION:    testBitRev16
*                         
* DESCRIPTION: To test for all the FFT lengths 16,32,64,128,
*              256, 512, 1024, 2048
*
* ARGUMENTS:   None
*                           
* RETURNS:     test case passed, or test case failed 
*               
* GLOBAL 
*  VARIABLES:  CFrac16 pX2048[2048], Actual_op_16,Actual_op_32
*              Actual_op_64, Actual_op_128, Actual_op_256, Actual_op_512
*              Actual_op_1024, Actual_op_2048
*--------------------------------------------------------------*/
  
Result testBitRev16 ()    
{

	UInt16 j,k;
	Result ret_val; 
    CFrac16 *Out_vect;
	test_sRec testRec;
	
	testStart (&testRec, "Testing complex bit reverse...");
	
	for (k = MIN_CFFT_LEN; k <= MAX_CFFT_LEN; k = k<<1)	
	{
		Out_vect=(CFrac16 *) memMallocEM(sizeof(CFrac16)*k);
	
		if (Out_vect==NULL) return FAIL;
	
		for (j=0; j<k; j++)
		{
			Out_vect[j].real=pX_input[j].real;		/*Initialize the test vector with*/
		                                   	        /*the indices for addressing */
			Out_vect[j].imag=pX_input[j].imag;
		
		}
	
	    /* Call to complex bit reverse */
		ret_val = dfr16Cbitrev (Out_vect,Out_vect,k);
	
		if(ret_val == FAIL) 
		{
		    testFailed (&testRec, "Size outside range");
 			return FAIL;
		}
		
        /* Call to complex bit reverse for second time*/
		ret_val=dfr16Cbitrev (Out_vect,Out_vect,k);
	
		if(ret_val==FAIL) 
		{
		    testFailed (&testRec, "Size outside range");
			return FAIL;
		}
	
		for (j=0; j<k; j++) 
		{	
			if(pX_input[j].real != Out_vect[j].real)
			{
				testFailed (&testRec, "Bitreverse failed");
			    return FAIL;
			}
			
			if(pX_input[j].imag	!= Out_vect[j].imag)
			{
				testFailed (&testRec, "Bitreverse failed");
			    return FAIL;
			}	
		}
				
		memFreeEM(Out_vect);
		
		switch (k)
		{
		    case 8:    testComment (&testRec, "Bit reverse Passed for N = 8");
		               break;
		    case 16:   testComment (&testRec, "Bit reverse Passed for N = 16");
		               break;
		    case 32:   testComment (&testRec, "Bit reverse Passed for N = 32");
		               break;
		    case 64:   testComment (&testRec, "Bit reverse Passed for N = 64");
		               break;
		    case 128:  testComment (&testRec, "Bit reverse Passed for N = 128");
		               break;
		    case 256:  testComment (&testRec, "Bit reverse Passed for N = 256");
		               break;
		    case 512:  testComment (&testRec, "Bit reverse Passed for N = 512");
		               break;
		    case 1024: testComment (&testRec, "Bit reverse Passed for N = 1024");
		               break;
		    case 2048: testComment (&testRec, "Bit reverse Passed for N = 2048");
		}
		
	}
	
	testEnd(&testRec);
	printf ("\n");
	return PASS;			
}	


	
/******************************************************************/
/* Test Complex FFT */
/******************************************************************/
    
/*--------------------------------------------------------------
 * Revision History:
 *
 * VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
 * -------    ----------    -----------      -----      --------
 *   0.1      N R Prasad        -          31-01-2000   For review.
 *   1.0          -             -          16-02-2000   Reviewed and 
 *                                                      baselined.
 * 
 *-------------------------------------------------------------*/
/*--------------------------------------------------------------
 * FILE:        testCfft16.c
 *
 * FUNCTION:    testCfft16
 *
 * DESCRIPTION: Tests CFFT for N = 8 to N = 2048.
 *              For all the cases, input is normal and ouput is normal.
 *              NOTE: Matching is up to 14-bits wrt to actual o/p
 *                    (obtained using MATLAB).
 *
 * ARGUMENTS:   None
 *
 * RETURNS:     Pass or Fail
 *
 * GLOBAL 
 *  VARIABLES:  None
 *--------------------------------------------------------------*/
 
Result testCfft16(void)
{
   
    test_sRec testRec;
    testStart (&testRec, "testfft16");
    
    {
    
        Int16 res, flag = true;  /* 1 = true, 0 = false */
        UInt16 n, options = FFT_SCALE_RESULTS_BY_N;
        Int16 i, j, loop;
        CFrac16 *pX;
        const CFrac16 *Expected_Out_cfft;
        dfr16_tCFFTStruct *pCFFT;
        test_sRec testRec;
    
        printf ("Testing CFFT...\n");

        for (n = MIN_CFFT_LEN; n <= MAX_CFFT_LEN; n = n<<1)

        {
            pX = (CFrac16 *) malloc (n * sizeof(CFrac16));
            if (pX == NULL)
            {
                testComment (&testRec, "Memory allocation for PX[n] failed in test code");
                assert (!"Out of Memory");
            }
            
            switch (n)
            {
                case 8:
                          testStart (&testRec, "Testing CFFT for N = 8...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_8[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (8, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 16:
                          testStart (&testRec, "Testing CFFT for N = 16...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_16[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (16, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");                              
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 32:
                          testStart (&testRec, "Testing CFFT for N = 32...");
                          break;
                          
                case 64:
                          testStart (&testRec, "Testing CFFT for N = 64...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_64[0];
                         
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (64, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 128:
                          testStart (&testRec, "Testing CFFT for N = 128...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_128[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (128, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                case 256:
                          testStart (&testRec, "Testing CFFT for N = 256...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_256[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (256, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                case 512:
                          testStart (&testRec, "Testing CFFT for N = 512...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_512[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (512, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                 case 1024:
                          testStart (&testRec, "Testing CFFT for N = 1024...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_1024[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (1024, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                
                          
                 case 2048:
                          testStart (&testRec, "Testing CFFT for N = 2048...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pX[loop].real = pX_input[loop].real;
                              pX[loop].imag = pX_input[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cfft = &Expected_Out_cfft_2048[0];
                          
                          /* Call FFT Create function */
                          pCFFT = dfr16CFFTCreate (2048, options);
                          if (pCFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }         
            }

            if (n == 32)
            {
                testCfft16_for_all_options ();
                testEnd(&testRec);
                printf("\n");
                free (pX);
            }
            else
            {
                /*-------------------------*/
                /* Complex FFT (C Version) */
                /*-------------------------*/
                for (loop = 0; loop < n; loop++)
                {
                    pX[loop].real = pX_input[loop].real;
                    pX[loop].imag = pX_input[loop].imag;
                }
                          
                res = dfr16CFFTC (pCFFT, &pX[0], &pX[0]);
                if (res == FAIL) assert (!"Bit Reverse Failed");
                
                for (i = 0; i < n; i++)
                {
                    if (((((UInt16)pX[i].real - (UInt16)Expected_Out_cfft[i].real) >= -3) ||
                        (((UInt16)pX[i].real - (UInt16)Expected_Out_cfft[i].real) <= 3)) &&
                        ((((UInt16)pX[i].imag - (UInt16)Expected_Out_cfft[i].imag) >= -3) ||
                         (((UInt16)pX[i].imag - (UInt16)Expected_Out_cfft[i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1) 
                {
                    testComment (&testRec, "Complex FFT Passed (C Version)");
                }
                else
                {
                    testFailed (&testRec, "Complex FFT Failed (C Version)");
                    flag = true;
                }


                /*---------------------------*/
                /* Complex FFT (ASM Version) */
                /*---------------------------*/
                /* Have a local copy of the input test vector */
                for (loop = 0; loop < n; loop++)
                {
                    pX[loop].real = pX_input[loop].real;
                    pX[loop].imag = pX_input[loop].imag;
                }
                          
                res = dfr16CFFT (pCFFT, &pX[0], &pX[0]);
                if (res == FAIL) assert (!"Bit Reverse Failed");
                            
                for (i = 0; i < n; i++)
                {
                    if (((((UInt16)pX[i].real - (UInt16)Expected_Out_cfft[i].real) >= -3) ||
                        (((UInt16)pX[i].real - (UInt16)Expected_Out_cfft[i].real) <= 3)) &&
                        ((((UInt16)pX[i].imag - (UInt16)Expected_Out_cfft[i].imag) >= -3) ||
                         (((UInt16)pX[i].imag - (UInt16)Expected_Out_cfft[i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1) 
                {
                    testComment (&testRec, "Complex FFT Passed (ASM Version)");
                }
                else
                {
                    testFailed (&testRec, "Complex FFT Failed (ASM Version)");
                }
                
                /*-------------------------------------*/
                /* Free the local copy of input buffer */
                /*-------------------------------------*/
                free (pX);
            
                /*--------------*/
                /* CFFT destroy */
                /*--------------*/
                dfr16CFFTDestroy (pCFFT);
                testEnd(&testRec);
                printf("\n");
            } 
        }
    }
                
                
  
/******************************************************************/
/* Test Complex Inverse FFT */
/******************************************************************/
    
/*--------------------------------------------------------------
 * Revision History:
 *
 * VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
 * -------    ----------    -----------      -----      --------
 *   0.1      N R Prasad        -          14-02-2000   For review.
 *   1.0          -             -          16-02-2000   Reviewed and 
 *                                                      baselined.                  
 *-------------------------------------------------------------*/

/*--------------------------------------------------------------
 * FILE:        testCfft16.c
 *
 * FUNCTION:    None
 *
 * DESCRIPTION: Tests complex inverse FFT for N = 8 to N = 2048. 
 *              For all the cases, input is normal and ouput is normal.
 *              NOTE: Matching is up to 14-bits wrt to actual o/p
 *                    (obtained using MATLAB).
 *
 * ARGUMENTS:   None
 *
 * RETURNS:     None
 *
 * GLOBAL 
 *  VARIABLES:  None
 *--------------------------------------------------------------*/
   
    {
    
        Int16 res1, flag = true;  /* 1 = true, 0 = false */
        UInt16 n, options = FFT_SCALE_RESULTS_BY_N;
        Int16 i, j, loop;
        CFrac16 *pXI;
        const CFrac16 *Expected_Out_cifft;
        dfr16_tCFFTStruct *pCIFFT;
        test_sRec testRec;
    
        printf ("Testing CIFFT...\n");
                
        for (n = MIN_CIFFT_LEN; n <= MAX_CIFFT_LEN; n = n<<1)
        {
            pXI = (CFrac16 *) malloc (n * sizeof (CFrac16));
            if (pXI == NULL)
            {
                testComment (&testRec, "Memory allocation for PXI[n] failed in test code");
                assert (!"Out of Memory");
            }
            
            switch (n)
            {
                
                case 8:
                          testStart (&testRec, "Testing CIFFT for N = 8...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_8[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_8[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                         
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (8, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 16:
                          testStart (&testRec, "Testing CIFFT for N = 16...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_16[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_16[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                         
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (16, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 32:
                          testStart (&testRec, "Testing CIFFT for N = 32...");
                          break;
                          
                case 64:
                          testStart (&testRec, "Testing CIFFT for N = 64...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_64[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_64[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                          
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (64, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 128:
                          testStart (&testRec, "Testing CIFFT for N = 128...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_128[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_128[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                          
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (128, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 256:
                          testStart (&testRec, "Testing CIFFT for N = 256...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_256[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_256[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                          
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (256, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                case 512:
                          testStart (&testRec, "Testing CIFFT for N = 512...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_512[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_512[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                          
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (512, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                 case 1024:
                          testStart (&testRec, "Testing CIFFT for N = 1024...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_1024[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_1024[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                         
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (1024, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                
                          
                 case 2048:
                          testStart (&testRec, "Testing CIFFT for N = 2048...");
                          
                          /* Have a local copy of the input test vector */
                          for (loop = 0; loop < n; loop++)
                          {
                              pXI[loop].real = Expected_Out_cfft_2048[loop].real;
                              pXI[loop].imag = Expected_Out_cfft_2048[loop].imag;
                          }
                          
                          /* Point to expected output */
                          Expected_Out_cifft = &pX_input[0];
                          
                          /* Call FFT Create function */
                          pCIFFT = dfr16CIFFTCreate (2048, options);
                          if (pCIFFT == NULL)
                          {
                              assert (!"Create failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }                                   
            }

            if (n == 32)
            {
                testCIfft16_for_all_options ();
                testEnd(&testRec);
                printf("\n");
                free (pXI);
            }
            else
            {    
                /*--------------------------*/
                /* Complex IFFT (C Version) */
                /*--------------------------*/
                switch (n)
                {
                    case 8:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_8[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_8[loop].imag;
                               }
                               break;
                           
                    case 16:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_16[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_16[loop].imag;
                               }
                               break;
                           
                    case 32:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_32[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_32[loop].imag;
                               }
                               break;
                           
                    case 64:   /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_64[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_64[loop].imag;
                               }
                               break;
                           
                    case 128:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_128[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_128[loop].imag;
                               }
                               break;
                           
                    case 256:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_256[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_256[loop].imag;
                               }
                               break;
                           
                    case 512:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_512[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_512[loop].imag;
                               }
                               break;
                           
                    case 1024: /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_1024[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_1024[loop].imag;
                               }
                               break;
                           
                    case 2048: /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_2048[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_2048[loop].imag;
                               }
                }
            
                res1 = dfr16CIFFTC (pCIFFT, &pXI[0], &pXI[0]);
                if (res1 == FAIL) assert (!"Bit Reverse Failed");
                            
                /*---------------------*/
                /* Compare the results */
                /*---------------------*/
                for (i = 0; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pXI[i].real - ((UInt16)Expected_Out_cifft[i].real >> res1)) >= -3) ||
                        (((UInt16)pXI[i].real - ((UInt16)Expected_Out_cifft[i].real >> res1)) <= 3)) &&
                        ((((UInt16)pXI[i].imag - ((UInt16)Expected_Out_cifft[i].imag >> res1)) >= -3) ||
                         (((UInt16)pXI[i].imag - ((UInt16)Expected_Out_cifft[i].imag >> res1)) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1)  /* Find out whether IFFT has passed or not */
                {
                    testComment (&testRec, "Complex IFFT Passed (C Version)");
                }
                else
                {
                    testFailed (&testRec, "Complex IFFT Failed (C Version)");
                    flag = true;
                }
    
                /*------------------------*/
                /* Complex IFFT (ASM code)*/
                /*------------------------*/
            
                switch (n)
                {
                    case 8:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_8[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_8[loop].imag;
                               }
                               break;
                           
                    case 16:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_16[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_16[loop].imag;
                               }
                               break;
                           
                    case 32:    /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_32[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_32[loop].imag;
                               }
                               break;
                           
                    case 64:   /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_64[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_64[loop].imag;
                               }
                               break;
                           
                    case 128:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_128[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_128[loop].imag;
                               }
                               break;
                           
                    case 256:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_256[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_256[loop].imag;
                               }
                               break;
                           
                    case 512:  /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_512[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_512[loop].imag;
                               }
                               break;
                           
                    case 1024: /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_1024[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_1024[loop].imag;
                               }
                               break;
                           
                    case 2048: /* Have a local copy of the input test vector */
                               for (loop = 0; loop < n; loop++)
                               {
                                   pXI[loop].real = Expected_Out_cfft_2048[loop].real;
                                   pXI[loop].imag = Expected_Out_cfft_2048[loop].imag;
                               }
                }
            
                res1 = dfr16CIFFT (pCIFFT, &pXI[0], &pXI[0]);
                if (res1 == FAIL) assert (!"Bit Reverse Failed");
            
                /*---------------------*/
                /* Compare the results */
                /*---------------------*/
                for (i = 0; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pXI[i].real - ((UInt16)Expected_Out_cifft[i].real >> res1)) >= -3) ||
                        (((UInt16)pXI[i].real - ((UInt16)Expected_Out_cifft[i].real >> res1)) <= 3)) &&
                        ((((UInt16)pXI[i].imag - ((UInt16)Expected_Out_cifft[i].imag >> res1)) >= -3) ||
                         (((UInt16)pXI[i].imag - ((UInt16)Expected_Out_cifft[i].imag >> res1)) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1)  /* Find out whether IFFT has passed or not */
                {
                    testComment (&testRec, "Complex IFFT Passed (ASM Version)");
                }
                else
                {
                    testFailed (&testRec, "Complex IFFT Failed (ASM Version)");
                    flag = true;
                }
            
                /*---------------------------------------------*/
                /* Free the memory allocated to local variable */
                /*---------------------------------------------*/
                free (pXI);
            
                /*---------------*/
                /* CIFFT destroy */
                /*---------------*/
                dfr16CIFFTDestroy (pCIFFT);
                testEnd(&testRec);
                printf("\n");
            }            
        }
    } /* End of CIFFT */
    
    testEnd (&testRec);
    printf("\n");
	return PASS;
    
}



Result testCfft16_for_all_options (void)
{
        
    /* Check N = 32 CFFT for all options */
    
        Int16 res, flag = true;  /* 1 = true, 0 = false */
        UInt16 n = 32, options;
        Int16 i, j, loop;
        CFrac16 *pX, *pZ;
        const CFrac16 *Expected_Out_cfft;
        dfr16_tCFFTStruct *pCFFT;
        test_sRec testRec;
        
        pX = (CFrac16 *) malloc (n * sizeof(CFrac16));
        if (pX == NULL)
        {
            testComment (&testRec, "Memory allocation for pX[n] failed in test code");
            assert (!"Out of Memory");
        }
        
        pZ = (CFrac16 *) malloc (n * sizeof(CFrac16));
        if (pZ == NULL)
        {
            testComment (&testRec, "Memory allocation for pZ[n] failed in test code");
            assert (!"Out of Memory");
        }
        
                        
        for (options = 1; options < 16; options++)
        {
                            
            if (options == 3 || options == 4 || options == 7 || options == 8 ||
                options == 11 || options == 12 || options == 15)
            {
                continue;
            }
            else
            {
                switch (options)
                {
                    case 0:  Expected_Out_cfft = &Exp_Out_OPT_0[0]; break;
                    case 1:  Expected_Out_cfft = &Exp_Out_OPT_1[0];
                             printf ("Testing for NORMAL INPUT, NORMAL OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 2:  Expected_Out_cfft = &Exp_Out_OPT_2[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 5:  Expected_Out_cfft = &Exp_Out_OPT_5[0];
                             printf ("Testing for BIT-REVERSED INPUT, NORMAL OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 6:  Expected_Out_cfft = &Exp_Out_OPT_6[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 9:  Expected_Out_cfft = &Exp_Out_OPT_9[0];
                             printf ("Testing for NORMAL INPUT, BIT-REVERSED OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 10: Expected_Out_cfft = &Exp_Out_OPT_10[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 13: Expected_Out_cfft = &Exp_Out_OPT_13[0];
                             printf ("Testing for BIT-REVERSED INPUT, BIT-REVERSED OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 14: Expected_Out_cfft = &Exp_Out_OPT_14[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                }
                                         
                /* Call FFT Create function */
                pCFFT = dfr16CFFTCreate (32, options);
                if (pCFFT == NULL)
                {
                    testFailed (&testRec, "Create failed");
                    assert (!"Create failed");
                }
                else
                {
                    testComment (&testRec, "Create passed");
                }
                
                /*---------------------------*/
                /* Complex FFT (C Version) */
                /*---------------------------*/
                for (loop = 0; loop < n; loop++)
                {
                    pX[loop].real = pX_input32[loop].real;
                    pX[loop].imag = pX_input32[loop].imag;
                }
                res = dfr16CFFTC (pCFFT, &pX[0], &pZ[0]);
                if (res == FAIL) assert (!"Bit Reverse Failed");

                /*---------------------*/  
                /* Compare the results */
                /*---------------------*/
                for (i = 0; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pZ[i].real - (UInt16)Expected_Out_cfft[i].real) >= -3) ||
                        (((UInt16)pZ[i].real - (UInt16)Expected_Out_cfft[i].real) <= 3)) &&
                        ((((UInt16)pZ[i].imag - (UInt16)Expected_Out_cfft[i].imag) >= -3) ||
                         (((UInt16)pZ[i].imag - (UInt16)Expected_Out_cfft[i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1)  /* Find out whether FFT has passed or not */
                {
                    testComment (&testRec, "CFFT passed C Code");
                }
                else
                {
                     testFailed (&testRec, "CFFT failed C Code");
                     flag = true;              /* reinitialize the flag */
                }
                      
                /*---------------------------*/
                /* Complex FFT (ASM Version) */
                /*---------------------------*/
                for (loop = 0; loop < n; loop++)
                {
                    pX[loop].real = pX_input32[loop].real;
                    pX[loop].imag = pX_input32[loop].imag;
                }
                res = dfr16CFFT (pCFFT, &pX[0], pZ);
                if (res == FAIL) assert (!"Bit Reverse Failed");

                /*---------------------*/  
                /* Compare the results */
                /*---------------------*/
                for (i = 0; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pZ[i].real - (UInt16)Expected_Out_cfft[i].real) >= -3) ||
                        (((UInt16)pZ[i].real - (UInt16)Expected_Out_cfft[i].real) <= 3)) &&
                        ((((UInt16)pZ[i].imag - (UInt16)Expected_Out_cfft[i].imag) >= -3) ||
                         (((UInt16)pZ[i].imag - (UInt16)Expected_Out_cfft[i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        flag = false;
                        break;
                    }
                }

                if (flag == 1)  /* Find out whether FFT has passed or not */
                {
                    testComment (&testRec, "CFFT passed ASM Code");
                }
                else
                {
                    testFailed (&testRec, "CFFT failed ASM Code");
                    flag = true;

                }
    
                /*--------------*/
                /* CFFT destroy */
                /*--------------*/
                dfr16CFFTDestroy (pCFFT);
                testEnd(&testRec);
                printf("\n");
            }            
        }
        
        /*-------------------------------------*/
        /* Free the local copy of input buffer */
        /*-------------------------------------*/
        
        free (pX);
        free (pZ);
    
    return PASS;
}
    
Result testCIfft16_for_all_options (void)
{    
    /* Check N = 32 CIFFT for all options */
    
        Int16 res, flag = true;  /* 1 = true, 0 = false */
        UInt16 n = 32, options;
        Int16 i, j, loop;
        CFrac16 *pXI, *pZI;
        const CFrac16 *Expected_Out_cifft;
        dfr16_tCFFTStruct *pCIFFT;
        test_sRec testRec;
                
        pXI = (CFrac16 *) malloc (n * sizeof(CFrac16));
        if (pXI == NULL)
        {
            testComment (&testRec, "Memory allocation for pXI[n] failed in test code");
            assert (!"Out of Memory");
        }
        
        pZI = (CFrac16 *) malloc (n * sizeof(CFrac16));
        if (pZI == NULL)
        {
            testComment (&testRec, "Memory allocation for pZI[n] failed in test code");
            assert (!"Out of Memory");
        }
                          
                                   
        for (options = 1; options < 16; options++)
        {
            if (options == 3 || options == 4 || options == 7 || options == 8 ||
                options == 11 || options == 12 || options == 15)
            {
                continue;
            }
            else
            {
                switch (options)
                {                    
                    case 0:  Expected_Out_cifft = &Exp_Out_OPT_0[0]; break;
                    case 1:  Expected_Out_cifft = &Exp_Out_OPT_1[0];
                             printf ("Testing for NORMAL INPUT, NORMAL OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 2:  Expected_Out_cifft = &Exp_Out_OPT_2[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 5:  Expected_Out_cifft = &Exp_Out_OPT_5[0];
                             printf ("Testing for BIT-REVERSED INPUT, NORMAL OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 6:  Expected_Out_cifft = &Exp_Out_OPT_6[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 9:  Expected_Out_cifft = &Exp_Out_OPT_9[0];
                             printf ("Testing for NORMAL INPUT, BIT-REVERSED OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 10: Expected_Out_cifft = &Exp_Out_OPT_10[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;
                    case 13: Expected_Out_cifft = &Exp_Out_OPT_13[0];
                             printf ("Testing for BIT-REVERSED INPUT, BIT-REVERSED OUTPUT...Started\n");
                             testStart (&testRec, "Opt: SCALE_BY_N");
                             break;
                    case 14: Expected_Out_cifft = &Exp_Out_OPT_14[0];
                             testStart (&testRec, "Opt: SCALE_BY_DATA_SIZE");
                             break;

                }
                
                                         
                /* Call FFT Create function */
                pCIFFT = dfr16CIFFTCreate (32, options);
                if (pCIFFT == NULL)
                {
                    assert (!"Create failed");
                }
                else
                {
                    testComment (&testRec, "Create passed");
                }
                
                
                /*----------------------------*/
                /* Complex IFFT (C Version) */
                /*----------------------------*/
                /* Have a local copy of the input test vector */
                for (loop = 0; loop < n; loop++)
                {
                    pXI[loop].real = pX_input32[loop].real;
                    pXI[loop].imag = pX_input32[loop].imag;
                }
                res = dfr16CIFFTC (pCIFFT, &pXI[0], &pZI[0]);
                if (res == FAIL) assert (!"Bit Reverse Failed");
               
                /*---------------------*/  
                /* Compare the results */
                /*---------------------*/
                
                for (i = 1; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pZI[i].real - (UInt16)Expected_Out_cifft[n-i].real) >= -3) ||
                        (((UInt16)pZI[i].real - (UInt16)Expected_Out_cifft[n-i].real) <= 3)) &&
                        ((((UInt16)pZI[i].imag - (UInt16)Expected_Out_cifft[n-i].imag) >= -3) ||
                         (((UInt16)pZI[i].imag - (UInt16)Expected_Out_cifft[n-i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        if (((((UInt16)pZI[0].real - (UInt16)Expected_Out_cifft[0].real) >= -3) ||
                            (((UInt16)pZI[0].real - (UInt16)Expected_Out_cifft[0].real) <= 3)) &&
                            ((((UInt16)pZI[0].imag - (UInt16)Expected_Out_cifft[0].imag) >= -3) ||
                             (((UInt16)pZI[0].imag - (UInt16)Expected_Out_cifft[0].imag) <= 3)))
                        {
                            break;
                        }
                        else
                        { 
                            flag = false;
                            break;
                        }
                    }
                }

                if (flag)  /* Find out whether IFFT has passed or not */
                {
                    testComment (&testRec, "CIFFT passed C Code");
                }
                else
                {
                    testFailed (&testRec, "CIFFT failed C Code");
                    flag = true;
                }
          
                /*----------------------------*/
                /* Complex IFFT (ASM Version) */
                /*----------------------------*/
                /* Have a local copy of the input test vector */
                for (loop = 0; loop < n; loop++)
                {
                    pXI[loop].real = pX_input32[loop].real;
                    pXI[loop].imag = pX_input32[loop].imag;
                }
                
                res = dfr16CIFFT (pCIFFT, &pXI[0], pZI);
                if (res == FAIL) assert (!"Bit Reverse Failed");

                /*---------------------*/  
                /* Compare the results */
                /*---------------------*/
                
                for (i = 1; i < n; i++)
                {
                    /* Check for accuracy upto 14 bits (out of 16 bits) */
                    if (((((UInt16)pZI[i].real - (UInt16)Expected_Out_cifft[n-i].real) >= -3) ||
                        (((UInt16)pZI[i].real - (UInt16)Expected_Out_cifft[n-i].real) <= 3)) &&
                        ((((UInt16)pZI[i].imag - (UInt16)Expected_Out_cifft[n-i].imag) >= -3) ||
                         (((UInt16)pZI[i].imag - (UInt16)Expected_Out_cifft[n-i].imag) <= 3)))
                    {
                        continue;
                    }
                    else
                    {
                        if (((((UInt16)pZI[0].real - (UInt16)Expected_Out_cifft[0].real) >= -3) ||
                            (((UInt16)pZI[0].real - (UInt16)Expected_Out_cifft[0].real) <= 3)) &&
                            ((((UInt16)pZI[0].imag - (UInt16)Expected_Out_cifft[0].imag) >= -3) ||
                             (((UInt16)pZI[0].imag - (UInt16)Expected_Out_cifft[0].imag) <= 3)))
                        {
                            break;
                        }
                        else
                        { 
                            flag = false;
                            break;
                        }
                    }
                }

                if (flag)  /* Find out whether IFFT has passed or not */
                {
                    testComment (&testRec, "CIFFT passed ASM Code");
                }
                else
                {
                    testFailed (&testRec, "CIFFT failed ASM Code");
                    flag = true;
                }
    
                /*--------------*/
                /* CFFT destroy */
                /*--------------*/
                dfr16CIFFTDestroy (pCIFFT);
                testEnd(&testRec);
                printf("\n");
            }
        } 
        
        /*-------------------------------------*/
        /* Free the local copy of input buffer */
        /*-------------------------------------*/
        free (pXI);
        free (pZI);
    
    
	return PASS;   
}

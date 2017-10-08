/********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*********************************************************************
*
* File Name: testRfft16.c
*
* Description: Includes test function for real FFT and IFFT.
*
* Modules Included: testRfft16   - Tests Rfft
*                   testRfft32 - Tests Rfft for N = 32 for all options
*                   testRifft32 - Tests Rifft for N = 32 for all options
*
* Author(s): Sandeep S
*
* Date: 10 Feb 2000
*
********************************************************************/

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "dfr16.h"
#include "dfr16.h"
#include "dfr16priv.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"
#include "input_rfft.h"
#include "mem.h"


EXPORT Result testRfft16 (void);
EXPORT Result testRfft32(UInt16 n);
EXPORT Result testRifft32(UInt16 n);
EXPORT Result dfr16CFFTC (dfr16_tCFFTStruct *, CFrac16 *, CFrac16 *);
EXPORT Result dfr16RFFTC (dfr16_tRFFTStruct *, Frac16 *, dfr16_sInplaceCRFFT *);
EXPORT Result dfr16CIFFTC (dfr16_tCFFTStruct *, CFrac16 *, CFrac16 *);
EXPORT Result dfr16RIFFTC(dfr16_tRFFTStruct *, dfr16_sInplaceCRFFT *, Frac16 *);


/********************************************************************/
/* Test case for Real fft                                           */
/********************************************************************/

/*--------------------------------------------------------------
* Revision History:
*
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
* -------    ----------    -----------      -----      --------
*   0.1      Sandeep Sehgal    -          10-02-2000   For review.
*   1.0           -            -          16-02-2000   Reviewed and
*                                                      baselined
* 
*-------------------------------------------------------------*/
/*--------------------------------------------------------------
* FILE:        testRfft.c
*
* FUNCTION:    Test routine for Real FFT 
*                         
*
* DESCRIPTION: To test for all the Real FFT lengths 8,16,32,64,128,
*              256, 512, 1024, 2048
*             
*
* ARGUMENTS:   
*                           
*              
*
* RETURNS:  Test case passed or test case failed   
*               
*
* GLOBAL VARIABLES:  CFrac16 pX_input[2048], Actual_op_16,Actual_op_32
*             Actual_op_64, Actual_op_128, Actual_op_256, Actual_op_512
*             Actual_op_1024, Actual_op_2048,Actual_op_option_1,
*             Actual_op_option_2,pX32_input
*--------------------------------------------------------------*/

Result testRfft16 ()
{
    test_sRec      testRec;
    testStart (&testRec, "testfft16");
	
	/* Testing with Assembly version of real FFT code*/
    
	{
	    Int16 res, flag = 1;  /* 1 = Pass, 0 = Fail */
        UInt16 n, options = FFT_SCALE_RESULTS_BY_N;
        Int16 i, j;
        Frac16 *pX,*pX2048,*pX32;
        const CFrac16 *Actual_op;
        dfr16_sInplaceCRFFT *pZ;
        dfr16_tRFFTStruct *pRFFT;
        test_sRec testRec;
        
        pX2048 = (Frac16 *) pX_input;
        pX32 = (Frac16 *) pX32_input;

        printf ("Testing RFFT...\n");
        
        for (n = RFFT_MIN_LENGTH; n <= RFFT_MAX_LENGTH; n = n<<1)

        {
            pX=(Frac16 *) memMallocEM(n*sizeof(Frac16));
            if (pX == NULL)
            {
                assert(!"Cannot allocate memory");

            }   
            
            pZ=(dfr16_sInplaceCRFFT *) memMallocEM(sizeof(dfr16_sInplaceCRFFT) + 
                sizeof(CFrac16)*(n/2-2));
            if (pZ == NULL)
            {
                assert(!"Cannot allocate memory");
            }    
                      
            
            switch (n)
            {
                
                case 8:
                          testStart (&testRec, "Testing Real FFT for N = 8...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_8[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (8, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                          
                case 16:
                          testStart (&testRec, "Testing Real FFT for N = 16...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_16[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (16, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 32:
                          testStart (&testRec, "Testing Real FFT for N = 32...");
                          memFreeEM(pZ);
                          memFreeEM(pX);
                          break;
                          
                case 64:
                          testStart (&testRec, "Testing Real FFT for N = 64...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_64[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (64, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
              
                case 128:
                          testStart (&testRec, "Testing Real FFT for N = 128...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_128[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (128, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 256:
                          testStart (&testRec, "Testing Real FFT for N = 256...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_256[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (256, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                case 512:
                          testStart (&testRec, "Testing Real FFT for N = 512...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_512[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (512, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 1024:
                          testStart (&testRec, "Testing Real FFT for N = 1024...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_1024[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (1024, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                 case 2048:
                          testStart (&testRec, "Testing Real FFT for N = 2048...");
                          for (i=0; i < n; i++)
                              pX[i] = pX2048[i];
                          Actual_op = &Actual_op_2048[0];
                          
                          /* Call FFT Create function */
                          pRFFT = dfr16RFFTCreate (2048, options);
                          if (pRFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;                          
                          
            }
      
        
           /* Real FFT */
            
           if (n == 32)  /* For 32 case */
           {
               testRfft32(n);
               testEnd(&testRec);
               printf("\n");
           }
      
           else /* For all other lengths */
           {                 
                res = dfr16RFFTC (pRFFT, &pX[0], pZ); 
                if (res == FAIL) assert (!"Bit Reverse Failed");
     
                /* Compare the results */
                
                if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
                    || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
                {
                      testFailed (&testRec, "Real FFT Failed for C code");
                      flag = 0;
                }
                    
                if (flag)
                {
                    for (i = 0; i < ((pRFFT->n)-1); i++)
                    {
                        if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                            (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                        {    
                            testFailed (&testRec, "Real FFT Failed for C code");
                            flag =0;
                            break;
                        }
                    }
                }
                
                if (flag)
                {
                    testComment (&testRec, "Real FFT Passed for C code");
                }
                else
                {
                   flag =1;
                }   
                
                res = dfr16RFFT (pRFFT, &pX[0], &pZ[0]);
                if (res == FAIL) assert (!"Bit Reverse Failed");
     
                /* Compare the results */
                
                if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
                    || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
                {
                      testFailed (&testRec, "Real FFT Failed for ASM code");
                      flag = 0;    
                }
                
                if (flag)
                {
                    for (i = 0; i < ((pRFFT->n)-1); i++)
                    {
                        if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                            (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                        {    
                            testFailed (&testRec, "Real FFT Failed for ASM code");
                            flag =0;
                            break;  
                        }
                    }
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real FFT Passed for ASM code");
                }
                else
                {
                    flag =1;
                }    
               
                memFreeEM(pZ);  /* Free up the dynamic memory*/
                memFreeEM(pX);  /* Free up the dynamic memory*/
    
                /* RFFT destroy */
                dfr16RFFTDestroy (pRFFT);
                testEnd(&testRec);
                printf("\n");                
    
            }                                  
       }
	}
	


/********************************************************************/
/* Test case for Real Inverse fft testing                                   */
/********************************************************************/

/*--------------------------------------------------------------
* Revision History:
*
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
* -------    ----------    -----------      -----      --------
*   0.1      Sandeep Sehgal    -          10-02-2000   For review.
*   1.0           -            -          16-02-2000   Reviewed and 
*                                                      baselined.
* 
*-------------------------------------------------------------*/
/*--------------------------------------------------------------
* FILE:        testRfft16.c
*
* FUNCTION:    None 
*                         
*
* DESCRIPTION: To test for all the Real Inverse FFT lengths 16,32,64,128,
*              256, 512, 1024, 2048
*             
*
* ARGUMENTS:   None 
*                           
*              
*
* RETURNS:     Test case passed, or test case failed  
*               
*
* GLOBAL VARIABLES:  CFrac16 pX_input[2048], Actual_op_16,Actual_op_32
*             Actual_op_64, Actual_op_128, Actual_op_256, Actual_op_512
*             Actual_op_1024, Actual_op_2048,Actual_op_option_1,
*             Actual_op_option_2,pX32_input
*--------------------------------------------------------------*/

    archSetNoSat(); 
    {
    
        Int16 res, flag = 1;  /* 1 = Pass, 0 = Fail */
        UInt16 n, options = FFT_SCALE_RESULTS_BY_N;
        Int16 i, j;
        Frac16 *pXI;
        CFrac16 *pX32;
        const Frac16 *Actual_op;
        dfr16_sInplaceCRFFT *pZI;
        dfr16_tRFFTStruct *pRIFFT;
        test_sRec testRec;
        Frac16 t;
      
        pX32 = (CFrac16 *)pX32_input;

        printf ("Testing Real Inverse FFT...\n");

        for (n = RIFFT_MIN_LENGTH; n <= RIFFT_MAX_LENGTH; n = n<<1)
        {
            pXI=(Frac16 *) memMallocEM(n*sizeof(Frac16));
            if (pXI == NULL)
            {
                assert (!"Cannot allocate the memory"); 
            }    
            
            pZI=(dfr16_sInplaceCRFFT *) memMallocEM(sizeof(dfr16_sInplaceCRFFT) + 
                 sizeof(CFrac16)*(n/2-2));
           if (pZI == NULL)
           {
                assert (!"Cannot allocate memory");
           }     
                
             switch (n)
            {
                 
                 case 8:
                          testStart (&testRec, "Testing Real IFFT for N = 8...");
                          
                          pZI->z0 = Actual_op_8[0].real;
                          pZI->zNDiv2 = Actual_op_8[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_8[i+1].real;
                              pZI->cz[i].imag = Actual_op_8[i+1].imag;
                          }    
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (8, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
          
                case 16:
                          testStart (&testRec, "Testing Real IFFT for N = 16...");
                          
                          pZI->z0 = Actual_op_16[0].real;
                          pZI->zNDiv2 = Actual_op_16[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_16[i+1].real;
                              pZI->cz[i].imag = Actual_op_16[i+1].imag;
                          }    
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (16, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 32:
                          testStart (&testRec, "Testing Real IFFT for N = 32...");
                          memFreeEM(pZI);
                          memFreeEM(pXI);
                          break;
                          
                case 64:
                          testStart (&testRec, "Testing Real IFFT for N = 64...");
                          pZI->z0 = Actual_op_64[0].real;
                          pZI->zNDiv2 = Actual_op_64[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_64[i+1].real;
                              pZI->cz[i].imag = Actual_op_64[i+1].imag;
                          }
                              
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (64, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                case 128:
                          testStart (&testRec, "Testing Real IFFT for N = 128...");
                          pZI->z0 = Actual_op_128[0].real;
                          pZI->zNDiv2 = Actual_op_128[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_128[i+1].real;
                              pZI->cz[i].imag = Actual_op_128[i+1].imag;
                          } 
                             
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (128, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 256:
                          testStart (&testRec, "Testing Real IFFT for N = 256...");
                          pZI->z0 = Actual_op_256[0].real;
                          pZI->zNDiv2 = Actual_op_256[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_256[i+1].real;
                              pZI->cz[i].imag = Actual_op_256[i+1].imag;
                          }
                              
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (256, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                           
                case 512:
                          testStart (&testRec, "Testing Real IFFT for N = 512...");
                          pZI->z0 = Actual_op_512[0].real;
                          pZI->zNDiv2 = Actual_op_512[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_512[i+1].real;
                              pZI->cz[i].imag = Actual_op_512[i+1].imag;
                          }    
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (512, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                case 1024:
                          testStart (&testRec, "Testing Real IFFT for N = 1024...");
                          pZI->z0 = Actual_op_1024[0].real;
                          pZI->zNDiv2 = Actual_op_1024[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_1024[i+1].real;
                              pZI->cz[i].imag = Actual_op_1024[i+1].imag;
                          }    
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (1024, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;
                          
                 case 2048:
                          testStart (&testRec, "Testing Real IFFT for N = 2048...");
                          pZI->z0 = Actual_op_2048[0].real;
                          pZI->zNDiv2 = Actual_op_2048[0].imag;
                          for (i=0; i < (n/2-1); i++)
                          {
                              pZI->cz[i].real = Actual_op_2048[i+1].real;
                              pZI->cz[i].imag = Actual_op_2048[i+1].imag;
                          }    
                          Actual_op = (Frac16 *)&pX_input[0];
                          
                          /* Call FFT Create function */
                          pRIFFT = dfr16RIFFTCreate (2048, options);
                          if (pRIFFT == NULL)
                          {
                              assert(!"Create Failed");
                          }
                          else
                          {
                              testComment (&testRec, "Create Passed");
                          }
                          break;                          
                          
            }

            if ( n == 32)
            {
                testRifft32(n);
                testEnd(&testRec);
                printf("\n");                                    
            }
            else
            {
            
                /* Real Inverse FFT */
                res = dfr16RIFFTC (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                     assert(!"Bitreversed Failed");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])/(2*(pRIFFT->n))) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for C code");
                        flag = 0;
                        break;
                    }
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for C code");
                }
                else
                {
                    flag = 1;
                }
    
    
                /* Real Inverse FFT */
                res = dfr16RIFFT (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                    assert(!"Bitreversed Failed");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])/(2*(pRIFFT->n))) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for ASM code");
                        flag =0;
                        break;   
                    }
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for ASM code");
                }
                else
                {
                    flag = 1;
                }    

                memFreeEM(pZI);               
                memFreeEM(pXI);

                /* RIFFT destroy */
                dfr16RIFFTDestroy (pRIFFT);
                testEnd(&testRec);
                printf("\n");                
                        
            }        
        }
        
    }/* End of Real Inverse FFT test */
    
    testEnd (&testRec);
    printf("\n");
    return PASS;

}	



Result testRfft32(UInt16 n)
{
    Int16 res, flag = 1;  /* 1 = Pass, 0 = Fail */
    UInt16 options = 1;
    Int16 i, j;
    Frac16 *pX,*pX2048,*pX32;
    const CFrac16 *Actual_op;
    dfr16_sInplaceCRFFT *pZ;
    dfr16_tRFFTStruct *pRFFT;
    test_sRec testRec;
    
    pX2048 = (Frac16 *) pX_input;
    pX32 = (Frac16 *) pX32_input;
    
        pX=(Frac16 *) memMallocEM(n*sizeof(Frac16));
        if (pX == NULL)
        {
            assert(!"Cannot allocate memory");

        }   
        
        pZ=(dfr16_sInplaceCRFFT *) memMallocEM(sizeof(dfr16_sInplaceCRFFT) + 
            sizeof(CFrac16)*(n/2-2));
        if (pZ == NULL)
        {
            assert(!"Cannot allocate memory");
        } 
        
          /*Test for option = FFT_SCALE_RESULTS_BY_N */
          
          testStart(&testRec, "Option : SCALE_BY_N ");
          options = FFT_SCALE_RESULTS_BY_N;
          for (i=0; i < n; i++)
              pX[i] = pX32[i];
          Actual_op = &Actual_op_option_1[0];
          
          /* Call FFT Create function */
          pRFFT = dfr16RFFTCreate (32, options);
          if (pRFFT == NULL)
          {
              assert(!"Create Failed");
          }
          else
          {
              testComment (&testRec, "Create Passed");
          }

         /* Call to the RFFT for C version*/
         res = dfr16RFFTC (pRFFT, &pX[0], pZ);

         if (res == FAIL)
         {
              assert(!"Bitreversed Failed");
         }    
    
        /* Compare the results */
        
        if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
            || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
        {
              testFailed (&testRec, "Real FFT Failed for C code");
              flag = 0;
              
        }
            
        if (flag)
        {
            for (i = 0; i < ((pRFFT->n)-1); i++)
            {
                if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                    (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                {    
                    testFailed (&testRec, "Real FFT Failed for C code");
                    flag =0;
                    break;            
                }
            }
        }

        if (flag)
        {
            testComment (&testRec, "Real FFT Passed for C code");
        }
        else
        {
            flag = 1;
        }
        
        /*Call to RFFT Asm version */
        
         res = dfr16RFFT (pRFFT, &pX[0], pZ);

         if (res == FAIL)
         {
               assert(!"Bitreversed Failed");
         }    
    
        /* Compare the results */
        
        if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
            || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
        {
              testFailed (&testRec, "Real FFT Failed for ASM code");
              flag = 0;          
        }
        
        if (flag)
        {
            for (i = 0; i < ((pRFFT->n)-1); i++)
            {
                if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                    (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                {    
                    testFailed (&testRec, "Real FFT Failed for ASM code");
                    flag = 0;
                    break;
                }       
            }
        }

        if (flag)
        {
            testComment (&testRec, "Real FFT Passed for ASM code");
        }
        else
        {
            flag = 1;
        }

        dfr16RFFTDestroy (pRFFT);
        testEnd(&testRec);
        printf("\n");               
        
       /* Testing for length 32 and option SCALE_RESULT_BY_DATA_SIZE */   
     
         testStart(&testRec, "Option : SCALE_BY_DATA_SIZE ");
         options = FFT_SCALE_RESULTS_BY_DATA_SIZE;
          for (i=0; i < n; i++)
              pX[i] = pX32[i];
          Actual_op = &Actual_op_option_2[0];
          
          pRFFT = dfr16RFFTCreate (32, options);
          if (pRFFT == NULL)
          {
              assert(!"Create Failed");
          }
          else
          {
              testComment (&testRec, "Create Passed");
          }
          
         res = dfr16RFFTC (pRFFT, &pX[0], pZ);

         if (res == FAIL)
         {
              assert(!"Bitreversed Failed");
         }    
    
        /* Compare the results */
        
        if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
            || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
        {
              testFailed (&testRec, "Real FFT Failed for C code");
              flag = 0;                      
        }
        
        if (flag)
        {
            for (i = 0; i < ((pRFFT->n)-1); i++)
            {
                if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                    (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                {    
                    testFailed (&testRec, "Real FFT Failed for C code");
                    flag = 0;
                    break;                        
                }            
            }
        }

        if (flag)
        {
            testComment (&testRec, "Real FFT Passed for C code");
        }
        else
        {
            flag = 1;
        }
        
        /* Call to ASM RFFT */
        
         res = dfr16RFFT (pRFFT, &pX[0], pZ);

         if (res == FAIL)
         {
                assert(!"Bitreversed Failed");
         }    
    
        /* Compare the results */
        
        if ((abs((pZ->z0) - (Actual_op[0].real)) > 3) 
            || (abs(( pZ->zNDiv2) - (Actual_op[0].imag)) > 3))
        {
              testFailed (&testRec, "Real FFT Failed for ASM code");
              flag = 0;                      
        }
            
        if (flag)
        {
            for (i = 0; i < ((pRFFT->n)-1); i++)
            {
                if ((abs(( pZ->cz[i].real) - (Actual_op[i+1].real)) > 3) ||
                    (abs(( pZ->cz[i].imag) - (Actual_op[i+1].imag)) > 3))
                {    
                    testFailed (&testRec, "Real FFT Failed for ASM code");
                    flag = 0;
                    break;                        
                }        
            }
        }

        if (flag)
        {
            testComment (&testRec, "Real FFT Passed for ASM code");
        }
        else
        {
            flag = 1;
        }

        options = FFT_SCALE_RESULTS_BY_N;
        
        memFreeEM(pZ);
        memFreeEM(pX);
     
        dfr16RFFTDestroy (pRFFT);
        testEnd(&testRec);
        printf("\n");        
        
        return PASS;
}


Result testRifft32(UInt16 n)
{
    Int16 res, flag = 1;  /* 1 = Pass, 0 = Fail */
    UInt16 options = 1;
    Int16 i, j;
    Frac16 *pXI;
    CFrac16 *pX32;
    const Frac16 *Actual_op;
    dfr16_sInplaceCRFFT *pZI;
    dfr16_tRFFTStruct *pRIFFT;
    test_sRec testRec;
    Frac16 t;
    
    pX32 = (CFrac16 *)pX32_input;
       
        pXI=(Frac16 *) memMallocEM(n*sizeof(Frac16));
        if (pXI == NULL)
        {
            assert (!"Cannot allocate the memory"); 
        }    
        
        pZI=(dfr16_sInplaceCRFFT *) memMallocEM(sizeof(dfr16_sInplaceCRFFT) + 
             sizeof(CFrac16)*(n/2-2));
        if (pZI == NULL)
        {
            assert (!"Cannot allocate memory");
        } 
       
                  testStart (&testRec, "Option : SCALE_BY_N");
                  options = FFT_SCALE_RESULTS_BY_N;
                  pZI->z0 = pX32[0].real;
                  pZI->zNDiv2 = pX32[0].imag;
                  for ( i=0; i < (n/2 -1); i++)
                  {
                      pZI->cz[i].real = pX32[i+1].real;
                      pZI->cz[i].imag = pX32[i+1].imag;
                  }
                  
                  Actual_op = &Actual_op_rifft_option_1[0];
                  
                  /*Call to the create function call */
                  pRIFFT = dfr16RIFFTCreate (32, options);
                  if (pRIFFT == NULL)
                  {
                      assert (!"Create Failed");
                  }
                  else
                  {
                      testComment (&testRec, "Create Passed");
                  }
                  
                  
                /* Real Inverse FFT (C) */
                res = dfr16RIFFTC (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                      testFailed (&testRec, "Real IFFT Failed for C code");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for C code");
                        flag = 0;
                        break;
                    }
                    
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for C code");
                }
                else
                {
                    flag =1;
                }
                
                /* Real Inverse FFT (ASM) */
                res = dfr16RIFFT (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                     testFailed (&testRec, "Real IFFT Failed for C code");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for ASM code");
                        flag = 0;
                        break;
                    }  
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for ASM code");
                }
                else
                {
                    flag = 1;
                }
                
                dfr16RIFFTDestroy (pRIFFT);
                testEnd(&testRec);
                printf("\n");               
                
                
               /*Test for SCALE_RESULTS_BY_DATA_SIZE */
                  
                  testStart (&testRec, "Option : SCALE_BY_DATA_SIZE");
                  options = FFT_SCALE_RESULTS_BY_DATA_SIZE;
                  pZI->z0 = pX32[0].real;
                  pZI->zNDiv2 = pX32[0].imag;
                  for ( i=0; i < (n/2 -1); i++)
                  {
                      pZI->cz[i].real = pX32[i+1].real;
                      pZI->cz[i].imag = pX32[i+1].imag;
                  }
                  
                  Actual_op = &Actual_op_rifft_option_2[0];
                  
                  /*Call to the create function call */
                  pRIFFT = dfr16RIFFTCreate (32, options);
                  if (pRIFFT == NULL)
                  {
                      assert (!"Create Failed");
                  }
                  else
                  {
                      testComment (&testRec, "Create Passed");
                  }
                  
                /* Real Inverse FFT (C) */
                res = dfr16RIFFTC (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                     testFailed (&testRec, "Real IFFT Failed for C code");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for C code");
                        flag = 0;
                        break;
                    }
                    
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for C code");
                }
                else
                {
                    flag = 1;
                }
                
                /* Real Inverse FFT (ASM)*/
                res = dfr16RIFFT (pRIFFT, pZI, &pXI[0]);

                if (res == FAIL)
                {
                     testFailed (&testRec, "Real IFFT Failed for ASM code");
                }     
      
                /* Compare the Results*/
                
                for (i = 0; i < ((pRIFFT->n)<<1); i++)
                {
                    if ( abs( pXI[i] - ((Actual_op[i])) )>3)
                    {    
                        testFailed (&testRec, "Real IFFT Failed for ASM code");
                        flag = 0;
                        break;
                    }
                }
    
                if (flag)
                {
                    testComment (&testRec, "Real IFFT Passed for ASM code");
                }
                else
                {
                    flag = 1;
                }
                  
                dfr16RIFFTDestroy (pRIFFT);
                testEnd(&testRec);
                printf("\n");                
                  
             /* Restore the options setting for remaining cases */
             
                options = FFT_SCALE_RESULTS_BY_N; 
                
                memFreeEM(pZI);
                memFreeEM(pXI); 
                
                return PASS;
}

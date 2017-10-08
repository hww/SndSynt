/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*****************************************************************************
*
* File Name: testg165.c
*
* Description: Test Echo canceller for Req. in G.165 std. 3.4.2.1 and 
*              3.4.2.2 
*
* Modules Included:
*                   main ()
*                   Callback ()
*
* Author : Sandeep Sehgal
*
* Date   : 06 July 2000
*
*****************************************************************************/

#include "mem.h"
#include "assert.h"
#include "fcntl.h"
#include "fileio.h"
#include "ascii2hex.c"
#include "test.h"

/* G165 specific include files */
#include "g165.h"

#define G165_OUT_BUF_LENGTH 10000  /* User output buffer length */

/* Output buffer to store the data */
Int16 Sout[G165_OUT_BUF_LENGTH];

/* Write offset in the buffer for the next call of callback */
Int16 offset=0;

void Callback (void *pCallbackArg, Int16 * pSamples, UInt16 NumSamples);

/* File Descriptor */
int Fd_input;


/*****************************************************************************
*
* Module: main ()
*
* Description: To test the test cases for Test A.1 and A.2 specified in 
*              the design document (or tests specified in CCITT G.165 
*              std in 3.4.2.1 and 3.4.2.2). Test for Convergence of 
*              Adaptation Algorithm.
*
* Returns: None
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g165.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author

*    06-07-2000     0.1          For review       Sandeep Sehgal           .
*    12-07-2000     1.0          Reviewed and     Sandeep Sehgal       
*                                baselined                      
* 
****************************************************************************/

void main()
{
    g165_sConfigure * pConfig;
    g165_sHandle * pG165;
    Result res;
    test_sRec      testRec;    
    Int16 k, wrds, cmp_loop;
    static Int16 RinBuffer[320], SinBuffer[320];
    Int16 loopcnt;
    static Int16 Temp_Buffer[640*6];
    UInt16 BufSz = 640;
    UInt16 num_cases;
    
    
    testPrintString ("Testing for Converg., Double Tlk, Tone Disabler and HRL\n");    
            
    pConfig = (g165_sConfigure *) memMallocEM(sizeof (g165_sConfigure));
    if (pConfig == NULL) assert(!"Cannot allocate memory for pConfig");
    
    /* User configuration of G.165 */                   
    pConfig->Flags= 0;
    pConfig->EchoSpan = 320;
    pConfig->callback.pCallback = Callback;
    pConfig->callback.pCallbackArg = NULL;
    
    /* Create the instance of G.165 */
    pG165 = g165Create(pConfig);
    if (pG165 == NULL) assert(!"Cannot allocate memory for pG165");
    
    testPrintString ("Instance of G165 created \n\n");
    
     
     for (num_cases = 0; num_cases < 5; num_cases ++)
     {  
        
         switch (num_cases)
         {
             case 0 : 
                     /* Initialization of G.165 */  
                      res = g165Init(pG165, pConfig);
    
                      if (res == FAIL) assert(!"EchoSpan outside valid  range");
                      testStart (&testRec, "Testing G165 Convergence and Adaptation : ");    
                      testComment (&testRec, "G165 Init passed ");
                      Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a12.in", O_RDONLY);
                      if (Fd_input == NULL) assert(!"Cannot open file");
                      testComment (&testRec, "Reading from input file of 9000 samples");
                      break;

             case 1 : 
                    /* Initialization of G.165 */  
                      res = g165Init(pG165, pConfig);
    
                      if (res == FAIL) assert(!"EchoSpan outside valid  range");
                      testStart (&testRec, "Testing G165 Degradation due to double tlk : "); 
                      testComment (&testRec, "G165 Init passed ");
                      Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a4.in", O_RDONLY);
                      if (Fd_input == NULL) assert(!"Cannot open file");
                      testComment (&testRec, "Reading from input file of 9000 samples");
                      break;
                 

             case 2 : 
                     /* Initialization of G.165 */  
                      res = g165Init(pG165, pConfig);
    
                      if (res == FAIL) assert(!"EchoSpan outside valid  range");
                      testStart (&testRec, "Testing G165 Infinite Return loss Convg. : ");  
                      testComment (&testRec, "G165 Init passed ");
                      Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a6.in", O_RDONLY);
                      if (Fd_input == NULL) assert(!"Cannot open file");
                      testComment (&testRec, "Reading from input file of 9000 samples");
                       break;
 
                      
             case 3 : 
                    /* Initialization of G.165 */  
                      res = g165Init(pG165, pConfig);
    
                      if (res == FAIL) assert(!"EchoSpan outside valid  range");
                      testStart (&testRec, "Testing G165 Tone Disabler : ");     
                      testComment (&testRec, "G165 Init passed ");
                      Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\td.in", O_RDONLY);
                      if (Fd_input == NULL) assert(!"Cannot open file");
                      testComment (&testRec, "Reading from input file of 10000 samples");
                      break;

             case 4 : 
                    /* Initialization of G.165 */  
                      res = g165Init(pG165, pConfig);
    
                      if (res == FAIL) assert(!"EchoSpan outside valid  range");
                      testStart (&testRec, "Testing G165 Hold Release logic : "); 
                      testComment (&testRec, "G165 Init passed ");
                      Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\hrl.in", O_RDONLY);
                      if (Fd_input == NULL) assert(!"Cannot open file");
                      testComment (&testRec, "Reading from input file of 5500 samples");
                      break;
   
         }    
              
    
        if (num_cases == 0 | num_cases == 1| num_cases == 2)
        {
            for (k = 0; k < 28; k++)
            {
                wrds = read(Fd_input, Temp_Buffer, BufSz*6); 
                Ascii2hex(Temp_Buffer, BufSz*6);
                for ( loopcnt = 0; loopcnt < 320; loopcnt++)
                {
                    RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                    SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
                }    
                res = g165Process(pG165, RinBuffer, SinBuffer, 320);
                printf ("Processed %6d Samples\n", 320*(k+1));
            }    
    
            wrds = read(Fd_input, Temp_Buffer, 80*6); 
            Ascii2hex(Temp_Buffer, 80*6);
            for ( loopcnt = 0; loopcnt < 40; loopcnt++)
            {
                RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
            }    
     
    
            res = g165Process(pG165, RinBuffer, SinBuffer, 40);
            testComment (&testRec, "Processed 9000 samples");
    

            g165Control (pG165, G165_DEACTIVATE);
              
            close (Fd_input);
    
            testComment (&testRec, "Comparing with the standard output");

            /* File Comparsion */

            switch (num_cases)
            {
                 case 0: 
                         Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a12.ref", O_RDONLY);
                         break;
                         
                 case 1: 
                         Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a4.ref", O_RDONLY);
                         break;
                 case 2: 
                         Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\ec_a6.ref", O_RDONLY);
                         break;
                 
            }
            
            for (k =0; k < 9000; k=k+100)
            {
                wrds = read(Fd_input, Temp_Buffer, 100*6); 
                Ascii2hex(Temp_Buffer, 100*6);
        
                for (cmp_loop = 0; cmp_loop < 100; cmp_loop++)
                {
        
                    if (Sout[k + cmp_loop] != Temp_Buffer[cmp_loop]) 
                    {
                        testFailed(&testRec,"Test failed ");
                        assert(!"Test failed");
                    }
                
                }    
                    
            }
    
            testEnd(&testRec);
			testPrintString("\n");
    
            close (Fd_input);
            offset = 0;
    
        }
        if (num_cases == 3 )
        {
            for (k = 0; k < 31; k++)
            {
                wrds = read(Fd_input, Temp_Buffer, BufSz*6); 
                Ascii2hex(Temp_Buffer, BufSz*6);
                for ( loopcnt = 0; loopcnt < 320; loopcnt++)
                {
                    RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                    SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
                }    
                res = g165Process(pG165, RinBuffer, SinBuffer, 320);
                printf ("Processed %6d Samples\n", 320*(k+1));
            }    
    
            wrds = read(Fd_input, Temp_Buffer, 160*6); 
            Ascii2hex(Temp_Buffer, 160*6);
            for ( loopcnt = 0; loopcnt < 80; loopcnt++)
            {
                RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
            }    
     
    
            res = g165Process(pG165, RinBuffer, SinBuffer, 80);
            testComment (&testRec, "Processed 10000 samples");
    

            g165Control (pG165, G165_DEACTIVATE);
              
            close (Fd_input);
    
            testComment (&testRec, "Comparing with the standard output");

            /* File Comparsion */

            Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\td.ref", O_RDONLY);
                 
                        
            for (k =0; k < 10000; k=k+100)
            {
                wrds = read(Fd_input, Temp_Buffer, 100*6); 
                Ascii2hex(Temp_Buffer, 100*6);
        
                for (cmp_loop = 0; cmp_loop < 100; cmp_loop++)
                {
        
                    if (Sout[k + cmp_loop] != Temp_Buffer[cmp_loop]) 
                    {
                        testFailed(&testRec,"Test failed ");
                        assert(!"Test failed");
                    }
                
                }    
                    
            }
    
            testEnd(&testRec);
			testPrintString("\n");
    
            close (Fd_input);
            offset = 0;
    
        }

        if (num_cases == 4)
        {
            for (k = 0; k < 17; k++)
            {
                wrds = read(Fd_input, Temp_Buffer, BufSz*6); 
                Ascii2hex(Temp_Buffer, BufSz*6);
                for ( loopcnt = 0; loopcnt < 320; loopcnt++)
                {
                    RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                    SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
                }    
                res = g165Process(pG165, RinBuffer, SinBuffer, 320);
                printf ("Processed %6d Samples \n", 320*(k+1));
            }    
    
            wrds = read(Fd_input, Temp_Buffer, 120*6); 
            Ascii2hex(Temp_Buffer, 120*6);
            for ( loopcnt = 0; loopcnt < 60; loopcnt++)
            {
                RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
                SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
            }    
     
    
            res = g165Process(pG165, RinBuffer, SinBuffer, 60);
            testComment (&testRec, "Processed 5500 samples");
    

            g165Control (pG165, G165_DEACTIVATE);
              
            close (Fd_input);
    
            testComment (&testRec, "Comparing with the standard output");

            /* File Comparsion */

            Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g165\\test_g165\\c_sources\\hrl.ref", O_RDONLY);
            
            for (k =0; k < 5500; k=k+100)
            {
                wrds = read(Fd_input, Temp_Buffer, 100*6); 
                Ascii2hex(Temp_Buffer, 100*6);
        
                for (cmp_loop = 0; cmp_loop < 100; cmp_loop++)
                {
        
                    if (Sout[k + cmp_loop] != Temp_Buffer[cmp_loop]) 
                    {
                        testFailed(&testRec,"Test failed ");
                        assert(!"Test failed");
                    }
                
                }    
                    
            }
    
            testEnd(&testRec);
			testPrintString("\n");
    
            close (Fd_input);
            offset = 0;
    
        }
  
    }    
   
    g165Destroy(pG165);
    memFreeEM(pConfig);

    return;
}



/*****************************************************************************
*
* Module: Callback ()
*
* Description: To store the echo cancelled output Bandlimited 
*              noise data in a buffer
*
* Returns: None
*
* Arguments: pCallbackArg -> pointer to the argument list passed to the
*                            g165_process by the main function
*            pSamples -> pointer to the echo cancelled samples buffer
*            NumSamples - Number of samples in the echo cancelled 
*                         samples buffer
*            
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g165.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*
*    06-07-2000     0.1          For review       Sandeep Sehgal           .
*    12-07-2000     1.0          Reviewed and     Sandeep Sehgal       
*                                baselined                      
* 
****************************************************************************/

void Callback ( void *pCallbackArg, Int16 *pSamples, UInt16 NumSamples)
{

    Int16 loop_variable;
    
    for (loop_variable = 0; loop_variable < NumSamples; loop_variable++)
     {
      
         Sout[loop_variable + offset] = pSamples[loop_variable];

     }

     offset += NumSamples;
     
    return;
}                
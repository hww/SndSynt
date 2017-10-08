/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: testcasdetect.c
*
* Description: To test CAS detector functionality
*              
*
* Modules Included: main
*                   
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

#include "assert.h"
#include "fileio.h"
#include "ascii2hex.c"
#include "test.h"

/* cas detect specific include files */
#include "casDetect.h"

Int16 InBuffer[80*6];

/**********************************************************************
*
* Module: main()
*
* Description:  Samples are read from file. The 
*               casDetectProcess function is called with the samples.
*               If the total number of accumulated samples is more 
*               than 80, they are processed and the CAS 
*               detector flag is returned to the user. Whenever the 
*               return value is CAS_PRESENT, the CAS tone is said to
*               have been detected.
*
* Returns: None
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: Tested through test_casdetect.mcp
*
***************************** Change History **************************
*
*  DD/MM/YY    Code Ver     Description                Author
*  --------    --------     -----------                ------
*  23/11/2000  0.0.1        Function created          Sandeep S
*  18/12/2000  1.0.0        Modified per review       Sandeep S
*                           comments and baselined
*
**********************************************************************/

main()
{
    casDetect_sHandle * pCasDetect;
    UInt16 casdetected;
    test_sRec testRec;    
    Int16 k, wrds, grptest;
    UInt16 BufSz = 80;
    
    /* File Descriptor */
    int Fd_input;

    testPrintString ("Testing CPE Alerting Signal Detector\n\n"); 
    
    /* Test for the Group I, Group II and Group III as per BellCore 
       recommendation */
          
    for (grptest = 0; grptest < 3; grptest++)
    {

        switch (grptest)
        {
        
            case 0 : testStart (&testRec, "Testing for nominal CAS Parameters");    
                     Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cas_detect\\test_casdetect\\inputs\\group1.in", O_RDONLY);
                     if (Fd_input == NULL) assert(!"Cannot open file");
                     break;
                     
            case 1 : testStart (&testRec, "Testing with one CAS parameter at extreme");
                     Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cas_detect\\test_casdetect\\inputs\\group2.in", O_RDONLY);
                     if (Fd_input == NULL) assert(!"Cannot open file");
                     break;       
            
            case 2 : testStart (&testRec, "Testing with all parameters at 90% of extreme");
                     Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cas_detect\\test_casdetect\\inputs\\group3.in", O_RDONLY);
                     if (Fd_input == NULL) assert(!"Cannot open file");
                     break;            
        } 
        /* Create the instance of CAS Detect */
        pCasDetect = casDetectCreate();
        if (pCasDetect == NULL) assert(!"Cannot allocate memory for pCasDetect");
    
        testComment (&testRec, "Instance of CAS Detect created");
  
        /* Initialization of CAS Detect */  
        casDetectInit(pCasDetect);
        
        testComment (&testRec, "CAS Detect Init passed ");
        
        /* Reading from an input file*/  
        
        testComment (&testRec, "Reading from file");            
    
        for (k = 0; k < 20; k++)
        {
            wrds = read(Fd_input, InBuffer, BufSz*6); 
            Ascii2hex(InBuffer, BufSz*6);
            casdetected = casDetectProcess(pCasDetect, InBuffer, BufSz);
            if (casdetected == CAS_PRESENT) break;
        }    

        /* Close the file descriptor */
        close (Fd_input);
    
        if (casdetected != CAS_PRESENT)
            /* If no valid cas is detected in the file
                CAS returns fail */
            testFailed(&testRec,"Test failed ");
    
        testEnd(&testRec);
        testPrintString ("\n");

        /* Destroy the instance of CAS Detect */
        casDetectDestroy(pCasDetect);
        
    }
        
}
/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: testdtmfdet.c
*
* Description: This module is an example test code for testing DTMF detection
*
* Modules Included:
*                   testdtmfdet ()          -  C function
*                   DTMFDetCallback ()      -  C function
*
* Author : Sarang Akotkar
*
* Date   : 14 June 2000
*
*****************************************************************************/

#include "mem.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"
#include "fileio.h"

/* DTMF Detect specific include files */
#include "dtmfdet.h"

/* Used for file io */

#define NUMFILES  3
#define MAXDETKEYS 32


/* Function prototypes */
extern  void DTMFDetCallback (void *pCallbackArg, UWord16 Status, 
                              UWord16 *pChar, UWord16 Numchars);
extern  Result testdtmfdet (void);
extern  void   Ascii2hex (UInt16 *, UInt16 );


dtmfdet_sHandle *pDTMFDet;
dtmfdet_sConfigure  *pConfig;

Frac16 input[480];    /* Array holds the 80 input samples */

/* DTMF Keys to be detected */
UWord16  keybuf12[] = {0x30, 0x32, 0x34, 0x36, 0x38, 0x41, 0x43, 0x2a, 0x31, 
                      0x33, 0x35, 0x37, 0x39, 0x42, 0x44, 0x23};
UWord16  keybuf3[] = {0x30, 0x32, 0x23, 0x34, 0x44, 0x42, 0x36, 0x39, 0x38, 
                      0x41, 0x43, 0x37, 0x2a, 0x31, 0x35, 0x33, 0x31, 0x33, 
                      0x35, 0x37, 0x30, 0x39, 0x32, 0x34, 0x36, 0x42, 0x38,
                      0x41, 0x44, 0x43, 0x23, 0x2a };
UWord16  *keys;                      
                      
UWord16  det_keys[MAXDETKEYS];
UWord16  numdet_keys;  


/****************************************************************************
*
* Module: testdtmfdet ()
*
* Description: Tests DTMF Detection
*              Test Set-up : Test cases are provided in testx.in files
*                            where x is 1..6, containing the samples.
*                            The output of the test will be a digit 
*                            (0 -- F) if a valid frame corresponding to 
*                            the digit is present otherwise the output 
*                            will be -2 which indicates "An in valid frame"
*
* Returns: PASS or FAIL
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: dtmf_det_test.mcp test project
*
**************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    14/06/2000     0.0.1        Created          Sarang Akotkar
*    14/06/2000     1.0.0        Reviewed and     Sarang Akotkar
*                                Baselined
*
*****************************************************************************/

Result testdtmfdet (void)
{
  
    Result result;
    Word16 i,j,k, filesel, numframes;
    Word16 fd;
     
    test_sRec    testRec;
    UWord16  buffer_size;
    result = FAIL;
  
  
    /* Allocate memory for init structure of DTMF Detection */
  
    pConfig = (dtmfdet_sConfigure *) memMallocEM (sizeof (dtmfdet_sConfigure));
    if (pConfig == NULL) assert(!"Out of memory");
  
    /* Initialize the callback function */
  
    pConfig->DTMFDetCallback.pCallback = DTMFDetCallback;
    pConfig->Flags = DTMFDETECTION_INPRESENCE_OF_SPEECH; 
 
    pDTMFDet = DTMFDetCreate (pConfig);
    if (pDTMFDet == NULL) assert(!"Out of memory");
 
    testStart ( &testRec, "DTMF Detection");
       
    filesel = 1;
    
    for ( k = 1; k <= NUMFILES; k++)
    {
    
    /* Initialize the detected key buffer to invalid number */
    for ( i = 0; i < MAXDETKEYS; i++)
        det_keys[i] = 0xff;
    numdet_keys = 0;    
    
    switch (filesel)
    {
        case 1:
                  numframes = 160;
                  fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\Telephony\\dtmf_det\\test\\C Sources\\test1.in",O_RDONLY);
                  break;
        case 2:
                  numframes = 160;
                  fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\Telephony\\dtmf_det\\test\\C Sources\\test2.in",O_RDONLY);
                  break;
        case 3:
                  numframes = 320;
                  fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\Telephony\\dtmf_det\\test\\C Sources\\test3.in",O_RDONLY);
                  break;
                                                              
        default:
                  fd = -1; 
                  break;
    }
   
     
    if (fd == -1)
    {
         perror("Error ");
		 printf("Can not open test.in");
		 exit(EXIT_FAILURE);
    }
		
    for (i = 0; i < numframes; i++)
    {
         /* Read 80 samples from the input testx.in file  and process it*/
         j = read (fd, input, 480 * sizeof(char)); 
         if (j == 0)
         {
             printf("Read Error");
             exit( EXIT_FAILURE);
	     }
	
	     Ascii2hex (input, 480);
	
         result = DTMFDetection (pDTMFDet, input, 80);
         /* printf("%4X\n",result);  */
    }
  
    close(fd);
    
    buffer_size = 16;
    keys = keybuf12;
    if ( filesel == 3)
    {
         buffer_size = 32;
         keys = keybuf3;
    }     

    result = PASS;
    for (i = 0; i < buffer_size; i++)
    {
        if ( keys[i] != det_keys[i])
             result = FAIL;
    }
    
    if ( result == PASS)
    {
       if ( filesel == 1)
          testComment (&testRec, "Nominal keys detection test Passed");
       if ( filesel == 2)
          testComment (&testRec, "Twist test Passed");
       if ( filesel == 3)
          testComment (&testRec, "Dynamic range test Passed");
    }
    
    else
    {          
       if ( filesel == 1)
          testFailed (&testRec, "Nominal keys detection test Failed");
       if ( filesel == 2)
          testFailed (&testRec, "Twist test Failed");
       if ( filesel == 3)
          testFailed (&testRec, "Dynamic range test Failed");                      
    }
    
    filesel++;
       
    }
  
    DTMFDetDestroy (pDTMFDet);
  
    memFreeEM (pConfig);

    testEnd(&testRec);
  
    return (result); 
  
}



/****************************************************************************
*
* Module: DTMFDetCallback ()
*
* Description:  This module stores the detected DTMF digits in an array.
*               The digits are returned by the DTMF API function.
*
* Returns: None
*
* Arguments: pCallbackArg  - supplied by the user in the dtmfdet_sCallback
*                            structure. This value is passed back to the user 
*                            during the call to the callback procedure.
*                            User has to write his/her own callback function
*                 Status   - returned by DTMFDetection represnting whether
*                            data is ready or some error has occuerd.
*                 pChars   - a pointer to the detected digits buffer
*                 Numchars - Number of digits detected.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: dtmf_det_test.mcp test project
*
**************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    14/06/2000     0.0.1        Created          Sarang Akotkar
*    14/06/2000     1.0.0        Reviewed and     Sarang Akotkar
*                                Baselined
*
*****************************************************************************/

void DTMFDetCallback (void *pCallbackArg, UWord16 Status, UWord16 *pChar, 
                      UWord16 Numchars)
{
     int i;  
     if (Status == DTMFDET_KEY_DETECTED)
     {
         for (i = 0; i < Numchars; i++)
         {
              det_keys[numdet_keys] = *(pChar + i);
              numdet_keys++;
         }     
     }
}
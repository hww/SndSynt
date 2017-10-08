/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: testCallerID.c
*
* Description: This module is an example test code for testing Caller ID 
*              detection
*
* Modules Included:
*                   testCallerID ()         -  C function
*                   CallerIDRXCallback ()   -  C function
*
* Author : Meera S. P.
*
* Date   : 11 May 2000
*
*****************************************************************************/

#include "mem.h"
#include "test.h"
#include "stdio.h"
#include "fileio.h"

/* Caller ID specific include files */
#include "CallerID.h"

#define  NUMBER_SAMPLES_PERCALL    20

/* Define Function prototypes */
EXPORT   Result   testCallerID(void);
EXPORT   void Ascii2hex(UInt16 *, UInt16 );
void     CallerIDRXCallback (  void      * pCallbackArg,
                                        UWord16   Status, 
					                    UWord16   * pChar,
                                        UWord16   Numchars );

Result   CallerIDStatus;
callerID_sConfigure * pConfig;
test_sRec      testRec;


/****************************************************************************
*
* Module: testCallerID ()
*
* Description: Tests Caller ID Detection
*              Test Set-up : Test cases are provided in testx.in files
*                            where x is 1..16, containing the CPFSK 
*                            samples with different signal conditions for
*                            both On-Hook and Off-Hook modes. The output
*                            of the test will be length and type of
*                            message along with the actual message if test
*                            passes successfully otherwise the output will
*                            be "test Caller ID Detection - Failed".
*
* Returns: PASS or FAIL
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: caller_id_test.mcp for testing
*
**************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    11/05/2000     0.0.1        Created          Meera S. P.
*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*    15/11/2000     1.0.1        Removed calls    Sanjay Karpoor
*                                to create
*
*****************************************************************************/

Result testCallerID(void)
{
   callerID_sHandle  *pCallerID;
   Result    result;
   Word16    Fd;
   UWord16   i,testcase;
   UInt16    samplebuffer[150];
   UWord16   numsamples, NumberSamples, hook_status;
   UWord16   ReadCount;
   UWord16   Bytes;

   testStart (&testRec, "test Caller ID Detection");  

   for (testcase = 1; testcase <= 16; testcase++)
   {
       numsamples = 0;
       switch(testcase)
       {
           case 1:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test1.in", O_RDONLY);
                    break;
           case 2:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test2.in", O_RDONLY);
                    break;
           case 3:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test3.in", O_RDONLY);
                    break;
           case 4:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test4.in", O_RDONLY);
                    break;
           case 5:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test5.in", O_RDONLY);
                    break;
           case 6:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test6.in", O_RDONLY);
                    break;
           case 7:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test7.in", O_RDONLY);
                    break;
           case 8:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test8.in", O_RDONLY);
                    break;
           case 9:  Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test9.in", O_RDONLY);
                    break;
           case 10: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test10.in", O_RDONLY);
                    break;
           case 11: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test11.in", O_RDONLY);
                    break;
           case 12: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test12.in", O_RDONLY);
                    break;
           case 13: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test13.in", O_RDONLY);
                    break;
           case 14: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test14.in", O_RDONLY);
                    break;
           case 15: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test15.in", O_RDONLY);
                    break;
           case 16: Fd = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\caller_id\\test\\test16.in", O_RDONLY);
                    break;
           default : break;
       }
       
       printf("Test Case : %d \n",testcase);
       
       /* Read the hook status and total no. of samples */
       read (Fd, samplebuffer, 12);
       Ascii2hex (samplebuffer,12);

       hook_status   = samplebuffer[0];
       NumberSamples = samplebuffer[1];
 
      /* Allocate memory for the init structure */
       pConfig = memMallocEM( sizeof(callerID_sConfigure));
   
       pConfig ->Flags = hook_status;
       pConfig ->callerIDCallback.pCallback = CallerIDRXCallback;
       
       pCallerID = callerIDCreate (pConfig);
       callerIDInit (pCallerID, pConfig);
         
   	   NumberSamples = NumberSamples * 6;
   	   Bytes = NUMBER_SAMPLES_PERCALL * 6;

   	   do
	   { 
		   if(NumberSamples < 120)
		   {
		 	 Bytes = NumberSamples;
		   }
		 
		   /* reads 20 samples from the input file at a time and process it */
           ReadCount = read (Fd, samplebuffer, Bytes * sizeof(char));
                      
           Ascii2hex (samplebuffer, NUMBER_SAMPLES_PERCALL * 6);
   		   result = callerIDRX (pCallerID, samplebuffer, NUMBER_SAMPLES_PERCALL);

	   }while((NumberSamples -= ReadCount) != 0);
    
       memFreeEM(pConfig);
       
       /* Close the input file */
       close(Fd);
       
       /* Print Failed if corresponding test case fails */
       if ( (result != PASS) && (CallerIDStatus != PASS))
       {
           testComment (&testRec, " Failed");
       }
       callerIDDestroy (pCallerID);
   }
   
   return (result);   

}


/****************************************************************************
*
* Module: CallerIDRXCallback ()
*
* Description: What is to be done with the output data after Caller ID 
*              Detection processing is completed? The user who uses the 
*              Caller ID has to write this fuction. The most basic thing
*              that could be done is print the message type, message 
*              length and actual message on console if the test passes 
*              successfully, and print "test Caller ID Detection - Failed,
*              otherwise ,which is done in this present example.
*
* Returns: PASS or FAIL
*
* Arguments: pCallbackArg  - supplied by the user in the callerID_sCallback
*                            structure. This value is passed back to the user 
*                            during the call to the callback procedure.
*                            User has to write his/her own callback function
*                 Status   - returned by CallerID_Process represnting whether
*                            data is ready or some error has occuerd.
*                 pChars   - a pointer to the output data buffer
*                 Numchars - length of the output data buffer.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: caller_id_test.mcp for testing
*
**************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    11/05/2000     0.0.1        Created          Meera S. P.
*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
*****************************************************************************/

void  CallerIDRXCallback (  void      * pCallbackArg,
                               UWord16   Status, 
					           UWord16   * pChar,
                               UWord16   Numchars )
                               
{
    UWord16 length,i;
    if ( Status == CALLERID_ERROR )
    {    
       CallerIDStatus = FAIL;
       if (Status & CALLERID_CHECKSUM_ERROR == CALLERID_CHECKSUM_ERROR)
           testComment (&testRec, " Checksum Error");
       if (Status & CALLERID_CSS_ERROR == CALLERID_CSS_ERROR)
           testComment (&testRec, " CSS Error");
       if (Status & CALLERID_MARK_ERROR == CALLERID_MARK_ERROR)
           testComment (&testRec, " Mark Error");
       if (Status & CALLERID_LENGTH_ERROR == CALLERID_LENGTH_ERROR)
           testComment (&testRec, " Length Error");

    }  
    if ( Status == CALLERID_DATA_READY )
    {
       if(*pChar++ == 04 )
       {
           printf("Message Type is = ON_HOOK\n");
       }
       else
       {
           printf("Message Type is = OFF_HOOK\n");
       }
       length = *pChar++;
       printf("Length of the caller id is = %02d\n",length); 
       for (i = 0;i < length;i++)
           printf("%c",*pChar++);                   
    }
    printf("\n\n");
}                               

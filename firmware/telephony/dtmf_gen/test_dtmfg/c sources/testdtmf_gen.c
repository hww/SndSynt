/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: testdtmf_gen.c
*
* Description: This module is an example test code for testing DTMF
*              Generation. This also verifies the multi-channel 
*              functionality of the DTMF generation library.
*
* Modules Included:
*                   main ()
*
* Author : Meera S. P.
*
* Date   : 30 May 2000
*
* Modified By : Sudarshan & Mahesh
*
* Date of Modification: 11 July 2001
*
**********************************************************************/

#include <stdio.h>
#include "test.h"

/* DTMF Generate related header file */
#include "dtmf.h"

/* File I/O related header file */
#include "fcntl.h"
#include "fileio.h"

#define  NUM_SAMPLES      40
#define  NUM_KEYS_TESTED   7
#define  NUM_OF_CHANNELS   5


EXPORT void   Hex2ascii(Int16 *pBuf, UInt16 Buffer_size, Int16 *outBuf);
EXPORT void   Ascii2hex(Int16 *pBuf, UInt16 Buffer_size);


/***********************************************************************
*
* Module: main ()
*
* Description: Tests DTMF Generation algorithm
*                 Test Set-up : The input keys are provided in file 
*                               "test_in.io". Current testing is 
*                               performed for 7 keys viz. 8,0,0,3,5,1 
*                               and 7 and for the sampling frequency of
*                               7.2 K. The output samples are generated 
*                               and compared with a file "test_std.io" 
*                               containing standard output samples for
*                               the given keys.
*                               Same keys are generated for multiple 
*                               channel testing.
*
* Returns: NONE
*
* Arguments:
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp
*
***************************** Change History ***************************
*
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*    11/07/2001     2.0.0        Changed for      Sudarshan & Mahesh
*                                Multi Channel
*
***********************************************************************/

void main(void)	
{   
    Result            result;
    dtmf_sConfigure   Config;
    dtmf_sHandle      *pDTMF[NUM_OF_CHANNELS];
    Int16             Key;
    Int16             i,j, KeyNum,ChNum;
    Int16             SampleBuf[100];
    Int16             TempBuf[600]; 
                      /* should be six times of sample buffer, as each 
                      sample comprise of 6 char when converted to ascii */
    Word16            Fd1,Fd2;
    Int16             KeyBuf[NUM_OF_CHANNELS][NUM_KEYS_TESTED];  
    test_sRec         testRec;

	testStart (&testRec, "testDTMFGen");  
 
    /* Initialize Configuration Buffer */
    Config.OnDuration  = 360;    /* No. of samples for On-Duration */
    Config.OffDuration = 360;    /* No. of samples for Off-Duration */
    Config.SampleRate  = 7200;   /* Sampling Frequency, supports 
                                    7.2 K and 8 K */
    Config.amp         = 0x2666; /* Amplitude should be less than 0.5 */
    
    Fd1 = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\dtmf_gen\\test_dtmfg\\test_in.io", O_RDONLY);

    /* Call dtmfCreate */
    for (ChNum=0; ChNum < NUM_OF_CHANNELS; ChNum++) 
    {
    
       pDTMF[ChNum] = dtmfCreate (&Config);
       if (pDTMF[ChNum] == NULL)
       {
           printf ("Create Failed for channel %d /n", ChNum+1);
           continue;
       }

       /* Read the key from the file */   
       read (Fd1, KeyBuf[ChNum], NUM_KEYS_TESTED);
    }
    close(Fd1);

    /* Open the file for reading the reference samples */
    Fd2 = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\dtmf_gen\\test_dtmfg\\test_std.io", O_RDONLY);
    
    for (KeyNum = 0; KeyNum < NUM_KEYS_TESTED; KeyNum++)
    {
        for (ChNum=0; ChNum < NUM_OF_CHANNELS; ChNum++) 
        {
    	    Key = KeyBuf[ChNum][KeyNum]; 
            result = dtmfSetKey(pDTMF[ChNum], Key);
    
            if (result != PASS)
            {
    		      printf ("dtmfSetKey failed for channel %d  and key %d \n ", ChNum+1,Key);
            }
        }
        
        for (i = 0; i < 18; i++)  /* 18 = (ON_PERIOD + OFF_PERIOD) / 40 */
        {
            /* Read reference samples */
		    read (Fd2, TempBuf, 6 * NUM_SAMPLES); 
    		Ascii2hex (TempBuf, 6 * NUM_SAMPLES);
            
            for (ChNum=0; ChNum < NUM_OF_CHANNELS; ChNum++) 
            {
                /* Corrupt the SampleBuf */
                for (j=0; j < NUM_SAMPLES; j++)
                    SampleBuf[j] = 0xdd;     
                   
        	    result = dtmfGenerate (pDTMF[ChNum], SampleBuf, NUM_SAMPLES);
            	if(((result != PASS) && (i < 17)) || ((result != FAIL) && (i == 17)))
            	{
             		printf ("DTMFGenerate did not result correct RESULT for Channel %d & Key %d\n",ChNum+1,Key);
            		break;
        	    }

	    		for (j=0; j < NUM_SAMPLES; j++)
		    	{
			    	if (TempBuf[j] != SampleBuf[j])
			 	    {
                		printf ("DTMFGenerate did not result correct DATA for Channel %d & Key %d\n",ChNum+1,Key);
					    break;
				    }
			    }
		    }
		    
        }
    }
             
    for(ChNum=0; ChNum < NUM_OF_CHANNELS; ChNum++) 
    {
        dtmfDestroy(pDTMF[ChNum]);
    }
    close(Fd2);
    
    testEnd(&testRec);
}
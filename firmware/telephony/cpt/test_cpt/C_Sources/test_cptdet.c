/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*****************************************************************************
*
* File Name: test_cptdet.c
*
* Description: This module is an example application code that uses 
*              CPT detection library. This module takes the input 
*              from files 
*
* Modules Included:
*                   test_CPTdet ()
*                   CPTDetCallback ()
*
* Author : Manohar Babu
*
* Date   : 26 Sept 2000
*
*****************************************************************************/

#include "mem.h"
#include "test.h"
#include "stdio.h"
#include "assert.h"

/* CPT detect library related header file */
#include "CPTdet.h"

/* File IO related header files */
#include "fileio.h"

/* definitions used */
#define  NUM_SAMPLES  100        /* Number of samples per call */
#define  NO_OF_TESTS  6

/* Function prototypes */
void   CPTDetCallback ( void *pCallbackArg, UWord16 return_value);
Result test_CPTdet ( void);
extern Ascii2hex ( Int16 *pBuf, UInt16 Buffer_size);

CPTDet_sHandle     *pCPTDet;
CPTDet_sConfigure  *pConfig;

UWord16       file_length, test_no;
Word16        input_sample[NUM_SAMPLES*6];
Word16        Fd;             /* File pointer */
Result        return_value;


/*****************************************************************************
*
* Module: test_CPTdet ()
*
* Description: This module is an example application code that uses 
*              CPT detection library. This module takes the input 
*              from files
*
* Returns: PASS or FAIL
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_cpt.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    26/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

Result test_CPTdet (void)
{
  
    Result result;
    Word16 i,j,k, num_samples;
    test_sRec    testRec;

    testStart ( &testRec, "CPT Detection test");

  /* To test all valid tones */
 
  for ( test_no = 0; test_no < NO_OF_TESTS; test_no++)
  {
  
    result = FAIL;
         
    /* Allocate memory for init structure of CPT Detection */
  
    pConfig = (CPTDet_sConfigure *) memMallocEM (sizeof (CPTDet_sConfigure));
    if (pConfig == NULL) assert(!"Out of memory");
  
    /* Initialize the callback function */
  
    pConfig->CPTDetCallback.pCallback = CPTDetCallback;
 
    pCPTDet = CPTDetCreate (pConfig);
    if (pCPTDet == NULL) assert(!"Out of memory");
 
    
	  switch(test_no)
	  {
       case 0:
          printf("\nTesting for Dial Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1dial.in", O_RDONLY);
		  break;
		  
       case 1:
          printf("Testing for Message Waiting Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1msg_wait.in", O_RDONLY);
		  break;
       case 2:
          printf("Testing for Recall Dial Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1recall.in", O_RDONLY);
		  break;
       case 3:
          printf("Testing for Busy Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1busy.in", O_RDONLY);
		  break;
       case 4:
          printf("Testing for Reorder Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1reorder.in", O_RDONLY);
		  break;
       case 5:
          printf("Testing for Audible Ringing Tone\n");
		  Fd= open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\cpt\\test_cpt\\C_Sources\\file_data\\test1ringing.in", O_RDONLY);
		  break;
	   default:
		  break;
	  }  
	  
	if ( Fd == -1)
    {
         printf("\nerror in opening file\n");
         exit;
    }

	read(Fd, input_sample,6*sizeof(short));
    Ascii2hex( input_sample, 6);
	file_length = input_sample[0];
	  
    for ( i = 0; i < file_length; i+=NUM_SAMPLES)
	{
	    read(Fd, input_sample, NUM_SAMPLES*6*sizeof(short));
   	    Ascii2hex( input_sample, NUM_SAMPLES*6);
        result = CPTDetection (pCPTDet, input_sample, NUM_SAMPLES); 
        
        if (result == PASS)
            break;
    }
        
    if (result == FAIL)
    {
        return_value = 0xff;
        pCPTDet->pCallback->pCallback(                     
                 pCPTDet->pCallback->pCallbackArg,
                 return_value);
	}                
      
    close(Fd); 
    
    CPTDetDestroy (pCPTDet);
  
    memFreeEM (pConfig);
    
  }
    
    testEnd(&testRec);
    
    return (PASS); 
    
} 


/*****************************************************************************
*
* Module: CPTDetCallback ()
*
* Description: Print the CPT detected
*
* Returns: None
*
* Arguments: pCallbackArg -> pointer to the argument list passed to the
*                            CPTDetection by the test_CPTdet function
*            return_value - detected CPT digit
*            
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_cpt.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    26/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

void CPTDetCallback (void *pCallbackArg, UWord16 return_value)
{

   switch(return_value)
   {
      case(DIAL_TONE_DETECTED):
          printf("Dial tone detected \n\n");
          break;
      case(MSG_WAITING_TONE_DETECTED):
          printf("Message Waiting tone detected \n\n");
          break;
      case(RECALL_DIAL_TONE_DETECTED):
          printf("Recall Dial tone detected \n\n");
          break;
      case(BUSY_TONE_DETECTED):
          printf("Busy tone detected \n\n");
          break;
      case(REORDER_TONE_DETECTED):
          printf("Reorder tone detected \n\n");
          break;
      case(RINGING_TONE_DETECTED):
          printf("Audible ringing tone detected \n\n");
          break;
      default:
          printf("Tone not Detected \n\n");
          break;
   }
     
}
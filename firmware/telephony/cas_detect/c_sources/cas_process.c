/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: cas_process.c
*
* Description: Includes a function to process the samples to detect
*              valid CAS tone.
*
* Modules Included: casDetectProcess
*                   
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

#include "port.h"
#include "mem.h"
#include "casdetect.h"
#include "prototype.h"

#define FRAME_SZ 80


EXPORT UInt16 CAS_DETECT (Int16 *pSamples);

/**********************************************************************
*
* Module: CAS_DetectProcess()
*
* Description: To process input buffer of samples in blocks of 
*               80 samples (i.e signal of 10msec duration at 8KHz
*               sampling rate). 
*
* Returns: CAS_PRESENT      1 (if CAS tone is detected in any of the
*                              processed frame)
*          CAS_NOT_PRESENT  0 (if CAS tone is not detected in the
*                              processed frames)
*
* Arguments: Pointer to casDetect_sHandle structure, pointer to input
*            samples buffer and number of samples in the buffer 
*               
* Range Issues: None
*
* Special Issues: If CAS tone is detected in the casDetectProcess, the
*                 return statement with CAS_PRESENT is executed even if 
*                 some more frames are left to be processed.
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


Result casDetectProcess (casDetect_sHandle *pCasDetect, Int16 *pSamples, 
                         UInt16 NumSamples)
{
    UInt16 loopcnt;
    UInt16 casFlag;
    UInt16 local_context = 0;
    
    /* Check if (context_buf_length+NumSamples) >= 80 */
        
    if ((pCasDetect->context_buf_length + NumSamples) >= FRAME_SZ)
    {
     
        for (loopcnt = pCasDetect->context_buf_length; loopcnt < FRAME_SZ; loopcnt++)
        {
            /* Copy samples from Input buufer to fillup the context buffer*/
            pCasDetect->In_Context_buf[loopcnt] = pSamples[local_context++];
        }    
            
        pCasDetect->context_buf_length = 0; /* Set context buf length to
                                              zero for next copy */
            
        casFlag = CAS_DETECT (pCasDetect->In_Context_buf);
        
        /* Check the valid cas flag */
        
        if (casFlag == CAS_PRESENT) return (casFlag); /* return if cas 
                                                         present */
                
        /* Still more samples to make a frame ? */
        while ((NumSamples - local_context) >= FRAME_SZ)
        {
            for (loopcnt = pCasDetect->context_buf_length; loopcnt < FRAME_SZ; 
                 loopcnt++)
            {
                /* Copy samples from input buffer to context buffer */
                pCasDetect->In_Context_buf[loopcnt] = pSamples[local_context++];
            }    
            
            /* Clear context buf length */
            pCasDetect->context_buf_length = 0;
    
            casFlag = CAS_DETECT (pCasDetect->In_Context_buf);
              
            if (casFlag == CAS_PRESENT) return (casFlag); /* return if
                                                             cas present*/
    
        }

        /* Final context buf length before the return from this function*/ 
        
        pCasDetect->context_buf_length = (NumSamples - local_context);
        
        for (loopcnt = 0; loopcnt < pCasDetect->context_buf_length; loopcnt++)
        {
            /* Copy remaining samples from the input buffer to the 
               context buffer */
               
            pCasDetect->In_Context_buf[loopcnt] = pSamples[local_context++];
        }    
                
        return (CAS_NOT_PRESENT);    
    }
    
    /* If (NumSamples + context_buf_length) don't make a frame
       copy the input samples to context buffer */
       
    else
    {
        for (loopcnt = 0; loopcnt < NumSamples; loopcnt++)
        {
            pCasDetect->In_Context_buf[loopcnt + pCasDetect->context_buf_length] = *pSamples++;
        }    
            
        pCasDetect->context_buf_length += NumSamples;
        
        return (CAS_NOT_PRESENT);
    } 
}


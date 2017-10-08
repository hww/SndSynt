/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: dtmfdetAPI.c
*
* Description: This module is an API for DTMF detection and to be
*              used by the user Application routines
*
* Modules Included:
*                   DTMFDetCreate ()  -  C function
*                   DTMFDetInit ()    -  C function
*                   DTMFDetection ()  -  C function
*                   DTMFDetDestroy () -  C function
*
* Author : Sarang Akotkar
*
* Date   : 14 June 2000
*
*****************************************************************************/

#include "dtmfdet.h"
#include "stdlib.h"
#include "arch.h"
#include "mem.h" 
#include "port.h"

/*  definitions used in the API */

#define INVALID_FRAME       -2
#define SAMPLE_BLOCK_SIZE   80

/*  Function prototypes */

extern Word16  PROCESS_DTMF (Word16 *);    
extern Result  INIT_DTMF_DETECT (void);
extern UWord16 speech_flag;


/****************************************************************************
*
* Module: DTMFDetCreate ()
*
* Description: The DTMFDetCreate function does all the initializations 
*              for the DTMF Detection by internally calling DTMFDetInit 
*              fuction. 
*
* Returns: DTMF Handle (dtmfdet_sHandle) - 86 words get allocated per
*                                          instance
*
* Arguments: pConfig - pointer to the dtmfdet_sConfigure structure used 
*                           to configure DTMF Detection operation.
*
* Range Issues: None
*
* Special Issues: Should be called ones before calling any of the
*                 API modules
*
* Test Method: dtmf_det_test.mcp for demo_dtmf_det for demo
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

dtmfdet_sHandle *DTMFDetCreate (dtmfdet_sConfigure *pConfig)
{
    Result  result = PASS;
     
    dtmfdet_sHandle *pDTMFDet;
     
    pDTMFDet = (dtmfdet_sHandle *) memMallocEM (sizeof (dtmfdet_sHandle));
     
    pDTMFDet->contextbuff = (Word16 *) memMallocEM (sizeof (Word16) * SAMPLE_BLOCK_SIZE);
     
    pDTMFDet->pCallBck = (dtmfdet_sCallback *) memMallocEM (sizeof (dtmfdet_sCallback));
    
    if ((pDTMFDet || pDTMFDet->contextbuff || pDTMFDet->pCallBck) == NULL)
    
         return (NULL);
     
    result = DTMFDetInit (pDTMFDet, pConfig); 
     
    return (pDTMFDet);
}


/****************************************************************************
*
* Module: DTMFDetInit ()
*
* Description: The DTMFDetInit function will initialize the DTMF Detection
*              algorithm. During the initialization, all resources will be 
*              set to their initial values in preparation for DTMF 
*              Detection operation. This function is called internally by 
*              DTMFDetCreate. 
*
* Returns: PASS or FAIL
*
* Arguments: pDTMFDet - Handle to an instance of DTMF detection
*            pConfig  - pointer to the dtmfdet_sConfigure structure used 
*                       to configure DTMF Detection operation.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: dtmf_det_test.mcp for demo_dtmf_det for demo
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

Result DTMFDetInit (dtmfdet_sHandle *pDTMFDet, dtmfdet_sConfigure *pConfig)
{
    Result   result;
    pDTMFDet->length = 0;
    
    pDTMFDet->pCallBck->pCallback = pConfig->DTMFDetCallback.pCallback; 
    pDTMFDet->pCallBck->pCallbackArg = pConfig->DTMFDetCallback.pCallbackArg;
    
    speech_flag = pConfig->Flags;
    result = INIT_DTMF_DETECT ();
    
    return (result);
    
}


/****************************************************************************
*
* Module: DTMFDetection ()
*
* Description: The DTMFDetection function will process the samples supplied. 
*              After processing, if a valid digit is detected the result is  
*              given back to the user by calling the DTMFDetCallback procedure. 
*              A valid digit is from 0 - F.
*
* Returns: PASS or FAIL
*
* Arguments: pDTMFDet - Handle to an instance of DTMF detection
*            pSamples  - Pointer to the input data buffer.
*            NumberSamples - No. of samples to be processed.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: dtmf_det_test.mcp for demo_dtmf_det for demo
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

Result DTMFDetection (dtmfdet_sHandle *pDTMFDet, Word16 *pSamples, UWord16 NumberSamples)
{
    Result   result;
    Word16   res;
    UWord16  len;
    UWord16  i, j;
    UWord16  temp;
    
    Word16  *buff;
    
    result = PASS;
        
    len  = pDTMFDet->length;
    
    buff = pDTMFDet->contextbuff;
    
    temp = NumberSamples;
    
    /* Number of samples different than SAMPLE_BLOCK_SIZE */
    
    if ((len + NumberSamples) >= SAMPLE_BLOCK_SIZE ) 
    {
        if (len == 0)
        { 
            i = 0;
            while (temp >= SAMPLE_BLOCK_SIZE)
            {
        
                /* res = -2 (INVALID_FRAME) else res = digit detected */
         
                res = PROCESS_DTMF (pSamples + (i * SAMPLE_BLOCK_SIZE)); 
         
                /* Call back proc. to indicate that valid data is available */
              
                if (res != INVALID_FRAME)         
                    pDTMFDet->pCallBck->pCallback(                     
                        pDTMFDet->pCallBck->pCallbackArg,
                        DTMFDET_KEY_DETECTED, (UWord16 *) &res, 1);
                     
                temp -= SAMPLE_BLOCK_SIZE ;
                i++;
            }
        
            /* copy the remaining samples in context buffer and 
               set context buffer length*/

            for (j = 0; j < temp; j++)
                 *(buff + j) = *(pSamples + (i * SAMPLE_BLOCK_SIZE) + j);
        

            pDTMFDet->length = temp;
        
        }
        else
        { 
      
            temp = (len + NumberSamples);
            i = 0;
        
            while(temp >= SAMPLE_BLOCK_SIZE)
            {
                if(!i)
                {
          
                    /* copy new samples in context buff till buffer is full (80)
                       and pass context buff pointer */
           
                    for (j = 0; j < (SAMPLE_BLOCK_SIZE - len); j++)
                         *(buff + len + j) = *(pSamples + j);

                    res = PROCESS_DTMF(buff); 
                   
                  
                    if (res != INVALID_FRAME)
                        pDTMFDet->pCallBck->pCallback(                     
                        pDTMFDet->pCallBck->pCallbackArg,
                        DTMFDET_KEY_DETECTED, (UWord16 *) &res, 1);
                     
                    temp -= SAMPLE_BLOCK_SIZE ;
                    i++;
           
                }
                else
                {
            
                    /* j holds the difference value (SAMPLE_BLOCK_SIZE - len) */
                    res = PROCESS_DTMF (pSamples + j + ((i - 1) * SAMPLE_BLOCK_SIZE));
            
                  
                  
                    if (res != INVALID_FRAME)
                        pDTMFDet->pCallBck->pCallback(                     
                        pDTMFDet->pCallBck->pCallbackArg,
                        DTMFDET_KEY_DETECTED, (UWord16 *) &res, 1);
                     
                    temp -= SAMPLE_BLOCK_SIZE ;
                    i++;   
            
                } 
            }    
        
                  /* copy the remaining samples in context buffer and 
                     set context buffer length */

                  for (j = 0; j < temp; j++)
                       *(buff + j) = *(pSamples + ((i * SAMPLE_BLOCK_SIZE) - len) + j);

         
                  pDTMFDet->length = temp;
        
        }
    }
    else
    {
    
         if (len == 0)
         {
          
             for (j = 0; j < NumberSamples; j++)
                  *(buff + j) = *(pSamples + j);
         
             pDTMFDet->length = NumberSamples;
      
         }
         else
         {
      
             for (j = 0; j <= NumberSamples; j++)
                  *(buff + len + j) = *(pSamples+j);
      
             pDTMFDet->length = NumberSamples + len;
         
         }  
        
         res = INVALID_FRAME;
    }
        
        if (res == INVALID_FRAME)
            return(FAIL);
        else
            return(PASS); 
    
}      


/****************************************************************************
*
* Module: DTMFDetDestroy ()
*
* Description: This module de-allocates the instance created by a call to
*              DTMFDetCreate function
*
* Returns: None
*
* Arguments: pDTMFDet - Handle to an instance of DTMF detection
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: dtmf_det_test.mcp for demo_dtmf_det for demo
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

void DTMFDetDestroy (dtmfdet_sHandle * pDTMFDet)

{   
    memFreeEM (pDTMFDet->contextbuff);
    memFreeEM (pDTMFDet->pCallBck);
    memFreeEM (pDTMFDet);
    return ;
}     


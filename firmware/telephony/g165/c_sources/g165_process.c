/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_process.c
*
* Description: This file contains a module which does G.165 samples
*              processing
*
* Modules Included:
*                   g165Process ()
*
* Author : Sandeep Sehgal
*
* Date   : 25 May 2000
*
*****************************************************************************/

#include "port.h"
#include "mem.h"
#include "arch.h"
#include "g165.h"

#define  G165_FRM_BUF_LEN  320

extern Int16  G165_SAMP_PRO_subroutine(Int16 *pSamples_Rin, Int16 *pSamples_Sin);



/*****************************************************************************
*
* Module: g165Process ()
*
* Description: G165 Process function,processes the samples
*              according to pConfig Flags and EchoSpan.
*              Refer to g165.h for description of pConfig Flags 
*              and Echospan.
*
* Returns: PASS or FAIL
*
* Arguments: pG165  -> Pointer to structure g165_tHandle, 
*            pSamples_Rin -> pointer to samples buffer
*            pSamples_Sin -> pointer to samples buffer
*            NumSamples -  Number of samples in the samples buffer 
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g165.mcp and demo_g165.mcp
*
***************************** Change History **************************
*
*  DD/MM/YY    Code Ver     Description                Author
*  --------    --------     -----------                ------
*  25/05/2000  0.0.1        Function created          Sandeep Sehgal
*  12/07/2000  1.0.0        Modified per review       Sandeep Sehgal
*                           comments and baselined
*
***********************************************************************/

Result g165Process( g165_sHandle * pG165, Int16 * pSamples_Rin,
                    Int16 *pSamples_Sin, 
				    UInt16 NumSamples)
{
    
 
    Int16 loop, *Buf_ptr;
    Int16 Total_length;
    bool Satbit = false;
    Satbit = archGetSetSaturationMode (Satbit);
    
    Total_length = NumSamples + pG165->context_buf_length;
        
    if (Total_length >= G165_FRM_BUF_LEN)
    {
    
        Buf_ptr = pG165->pOutBuf + pG165->context_buf_length;
    
        for (loop = 0; loop < (G165_FRM_BUF_LEN - 
             pG165->context_buf_length); loop++)
        {
            *Buf_ptr++ = G165_SAMP_PRO_subroutine(pSamples_Rin++, pSamples_Sin++);
        }

        /*Check for the remaining Samples in the input buffer*/
        
        pG165->context_buf_length = Total_length - G165_FRM_BUF_LEN;
                                            
        
        /* Callback function call*/
        
        (*(pG165->pCallback->pCallback)) (pG165->pCallback->pCallbackArg, pG165->pOutBuf, 
                                        G165_FRM_BUF_LEN);
        
        while ((pG165->context_buf_length) >= G165_FRM_BUF_LEN)
        {
            Buf_ptr = pG165->pOutBuf;
            
            for (loop = 0; loop < G165_FRM_BUF_LEN; loop++)
            {
              *Buf_ptr++ = G165_SAMP_PRO_subroutine(pSamples_Rin++, pSamples_Sin++);
            }
            
           /*Check for remaining samples to be processed*/
            
            pG165->context_buf_length = pG165->context_buf_length - G165_FRM_BUF_LEN;

          /*Callback function call*/
            (*(pG165->pCallback->pCallback)) (pG165->pCallback->pCallbackArg, pG165->pOutBuf, 
                                             G165_FRM_BUF_LEN);
            
        }
        
        Buf_ptr = pG165->pOutBuf;
        
        for (loop = 0; loop < pG165->context_buf_length; loop++)
        {
            /*save the remaining outputs in buffer */
            *Buf_ptr++ = G165_SAMP_PRO_subroutine(pSamples_Rin++, pSamples_Sin++);
        }
            
    }
    else
    {
        Buf_ptr = pG165->pOutBuf + pG165->context_buf_length;

        pG165->context_buf_length = NumSamples + 
                                    pG165->context_buf_length;
                                    
        
        for (loop = 0; loop < NumSamples; loop++)
        {
            /* store the output in the buffer*/
            *Buf_ptr++ = G165_SAMP_PRO_subroutine(pSamples_Rin++, pSamples_Sin++);
        }
        
    }    
    
    Satbit = archGetSetSaturationMode (Satbit);
    return (PASS);   
}				    
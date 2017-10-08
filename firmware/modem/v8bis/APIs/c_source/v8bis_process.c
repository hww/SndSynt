/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: v8bis_process.c
*
* Description:  Includes V8bis process function
*
* Modules Included:
*                   v8bisProcess ()
*                   local_tx_callback ()
*
* Author : Prasad N. R.
*
* Date   : 08 Aug 2000
*
***********************************************************************/

#include "port.h"
#include "v8bis.h"
#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

static v8bis_sHandle *l_pV8bis;
extern void V8bis_State_Machine ();
void local_tx_callback (Word16 *pSamples, UWord16 Numsamples);
extern void Setup_Frame (Word16 *pSample);

/***********************************************************************
*
* Module: v8bisProcess ()
*
* Description: Exchanges capabilities and decides upon the common
*              mode of communication between two DCEs.
*
* Returns: PASS or FAIL
*
* Arguments: pv8bis - a pointer to v8bis_sHandle structure obtained
*                     after a call to v8bisCreate function.
*            pSamples - a pointer to buffer containing received 
*                       codec samples (16-bit, 1.15 format, linear PCM).
*            NumSamples - Number of samples pointed-to by pSamples.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_v8bis_IS.mcp or test_v8bis_RS.mcp for testing
*
**************************** Change History ****************************
*
*    DD/MM/YY   Code Ver       Description         Author
*    --------   --------       -----------         ------
*    08/08/2000  0.0.1         Created             Prasad N R
*    25/08/2000  1.0.0         Reviewed and        Prasad N R
*                              Baselined 
*
**********************************************************************/

EXPORT Result v8bisProcess (v8bis_sHandle *pV8bis, Word16 *pSamples, UWord16 NumSamples)
{
    int i;
    Result res = PASS;
    UWord16 NumSams;
    
    /* Make a copy of V8bis handle pointer */
    
    l_pV8bis = pV8bis;
    
    /* Copy the received samples into appropriate buffers.
     * Sets flags for tx, rx, and time-out counter */
     
    for (i = 0; i < NumSamples; i++)
    {
        Setup_Frame (&pSamples[i]);
        
        /* Call State machine only if samples are ready for
         * processing, or if there is any request for
         * signal/message transmission, or time out counter
         * has expired (here we need to go to initial state) */
         
        if (g_v8bis_flags.five_seconds_counter ||
            g_v8bis_flags.ssi_rx_samples_ready ||
            g_v8bis_flags.ssi_tx_samples_rqst)
        {
            V8bis_State_Machine ();
        }
    }
    
    /* Return the mode selected to the user */
    if (!v_v8bis_start_or_stop)
    {
        /* g_tx_host_msg_type indicates one of the values
         * defined in the enum v8bis_eTx_Host_Messsages present in 
         * v8bis.h, which is passed to the user through callback */
         
        pV8bis->Output[0] = g_tx_host_msg_type;
        (*(pV8bis->RXCallback->pCallback)) (pV8bis->RXCallback->pCallbackArg,
                                            pV8bis->Output, 1);
                                            
        /* Callback to pass to user the agreed capabilities. The
         * first value in the buffer is always the number of words
         * in the buffer excluding itself. */
         
        NumSams = *g_tx_host_data_ptr;
        if (NumSams != 0)
        {
            (*(pV8bis->RXCallback->pCallback)) (pV8bis->RXCallback->pCallbackArg,
                                                g_tx_host_data_ptr, NumSams + 1);
        }
    }
    
    /* V8bis state machine will not be entered if v_v8bis_start_or_stop
     * flag is false */
     
    if (v_v8bis_start_or_stop == TRUE)
    {
        return (PASS);
    }
    else
    {
        return (FAIL);
    }        
}


/***********************************************************************
*
* Module: local_tx_callback ()
*
* Description: Local function to facilitate callback from 
*              dsp_core_control.asm
*
* Returns: None
*
* Arguments: pSamples - a pointer to buffer containing received samples.
*            NumSamples - Number of samples pointed-to by pSamples.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_v8bis_IS.mcp or test_v8bis_RS.mcp for testing
*
**************************** Change History ****************************
*
*    DD/MM/YY   Code Ver       Description         Author
*    --------   --------       -----------         ------
*    08/08/2000  0.0.1         Created             Prasad N R
*    25/08/2000  1.0.0         Reviewed and        Prasad N R
*                              Baselined 
*
**********************************************************************/

void local_tx_callback (Word16 *pSamples, UWord16 Numsamples)
{
    (*(l_pV8bis->TXCallback->pCallback)) (l_pV8bis->TXCallback->pCallbackArg,
                                          pSamples, Numsamples);
    return;
}
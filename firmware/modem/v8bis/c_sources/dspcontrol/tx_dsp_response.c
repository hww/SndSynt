/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   tx_dsp_response.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Tx_Dsp_Response, which sends the responses
*   to the state machine.
*
*   Functions in this file :
*
*   Tx_Dsp_Response
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/***************************************************************************
*
*   FUNCTION NAME   -   Tx_Dsp_Response
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_v8bis_flags     
*   REFERENCED          g_single_tone_detected 
*                   
*   GLOBALS         -   g_v8bis_flags
*   MODIFIED            g_response_type
*                       g_response_data
*                      
*   FUNCTIONS       -   None 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   26/05/98    0.00        Module Created      B.S Shivashankar
*   03/07/98    0.00        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module sends the DSP responses to the state machine.
*
***************************************************************************/

void Tx_Dsp_Response()
{
    /*
    *  If SIGNAL_DETECTED flag is set, send the SIGNAL_DETECTED_RESPONSE
    *  message to state machine with data word containing the detected
    *  signal value.
    */

    if (g_v8bis_flags.signal_detected)
    {
        g_v8bis_flags.signal_detected = 0;
        g_response_type = SIGNAL_DETECTED_RESPONSE;
        g_response_data = (SIGNALS_MESSAGES) g_single_tone_detected;
    }

    /*
    *  If MESSAGE_RECEIVED flag is set, send the MESSAGE_RECEIVED_RESPONSE 
    *  message to state machine with data word, which tells whether the 
    *  received message is valid or invalid.
    */

    else if (g_v8bis_flags.message_received)
    {
        g_v8bis_flags.message_received = 0;
        g_response_type = MESSAGE_RECEIVED_RESPONSE;
        if (g_v8bis_flags.message_validity)
        {
            g_response_data = VALID_MESSAGE;
        }
        else
        {
            g_response_data = INVALID_MESSAGE;
        }
    }

}    

/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   rx_dsp_response.c 
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Rx_Dsp_Response, which receives the
*   responses from DSP and initializes appropriate variables.
*
*   Functions in this file:
*
*   Rx_Dsp_Response 
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

#define MIN_MSG_COUNT 5


/***************************************************************************
*
*   FUNCTION NAME   -   Rx_Dsp_Response
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_response_type
*   REFERENCED          g_response_data
*                       g_sig_msg  
*                       g_host_config
*                       g_msg_rx_buffer[]
*                   
*   GLOBALS         -   g_sig_msg 
*   MODIFIED            g_response_type
*                       g_response_data
*                       g_remote_cap[]
*                       g_ms_buffer[]
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
*   11/06/98    0.00        Module Created      B.S Shivashankar
*   17/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments
*   03/07/2000  0.10        Ported on to MW     N R Prasad
*   22/08/2000  1.00        CL-MS bug fixed     Mahesh, L Prasad,
*                           (This bug was       N R Prasad
*                            found in the
*                            base code that
*                            was developed 
*                            on unix)
****************************************************************************
*
*   DESCRIPTION      
*
*   This module receives responses from DSP modules and initializes
*   appropriate variables. 
*
***************************************************************************/

void Rx_Dsp_Response()
{
    W16 i;

    switch(g_response_type)   
    {
        /*
        *  If SIGNAL DETECTED RESPONSE is received, copy the detected
        *  signal type to the received signal/message variable.
        */

        case SIGNAL_DETECTED_RESPONSE:
                
        g_sig_msg = g_response_data;

        break;

        /*
        *  If MESSAGE RECEIVED RESPONSE is received, check the response
        *  word for validity of the message. If the message is invalid,
        *  indicate that, else check for the revision number, if it does
        *  not match declare the message is invalid, else copy the message
        *  type and octets.
        */  

        case MESSAGE_RECEIVED_RESPONSE:

        if (g_response_data == INVALID_MESSAGE)
        { 
            g_sig_msg = INVALID_MESSAGE;
        }

        else if (((g_msg_rx_buffer[1] & 0x00f0) >> 4) != 
                 g_host_config.revision_number)
        {
            g_sig_msg = INVALID_MESSAGE;
        }    
            
        else
        {
            /*
            *  Copy the message type field to g_sig_msg.
            */

            g_sig_msg = (SIGNALS_MESSAGES) (g_msg_rx_buffer[1] & 0x000f);

            if ((g_sig_msg == CL) || (g_sig_msg == CLR) || (g_sig_msg == MS))
            {
                /*
                *  If the message count is less than 5, then indicate that
                *  a INVALID message is received.
                */

                if (g_msg_rx_buffer[0] < MIN_MSG_COUNT)
                {    
                    g_sig_msg = INVALID_MESSAGE;
                    break;
                }    
            }

            switch(g_sig_msg)
            {
                case CL:
                case CLR:

                /*
                *  Copy the received octets to remote capability buffer.
                */

                for(i = 0; i <= g_msg_rx_buffer[0]; i++)
                {
                    g_remote_cap[i] = g_msg_rx_buffer[i];
                }   
                break;
                    
                case MS:

                /*
                *  Copy the received octets to MS buffer.
                */

                for(i = 0; i <= g_msg_rx_buffer[0]; i++)
                {
                    g_ms_buffer[i] = g_msg_rx_buffer[i];
                }   
                break;
                
                /* The following code has been added to solve the ACK1
                * detection problem in transactions involving CL-MS message    
                * Added by MKR */
                case ACK1:
                
                if (g_v8bis_flags.message_gen_enable)
                {
                     g_sig_msg = NIL;
                     g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
                }
                
                break;

                default:

                break;
            }
        }
        break;

        default:

        break;  

    }

    /*
    *  Clear the response words.
    */

    g_response_type = NIL_RESPONSE;     
    g_response_data = NIL;

    return ;
}

/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   tx_v8bis_success_host_message.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Tx_host_Message_V8bis_Success, which 
*   transmits the v8bis success message to host.
*
*   Functions in this file:
*
*   Tx_host_Message_V8bis_Success 
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/***************************************************************************
*
*   FUNCTION NAME   -   Tx_host_Message_V8bis_Success 
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_v8bis_flags
*   REFERENCED          g_ms_buffer[]  
*                   
*   GLOBALS         -   g_tx_host_msg_type
*   MODIFIED            g_tx_host_data_ptr
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
*   10/06/98    0.00        Module Created      B.S Shivashankar
*   16/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module transmits the v8bis success message to the host. It also
*   sends the modes selected and whether to initiate modem handshaking or
*   look for modem handshake signals.
*
***************************************************************************/

void Tx_Host_Message_V8bis_Success()
{
    /*
    *  If START MODEM HANDSHAKE flag is set, send the message to host
    *  to start modem handshaking, else to look for modem handshake 
    *  signals.
    */

    if (g_v8bis_flags.start_modem_handshake)
    {
        g_tx_host_msg_type = V8BIS_SUCCESS_INITIATE_MODEM_HANDSHAKE;
    }
    else
    {
        g_tx_host_msg_type = V8BIS_SUCCESS_LOOK_FOR_MODEM_HANDSHAKE;
    }

    /*
    *  Send the modes selected to host.
    */

    g_tx_host_data_ptr = &g_ms_buffer[0];

    return;
}    

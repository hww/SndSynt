/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   tx_error_host_message.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Tx_Host_Message_Error, which transmits
*   error message to the host. 
*
*   Functions in this file:
*
*   Tx_Host_Message_Error
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/***************************************************************************
*
*   FUNCTION NAME   -   Tx_Host_Message_Error
*
*   INPUT           -   error_id 
*
*   OUTPUT          -   None
*
*   GLOBALS         -   None 
*   REFERENCED          
*                   
*   GLOBALS         -   g_tx_host_msg_type   
*   MODIFIED            s_tx_host_data
*                       g_tx_host_data_ptr
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
*   This module transmits error message to the host with error id.
*
***************************************************************************/

static W16 s_tx_host_data;

void Tx_Host_Message_Error(ERROR_IDS error_id)
{
   g_tx_host_msg_type = ERROR_MESSAGE;
   s_tx_host_data = (W16) error_id;
   g_tx_host_data_ptr = &s_tx_host_data;

#if DEMO 
   v_v8bis_start_or_stop = FALSE;
#endif

   return;
}




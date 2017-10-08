/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   rx_host_message.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Rx_Host_Message, which receives the host
*   messages and initiates appropriate actions. 
*
*   Functions in this file:
*
*   Rx_Host_Message
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

 
void host();
 

/***************************************************************************
*
*   FUNCTION NAME   -   Rx_Host_Message 
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_v8bis_flags
*   REFERENCED          g_rx_host_msg_type 
*                       g_rx_host_data_ptr
*                   
*   GLOBALS         -   g_host_config     
*   MODIFIED            g_local_cap[]
*                       g_prior[][]
*                       g_remote_cap[]
*                       g_v8bis_flags
*                       g_rx_host_msg_type
*                       g_tx_host_msg_type
*                       g_rx_host_data_ptr
*                      
*   FUNCTIONS       -   Goto_Initial_State 
*   CALLED              Tx_Host_Message_Error 
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   28/05/98    0.00        Module Created      B.S Shivashankar
*   17/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module receives the host messages. If the V.8 bis is transaction is
*   already started, it sends the error message to the host. It copies the
*   host data to appropriate global variables.
*
***************************************************************************/

void Rx_Host_Message()
{
    W16 i, j, count;
    W16 *prior_ptr;

    /*
    *  Call the function to update g_rx_host_msg_type and g_rx_host_data_ptr
    */  
     
    host();
         


    if (g_rx_host_msg_type != NIL_RX_HOST_MESSAGE)
    {

        /*
        *  If the host message is STOP_V8BIS_TRANSACTION, call the module 
        *  to reset all flags and go back to initial v.8 bis state.
        */

        if (g_rx_host_msg_type == STOP_V8BIS_TRANSACTION_MESSAGE)
        {
            Goto_Initial_State();
            g_tx_host_msg_type = ACK_MESSAGE;
        }       

        /*
        *  If V.8 bis transaction is already started, send an error 
        *  message to the host.
        */

        else if (g_v8bis_flags.v8bis_transaction_on)
        {
            Tx_Host_Message_Error(V8BIS_TRANSACTION_STARTED);
        }

        /*
        *  If the host message is CONFIGURATION_MESSAGE, copy the data
        *  to g_host_config variable.The configuration word is of 16 bits
        *  and it can be accessed by the ptr g_rx_host_data_ptr.
        */

        else
        {       

            if (g_rx_host_msg_type == CONFIGURATION_MESSAGE)
            {

                /*
                *  Save registers
                */
            
                asm(move r0,i);
                asm(move y0,j);

                /*
                *  Copy the configuration word to g_host_config.
                */

                asm(move g_rx_host_data_ptr,r0);
                asm(nop);
                asm(move x:(r0),y0);
                asm(move y0,g_host_config);

                /*
                *  Restore registers
                */
            
                asm(move i,r0);
                asm(move j,y0);
                
                g_v8bis_flags.host_config_msg_rxd = 1;
            }

            /*
            *  If the host message is CAPABILITIES_MESSAGE, copy the data 
            *  into local capabilities array. The first location of the  
            *  array contains number of octets contained in the array. The  
            *  octets can be accessed using the pointer g_rx_host_data_ptr.
            */

            else if (g_rx_host_msg_type == CAPABILITIES_MESSAGE)
            {
                count = *g_rx_host_data_ptr;
                for (i = 0; i <= count; i++)
                {
                    g_local_cap[i] = *g_rx_host_data_ptr++;
                }
        
                /*
                *  Set the flag to indicate that local capabilities 
                *  are received.
                */

                g_v8bis_flags.host_cap_msg_rxd = 1;
            }    

            /*
            *  If the host message is PRIORITIES_MESSAGE, copy the data 
            *  into local priorities array.
            *  The host data is a single dimensional array, the last 
            *  priority of each type contains the zero data.
            */

            else if (g_rx_host_msg_type == PRIORITIES_MESSAGE)
            {
                count = *g_rx_host_data_ptr++;
                prior_ptr = &g_prior[0][0];

                for(i = 0; i < count; i++)
                {
                    *prior_ptr++ = *g_rx_host_data_ptr++;
                }

                /*
                *  Set the flag to indicate that local priorities are 
                *  received.
                */

                g_v8bis_flags.host_priority_msg_rxd = 1;
            }    

            /*
            *  If the host message is REMOTE_CAPABILITIES_MESSAGE, copy 
            *  the data into remote capabilities array.
            */

            else if (g_rx_host_msg_type == REMOTE_CAPABILITIES_MESSAGE)
            {
                count = *g_rx_host_data_ptr;
                for (i = 0; i <= count; i++)
                {
                    g_remote_cap[i] = *g_rx_host_data_ptr++;
                }

                /*
                *  Set the flag to indicate that remote capabilities 
                *  are received.
                */

                g_v8bis_flags.host_rcap_msg_rxd = 1;
            }    

            /*
            *  If the host message is INITIATE_TRANSACTION, set the flag 
            *  to indicate that.
            */

            else if (g_rx_host_msg_type == INITIATE_TRANSACTION_MESSAGE)
            {
                g_v8bis_flags.initiate_transaction = 1;
            }   
            else if (g_rx_host_msg_type == TX_GAIN_FACTOR_MESSAGE)
            {
                v8_txgain = *g_rx_host_data_ptr;
            }

            /*
            *  Send a ACK message to host.
            */

            g_tx_host_msg_type = ACK_MESSAGE;

        } /* End of ELSE loop */        

        /*
        *  Clear the received host message word.
        */

        g_rx_host_msg_type = NIL_RX_HOST_MESSAGE;
    }

    return;
}    

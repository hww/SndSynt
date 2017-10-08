/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   rx_ctrl_command.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists the module Rx_Ctrl_Command, which receives the 
*   commands from state machine control module and takes appropriate 
*   actions.
*
*   Functions in this file :
*
*   Rx_Ctrl_Command
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"


/***************************************************************************
*
*   FUNCTION NAME   -   Rx_Ctrl_Command
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_command_type 
*   REFERENCED          g_command_data
*                       g_v8bis_flags 
*                   
*   GLOBALS         -   g_command_type 
*   MODIFIED            g_signal_type  
*                       g_v8bis_flags 
*                      
*   FUNCTIONS       -   Signal_Gen_Init 
*   CALLED              Message_Gen_Init 
*                       Signal_Detect_Init
*                       Msg_Receive_Init
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   26/05/98    0.00        Module Created      B.S Shivashankar
*   03/07/2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module receives the commands from the state machine control module
*   and initiates the appropriate actions.
*
***************************************************************************/


void Rx_Ctrl_Command()
{
    switch(g_command_type)
    {
        /*
        *  If the command is SEND_SIGNAL_COMMAND, call the signal 
        *  generation initialization module and set the flag to
        *  indicate that DSP transmission is busy.
        */

        case SEND_SIGNAL_COMMAND:

        g_signal_type = g_command_data;    
        Signal_Gen_Init();
        g_v8bis_flags.dsp_tx_busy = 1;
        break;

        case SEND_MESSAGE_COMMAND:

        /*
        *  If the message is to be preceded by ES, call the signal 
        *  generation init module to generate ESi or ESr depending
        *  on whether it is a initiating or responding station.
        */

        if (g_v8bis_flags.precede_es)
        {
            g_v8bis_flags.precede_es = 0;
            if (g_v8bis_flags.station == INIT_STATION)
            {
                g_signal_type = ESi;
            }
            else
            {
                g_signal_type = ESr;
            }
            Signal_Gen_Init();
        }    

        /*
        *  Else call the message generation initialization module.
        */

        else
        {
            Message_Gen_Init();
        }
        g_v8bis_flags.dsp_tx_busy = 1;

        break;

        /*
        *  If the command is ENABLE_SIG_SEARCH_COMMAND, call the signal
        *  detection initialization module and disable message reception
        *  enable flag.
        */

        case ENABLE_SIG_SEARCH_COMMAND:

        Signal_Detect_Init();
        g_v8bis_flags.message_reception_enable = 0;

        break;

        /*
        *  If the command is ENABLE_MSG_RECEPTION_COMMAND, call the message 
        *  receive initialization module and disable signal detection enable
        *  flag.
        */

        case ENABLE_MSG_RECEPTION_COMMAND:

        Msg_Receive_Init();
        g_v8bis_flags.signal_detect_enable = 0;

        break;

        default:

        break;
    }

    /*
    *  Clear the command words
    */

    g_command_type = NIL_COMMAND;
    g_command_data = NIL;
}    
        

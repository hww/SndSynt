/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   v8bis_init.c 
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file initializes all variables required for V.8 bis software.
*
*   Functions in this file:
*
*   V8bis_Init 
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"


/***************************************************************************
*
*   FUNCTION NAME   -   V8bis_Init
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_v8bis_flags
*   REFERENCED          g_host_config 
*                   
*   GLOBALS         -   g_command_type
*   MODIFIED            g_command_data
*                       g_response_type
*                       g_response_data
*                       g_sig_msg
*
*                       v_v8bis_start_or_stop
*                       g_tx_host_msg_type 
*                       g_rx_host_msg_type
*                       g_dual_offset
*                       g_single_offset
*                       g_signal_amp
*                       g_v8bis_control
*                       g_signal_counter
*                       g_current_decision
*                       g_single_tone_detected
*                       g_signal_type
*                       g_host_config
*                       g_signal_gen_state
*                       g_signal_det_state
*                       g_message_gen_state
*                       g_message_rx_state
*                       v_timeout_counter
*                       g_current_msg_gen_byte
*                       g_v21_rx_decision_length
*                       g_flag_gen_counter
*                       g_v21_rxdemod_bits
* 
*
*   FUNCTIONS       -   Goto_Initial_State
*   CALLED              Rx_Host_Message
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
*                           Review Comments
*   03/07/2000  0.10        Ported on to MW     N R Prasad
*   04/09/2000  1.00        Initialization      N R Prasad,
*                           bug fixed. (This    Sanjay Karpoor
*                           bug was found in
*                           the unix base code)
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module initializes all variables required for V.8 bis software. It
*   Receives host messages.
*
***************************************************************************/

extern void V8bis_Init_to_Zero (void);


void V8bis_Init ()
{
    W16 i;

    /* To start with, initialize all memory locations to zero.
     * The following function is in file v8bis_ram.asm */
    V8bis_Init_to_Zero ();
    
    /*
    *  Initialize the global variables.
    */
    
    codec_tx_rptr = &codec_tx_buffer[0];
    g_codec_tx_buf_ptr = &codec_tx_buffer[48];
    g_codec_rx_buf_ptr = &codec_rx_buffer[0];
    codec_rx_wptr = &codec_rx_buffer[0];

    v8_ssi_txctr = SAMPLES_PER_BAUD;
    v8_ssi_rxctr = 0;

    for (i = 0; i < CODEC_BUFFER_LENGTH; i++)
    {
        codec_tx_buffer[i] = 0;
        codec_rx_buffer[i] = 0;
    }

    g_command_type = NIL_COMMAND;
    g_command_data = NIL;
    g_response_type = NIL_RESPONSE;
    g_response_data = NIL;
    g_sig_msg = NIL;
    g_tx_host_msg_type = NIL_TX_HOST_MESSAGE;
    g_rx_host_msg_type = NIL_RX_HOST_MESSAGE;
    v_v8bis_start_or_stop = TRUE;
    v8_txgain = 0x4000;
    
    /* Globals initialized to zero to solve the 
     * initialization bug during successive transactions */
     
    g_dual_offset = 0;
    g_single_offset = 0;
    g_signal_amp = 0;
    g_v8bis_control = 0;
    g_signal_counter = 0;
    g_current_decision = 0;
    g_single_tone_detected = 0;
    g_signal_type = 0;
    asm (move #0,g_host_config);
    g_signal_gen_state = 255;
    g_signal_det_state = 255;
    g_message_gen_state = 255;
    g_message_rx_state = 0;
    v_timeout_counter = 0;
    g_current_msg_gen_byte = 0;
    g_v21_rx_decision_length = 0;
    g_flag_gen_counter = 0;
    g_v21_rxdemod_bits = 0;
    

    /*
    *  Call the module Goto_Initial_State. This module initializes
    *  v8 bis state to INITIAL V8BIS STATE, and initializes the 
    *  command variable to detect initiating signals.
    */ 

    Goto_Initial_State();

    /*
    *  If CONFIGURATION, CAPABILITIES and PRIORITIES messages have not
    *  come from host, call the module Rx_Host_Message repeatedly till
    *  all the three messages arrive.
    */

    while (!g_v8bis_flags.host_config_msg_rxd || 
           !g_v8bis_flags.host_cap_msg_rxd ||
           !g_v8bis_flags.host_priority_msg_rxd)
    {   
        Rx_Host_Message();
    }   

    /*
    *  If local station knows remote capabilities, call the module 
    *  Rx_Host_Message repeatedly until the REMOTE CAPABILITIES
    *  message arrive.
    */  

    if (g_host_config.local_knows_rcap)
    {
        while(!g_v8bis_flags.host_rcap_msg_rxd)
        {
            Rx_Host_Message();
        }
    }   

    return;
}    


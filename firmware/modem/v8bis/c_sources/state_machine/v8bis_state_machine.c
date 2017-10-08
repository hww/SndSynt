/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   v8bis_state_machine.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists modules related to V.8 bis state machine.It imlements
*   V.8 bis transactions as listed in TABLE 7 of Recommendation V.8 bis,
*   except transactions #7, #8 and #9 were not implemented if it is a
*   responding station.
*
*   Functions in this file:
*
*   V8bis_State_Machine
*   Send_Msg_Clr
*   Send_Msg_Cl
*   Send_Msg_Ms
*   Send_Msg_Nak1
*   Send_Msg_Ack1_Or_Nak3
*   Send_Sig_Crd
*   Check_Timeout_Counter
*   Goto_Initial_State
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/* static variables */

static ERROR_IDS s_error_id;

/***************************************************************************
*
*   FUNCTION NAME   -   V8bis_State_Machine
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_host_config
*   REFERENCED          g_local_Cap[]
*                       g_v8bis_state
*                       v_v8bis_start_or_stop
*                       g_sig_msg
*                   
*   GLOBALS         -   g_msg_tx_buffer[] 
*   MODIFIED            g_v8bis_flags
*                       g_v8bis_state
*                       g_command_type
*                       g_command_data
*                       g_sig_msg
*                       v_timeout_counter 
*                      
*   FUNCTIONS       -   V8bis_Init
*   CALLED              Dsp_Core_Control 
*                       Rx_Dsp_Response 
*                       Rx_Host_Message
*                       Send_Msg_Clr
*                       Send_Msg_Cl
*                       Send_Msg_Ms
*                       Send_Msg_Nak1
*                       Send_Msg_Ack1_Or_Nak3
*                       Send_Sig_Crd
*                       Tx_Host_Message_V8bis_Success
*                       Tx_Host_Message_Error
*                       Check_Timeout_Counter 
*                       Goto_Initial_State
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It is a V.8 bis state machine module. It implements V.8 bis transactions
*   as given Table 7 of Recommendation V.8 bis. It calls different module to 
*   send commands to lower level modules, to receive responses from lower 
*   level modules and to transmit and receive host messages.
*
***************************************************************************/

void V8bis_State_Machine()
{
    W16 i;

    /*
     * Initialize the tx_complete_cntr to 12.
     * This counter is used to ensure that all the samples in the codec 
     * buffer are transmitted. Since there can be a maximum of 12 bauds
     * in the trasmit codec buffer, this counter is initialized to 12.
     */
    

    /*
    *  Clear error id word.
    */

    s_error_id = NIL_ID;


    /*
    *  While v_v8bis_start_or_stop is non zero, enter the V.8 bis state machine.
    */
  
        switch(g_v8bis_state)
        {   

            case INITIAL_V8BIS_STATE:

            /*
            *  If the INITIATE TRANSACTION flag is set.
            */   

            if (g_v8bis_flags.initiate_transaction)
            {
                /*
                *  Reset INITIATE TRANSACTION flag.
                */

                g_v8bis_flags.initiate_transaction = FALSE;

                /*
                *  Set the flag to indicate that transaction is started.
                */

                g_v8bis_flags.v8bis_transaction_on = TRUE;

                /*
                *  Set the flag to indicate that it is a initiating station.
                */

                g_v8bis_flags.station = INIT_STATION; 

                /*
                *  If a priori knowledge of remote V.8 bis is not
                *  available AND telephony mode is available at local 
                *  initiate transaction #1 or #2 or #3.
                */

                if (!g_host_config.rem_v8bis_knowldg && 
                    g_host_config.telephony_mode)
                { 
                    /*  
                    *  If remote knows local capabilities, initiate 
                    *  transaction #1,otherwise initiate trans #2 or #3.
                    */

                    if  (g_host_config.remote_knows_lcap)
                    {
                        /*
                        *  If local is a auto answering machine, initiate
                        *  transaction with MRe, otherwise initiate with MRd
                        */

                        if (g_host_config.auto_answering)  
                        { 
                            /*
                            *  Send a command to DSP core module to transmit
                            *  signal MRe.
                            */

                            g_command_type = SEND_SIGNAL_COMMAND;
                            g_command_data = MRe;
                            Dsp_Core_Control();

                            /*
                            *  Go to SENT_MR_STATE and initialize the five 
                            *  seconds counter.
                            */

                            g_v8bis_state = SENT_MR_STATE;
                            v_timeout_counter = FIVE_SECONDS_COUNT;
                            g_v8bis_flags.five_seconds_counter = 0;

                            /*
                            *  Send a command to DSP core module to detect
                            *  responding signals.
                            */

                            g_command_type = ENABLE_SIG_SEARCH_COMMAND;
                        } 

                        else
                        { 
                            /*
                            *  Send a command to DSP core module to transmit
                            *  signal MRd.
                            */

                            g_command_type = SEND_SIGNAL_COMMAND;
                            g_command_data = MRd;
                            Dsp_Core_Control();

                            /*
                            *  Go to SENT_MR_STATE and initialize the five 
                            *  seconds counter.
                            */
  
                            g_v8bis_state = SENT_MR_STATE;
                            v_timeout_counter = FIVE_SECONDS_COUNT;
                            g_v8bis_flags.five_seconds_counter = 0;

                            /*
                            *  Send a command to DSP core module to detect
                            *  message.
                            */

                            g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
                        }
                    }

                    else
                    {   

                        /*
                        *  If local is a auto answering machine,initiate
                        *  transaction with CRe, else initiate with CRd
                        */

                        if (g_host_config.auto_answering)  
                        { 
                            /*
                            *  Send a command to DSP core module to transmit
                            *  signal CRe.
                            */

                            g_command_type = SEND_SIGNAL_COMMAND;
                            g_command_data = CRe;
                            Dsp_Core_Control();

                            /*
                            *  Go to SENT_CR_OR_CLR_STATE and initialize the 
                            *  five seconds counter.
                            */

                            g_v8bis_state = SENT_CR_OR_CLR_STATE;
                            v_timeout_counter = FIVE_SECONDS_COUNT;
                            g_v8bis_flags.five_seconds_counter = 0;

                            /*
                            *  Send a command to DSP core module to detect
                            *  responding signals.
                            */

                            g_command_type = ENABLE_SIG_SEARCH_COMMAND;
                        } 

                        else
                        { 
                            Send_Sig_Crd();
                        }
                    } 
                }

                /*
                *  If a priori knowledge of remote V.8 bis is available OR 
                *  telephony mode is not available,initiate transaction #4 
                *  or #5 or #6
                */

                else if (g_host_config.rem_v8bis_knowldg || 
                         !g_host_config.telephony_mode)
                {
                    /*
                    *  If local knows remote capabilities, initiate 
                    *  transaction #4 (ESi_MS).
                    */

                    if (g_host_config.local_knows_rcap)
                    {
                        /*
                        *  Set the flag to indicate that message should be
                        *  preceded by signal ES. Whether the signal is ESi
                        *  or ESr is decided by the flag 
                        *  g_host_config.station. This flag will indicate
                        *  whether it is a initiating or responding station.
                        */

                        g_v8bis_flags.precede_es = TRUE;
                        Send_Msg_Ms(); 
                    }

                    /*
                    *  If local wants to make decision OR local wants to 
                    *  know remote capabilities, initiate transaction 
                    *  #6 (ESi_CLR),otherwise initiate trans #5 (ESi_CL)
                    */

                    else if (g_host_config.local_wants_decision || 
                             g_host_config.local_wants_rcap)
                    {
                        /*
                        *  Set the flag to indicate that message should be
                        *  preceded by signal ES.
                        */

                        g_v8bis_flags.precede_es = TRUE;

                        /*
                        *  Copy the local capabilities to transmission 
                        *  buffer. The first element of the array contains 
                        *  the the count of octets.
                        */

                        for (i = 0; i <= g_local_cap[0]; i++)
                        {
                            g_msg_tx_buffer[i] = g_local_cap[i];
                        }

                        /*
                        *  Set the message type, and the revision number.
                        */

                        g_msg_tx_buffer[1] = MSG_TYPE_CLR | 
                                    (g_host_config.revision_number << 4);

                        /*
                        *  Send the command to DSP core module to transmit 
                        *  message.
                        */

                        g_command_type = SEND_MESSAGE_COMMAND;
                        Dsp_Core_Control();

                        /*
                        *  Go to SENT_CR_OR_CLR_STATE and initialize the 
                        *  five seconds counter.
                        */

                        g_v8bis_state = SENT_CR_OR_CLR_STATE;
                        v_timeout_counter = FIVE_SECONDS_COUNT;
                        g_v8bis_flags.five_seconds_counter = 0;

                        /*
                        *  Send a command to DSP core module to detect
                        *  message.
                        */

                        g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
                    }
 
                    else
                    {
                        /*
                        *  Set the flag to indicate that message should be
                        *  preceded by signal ES.
                        */

                        g_v8bis_flags.precede_es = TRUE;
                        Send_Msg_Cl(); 
                    } 

                }

            } /* End of IF <initiate transaction> loop */

            /*
            *  If INITIATE TRANSACTION flag is not set.
            */

            else
            {
                switch(g_sig_msg)
                {
                    /*
                    *  If the received message is invalid, send NAK1 and 
                    *  return to initial state
                    */

                    case INVALID_MESSAGE:

                    Send_Msg_Nak1();

                    break;
 
                    /*
                    *  If MRd is received AND local knows remote 
                    *  capabilities send MS (trans #1).
                    */

                    case MRd:  

                    if (g_host_config.local_knows_rcap)
                    {
                        Send_Msg_Ms();

                        /*
                        *  Set the flag to indicate that v8bis transaction 
                        *  is started.
                        */

                        g_v8bis_flags.v8bis_transaction_on = TRUE;
                    }

                    break;

                    /*
                    *  If MRe is received.
                    */
  
                    case MRe:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;
                 
                    /*
                    *  If local knows remote capabilities, send ESr_MS
                    *  (trans #1), else send CRdr (trans #10 or #11).
                    */
    
                    if (g_host_config.local_knows_rcap)
                    {
                       
                        /*
                        *  Set the flag to indicate that message should be
                        *  preceded by signal ES.
                        */

                        g_v8bis_flags.precede_es = TRUE;
                        Send_Msg_Ms();
                    }
                       
/* This is the code added by BPL */

                    /* This is to implement the transaction #7, #8 & #9 */

                    else if (!g_host_config.local_wants_decision)

                    {
                    
                         g_command_type = SEND_SIGNAL_COMMAND;
                         g_command_data = MRd;
                         Dsp_Core_Control();

					    /*
					    *  Go to SENT_MR_STATE and initialize the five 
					    *  seconds counter.
					    */
					
					     g_v8bis_state = SENT_MR_STATE;
					     v_timeout_counter = FIVE_SECONDS_COUNT;
					     g_v8bis_flags.five_seconds_counter = 0;
					     
					     if (g_host_config.remote_knows_lcap)
					     {
					          /* Tranaction #7. Look for message MS */
					          g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
					     }
					     else
					     {
					          /* Tranaction #8 & #9. Look for signal CRd */
					          g_command_type = ENABLE_SIG_SEARCH_COMMAND;
					     }
					                       
                    }
                    
/* End of the code added by BPL*/                   

                    else
                    {
                    
                        Send_Sig_Crd();
                    }

                    break;

                    /*
                    *  If CRe is received.
                    */

                    case CRe:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;

                    /*
                    *  If local wants to make decision, send CRd
                    *  (trans #12 or #13)
                    */   
                       
                    if  (g_host_config.local_wants_decision)
                    {
                        Send_Sig_Crd(); 
                    }
 
                    else
                    {
                        /*
                        *  If local wants to know remote capabilities,
                        *  send ESr_CLR (trans #3), *  otherwise send 
                        *  ESr_CL (trans #2)
                        */
 
                        if (g_host_config.local_wants_rcap)
                        {
                            /*
                            *  Set the flag to indicate that the message 
                            *  should be preceded by ES.
                            */

                            g_v8bis_flags.precede_es = TRUE;

                            /*
                            *  Set the flag to indicate that the message 
                            *  CL_MS is expected from remote station.
                            */

                            g_v8bis_flags.cl_ms_expected = TRUE; 
                            Send_Msg_Clr();
                        }
                        else
                        {
                            /*
                            *  Set the flag to indicate that the message 
                            *  should be preceded by ES.
                            */

                            g_v8bis_flags.precede_es = TRUE;
                            Send_Msg_Cl();
                        }
                    }

                    break;

                    /*
                    *  If CRd is received.
                    */

                    case CRd:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;

                    /*
                    *  If local wants to know remote capabilities,
                    *  send CLR (trans #3),else send CL (trans #2)
                    */
 
                    if (g_host_config.local_wants_rcap)
                    {
                        /*
                        *  Set the flag to indicate that the message CL_MS
                        *  is expected from remote station.
                        */

                        g_v8bis_flags.cl_ms_expected = TRUE; 
                        Send_Msg_Clr();
                    }

                    else
                    {
                        Send_Msg_Cl();
                    }

                    break;

                    /*
                    *  If MS is received,send ACK1 or NAK3 (trans #4).
                    */   

                    case MS:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;

                    Send_Msg_Ack1_Or_Nak3();

                    break;

                    /*
                    *  If CL is received, send MS (trans #5).
                    */   

                    case CL:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;
                    g_v8bis_flags.send_nak1 = TRUE;
                    Send_Msg_Ms();

                    break;

                    /*
                    *  If CLR is received, send CL (trans #6).
                    */   

                    case CLR:

                    /*
                    *  Set the flag to indicate that v8bis transaction 
                    *  is started.
                    */

                    g_v8bis_flags.v8bis_transaction_on = TRUE;

                    Send_Msg_Cl();

                    break;
        
                    default:

                    break;

                } /* End of SWITCH <g_sig_msg> */

                /*
                *  Clear the global variable g_sig_msg.
                */

                g_sig_msg = NIL;

            } /* End of IF <initiate transaction> - ELSE loop */

            break;      
 
            case SENT_MR_STATE:

            /*
            *  Call the module to check the five seconds counter. If the
            *  counter is expired, exit from the sent MR state.
            */ 

            Check_Timeout_Counter();

            /*
            *  If dsp transmission is busy, exit from the sent MR state.
            */

            if (g_v8bis_flags.dsp_tx_busy)
            {
                break;
            } 

            switch(g_sig_msg)
            {
                /*
                *  If the received message is invalid,send NAK1
                *  and return to initial state
                */

                case INVALID_MESSAGE:

                Send_Msg_Nak1();  

                break;

                /*
                *  If MS is received,send ACK1 or NAK3 (trans #1 or #7)
                */   

                case MS:

                Send_Msg_Ack1_Or_Nak3();

                break;

                /*
                *  If CRd is received.
                */

                case CRd:

                /*
                *  If local wants to know remote capabilities
                *  send CLR (trans #9 or #11), else send CL (trans #8 or #10)
                */ 
               
                if (g_host_config.local_wants_rcap)
                {
                    g_v8bis_flags.cl_ms_expected = TRUE; 
                    Send_Msg_Clr();
                }
                else
                {
                    Send_Msg_Cl();
                }

                break;


                /*
                *  If MRd is received.
                */

                case MRd:

                /*
                *  If local knows remote capabilities, send MS (trans #7)
                *  else send CRd (trans #8 or #9)
                */

                if (g_host_config.local_knows_rcap)    
                {
                    Send_Msg_Ms(); 
                }

                else
                {
                    g_command_type = SEND_SIGNAL_COMMAND;
                    g_command_data = CRd;  
                    Dsp_Core_Control();

                    /*
                    *  Go to SENT_CR_OR_CLR_STATE and initialize the five
                    *  seconds counter.
                    */

                    g_v8bis_state = SENT_CR_OR_CLR_STATE;
                    v_timeout_counter = FIVE_SECONDS_COUNT;
                    g_v8bis_flags.five_seconds_counter = 0;
                    g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
                }

                break;

                default: 
            
                break;

            } /* End of SWITCH <g_sig_msg> */

            /*
            *  Clear the global variable g_sig_msg.
            */

            g_sig_msg = NIL;

            break;
    
            case SENT_MS_STATE: 

            /*
            *  If the TRANSMIT_ACK1 parameter is reset, call the
            *  module to detect modem handshake signal.
            */

            if (!(g_ms_buffer[ID_NPAR1_INDEX] & TRANSMIT_ACK1))
            {
                Detect_Modem_Hs_Signal(); 

                /*
                *  If the handshake signal is detected, go to 
                *  MSMODE STATE.
                */

                if (g_v8bis_flags.hs_signal_detected)
                {
                    g_v8bis_state = MSMODE_STATE;
                    v_timeout_counter = TWELVE_BAUD_COUNT;

                    break;
                }  
            }

            /*
            *  Call the module to check the five seconds counter. 
            */ 

            Check_Timeout_Counter();

            /*
            *  IF dsp transmission is busy, exit from the sent MS state.
            */

            if (g_v8bis_flags.dsp_tx_busy)
            {
                break;
            } 

            switch(g_sig_msg)
            {
                /*
                *  If the received message is invalid,send NAK1
                *  and return to initial state
                */

                case INVALID_MESSAGE:

                Send_Msg_Nak1();

                break;

                /*
                *  If ACK1 is received, go to MSMODE STATE.
                */

                case ACK1:
   
                g_v8bis_flags.start_modem_handshake = 0;
                g_v8bis_state = MSMODE_STATE;
                v_timeout_counter = TWELVE_BAUD_COUNT;

                break;

                /*
                *  If NAK is received, return to initial state. Send a command 
                *  to DSP core module to detect initiating signals and also 
                *  send a error message to host.
                */

                case NAK1:

                Goto_Initial_State();
                Tx_Host_Message_Error(RECEIVED_NAK1_MSG);

                break;


                case NAK2:
                case NAK3:

                Goto_Initial_State();
                Tx_Host_Message_Error(RECEIVED_NAK2_Or_3_MSG);

                break;

                default:

                break;

            } /* End of SWITCH <g_sig_msg> */

            /*
            *  Clear the global variable g_sig_msg
            */

            g_sig_msg = NIL;

            break;

            case SENT_CL_STATE:

            /*
            *  Call the module to check the five seconds counter. 
            */ 

            Check_Timeout_Counter();

            /*
            *  IF dsp transmission is busy, exit from the sent CL state.
            */

            if (g_v8bis_flags.dsp_tx_busy)
            {
                break;
            } 

            switch(g_sig_msg)
            {
                /*
                *  If the received message is invalid,send NAK1
                *  and return to initial state
                */

                case INVALID_MESSAGE:

                Send_Msg_Nak1();

                break;

                /*
                *  If MS is received send ACK1 or NAK3 (trans #2,5,8,10,12)
                */

                case MS: 
 
                Send_Msg_Ack1_Or_Nak3();                      

                break;  

                /*
                *  If NAK is received, return to initial state. Send a command 
                *  to DSP core module to detect initiating signals and also send 
                *  a error message to host.
                */

                case NAK1:

                Goto_Initial_State();
                Tx_Host_Message_Error(RECEIVED_NAK1_MSG);

                break;

                default:

                break;
            }

            /*
            *  Clear the global variable g_sig_msg.
            */

            g_sig_msg = NIL;

            break;

            case SENT_CLR_STATE:

            /*
            *  Call the module to check the five seconds counter. 
            */ 

            Check_Timeout_Counter();

            /*
            *  IF dsp transmission is busy, exit from the sent CLR state.
            */

            if (g_v8bis_flags.dsp_tx_busy)
            {
                break;
            } 

            switch(g_sig_msg)
            {
                /*
                *  If the received message is invalid,send NAK1
                *  and return to initial state
                */

                case INVALID_MESSAGE:

                Send_Msg_Nak1();

                break;

                /*
                *  If CL is received, set the the flag to indicate that.
                */

                case CL:
 
                g_v8bis_flags.cl_received = TRUE;

                if (g_remote_cap[ID_NPAR1_INDEX] & ADDITIONAL_INFO_AVAILABLE)
                {
                    g_msg_tx_buffer[0] = 1;
                    g_msg_tx_buffer[1] = MSG_TYPE_ACK1 | 
                                         (g_host_config.revision_number << 4);
                    g_command_type = SEND_MESSAGE_COMMAND;
                }

                break;  

                /*
                *  If MS is received and if the CL received flag is set
                *  (i.e message CL_MS is received), send ACK1 or NAK3
                *  (transactions #3,9,11,13)
                */

                case MS:

                if (g_v8bis_flags.cl_received)
                {
                    g_v8bis_flags.cl_received = FALSE;
                    Send_Msg_Ack1_Or_Nak3();
                }

                break;

                /*
                *  If NAK is received, send a error message to host and
                *  return to initial state. Send a command to DSP core
                *  module to detect initiating signals.
                */

                case NAK1:

                Goto_Initial_State();
                Tx_Host_Message_Error(RECEIVED_NAK1_MSG);

                break;

                default:
       
                break;
               
            }

            /*
            *  Clear the global variable g_sig_msg.
            */

            g_sig_msg = NIL;

            break;

            case SENT_CR_OR_CLR_STATE:

            /*
            *  Call the module to check the five seconds counter. 
            */ 

            Check_Timeout_Counter();

            /*
            *  IF dsp transmission is busy, exit from the 
            *  sent CR_Or_CLR state.
            */

            if (g_v8bis_flags.dsp_tx_busy)
            {
                break;
            } 

            switch(g_sig_msg)
            {
                /*
                *  If the received message is invalid,send NAK1
                *  and return to initial state
                */

                case INVALID_MESSAGE:

                Send_Msg_Nak1();

                break;

                /* 
                *  If CLR is received send CL_MS (trans #3,9,11)  
                */

                case CLR:

                /*
                *  Call the module to select capabilities.
                */

                Mode_Select();

                /*
                *  If the message validity flag is not set,
                *  send NAK1 message.
                */  

                if (!g_v8bis_flags.message_validity)
                {
                    Send_Msg_Nak1();
                }
                else
                {

                    /*
                    *  Set the flag to indicate that message CL_MS is to be
                    *  generated.
                    */

                    g_v8bis_flags.generate_cl_ms = TRUE; 

                    /*
                    *  Copy the local capability octets to transmission 
                    *  buffer.
                    */
                
                    for (i = 0; i <= g_local_cap[0]; i++)
                    {
                        g_msg_tx_buffer[i] = g_local_cap[i];
                    }

                    /*
                    *  Send a command to DSP core module to transmit 
                    *  message.
                    */

                    g_command_type = SEND_MESSAGE_COMMAND;
                    Dsp_Core_Control();

                    /*
                    *  Go to SENT_MS_STATE and initialize the 
                    *  five seconds counter.
                    */

                    g_v8bis_state = SENT_MS_STATE;
                    v_timeout_counter = FIVE_SECONDS_COUNT;
                    g_v8bis_flags.five_seconds_counter = 0;
                    g_command_type = ENABLE_MSG_RECEPTION_COMMAND;
                }

                break;

                /*
                *  If CL is received, send MS (trans #2,6,10,12)
                */ 

                case CL:    

                g_v8bis_flags.send_nak1 = TRUE;
                Send_Msg_Ms();

                break;

                /*
                *  If CRd is received.
                */ 

                case CRd:
 
                /*
                *  If local wants to know remote capabilities send 
                *  CLR (trans #13), else send CL (trans #12)
                */

                if (g_host_config.local_wants_rcap)
                {
                    Send_Msg_Clr();
                    g_v8bis_flags.cl_ms_expected = TRUE; 
                }

                else
                {
                    Send_Msg_Cl();
                }

                break;

                case NAK1:

                Goto_Initial_State();
                Tx_Host_Message_Error(RECEIVED_NAK1_MSG);

                break;

                default:

                break;
            }

            /*
            *  Clear the global variable g_sig_msg.
            */

            g_sig_msg = NIL;

            break;

            case SENT_NAK_STATE:

            if (!g_v8bis_flags.dsp_tx_busy)
            {
                Goto_Initial_State();
                Tx_Host_Message_Error(s_error_id);
                s_error_id = NIL_ID;
            }

            break;


            case MSMODE_STATE:

            /*
            * If start modem handshake flag is reset, Call the 
            * module to detect modem handshake signal.
            */

            if (!g_v8bis_flags.start_modem_handshake)
            {
                Detect_Modem_Hs_Signal();
            }

            if (!g_v8bis_flags.dsp_tx_busy)
            {
                /*
                *  Send a message to host to indicate that the V.8 bis 
                *  transaction is success.
                */

                if (g_v8bis_flags.five_seconds_counter)
                {
                    Tx_Host_Message_V8bis_Success();
                    v_v8bis_start_or_stop = FALSE;
                }
            }

            

            break;

            default:

            break;

        
        } /* End of SWITCH <v8bis state> */

        Dsp_Core_Control();
        Rx_Dsp_Response();  

        return;
}



/***************************************************************************
*
*   FUNCTION NAME   -   Send_Msg_clr
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_local_cap[] 
*   REFERENCED          
*                   
*   GLOBALS         -   g_msg_tx_buffer[]
*   MODIFIED            g_v8bis_state
*                       g_command_type
*                       v_timeout_counter
*                      
*   FUNCTIONS       -   Dsp_Core_Control 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It sends the command to DSP core module to transmit message. It changes 
*   V.8 bis state SENT CLR STATE. It sends the command to DSP core module to 
*   detect message.
*
***************************************************************************/

void Send_Msg_Clr()
{
    W16 i;

    /*
    *  Copy the local capability octets to transmission buffer.
    */

    for (i = 0; i <= g_local_cap[0]; i++)
    {
        g_msg_tx_buffer[i] = g_local_cap[i];
    }

    /*
    *  Set message type and revision number.
    */

    g_msg_tx_buffer[1] = MSG_TYPE_CLR | 
                         (g_host_config.revision_number << 4);

    /*
    *  Send a command to DSP core module to transmit message.
    */

    g_command_type = SEND_MESSAGE_COMMAND;
    Dsp_Core_Control();

    /*
    *  Go to SENT_CLR_STATE and initialize the five seconds 
    *  counter.
    */

    g_v8bis_state = SENT_CLR_STATE;
    v_timeout_counter = FIVE_SECONDS_COUNT;
    g_v8bis_flags.five_seconds_counter = 0;

    /*
    *  Send a command to DSP core module to look for messages.
    */

    g_command_type = ENABLE_MSG_RECEPTION_COMMAND;

    return; 
}


/***************************************************************************
*
*   FUNCTION NAME   -   Send_Msg_cl
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_local_cap[] 
*   REFERENCED          
*                   
*   GLOBALS         -   g_msg_tx_buffer[]
*   MODIFIED            g_v8bis_state
*                       g_command_type
*                       v_timeout_counter
*                      
*   FUNCTIONS       -   Dsp_Core_Control 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It sends the command to DSP core module to transmit message. It changes 
*   V.8 bis state SENT CL STATE. It sends the command to DSP core module to 
*   detect message.
*
***************************************************************************/


void Send_Msg_Cl()
{
    W16 i;

    /*
    *  Copy the local capability octets to transmission buffer.
    */

    for (i = 0; i <= g_local_cap[0]; i++)
    {
        g_msg_tx_buffer[i] = g_local_cap[i];
    }

    /*
    *  Send a command to DSP core module to transmit message.
    */

    g_command_type = SEND_MESSAGE_COMMAND;
    Dsp_Core_Control();

    /*
    *  Go to SENT_CL_STATE and initialize the five seconds 
    *  counter.
    */

    g_v8bis_state = SENT_CL_STATE;
    v_timeout_counter = FIVE_SECONDS_COUNT;
    g_v8bis_flags.five_seconds_counter = 0;

    /*
    *  Send a command to DSP core module to detect message.
    */

    g_command_type = ENABLE_MSG_RECEPTION_COMMAND;

    return;
}



/***************************************************************************
*
*   FUNCTION NAME   -   Send_Msg_Ms
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_ms_buffer[] 
*   REFERENCED          
*                   
*   GLOBALS         -   g_msg_tx_buffer[]
*   MODIFIED            g_v8bis_state
*                       g_command_type
*                       v_timeout_counter
*                      
*   FUNCTIONS       -   Mode_Select 
*   CALLED              Dsp_Core_Control 
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It calls the module to select capabilities. It sends the command to DSP 
*   core module to transmit message. It changes V.8 bis state SENT_MS_STATE. 
*   It sends the command to DSP core module to detect message.
*
***************************************************************************/


void Send_Msg_Ms()
{
    W16 i;

    /*
    *  Call the module to form MS message.
    */

    Mode_Select();

    /*
    *  If the message_validity flag is set.
    */  

    if (g_v8bis_flags.message_validity)
    {
        /*
        *  Copy MS octets to transmission buffer.
        */

        for (i = 0; i <= g_ms_buffer[0]; i++)
        {
            g_msg_tx_buffer[i] = g_ms_buffer[i];
        }

        /*
        *  Send a command to DSP core module to transmit message.
        */

        g_command_type = SEND_MESSAGE_COMMAND;
        Dsp_Core_Control();

        /*
        *  Go to SENT_MS_STATE and initialize the five seconds counter. 
        */  

        g_v8bis_state = SENT_MS_STATE;
        v_timeout_counter = FIVE_SECONDS_COUNT;
        g_v8bis_flags.five_seconds_counter = 0;

        /*
        *  Send a command to DSP core module to detect message.
        */

        g_command_type = ENABLE_MSG_RECEPTION_COMMAND;

    }

    else
    {
        /*
        *  if send_nak1 flag is set, send NAK1 message.
        *  else send a error message to host and go to
        *  initial v8 bis state.
        */

        if (g_v8bis_flags.send_nak1)
        {
            g_v8bis_flags.send_nak1 = FALSE;
            Send_Msg_Nak1();
        }
        else
        {
            Goto_Initial_State();
            Tx_Host_Message_Error(INVALID_MSG_FORMAT);
        }
    }

    return;
}


/***************************************************************************
*
*   FUNCTION NAME   -   Send_Msg_Nak1 
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   None 
*   REFERENCED      
*                   
*   GLOBALS         -   g_msg_tx_buffer[]
*   MODIFIED            g_command_type
*                       g_command_data
*                       g_v8bis_state
*                      
*   FUNCTIONS       -   Dsp_Core_Control 
*   CALLED              Tx_Host_Message_Error
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*   
*   It sends the command to DSP core module to transmit message NAK1. It 
*   sends error message to host. It returns to initial state and sends the
*   command to DSP core module to detect initiating signals.
*
***************************************************************************/


void Send_Msg_Nak1()
{
    /*
    *  Format the message NAK1. The first element of the array contains
    *  count of message octets.
    */
     
    g_msg_tx_buffer[0] = 1; 
    g_msg_tx_buffer[1] = MSG_TYPE_NAK1 | 
                         (g_host_config.revision_number << 4);

    /*
    *  Send a command to DSP core module to transmit message.
    */

    g_command_type = SEND_MESSAGE_COMMAND; 

    /*
    * Change the state to SENT NAK STATE
    */

    g_v8bis_state = SENT_NAK_STATE;
   
    /*
    *  Send a error message to host
    */
      
    s_error_id = RECEIVED_INVALID_MSG;
    
    return; 
}



/***************************************************************************
*
*   FUNCTION NAME   -   Send_Msg_Ack1_Or_Nak3 
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_ms_buffer[]    
*   REFERENCED          
*                   
*   GLOBALS         -   g_msg_tx_buffer[] 
*   MODIFIED            g_v8bis_state
*                       g_command_type
*                       g_command_data
*                      
*   FUNCTIONS       -   Check_Mode  
*   CALLED              Dsp_Core_Control  
*                       Tx_Host_Message_Error 
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It calls the module to check whether local supports the capabilities 
*   selected by remote station. If local supports, it sends the command to 
*   DSP core module to transmit message ACk1, otherwise it sends the command
*   to transmit message NAK3.
*
***************************************************************************/

void Send_Msg_Ack1_Or_Nak3()
{
    BOOLEAN flag;

    /*
    *  Call the module to check whether local supports capabilities
    *  selected by remote station.
    */

    flag = Check_Mode();

    /*
    *  If local supports capabilities.
    */

    if (flag == TRUE)
    {

        /*
        *  If TRANSMIT ACK1 parameter of identification field NPAR1 octet
        *  is set, send a command to DSP core module to transmit message 
        *  ACK1.
        *  Else go to MS MODE STATE.
        */

        if (g_ms_buffer[ID_NPAR1_INDEX] & TRANSMIT_ACK1)
        {
            /*
            *  Format the message ACK1
            */

            g_msg_tx_buffer[0] = 1;
            g_msg_tx_buffer[1] = MSG_TYPE_ACK1 | 
                                 (g_host_config.revision_number << 4);

            g_command_type = SEND_MESSAGE_COMMAND;
        }  

        g_v8bis_flags.start_modem_handshake = 1;
        g_v8bis_state = MSMODE_STATE;        
        v_timeout_counter = TWELVE_BAUD_COUNT;
                     
    }

    /*
    *  If local does not support the capabilities, send NAK3.
    */

    else
    {
        if (g_v8bis_flags.message_validity)
        {

            /*
            *  Format the message NAK3
            */

            g_msg_tx_buffer[0] = 1;
            g_msg_tx_buffer[1] = MSG_TYPE_NAK3 | 
                                 (g_host_config.revision_number << 4);

           /*
           *  Send a command to DSP core module to transmit message.
           */

           g_command_type = SEND_MESSAGE_COMMAND;

           g_v8bis_state = SENT_NAK_STATE;

           /*
           *  Send a error message to host, indicating local does not
           *  support capabilities selected by remote station.
           */

           s_error_id = MODE_NOT_SUPPORTED;
        }

        /*
        *  If the message validity flag is not set, send a NAK1 msg.
        */

        else
        {
            Send_Msg_Nak1();
        }
    }

    return;
}

/***************************************************************************
*
*   FUNCTION NAME   -   Send_Sig_Crd 
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   None 
*   REFERENCED          
*                   
*   GLOBALS         -   g_v8bis_state 
*   MODIFIED            g_command_type
*                       g_command_data
*                       v_timeout_counter
*                      
*   FUNCTIONS       -   Dsp_Core_Control 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It sends the command to DSP core module to transmit signal CRd and also
*   sends the command to DSP core module to detect message. The V8 bis state 
*   is changed to SENT_CR_OR_CLR_STATE.
*
***************************************************************************/

void Send_Sig_Crd()
{
    /*
    *  Send a command to DSP core module to transmit signal CRd.
    */

    g_command_type = SEND_SIGNAL_COMMAND; 
    g_command_data = CRd;  
    Dsp_Core_Control();

    /*
    *  Go to SENT_CR_OR_CLR_STATE and initialize the five seconds 
    *  counter.
    */

    g_v8bis_state = SENT_CR_OR_CLR_STATE;
    v_timeout_counter = FIVE_SECONDS_COUNT;
    g_v8bis_flags.five_seconds_counter = 0;

    /*
    *  Send a command to DSP core module to detect message.
    */

    g_command_type = ENABLE_MSG_RECEPTION_COMMAND; 

    return;
}


/***************************************************************************
*
*   FUNCTION NAME   -   Check_Timeout_Counter 
*
*   INPUT           -   None
*
*   OUTPUT          -   None 
*
*   GLOBALS         -   v_timeout_counter 
*   REFERENCED          
*                   
*   GLOBALS         -   None 
*   MODIFIED            
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
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*  It checks v_timeout_counter, if it is less than or equal to zero, it 
*  returns to initial v8 bis state and looks for initiating signals. It also 
*  sends the error message to host.
*
***************************************************************************/

void Check_Timeout_Counter()
{
    /*
    *  If the counter is expired, return to initial V.8 bis state and send
    *  a command to DSP core module to look for initiating signals. Also
    *  send a error message to host.
    */

    if (g_v8bis_flags.five_seconds_counter)
    {  
        g_v8bis_flags.five_seconds_counter = 0;
        Goto_Initial_State();
        Tx_Host_Message_Error(TIMED_OUT);
    }
                 
    return ;
}    


/***************************************************************************
*
*   FUNCTION NAME   -   Goto_Initial_State 
*
*   INPUT           -   None
*
*   OUTPUT          -   None 
*
*   GLOBALS         -   None 
*   REFERENCED          
*                   
*   GLOBALS         -   g_v8bis_state 
*   MODIFIED            g_command_type
*                       g_v8bis_flags
*                       g_sig_msg
*                       
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
*   06/04/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments  
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It clears the flags. It initializes the v.8 bis state to initial state,
*   and sends the command to Dsp core control module to look for initiating
*   signals.
*
***************************************************************************/

void Goto_Initial_State()
{

    /*
    *  Clear all the flags.
    */
     
     
    asm(move #g_v8bis_flags,r0);
    asm(clr a);
    asm(move a,x:(r0)+);
    asm(move a,x:(r0));
                     

    /*
    *  Clear the received signal or message word.
    */

    g_sig_msg = NIL;

    /*
    *  Go to initial state and look for initiating signals.
    */

    g_v8bis_state = INITIAL_V8BIS_STATE;
    g_command_type = ENABLE_SIG_SEARCH_COMMAND;

    return;
}    

/***************************************************************************
*
*   FUNCTION NAME   -   Detect_Modem_Hs_Signal
*
*   INPUT           -   None
*
*   OUTPUT          -   None 
*
*   GLOBALS         -   g_ms_buffer[] 
*   REFERENCED          
*                   
*   GLOBALS         -   g_v8bis_flags.hs_signal_detected 
*   MODIFIED            
*                       
*                      
*   FUNCTIONS       -   Detect_ShortV8 
*   CALLED              Detect_V8
*                       Detect_V25 
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   28/07/98    0.00        Module Created      B.S Shivashankar
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It calls the module to detect appropriate modem handshake signal. It
*   sets the flag if handshake signal is detected.
*
***************************************************************************/

void Detect_Modem_Hs_Signal()
{
    BOOLEAN flag;

    if (g_ms_buffer[ID_NPAR1_INDEX] & SHORT_V8)
    {
        flag = Detect_ShortV8();
    }
    else if (g_ms_buffer[ID_NPAR1_INDEX] & V8)   
    {
        flag = Detect_V8();
    }
    else
    {
        flag = Detect_V25();
    }
   
    if (flag == TRUE)
    {
        g_v8bis_flags.hs_signal_detected = 1;
    }

    return;
}

/*
*  End of file.
*/

/**************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -  V.8 bis
*
*   FILENAME        -  msg_gen.c 
*
*   COMPILER        -  m568c: tartan compiler SPARC version 1.0
*
*   ORIGINAL AUTHOR -  Minati Ku. Sahoo
*
***************************************************************************
*
*   DESCRIPTION
*
*   This file initializes all the control variables used in message 
*   generation. Calls asm modules for the message generation
*   depending on bit 0/1. 
*
*
*   Function in this file :
*                         Message_Gen_Init
*                         Message_Generation     
*
**************************************************************************/

 /* includes */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/* defines */

#define     MARK_STATE_COUNT      30
#define     MASK_BYTE             0x01 
#define     BIT_STUFF_COUNT       5
 
/*******************************************************************************
*
*   FUNCTION NAME -  Message_Gen_Init
*
*   INPUTS        -  None 
*
*   OUTPUTS       -  None 
*
*   GLOBALS       -  g_v8bis_flags.es_generated
*   REFERENCED       g_msg_tx_buffer[]
*                    g_v8bis_flags.station
*                    
*   GLOBALS       -  g_message_gen_state 
*   MODIFIED         g_msg_tx_buffer[] 
*                    g_v8bis_flags.message_gen_enable
*                    g_v8bis_flags.es_generated
*                    g_flag_gen_counter
*                    g_current_msg_gen_byte
*                    g_codec_tx_buf_ptr
*                    v8_ssi_txctr
*                    g_v8bis_flags.ssi_tx_samples_rqst
*                    
*   FUNCTIONS     -  V21_Mod_Init
*   CALLED        -  Calc_Crc_Ccitt
*                 -  Crc_BitReversed
*                
**************************************************************************
*
*   CHANGE HISTORY
*
*   dd/mm/yy   Code Ver     Description                 Author
*   --------   -------      -----------                 ------
*   22/05/98    0.00        Module created              Minati
*   17/06/1998              Incorporated Review         Minati 
*                           Comments
*   03/07/98    0.10        Ported on to MW             N R Prasad
*
**************************************************************************
*
*   DESCRIPTION
*   
*   This module generates CRC for the message and initializes control 
*   variables for message generation.
*
*
***************************************************************************/
/*
* Static variables
*/

static  W16  s_flag_before_message; 
static  W16  s_mark_duration_counter; 
static  W16  s_current_bit_counter; 
static  W16  s_bit1_consecutive_counter;
static  W16  *s_current_msg_gen_byte_ptr;


void Message_Gen_Init()

{
    
    W16 crc, crc_octet_1, crc_octet_2, fc;

    /* 
    *  Flags for Message_gen_enable is set. 
    */

    g_v8bis_flags.message_gen_enable = TRUE;
   
    /*
    *  The CRC code word is generated using the message octets.
    */

    crc = Calc_Crc_Ccitt(&g_msg_tx_buffer[0]);
    crc = ~crc;
    crc = Crc_BitReversed(crc);
    crc_octet_1 = crc & 0x00ff;
    crc_octet_2 = crc & 0xff00;
    crc_octet_2 = crc_octet_2 >> 8;

    /*
    * Calculated CRC is appended to the original message.
    */ 

    g_msg_tx_buffer[g_msg_tx_buffer[0] + 1] = crc_octet_1;
    g_msg_tx_buffer[g_msg_tx_buffer[0] + 2] = crc_octet_2;
    
    /*
    *  The message length is incremented by 2 to account for the Crc.
    */
    g_msg_tx_buffer[0] += 2;

    /*
    * If ES_GENERATED Flag is set , initialize the #of flag octets reqd
    * before message. Initialize the message generation state to 
    * FLAG_GENERATION STATE. Init current message byte to be generated
    * to the HDLC flag byte. Reset the ES_GENERATED FLAG.The flag to 
    * detect flag sequence before message is set.
    */ 

    if(g_v8bis_flags.es_generated)
    {
        g_v8bis_flags.es_generated = FALSE;
        g_flag_gen_counter = NUM_OF_START_MSG_HDLC_FLAGS;
        g_message_gen_state = FLAG_GENERATION_STATE;
        g_current_msg_gen_byte = HDLC_FLAG;
        s_flag_before_message = TRUE;
    }

    /*
    * Else Message generation state is initialized to MARK_STATE.
    * Initialize the duration counter for mark generation to 30.
    */
    
    else
    {
        g_message_gen_state = MARK_GEN_STATE;
        s_mark_duration_counter = MARK_STATE_COUNT; 
    }

    /*
    * Depending on initiating station or responding station call V21_Mod_Init
    * to initialize all control variables.INIT_FC is the center frequency of
    * initiating station , i.e 1080 Hz and RESP_FC is the center frequency 
    * of responding station , i.e 1750 Hz.
    */ 

    if (g_v8bis_flags.station == INIT_STATION )
    {
        fc = INIT_FC;
    }
    else
    {
        fc = RESP_FC;
    }
    
    V21_Mod_Init(fc);
    
    /*
    * Initialize the codec_tx_rptr & codec_tx_buf_ptr.
    * Init the v8_ssi_txctr to 24 & Init the ssi_tx_samples_rqst to 1. 
    */

    /*
    * Initialize the static variables to zero.
    */
 
    s_current_bit_counter = 0;
    s_bit1_consecutive_counter = 0;
    
    return;
}
 


/**************************************************************************
*
*   FUNCTION NAME -  Message_Generation
*
*   INPUTS        -  None 
*
*   OUTPUTS       -  None
*
*   GLOBALS       -  g_message_gen_state
*   REFERENCED       g_flag_gen_counter
*                    g_msg_tx_buffer
*                    g_ms_buffer
*                    g_v8bis_flags.generate_cl_ms
*
*   GLOBALS       -  g_message_gen_state
*   MODIFIED         g_flag_gen_counter
*                    g_current_msg_gen_byte
*                    g_msg_tx_buffer
*                    g_ms_buffer
*                    g_v8bis_flags.generate_cl_ms
*                    g_v8bis_flags.ack_tx_over
*                    g_v8bis_flags.dsp_tx_busy
*                    g_v8bis_flags.message_gen_enable
*
*   FUNCTIONS     -  V21_Mod
*   CALLED        -  Message_Gen_Init
*
************************************************************************
*
*   CHANGE HISTORY
*
*   dd/mm/yy   Code Ver     Description              Author
*   --------   -------      -----------              ------
*   25/05/98     0.00       Module created           Minati
*   17/06/1998              Incorporated Review      Minati
*                           Comments
*   03/07/2000   0.10       Ported on to MW          N R Prasad
*                           
***********************************************************************
*
*   DESCRIPTION
*   
*   This module generates the message samples to be transmitted for the 
*   duration of one symbol period.
*
*
************************************************************************/

void Message_Generation();    /* Prototype */

void Message_Generation()

{
    W16 bit , i , loop_count; 
    switch (g_message_gen_state)
    {
        case MARK_GEN_STATE :
            
        /*  
        *  If in MARK_GEN_STATE , test for the mark duration counter .
        *  If the duration counter has not expired , V.21 CPFSK Modulation 
        *  is done for the bit 1.Update the duration counter.
        */  
  
        if (s_mark_duration_counter--)
        {
            V21_Mod(1);
        }

        /*
        * If the counter has expired , the #flag octets is initialized to the
        * #needed before the message .Message generation state is changed to 
        * FLAG_GENERATION_STATE.The current byte to be generated is  
        * initialized to HDLC flag byte ,i.e 0x7e. The flag to detect the  
        * flag sequence before message is set.
        */
    
        if (!s_mark_duration_counter)
        {
            g_flag_gen_counter = NUM_OF_START_MSG_HDLC_FLAGS;
            g_message_gen_state = FLAG_GENERATION_STATE;
            g_current_msg_gen_byte = HDLC_FLAG;
            s_flag_before_message = TRUE;
        }
                      
        break;

        case FLAG_GENERATION_STATE:

        /*
        * If 5 cosecutive  data '1's have been sent , send '0' as the 
        * current data bit and break from the Flag gen state.
        */ 
        
        if (s_bit1_consecutive_counter == BIT_STUFF_COUNT)
        {
            V21_Mod(0);
            s_bit1_consecutive_counter = 0;
            break;
        }

        /*
        * Get the bit to be generated . MASK_BYTE is defined as 0x01.
        */ 
    
        bit = g_current_msg_gen_byte & MASK_BYTE;

        /* 
        * Call V.21 Modulation unit to get the transmitted samples.
        */
    
        V21_Mod(bit);

        /*
        * Get the next bit to be modulated at the LSB of the byte.
        */
        g_current_msg_gen_byte = g_current_msg_gen_byte >> 1;

        /*
        * Update the current byte counter.
        */
    
        s_current_bit_counter++;

        /*
        * If all 8 flag bits from the current byte have been generated,
        * Flag counter is decremented.
        */ 
        
        if (s_current_bit_counter == NUM_BITS_PER_OCTET)
        {
            g_flag_gen_counter--;
            s_current_bit_counter = 0;

            /*
            * When the required # of flags have been generated , check
            * whether the flag sequence is before message.
            */
            
            if (!g_flag_gen_counter)
            {
                if (s_flag_before_message)
                {
                    /*
                    * If the flag sequence is before the message,message
                    * generation state is changed to DATA_GEN_STATE. The
                    * next byte to be generated is initialized to first
                    * message byte.
                    */
                 
                    g_message_gen_state = DATA_GEN_STATE;
                    s_current_msg_gen_byte_ptr = &g_msg_tx_buffer[1];
                    g_current_msg_gen_byte = *s_current_msg_gen_byte_ptr++;
                }
                else 
                {
                    /*
                    * If the flag sequence is after the message ,check
                    * for GENERATE_CL_MS flag.If the GENERATE_CL_MS flag is
                    * set , Update the message buffer pointer to point to
                    * MS message , Message_Gen_Init module is called and 
                    * the GENERATE_CL_MS flag is reset.
                    */
                    
                    if (g_v8bis_flags.generate_cl_ms)
                    {
                        loop_count = g_ms_buffer[0];
 
                        for(i = 0 ;i <= loop_count ; i++)
                        {       
                            g_msg_tx_buffer[i] = g_ms_buffer[i];
                        }
                        Message_Gen_Init();
                        g_v8bis_flags.generate_cl_ms = FALSE;
                    }
                    
                    /*
                    * Else reset the message generation flag and reset
                    * the DSP_TX_BUSY flag.
                    */
                    
                    else
                    {
                       g_v8bis_flags.message_gen_enable = FALSE;
                       g_v8bis_flags.dsp_tx_busy = FALSE;
                    }
                }
            }
            /*
            * When the required # of flags have not been generated,
            * next byte to be generated is initialized to HDLC flag.
            */
            
            else
            {
                g_current_msg_gen_byte = HDLC_FLAG;
            }
        }

        break;
    
        case DATA_GEN_STATE :

        /*
        * If 5 cosecutive '1's have been sent , send '0' as the current bit.
        */ 
        
        if (s_bit1_consecutive_counter == BIT_STUFF_COUNT)
        {
            V21_Mod(0);
            s_bit1_consecutive_counter = 0;
        }
            
        /*
        * Else Get the bit to be generated.Get the next bit to be generated 
        * as the LSB of the byte . Call V.21 Modulation unit.
        */

        else
        {
            
            bit = g_current_msg_gen_byte & MASK_BYTE;
            g_current_msg_gen_byte = g_current_msg_gen_byte >> 1;
            V21_Mod(bit);

            /*
            * Increment the current byte counter.
            */
            
            s_current_bit_counter++;

            /*
            * If current bit generated is 1 increment the
            * bit1_consecutive_counter else if bit generated is 0 
            * reset the counter.
            */ 
             
            if (bit == 0x01)
            {
                s_bit1_consecutive_counter++;
            }
            else
            {
                s_bit1_consecutive_counter = 0;
            } 
        }

        /*
        * If all 8 bits from the current byte have been generated ,
        * decrement the no. of message octets by 1.
        */
          
        if (s_current_bit_counter == NUM_BITS_PER_OCTET )
        {
            s_current_bit_counter = 0;
            g_msg_tx_buffer[0]--;

            /*
            * If all message octets have been sent ,message generation
            * state is changed to FLAG_GENERATION_STATE.The flag octets
            * needed after the message is initialized and the current 
            * byte to be generated is initialized to HDLC flag byte.
            */
            
            if (!g_msg_tx_buffer[0])
            {
                g_flag_gen_counter = NUM_OF_END_MSG_HDLC_FLAGS;
                g_message_gen_state = FLAG_GENERATION_STATE;
                g_current_msg_gen_byte = HDLC_FLAG;
                s_flag_before_message = FALSE;
            }

            /*
            * When all message octets have not been sent ,get
            * the next message byte to be sent.
            */
            
            else
            {
                g_current_msg_gen_byte = *s_current_msg_gen_byte_ptr++;
            }
        }

        break;

        default :

        break;

    }
    return;
}
/*
* End of File
*/ 


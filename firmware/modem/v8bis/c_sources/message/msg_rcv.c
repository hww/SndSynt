/************************************************************************
*
*    Motorola India Electronics Ltd. (MIEL).
*
*    PROJECT  ID     -   V.8 bis
*
*    FILENAME        -   msg_rcv.c
*
*    COMPILER        -   m568c: tartan compiler SPARC version 1.0
*
*    ORIGINAL AUTHOR -   G.Prashanth
*
****************************************************************************
*
*    DESCRIPTION 
*
*    This file Initialises the Parameters required for the message
*    reception.Receives the message after detecting the message start.
*    Calls asm modules and verifies the validity of message and delivers
*    the message to the higher level. 
*     
*    Functions in this file:
*                          Msg_Receive_Init
*                          Msg_Receive
*                          Msg_Receive_Ctrl
*                          Rm_Bit_Stuff
*                          End_Of_Message
*************************************************************************/

 /* includes */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/* defines */

#define BIT_STUFF_COUNT            5      /* count for bit stuffing */ 
#define SYMBOL_PER_FRAME           6      /* no.of symbols per frame */
#define RECEIVED_CRC               0x1d0f /*The ret value for crc*/
#define MIN_MESSAGE_OCTET          3      /* minimum no. of mesg octet*/
#define CRC_OCTET                  2      /*The no crc octets returned*/
#define MAX_END_FLAGS              3      /* Max of terminating flags*/
#define MAX_START_FLAGS            5      /* Max of starting flags*/

/***************************************************************************
*
*   FUNCTION NAME   -  Msg_Receive_Init 
*
*   INPUT           -  None  
*                       
*   OUTPUT          -  Initialise variables and buffers. 
*
*   GLOBALS         -   g_v8bis_flags.   
*   REFERENCED          g_message_rx_state.
*                       s_msg_rx_buf_ptr
*                       s_sig_samples_buf_ptr
*                       g_msg_rx_buffer[]
*                       g_sig_samples_buffer[]
*
*   GLOBALS         -   g_v8bis_flags.    
*   MODIFIED            g_message_rx_state. 
*                       s_msg_rx_buf_ptr
*                       s_sig_samples_buf_ptr
*
*   FUNCTIONS       _   V21_RxDemod_Init 
*   CALLED         
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   11:06:98        0.0      Module Created       G.Prashanth
*   03:07:2000      0.1      Ported on to MW      N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*  
*  Initialises the variables required for the message reception.
**********************************************************************/

/*
*  Static variables.
*/  

static W16 s_bit_stuff_counter;
static W16 s_msg_byte;
static W16 s_msg_bit_counter;
static W16 s_v21_rxdemod_byte;
static W16 s_flag_counter;
static W16 s_v21_rxdemod_bit_counter;
static W16 s_symbol_counter;
static W16 *s_msg_rx_buffer_ptr;
static W16 *s_sig_samples_buf_ptr;

void Msg_Receive_Init()
{
   W16 fc, status_reg;
   
   /*
   *    Flags are initialised.
   */
  
   g_v8bis_flags.message_reception_enable = TRUE;
   
   /*
   *    Initialise the buffers and variables needed for v21 
   *    demodulation.Check for the STATION flag and pass the variable
   *    depending on the flag.Initialise the codec receive
   *    buffer pointer.
   */
  
   if (g_v8bis_flags.station == INIT_STATION)
   {  
       fc = RESP_FC;
   }
   else
   {
       fc = INIT_FC;
   }   
   V21_RxDemod_Init(fc);
  
   /*
   *   Initialise the codec ptr to the first location of codec receive
   *   buffer.
   */
   
   g_codec_rx_buf_ptr = &codec_rx_buffer[0];
//   asm("move sr,&",&status_reg);
   asm(move sr,status_reg);
   asm(bfset #$0300,sr);
   asm(nop);  
   asm(nop);  
   codec_rx_wptr = &codec_rx_buffer[0];

   /*
   *   Initialise the receive counter for ISR to number of samples per 
   *   baud and reset the samples ready flag.
   */
   
   v8_ssi_rxctr = SAMPLES_PER_BAUD;
   g_v8bis_flags.ssi_rx_samples_ready = FALSE;
//   asm("move &,sr",status_reg);
   asm(move status_reg,sr);
   asm(nop);  
   asm(nop);  

   /*
   *   If the ES_DETECTED flag is set, means ESi or ESr have been 
   *   detected reset the flag and and start receiveing message bits
   *   by changing the message reception state to FLAG_VERIFY_STATE
   */
   
   if (g_v8bis_flags.es_detected == TRUE)
   {
       g_v8bis_flags.es_detected = FALSE;
       g_message_rx_state = FLAG_VERIFY_STATE;
   }

   /*
   *   Change the message reception state to CAREER_DETECT_STATE 
   */
   
   else
   {  
       g_message_rx_state = CARRIER_DETECT_STATE;
   }   

   /*
   *   Initialise the pointer for message buffer and samples buffer.
   */
   
   s_msg_rx_buffer_ptr = &g_msg_rx_buffer[1];
   s_sig_samples_buf_ptr = &g_sig_samples_buffer[0];
   
   /*
   *   Initialise all the static variables to zero.
   */
       
   s_symbol_counter = 0;
   s_flag_counter = 0;
   s_v21_rxdemod_bit_counter = 0;       
   s_msg_byte = 0;
   s_v21_rxdemod_byte = 0;
   s_bit_stuff_counter = 0;
   s_msg_bit_counter = 0;
}

/***************************************************************************
*
*   FUNCTION NAME   -  Msg_Receive 
*
*   INPUT           -  None. 
*                       
*   OUTPUT          -  None. 
*
*
*   GLOBALS         -  g_v21_rx_decision_length    
*   REFERENCED         g_v21_rxdemod_bits
*                      
* 
*   GLOBALS         -  g_V21_rxdemod_bits 
*   MODIFIED             
*
*   FUNCTIONS       _  Msg_Receive_Ctrl() 
*   CALLED              
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   11:06:98        0.0      Module Created       G.Prashanth
*   03:07:2000      0.1      Ported on to MW      N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
* 
*   Receives the message after detecting the message start.Depending 
*   on the length of the received bits it calls Msg_Receive_Ctrl  
*   function for reception of message bytes.
**********************************************************************/
        
void Msg_Receive()
{
   volatile W16 temp_bit;
   /*
   *   Call V21_Rxctrl statemachine to check for the CDBIT flag
   *   and received bits.
   */
   
   V21_Rxctrl();
    
   /*
   *   If the decision length of demod bits equals 2 extract the 
   *   individual bits and call Msg_Receive_Ctrl for reception 
   *   of bits.
   */
   
   if (g_v21_rx_decision_length == 2)
   {
       /*
       *   Extract the first bit.
       */
     
       temp_bit = g_v21_rxdemod_bits;
       g_v21_rxdemod_bits = g_v21_rxdemod_bits >> 1;

       /*
       *   Shift the each bit by 8 so that the first bit becomes the
       *   LSB and 8th bit becomes MSB in an octet.
       */
       
       g_v21_rxdemod_bits <<= NUM_BITS_PER_OCTET - 1;
       Msg_Receive_Ctrl();

       /*
       *   Recover the second bit.
       */
       
       g_v21_rxdemod_bits = 0x0001 & temp_bit;
   }
   
   /*
   *   If not equal to 2 call Msg_Receive_Ctrl 
   */

   g_v21_rxdemod_bits <<= NUM_BITS_PER_OCTET - 1;
   Msg_Receive_Ctrl();
}  

/***************************************************************************
*
*   FUNCTION NAME   -  Msg_Receive_Ctrl 
*
*   INPUT           -  None. 
*                       
*   OUTPUT          -  None. 
*
*
*   GLOBALS         -  g_msg_rx_buffer[] 
*   REFERENCED         g_sig_samples_buffer[]
*                      g_v8bis_flags
*                      g_message_rx_state
*                      g_single_tone_detected
*                      g_current_decision
*                      
* 
*   GLOBALS         -  g_v8bis_flags  
*   MODIFIED           g_sig_samples_buffer[]  
*                      g_message_rx_state
*                      s_v21_rxdemod_byte
*                      s_msg_rx_buf_ptr;
*                      s_bit_stuff_counter;
*                      s_msg_byte;
*                      s_msg_bit_counter;
*                      s_flag_counter;
*                      s_v21_rxdemod_bit_counter;
*
*   FUNCTIONS       _  Msg_Receive_Init() 
*   CALLED             Stf_Det_Init()
*                      Stf_Det()
*                      Rm_Bit_Stuff()
*                      End_Of_Message()
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   11:06:98        0.0      Module Created       G.Prashanth
*   03:07:2000      0.1      Ported on to MW      N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
* 
*   Receives the message after detecting the message start.Verifies the 
*   validity of a message and delivers the message to the higher layer.
*   
******************************************************************************/ 

void Msg_Receive_Ctrl()
{

   W16 *temp_ptr;
   W16 i;
  
   /*
   *   Check for the message reception state.
   */
 
   switch(g_message_rx_state)
   {  
       /*
       *   If it is CARRIER_DETECT_STATE find the carrier energy
       *   and set the flag.
       */
     
       case CARRIER_DETECT_STATE :  
       
       /*
       *   if career is detected change the state to MARK_DETECT_STATE,
       */
                
       if (g_v8bis_flags.cdbit)
       {
           g_message_rx_state = MARK_DETECT_STATE;
       }
       
       /*
       *   End of CARRIER_DETECT_STATE.
       */
       
       break;

       /*
       *   If it is in MARK_DETECT_STATE check for the carrier detection
       */

       case MARK_DETECT_STATE :
                
       /*
       *   if career detection is negative (if CDBIT flag is not set)
       *   initialise the variables for message reception by calling
       *   Msg_Receive_Init
       */ 
        
       if (!g_v8bis_flags.cdbit)
       { 
           Msg_Receive_Init();
       }
       else
       {   /*
           *   Store the collected samples in the signal buffer.
           *   for 6 symbols (20ms at 300 baud) else exit.
           */
         
           if (s_symbol_counter != SYMBOL_PER_FRAME)
           {   
               temp_ptr = g_samples_buf_ptr; 
               for (i = 0;i < SAMPLES_PER_BAUD; i++)
               { 
                   *s_sig_samples_buf_ptr++ = *temp_ptr++;  
               }   
               s_symbol_counter++;
           }

           /*
           *   If the six symbols have been collected call single
           *   tone detection. 
           */

           else
           {
               g_samples_buf_ptr = &g_sig_samples_buffer[0];
               Stf_Det_Init();
               Stf_Det();

               /*
               *   Get the type of single tone detected and if it is
               *   Esi or Esr and decision is true change the messgae
               *   state to FLAG_VERIFY_STATE else to CARRIER_DETECT
               *   _STATE by calling Msg_Receive_Init 
               */
           
               g_single_tone_detected += SIGNAL_OFFSET;
               if ((g_current_decision == TRUE) && 
                   (((g_single_tone_detected == ESi) && 
                    (g_v8bis_flags.station == RESP_STATION )) ||
                    ((g_single_tone_detected == ESr) &&
                     (g_v8bis_flags.station == INIT_STATION))))
               {
                   g_message_rx_state = FLAG_VERIFY_STATE;
               }
               else
               {
                   Msg_Receive_Init();           
               }
           }          
       }                             /* End of loop for FLAG=TRUE */    

       /*
       *   End of MARK_DETECT_STATE.
       */
       
       break;
       
       /*
       *   Check for FLAG_VERIFY_STATE
       */

       case FLAG_VERIFY_STATE :
       
       /*
       *   If CDBIT flag is negative check for the previous signal
       *   received.
       */

       if (!g_v8bis_flags.cdbit)
       {
         
           /*
           *   Check if signal received is Esi,if yes call Msg_
           *   Receive_Init,and exit.
           */
           
           if(g_single_tone_detected == ESi)  
           {
               Msg_Receive_Init();
           }

           /*
           *   Reset the message reception flag,and set message received
           *   flag to indicate that the carrier dropped in the middle
           *   of the message.
           */
           
           else
           {
               g_v8bis_flags.message_reception_enable = FALSE;
               g_v8bis_flags.message_received = TRUE;
               g_v8bis_flags.message_validity = FALSE;
           }    
       }
       
       else
       { 
         
           /*
           *   Put the received bit in a buffer if the decision length
           *   is not equal to zero.
           */
          
           if (g_v21_rx_decision_length)  
           {
               s_v21_rxdemod_byte >>= 1;
               s_v21_rxdemod_byte |= g_v21_rxdemod_bits;
               s_v21_rxdemod_bit_counter++;
               if (s_flag_counter < 2)
               {
                 
                   /*
                   *   If the number of received bits forms an octet
                   *   check for the HDLC flag and reset the counter.
                   */   
          
                   if ( s_v21_rxdemod_bit_counter == NUM_BITS_PER_OCTET)
                   {
                       s_v21_rxdemod_bit_counter = 0;

                       /*
                       *   Check for the HDLC flag.If the received bits 
                       *   constitute a flag increment the counter and 
                       *   set the received byte to 0x00ff.
                       */
                       
                       if (s_v21_rxdemod_byte == HDLC_FLAG) 
                       {
                           s_flag_counter++;
                           s_v21_rxdemod_byte = 0x00ff;
                       }

                       /*
                       *   If not an HDLC flag indicate the bit receiv
                       *   ed are incorrect and reset the 
                       *   RECEPTION_ENABLE flag.
                       */
                       
                       else
                       {
                           g_v8bis_flags.message_reception_enable = FALSE;
                           g_v8bis_flags.message_received = TRUE;
                           g_v8bis_flags.message_validity = FALSE;
                       } 
                   }    
               }
               
              /*
              *   Search for the Message octet.
              */
           
               else 
               {
                   /*
                   *   If the received bits forms an octet check for
                   *   HDLC flag and reset the counter.
                   */   

                   if (s_v21_rxdemod_bit_counter == NUM_BITS_PER_OCTET)
                   {
                       s_v21_rxdemod_bit_counter = 0;

                       /*
                       *   Check for the HDLC flag.If the received bits 
                       *   constitute a flag discard the octet by  
                       *   resetting the counters.
                       */
                       
                       if (s_v21_rxdemod_byte == HDLC_FLAG)
                       {  
                           s_v21_rxdemod_byte = 0x00ff;
                           s_flag_counter++;
                           s_msg_bit_counter = -1;
                       }

                       /*
                       *   If not an HDLC flag means the received byte 
                       *   forms an octet,so change the state to 
                       *   DATA_STATE.
                       */
                       
                       else
                       {
                           g_message_rx_state = DATA_STATE;
                           g_msg_rx_buffer[0] = 0;
                       }           
                       
                   }
                   
                   /*
                   *   Call Rm_Bit_Stuff to store the received bits 
                   *   in the message buffer.
                   */

                   Rm_Bit_Stuff();

               }                      /* End of ELSE loop */
           }
           
          /*
           *   If number of flag counter exceeds 5 octets it is assumed
           *   that no message symbol will be there so reset the
           *   RECEPTION_ENABLE flag and VALIDITY flag.
           */
               
           if (s_flag_counter > MAX_START_FLAGS)
           {
               g_v8bis_flags.message_reception_enable = FALSE;
               g_v8bis_flags.message_received = TRUE;
               g_v8bis_flags.message_validity = FALSE;
           }
       }                       /* End of loop if FLAG = TRUE */ 
       /*
       *   End of FLAG_VERIFY_STATE.
       */
           
       break;
    
       /*
       *   Check if it is in DATA_STATE.
       */
    
       case DATA_STATE :
    
       /*
       *   Check for the validity of the flag if it is FALSE
       *   reset the message enable flag and set messge received flag
       *   to indicate that carrier dropped in the middle of the
       *   message,and reset the MESSGE_VALIDITY flag.
       */
    
       if (!g_v8bis_flags.cdbit)
       {
           g_v8bis_flags.message_reception_enable = FALSE;
           g_v8bis_flags.message_received = TRUE;
           g_v8bis_flags.message_validity = FALSE;
       }
    
       /*
       *   Put the received bit in a buffer if the decision length
       *   is not equal to zero.
       */
       
       else if( g_v21_rx_decision_length)
       {
           
           /*
           *   Recieve the bit and store it in a message buffer 
           *   until a terminating flag octet is received.
           */
         
           s_v21_rxdemod_byte >>= 1;
           s_v21_rxdemod_byte |= g_v21_rxdemod_bits;

           /*
           *   If the last octet constitutes a HDLC flag change the
           *   state to END_FLAG_STATE and reset the s_v21_rxdemod_byte
           *   to 0xff and intialise the flag counter to 1 indicating 
           *   one flag is received.
           */
           
           if (s_v21_rxdemod_byte == HDLC_FLAG)  
           {
               g_message_rx_state = END_FLAG_STATE;
               s_v21_rxdemod_byte = 0x00ff;
               s_flag_counter = 1;
               s_v21_rxdemod_bit_counter = 0;
           }

           /*
           *   Store the bit in a buffer and check for stuffed bit
           */

           else
           {
               Rm_Bit_Stuff();
           }
       }           
       /*
       *   End of DATA_STATE.
       */   
   
       break;
    
       /*
       *   Check if it is in END_FLAG_STATE.
       */
    
       case END_FLAG_STATE :
      
       /*
       *   If the CDBIT flag is false the # of flag received is
       *   equal to 3 call End_Of_Mesaage .
       */
       
       if (g_v8bis_flags.cdbit == FALSE)  
       {
           g_v8bis_flags.message_reception_enable = FALSE;
           End_Of_Message();     
       }
       
       /*
       *   Check For the HDLC flag if decision length is greate than 
       *   zero.
       */
       
       if (g_v21_rx_decision_length) 
       {
           /*
           *   Recieve the bit and store it in a message buffer 
           *   until a terminating flag octet is received.
           */
         
           s_v21_rxdemod_byte >>= 1;
           s_v21_rxdemod_byte |= g_v21_rxdemod_bits;
           s_v21_rxdemod_bit_counter++; 

           /*
           *   If the last octet constitutes a HDLC flag increment 
           *   counter of number of end of flags detected and reset
           *   the flag to 0xff. 
           */
          
           if (s_v21_rxdemod_bit_counter == NUM_BITS_PER_OCTET)
           {
               if (s_v21_rxdemod_byte == HDLC_FLAG)  
               {
                   s_v21_rxdemod_byte = 0x00ff;
                   s_flag_counter++;
                   s_v21_rxdemod_bit_counter = 0;
               }

               /*
               *   If the # of bits received equals 8 callEnd_Of_Message
               */
           
               else 
               {
                   g_v8bis_flags.message_reception_enable = FALSE;
                   End_Of_Message();
               } 
           }    
       }        

       /*
       *   If the flag counter  is greater than 3 declare that invalid 
       *   message is received.
       */
       
       if (s_flag_counter > MAX_END_FLAGS)  
       {
           g_v8bis_flags.message_reception_enable = FALSE;
           g_v8bis_flags.message_received = TRUE;
           g_v8bis_flags.message_validity = FALSE;
       }
         
       /*
       *   End of END_FLAG_STATE.
       */  
      
       break;
       
       /*
       *   If any default just break from the loop.
       */

       default :
       break;
     
   }                       /* End of switch(g_message_ex_state) loop.*/
}                          /* End of main loop */      
/***************************************************************************
*
*   FUNCTION NAME   -   Rm_Bit_Stuff 
*
*   INPUT           -   None 
*                     
*                       
*   OUTPUT          -   None
*
*   GLOBALS         -   g_msg_rx_buffer[] 
*   REFERENCED          g_v21_rxdemod_bits
*                       s_bit_stuff_counter
*                       s_msg_byte
*                       s_msg_rx_buffer_ptr
*                       s_msg_bit_counter
*   
*   GLOBALS         -   g_msg_rx_buffer[]
*   MODIFIED            s_msg_byte 
*                       s_bit_stuff_counter
*                       s_msg_rx_buffer_ptr
*                       s_msg_bit_counter
*
*   FUNCTIONS       _ 
*   CALLED         
*
*********************************************************************
*   CHANGE HISTORy
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   11:06:98        0.0      Module Created       G.Prashanth
*   03:07:2000      0.1      Ported on to MW      N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*  
*    Removes the stuffed bit from message octet if there are any and 
*    updates the bit_stuff_counter,store the message octet in to message
*    buffer if it constitutes an octet.
*    
**********************************************************************/
void Rm_Bit_Stuff()
{ 
   /*
   *   If the bit_stuff_count is equal to 5 and the next received bit 
   *   is 0 ,reset the count and discard the received bit.
   */
  
   if ((s_bit_stuff_counter == 5) && (g_v21_rxdemod_bits == 0))
   {
       s_bit_stuff_counter = 0;
   }
   else
   {
       /*
       *   Icrement the bit_stuff_count if the received bit is 1 else
       *   reset it to zero.
       */
       
       if (g_v21_rxdemod_bits != 0)
       {
           s_bit_stuff_counter++;
       }
       else
       {
           s_bit_stuff_counter = 0;
       }
       
       /*
       *   Store the received bit in the buffer by shifting it by one.
       */
    
       s_msg_byte >>= 1;
       s_msg_byte |= g_v21_rxdemod_bits;
       

       /*
       *   Increment the message bit counter which indicates the no
       *   of message bits received without stuffed bit.
       */
       
       s_msg_bit_counter++;

       /*
       *   If the number of bits received forms an octet store
       *   the byte in g_msg_rx_buffer for which g_msg_rx_buf_ptr is
       *   a pointer to first location,Increment the count of no of
       *   message bytes received and store it in first location of
       *   g_msg_rx_buffer, flush the message bit counter.
       */
       
       if(s_msg_bit_counter == NUM_BITS_PER_OCTET)
       {
           s_msg_bit_counter = 0;
           *s_msg_rx_buffer_ptr++ = s_msg_byte;
           g_msg_rx_buffer[0]++;
       } 
   }
}     
/***************************************************************************
*
*   FUNCTION NAME   -   End_Of_Message 
*
*   INPUT           -    None
*                       
*   OUTPUT          -    None
*
*   GLOBALS         -    g_v8bis_flags 
*   REFERENCED           s_v21_rxdemod_byte
*                        g_msg_rx_buffer
*                        s_msg_bit_counter
*                        s_msg_byte 
*   
*   GLOBALS         -    g_v8bis_flags
*   MODIFIED             s_v21_rxdemod_byte
*                        g_msg_rx_buffer
*                        s_msg_bit_counter
*                        s_msg_byte 
*
*   FUNCTIONS       _    Calc_Crc_Ccitt()  
*   CALLED               Message_Receive_Init()
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   11:06:98        0.0      Module Created       G.Prashanth
*   03:07:2000      0.1      Ported on to MW      N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*  The module checks for the end of message if the last 8 received
*  bits constitute a flag,and sets messge received flag and message 
*  validity flag .
*   
****************************************************************************/ 

void End_Of_Message()
{

   /*
   *   Set the MESSAGE_RECIEVED flag to indicate that a message has
   *   been received.
   */
   
   g_v8bis_flags.message_received = TRUE;
   
   /*
   *   If the message bits does not constitute a integral number 
   *   of octets reset the MESSAGE_VALIDITY flag to indicate that
   *   a messge with invalid number of bits received,
   */
   
   if (s_msg_bit_counter != NUM_BITS_PER_OCTET-1)
   {
       g_v8bis_flags.message_validity = FALSE;
   }

   else
   {
       /*
       *   If the message collected is fever than 3 octets reset the 
       *   MESSAGE_VALIDITY flag to indicate that a message with a
       *   invalid number of octets received.
       */
     
       if (g_msg_rx_buffer[0] < MIN_MESSAGE_OCTET)
       {
           g_v8bis_flags.message_validity = FALSE;
       }           

       /*
       *   Compute CRC of the message octets.
       *   If crc_value does not match the two FCS octets at the 
       *   end of the message reset the MESSAGE_VALIDITY flag 
       *   indicating that invalid FCS is received.
       */
       
       else if (RECEIVED_CRC != Calc_Crc_Ccitt(&g_msg_rx_buffer))
       {
           g_v8bis_flags.message_validity = FALSE;
       }

       /*
       *   If the crc_value matches than set the message received flag 
       *   by setting MESSAGE VALIDITY flag to indicate that a
       *   message has been received.
       */
       
       else
       {
           g_v8bis_flags.message_validity = TRUE;
           
           /*
           *   Subtract the count of octets since two CRC octets
           *   have been added.
           */
           
           g_msg_rx_buffer[0] -= CRC_OCTET;  

           /*
           *   If cl_ms_expected flag is set initialise message 
           *   receive variables by calling Msg_Receive_Init and
           *   reset the flag.
           */
           
           if (g_v8bis_flags.cl_ms_expected)
           {
               Msg_Receive_Init();
               g_v8bis_flags.cl_ms_expected = FALSE;
           }
       }                   /* End Of Loop if Crc value matches */ 
   }                       /* End Of Loop if messge constitute an
                              integral number */
   s_msg_bit_counter = 0;
}                          /* End of Function */
       
/*
*  End Of File
*/  

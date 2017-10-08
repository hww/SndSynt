/************************************************************************
*
*    Motorola India Electronics Ltd. (MIEL).
*
*    PROJECT  ID     -   V.8 bis
*
*    FILENAME        -   signal_gen.c
*
*    COMPILER        -   m568c: tartan compiler SPARC version 1.0
*
*    ORIGINAL AUTHOR -   G.Prashanth
*
****************************************************************************
*
*    DESCRIPTION 
*
*    This file initialises the variables used in the signal
*    generate module and sets the flags.Calls asm modules for 
*    the signal generation depending on type of the siganl.
*    
*    Functions in this file:
*                          Signal_Gen_Init
*                          Signal_Gen
* 
*************************************************************************/

 /* includes */

#include "v8bis_defines.h" 
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/* defines */

#define    DUAL_TONE_TIME             20 /* No of frames for DTMF */
#define    SINGLE_TONE_TIME           5  /* No of frames for STF  */
#define    SILENCE_TIME               75 /* No of frames for Silence */
/***************************************************************************
*
*   FUNCTION NAME   -  Signal_Gen_Init
*
*   INPUT           -  None
*
*   OUTPUT          -  None 
*
*   GLOBALS         -  g_dual_offset,
*   REFERENCED         g_single_offset
*                      g_signal_amp,
*                      g_v8bis_flags.station
*                      g_v8bis_flags.signal_gen_enable
*
*   GLOBALS         -  g_dual_offset,
*   MODIFIED           g_single_offset
*                      g_signal_amp
*                      g_v8bis_flags.station
*                      g_v8bis_flags.signal_gen_enable
*
*   FUNCTIONS       _  Dtmf_Init 
*   CALLED
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description       Author
*   ---------     ---------    -------------     -------
*   10:04:98       0.0        Module Created   G.Prashanth
*   03:07:2000     0.1        Ported on to MW  N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*
*    This is the module which initialises the variables for 
*    for signal generation. 
*
**********************************************************************/

void Signal_Gen_Init()
{
    W16 status_reg;

    /*  
    *    Flags for Signal_gen_enable and dual_tone generation are
    *    set.Initialise the variable for the type of signal to be 
    *    genetated.
    */

    g_v8bis_flags.signal_gen_enable = TRUE;
    g_signal_gen_state = DUAL_TONE_GEN_STATE;
     
    if (g_v8bis_flags.station == INIT_STATION)
    {
        g_dual_offset = INIT_OFFSET; 
    }
    else
    {
        g_dual_offset = RESP_OFFSET;
    }

    /*
    *  Initialise the Dual tone duration counter.
    */ 
    
    g_signal_counter = DUAL_TONE_TIME;
 
    /*
    *   Depending on the signal_type get the freqency and 
    *   initialise the single_tone frequency.and initialise
    *   the offset depending on the signal_type. 
    */

    g_single_offset = g_signal_type - SIGNAL_OFFSET;

    /*  
    *   Choose the ampitude depending on the Signal_type and 
    *   Initialise it.
    */

    if (g_signal_type==CRe || g_signal_type==MRe)
    {
        g_signal_amp = AMP_L;
        g_signal_gen_state = SILENCE_GEN_STATE;
        g_v8bis_flags.silence_before_signal = TRUE;
    }
    else
    {
        g_signal_amp = AMP_H; 
    }
    
    /*
    *  Initialise the codec generate pointer and transmit counter 
    *  for ISR to frame length and set the samples request flag
    */

    g_codec_tx_buf_ptr = &codec_tx_buffer[144];
//    asm ("move sr,&",&status_reg);
    asm (move sr,status_reg);
    asm (bfset #$0300,sr);
    asm (nop);
    asm (nop);
    v8_ssi_txctr = 0;
    g_v8bis_flags.ssi_tx_samples_rqst = TRUE;
    codec_tx_rptr = &codec_tx_buffer[0];
//    asm ("move &,sr",status_reg);
    asm (move status_reg,sr);

    /*
    *   Initialse the dual_tone generation variables.
    */
    
    Dtmf_Init();        
    return;
}    
/***************************************************************************
*
*   FUNCTION NAME   -  Signal_Gen
*
*   INPUT           -  None 
*
*   OUTPUT          -  None 
*
*   GLOBALS         -  g_signal_counter,
*   REFERENCE          g_signal_gen_state,
*                      g_v8bis_flags.dsp_tx_busy,
*                      g_v8bis_flags.signal_gen_enable,
*                      g_host_config.echo_suppressor
*                      g_message_gen_state
*                      g_message_gen_byte 
*
*   GLOBALS         -  g_signal_counter,  
*   MODIFIED           g_v8bis_flags.signal_gen_enable,
*                      g_v8bis_flags.dsp_tx_busy 
*
*   FUNCTIONS       _  Dtmf_Buff_Gen,
*   CALLED             Stf_Init
*                      Stf_Buff_Gen
*                      Silence_Gen,
*                      Message_Gen_Init
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description      Author
*   ---------     ---------    -------------    -------
*   10:04:98        0.0       Module Created  G.Prashanth
*   03:07:2000      0.1       Ported on to MW N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*
*   Generates the tones by calling assembly subroutines depending on
*   the signal_type.updates the flags.
*
**********************************************************************/


void Signal_Gen()
{
   /*
   *   Checks for the signal_gen_state flag and calls the 
   *   desired subroutine for the specified counter
   */

   /*
   *   Generate dual_tone if flag is set for DUAL_TONE.
   */
  
   if (g_signal_gen_state == DUAL_TONE_GEN_STATE)
   {
       Dtmf_Buff_Gen();
   } 
      
   /*
   *   Generate sigle tone if flag is set for SINGLE_TONE.
   */

   else if (g_signal_gen_state == SINGLE_TONE_GEN_STATE)
   {
       Stf_Buff_Gen();
   }

   /*
   *   Generate silence if flag is set for silence 
   */    
    
   else if ( g_signal_gen_state == SILENCE_GEN_STATE)
   {
       Silence_Gen();
   }

   /*
   *   Update the tone Generation counter.
   */

   if (--g_signal_counter == 0)
   {
     
       /*
       *   If Dual_tone expired initialise variables
       *   for Single tone.
       */
     
       if (g_signal_gen_state == DUAL_TONE_GEN_STATE)
       {
           g_signal_counter = SINGLE_TONE_TIME;
           g_signal_gen_state = SINGLE_TONE_GEN_STATE;
           
           /*
           *   Initialises variables for single tone.
           */
           
           Stf_Init();
       }

   /*
   *   If Single_tone expired initialise variables for 
   *   Silence tone depending on Signal_type.
   */
 
       else if (g_signal_gen_state == SINGLE_TONE_GEN_STATE)
       {
           if (((g_signal_type == ESi) || (g_signal_type == MRe) 
                || (g_signal_type == CRe)) && 
               (g_host_config.echo_suppressor)) 
           {
               g_signal_counter = SILENCE_TIME;
               g_signal_gen_state = SILENCE_GEN_STATE;
           }
           else
           {
             
               /*
               *   Reset the signal generation flag since signal generation
               *   is over.
               */
             
               g_v8bis_flags.signal_gen_enable = FALSE;
               
               /*
               *   If signal type is Esi or Esr  
               *   call messge gen init. 
               */
              
               if ((g_signal_type == ESi) || (g_signal_type == ESr))
               {
                   g_v8bis_flags.es_generated = TRUE;
                   Message_Gen_Init();
                   g_v8bis_flags.dsp_tx_busy = TRUE;
               }
               else
               {
                   g_v8bis_flags.dsp_tx_busy = FALSE;
               }
            }
       }
       else if (g_signal_gen_state == SILENCE_GEN_STATE)
       { 
           if ((g_signal_type == MRe) || (g_signal_type == CRe))
           {
               if (g_v8bis_flags.silence_before_signal)
               {
                   g_v8bis_flags.silence_before_signal = FALSE;
                   g_signal_gen_state = DUAL_TONE_GEN_STATE; 
                   g_signal_counter = DUAL_TONE_TIME;
               }
               else
               {
                   g_v8bis_flags.signal_gen_enable = FALSE;
                   g_v8bis_flags.dsp_tx_busy = FALSE;
               }
           }

           /*
           *   Reset the signal generation flag and set dsp_tx_busy flag.
           *   call Message_Gen_Init sinse ESi was generated.
           */
           
           else if (g_signal_type == ESi)
           {
               g_v8bis_flags.signal_gen_enable = FALSE;
               Message_Gen_Init();
               g_v8bis_flags.dsp_tx_busy = TRUE;
           }
       }
   }
   return;
}
/*
*   End Of File
*/

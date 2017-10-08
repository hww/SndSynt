/************************************************************************
*
*    Motorola India Electronics Ltd. (MIEL).
*
*    PROJECT  ID     -   V.8 bis
*
*    FILENAME        -   signal_det.c
*
*    COMPILER        -   m568c: tartan compiler SPARC version 1.0
*
*    ORIGINAL AUTHOR -   G.Prashanth
*
****************************************************************************
*
*    DESCRIPTION 
*
*    This file Initialises the Parameters required for the detection.
*    calls the asm modules for detection of signals depending on the 
*    type of the flag,and decides the type of the signal detected.   
*     
*    Functions used in this file:
*                               Signal_Detect_Init
*                               Signal_Detect
*************************************************************************/

 /* includes */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/* defines */

#define      DTMF_FRAME_COUNT           18 /* frame count for DTMF */
#define      STF_FRAME_COUNT            7  /* frame count for STF */
/***************************************************************************
*
*   FUNCTION NAME   -  Signal_Detect_Init
*
*   INPUT           -  None  
*
*   OUTPUT          -  None.
*
*   GLOBALS         -  g_v8bis_flags.signal_detect_enable,
*   REFERENCED         g_current_decision, 
*                      g_signal_det_state.
*
*   GLOBALS         -  g_v8bis_flags 
*   MODIFIED           g_current_decision,  
*                      g_signal_det_state
*
*   FUNCTIONS       _  Dtmf_Det_Init 
*   CALLED         
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description          Author
*   ---------     ---------    -------------        -------
*   17:04:98        0.0        Module Created      G.Prashanth 
*   03:07:2000      0.1        Ported on to MW     N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*
*     Initialise the varibles for the tone detection.  
*
**********************************************************************/
/*
*   Static variables
*/
 
static W16 s_no_of_frames_processed;
static W16 s_previous_decision;

void Signal_Detect_Init()
{
   W16 signal_type,status_reg ;           
  
   /*
   *   Flags are initialised
   */
  
   g_v8bis_flags.signal_detect_enable = TRUE;
   g_signal_det_state = DUAL_TONE_DETECT_STATE;
        
   /*
   *   Initialisation of Modified Goertzel(MG) coefficients
   *   for the detection of correct dual_tone pair depending
   *   on initiating or responding tone.
   */

   if (g_v8bis_flags.station == INIT_STATION)
   {
       signal_type = RESP_OFFSET;
   }
   else
   {
       signal_type = INIT_OFFSET;
   }   
   
   /*
   *   Initialise the codec receive pointer and recive counter for
   *   ISR to the frame length ,reset the samples ready flag.
   */
 
   g_codec_rx_buf_ptr = &codec_rx_buffer[0];
//   asm ("move sr,&",&status_reg);
   asm (move sr,status_reg);
   asm (bfset #$0300,sr);
   asm (nop);
   asm (nop);
   v8_ssi_rxctr = SAMPLES_PER_FRAME;
   g_v8bis_flags.ssi_rx_samples_ready = FALSE;
   codec_rx_wptr = &codec_rx_buffer[0];
//   asm ("move &,sr",status_reg);
   asm (move status_reg,sr);
   asm (nop);
   asm (nop);
   
   /*
   *   Initialisations for the decision to FALSE ,and call Dtmf_Det_Init
   */
   
   g_current_decision = FALSE;

   Dtmf_Det_Init(signal_type);

   /*
   *   Initialise the static variables to zero.
   */

   s_no_of_frames_processed = 0;
   s_previous_decision = 0;
    
   return;
}
              
/***************************************************************************
*
*   FUNCTION NAME   -  Signal_Detect
*
*   INPUT           -  None 
*
*   OUTPUT          -  None 
*
*   GLOBALS         -  g_v8bis_flags.signal_detected,
*   REFERENCED         g_v8bis_flags.signal_detect_enable, 
*                      g_signal_det_state,
*                      g_current_decision
*                      g_single_tone_detected
*                      s_no_of_frames_processed
*                      s_previous_decision
*
*   GLOBALS         -  g_signal_det_state    
*   MODIFIED           g_current_decision
*                      g_single_tone_detected
*                      g_v8bis_flags.signal_detected,
*                      g_v8bis_flags.signal_detect_enable
*                      s_no_of_frames_processed
*                      s_previous_decision
*
*   FUNCTIONS       _  Dtmf_Det 
*   CALLED             Stf_Det 
*                      Stf_Det_Init     
*                      Msg_Receive_Init. 
*
*********************************************************************
*   CHANGE HISTORY
*
*   dd/mm/yy      Code Ver     Description       Author
*   ---------     ---------    -------------     -------
*   20:04:98        0.0       Module Created    G.Prashanth 
*   03:07:2000      0.1       Ported on to MW   N R Prasad
*
*********************************************************************
*
*    DESCRIPTION
*
*    Checks for the flag and calls Dtmf_Det module for the dualtone
*    detection.After successful completion of Dulatone detection 
*    Stf_Det module is called for single tone detection.
*
**********************************************************************/


void Signal_Detect()
{
   /*
   *   checks for the signal_det_flag and calls the 
   *   appropriate asm rotine for the detection.
   */
    
   /*
   *   call DTMF detection routine if that flag is set.
   *   Increment the No_of_frames_processed variable each 
   *   time you call Dtmf_Det routine.
   */
   if (g_signal_det_state == DUAL_TONE_DETECT_STATE)
   {
       Dtmf_Det();
       
       /*
       *   if Dtmf_Det is called for the first time and if the  
       *   current decision is true increment counter initialise 
       *   previous_decision to current_decision which is returned
       *   from assembly.Otherwise compare 
       *   otherwise compare the two,if both are false 
       *   reset the No_of_frames_processed to zero and
       *   continue freshly,else assign current to previos
       *   and continue detection till 18 frames. 
       */
       
       if ((s_no_of_frames_processed == 0) && 
           (g_current_decision == TRUE))
        {
            s_previous_decision = g_current_decision;
            s_no_of_frames_processed++;
        }

       /*
       *   Compare the previous and current decision,if both are
       *   false reset the no_of_frames_processed to zero and start
       *   freshly.
       */
        
       else if (s_previous_decision == g_current_decision)
       {
           if (s_previous_decision == FALSE)
           {
               s_no_of_frames_processed = 0;
           }
           else
           {
               s_no_of_frames_processed++;
           }
       }   

       /*          
       *   If both the decisions are not same change previos
       *   decision to current decision, increment the no_of
       *   frames_processed.
       */
           
       else
       {
           s_previous_decision = g_current_decision;       
           s_no_of_frames_processed++;  
       }  

       /*
       *   If no_of_frames_processed equals the count change
       *   the signal_det_state single_tone detect state and
       *   reset the no_of_frames_processed to zero,reset 
       *   previous decision and initialise variables for
       *   single tone detection.
       */
               
       if (s_no_of_frames_processed == DTMF_FRAME_COUNT)
       {
           s_no_of_frames_processed = 0;
           g_signal_det_state = SINGLE_TONE_DETECT_STATE;
           s_previous_decision = FALSE;
           Stf_Det_Init(); 
       }
   }
   
   /*
   *   If flag is set for SINGLE_TONE call single_tone detection 
   *   subroutine.If 7 frames have elapsed sinse entering this state
   *   exit.
   */

   else if (g_signal_det_state == SINGLE_TONE_DETECT_STATE)
   {

       Stf_Det();
       s_no_of_frames_processed++;


       if (s_no_of_frames_processed > STF_FRAME_COUNT)
       {
           Signal_Detect_Init();
       }
       
       /*
       *   If first frame is called for detection initialise the 
       *   previos_decision to current_decision.
       */  

       else
       {

           if (s_no_of_frames_processed == 1)
           {
               s_previous_decision = g_current_decision;
           }
           else
           {
               /*
               *   If two consecutive frames have been detected
               *   check for the dual_tone and single_tone detection
               *   and set SIGNAL_DETECTED flag if they constitute a
               *   valid signal.
               */

               if (s_previous_decision == g_current_decision)
               {
                   if (s_previous_decision == TRUE) 
                   {
                       g_single_tone_detected += SIGNAL_OFFSET;  

                       /*
                       *   Check for the type of DTMF detected to 
                       *   Initialising tone.If single tone detected
                       *   is other than ESr and staion is RESP_STATION
                       *   set SIGNAL_DETECTED to true.
                       */
                       
                       if ((g_v8bis_flags.station == RESP_STATION) &&
                           (!(g_single_tone_detected == ESr)))
                       {
                           g_v8bis_flags.signal_detected = TRUE;
                       }
                  
                       /*
                       *   If not intialising it is assumed that type of
                       *   DTMF tone detected is Responding,so check for
                       *   the valid single tone signal detected.If yes
                       *   set the signal_detected flag to TRUE.
                       */
                     
                       else if ((g_v8bis_flags.station == INIT_STATION)&& 
                               ((g_single_tone_detected == MRd) ||
                                (g_single_tone_detected == CRd) ||
                                (g_single_tone_detected == ESr)))
                         
                       {
                           g_v8bis_flags.signal_detected = TRUE;   
                       }

                       /*
                       *   If the tone detected is a valid signal change
                       *   the state to DUAL_TONE_DET_STATE by calling
                       *   Signal_Det_Init
                       */
                       
                       else
                       {
                           Signal_Detect_Init();
                       }           

                       /*
                       *   Check if single tone detected is escape 
                       *   signal ie., Esi or Esr.and if it is valid 
                       *   signal.
                       */
                   
                       if (((g_single_tone_detected == ESi) || 
                           (g_single_tone_detected == ESr)) &&
                           (g_v8bis_flags.signal_detected == TRUE))

                       /*
                       *   call Msg_Receive_Init and set the ES_DETECTED
                       *   flag,disable the SIGNAL_DETECT_ENABLE flag.
                       */
                     
                       {
                           g_v8bis_flags.es_detected = TRUE;
                           Msg_Receive_Init();
                           g_v8bis_flags.signal_detect_enable  = FALSE;
                       }
                   }           
               }               /* End of IF loop */  
               else
               {
                   s_previous_decision = g_current_decision;
               }
           }                   /* End of ELSE loop */ 
       } 
   }    /* End of SINGLE_TONE_DETECTION */
   return;
}   
/*
*   End Of File.
*/                                              

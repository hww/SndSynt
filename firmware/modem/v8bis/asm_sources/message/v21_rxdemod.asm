;***************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
; 
;  FILE NAME            : v21_rxdemod.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo
;
;  DATE CREATED         : 02/04/98 
;
;  FILE DESCRIPTION     : This file initializes all the variables used in
;                         V.21 Demodulation and performs V.21 Demodulation. 
;
;  FUNCTIONS            : FV21_RxDemod_Init,V21_RxDemod 
;
;  MACROS               : Nil 
;
;***************************************************************************

        include "v8bis_equ.asm" 
               
        SECTION V21_RxDemod
 
        GLOBAL  FV21_RxDemod_Init

        GLOBAL  V21_RxDemod
 
 
;****************************** Module ************************************
;
;  Module Name    : V21_RxDemod_Init
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This module initializes all the variables reqd. for V.21 Demodulation.
;  For demodulating Message from initiating station it initializes 
;  variables for V.21 L Demodulation , and for responding station it
;  initializes variables for V.21 H Demodulation.
;  
;  Calls :
;        Modules : Nil
;        Macros  : Nil
;
; 
;*************************** Revision History *****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  26/05/98     Minati             Created the module
;  03/07/2000   N R Prasad         Ported on to Metrowerks
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. The center frequency of V21(L) Mod/V21(H) Mod in y0
;     fc = | 0000 0iii | iiii iiii | 
;
;  Output :
;
;  1. The address of SINE_TABLE1/SINE_TABLE2 in x:rx_sinetable_ptr
;     rx_sinetable_ptr = | iiii iiii | iiii iiii |
;  2. The set up for modulo sine table(for both r0 & r1) 
;     in x:rx_sinetable_len 
;     rx_sinetable_len = | 1000 000i | iiii iiii |
;  3. The offset reqd. to search for sine value in x:sine_index
;     sine_index = | 0000 0000 | 00ii iiii |
;  4. The offset reqd. to search for cos value in x:cos_index
;     cos_index = | 0000 0000 | 0iii iiii |
;  5. The address of lpfst_rl_buf in x:lpfst_rl_buf_ptr
;     lpfst_rl_buf_ptr = | iiii iiii | iiii iiii |
;  6. The address of lpfst_im_buf in x:lpfst_im_buf_ptr
;     lpfst_im_buf_ptr = | iiii iiii | iiii iiii |
;  7. The address of avgout_buf in avgout_buf_ptr
;     avgout_buf_ptr = | iiii iiii | iiii iiii |
;  8. The real filter state inputs initialized to zero in  x:lpfst_rl_buf
;     lpfst_rl_buf = | sfff ffff | ffff ffff |
;  9. The imaginary filter state inputs initialized to zero 
;     in x:lpfst_im_buf
;     lpfst_im_buf = | sfff ffff | ffff ffff |
;  10.The variable zero_cross_index initialized to 6 in x:zero_cross_index
;     zero_cross_index = | 0000 0000 | 0000 iiii |
;  11.The previous five inputs reqd for average filter initialized to zero
;     in first five location of divout_buf
;     divout_buf = | sfff ffff | ffff ffff |
;  12.The previous complex sample reqd to enable the division of first  
;     sample in first location of lpfout_rl_buf & lpfout_im_buf . 
;     initialized to 1.
;     lpfout_rl_buf/lpfout_im_buf = | sfff ffff | ffff ffff |
;
;****************************** Resources *********************************
;
;  Registers Used:       y0,r1_r3
;
;  Registers Changed:    y0,r1_r3 
;
;  Number of locations
;    of stack used:      Nil
;
;  Number of DO Loops:   1 
;
;**************************** Assembly Code *******************************
 
         ORG     p:

FV21_RxDemod_Init
 
        cmp     #V21_L_FC,y0              ;compare with v21_l_fc, ie 1080
 
        beq     _v21_l_demod              ;if fc == 1080 then do v21(l)
                                          ;  else do v21(h) demodulation
        move    #COS_H_INDEX,x:cos_index
        move    #V21_H_INDEX,x:sine_index
        move    #(R1_MODULO|(SINE_TABLE2_LEN-1)),x:rx_sinetable_len
        move    #SINE_TABLE2,x:rx_sinetable_ptr
        jmp     _end_v21_l_demod
 
_v21_l_demod
 
        move    #COS_L_INDEX,x:cos_index
        move    #V21_L_INDEX,x:sine_index
        move    #(R1_MODULO|(SINE_TABLE1_LEN-1)),x:rx_sinetable_len
        move    #SINE_TABLE1,x:rx_sinetable_ptr
 
;*************************************************************************
;
;  cos_index is #90 for V21(L) and #36 for V21(H) demodulation .
;  sine_index is #54 for V21(L)  and #35 for V21(H) demodulation.
;  The sine table length is #360 for V21(L)  and #144 for V21(H) 
;  demodulation.R1_MODULO is $8000.
;
;*************************************************************************

_end_v21_l_demod

                                          
        clr     y0                        ;zero in y0
        move    #lpfst_rl_buf,r1          ;r1 -> lpfst_rl_buf[1]
        move    r1,x:lpfst_rl_buf_ptr     
        move    #lpfst_im_buf,r2          ;r2 -> lpfst_im_buf[1]
        move    r2,x:lpfst_im_buf_ptr
        move    #divout_buf,r3            ;r3 -> divout_buf 

;************************************************************************
;
; The first five previous inputs reqd. for average filter are initialized
; to zero. The real and imaginary filter state inputs are also 
; initialized to zero.
;
;***********************************************************************
                                          
        do      #LPF_ORDER,_store_zero    ;for i = 1 to 3,store zero 

        move    y0,x:(r1)+
        move    y0,x:(r2)+
        move    y0,x:(r3)+
                                                 
_store_zero                               ;end of i loop

        move    y0,x:(r3)+
        move    y0,x:(r3)
        move    #$7fff,y0                 ;1 in y0
        move    y0,x:lpfout_rl_buf        ;1st sample is initialized to one
        move    y0,x:lpfout_im_buf        ;  reqd. for division    
        move    #avgout_buf,x:avgout_buf_ptr 
        move    #DEF_ZERO_CROSS_INDEX,x:zero_cross_index
                                          ;zero_cross_index initialized to 6
        move    #1,x:v21_rxstchg          ;Needed to execute the first state 
                                          ;  initialisation
        brset   #ES_DETECTED,x:Fg_v8bis_flags,_start_agc
                                          ;if ES_DETECTED flag is set
                                          ;  jump _start_agc
        move    #V21_Rxcdw_Init,x:v21_rxsti_ptr
        jmp     _end_v21_demod_init

_start_agc

        move    #1,x:v21_cdflag           ;set CD flag
        bfset   #CDBIT,x:Fg_v8bis_flags   ;set CDBIT flag
        move    #V21_Rxagc_Init,x:v21_rxsti_ptr
 
_end_v21_demod_init       

        rts


;****************************** Module ************************************
;
;  Module Name    : V21_RxDemod
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;  
;  This module performs V.21 Demodulation. If the software is looking for
;  a message from the initiating station, it aims at demodulating the 
;  V.21(L) Modulation and if it is looking for a message from the responding
;  station , it demodulates the V.21(H) Modulation.
;
;  V.21 (L) demodulates 980 Hz as binary 1 and 1180 Hz as binary 0. 
;  V.21 (H) demodulates 1650 Hz as binary 1 and 1750 Hz as binary 0. 
;
;  The sampling rate is 7200 Hz and the baud rate is 300.
;  This module gets 24 samples as input and demodulates it as binary 1/0.   
;
;  Calls :
;        Modules : V21_RxLpf,V21_RxDiv,V21_RxAvg_Filter
;        Macros  : V21_RxFreq_Shift 
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  28/05/98     Minati             Incorporated Review Comments.
;  03/07/2000   N R Prasad         Ported on to Metrowerks.
;  08/08/2000   N R Prasad         Dual parallel move converted into
;                                  two different move statements (because,
;                                  all internal memory is moved to
;                                  external memory)
;
;************************* Calling Requirements ***************************
;
;  1. Initialize  SP .
;  2. V21_Demod_Init is to be called before calling this module.
;
;************************** Input and Output ******************************
;
;  Input  :
; 
;  1. The input samples(24) are in location starting from pointer
;     x:Fg_samples_buf_ptr
;     samples  = | sfff ffff | ffff ffff |
;  2. The address of avgout_buf in x:avgout_buf_ptr.
;     This is initialized to point the first location of avgout_buf.
;     avgout_buf_ptr = | iiii iiii | iiii iiii | 
;  
;  Output :
;
;  1. The output (12 samples) of average filter in x:avgout_buf
;     avgout_buf = | sfff ffff | ffff ffff | 
;  2. Updated address of avgout_buf in x:avgout_buf_ptr
;     avgout_buf_ptr = | iiii iiii | iiii iiii |
;  3. Updated previous inputs reqd. for average filter in x:divout_buf
;     divout_buf = | sfff ffff | ffff ffff |
;  4. Updated previous inputs reqd. for division in x:lpfout_rl_buf
;     and x:lpfout_im_buf.
;     lpfout_rl_buf/lpfout_im_buf = | sfff ffff | ffff ffff |
;  
;
;****************************** Resources *********************************
;
;  Registers Used:       x0,y0,r0-r3, 
;
;  Registers Changed:    x0,y0,r0-r3, 
;                        
;  Number of locations 
;    of stack used:      8 
;
;  Number of DO Loops:   1              
;
;**************************** Assembly Code *******************************

V21_RxDemod


;*************************************************************************
;
;  The input signal is multiplied by the nominal center frequency
;  ( Signal * exp(jwc) ; fc = 1080 Hz if V21(L) , 1750 Hz if V21(H))
;  and brought down to base band.
;
;************************************************************************

        jsr     V21_RxFreq_Shift

;**************************************************************************
;       
;  LPF is done to reject the double frequency and to reject out of band
;  noise . This function is called separately for real and imaginary part
;  of the multiplication result.Decimation is also done in LPF module.
;  As a result of decimation the sampling rate comes down to 3600 Hz.
;
;  The input to LPF are in fs_rl_buf/fs_im_buf and the output are in 
;  lpfout_rl_buf(2:13)/lpfout_im_buf(2:13).Filter state inputs are in
;  lpfst_rl_buf/lpfst_im_buf.
;     
;***************************************************************************        
        move    #fs_rl_buf,r1             ;r1 -> fs_rl_buf[1]
        move    #lpfout_rl_buf+1,r2       ;r2 -> lpfout_rl_buf[2]  
        move    x:lpfst_rl_buf_ptr,r0     ;r0 -> lpfst_rl_buf
 
        jsr     V21_RxLpf

        move    r0,x:lpfst_rl_buf_ptr     ;store address pointer reqd.
                                          ;  for next baud processing
        move    #fs_im_buf,r1             ;r1 -> fs_im_buf[1]
        move    #lpfout_im_buf+1,r2       ;r2 -> lpfout_im_buf[2]
        move    x:lpfst_im_buf_ptr,r0     ;r0 -> lpfst_im_buf

        jsr     V21_RxLpf 

        move    r0,x:lpfst_im_buf_ptr     ;store address pointer reqd.
                                          ;  for next baud processing

;***************************************************************************
;
;  Here each sample is devided by previous sample to get the angle 
;  change . The imaginary part of the division is approximated to 'w'.
;  
;  i.e., exp(j*w*n+theta)/exp(j*w*(n-1)+theta) = exp(j*w)
; 
;  'w' is +ve and corresponds to 100 Hz if a '1' was transmitted and is
;  -ve and corresponds to -100 Hz if a '0' was transmitted.
;
;  The inputs are in lpfout_rl_buf and lpfout_im_buf.The outputs are in 
;  divout_buf. The first input of both lpfout_rl_buf and lpfout_im_buf
;  is the last sample of the previous baud . This is reqd. to enable
;  the division of first sample of the current baud. 
;  These are initialized to "1" for the first baud. 
;  
;****************************************************************************
                                          
        move    #lpfout_rl_buf,r1         ;r1 -> lpfout_rl_buf[1]
        move    #lpfout_im_buf,r3         ;r3 -> lpfout_im_buf[1]
        move    #divout_buf+5,r2          ;r2 -> divout_buf[6]

        jsr     V21_RxDiv 

;***************************************************************************
;
;  The last sample of current baud is stored to enable the division of the
;  first sample of the next baud.r1 and r3 points to the real and imagianry
;  part of the last sample of the curent baud.
;
;**************************************************************************  
                             
        move    x:(r1)+,y0
        move    x:(r3)+,x0
        move    y0,x:lpfout_rl_buf    
        move    x0,x:lpfout_im_buf    

;**************************************************************************
;
;  A  6_tap moving average is done  on the calculated value of 'w'
;  to attenuate echo as well as to do more noise rejection.
;
;  The inputs are in divout_buf and the outputs are in avgout_buf. 
;  The avgout_buf is a circular buffer of length 36(3 baud long).
;  The first 5 samples of divout_buf are the last 5 samples of previous
;  baud. For the first baud these samples are initialized to zero.
;  
;*********************************************************************** 
                                          
        move    #divout_buf,r3            ;r3 -> divout_buf[1]
        move    x:avgout_buf_ptr,r0       ;r0 -> avgout_buf
 
        jsr     V21_RxAvg_Filter 
   
        move    r0,x:avgout_buf_ptr       ;store address of avgout_buf,
                                          ;  which is reqd. for next
                                          ;  baud processing

;************************************************************************
;
;  The reqd. previous 5 inputs for next baud processing are the last 
;  5 samples of the divout_buf or previous baud.These are stored at
;  the first 5 locations of divout_buf.  
;
;************************************************************************

        move    #divout_buf,r2            ;r2 -> divout_buf[1]
        move    #divout_buf+12,r3         ;r3 -> divout_buf[13]

        do      #(AVG_LEN-1),_store_previous
                                          ;for i = 1 to 5
                                          ;  store the previous 5 inputs 
        move    x:(r3)+,x0
        move    x0,x:(r2)+

_store_previous                           ;end of i loop
 
        jmp     V21_Rx_Nxt_Tsk
 
        ENDSEC
 
;****************************** End of File *******************************





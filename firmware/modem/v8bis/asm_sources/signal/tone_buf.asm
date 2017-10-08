;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : tone_buf.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 4:03:98
;
; FILE DESCRIPTION     : Normalises the samples and adds gaurd bits
;                        Finds the signal_energy of the signal.  
;
; FUNCTIONS            : Generate_Analysis_Array,Calc_Sig_En
;
; MACROS               : 
;
;************************************************************************ 
        
        include "v8bis_equ.asm"
        include 'tone_set.asm'
        SECTION TONE_BUF                        
        GLOBAL  Generate_Analysis_Array
        GLOBAL  Calc_Sig_En


;***************************** Module ********************************
;
;  Module Name   :  Generate_Analysis_Array 
;  Author        :  G.Prashanth
;
;*************************** Description *******************************
;
;       This module is normalises the input samples and adds gaurd bits
;       according to the DTMF design.
;  Calls:
;       Modules  :  Calc_Sig_En,Find_shift
;       Macro    : 
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  28:02:98             G.Prashanth          Module Created 
;   1:06:98             G.Prashanth After incorporating Review comments 
;************************ Calling Requirements *************************
;
;  1. Initialise SP
;
;************************* Input and Output ****************************
;
;       Input:  input_buf = pointer to input frame
;
;       The stack strucure can be shown as
;                          ____________
;      input_buf-> (sp-2) |____________|
;      SR       -> (sp-1) |____________|
;                   sp    |____________|
;
;       Output:         a = energy and is double prcision.
;    sig_energy(hi) = | 0.fff ffff | ffff ffff | in a1
;    sig_energy(lo) = | ffff ffff  | ffff ffff | in a0
;
;
;       Return Value: analysis buffer which is normalised and gaurd 
;                     bits added.(144 samples at 7.2Khz of input buffer)
;
;**************************** Resources *******************************
;
;  Registers Used      : a,b,y1,y0,r0,r1
;
;  Registers Changed   : a,b,y1,y0,r0,r1
;
;  Number of locations : 2(only for jsr) 
;  of stack used  
;
;  Number of Do loops  : 2
;
;************************** Assembly Code *****************************

        ORG     p:
Generate_Analysis_Array
        Define  SP_input_buf 'x:(sp-2)' 
        move    #ana_buf,r1               ;r1 = analysis_buf
        clr     y1 
        move    SP_input_buf,r0       
        move    #(ANA_BUF_SIZE)>>1,y0
        move    x:(r0)+,a                 ;Get max over 144 samples
        do      y0,_MAX_SAMPLE_BUF        ;OR each sample to find  
        abs     a        x:(r0)+,b        ;  the maximum.
        move    a,a                       ;saturate 
        or      a1,y1
        abs     b        x:(r0)+,a
        move    b,b                       ;saturate.
        or      b1,y1

_MAX_SAMPLE_BUF
        move    y1,a    
        jsr     Find_shift               ;find the normalising count.
        add     #SAMPLE_SHIFT,a          ;add the gaurd bit count.  
        move    SP_input_buf,r0          ;r0 -> in_buf  
        blt     _LEFT_SHIFT
        move    a,y0
;*********************************      
;Do ana_buf_size times
;**********************************     
        move    #ANA_BUF_SIZE,lc
        do      lc,_END_COPY2_LFT1
        move    x:(r0)+,y1                ;y1 = input_buf[r0++] 
        asrr    y1,y0,y1                  ;y1 = y1>>SAMPLE_SHIFT
        move    y1,x:(r1)+                ;analysis_buf[r1++] = y1
_END_COPY2_LFT1                           ;enddo
 
        bra     _END_GEN_ANA_ARR

_LEFT_SHIFT
        neg     a
        move    a,y0
        move    SP_input_buf,r0           ;r0 = input_buf
;************************************   
;Do ana_buf_size times
;************************************   
        move    #ANA_BUF_SIZE,lc
        do      lc,_END_COPY2_LFT
        move    x:(r0)+,y1               ;y1 = input_buf[r0++] 
        asll    y1,y0,y1                 ;y1 = y1<<SAMPLE_SHIFT
        move    y1,x:(r1)+      
_END_COPY2_LFT                           ;enddo

_END_GEN_ANA_ARR
        jsr     Calc_Sig_En              ;find the signal_energy.
        rts

Find_shift
        move    #0,r0
        tst     a                        ;Reflect the flags for norm
        do      #NORM_COUNT,_end_norm    ;  instruction
        norm    r0,a
_end_norm
        move    r0,a
        move    a,b
        abs     b 
        move    b,x:shift_count
        rts
;***************************** Module ********************************
;
;  Module Name   : Calc_Sig_En
;  Author        : G.Prashanth 
;
;*************************** Description *******************************
;
;       This module computes the energy over specified number of
;       samples and scales it according to DTMF requirements.
;       This energy is proportional to the mg_energies which can
;       be used for various tests for DTMF,and STF.
;
;  Calls:
;       Modules  :
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description 
;  ------              ----------              ---------
; 2:03:98              G.Prashanth           Module Created 
; 1:06:98             G.Prashanth After incorporating Review comments 
;
;************************ Calling Requirements *************************
;
;  1.Initialize the ana_buf
;
;
;************************* Input and Output ****************************
;
;       Input:     
;           ana_buf = Contains the samples from 
;                                 Generate_Analysis_Array
;
;       Output:         a = energy and is double prcision.
;    sig_energy(hi) = | 0.fff ffff | ffff ffff | in a1
;    sig_energy(lo) = | ffff ffff  | ffff ffff | in a0
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b,r2
;
;  Registers Changed   : x0,y0,y1,a,b,r2
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : 1 
;
;************************** Assembly Code *****************************

Calc_Sig_En

        move    #ana_buf,r2
        move    #NS,y1                    ;y1 = NS 
        clr     a        x:(r2)+,y0       ;sig_energy=0, get the first 
                                          ;  sample
        do      y1,_COMPUTE_ENERGY
        mac     y0,y0,a  x:(r2)+,y0       ;a = sig_energy
_COMPUTE_ENERGY
        tfr     a,b                       ;take a copy in to b
        asl     a                         ;multiply sig_energy by NS/2
                                          ;  to compensate with mg_ener
                                          ;  which is done as 
                                          ;  2^6*sig_energy+2^3*sig_energy.
        asl     a
        asl     a
        asl     a
        asl     a
        asl     a
        asl     b
        asl     b
        asl     b
        add     b,a 
        move    #N_COMP,x0                ;Get Noise compensator to x0
        sub     x0,a                      ;Subtract magic number from
                                          ;  sig_energy,Noice compensatr
                                          ;  set to zero for testing
        rts
        ENDSEC 
;************************* End Of File ****************************************

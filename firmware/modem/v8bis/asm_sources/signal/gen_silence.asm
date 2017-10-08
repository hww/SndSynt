;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : gen_silence.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 10:04:98
;
; FILE DESCRIPTION     : generate the silence for 20ms. at 7.2KhZ sampling
;                        rate.  
;
; FUNCTIONS            : FSilence_Gen
;
; MACROS               : N/A
;
;************************************************************************  
        include  'tone_set.asm'
        include  'v8bis_equ.asm'
        
        SECTION   Gen_Silence                                           
        GLOBAL    FSilence_Gen 

;****************************** Module *************************************
;
; Module Name  :   Silence_Gen 
; Author       :   G.prashanth
;
;************************* Module Description *************************** 
;     This module puts the silence data in to specified memory locn.
;     for the specified time(20ms).
;
;     calls    :    N/A
;     macros   :    N/A 
;
;************************** Revision History *****************************
;
;      Date               Person         Description  
;      ----               ------           ------
;     10:04:98          G.Prashanth      Module Created   
;     03:07:2000        N R Prasad       Ported on to Metrowerks   
;
;************************* Calling Requirements *************************
;
;  1.Initialise Fg_samples_buf_ptr
;
;*************************** Input and Output ****************************
;
;  Inputs : ouput buffer pointer in x:Fg_samples_buf_ptr.
;
;  Outputs:
;          generates silence of 144 samples. 
;
;***************************** Resources **********************************
;
;  Registers Used       :   a 
;
;  Registers Changed    :   a, lc 
;
;  Number of locations     
;  stack used           :   N/A 
;
;  Number of DO Loops   :   1 
;
;**************************** Assembly Code *******************************
        ORG     p:
FSilence_Gen

        move    x:Fg_samples_buf_ptr,r0
        clr     a
        move    #NS,lc
        do      lc,_END_SILENCE
        move    a,x:(r0)+
_END_SILENCE
        rts
        ENDSEC
;************************ End Of File ***************************************** 

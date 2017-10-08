;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : stf_api.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 4:04:98
;
; FILE DESCRIPTION     : Initialises the filter states and tests
;                        for the STF detection by calling other 
;                        sub modules.   
;
; FUNCTIONS            : Stf_Detect 
;
; MACROS               : N/A
;
;************************************************************************  

        include 'tone_set.asm'
        SECTION stf_api                 
        GLOBAL  Stf_Detect


;***************************** Module ********************************
;
;  Module Name   : Stf_Detect
;  Author        : G.Prashanth
;
;*************************** Description *******************************
;
;       This routine performs STF detection on samples found
;       in the ana_buf analysis buffer. If a valid tone is detected, 
;       returns 1 in x0 else 0 is returned in x0.
;       Initialises the filter states to zero. 
;  Calls:
;       Modules  :Newnum,Calc_Mg_En,Tst_Stf
;       Macro    :
;
;************************** Revision History ***************************
;
;   Date                 Author              Description    
;  ------              ----------              ---------
;  3:03:98             G.Prashanth          Module Created  
;  02:06:98            G.Prashanth          Incorporated Review comments
;  03:07:2000          N R Prasad           Ported on to Metrowerks
;
;************************ Calling Requirements *************************
;
;  1. initialise the analysis buffer.
;
;
;************************* Input and Output ****************************
;
;   Input :     ana_buf - Samples generated from 
;               Generate_Analysis_Array
;               
;   Output :
;    data_word = | 0000 0000 | 0000 000i | in x0
; 
;  Return Value: tone detected (0 or 1 in x0 depending on decision)
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,n,m01,r0,
;                        r3,r1,y0
;
;  Registers Changed   : x0,n,r3,r0
;                        r1,y0
;
;  Number of locations :  2(used for jsr)  
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************
 
Stf_Detect      

        move    #sik,r3                   ;set the filter states to
        clr     x0                        ;zero before finding energy.
        rep     #2*NO_STF
        move    x0,x:(r3)+                
        move    #sik+2*NO_STF-3,r0        ;r0 -> sik+9 
        move    #2*NO_STF-1,m01           ;set the modulo buffer of
                                          ; 11. 
        jsr     Newnum                    ;find sik's for STF filters

        jsr     Calc_Mg_En                ;Calculate MG_EN of STF 

        jsr     Tst_Stf                   ;test if STF tone exists
                                          ;  the x0 contains the 
                                          ;  decision as output. 
        move    #-1,m01                   ;set for linear mode.
        rts                               ;return
        ENDSEC

;******************** End of File *********************************

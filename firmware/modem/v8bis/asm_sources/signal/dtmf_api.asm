;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : dtmf_api.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 4:03:98
;
; FILE DESCRIPTION     : Initialises the filter variables and tests
;                        for the DTMF detection by calling other 
;                        sub modules.   
;
; FUNCTIONS            : Dtmf_Detect 
;
; MACROS               : N/A
;
;************************************************************************  

        include 'tone_set.asm'
        SECTION dtmf_api                        
        GLOBAL    Dtmf_Detect


;***************************** Module ********************************
;
;  Module Name   : Dtmf_Detect
;  Author        : G.Prashanth
;
;*************************** Description *******************************
;
;       This routine performs DTMF detection on samples found
;       in the ana_buf analysis buffer. If a valid tone is detected, 
;       returns 1 in x0 else 0 is returned in x0.,
;  Calls:
;       Modules  :Newnum,Calc_Mg_En,Tst_Dtmf
;       Macro    :
;
;************************** Revision History ***************************
;
;   Date                 Author              Description    
;  ------              ----------              ---------
;  3:03:98              G.Prashanth          Module Created  
;  1:06:98              G.Prashanth          Incorporated Review comments
;
;************************ Calling Requirements *************************
;
;  1. analysis buffer should be generated.
;
;
;************************* Input and Output ****************************
;
;   Input :     ana_buf -Samples generated from
;               Generate_Analysis_Array
;               
;   Output :
;    decision = | 0000 0000 | 0000 000i | in x0
; 
;  Return Value: tone detected (1 or 0 depending on decision)
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,n,m01,r0,r3
;
;  Registers Changed   : x0,n,r3,r0
;
;  Number of locations : 2 (for jsr only) 
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************
 
Dtmf_Detect     

        move    #sik,r3                   ;set the filter states to
        clr     x0                        ;  zero before finding energy
        rep     #2*NO_DTMF
        move    x0,x:(r3)+
        move    #sik+2*NO_DTMF-3,r0
        move    #2*NO_DTMF-1,m01          ;set the modulo buffer.
        jsr     Newnum                    ;find sik's for DTMF filters

        jsr     Calc_Mg_En                ;Calculate MG_EN of DTMF 

        jsr     Tst_Dtmf                  ;test if DTMF tone exists
                                          ;  the output in x0 indicates
                                          ;  the decision.
        move    #-1,m01                   ;set for linear mode.
        rts                               ;return
        ENDSEC
;******************** End of File *********************************

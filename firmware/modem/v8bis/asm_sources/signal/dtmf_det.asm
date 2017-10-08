;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : dtmf_det.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 28:04:98
; 
; FILE DESCRIPTION     : This module initialises the variables used for
;                        dtmf detection.as well as calls the other
;                        modules for the detection of dual_tone signals
;                        in V8bis. 
;
; FUNCTIONS            : FDtmf_Det_Init,FDtmf_Det
;
; MACROS               : -
;
; 
;*************************************************************************** 

        include 'tone_set.asm' 
        include "v8bis_equ.asm"
         
        SECTION  Dtmf_Det
        GLOBAL  FDtmf_Det_Init             
        GLOBAL  FDtmf_Det             


;**************************** Module **************************************
;
;  Module Name      :   FDtmf_Det_Init 
;  Author           :   G.Prashanth
;
;********************* Module Description ********************************
;  This module initialises the variables needed for the dtmf detection
;  ie , moves the X-Rom HPF coefficients to X-Ram scratch which is a
;  module buffer.This is to be called before dtmf detection begins. 
;  Calls :
;        Modules :
;               
;        Macros  : N/A
;   
; ********************** Revision History *****************************
;
;   Date                Author            Description 
;   ----                ------             -------
;  26:04:98           G.Prashanth        Module Created  
;  03:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks.
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
; 
; ******************** Calling Requirements *************************** 
;
;  1. Nil
;
; ********************** Input and Output *****************************
;
;  Input   :   signal_type offset in y0 Iniating or Responding
;        data word =  |0000 0000 | 0000 00i0|    
;                                      
;  Output  :  N/A
;
;************************** Resources ********************************
;
;  Registers Used      :       x0,r3,r1,r0,n 
;
;  Registers Changed   :       x0,r0,r3,r1,n 
;
;  Number of locations
;    of stack used     :       N/A 
;
;  Number of DO Loops  :       1 
;
;********************** Assembly Code ********************************

        ORG     p:
FDtmf_Det_Init
        move    #cosval_dtmf,r3           ;initialise the mg_filter
                                          ;  coeffecients.
        move    y0,n                      ;get the index in to n
        move    #Dtmf_mg_fil_coeff,x:coeff_ptr
                                          ;x:response -> scratch_buff
        lea     (r3)+n                    ;point to the exact locn.
                                          ;  r3 ->cosval+n
        move    #Dtmf_mg_fil_coeff,r1                             
        do      #NO_DTMF,_end_coeff       ;copy the x-rom constants
                                          ;  to scratch buffer.
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;dummy move of r0 to y0
                                          ;  is done. x0 = cosval(i)   
        move    x0,x:(r1)+                ;move the constant to scra
                                          ;  tch buffer.
_end_coeff
        move    #HPF_coeff,r3             ;r3 -> HPF_coeff
        move    #HPF_mscratch,r1          ;r1->HPF_scratch_coeff
        do      #NO_HPF_COEFF,_end_coef_fill 
                                          ;copy the HPF coeff values
                                          ;  from X-rom to X-ram 
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;dummy move of r0 to y0 
                                          ;  is done.
        move    x0,x:(r1)+
_end_coef_fill 
        move    #NO_DTMF,x:no_of_filter   ;get the count of filter.
;***************************************************************
; Absolute energy which is -60dBm and expressed in double precision
;   move it in to variable dtmf_level and used in Mag test.
;*************************************************************** 
        move    #EMIN_H,x:dtmf_level      ;get level(hi)
                                          ;  dtmf_level = EMIN_H 
        move    #EMIN_L,x:dtmf_level+1    ;get level(lo)
                                          ;dtmf_level+1 = EMIN_L 
        rts



;**************************** Module **************************************
;
;  Module Name      :   FDtmf_Det 
;  Author           :   G.Prashanth
;
;********************* Module Description ********************************
;
;  This module takes input as a buffer of 152 samples and calls other
;  module for the DTMF detection and outputs the decision.
;  Note  : The actual data samples should be 8th loacation onwords. 
;  Calls :
;        Modules : Generate_Analysis_Array,Dtmf_Hpf,
;                  Dtmf_Detect.
;        Macros  : N/A
;   
; ********************** Revision History *****************************
;
;   Date                Author            Description 
;   ----                ------             -------
;  26:03:98           G.Prashanth        Module Created  
;   3:06:98           G.Prashanth        Incorporated Review comments  
;  03:07:2000         N R Prasad         Ported on to Metrowerks
;
; ******************** Calling Requirements *************************** 
;
;  1.  Initialize  the input buffer ptr in x:Fg_samples_buf_ptr 
;
; ********************** Input and Output *****************************
;
;  Input   :  input buffer of 152 samples with starting from  8th
;             location.  pointed by
;             x:Fg_samples_buf_ptr
;
;  Output  :
;             decesion        = | 0000 0000 | 0000 000i | in 
;             x:Fg_current_decision
;
;************************** Resources ********************************
;
;  Registers Used      :     a,y0,r0,n
;
;  Registers Changed   :     a,y0,r0,n 
;
;  Number of locations
;    of stack used     :     1 + 2(used for jsr) 
;
;  Number of DO Loops  :     1 
;
;********************** Assembly Code ********************************
        ORG     p:
FDtmf_Det

        lea     (sp)+
        move    x:Fg_samples_buf_ptr,r0   ;r0 -> input_buff 
        move    r0,x:(sp)                 ;store the value in stack
                
        jsr     Generate_Analysis_Array   ;find the sig_energy before
                                          ;  filtering.
        move    x:(sp),r0                 ;r0 -> input_buf+8
        move    #FIRST_LOC,n
        move    a1,x:sig_energy
        move    a0,x:sig_energy+1         ;store the double precision
                                          ;  energy.
        lea     (r0)+n
        move    r0,x:(sp)                 ;r0 -> input_buf
        jsr     Dtmf_Hpf                  ;filter the samples.
        move    x:(sp),r0
        move    #OUT_INDEX,n
        nop
        lea     (r0)+n
        move    r0,x:(sp)                 ;r0->input_buf+4 output
                                          ;  of hpf.
        jsr     Generate_Analysis_Array
        move    a1,x:sig_energy+2         ;store the sig_energy 
        move    a0,x:sig_energy+3
        jsr     Dtmf_Detect               ;carry out initialisation
                                          ;  of abs. energy and 
                                          ;  detect the signal
        move    x0,x:Fg_current_decision  ;move the decision to global
                                          ;  variable. 
        pop     y0                        ;pop in to some register 
                                          ;  before returning.
        rts
        ENDSEC   
;************************ End of File ****************************** 

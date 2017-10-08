;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : stf_det.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 25:04:98
; 
; FILE DESCRIPTION     : This module initialises the variables used for
;                        stf detection.as well as calls the other
;                        modules for the detection of single_tone signal
;                        in V8bis. 
;
; FUNCTIONS            : FStf_Det_Init,FStf_Det
;
; MACROS               : -
;
; 
;*************************************************************************** 

        SECTION  Stf_Det 
        include 'tone_set.asm' 
        GLOBAL  FStf_Det_Init      
        GLOBAL  FStf_Det      

        
;**************************** Module **************************************
;
;  Module Name      :   FStf_Det_Init 
;  Author           :   G.Prashanth
;
;********************* Module Description ********************************
;  This module initialises the variables needed for the stf detection
;  ie , moves the X-Rom coefficients to X-Ram scratch which is a
;  This is to be called before stf detection begins. 
;  Calls :
;        Modules :
;               
;        Macros  : N/A
;   
; ********************** Revision History *****************************
;
;   Date                Author            Description 
;   ----                ------             -------
;  26:04:98            G.Prashanth        Module Created  
;  03:06:98            G.Prashanth        Incorporated Review comments
;  03:07:2000          N R Prasad         Ported on to Metrowerks
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
; ******************** Calling Requirements *************************** 
;
;   N/A  
;
; ********************** Input and Output *****************************
;
;  Input   :  N/A
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
FStf_Det_Init
        move    #cosval_stf,r3            ;initialise the mg_filter
                                          ;  coefficients.
        move    #Stf_mg_fil_coeff,r1      ;r1 -> scratch_buff
        move    r1,x:coeff_ptr            ;store the address ptr in 
                                          ;  variable.
        do      #NO_STF,_end_coeff_copy   ;copy the x-rom constants
                                          ;  of STF to scratch buffer.
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;dummy move of r0 to y0 is
                                          ;  done.
        move    x0,x:(r1)+                ;get the constant in to 
                                          ;  scratch buffer.
_end_coeff_copy
        move    #NO_STF,x:no_of_filter    ;get the count of filter.
        rts



;**************************** Module **************************************
;
;  Module Name      :   FStf_Det 
;  Author           :   G.Prashanth
;
;********************* Module Description ********************************
;
;  This module takes input as a buffer of 144 samples and calls other
;  module for the STF detection and outputs the decision.
;  Calls :
;        Modules : Generate_Analysis_Array,Stf_Detect
;
;        Macros  : N/A
;   
; ********************** Revision History *****************************
;
;   Date                Author           Description 
;   ----                ------             -------
;  14:04:98           G.Prashanth        Module Created    
;  03:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks
;
; ******************** Calling Requirements *************************** 
;
;  1.  Initialize  the input buffer ptr x:Fg_samples_buf_ptr 
;
; ********************** Input and Output *****************************
;
;  Input   :  input buffer of 144 samples pointer pointed by
;
;             x:Fg_samples_buf_ptr
;
;  Output  :
;         decision   = | 0000 0000 | 0000 000i | in 
;                                                 x:Fg_current_decision
;
;************************** Resources ********************************
;
;  Registers Used      :       a,y0,r0,n,
;                              r1,x0
;
;  Registers Changed   :       a,y0,r0,n,
;                              r1,x0 
;
;  Number of locations
;    of stack used     :       1 + 2(for jsr)
;
;  Number of DO Loops  :       -
;
;********************** Assembly Code ********************************
      
        ORG     p:
FStf_Det
        lea     (sp)+
        move    x:Fg_samples_buf_ptr,r0   ;get the buff_ptr in r0 
        move    r0,x:(sp)                 ;store the value in stack 
        
        jsr     Generate_Analysis_Array   ;find the sig_energy.
        move    a1,x:sig_energy             
        move    a0,x:sig_energy+1         ;store the double precision
                                          ;  energy
        jsr     Stf_Detect                ;find the decision and the 
                                          ;  type of signal detected. 
        move    x0,x:Fg_current_decision  ;move the decision.     
        pop     y0                        ;pop in to some register 
                                          ; before returning.
        rts
        
        ENDSEC 
          
;************************ End of File ****************************** 

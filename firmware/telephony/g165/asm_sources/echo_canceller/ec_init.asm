;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_INIT
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  11/11/97    0.0.1        Macro Created              Quay Cindy
;  21/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  Initialization of variables for EC modules.
; 
;  Symbols Used :
;       sin_sample        : Sample from snd channal
;       rin_sample        : Sample from rcv channal
;       sout_sample       : Output sample to snd channel
;       g165_ec_enable    : Flag to enable or disable echo cancellation
;       hfilt[Filt_Len+1] : Filter coefficients
;       hbak1[Filt_Len+1] : First backup of filter coeff 
;       hbak2[Filt_Len+1] : Second backup of filter coeff 
;       f_stat[Filt_Len+1]: States of the filter
;       fstat_p           : Pointer to the filter states
;       hfilt_p           : Pointer to the filter coefficients
;       hbak1_p           : Pointer to the first filter bakup
;       hbak2_p           : Pointer to the second filter backup
;       dbl_tlk           : Double talk detection flag
;       dont_adapt        : Flag to freeze adaptation
;       trn_lvl           : Level of training flag
;       reset_coef        : Flag for resetting coefficients
;       nl_option         : Non - linear supression option
;       nl_supress        : Non - linear supression counter 
;       Frm_ctr           : Sample count in a Frame
;       ener_rin_low      : LSW  of ener_rin (energy of rcv samples)
;       ener_rin_high     : MSW  of ener_rin
;       ener_sin_low      : LSW  of ener_sin (energy of input snd samples)
;       ener_sin_high     : MSW  of ener_sin
;       ener_sout_low     : LSW  of ener_sout (energy of output snd smpls)
;       ener_sout_high    : MSW  of ener_sout
;       mu_base           : Base for calculating mu
;       mu                : Mu for adaptation
;       power2tab         : Table for power of 2 values
;       len_factor        : Filter length factor adjustment
;       change_flag       : Flag to indicate change in the coefficients
;       ec_frm_full       : Flag to indicate echo-cancln frame is full
;       ec_frm_full       : Flag to disable tone detect logic (set by user)
;       inhibit_converge  : Flag to freeze adaptation (set by user)
;       EC_FRMLEN         : Frame length for echo canceller
;       NL_HANGOVER       : No of frames of delay before activating 
;                         :   non-linear supression
;       NL_ATTENUATION    : Non-linear attenuatation factor
;
;  Functions called
;       None
;
;  Note:  The constant and variable declarations for this module are defined
;         in the ec_data.asm file
;
;**************************** Function Arguments **************************
;
;  None
;  
;************************* Calling Requirements ***************************
;
;  None
;
;************************** Input and Output ******************************
;
;  Input  :
;       None
;      
;  Output :
;       None
;
;
;************************* Globals and Statics ****************************
;
;  Globals : 
;       hfilt[k]          =   | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       hbak1[k]          =   | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       hbak2[k]          =   | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       f_stat[k]         =   | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       dbl_tlk           =   | 0000 0000  | 0000 000i |
;
;       dont_adapt        =   | 0000 0000  | 0000 000i |
;
;       trn_lvl           =   | 0000 0000  | 0000 00ii |
;
;       reset_coef        =   | 0000 0000  | 0000 000i |
;
;       nl_option         =   | 0000 0000  | 0000 000i |
;
;       nl_supress        =   | 0000 0000  | 0000 00ii |
;
;       Frm_ctr           =   | 0000 000i  | iiii iiii | 
;
;       sin_sample        =   | s.fff ffff | ffff ffff | 
;
;       rin_sample        =   | s.fff ffff | ffff ffff | 
;
;       sout_sample       =   | s.fff ffff | ffff ffff | 
;
;       ener_rin_high     =   | i.fff ffff | ffff ffff | 
;
;       ener_rin_low      =   | ffff ffff  | ffff ffff |
;
;       ener_sin_high     =   | i.fff ffff | ffff ffff | 
;
;       ener_sin_low      =   | ffff ffff  | ffff ffff |
;
;       ener_sout_high    =   | i.fff ffff | ffff ffff | 
;
;       ener_sout_low     =   | ffff ffff  | ffff ffff |
;
;       mu_base           =   | i.fff ffff | ffff ffff |
;
;       mu                =   | iiii iiii  | iiii iiii |
;
;       power2tab[k]      =   | iiii iiii  | iiii iiii | for k = 0 to 13
;
;       len_factor        =   | i.fff ffff | ffff ffff |   
;
;       change_flag       =   | 0000 0000  | 0000 000i |
;
;       ec_frm_full       =   | 0000 0000  | 0000 000i |
;
;       hfilt_p           =   | iiii iiii  | iiii iiii |
;
;       fstat_p           =   | iiii iiii  | iiii iiii |
;
;       hbak1_p           =   | iiii iiii  | iiii iiii |
;
;       hbak2_p           =   | iiii iiii  | iiii iiii |
;
;       ec_frm_full       =   | 0000 0000  | 0000 000i |
;
;       inhibit_converge  =   | 0000 0000  | 0000 000i |
;
;  Statics : 
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : (4*ECHOSPAN) + 80
;                        Program Words : 82
;                        NLOAC         : 66
;
;  Address Registers Used:
;       None
;
;  Offset Registers Used:
;       None
;
;  Data Registers Used:
;       None
;
;  Registers Changed:
;       None
;
;***************************** Pseudo Code ********************************
;
;   Begin
;       for k = 1 to filt_length,
;           hfilt[k] = 0;       /* Start with 0 coefficients */
;           hbak1[k] = 0;       /* Backup filt coeffs are reset */
;           hbak2[k] = 0;       /* Backup filt coeff are reset */
;           filt_states[k] = 0;  /* Start with 0 states */
;       endfor
;
;       dbl_tlk     = 0;    /* Set Doublener_talk flag to zero */
;       dont_adapt  = 0;    /* Set dont_adapt flag to zero */
;       trn_lvl     = 0;    /* Set trn_lvl flag to zero */
;       nl_supress  = 0;    /* Set nl_supress counter to zero */
;       ec_frm_full = 0;    /* Set ec_frm_full to zero */
;       ec_frm_full = 0;
;       inhibit_converge = 0;
;       reset_coef  = 0;
;       change_flag = 1;
;       nl_option   = 1;
;       g165_ec_enable = 1;
;       Frm_ctr     = EC_FRMLEN;  /* Set frm_ctr counter to EC_FRMLEN */
;       len_factor  = 40/ECHOSPAN ; table of values for EchoSpan [40,320]
;       ener_rin  = 2^(-18); (1n 1.32 format)
;       ener_sin  = 2^(-18); (1n 1.32 format)
;       ener_sout = 2^(-18); (1n 1.32 format)
;       mu_base = 1;(1n 1.15 format)
;   End
;
;**************************** Assembly Code *******************************

	SECTION EC_INIT_CODE
	
    include "equates.asm"
    	
	GLOBAL  EC_INIT
    
    org     p:

EC_INIT  
_Begin_EC_INIT

	move    #hfilt,r0                 ;r0 --> hfilt[0]
	move    #f_stat,r3                ;r3 --> f_stat[0]
    move    x:EchoSpan,x0
	clr     a                         ;Clear delay buffer
	do      x0,_initover              ;  and coeffs buffer
	move    a,x:(r0)+                 
	move    a,x:(r3)+        
_initover 

	move    #hbak1,r0                 ;r0 --> hbak1[0]
	move    r0,x:hbak1_p              ;hbak1_p is loaded with address
             			              ;  of hbak1[0]
	move    #hbak2,r3                 ;r3 --> hbak2[0]
	move    r3,x:hbak2_p              ;hbak2_p is loaded with address

	do      x0,_initcofbak            ;Clear coeffs backup buffers
	move    a,x:(r0)+        
	move    a,x:(r3)+        
_initcofbak 

	move    a,x:dbl_tlk               ;Set dbl_tlk = 0
	move    a,x:dont_adapt            ;Set dont_adapt = 0
	move    a,x:trn_lvl               ;Set trn_lvl = 0
	move    a,x:nl_supress            ;Set nl_supress = 0
	move    a,x:ec_frm_full           ;Set ec_frm_full = 0
	move    a,x:ener_rin_high         ;Set ener_rin_high = 0
	move    a,x:ec_frm_full           ;Set ec_frm_full =0
	move    a,x:ener_rin_high         ;ener_rin_high =  0
	move    a,x:ener_sin_high         ;ener_sin_high =  0
	move    a,x:ener_sout_high        ;ener_sout_high = 0 
	move    #$2000,x0                 ;2^(-18)in 1.31 format
	move    x0,x:ener_rin_low         ;ener_rin_low =  2^-18
	move    x0,x:ener_sin_low         ;ener_sin_low =  2^-18
	move    x0,x:ener_sout_low        ;ener_sout_low =  2^-18
	move    #$8000,x0           
	move    x0,x:mu_base              ;mu_base = 1 (in 1.15 format)
	move    #EC_FRMLEN,x0        
	move    x0,x:Frm_ctr              ;Frm_ctr = EC_FRMLEN
	
	move    #hfilt,x0                 ;Calling req. 4 for FIR
    add     x:Filt_Len,x0
	move    x0,r3
	move    r3,x:hfilt_p              ;Store filter coef pointer
	move    #f_stat,x0                ;Calling req. 4 for FIR   
    add     x:Filt_Len,x0
	move    x0,r0
	move    r0,x:fstat_p              ;Pointer initialisation for
					                  ; f_stat buffer
	move    #<1,x0
	move    x0,x:change_flag          ;Set change_flag = 1
	move    x0,x:g165_ec_enable       ;Set g165_ec_enable = 1   
_End_EC_INIT
	rts

    ENDSEC 


;****************************** End of File *******************************

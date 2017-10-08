;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_RESTART
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  11/11/97    0.0.1        Macro Created              Quay Cindy
;  20/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  Initialization of variables for EC modules.
;
;  Symbols Used    :
;       Frm_ctr            : Ctr for samples in a buffer
;       ec_frm_full        : Flag to indicate echo frame is full
;       dbl_tlk            : Flag to indicate the double talk
;       dont_adapt         : Flag to indicate don't adapt to echo-canceln
;       reset_coef         : Flag to reset coefficients
;       nl_supress         : Ctr for non-linear echo suppression
;       mu_base            : Base value of mu
;
;       g165_ton_disable1  : Disabler tone flag for rcv chnl.
;       g165_ton_disable2  : Disabler tone flag for snd chnl.
;       reset_tond1        : Tone detector reset for rcv chnl.
;       reset_tond2        : Tone detector reset for snd chnl.
;       
;       ener_rin           : Energy of samples from rcv chnl.
;       ener_sin           : Energy of input samples from snd chnl.
;       ener_sout          : Energy of output samples to snd chnl.
;
;  Functions Called    :
;
;       None
;
;**************************** Function Arguments **************************
;
;  None
;  
;************************* Calling Requirements ***************************
;
;  1. The Function EC_INIT should be called before the 1st call of this 
;     Function.
;     The constant and variable declarations are defined in
;     file ec_data.asm
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
;       g165_ton_disable1 = | 0000 0000  | 0000 000i |
;
;       g165_ton_disable2 = | 0000 0000  | 0000 000i |
;
;       dont_adapt        = | 0000 0000  | 0000 000i |
;
;       reset_coef        = | 0000 0000  | 0000 000i |
;
;       dbl_tlk           = | 0000 0000  | 0000 000i |
;
;       ener_rin_high     = | i.fff ffff | ffff ffff |
;
;       ener_rin_low      = | ffff ffff  | ffff ffff |
;
;       ener_sin_high     = | i.fff ffff | ffff ffff |
;
;       ener_sin_low      = | ffff ffff  | ffff ffff |
;
;       ener_sout_high    = | i.fff ffff | ffff ffff |
;
;       ener_sout_low     = | ffff ffff  | ffff ffff |
;
;       reset_tond1       = | 0000 0000  | 0000 000i |
;
;       reset_tond2       = | 0000 0000  | 0000 000i |
;
;       ec_frm_full       = | 0000 0000  | 0000 000i |
;
;       Frm_ctr           = | iiii iiii  | iiii iiii |
;
;       nl_supress        = | iiii iiii  | iiii iiii |
;
;       mu_base           = | f.fff ffff | ffff ffff |
;
;       trn_lvl           = | 0000 0000  | 0000 00ii |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 43
;                        Program Words : 43
;                        NLOAC         : 28
;
;  Address Registers Used:
;       None
;
;  Offset Registers Used:
;       None
;
;  Data Registers Used:
;                        a0   
;                        a1   
;                        a2   
;
;  Registers Changed:
;                        a0   
;                        a1   
;                        a2   
;
;
;***************************** Pseudo Code ********************************
;
;   Begin
;             ec_frm_full = 0;
;             dbl_tlk     = 0;
;             trn_lvl     = 0;
;             dont_adapt  = 0;
;             nl_supress  = 0;
;             g165_ton_disable1 = 0;
;             g165_ton_disable2 = 0;
;             reset_coef  = 1;
;             reset_tond1 = 1;
;             reset_tond2 = 1;
;             mu_base     = 1;
;             Frm_ctr = EC_FRMLEN;
;             ener_rin  = 2^(-18); % (in 1.31 format)
;             ener_sin  = 2^(-18);
;             ener_sout = 2^(-18);
;   End
;
;**************************** Assembly Code *******************************

	SECTION EC_CODE
	
	GLOBAL  EC_RESTART
	
    include "equates.asm"	

    org     p:

EC_RESTART

_Begin_EC_RESTART

        clr       a
        move      a1,x:ec_frm_full 
        move      a1,x:dbl_tlk 
        move      a1,x:trn_lvl 
        move      a1,x:nl_supress 
        move      a1,x:g165_tone_disable1 
        move      a1,x:g165_tone_disable2 
        move      a1,x:ec_frm_full 
        move      a1,x:dont_adapt
        move      #1,a0
        move      a0,x:reset_coef
        move      a0,x:reset_TD1
        move      a0,x:reset_TD2
        move      #EC_FRMLEN,a0
        move      a0,x:Frm_ctr
        move      #2000,a0 
        move      a1,x:ener_rin_high
        move      a0,x:ener_rin_low
        move      a1,x:ener_sin_high
        move      a0,x:ener_sin_low
        move      a1,x:ener_sout_high
        move      a0,x:ener_sout_low
           
_End_EC_RESTART
        rts

        ENDSEC 


;****************************** End of File *******************************

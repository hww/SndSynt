;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_DATA
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
;  Declaration of constants and variables for Echo Cancellation Modules
; 
;  Symbols Used :
;       sin_sample        : Sample from snd channal
;       rin_sample        : Sample from rcv channal
;       sout_sample       : Output sample to snd channel
;       g165_ec_enable    : Flag to enable or disable echo cancellation
;       hfilt[FILT_LEN+1] : Filter coefficients
;       hbak1[FILT_LEN+1] : First backup of filter coeff 
;       hbak2[FILT_LEN+1] : Second backup of filter coeff 
;       f_stat[FILT_LEN+1]: States of the filter
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
;       disable_TD        : Flag to disable tone detect logic (set by user)
;       inhibit_converge  : Flag to freeze adaptation (set by user)
;       EC_FRMLEN         : Frame length for echo canceller
;       NL_HANGOVER       : No of frames of delay before activating 
;                         :   non-linear supression
;       NL_ATTENUATION    : Non-linear attenuatation factor
;                           
;
;  Function called
;       None
;
;
;**************************** Function Arguments **************************
;
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
;       hfilt[k]          =   | s.fff ffff | ffff ffff | k =  0 to Filt_Len
;
;       hbak1[k]          =   | s.fff ffff | ffff ffff | k =  0 to Filt_Len
;
;       hbak2[k]          =   | s.fff ffff | ffff ffff | k =  0 to Filt_Len
;
;       f_stat[k]         =   | s.fff ffff | ffff ffff | k =  0 to Filt_Len
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
;       disable_TD        =   | 0000 0000  | 0000 000i |
;
;       inhibit_converge  =   | 0000 0000  | 0000 000i |
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 0
;                        Program Words : 0
;                        NLOAC         : 101
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
;       Begin
;         Declaration of constants
;         Declaration of variables
;       End
;
;**************************** Assembly Code *******************************

;Section EC_CONST contains the definition of all the constants used in the
;in the EC thread

	SECTION EC_CONST 
	
    GLOBAL  FILT_LEN,LEN_RATIO,EC_FRMLEN 
    GLOBAL  NL_HANGOVER,NL_ATTENUATION,ECHOSPAN,EC_MODE
    GLOBAL  pow2tab
    GLOBAL  EchoSpan,Filt_Len,Len_ratio
        

_Begin_EC_CONST
	
    org     x:

ECHOSPAN		equ			 320
Len_ratio       dc          $7fff
                dupf        i,41,320
                dc          40.0/@CVF(i)
                endm
                 
   include "equates.asm"
   
pow2tab         dc           $8000,$4000,$2000,$1000  
  	            dc           $0800,$0400,$0200,$0100
		        dc           $0080,$0040,$0020,$0010
	            dc           $0008,$0004,$0002

EchoSpan        ds           1
Filt_Len        ds           1	            

_End_EC_CONST
   
   ENDSEC 

;Section EC_VAR contains the definition of all the constants used in the
;in the EC thread


	SECTION EC_VAR
	
    GLOBAL  ec_frm_full,disable_TD,reset_coef,inhibit_converge,nl_option
    GLOBAL  sout_sample,dont_adapt,g165_ec_enable 
        
;Converted XDEF's to GLOBAL
	
    GLOBAL  f_stat,hfilt,hbak1,hbak2
    GLOBAL  len_factor
    GLOBAL  dbl_tlk,trn_lvl
	GLOBAL  nl_supress,Frm_ctr
   	GLOBAL  ener_sout_high,ener_sout_low
    GLOBAL  mu_base,mu
	GLOBAL  fstat_p,hfilt_p,hbak1_p,hbak2_p
    GLOBAL  change_flag
    GLOBAL  temp_status
	GLOBAL  ener_rin_high,ener_rin_low,ener_sin_high,ener_sin_low
    GLOBAL  rin_sample,sin_sample
    GLOBAL  reset_TD1,reset_TD2
    GLOBAL  g165_tone_disable1,g165_tone_disable2


_Begin_EC_VAR

    org     x:

f_stat               dsm          ECHOSPAN          
hfilt                dsm          ECHOSPAN          
hbak1                ds           ECHOSPAN          
hbak2                ds           ECHOSPAN          
disable_TD           ds           1
inhibit_converge     ds           1
len_factor           ds           1
dbl_tlk              ds           1                   
dont_adapt           ds           1                   
trn_lvl              ds           1                   
reset_coef           ds           1                   
nl_option            ds           1                   
nl_supress           ds           1                   
Frm_ctr              ds           1    
ener_rin_high        ds           1                   
ener_rin_low         ds           1                   
ener_sin_high        ds           1                   
ener_sin_low         ds           1                   
rin_sample           ds           1                       
sin_sample           ds           1                   
reset_TD1            ds           1
reset_TD2            ds           1
g165_tone_disable1   ds           1
g165_tone_disable2   ds           1

ener_sout_high       ds           1                   
ener_sout_low        ds           1                   
mu_base              ds           1                   
mu                   ds           1                   
g165_ec_enable       ds           1                   
sout_sample          ds           1                   
fstat_p              ds           1
hfilt_p              ds           1
hbak1_p              ds           1
hbak2_p              ds           1
change_flag          ds           1
ec_frm_full          ds           1

_End_EC_VAR
   
   
    ENDSEC 

;****************************** End of File *******************************

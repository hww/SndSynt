;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Module ************************************
;
;  Project ID     : G165EC
;  Module Name    : EC_FUNC
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  11/11/97     0.0.1       Module Created             Quay Cindy
;  21/11/97     1.0.0       Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Module Description ***************************
;
;  Contains all the subroutines for the Echo Cancellation thread:
;                    EC_INIT_subroutine
;                    EC_SAMP_PRO_subroutine
;                    EC_FRM_PRO_subroutine  
;                    EC_RESTART_subroutine
; 
;  Symbols Used :
;
;  Functions Called :
;       EC_INIT        : Initializes variables for Echo Cancellation
;       EC_SAMP_PRO    : Sample processing for Echo Cancellation
;       EC_FRM_PRO     : Frame processing for Echo Cancellation
;       EC_RESTART     : Re-initializes variables
;
;  Note:  The constant and variable declarations for this module are defined
;         in the ec_data.asm file
;
;**************************** Module Arguments *****************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. At least 2 locations should be available in the software stack:
;          Subroutine               Stacks required
;         ------------              ---------------
;         EC_INIT_subroutine     :       2
;         EC_FRM_PRO_subroutine  :       2
;         EC_SAMP_PRO_subroutine :       2
;         EC_RESTART_subroutine  :       2
;
;************************** Input and Output ******************************
;
;  Input  :
;       None
;
;  Output :
;       None
;
;************************* Globals and Statics ****************************
;
;  Globals  :
;       EC_INIT_subroutine     = | iiii iiii | iiii iiii |
;
;       EC_SAMP_PRO_subroutine = | iiii iiii | iiii iiii |
;
;       EC_FRM_PRO_subroutine  = | iiii iiii | iiii iiii |
;
;       EC_RESTART_subroutine  = | iiii iiii | iiii iiii |
;
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;              Icycle Count  : 
;                   EC_INIT_subroutine     :(4*ECHOSPAN) + 9
;                   EC_FRM_PRO_subroutine  :(3*ECHOSPAN) + 71 (max)
;                   EC_SAMP_PRO_subroutine :(4*ECHOSPAN) + 210
;                   EC_RESTART_subroutine  :52
;         
;              Program Words : 
;                   EC_INIT_subroutine     :83       
;                   EC_FRM_PRO_subroutine  :116
;                   EC_SAMP_PRO_subroutine :193
;                   EC_RESTART_subroutine  :44
;
;              NLOAC                       :34
;
;  Address Registers used:
;                        r0 
;                        r1 
;                        r2 
;                        r3 
;
;  Offset Registers used:
;                        n
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;  Registers Changed:
;                        r0  m01  n  a0  b0  x0  y0  sr
;                        r1          a1  b1      y1  pc
;                        r2          a2  b2
;                        r3
;
;***************************** Pseudo Code ********************************
;
;       Begin
;
;         Define EC_INIT_subroutine;
;
;         Define EC_SAMP_PRO_subroutine;
;
;         Define EC_FRM_PRO_subroutine;
;
;         Define EC_RESTART_subroutine;
;
;
;       End
;
;**************************** Assembly Code *******************************

	    SECTION  EC_CODE 
	        
   	    GLOBAL  EC_SAMP_PRO_subroutine
  	    GLOBAL  EC_FRM_PRO_subroutine
    	GLOBAL  EC_RESTART_subroutine
		GLOBAL  FILT_LEN,LEN_RATIO,EC_FRMLEN 
        GLOBAL  NL_HANGOVER,NL_ATTENUATION
        GLOBAL  pow2tab
		GLOBAL	f_stat,hfilt,hbak1,hbak2
        GLOBAL  len_factor,
        GLOBAL  dbl_tlk,dont_adapt,trn_lvl
		GLOBAL  nl_supress,Frm_ctr
   		GLOBAL  ener_sout_high,ener_sout_low
        GLOBAL  mu_base,mu
		GLOBAL  g165_ec_enable
		GLOBAL	fstat_p,hfilt_p,hbak1_p,hbak2_p
        GLOBAL  change_flag
		GLOBAL  ener_rin_high,ener_rin_low,ener_sin_high,ener_sin_low
        GLOBAL  rin_sample,sin_sample
        GLOBAL  reset_TD1,reset_TD2
        GLOBAL	g165_tone_disable1,g165_tone_disable2


        org     p:
        
EC_SAMP_PRO_subroutine
        jsr   EC_SAMP_PRO                 ;Sample processing
        rts

        org      p:
        
EC_FRM_PRO_subroutine
        jsr   EC_FRM_PRO                  ;Frame processing
        rts

        org      p:
        
EC_RESTART_subroutine
        jsr   EC_RESTART                  ;Re-initialization
        rts

        ENDSEC

	    SECTION  EC_INIT_CODE
 	    GLOBAL   EC_INIT_subroutine
 	    GLOBAL   FEC_INIT_subroutine
 	        

        org      p:
        
FEC_INIT_subroutine
EC_INIT_subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Modified according the C Calling conventions for passing g165_sInit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        move    x:(r2)+,x0
        move    x0,x:nl_option
        move    x:(r2)+,x0
        move    x0,x:Disable_TD
        move    x:(r2)+,x0
        move    x0,x:inhibit_converge
        move    x:(r2)+,x0
        move    x0,x:reset_coef
        move    x:(r2),x0
        move    x0,x:EchoSpan
        move    x0,y0
        decw    x0
        move    #Len_ratio,r2
        sub     #40,y0
        move    y0,n
        move    x0,x:Filt_Len
        move    x:(r2+n),x0
        move    x0,x:len_factor     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        jsr     EC_INIT                           ;Initialization
        rts

        ENDSEC


;****************************** End of File *******************************

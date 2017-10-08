;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_SAMP_PRO
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  5/11/97     0.0.1        Macro created              Quay Cindy
;  20/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  To perform echo cancellation on the received sample
; 
;  Symbols Used :
;       sin_sample      : Input sample from snd channel
;       rin_sample      : Input sample from rcv channel
;       sout_sample     : Output sample to snd channel
;       ener_rin_low    : LSW of ener_rin (energy of input rcv samps)
;       ener_rin_high   : MSW of ener_rin
;       ener_sin_low    : LSW of ener_sin (energy of input snd samps)
;       ener_sin_high   : MSW of ener_sin
;       ener_sout_low   : LSW of ener_sout (energy of output snd samps)
;       ener_sout_high  : MSW of ener_sout
;       dbl_tlk         : Double talk detection flag
;       trn_lvl         : Level of training
;       nl_supress      : Non - linear supression counter
;       Frm_ctr         : Sample count in a Frame
;       dont_adapt      : Flag to freeze adaptation
;       mu              : Adaptation constant
;       len_factor      : Filter length factor adjustment
;       change_flag     : Flag to indicate change in the coefficients
;       NL_HANGOVER     : No of frames of delay before activating 
;                         non-linear supression
;       NL_ATTENUATION  : Non-linear attenuatation factor
;       EC_FRMLEN       : Frame length for echo canceller
;       ec_frm_full     : Flag to indicate, echo-canceller frame is full
;  
;  Function Called :
;       EC_ENER         : Computes the energy of the input sample
;       EC_SET_MU       : Sets the value of mu
;       EC_FIR          : Does filtering for echo-cancellation
;       EC_ADAPT        : Does adaptation of echo-cancellor filter 
;                         coefficients
;
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. EC_INIT should be called before the 1st call of this function
;     The constant and variable declarations are defined in
;     file ec_data.asm
;  2. m01 = $ffff and n = 0
;  3. Hardware looping resources including LA, LC and 1 location
;     of HWS must be available for use.
;  4. EC_VAR_INT_XRAM should be defined before the call of this function
;
;************************** Input and Output ******************************
;
;  Input  :
;       sin_sample       = | s.fff ffff | ffff ffff |  in x:sin_sample
;
;       rin_sample.      = | s.fff ffff | ffff ffff |  in x:rin_sample
;
;  Output :
;       sout_sample      = | s.fff ffff | ffff ffff |  in x:sout_sample
;
;  Update :
;
;************************* Globals and Statics ****************************
;
;       ener_rin         = | s.fff ffff | ffff ffff |
;
;       ener_sin         = | s.fff ffff | ffff ffff |
;
;       ener_sout        = | s.fff ffff | ffff ffff |
;
;       dbl_tlk          = | 0000 0000  | 0000 000i |
;
;       trn_lvl          = | 0000 0000  | 0000 000i |
;
;       nl_supress       = | 0000 0000  | 0000 000i |
;
;       Frm_ctr          = | 0000 000i  | iiii iiii |
;
;       dont_adapt       = | 0000 0000  | 0000 000i |
;
;       ener_rin_high    = | i.fff ffff | ffff ffff | 
;
;       ener_rin_low     = | ffff ffff  | ffff ffff |
;
;       ener_sin_high    = | i.fff ffff | ffff ffff | 
;
;       ener_sin_low     = | ffff ffff  | ffff ffff |
;
;       ener_sout_high   = | i.fff ffff | ffff ffff | 
;
;       ener_sout_low    = | ffff ffff  | ffff ffff |
;
;       mu               = | iiii iiii  | iiii iiii |
;
;       len_factor       = | i.fff ffff | ffff ffff |   
;
;       change_flag      = | 0000 0000  | 0000 000i |
;
;       ec_frm_full      = | 0000 0000  | 0000 000i |
;
;  Statics :
;       None
;
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 4*ECHOSPAN + 201
;                        Program Words : 192
;                        NLOAC         : 73
;
;  Address Registers Used:
;                        r0 
;                        r1
;                        r3
;
;  Offset Registers Used:
;                        n  
;
;  Data Registers Used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  n  a0  b0  x0  y0  sr
;                        r1     a1  b1      y1  pc
;                        r3     a2  b2  
;
;
;***************************** Pseudo Code ********************************
;
;       Begin
;            % Compute energies of rin and sin channels %
;            ener_sin = Ener_compute(ener_sin, sin_sample);
;            ener_rin = Ener_compute(ener_rin, rin_sample);
;
;            % Check Double talk flag %
;            If ( (trn_lvl == 0) & (ener_sout > (ener_rin/2) )
;                dbl_tlk = 1;
;                nl_supress = 0;
;            Else If ( (trn_lvl == 1) & (ener_sout > (ener_rin/8) )
;                dbl_tlk = 1;
;                nl_supress = 0;
;            Endif
;
;            % Estimate mu vlaue %
;            If ( (dbl_tlk == 1) | (dont_adapt == 1) )
;                mu = 0;
;            Else
;                mu = Set_mu_value();
;            Endif
;
;            % Estimate and cancel the echo %
;            echo_estimate = Filtering(rin_sample); 
;            sout_sample = sin_sample - echo_estimate;
;
;            % Compute energies of sout channels % 
;            ener_sout = Ener_compute(ener_sout, sout_sample);
; 
;            % Coefficient Adaptation if appropriate flags are set % 
;            If ( (dont_adapt == 0) & (dbl_tlk == 0) )
;                Call Adapt_coefficients(mu,sout_sample);
;                change_flag = 1
;            Endif 
;
;            % Check for non-linear supression % 
;            If (nl_supress != NL_HANGOVER)
;                sout_smpl = sout_sample;
;            Else
;                sout_smpl = sout_sample*NL_ATTENUATION;
;            Endif
;
;            % Check end-of-frame %
;            Frm_ctr = Frm_ctr - 1;
;            If ( Frm_ctr == 0 ),
;                Frm_ctr = EC_FRMLEN;
;                ec_frm_full = 1;
;            Endif
;        End
;
;**************************** Assembly Code *******************************
	
	SECTION EC_CODE

    GLOBAL  EC_SAMP_PRO
 
    include "equates.asm" 
    
    org     p:

EC_SAMP_PRO

_Begin_EC_SAMP_PRO

	move    #ener_sin_high,r1         ;Calling requirement for EC_ENER
	move    x:sin_sample,y0           ;Input echo sample for computing 
					                  ;  energy
	jsr     EC_ENER                   ;Ener_compute(ener_sin,sin_sample)
	move    #ener_rin_high,r1         ;Calling requirement for EC_ENER
	move    x:rin_sample,y0           ;Input received sample for 
					                  ;  computing energy
	jsr     EC_ENER                   ;Ener_compute(ener_rin,rin_sample)
	move    x:ener_sout_high,b        ;Get energy of echo residue 
	move    x:ener_sout_low,b0        ;  (ener_sout)
	asr     a                         ;Compute ener_rin/2
	cmp     a,b                       ;Compare ener_sout and ener_rin/2
	bgt     <_setflags                ;Branch if ener_sout > ener_rin/2
	asr     a                         ;Compute ener_rin/8
	asr     a                         
	cmp     a,b                       ;Compare ener_sout and ener_rin/8
	blt     <_nosetflags              ;Branch if ener_sout < ener_rin/8
	tstw    x:trn_lvl                 ;Test  trv_lvl flag for zero
	
	beq     <_nosetflags              ;Branch if trn_lvl = 0
_setflags
	move    #<1,x:dbl_tlk             ;Set dbl_tlk flag to one 
	move    #<0,x:nl_supress          ;Set nl_supress flag to zero

_nosetflags
	move    #<0,x:mu                  ;Set mu = 0
	move    x:dbl_tlk,y1              
	move    x:dont_adapt,a            
	or      y1,a                      ;Check dbl_tlk = 0 | dont_adapt = 0
	bne     <_skipsetmu               ;No setting of mu if dbl_tlk or
					  				  ;  dont_adapt is equal to 1
	jsr     EC_SET_MU                 ;Call function EC_SET_MU

_skipsetmu        

    move    x:Filt_Len,a
    neg     a
    move    a1,n
	move    #$8000,y0
    add     x:Filt_Len,y0
	move    y0,m01  
	move    x:rin_sample,y0
	move    x:fstat_p,r0
	move    x:hfilt_p,r3              ;Calling requirement for EC_FIR
	jsr	    EC_FIR		       	      ;Filtering(rin_sample)
	move    x:sin_sample,b            ;Get simulated echo sample
	sub     a,b                       ;Simulated echo - EC filter
	move    b1,x:sout_sample          ;Store echo residue to send out
					                  ;  after non-linear supression
	move    r0,x:fstat_p

	move    #$ffff,m01
    move    #0,n

	move    #ener_sout_high,r1        ;Calling requirement 3 for EC_ENER
	move    b1,y0                     ;Get sout_sample for energy 
					                  ;  computation as input to EC_ENER

	jsr     EC_ENER                   ;Compute energy of echo residue 
	move    x:dont_adapt,a1           ;Check if dbl_tlk = 0
	move    x:dbl_tlk,a0              ;  and dont_adapt = 0
	tst     a                                    
	bne     <_noadapt                 ;No adaptation if dbl_tlk = 0 and 
					                  ;  dont_adapt = 0

	move    #$8000,y0
    add     x:Filt_Len,y0
	move    y0,m01  
	move    x:sout_sample,x0
	
	move    #hfilt,y0
    add     x:Filt_Len,y0
	move    y0,r1
	move    x:mu,y1                   ;Calling requirement for EC_ADAPT
	move    x:len_factor,y0           ;Calling requirement for EC_ADAPT
	jsr     EC_ADAPT                  ;Call EC_ADAPT
	move    #<1,x:change_flag         ;change_flag = 1
	
	move    #$ffff,m01 
	
_noadapt
	move    x:nl_supress,a            ;Checking nl_supress 
                                      ;  with NL_HANGOVER
	cmp     #NL_HANGOVER,a            ;Compare nl_supress and NL_HANGOVER
	bne     <_sendsample              ;Branch if nl_supress !=NL_HANGOVER
	move    #NL_ATTENUATION,y1        ;Compute
	move    x:sout_sample,y0          ;  sout_sample * NL_ATTENUATION
	mpyr    y1,y0,a                   
	move    a,x:sout_sample           ;Store back sout_sample to be 
_sendsample
	decw    x:Frm_ctr                 ;Frm_ctr = Frm_ctr - 1
	bne     <_End_EC_SAMP_PRO         ;If Frm_ctr == 0 
	move    #<1,x:ec_frm_full         ;Set ec_frm_full flag
	move    #EC_FRMLEN,x:Frm_ctr      ;Frm_ctr = EC_FRMLEN
_End_EC_SAMP_PRO

    rts

	ENDSEC  
;****************************** End of File *******************************

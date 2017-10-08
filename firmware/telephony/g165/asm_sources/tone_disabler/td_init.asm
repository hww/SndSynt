;**************************************************************************
;
;  (C) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Function Name  : TD_INIT
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver     Description                Author
;  --------     --------     -----------                ------
;  3/11/97      0.0.1        Macro Created              Qiu Lunji
;  19/11/97     1.0.0        Reviewed and Modified      Qiu Lunji
;  10/07/00     1.0.1        Converted macros to        Sandeep Sehgal
;                            functions    
;
;*************************** Function Description *************************
;  Initilization of variables for tone detection.
;  All the variables ending with 1 represents receive (rcv) channel
;  All the variables ending with 2 represents send (snd) channel
;
;  Symbols Used    :
;       tone_count1         : Sample counter for the valid tone in rcv channel
;       tone_count2         : Sample counter for the valid tone in snd channel
;       dont_adapt1         : Flag to freeze G.165 echo-canceller in rcv channel
;       dont_adapt2         : Flag to freeze G.165 echo-canceller in snd channel
;       g165_tone_disable1  : Flag to disable G.165 echo-canceller in rcv channel
;       g165_tone_disable2  : Flag to disable G.165 echo-canceller in snd channel
;       tone_pass_count1    : Block counter to count number of vaild tone
;                               passes (in accordance with Req B.1-B.3) in rcv chn
;       tone_pass_count2    : Block counter to count number of vaild tone
;                               passes (in accordance with Req B.1-B.3) in snd chn
;       state_TD1           : State of the tone detector for rcv chn
;       state_TD2           : State of the tone detector for snd chn
;       reset_TD1           : Flag to reset tone detector in rcv chn
;       reset_TD2           : Flag to reset tone detector in snd chn
;       TD_frm_energy1_high : MSW of 19-point frame energy for rcv chnnel
;       TD_frm_energy1_low  : LSW of 19-point frame energy for rcv chnnel
;       TD_frm_energy2_high : MSW of 19-point frame energy for snd chn
;       TD_frm_energy2_low  : LSW of 19-point frame energy for snd chn
;       goertzel_count1     : Counter for goertzel algorithn, from 0 to 19
;       goertzel_count2     : Counter for goertzel algorithn, from 0 to 19
;       goertzel1[2]        ; States used in Goertzel algorithm
;       goertzel2[2]        ; States used in Goertzel algorithm
;       ave_TD_tone1_high   ; MSW of average tone (2100 Hz) energy
;       ave_TD_tone1_low    ; LSW of average tone (2100 Hz) energy
;       ave_TD_tone2_high   ; MSW of average tone (2100 Hz) energy
;       ave_TD_tone2_low    ; LSW of average tone (2100 Hz) energy
;       ave_TD_noise1_high  : MSW of average noise energy
;       ave_TD_noise1_low   : LSW of average noise energy
;       ave_TD_noise2_high  : MSW of average noise energy
;       ave_TD_noise2_low   : LSW of average noise energy
;       TD_TONE_THRES       : Tone threshold constant for Req B.1-B.2
;       TD_SNR_THRES        : SNR threshold constant for Req B.3
;       ph_rev_flag1        : Flag for phase reversal detection in rcv
;       ph_rev_flag2        :   and snd channels
;       ph_rev_inst1        : Instance of detection of phase reversal
;       ph_rev_inst2        :   for rcv and snd channels
;       ph_rev_inst11       : Instant of 1st phase reversal for rcv
;       ph_rev_inst12       :   and snd channels
;       ph_rev_inst21       : Instant of 2nd phase reversal for rcv
;       ph_rev_inst22       :   and snd channels
;       ph_rev_amp1         : No. of "good" zero-crossing detected which 
;                               indicated presence of a phase reversal between
;                               them for rcv chn                             
;       ph_rev_amp2         :   and snd chn
;       ph_rev_amp11        : No. of "good" zero-crossing detected which 
;                               indicated presence of a phase reversal between
;                               them at first phase reversal for rcv chn                             
;       ph_rev_amp12        :   and snd chn
;       ph_rev_amp21        : No. of "good" zero-crossing detected which 
;                               indicated presence of a phase reversal between
;                               them at second phase reversal for rcv chn                             
;       ph_rev_amp22        :   and snd chn
;       alp_states1[3]      : All-pole states for LPF for chn 1 and
;       alp_states2[3]      :   chn. 2
;       blp_states1[3]      : All-zero states for LPF for rcv and
;       blp_states2[3]      :   snd channels
;       alp_states1_p       : Pointer to alp_stat1 array
;       alp_states2_p       : Pointer to alp_stat2 array
;       alp_states1_p       : Pointer to alp_stat1 array
;       alp_states2_p       : Pointer to alp_stat2 array
;       lp_coef[7]          : Normalised coeffs for LPF
;       sine_p1             : Pointer for sine table (freq 2000 Hz) in rcv.
;       sine_p2             : Pointer for sine table (freq 2000 Hz) in snd
;       g165_ton_disable1   : Flag to disable G.165 echo-cancellor in rcv chn
;       g165_ton_disable2   : Flag to disable G.165 echo-cancellor in snd chn
;       sin_sample          : Sample for snd channal
;       rin_sample          : Sample from rcv channal
;       zero_cross1         : Flag to indicate zero crossing  has occured in
;       zero_cross2         :   rcv and snd chanels
;       hf_period1          : Half period of the modulated tone
;       hf_period2          :   in rcv. and snd. chanels
;       sum_hf_period1      : Sum of valid half period samples
;       sum_hf_period2      :   in rcv. and snd channels
;       num_hf_period1      : Number of valid half periods
;       num_hf_period2      :   in rcv. and snd chanals
;       first_zc_flag1      : First zero crossings indication flag
;       first_zc_flag2      :   in rcv. and snd channels
;       count1              : Counter for counting number of samples
;                              between two zero-crossings in rcv.
;       count2              :   and snd chanals respectively
;       zc_amps1[6]         : Stack of six "good" zero crossings distances
;       zc_amps2[6]         :   in rcv and snd chanals
;       zc_amps1_p          : Pointer to zc_amps1 array
;       zc_amps2_p          : Pointer to zc_amps2 array
;       sum_zc1             : Distance between 1st and 6th "good"
;                              zero crossings in rcv. chn and
;       sum_zc2             :   snd chn.
;       fcount1             : Counter for number of samples between
;                              two zero crossings in rcv. and snd.
;       fcount2             :   channels
;       zc_count1           : Count for number of samples between
;                              two good zero crossings (modulo period)
;       zc_count2           :   in recv. and snd channels.
;       factors[15]         : Array to store 1/8 to 1/22 in 1.15 format
;       sine_2000           : Sine - Table entries for 2000 Hz
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
;  None
;
;************************** Input and Output ******************************
;
;  Input   :
;       None
;
;  Output  :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals :
;
;       tone_count1        = | 0000 0000  | 0000 000i |
;
;       tone_count2        = | 0000 0000  | 0000 000i |
;
;       dont_adapt1        = | 0000 0000  | 0000 000i |
;
;       dont_adapt2        = | 0000 0000  | 0000 000i |
;
;       g165_ton_disable1  = | 0000 0000  | 0000 000i |
;
;       g165_ton_disable2  = | 0000 0000  | 0000 000i |
;
;       tone_pass_count1   = |  iiii iiii | iiii iiii |
;
;       tone_pass_count2   = |  iiii iiii | iiii iiii |
;
;       state_TD1          = | 0000 0000  | 0000 000i |
;
;       state_TD2          = | 0000 0000  | 0000 000i |
;
;       reset_TD1          = | 0000 0000  | 0000 000i |
;
;       reset_TD2          = | 0000 0000  | 0000 000i |
;
;  The following variables must be declared consecutively in the
;  following order from lower to higher memory:
;
;       TD_frm_energy1_high = | i.fff ffff | ffff ffff |
;
;       TD_frm_energy1_low  = |  ffff ffff | ffff ffff |
;
;       goertzel_count1     = |  0000 0000 | 000i iiii |
;
;       goertzel1(k)        = | i.fff ffff | ffff ffff |  for k=1 to 2
;
;       TD_ave_tone1_high   = | i.fff ffff | ffff ffff |
;
;       TD_ave_tone1_low    = |  ffff ffff | ffff ffff |
;
;       TD_ave_noise1_high  = | i.fff ffff | ffff ffff |
;
;       TD_ave_noise1_low   = |  ffff ffff | ffff ffff |
;
;  The following variables (up to TD_frm_energy2_low) must be declared 
;  consecutively in the following order from lower to higher memory:
;
;       TD_frm_energy2_high = | i.fff ffff | ffff ffff |
;
;       TD_frm_energy2_low  = |  ffff ffff | ffff ffff |
;
;       goertzel_count2     = |  0000 0000 | 000i iiii |
;
;       goertzel2(k)        = | i.fff ffff | ffff ffff |  for k=1 to 2
;
;       TD_ave_tone2_high   = | i.fff ffff | ffff ffff |
;
;       TD_ave_tone2_low    = |  ffff ffff | ffff ffff |
;
;       TD_ave_noise2_high  = | i.fff ffff | ffff ffff |
;
;       TD_ave_noise2_low   = |  ffff ffff | ffff ffff |
;
;       ph_rev_flag1        = | 0000 0000  | 0000 000i |
;
;       ph_rev_flag2        = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst1        = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst2        = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst11       = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst21       = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst12       = | 0000 0000  | 0000 000i |
;
;       ph_rev_inst22       = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp1         = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp2         = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp11        = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp21        = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp12        = | 0000 0000  | 0000 000i |
;
;       ph_rev_amp22        = | 0000 0000  | 0000 000i |
;
;       fcount1             = |  iiii iiii | iiii.ffff |
;
;       fcount2             = |  iiii iiii | iiii.ffff |
;
;       hf_period1          = |  iiii iiii | iiii.ffff |
;
;       hf_period2          = |  iiii iiii | iiii.ffff |
;
;       sum_hf_period1      = |  iiii iiii | iiii iiii |
;
;       sum_hf_period2      = |  iiii iiii | iiii iiii |
;
;       num_hf_period1      = |  iiii iiii | iiii iiii |
;
;       num_hf_period2      = |  iiii iiii | iiii iiii |
;
;       first_zc_flag1      = | 0000 0000  | 0000 000i |
;
;       first_zc_flag2      = | 0000 0000  | 0000 000i |
;
;       zero_cross1         = | 0000 0000  | 0000 000i |
;
;       zero_cross2         = | 0000 0000  | 0000 000i |
;
;       count1              = | iiii iiii  | iiii iiii |
;
;       count2              = | iiii iiii  | iiii iiii |
;
;       zc_count1           = | iiii iiii  | iiii iiii |
;
;       zc_count2           = | iiii iiii  | iiii iiii |
;
;       sum_zc1             = | iiii iiii  | iiii.ffff |
;
;       sum_zc2             = | iiii iiii  | iiii.ffff |
;
;       zc_amps1_p          = | iiii iiii  | iiii iiii |
;
;       zc_amps2_p          = | iiii iiii  | iiii iiii |
;
;       abp_states1_p       = | iiii iiii  | iiii iiii |
;
;       abp_states2_p       = | iiii iiii  | iiii iiii |
;
;       abp_states1_p       = | iiii iiii  | iiii iiii |
;
;       abp_states2_p       = | iiii iiii  | iiii iiii |
;
;       alp_states1_p       = | iiii iiii  | iiii iiii |
;
;       alp_states2_p       = | iiii iiii  | iiii iiii |
;
;       alp_states1_p       = | iiii iiii  | iiii iiii |
;
;       alp_states2_p       = | iiii iiii  | iiii iiii |
;       
;       sine_p1             = | iiii iiii  | iiii iiii |
;
;       sine_p2             = | iiii iiii  | iiii iiii |
;
;  Statics  :
;
;       alp_states2[k]      = | s.fff ffff | ffff ffff | for k = 0 to 2
;
;       blp_states2[k]      = | s.fff ffff | ffff ffff | for k = 0 to 2
;
;       lp_coef[k]          = | s.fff ffff | ffff ffff | for k = 0 to 7
;
;       factors[k]          = | s.fff ffff | ffff ffff | for k = 0 to 14
;
;       zc_amps1[k]         = | s.fff ffff | ffff ffff | for k = 0 to 5
;
;       zc_amps2[k]         = | s.fff ffff | ffff ffff | for k = 0 to 5
;
;       sine_2000[k]        = | iiii iiii  | iiii iiii | for k = 0 to 3
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 181
;                        Program Words : 163
;                        NLOAC         : 171
;
;  Address Registers used:
;                        None
;
;  Offset Registers used:
;                        None
;
;  Data Registers used:
;                        None
;
;  Registers Changed:
;                        None
;
;***************************** Pseudo Code ********************************
;
;        Begin
;               tone_count1        = 0
;               tone_count2        = 0
;               dont_adapt1        = 0
;               dont_adapt2        = 0
;               g165_ton_disable1  = 0
;               g165_ton_disable2  = 0
;               tone_pass_count1   = 0
;               tone_pass_count2   = 0
;               state_TD1          = 0
;               state_TD2          = 0
;               reset_TD1          = 0
;               reset_TD2          = 0
;               goertzel_count1    = 0
;               goertzel1(1)       = 0
;               goertzel1(2)       = 0
;               TD_frm_energy1_high= 0
;               TD_frm_energy1_low = 0
;               ave_TD_tone1_high  = MSW of TD_TONE_THRES
;               ave_TD_tone1_low   = LSW of TD_TONE_THRES
;               ave_TD_noise1_high = MSW of TD_TONE_THRES/TD_SNR_THRES
;               ave_TD_noise1_low  = LSW of TD_TONE_THRES/TD_SNR_THRES
;               goertzel_count2    = 0
;               goertzel2(1)       = 0
;               goertzel2(2)       = 0
;               TD_frm_energy2_high= 0
;               TD_frm_energy2_low = 0
;               ave_TD_tone2_high  = MSW of TD_TONE_THRES
;               ave_TD_tone2_low   = LSW of TD_TONE_THRES
;               ave_TD_noise2_high = MSW of TD_TONE_THRES/TD_SNR_THRES
;               ave_TD_noise2_low  = LSW of TD_TONE_THRES/TD_SNR_THRES
;               ph_rev_flag1       = 0
;               ph_rev_flag2       = 0
;               ph_rev_inst1       = 0
;               ph_rev_inst2       = 0
;               ph_rev_inst11      = 0
;               ph_rev_inst21      = 0
;               ph_rev_inst12      = 0
;               ph_rev_inst22      = 0
;               ph_rev_amp1        = 0
;               ph_rev_amp11       = 0
;               ph_rev_amp21       = 0
;               first_zc_flag1     = 0
;               count1             = 0
;               ph_rev_amp2        = 0
;               ph_rev_amp12       = 0
;               ph_rev_amp22       = 0
;               first_zc_flag2     = 0
;               count2             = 0
;               zero_cross1        = 0
;               zero_cross2        = 0
;               hf_period1         = 0
;               num_hf_period1     = 0
;               sum_hf_period1     = 0
;               hf_period_lim1     = 0
;               fcount1            = 0
;               hf_period2         = 0
;               num_hf_period2     = 0
;               sum_hf_period2     = 0
;               hf_period_lim2     = 0
;               fcount2            = 0
;               zc_count1          = 0
;               zc_count2          = 0
;               sum_zc1            = 0
;               sum_zc2            = 0
;
;               reset_TD1          = 1
;               reset_TD2          = 1
;
;               sine_p1            = 0
;               sin_p2             = 0
;
;             % Arrys initialised to zero
;               alp_states1        = zeros(3,1)
;               blp_states1        = zeros(3,1)
;               alp_states2        = zeros(3,1)
;               blp_states2        = zeros(3,1)
;
;        End
;
;**************************** Assembly Code *******************************


;Section TD_VAR contains the declaration of all the variables used in
; tone detection

	SECTION TD_INIT_CODE
	
	GLOBAL    TD_TONE_THRES
	GLOBAL    TD_SNR_THRES
	GLOBAL    lp_coef
	GLOBAL    sine_2000

	GLOBAL    tone_count1
	GLOBAL    tone_count2
	GLOBAL    state_TD1
	GLOBAL    state_TD2
	GLOBAL    TD_frm_energy1_high
	GLOBAL    TD_frm_energy1_low
	GLOBAL    goertzel_count1
	GLOBAL    goertzel1
	GLOBAL    ave_TD_tone1_high
	GLOBAL    ave_TD_tone1_low
	GLOBAL    ave_TD_noise1_high
	GLOBAL    ave_TD_noise1_low
	GLOBAL    tone_pass_count1
	GLOBAL    TD_frm_energy2_high
	GLOBAL    TD_frm_energy2_low
	GLOBAL    goertzel_count2
	GLOBAL    goertzel2
	GLOBAL    ave_TD_tone2_high
	GLOBAL    ave_TD_tone2_low
	GLOBAL    ave_TD_noise2_high
	GLOBAL    ave_TD_noise2_low
	GLOBAL    tone_pass_count2
	GLOBAL    ph_rev_amp1
	GLOBAL    ph_rev_inst1
	GLOBAL    ph_rev_amp11
	GLOBAL    ph_rev_amp12
	GLOBAL    ph_rev_flag1
	GLOBAL    ph_rev_inst11
	GLOBAL    ph_rev_inst12
	GLOBAL    first_zc_flag1
	GLOBAL    count1
	GLOBAL    ph_rev_amp2
	GLOBAL    ph_rev_inst2
	GLOBAL    ph_rev_amp21
	GLOBAL    ph_rev_amp22
	GLOBAL    ph_rev_flag2
	GLOBAL    ph_rev_inst21
	GLOBAL    ph_rev_inst22
	GLOBAL    first_zc_flag2
	GLOBAL    count2
	GLOBAL    zero_cross1
	GLOBAL    zero_cross2
	GLOBAL    hf_period1
	GLOBAL    hf_period2
	GLOBAL    num_hf_period1
	GLOBAL    sum_hf_period1
	GLOBAL    num_hf_period2
	GLOBAL    sum_hf_period2
	GLOBAL    hf_period_lim1
	GLOBAL    hf_period_lim2
	GLOBAL    fcount1
	GLOBAL    fcount2
	GLOBAL    zc_count1
	GLOBAL    zc_count2
	GLOBAL    sum_zc1
	GLOBAL    sum_zc2
	GLOBAL    zc_amps1
	GLOBAL    zc_amps1_p
	GLOBAL    zc_amps2
	GLOBAL    zc_amps2_p
	GLOBAL    alp_states1_p
	GLOBAL    blp_states1_p
	GLOBAL    alp_states1
	GLOBAL    blp_states1
	GLOBAL    alp_states2_p
	GLOBAL    blp_states2_p
	GLOBAL    alp_states2
	GLOBAL    blp_states2
	GLOBAL    sine_p1
	GLOBAL    sine_p2
	GLOBAL    TD_INIT
	
    
    include "equates.asm"
    
    org      p:
    
    
TD_INIT

_BEGIN_TD_INIT_CODE

	move    #$ffff,m01 
;For Receive Channel
	clr     a
	move    a,x:state_TD1
	move    a,x:tone_count1
	move    a,x:dont_adapt1     
	move    a,x:g165_tone_disable1
	move    a,x:reset_TD1
	move    a,x:count1
	move    a,x:sum_hf_period1
	move    a,x:num_hf_period1
	move    a,x:first_zc_flag1
	move    a,x:fcount1
	move    a,x:ph_rev_amp1
	move    a,x:ph_rev_inst1
	move    a,x:ph_rev_amp11
	move    a,x:ph_rev_inst11
	move    a,x:ph_rev_amp21
	move    a,x:ph_rev_inst21
	move    a,x:zc_count1
	move    #688,x:hf_period1
	move    #blp_states1,r1            ;Calling requirement for td_lpfm
	move    r1,x:blp_states1_p
	rep     #3
	move    a,x:(r1)+
	move    #alp_states1,r1
	move    r1,x:alp_states1_p
	rep     #3
	move    a,x:(r1)+
	move    #sine_2000,r1
	move    r1,x:sine_p1
	move    #zc_amps1,r1
	move    r1,x:zc_amps1_p

	move    a,x:goertzel_count1
	move    a,x:tone_pass_count1
	move    a,x:goertzel1
	move    a,x:goertzel1+1
	move    a,x:TD_frm_energy1_high
	move    a,x:TD_frm_energy1_low
	move    #TD_TONE_THRES,b
	move    b,x:ave_TD_tone1_high
	move    b0,x:ave_TD_tone1_low
	move    #4.0*TD_TONE_THRES/TD_SNR_THRES,b
	asr     b
	asr     b
	move    b,x:ave_TD_noise1_high
	move    b0,x:ave_TD_noise1_low

;For Send Channel
	move    a,x:state_TD2
	move    a,x:tone_count2
	move    a,x:dont_adapt2     
	move    a,x:g165_tone_disable2
	move    a,x:reset_TD2
	move    a,x:count2
	move    a,x:sum_hf_period2
	move    a,x:num_hf_period2
	move    a,x:first_zc_flag2
	move    a,x:fcount2
	move    a,x:ph_rev_amp2
	move    a,x:ph_rev_inst2
	move    a,x:ph_rev_amp12
	move    a,x:ph_rev_inst12
	move    a,x:ph_rev_amp22
	move    a,x:ph_rev_inst22
	move    a,x:zc_count2
	 
	move    #688,x:hf_period2
	move    #blp_states2,r1            ;Calling requirement for td_lpfm
	move    r1,x:blp_states2_p
	rep     #3
	move    a,x:(r1)+
	move    #alp_states2,r1
	move    r1,x:alp_states2_p
	rep     #3
	move    a,x:(r1)+
	move    #sine_2000,r1
	move    r1,x:sine_p2
	move    #zc_amps2,r1
	move    r1,x:zc_amps2_p

;Initialization for td_bpf2.asm
	move    a,x:goertzel_count2
	move    a,x:tone_pass_count2
	move    a,x:goertzel2
	move    a,x:goertzel2+1
	move    a,x:TD_frm_energy2_high
	move    a,x:TD_frm_energy2_low
	move    #TD_TONE_THRES,b
	move    b,x:ave_TD_tone2_high
	move    b0,x:ave_TD_tone2_low
	move    #4.0*TD_TONE_THRES/TD_SNR_THRES,b
	asr     b
	asr     b
	move    b,x:ave_TD_noise2_high
	move    b0,x:ave_TD_noise2_low

_End_TD_INIT

	rts
	
	ENDSEC
;****************************** End of File *******************************

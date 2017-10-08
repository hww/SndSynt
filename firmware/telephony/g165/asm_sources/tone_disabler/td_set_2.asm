;**************************************************************************                                   
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                              
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_SET_STAT2
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver        Description             Author
;  --------     --------        -----------             ------
;  5/11/97      0.0.1           Macro Created           Qiu Lunji
;  18/11/97     1.0.0           Reviewed and Modified   Qiu Lunji
;  10/07/00     1.0.1           Converted macros to     Sandeep Sehgal
;                               functions    
;
;*************************** Function Description *************************
;
;  Sets state of the tone detector depending on tone counter and 
;      performs initialization for the new state for snd channel.
;
;  Symbols Used :
;       tone_count2       : Sample counter for the valid tone 
;       state_TD2         : State of tone detector
;       reset_TD2         : Flag to reset tone detector
;       sum_hf_period2    : Sum of valid half period samples
;       num_hf_period2    : Number of valid half periods
;       first_zc_flag2    : First zero crossing indication flag
;       count2            : Counter for counting number of samples 
;                           between two zero-crossings
;       ph_rev_amp2       : No. of "good" zero-crossing detected which
;                           indicated presence of a phase reversal between
;                           them
;       ph_rev_amp12      : No. of "good" zero-crossing detected which
;                           indicated presence of a phase reversal between
;                           them at first phase reversal
;       ph_rev_inst2      : Instance of phase reversal detected
;       ph_rev_inst12     : Instant of 1st phase reversal 
;       hf_period2        : Half of the period of the modulated tone
;       hf_period_lim2    : Tolerance for good zero crossing distance
;       fcount2           : Counter for number of samples between
;                           two zero crossings
;       zc_count2         : Counter for counting number of samples
;                           between two good zero crossings
;       factors[15]       : Array of 15 elements which stores 1/k
;                           for k = 8 to 22 
;
;  Functions Called   
;       None
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The function TD_INIT should be called before the 1st call of this function
;     for the first time. The constant and variable declarations are defined
;     in file td_data_asm
;
;************************** Input and Output ******************************
;
;  Input  :
;       tone_count2        = | iiii iiii | iiii iiii | in a1
;                           with a2 = 0 and a0 = 0 
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       state_TD2          = | 0000 0000 | 0000  00ii  |
;
;       reset_TD2          = | 0000 0000 | 0000  000i  |
;
;       first_zc_flag2     = | 0000 0000 | 0000  000i  |
;
;       sum_hf_period2     = | iiii iiii | iiii  iiii  |
;
;       num_hf_period2     = | iiii iiii | iiii  iiii  |
;
;       count2             = | iiii iiii | iiii  iiii  |
;
;       ph_rev_amp2        = | 0000 0000 | 0000  0iii  |
;
;       ph_rev_inst2       = | iiii iiii | iiii  iiii  |
;
;       ph_rev_amp12       = | 0000 0000 | 0000  0iii  |
;
;       ph_rev_inst12      = | iiii iiii | iiii  iiii  |
;
;       hf_period2         = | iiii iiii | iiii . ffff |
;
;       hf_period_lim2     = | iiii iiii | iiii . ffff |
;
;       fcount2            = | iiii iiii | iiii . ffff |
;
;       zc_count2          = | iiii iiii | iiii . ffff |
;
;  Statics :
;       factors[k]         = | s.fff ffff | ffff  ffff | for k = 0 to 14
;
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 137 (Max)
;                        Program Words : 122
;                        NLOAC         : 88
;
;  Address Registers used:
;
;  Offset Registers used:
;                        n  : used as an offset for updating r1
;
;  Data Registers used:
;                        a0  x0  y0
;                        a1      y1
;                        a2  
;
;  Registers Changed:
;                        r1  n1  a0  x0  y0  sr
;                                a1      y1  pc
;                                a2  
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           If ( tone_count2 == 1600 ),   % 200 ms %
;               state_TD2    =  1      
;           Endif
;
;           If (tone_count2 == 1720) | (tone_count2 == 5120)  % 215, 640 ms %
;               state_TD2 = 2           % Period estimation in sweep 1 %
;               first_zc_flag2 =  0
;               hf_period2 = 43
;               sum_hf_period2 = 0                          
;               num_hf_period2 = 0                          
;               count2 = 0
;           Endif
;      
;           If (tone_count2 == 2440) | (tone_count2 == 5840) % 305, 730 ms %
;               diff = num_hf_period2 - 8
;               If ( (diff < 0) | (diff > 14) ),
;                   reset_TD2 = 1
;               Else
;                   fnum = factors[diff]               
;                   tmp = fnum*(sum_hf_period2*2^(-15)) + 2^(-20)      
;                      % mpy fcount and sum_hf_period2 %
;                      % add rounding factor       %
;                   hf_period2 = floor(tmp*32768*16)/16     
;                      % store in 12.4 format  %
;                   adiff = abs (hf_period2 - 43)
;                   If ( adiff > 11 ) 
;                      reset_TD2 = 1
;                   Else 
;                       state_TD2 = 3
;                       fcount2 = 0
;                       zc_count2 = 0
;                       ph_rev_amp2 = 0
;                       ph_rev_inst2 = 0
;                       hf_period_lim2 = 0.1*hf_period2   % mult with round %
;                       first_zc_flag2 =  0
;                     Endif
;               Endif
;           Endif
;       
;           If (tone_count2 == 2760) | (tone_count2 == 6160) % 345, 770 ms %
;               state_TD2 = 4   % Check for phase reversal in sweep 1 %
;           Endif
;       
;           If ( tone_count2 == 4280 ),   % 535 ms %
;               %   Stop & store the results of previous phase reversal  %
;               state_TD2  =  1
;               ph_rev_amp12  =  ph_rev_amp2
;               ph_rev_inst12 =  ph_rev_inst2
;           Endif
;       End
;
;**************************** Assembly Code *******************************
	
	SECTION TD_SND_CODE
	
	GLOBAL  TD_SET_STAT2
	
	org     p:
	

TD_SET_STAT2

_Begin_TD_SET_STAT2
			      
	cmp     #1600,a
	jne     _casea
	move    #<1,x:state_TD2          ;state_TD2 = 1
	jmp     _End_TD_SET_STAT2        ;Branch out of module

_casea
	cmp     #1720,a
	bne     _caseb
_caseaa        
	move    #<2,x:state_TD2          ;state_TD2  = 2
	clr     a
	move    a,x:first_zc_flag2       ;first_zc_flag2 = 0
	move    a,x:sum_hf_period2       ;sum_hf_period2 = 0
	move    a,x:num_hf_period2       ;num_hf_period2 = 0
	move    a,x:count2               ;count2 = 0
	move    #688,x:hf_period2        ;hf_period2 = 43 (in 12.4 format)
	jmp     _End_TD_SET_STAT2        ;Branch out of module
_caseb
	cmp     #2440,a
	bne     _casec
_casebb        
	move    x:num_hf_period2,a
	sub     #8,a                     ;Evaluate diff = num_hf_period2 - 8
	blt     <_set_ton                ;Branch if diff < 0
	cmp     #14,a                    ;Compare diff with 14
	ble     <_nextchk                ;Branch if diff <= 14
_set_ton        
	move    #<1,x:reset_TD2          ;reset_TD2 = 1       
	jmp     _End_TD_SET_STAT2        ;Branch out of module
_nextchk
	move    #factors,r1              ;Get the address of factors[0]
	move    a,n                      ;Get diff in offset register
	move    x:sum_hf_period2,y0      ;Get sum_hf_period2
	clr     a       x:(r1)+n,x0      ;r1 -->factors[diff]
	move    #$800,a0                 ;Load  2^(-20) in 1.31 format
	move    x:(r1),x0                ;Read factors[diff]
	macsu   x0,y0,a                  ;Evaluate tmp
	asl     a                        ;Convert tmp to 12.4 format
	asl     a
	asl     a
	asl     a
	move    a,x:hf_period2           ;hf_period2 = tmp in 12.4 format 
	move    a,y0                     ;hf_period2 for later use 
       
	sub     #688,a                   ;Evaluate  hf_period2 - 43 (in 12.4 
					 ;  format)
	abs     a                        ;Evaluate adiff
       
	cmp     #176,a                   ;Compare adiff with 11 (in 12.4 )
	ble     <_elsecase               ;Branch if adiff <= 11 (in 12.4 )
	move    #<1,x:reset_TD2          ;reset_TD2 = 1
	bra     <_End_TD_SET_STAT2       ;Branch out of module
_elsecase
			
	move    #<3,x:state_TD2          ;state_TD2 = 3
	clr     a
	move    a,x:fcount2              ;fcount2   = 0
	move    a,x:zc_count2            ;zc_count2 = 0     
	move    a,x:ph_rev_amp2          ;ph_rev_amp2 = 0
	move    a,x:ph_rev_inst2         ;ph_rev_inst2 = 0
	move    a,x:first_zc_flag2       ;first_zc_flag2 = 0
	move    #0.1,x0                  ;Read 0.1 in 1.15 format
	mpyr    x0,y0,b                  ;Evaluate 0.1*hf_period2
	move    b,x:hf_period_lim2       ;hf_period_lim2 = 0.1*hf_period2
	bra     <_End_TD_SET_STAT2       ;Branch to End_TD_SET_STAT2

_casec
	cmp     #2760,a 
	bne     _cased
_casecc
	
	move    #<4,x:state_TD2          ;state_TD2 = 4
	bra     <_End_TD_SET_STAT2       ;Branch to End_TD_SET_STAT2

_cased
	cmp     #4280,a
	bne     <_casee
	move    #<1,x:state_TD2          ;state_TD2 = 1
	move    x:ph_rev_amp2,x0         
	
	move    x0,x:ph_rev_amp12        ;ph_rev_amp12 = ph_rev_amp2
	move    x:ph_rev_inst2,x0
	move    x0,x:ph_rev_inst12       ;ph_rev_inst12 = ph_rev_inst2
	bra     <_End_TD_SET_STAT2
_casee
	cmp     #5120,a
	jeq     _caseaa
	
	cmp     #5840,a
	jeq     _casebb
	
	cmp     #6160,a
	jeq     _casecc

_End_TD_SET_STAT2
	rts

	ENDSEC
;****************************** End of File *******************************

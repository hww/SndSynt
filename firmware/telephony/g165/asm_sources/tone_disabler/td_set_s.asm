;**************************************************************************
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                                 
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_SET_STAT1
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver        Description             Author
;  --------     --------        -----------             ------
;  5/11/97      0.0.1           Macro Created           Qiu Lunji
;  18/11/97     1.0.0           Reviewed and modified   Qiu Lunji
;  10/07/00     1.0.1           Converted macros to     Sandeep Sehgal
;                               functions    
;
;*************************** Function Description *************************
;
;  Sets state of the tone detector depending on tone counter and 
;      performs initialization for the new state for rcv channel.
;
;  Symbols Used :
;       tone_count1       : Sample counter for the valid tone 
;       state_TD1         : State of tone detector
;       reset_TD1         : Flag to reset tone detector
;       sum_hf_period1    : Sum of valid half period samples
;       num_hf_period1    : Number of valid half periods
;       first_zc_flag1    : First zero crossing indication flag
;       count1            : Counter for counting number of samples 
;                           between two zero-crossings
;       ph_rev_amp1       : No. of "good" zero-crossing detected which 
;                           indicated presence of a phase reversal between
;                           them
;       ph_rev_amp11      : No. of "good" zero-crossing detected which
;                           indicated presence of a phase reversal between
;                           them at first phase reversal
;       ph_rev_inst1      : Instance of phase reversal detected
;       ph_rev_inst11     : Instant of 1st phase reversal 
;       hf_period1        : Half of the period of the modulated tone
;       hf_period_lim1    : Tolerance for good zero crossing distance
;       fcount1           : Counter for number of samples between
;                           two zero crossings
;       zc_count1         : Counter for counting number of samples
;                           between two good zero crossings
;       factors[15]       : Array of 15 elements which stores 1/k
;                           for k = 8 to 22 
;
;  Functions Called   
;       None
;
;**************************** Function Arguments *****************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The Function TD_INIT should be called before the 1st call of this function
;     for the first time. The constant and variable declarations are defined 
;     in file td_data.asm
;
;************************** Input and Output ******************************
;
;  Input  :
;       tone_count1        = | iiii iiii | iiii iiii | in a1
;                           with a2 = 0 and a0 = 0 
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       state_TD1          = | 0000 0000 | 0000  00ii  |
;
;       reset_TD1          = | 0000 0000 | 0000  000i  |
;
;       first_zc_flag1     = | 0000 0000 | 0000  000i  |
;
;       sum_hf_period1     = | iiii iiii | iiii  iiii  |
;
;       num_hf_period1     = | iiii iiii | iiii  iiii  |
;
;       count1             = | iiii iiii | iiii  iiii  |
;
;       ph_rev_amp1        = | 0000 0000 | 0000  0iii  |
;
;       ph_rev_inst1       = | iiii iiii | iiii  iiii  |
;
;       ph_rev_amp11       = | 0000 0000 | 0000  0iii  |
;
;       ph_rev_inst11      = | iiii iiii | iiii  iiii  |
;
;       hf_period1         = | iiii iiii | iiii . ffff |
;
;       hf_period_lim1     = | iiii iiii | iiii . ffff |
;
;       fcount1            = | iiii iiii | iiii . ffff |
;
;       zc_count1          = | iiii iiii | iiii . ffff |
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
;           If ( tone_count1 == 1600 ),   % 200 ms %
;               state_TD1    =  1      
;           Endif
;
;           If (tone_count1 == 1720) | (tone_count1 == 5120)  % 215, 640 ms %
;               state_TD1 = 2           % Period estimation in sweep 1 %
;               first_zc_flag1 =  0
;               hf_period1 = 43
;               sum_hf_period1 = 0                          
;               num_hf_period1 = 0                          
;               count1 = 0
;           Endif
;      
;           If (tone_count1 == 2440) | (tone_count1 == 5840) % 305, 730 ms %
;               diff = num_hf_period1 - 8
;               If ( (diff < 0) | (diff > 14) ),
;                   reset_TD1 = 1
;               Else
;                   fnum = factors[diff]               
;                   tmp = fnum*(sum_hf_period1*2^(-15)) + 2^(-20)      
;                      % mpy fcount and sum_hf_period1 %
;                      % add rounding factor       %
;                   hf_period1 = floor(tmp*32768*16)/16     
;                      % store in 12.4 format  %
;                   adiff = abs (hf_period1 - 43)
;                   If ( adiff > 11 ) 
;                      reset_TD1 = 1
;                   Else 
;                       state_TD1 = 3
;                       fcount1 = 0
;                       zc_count1 = 0
;                       ph_rev_amp1 = 0
;                       ph_rev_inst1 = 0
;                       hf_period_lim1 = 0.1*hf_period1   % mult with round %
;                       first_zc_flag1 =  0
;                     Endif
;               Endif
;           Endif
;       
;           If (tone_count1 == 2760) | (tone_count1 == 6160) % 345, 770 ms %
;               state_TD1 = 4   % Check for phase reversal in sweep 1 %
;           Endif
;       
;           If ( tone_count1 == 4280 ),   % 535 ms %
;               %   Stop & store the results of previous phase reversal  %
;               state_TD1  =  1
;               ph_rev_amp11  =  ph_rev_amp1
;               ph_rev_inst11 =  ph_rev_inst1
;           Endif
;       End
;
;**************************** Assembly Code *******************************
	
	SECTION TD_RCV_CODE
	
	GLOBAL  TD_SET_STAT1
	
	org     p:

TD_SET_STAT1

_Begin_TD_SET_STAT1
			      
	cmp     #1600,a
	jne     _casea
	move    #<1,x:state_TD1          ;state_TD1 = 1
	jmp     _End_TD_SET_STAT1        ;Branch out of module

_casea
	cmp     #1720,a
	bne     _caseb
_caseaa        
	move    #<2,x:state_TD1          ;state_TD1  = 2
	clr     a
	move    a,x:first_zc_flag1       ;first_zc_flag1 = 0
	move    a,x:sum_hf_period1       ;sum_hf_period1 = 0
	move    a,x:num_hf_period1       ;num_hf_period1 = 0
	move    a,x:count1               ;count1 = 0
	move    #688,x:hf_period1        ;hf_period1 = 43 (in 12.4 format)
	jmp     _End_TD_SET_STAT1        ;Branch out of module
_caseb
	cmp     #2440,a
	bne     _casec
_casebb        
	move    x:num_hf_period1,a
	sub     #8,a                     ;Evaluate diff = num_hf_period1 - 8
	blt     <_set_ton                ;Branch if diff < 0
	cmp     #14,a                    ;Compare diff with 14
	ble     <_nextchk                ;Branch if diff <= 14
_set_ton        
	move    #<1,x:reset_TD1          ;reset_TD1 = 1       
	jmp     _End_TD_SET_STAT1        ;Branch out of module
_nextchk
	move    #factors,r1              ;Get the address of factors[0]
	move    a,n                      ;Get diff in offset register
	move    x:sum_hf_period1,y0      ;Get sum_hf_period1
	clr     a       x:(r1)+n,x0      ;r1 -->factors[diff]
	move    #$800,a0                 ;Load  2^(-20) in 1.31 format
	move    x:(r1),x0                ;Read factors[diff]
	macsu   x0,y0,a                  ;Evaluate tmp
	asl     a                        ;Convert tmp to 12.4 format
	asl     a
	asl     a
	asl     a
	move    a,x:hf_period1           ;hf_period1 = tmp in 12.4 format 
	move    a,y0                     ;hf_period1 for later use 
       
	sub     #688,a                   ;Evaluate  hf_period1 - 43 (in 12.4 
					 ;  format)
	abs     a                        ;Evaluate adiff
       
	cmp     #176,a                   ;Compare adiff with 11 (in 12.4 )
	ble     <_elsecase               ;Branch if adiff <= 11 (in 12.4 )
	move    #<1,x:reset_TD1          ;reset_TD1 = 1
	bra     <_End_TD_SET_STAT1       ;Branch out of module
_elsecase
			
	move    #<3,x:state_TD1          ;state_TD1 = 3
	clr     a
	move    a,x:fcount1              ;fcount1   = 0
	move    a,x:zc_count1            ;zc_count1 = 0     
	move    a,x:ph_rev_amp1          ;ph_rev_amp1 = 0
	move    a,x:ph_rev_inst1         ;ph_rev_inst1 = 0
	move    a,x:first_zc_flag1       ;first_zc_flag1 = 0
	move    #0.1,x0                  ;Read 0.1 in 1.15 format
	mpyr    x0,y0,b                  ;Evaluate 0.1*hf_period1
	move    b,x:hf_period_lim1       ;hf_period_lim1 = 0.1*hf_period1
	bra     <_End_TD_SET_STAT1       ;Branch to outofmodule

_casec
	cmp     #2760,a 
	bne     _cased
_casecc
	
	move    #<4,x:state_TD1          ;state_TD1 = 4
	bra     <_End_TD_SET_STAT1       ;Branch to outofmodule

_cased
	cmp     #4280,a
	bne     <_casee
	move    #<1,x:state_TD1          ;state_TD1 = 1
	move    x:ph_rev_amp1,x0         
	
	move    x0,x:ph_rev_amp11        ;ph_rev_amp11 = ph_rev_amp1
	move    x:ph_rev_inst1,x0
	move    x0,x:ph_rev_inst11       ;ph_rev_inst11 = ph_rev_inst1
	bra     <_End_TD_SET_STAT1
_casee
	cmp     #5120,a
	jeq     _caseaa
	
	cmp     #5840,a
	jeq     _casebb
	
	cmp     #6160,a
	jeq     _casecc

_End_TD_SET_STAT1

	rts

	ENDSEC
;****************************** End of File *******************************

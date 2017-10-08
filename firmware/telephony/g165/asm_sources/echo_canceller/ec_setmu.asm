;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Macro *************************************
;
;  Project ID     : G165EC  
;  Function name  : EC_SET_MU
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  01/10/97    0.0.1        Macro created              Quay Cindy
;  18/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           function
;
;*************************** Function Description **************************
;
;  This function sets the value of mu based on the energy of the input 
;  signal
;
;  Symbols Used :
;       mu_base      : Base for calculating mu
;       mu           : Adaptation constant
;       pow2tab      : Table for power of 2 values
;       ener_rin_high: MSW of energy 
;
;  Functions called
;       None
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The function EC_INIT  should be called before  the first call of this 
;     function
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
;************************ Globals and Statics *****************************
;
;  Globals  :
;
;       mu_base       = | f.fff ffff | ffff ffff |
;
;       mu            = | iiii iiii  | iiii iiii |
;
;       pow2tab       = | iiii iiii  | iiii iiii |
;
;       ener_rin_high = | i.fff ffff | ffff ffff | 
;
;  Statics :
;       None 
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 37
;                        Program Words : 21
;                        NLOAC         : 28
;
;  Address Registers used:
;                        r0 : used to address pow2tab 
;                             in linear addressing mode
;
;  Offset Registers used:
;                        n  : used as an offset to read pow2tab values
;
;  Data Registers used:
;                        a0  x0  
;                        a1  y0    
;                        a2  
;
;  Registers Changed:
;                        r0  n   a0  x0  sr
;                                a1  y0  pc
;                                a2  
;                              
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           if(ener_rin < 2^(-15))
;               power2approximation = pow2tab[0]
;           else
;               power2approximation = pow2tab[normalisation factor]
;           endif            % normalisation factor = log_2(ener_rin) %
;           mu = mu_base * power2approximation
;       End
;
;**************************** Assembly Code *******************************

	SECTION EC_CODE


    GLOBAL  EC_SET_MU
    
    org     p:
    

EC_SET_MU 

_Begin_EC_SET_MU
	move    #-14,r0                   ;For bottom clipping index
	move    x:ener_rin_high,a         ;Get ener_rin_high
	tst     a                         ;Test ener_rin_high
	beq     <_boclip                  ;If ener_rin_high=0 jump to clipping

	move    #-4,r0                    ;Store -4 in r0
	asl     a
	asl     a
	asl     a
	asl     a
	rep     #12
	norm    r0,a                      ;Repeat 12 norm iterations
					                  ;r0 gives minus of the number of
					                  ; shifts needed for normalisation 
_boclip          
	move    #pow2tab+14,n             ;Get address of pow2tab[14]
	move    x:mu_base,x0              ;Get mu_base 
	andc    #$7fff,x0                 ;Force mu_base to be positive
	move    x:(r0+n),y0               ;Get the power2approximation
	mpysu   x0,y0,a                   ;mu_base*power2approximation
	tstw    x:mu_base                 ;Perform final addition if MSB of
					                  ;mu_base was a '1'
	bge     _over
	add     y0,a              
_over
	move    a,x:mu                    ;Store mu 

_End_EC_SET_MU

    rts

	ENDSEC  

;****************************** End of File *******************************
 


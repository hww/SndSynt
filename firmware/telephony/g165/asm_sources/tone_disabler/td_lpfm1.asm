;**************************************************************************                                    
;                                                                        
;   (C) 2000 MOTOROLA, INC. All Rights Reserved                           
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_LPF_MODLN1
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;  
;**************************Revision History ******************************* 
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  24/9/97      0.0.1      Macro Created                Qiu Lunji
;  29/9/97      1.0.0      Reviewed and Modified        Qiu Lunji
;  3/11/97      1.0.1      Added optional compilation   Qiu Lunji, 
;                          capability for 2nd parallel  Sim Boh Lim
;                          memory access
;  10/07/00    1.0.2        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  Modulation, Low pass filtering and zero cross detection for rcv channel.
;
;  Symbols Used :
;       rin_sample        : Input Sample from rcv channel
;       zero_cross1       : Zero cross flag for rcv ch.
;       sine_p1           : Pointer for sine table (freq 2000 Hz)
;       alp_states1[3]    : All-pole states for LPF
;       alp_states1_p     : Pointer for all-pole states for LPF
;       blp_states1[3]    : All-zero states for LPF
;       blp_states1_p     : Pointer for all-zero states for LPF
;       blp_coef[4]       : LPF coeffs for all-zero section
;       alp_coef[3]       : LPF coeffs for all-pole section
;       TD_CONST_INT_XRAM : For compilation purpose
;                           Indicates that section TD_CONST lies strictly
;                           in internal XRAM (=1), lies in external
;                           XRAM (=0), or lies in unknown location of XRAM
;                           until linking time (=0)
;  
;  Functions Called :
;       None
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. TD_INIT should be called before the 1st call of this function.
;     The constant and variable declarations are defined in file td_data.asm
;  2. The lowpass filter coefficients should be arranged as shown in 
;     globals and statics section.
;  3. TD_CONST_INT_XRAM must be defined in the calling module or during
;     compilation.
;
;************************** Input and Output ******************************
;
;  Input  :
;       rin_sample       = | s.fff ffff | ffff ffff |     in x:rin_sample
;
;  Output :
;       zero_cross1      = |  0000 0000 | 0000 000i |     in x:zero_cross1
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;
;       sine_p1          = |  iiii iiii | iiii iiii |
;       alp_states1_p    = |  iiii iiii | iiii iiii |
;       blp_states1_p    = |  iiii iiii | iiii iiii |
;       sine_2000 Table (for 2000 Hz sine wave in 2.14 format):
;          (Pointer for the sine_2000 table is stored in sine_p1 using r0)
;
;                                +<-----<-----+
;                                |            |
;                      +-------------------+  |
;              r0----->|         0         |  |
;       (incremented   |-------------------|  |
;        by 1 after    |         1         |  |
;        call)         |-------------------|  |
;                      |         0         |  | (Modulo 4)
;                      |-------------------|  |
;                      |        -1         |  | 
;                      |-------------------|  |
;                                |            |
;                                +----->----->+
;                     sine wave samples (2000Hz)       
;
;
;       Filter coefficients (Normalized):
;
;       blp_coef(k)      = | s.fff ffff | ffff ffff |  for k=0 to 3
;                        (for all-zero section of LPF (scaled up by 32))
;       alp_coef(k)      = | s.fff ffff | ffff ffff |  for k=0 to 2
;                        (for all-pole section of LPF (scaled down by 2))
;
;       blp_coef and alp_coef are stored in one array of 
;       lp_coef(k)        = | s.fff ffff | ffff ffff | for k=0 to 6
;       as shown below.
;
;                      +---------------+
;              r3----->|  blp_coef(3)  |
;                      |---------------|
;                      |  blp_coef(2)  |
;                      |---------------|
;                      |  blp_coef(1)  |
;                      |---------------|
;                      |  blp_coef(0)  |
;                      |---------------|
;                      |  -alp_coef(3) |
;                      |---------------|
;                      |  -alp_coef(2) |
;                      |---------------|
;                      |  -alp_coef(1) |
;                      +---------------+
;                filter coefficients buffer (alp_coef(0)=1).
;
;       TD_CONST_INT_XRAM  = 1   indicates that section TD_CONST lies
;                                strictly in internal XRAM
;                          = 0   indicates that section TD_CONST lies
;                                in external or unknown location
;                                of XRAM until linking time
;
;  Statics :
;
;       Filter states:
;    
;       blp_states1(k)    = | s.fff ffff | ffff ffff |  for k=0 to 2
;                          ( for all-zero section states of LPF )
;       alp_states1(k)    = | s.fff ffff | ffff ffff |  for k=0 to 2
;                          ( for all-pole section states of LPF )
;
;       are stored as shown below.
;       (Pointers are stored in blp_states1_p, alp_states1_p using r0)
;                               
;                                +<-----<-----+
;                                |            |
;                      +-------------------+  |
;              r0----->|  blp_states1(n-3) |  |
;       (incremented   |-------------------|  |
;        by 1 after    |  blp_states1(n-2) |  |
;        every call)   |-------------------|  |
;                      |  blp_states1(n-1) |  | (Modulo 3)
;                      |-------------------|  |
;                                |            |
;                                +----->----->+
;                       input states buffer       
;
;                                +<-----<-----+
;                                |            |
;                      +-------------------+  |
;              r0----->|  alp_states1(n-3) |  |
;       (incremented   |-------------------|  |
;        by 1 after    |  alp_states1(n-2) |  |
;        every call)   |-------------------|  |
;                      |  alp_states1(n-1) |  | (Modulo 3)
;                      |-------------------|  |
;                                |            |
;                                +----->----->+
;                       output states buffer       
;
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 56 for TD_CONSTANT_INIT_XRAM = 1
;					 64 for TD_CONSTANT_INIT_XRAM = 0
;                        Program Words : 44 for TD_CONSTANT_INIT_XRAM = 1
;					 48 for TD_CONSTANT_INIT_XRAM = 0
;                        NLOAC         : 57
;
;  Address Registers used:
;                        r0 : used to read states in modulo 3 mode,
;                             used to read the sine table in modulo 4 mode
;                        r3 : used to read coefficients in linear mode
;
;  Offset Registers used:
;                        None
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  m01  a0  b0  x0  y0  sr
;                        r3       a1  b1      y1  pc
;                                 a2  b2
;                              
;
;***************************** Pseudo Code ********************************
;
;        Begin
;       
;          %%% Modulate by 2000 Hz wave %%%
;       
;          Implemented using a sine_2000 table for 2000Hz sine wave.
;          Read table entry and multiply with the input sample.
;          (Table entries 0,1,0,-1 in 2.14 format pointed by sine_p1)
;
;               xn1 = rin_sample*(*sine_p1++);
;
;          %%% Low Pass filtering for channel 1 %%%
;       
;          tmp = blp_coef(0)*xn1 + blp_coef(1:3)'*blp_states1(0:2)
;          tmp = tmp/1024                      % tmp in accumulator %
;           
;          blp_states1(1:2) = blp_states1(0:1)
;          blp_states1(0) = xn1
;       
;          tmp = tmp - alp_coefs(1:3)'*alp_states1(0:2)
;          tmp = tmp*4 + 2^(-16)
;           
;          yn1 = (floor(tmp*32768))/32768  % Store result in 1.15 form %
;       
;          alp_states1(1:2) = alp_states1(0:1)
;          alp_states1(0) = yn1
;       
;          %%% Zero cross detect for channel 1 %%%
;       
;          prev_yn1  = alp_states1(1)
;       
;          % Implemented using xoring of prev_yn1 and yn1 %
;
;          If ( (prev_yn1 >= 0) & (yn1 < 0) )
;               zero_cross1 = 1
;          Elseif ( (prev_yn1 < 0) & (yn1 >= 0) )
;               zero_cross1 = 1
;          Else
;               zero_cross1 = 0
;          Endif
;       
;        End
;
;**************************** Assembly Code *******************************
	
	SECTION TD_RCV_CODE
	
	GLOBAL  TD_LPF_MODLN1

    include "equates.asm"
    
    org     p:


TD_LPF_MODLN1

_Begin_TD_LPF_MODLN1
 
; Modulation by 2000 Hz.

	move    #$8003,m01                ;Modulo 4 sine tbl
	move    x:sine_p1,r0              ;Load current ptr
	move    x:rin_sample,y0           ;Read sample
	move    x:(r0)+,x0                ;Read sine value
	mpy     x0,y0,a                   ;Modulate
	asl     a                         ;Normalize output
	move    r0,x:sine_p1              ;Save the pointer

; Setting up pointers for LPF 
	
	move    #$8002,m01                ;Modulo 3 addressing
	move    #lp_coef,r3               ;Set Coeffs pointer
	move    x:blp_states1_p,r0        ;Set States pointer
	move    a,y1                      ;Modulation output,
					  ;  xn1 to LPF input
; All-zero section of LPF

					  ;Initial read coef & state
	move    x:(r0)+,y0
	move    x:(r3)+,x0
	mpy     y0,x0,a      x:(r0)+,y0
	move    x:(r3)+,x0
	mac     y0,x0,a      x:(r0)+,y0
	move    x:(r3)+,x0
	mac     y0,x0,a      x:(r3)+,x0                
	mac     y1,x0,a      y1,x:(r0)+                
					  ;Filter computes and parallel
					  ;  read next coeff and state
	rep     #8                        ;tmp = tmp/256
	asr     a                                     
	move    r0,x:blp_states1_p        ;Store the state pointer

; All-pole section of LPF
	
	move    x:alp_states1_p,r0        ;Set states pointer 
					  ;r3 points to coeffs
	asr     a            x:(r3)+,x0   ;tmp = tmp/4
	asr     a            x:(r0)+,y0   ;Parallel read state & coeff

	mac     y0,x0,a      x:(r0)+,y0
	move    x:(r3)+,x0
	mac     y0,x0,a      x:(r0)+,y0
	move    x:(r3)+,x0
	mac     x0,y0,a                                 
					  ;Filter computes and parallel
					  ;  read next coeff and state
	asl     a                         ;Multiply by 4 for denormalization 
	asl     a                          
	rnd     a                         ;Rounding    
	clr     b    a,x:(r0)+            ;Store output as a state 
	move    r0,x:alp_states1_p        ;Store the state pointer 

; Zero Cross Detection
	   
	move    a0,x0                     ;Store 0 in x0
	inc     b                         ;Set b as 1
	eor     y0,a                      ;Xor the current and
					  ;  previous output 
	tge     x0,b                      ;Reset b if xor result is +ve
	move    b,x:zero_cross1           ;Update zero_cross flag

_End_TD_LPF_MODLN1

	rts

	
	ENDSEC
;****************************** End of File *******************************

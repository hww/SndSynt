;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_ADAPT
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  05/11/97    0.0.1        Macro created              Quay Cindy
;  19/11/97    1.0.0        Modify per review          Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  This function performs the modified Normalised LMS algorithm
;
;  Symbols Used :
;      Filt_Len         : Order of the filter
;      mu               : Mu for adaptation
;      f_stat[Filt_Len] : States of the filter of length Filt_Len+1
;      hfilt[Filt_Len]  : Filter coeff of length Filt_Len+1
;      sout_sample      : Output sample for the snd channel
;      len_factor       : Filter length factor adjustment
;
;  Macros Called :
;       None
;
;**************************** Function Arguments **************************
;
;   None
;
;************************* Calling Requirements ***************************
;
;  1. EC_INIT should be called before the 1st call of this function
;     The constant and variable declarations are defined in
;     file ec_data.asm
;  2. The EC_FIR function should be called before calling this function.
;  3. Hardware looping resources including LA, LC and 1 location
;     of HWS must be available for use.
;  4. mu must be stored in y1.
;  5. sout_sample must be stored in x0.
;  6. LEN_RATIO (40/ECHOSPAN) must be stored in y0
;  7. m01 =  $8000+Filt_Len
;  8. r1 points to hfilt(0) as indicated in the input output section.
;  9. EC_VAR_INT_XRAM should be defined before the call of this function
;
;************************** Input and Output ******************************
;
;  Input  : 
;       mu          = | iiii iiii  | iiii iiii | in y1 
;
;       sout_sample = | s.fff ffff | ffff ffff | in y0  
;
;       len_factor  = | i.fff ffff | ffff ffff | in x0  
;
;       hfilt(k)    = | s.fff ffff | ffff ffff | for k=0,1,2,...,Filt_Len  
;
;       f_stat(k)   = | s.fff ffff | ffff ffff | for k=0,1,2,...,Filt_Len  
;
;       are stored as shown below.
;
;             hfilt array                      f_stat array
;
;                   +<-----<-----+                   +<-----<-----+
;                   |            |                   |            |
;            |-------------|     |           |---------------|    |  
;            |h(Filt_Len)  |     |           |x(n-Filt_Len)  |    | 
;            |-------------|     |           |---------------|    |  
;            |h(Filt_Len-1)|     |           |x(n-Filt_Len+1)|    |
;            |-------------|     |           |---------------|    |
;            |h(Filt_Len-2)|     |           |x(n-Filt_Len+2)|    |
;            |-------------|   Modulo        |---------------|   Modulo
;            |    .        |   Filt_Len+1    |    .          |   Filt_Len+1
;            |    .        |   buffer        |    .          |   buffer 
;            |-------------|     |           |---------------|    |
;            | h(2)        |     |           |   x(n-2)      |    |
;            |-------------|     |           |---------------|    |
;            | h(1)        |     ^           |   x(n-1)      |    |
;            |-------------|     |           |---------------|    |
;    r3,r1-->| h(0)        |     |           |   x(n)        | <--- r0    
;  (before   |-------------|     |           |---------------|    |
;  & after call)     |           |                   |            |
;                    +----->----->+                  +----->----->+
;
;                                            (r0) points to the most recent
;                                            sample which is  determined by 
;                                            the macro EC_FIR and is not  
;                                            changed after the call of this
;                                            macro
;
;  Output :
;    
;       hfilt(k)    = | s.fff ffff | ffff ffff | for k=0,1,2,...,Filt_Len  
;
;       f_stat(k)   = | s.fff ffff | ffff ffff | for k=0,1,2,...,Filt_Len  
;
;       are stored as shown in input session.
;
;
;************************* Globals and Statics ****************************
;
;  Globals : 
;       None
;
;  Statics : 
;       None 
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 2*(Filt_Len+1) + 21 
;                        Program Words : 24
;                        NLOAC         : 34
;
;  Address Registers Used:
;                        r0  : used to address f_stat in
;                              modulo addressing mode
;                        r1  : used to address hfilt in
;                              modulo addressing mode
;                        r3  : used to address hfilt in
;                              linear addressing mode
;
;  Offset Registers Used:
;                        None
;
;  Data Registers Used:
;                        a0  b0  x0  y0  
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                          a0  b0  x0  y0  sr
;                          a1  b1      y1  pc
;                          a2  b2  
;
;***************************** Pseudo Code ********************************
;
;  Begin
;       temp  = mu * sout_sample * (2^3)
;       temp1 = temp * len_factor 
;       temp2 = (2^6) * temp1
;       For  k= 1 to filt_length
;           hfilt[k] = hfilt[k] + temp2 * filt_states[k]
;       endfor
;  End
;
;**************************** Assembly Code *******************************

	SECTION EC_CODE
	
	GLOBAL  EC_ADAPT
	
    include "equates.asm"

    org     p:

EC_ADAPT

_Begin_EC_ADAPT

	mpysu   x0,y1,a                   ;temp=mu*sout_sample  
	
	asl     a                         ;Shifting up by 2^3 
	asl     a
	asl     a           

	move    a,x0                      ;get temp
	
	mpysu   x0,y0,a                   ;temp1=temp*len_factor

	asl     a                         ;Shifting up by 2^6
	asl     a        
  
	asl     a           x:(r1)+,x0    ;dummy read, r1 --> hfilt[Filt_Len] 
	asl     a           x:(r0)+,y0    ;Read x[n-Filt_Len] from
					                  ; f_stat buffer into y0
					                  ;r0 --> f_stat[n-Filt_Len +1]

    move    a,y1                      ;saturating a if a>=1 or a<-1
	asl     y1           
	asl     y1                        ;get temp2

	move    r1,r3                     ;r3 --> hfilt[Filt_Len]
	

    move    x:Filt_Len,b1             ;Load Filt_Len
	move    x:(r3)+,a                 ;hfilt[Filt_Len] --> a
					                  ;r3 --> hfilt[Filt_Len-1]  

	do      b1,_adaover               ;for (k = 0 to Filt_Len-1) 

	macr    y1,y0,a      x:(r0)+,y0    x:(r3)+,x0      
					                 ;Compute hfilt[k] + temp2*f_stat[k]
					                 ; r0 --> f_stat[n-FILT_LEN+1+k]
					                 ; r3 --> hfilt[FILT_LEN-(1+k)]
	
	tfr     x0,a          a,x:(r1)+   ;Move hfilt[k] for next iteration
                                      ; Store back hfilt[k] 

_adaover
	macr    y1,y0,a

	move    a,x:(r1)
	move    r1,r3

_End_EC_ADAPT
    rts

	ENDSEC  
;****************************** End of File *******************************

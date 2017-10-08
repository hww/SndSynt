;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_FIR
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  01/10/97    0.0.1        Macro created             Quay Cindy
;  06/10/97    1.0.0        Modified per review       Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;     This function implements the non-recursive difference equation of an 
;     all-zero filter, of order Filt_Len. All the coefficients of all-zero 
;     filter are assumed to be less than 1 in magnitude. 
;
; Difference Equation :
;
;       y(n)=h(0)*x(n)+h(1)*x(n-1)+h(2)*x(n-2)+....+h(N)*x(n-N)
;
;      where
;              y(n)=output sample of the filter at index n 
;              x(n)=input sample of the filter at index n 
;              N   = length of filter
; 
;  Symbols Used :
;  
;       hfilt[Filt_Len+1]     : Adaptive filter coefficient buffer
;       f_states[Filt_Len+1]  : Adaptive filter state buffer
;       sample                : Input sample at y0
;
;  
;  Function called
;       None
;
;
;**************************** Function Arguments **************************
;
;  Filt_Len : Order of the  filter . (Filt_Len >= 2)
;
;************************* Calling Requirements ***************************
;
;  1. Set m01 = Filt_Len and n = -Filt_Len.
;  2. The pointers r0 and r3 are positioned as depicted in the
;     `Input and Output' section when the first call of this function
;     is made. r0 and r3 should not be altered between two successive
;     function calls.
;  3. The function EC_INIT  should be called before the first call of
;     this function.
;  4. sample should be stored in y0.
;  5. Harware looping resource which includes LA, LC and 1 location
;     of HWS must be available for use.
;
;************************** Input and Output ******************************
;
;  Input  :
;
;       sample    = | s.fff ffff | ffff ffff |  in reg y0
;       hfilt(k)  = | s.fff ffff | ffff ffff |  for k=0,1,2,...,Filt_Len
;       f_stat(k) = | s.fff ffff | ffff ffff |  for k=0,1,2,...,Filt_Len
;       are stored as shown below.
;   
;                                                        +<-----<-----+
;                                                       |             |
;            |-----------------|                 |---------------|    |  
;            |hfilt(Filt_Len)  |                 |x(n-Filt_Len)  |    | <--r0
;            |-----------------|                 |---------------|  (after call)
;            |hfilt(Filt_Len-1)|                 |x(n-Filt_Len+1)|    |
;            |-----------------|                 |---------------|    |
;            |hfilt(Filt_Len-2)|                 |x(n-Filt_Len+2)|    |
;            |-----------------|                 |---------------| Modulo
;            |    .            |                 |    .          | Filt_Len+1
;            |    .            |                 |    .          |  buffer
;            |-----------------|                 |---------------|    |
;            | hfilt(2)        |                 |x(n-2)         |    |
;            |-----------------|                 |---------------|    |
;            | hfilt(1)        |                 |x(n-1)         |    |
;            |-----------------|                 |---------------|    |
;    r3  --->| hfilt(0)        |                 |x(n)           |    |<--r0
;            |-----------------|                 |---------------| (before call)
;                                                       |             |
;                                                       +----->-----> +
;
;     
;  Implicit inputs:
;       To compute the present output , inputs x(n-i) for i=1,2,..Filt_Len
;       are needed. These are stored in the filter states buffer,f_stat, as 
;       shown above.
;
;  Output:
;       y(n) = | s.fff ffff | ffff ffff | 0000 0000 | 0000 0000 |
;              |<-----------a1--------->|<----------a0--------->|
;                in a1, with a0 zero filled and a2 sign extended.
;
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
;                        Icycle Count  : Filt_Len + 8
;                        Program Words : 9
;                        NLOAC         : 12
;
;  Address Registers Used:
;                        r0 : used to address delay buffer
;                              in modulo addressing mode
;                        r3 : used to address coefficient buffer
;                              in linear addressing mode
;
;  Offset Registers Used:
;                        None
;
;  Data Registers Used:
;                        a0   x0  y0 
;                        a1       y1
;                        a2   
;
;  Registers Changed:
;                        a0  r0  x0  y0  sr
;                        a1          y1  pc
;                        a2    
;
;***************************** Pseudo Code ********************************
;
;               Read h(0)
;               Store x(n) as x(n-1) for next call.            
;               Sum1=x(n)
;               Sum2=Sum1*h(0)
;               For(i=Filt_Len ; i>=2 ; i-- )
;               {
;                   Sum3=Sum2+h(i)*x(n-i)
;                   Sum2=Sum3
;               }
;               Sum4=Sum3+h(1)*x(n-1)         /* Sum4=y(n) */
;
;
;**************************** Assembly Code *******************************

	SECTION EC_CODE

    GLOBAL  EC_FIR
        
    include "equates.asm"
    
    org     p:

EC_FIR 
	
	move    y0,x:(r0)+                ;Store x(n) in x(n-1) 
	move    x:(r3)+n,y1               ;Read h(0) in y1


;Compute Sum2, get x(n-Filt_Len) and  h(Filt_Len) in y0 and x0

	mpy     y1,y0,a   x:(r0)+,y0   x:(r3)+,x0                                              

    move    x:Filt_Len,y1

;Update Sum3, get x(n-i) and h(i)in y0 and x0. Compute Sum4. 
;Repeat Filt_Len times

	do      y1,_loop                  
	mac     y0,x0,a      x:(r0)+,y0    x:(r3)+,x0                               
_loop    
	rnd     a
	rts                                ;Sum4 is y(n)

	ENDSEC  

;****************************** End of File *******************************

;******************************* Function *********************************
;
;  Macro Name     : DTMFG_IN
;  Author         : Omkar.S.P
;  Date of Origin : 18 Mar 96
;  Last update    : 10 APr 96
;
;*************************** Function Description *************************
;
;  This function initializes the pair of initial states and the 
;  coefficients of the corresponding digital oscillator, depending on the 
;  key pressed, using the row and coulmn indexes of the key.
;
;**************************** Function Arguments **************************
;
;  coef          : The address of the starting X memory location where the
;                  coefficients and initial states are stored.
;
;  amp           : The amplitude of the sinusoids, in fractional format,
;                  can be a maximum of $3fff.
;
;  hi_buf        : The satrting address of the X memory location where the 
;                  high group initial states are stored as a modulo 2 
;                  buffer
;
;  lo_buf        : The starting address of the X memory location where the 
;                  low group initial states are stored as a modulo 2 buffer
;
;************************* Calling Requirements ***************************
;
;  1.The module dt_setup must be first invoked.
;
;************************** Input and Output ******************************
;
;  Inputs : 
;     r_indx  = |0000 0000 0000 00ii|, in r0
;    
;     c_indx  = |0000 0000 0000 00ii|, in r1
; 
;     The mapping of r_indx,c_indx to the key number is given in the 
;     figure below:
;
;       c_indx---->
;       0      1    2     3
;     +-----+-----+-----+-----+
;     |  1  | 2   | 3   | A   | 0 r_indx
;     +-----+-----+-----+-----+      |
;     |  4  | 5   | 6   | B   | 1    |
;     +-----+-----+-----+-----+      |
;     |  7  | 8   | 9   | C   | 2    |
;     +-----+-----+-----+-----+      v
;     |  *  | 0   | #   | D   | 3
;     +-----+-----+-----+-----+
;
;     [For example, the digit 6 is represented by rindx=1, cindx=2.]
;
;  Outputs:
;                      |----------|        |----------|  
;      X:lo_buf+1----->|   sl2    |        |  sh2     |<-----X:hi_buf+1
;                      |----------|        |----------|
;        X:lo_buf----->|   sl1    |        |  sh1     |<-----X:hi_buf
;                      |----------|        |----------|
;                      low group filter    high group filter 
;                      states buffer       states buffer  
;                      modulo 2            modulo 2
;                       
;                      Figure 1.: Buffers for initial states.                  
;                      --------------------------------------
;        
;     sl1     = | 0.fff ffff | ffff ffff |  in X:lo_buf.
;     [initial state 1 of the low group oscillator,see Figure1.]
;
;     al/2    = | 0.fff ffff | ffff ffff |  in x:al_2.  x0 .
;     [coefficient of the low group oscillator].
;
;     sl2     = | 0.fff ffff | ffff ffff |  in X:lo_buf+1.
;     [initial state 2 of the low  group oscillator.see Figure1.]
;
;     sh1     = | 0.fff ffff | ffff ffff |  in X:hi_buf.
;     [initial state 1 of the low group oscillator,see Figure1.]
;
;     sh2     = | 0.fff ffff | ffff ffff |  in X:hi_buf+1.
;     [initial state 2 of the high group oscillator,see Figure1.]
;
;     ah/2    = | 0.fff ffff | ffff ffff |  in x:ah_2.   y0.
;     [initial state 1 and coefficient of the high group oscillator]
;
;****************************** Resources *********************************
;
;                        Cycle Count   : 26
;                        Program Words : 24
;                        NLOAC         : 25
;
; Address Registers used: 
;                        r0 : Used for input rindx
;                        r1 : Used for input cindx
;                        
; Offset Registers used: 
;                        n is used with an offset of 4,linear addressing
;
; Data Registers used:
;                        a0  b0    x0  y0  
;                        a1  b1    y1  
;                        a2  b2          
;
; Registers Changed:  
;                        r0        a0  b0    x0  y0    sr
;                        r1  n     a1  b1    y1        pc
;                                  a2  b2                             
;
;***************************** Pseudo Code ********************************
;
;       Begin
;          ['amp' is the amplitude of both sine waves, maximum value=$3fff]
;          i    = r_indx    
;          j    = c_indx +4
;          al/2 = coef[i]
;          sl1  = amp*al/2
;          sl2  = amp
;          ah/2 = coef[j]
;          sh1  = amp*ah/2
;          sh2  = sl2
;       End
;
;**************************** Assembly Code *******************************
 
        SECTION DTMF
 
        GLOBAL  Fdtmfg_in
        
        GLOBAL  amp
 
        org   x:

amp ds 1        

        org   p:

Fdtmfg_in

        move    x:r_indx,r0
        move    x:c_indx,r1
        move    y0,x:amp
        move    #-1,m01
        clr     a                         ;Clear a
        move    #4,n                      ;Offset 4 in n
        move    r2,y1                     ;Base address 'coef' in y1
        move    r0,a                      ;Get r_indx in a
        add     y1,a                      ;coef + r_indx in a
        move    a,r0                      ;i = r_indx +coef in r0
        move    r1,a                      ;Get c_indx in a
        add     y1,a                      ;coef + c_indx in a,
        move    x:amp,y1                   ;Get amp in y1
        move    x:(r0),x0                 ;al/2, in x0
        mpyr    x0,y1,b                   ;sl1=amp*al/2 in b
        move    #lo_buf,r0                ;Low group states buffer address
        move    a,r1                      ;j = c_indx+ coef in r1
        move    b,x:(r0)+                 ;Store sl1 in x:lo_buf
        move    y1,x:(r0)                 ;Store sl2=amp in x:(lo_buf+1)
        move    #hi_buf,r0                ;High group states buffer address
        move    x:(r1+n),y0               ; ah/2 in y0
        mpyr    y1,y0,b                   ;sh1=amp*ah/2 in b
        move    b,x:(r0)+                 ;Store sh1 in x:hi_buf
        move    y1,x:(r0)                 ;Store sh2=amp in x:(hi_buf+1)
        move    x0,x:al_2
        move    y0,x:ah_2
        rts

        ENDSEC

;****************************** End of File *******************************

;******************************* Module **********************************
;
;  Module Name          : tx_fm
;  Author               : Sanjay S. K. and Shyam Sundar 
;  Date of origin       : 10 Dec 1995
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* Module Description ****************************
;
;  Interpolation, filtering and modulation are included in the same filter
;  structure. The transmit lowpass filter is implemented using 36-tap FIR
;  structure, whose frequency response exhibits a raised cosine shape.
;  The interpolation factor is 12. 12 samples per (I,Q) are interpolated
;  considering the influence of the previous two (I,Q) symbols. Since
;  only 3 inputs are active at a time, the 36 filter coefficients are
;  divided into 12 groups of 3 each. Each output sample is obtained by
;  loading the filter coefficient buffer with a new set of coefficients.
;  The input of the filter ( I,Q buffer ) is updated only after every 12
;  output samples; the I,Q buffer is shifted to the right by 2, so that
;  I(n-2), Q(n-2) are lost, I(n-1) and Q(n-1) are stored as I(n-2) and
;  Q(n-2) respectively, the New I and Q are stored as In and Qn respecti-
;  vely. The filter coefficients also involve the samples of carrier  
;  ( either 1200 or 2400 Hz ). 
;  Guard tone of 1800 Hz ( 6 db below ) or 562.5 Hz ( 3 db below ) are
;  added to each output sample depending on the option. 64 samples of each
;  of the guard tones are stored in tables starting from locations #sin1800
;  and #sin562 respectively.
;
;  The structure of the filter modulator is given below.
;
;                  In       Qn     I(n-1)   Q(n-1)   I(n-2)   Q(n-2) 
;                  |        |        |        |        |        |   
;                  |        |        |        |        |        |      
;                 (X)      (X)      (X)      (X)      (X)      (X)
;                  |        |        |        |        |        |      
;             h(0) |   h(1) |   h(2) |   h(3) |   h(4) |   h(5) |       
;                  V        V        V        V        V        V
;                  |        |        |        |        |        |
;                   \        \       |        |       /        /
;                    +--------+------+--------+------+--------+
;                    |                   +                    |
;                    +----------------------------------------+
;                                        |
;                                        V
;                                        |
;                                      +---+
;                      Guard Tone ---->| + |
;                  (1800 Hz/562.5 Hz)  +---+
;                     (Optional)         |
;                                        |
;                                        V
;                                  Output Sample
;    
;  where h(i) = Real part of the filter coefficient for i even and
;             = Imaginary part of the filter coefficient for i odd
;     
;      In, Qn            =    Current I and Q symbols
;      I(n-k), Q(n-k)    =    Delayed values of I & Q 
;
;             Symbols used :
;                          gtone_ptr  : Address of Guard tone table
;                          tx_fm_buf  : Address of I,Q input buffer
;                          tx_fm_coef : Address of Filter coef buffer
;                          gtamp      : Contains the max value of 
;                                         Guard tone 
;                          tx_out     : Output buffer of length 12
;                          
;************************* Calling Requirements **************************
; 
;  1. The new values of I and Q should be stored in a1 and b1 respectively
;   
;  2. The memory location x:gtone_ptr should be loaded with the starting 
;     address of sine table. 
;
;  3. x:tx_fm_gt_offset = 64 if Guard tone is of 1800 Hz, and 20 if Guard 
;     tone is of 562.5 Hz.
;
;  4. A buffer of length 6 should be provided to the module with the 
;     starting address labled as 'tx_fm_buf '. These 6 locations should
;     be cleared when this module is called for the first time. 
;
;  5. 72 filter coefficients with real and imaginary values should be
;     stored consecutively in a buffer whose starting address is tx_fm_coef
;
;  6. An output buffer of length 12 should be provided with the starting
;     address labled as tx_out.
;
;  7. This module has one do loop, hence while calling this module in
;     another do loop the contents of la and lc should be saved.
;
;  8. The memory location x:gtamp should be loaded with #12 if the
;     guard tone is 1800 Hz sine or #$1a if the guard tone is 562.5 Hz
;     sine wave.
;
;  /* The file init_mdm contains all initializations for this module */
;
;*********************** Inputs and Outputs *******************************
;
;  Input : 
;          I      = | siii. 0000 | 0000 0000 |  in a1
;          Q      = | siii. 0000 | 0000 0000 |  in b1
;
;  Output : 
;          12 samples of
;          tx_out = | iiii  iiii | iiii iiii |  in x:tx_out+n
;                                               n = 0, 1, ... , 11
;
;**************************** Implicit inputs *****************************
;
;          Coefs  = | siii  iiii | iiii iiii |   in x:tx_fm_coef+n
;                                                  n = 0, 1, ..., 71
;          Buff   = | siii. 0000 | 0000 0000 |   in x:tx_fm_buf+m
;                                                  m = 0, 1, ..., 5
;          For more details of the above inputs refer to the 
;          Module description section in this file.
;
;          Offset =  Address Pointer             in x:gtone_ptr
;
;          gtamp  = | 0000  0000 | 000f ffff |   in x:gtamp
;
;*********************** Tables and Constants *****************************
;
;  Refer to init_mdm.asm file for filter coefficients and Guard tone tables
;  
;**************************** Pseudo code *********************************
;
;         Offset = temp = 20; For Guard tone of 562.5 Hz or
;         Offset = temp = 64; For Guard tone of 1800 Hz
;                           /* Done only once through initialization */
;         /* Insert input I and Q values */
;
;         Begin
;
;             Buff[5]  = Buff[3]
;             Buff[4]  = Buff[2]
;             Buff[3]  = Buff[1]
;             Buff[2]  = Buff[0]
;             Buff[1]  = New Q
;             Buff[0]  = New I
;
;             sine     = Sine table of 256 entries
;             /* sine[k] ==> kth entry of the sine table */
;
;             for i = 0 to 11
;
;             {
;                 tx_out[i] = 0
;
;                 for j = 0 to 5
;                     tx_out[i] = tx_out[i] + Coefs[6*i+j] * Buff[j]
;
;                 tx_out[i] = tx_out[i] + gtamp * sine[Offset]
;             }
;
;             Offset = (Offset + temp) % 255
;         End
;                          
;******************************* Resources ********************************
;
;                    Cycle Count   : 163
;                    Program Words : 41
;                    NLOAC         : 33
;
; Address Registers used : 
;                     r0 : Used as a pointer to Guard tone table
;                          in modulo 256 addressing mode.
;                     r1 : Used as a pointer to the input I,Q buffer
;                          of length 6 in linear addressing mode.
;                     r2 : Used as a pointer to the output buffer
;                          of length 12 in linear addressing mode.
;                     r3 : Used as a pointer to Filter coefficient
;                          buffer of length 72 in linear addressing
;                          mode.
;                      
; Offset Registers used  : 
;                      n : used as an offset register to Guard tone table
;
; Modifier Register used : 
;                    m01 : To allow r0 accessing guard tone table in mod
;                          256 addressing
;
; Data Registers used :
;                         a0  b0  x0  y0
;                         a1  b1      y1
;                         a2  b2
;
; Registers Changed :  
;                         r0  a0  b0  x0  y0  sr  n  m01
;                         r1  a1  b1      y1  pc
;                         r2  a2  b0          lc
;                         r3
; Flags                 :
;                         None
; Counters              :
;                         None
; Buffers               :
;                         tx_fm_buf(6L), tx_fm_coef_low(72L) or
;                         tx_fm_coef_high(72L), tx_out(12L), SIN_TBL(256C)
; Pointers              :
;                         gtone_ptr(C), tx_fm_coef(L),
; Memory locations      :
;                         tx_fm_gt_offset, gtamp
; Macros                :
;                         None
;
; ** Note :  In the ' Resources ' part of the template -
;            1. 'L' refers to Linear buffer/pointer to linear buffer
;            2. 'C' refers to Circular buffer/pointer to Circular buffer
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;****************************** Assembly Code *****************************

        SECTION V22B_TX 

        GLOBAL tx_fm

        org    p:
tx_fm
	move    #255,m01                  ;To access guard tone samples
	move    x:gtone_ptr,r0            ;Load pointer to guard tone table
	move    #tx_fm_buf,r1             ;Load address of 'fm' buffer
	move    x:tx_fm_coef,r3           ;Load pointer to filter coeffs.
	move    x:tx_fm_gt_offset,n       ;Load offset to address 256 point
                                      ;  table of gtone values
	move    x:(r1)+,x0                ;I(n)   -> x0
	move    x:(r1)+,y0                ;Q(n)   -> y0
	move    x:(r1)+,a0                ;I(n-1) -> a0
	move    x:(r1)+,b0                ;Q(n-1) -> b0
	move    a0,x:(r1)+                ;Save I(n-1) as I(n-2)
	move    b0,x:(r1)                 ;Save Q(n-1) as Q(n-2)
	move    #tx_fm_buf,r1             ;Load address of 'fm' buffer
	move    #tx_out,r2                ;Load starting address of output
	                                  ;  buffer
	move    a1,x:(r1)+                ;Save new I as I(n)
    move    b1,b
    neg     b
	move    b1,x:(r1)+                ;Save new Q as Q(n)
	move    x0,x:(r1)+                ;Save I(n) as I(n-1)
	move    y0,x:(r1)+                ;Save Q(n) as Q(n-1)
	
	move    x:gtamp,b                 ;Get guard tone amplitude
	
	move    #tx_fm_buf,b0             ;Load starting address of I and Q
               	                	  ;  buffer

	do      #12,loopfm                ;Counter for 12 samples
	move    b0,r1                     ;Load starting address of I and Q
                                      ;  buffer
	clr     a                         ;Sum = 0
	move    x:(r1)+,y0    x:(r3)+,x0  ;Get first I and First filter 
                                      ;  coefficient from memory
                                      ;Compute over 3 symbol duration
	mac     x0,y0,a       x:(r1)+,y0   x:(r3)+,x0
	mac     x0,y0,a       x:(r1)+,y0   x:(r3)+,x0
	mac     x0,y0,a       x:(r1)+,y0   x:(r3)+,x0
	mac     x0,y0,a       x:(r1)+,y0   x:(r3)+,x0
	mac     x0,y0,a       x:(r1)+,y0   x:(r3)+,x0
	mac     x0,y0,a    
                                      ;Multiply I and Q with correspo-
                                      ;  nding filter coefficients and
                                      ;  accumulate
    move    x:(r0)+n,y1
                                      ;Get guardtone(sine value)
	macr    b1,y1,a                   ;Add guard tone
	move    a,x:(r2)+                 ;Store the sample value in
                                      ;  output buffer

loopfm
	move    r0,x:gtone_ptr            ;Save current offset to guard
                                      ;  tone table.
	move    #$ffff,m01                ;r0 in linear addr. mode
end_tx_fm
	jmp     next_task

    ENDSEC

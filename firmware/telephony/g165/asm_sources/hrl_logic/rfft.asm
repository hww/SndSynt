;******************************* Function ************************************
;
;  Function Name  : rfft
;  Author         : Abhay Sharma
;
;**************************Revision History *******************************
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  19/10/95      0.0.1     Macro created                Abhay Sharma
;  22/10/95      1.0.0     Macro modified               Abhay Sharma
;  22/10/97      1.1.0     Macro modified:              Sim Boh Lim
;                          1. enable the rfft to access both internal
;                             and external data memory by introducing 2
;                             user-defined constants, FFT_DATA_INT_RAM and
;                             FFT_COEF_INT_XRAM;
;                          2. changes the parameter input buffer address
;                             #data to input buffer pointer address
;                             x:data_ptr;
;                          3. added calling requirements for stacks, m01 and
;                             hardware do loop resources, etc
;                          4. Added comments on the magnitude of the
;                             output spectrum
;  11/11/97      1.1.1     Reviewed and modified        Sim Boh Lim
;  10/07/00      1.1.2     Converted macros to          Sandeep Sehgal
;                          functions    
;
;*************************** Function Description *************************
;
;  This Function computes the square of the magnitude of the DFT of a real
;  sequence of length N by dividing it into two sequences, i.e., even and
;  odd sequences. The input x(n), n=0,..N-1 is arranged as a complex
;  sequence of length N/2 z[n]=x[2n]+j*x[2n+1] n=0,..N/2-1. The N/2 point
;  complex FFT of z[n] is z[k]. The final complex FFT of x[n] is x[k].
;  The magnitude square of x[k], which is X[k] k=0,..N/2, is sufficient
;  for the calculation of entire magnitude square X[k] k=0,..N-1.
;  The output is in block floating point format.
;
;**************************** Function Arguments **************************
;
;
;************************** Input and Output ******************************
;
;  Input  :
;       x[i], i=0,..,N-1     The real data input sequence stored from
;                            x:(x:data_ptr) to x:(x:data_ptr)+N-1
;                            (N locations)
;
;       coef[i], i=0,..,N/4  complex sin/cos coefficients required for
;                            the last pass coef[i] = cos(2*PI*k/N) +
;                            j.sin(2*PI*k/N) arranged as
;                            coef[0].imag, coef[0].real... and stored from
;                            x:coef to x:coef+N/2+1 (N/2+2 locations)
;
;       twid[i], i=0..N/4-1  complex twiddle factors for N/2 point FFT
;                            arranged in bitreversed order (N/2 locations)
;
;       FFT_DATA_INT_XRAM    For compilation purpose, used in FFTAS function
;                            Indicates that all of x[i], from x:(x:data_ptr)
;                            to x:(x:data_ptr)+N-1, are located in internal
;                            XRAM (FFT_DATA_INT_XRAM=1), in external XRAM (=0),
;                            or in unknown location of XRAM until linking
;                            time (=0)
;       FFT_COEF_INT_XRAM    For compilation purpose.
;                            Indicates that all of coef[i], from x:coef to
;                            x:coef+N/2+1, are located in internal XRAM
;                            (FFT_COEF_INT_XRAM=1), in external XRAM (=0),
;                            or in unknown location of XRAM until linking
;                            time (=0)
;
;  Output :
;       X[i], i=0,..,N/2     Square of the Magnitude of the FFT of input in
;                            double precision, stored from x:(x:data_ptr) to
;                            x:(x:data_ptr)+N+1, (N+2 locations).
;                            The output has been scaled down by is 4/(N*N).
;                            This means that if z[k] is the unscaled FFT,
;                            then X[i] contains |z[k]|*|z[k]|*4/(N*N)
;
;  Note:  1. If FFT_DATA_INT_XRAM is set to 1, then second parallel reads
;            (where appropriate) will be compiled and used resulting in
;            faster execution. Since DSP56800 only supports second parallel
;            reads on internal XRAM, all of x[i] have to be located in
;            internal XRAM for correct operation.
;         2. If FFT_DATA_INT_XRAM is set to 0, then x[i] can be located
;            in internal or external XRAM. This is because second parallel
;            reads (where appropriate) will not be compiled and used.
;         3. Likewise for FFT_COEF_INT_XRAM and coef[i]
;
;************************* Calling Requirements ***************************
;
;  1. To ensure that no overflow occurs at any point, the following
;     condition has to be satisfied.
;      x(2i)**2 + x(2i+1)**2 < 0.5   i = 0,..,N/2-1
;  3. The twiddle factors should be arranged in bit reversed order
;  4. The complex coefficients required must be provided in the order of
;     imaginary and real for all points
;  5. N must be a power of 2
;  6. Two additional output locations are required for the X[N/2] in
;     double precision storage, these locations should be after the input
;     data buffer.
;  7. At least 5 locations of software stacks must be available (for use
;     in fftas function)
;  8. m01 = $ffff for linear addressing
;  9. All hardware looping resources including LA, LC and 2 locations of HWS
;     must be available for use in nested hardware do loop
;  10. Constant FFT_DATA_INT_XRAM and FFT_COEF_INT_XRAM must be defined
;      to 1 or 0 by the calling module or during compilation.
;
;****************************** Functions called *******************************
;
;  1. fftas  : computes the Complex FFT
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           CFFT(z,N/2);             /* call N/2 point complex FFT */
;           z[N/2] = z[0];
;           For k = 0 to N/4
;               A = zr[k] + zr[N/2-k] 
;               B = zr[n/2-k] - zr[k] = 2*zr[N/2-k] - A
;               C = zi[k] + zi[N/2-k]
;               D = zi[k] - zi[N/2-k] = 2*zi[k] - C
;                
;               xr[k]=0.5(A+sin(2*pi*k/N)*B+cos(2*pi*k/N)*C; 
;               xi[k]=0.5(D-sin(2*pi*k/N)*C+cos(2*pi*k/N)*B;
;               X[k] = xr[k]**2+xi[k]**2;
;               xr[N/2-k]=0.5(A-sin(2*pi*k/N)*B-cos(2*pi*k/N)*C; 
;               /* xr[N/2-k] = A - xr[k] */
;               xi[N/2-k]=0.5(-D-sin(2*pi*k/N)*C+cos(2*pi*k/N)*B;
;               /* xi[N/2-k] = xi[k] - D */
;               X[N/2-k] = xr[N/2-k]**2+xi[N/2-k]**2;
;           Endfor
;       End
;
;****************************** Resources *********************************
;
;                        Icycle Count  : (Int P/X RAM, FFT_DATA_INT_XRAM = 1,
;                                         FFT_COEF_INT_XRAM=1)
;                                        1279  (N0 = 32)
;                                        2837  (N0 = 64)
;                                        6272  (N0 = 128)
;                                        13604 (N0 = 256)
;                                        29516 (N0 = 512)
;                                        64011 (N0 = 1024)
;                        Program Words : 198
;                        NLOAC         : 64
;
;  Address Registers used:
;                        r0 : points to the data buffer in linear
;                             addressing mode, also used by fftas function
;                        r1 : points to the data[k] in linear
;                             addressing mode, also used by fftas function
;                        r2 : used by fftas function
;                        r3 : points to the complex coefficients required
;                             for the final pass in linear addressing mode,
;                             also used by fftas function
;
;  Offset Registers used:
;                        n
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  n   a0  b0  x0  y0  sr
;                        r1      a1  b1      y1  pc
;                        r2      a2  b2
;                        r3
;
;**************************** Assembly Code *******************************


        SECTION HRL_RFFT_CODE

        include "equates.asm"
       
        GLOBAL  rfft
        
        org     p:
        
    
rfft    
					  ;N0=number of points in real FFT
					  ;N0 point data buffer starts at
                                          ;  x:(x:data_ptr)
					  ;N0/4+1 point complex coefficients
					  ;  required for the final pass
					  ;  starts at x:coef
					  ;N0/4 point complex twiddle factor
					  ;  buffer starts at x:twid
					  
		  
_Begin_rfft
    jsr		fftas   ;N0/2,data_ptr,twid

_Start1
    move    x:frm_buf_ptr,r1             ;r1 --> zr[0]
	move    #HRL_FRMLEN,n                     
	move    r1,r0                     ;r0 -->zr[0]
    move    #coefs,r3                  ;r3 -->1st complex coefficient
	lea     (r0)+n                    ;r0 -->zr[N/2-k]
	move    #-1,n                     ;n set for decrementing r1,r0,r3
	move    #HRL_FRMLEN/4,a1                  ;set loop counter
	move    x:(r1)+,y1                ;get zr[0] r1 --> zi[0]
	move    x:(r1),x0                 ;get zi[0] r1 --> zi[0]
	move    y1,x:(r0)+                ;zr[N/2]=zr[0] r0 --> zi[N/2]
	move    x0,x:(r0)                 ;zi[N/2]=zi[0] r0 --> zi[N/2]

	do      a1,_last                  ;for k=0 to (N/4+1)
	move    x:(r0)+n,b                ;get zi[N/2-k] 
	move    x:(r1)+n,a                ;get zi[k]
					  ;  r0 --> zr[N/2-k]
					  ;  r1 --> zr[k]
	add     a,b                       ;compute C              
	asl     a            b,x:(r1)+    ;Find 2*zi[k],save C at zr[k]
					  ;  r1->zi[k]
	sub     b,a          x:(r0)+,b    ;compute D = 2*zi[k] - C 
					  ;  get zr[N/2-k],r0 -> zi[N/2-k] 
	tfr     y1,a         a,x:(r0)+n   ;Get zr[k],save D at zi[N/2-k]  
					  ;  r0 --> zr[N/2-k]
	add     b,a          x:(r3)+,x0   ;compute A ,get sin(2*pi*k/N)
					  ;  r3 --> cos(2*pi*k/N)
	asl     b                         ;Find 2*zr[N/2-k]                  
	sub     a,b          x:(r1)+n,y0  ;compute B,dummy read
					  ;  r1 --> zr[k] or C 
	move    b,y0                      ;Save B


        mpy     x0,y0,b      x:(r1)+,y1
        move    x:(r3)-,x0
                                          ;Compute sin(2PIk/N)*B
					  ;  get C ,r1 --> zi[k]
					  ;  get cos(2*pi*k/N)   
					  ;  r3 --> sin(2*pi*k/N)   
	macr    y1,x0,b      x:(r1)+n,x0  ;compute sin(2PIk/N)*B+
					  ;  cos(2PIk/N)*C
					  ;  dummy read ,r1 -> zr[k]
	add     a,b          x:(r3)+,x0   ;compute 2*xr[k],dummy read
					  ;  r3 -> cos(2*pi*k/N)
	asr     b            x:(r3)+n,x0  ;compute xr[k],get cos(2*pi*k/N) 
					  ;  r3 --> sin(2*pi*k/N) 
	sub     b,a          b,x:(r0)+    ;compute xr[N/2-k]
					  ;  save xr[k] at zr[N/2-k]
					  ;  r0 ->zi[k]
        mpy     y0,x0,b      x:(r0)+n,y0
        move    x:(r3)+,x0
					  ;compute B*cos(2*pi*k/N)
					  ;  get D,r0 -> zr[N/2-k]
					  ;  get sin(2*pi*k/N)
					  ;  r3 -> cos(2*pi*k/N) 
	mac    -y1,x0,b                   ;compute -C*sin(2*pi*k/N)+
					  ;  B*cos(2*pi*k/N)
	add      y0,b        x:(r3)+,x0   ;compute 2*xi[k],dummy read
					  ;  r3 -> sin(2*pi*(k+1)/N)
	asr      b           a,x:(r1)+    ;compute xi[k],save xr[N/2-k]
					  ; at zr[k],r1 -> zi[k]
	sub      y0,b        b,x:(r1)+n   ;compute xi[N/2-k],save xi[k]
					  ;  at zi[k],r1 -> zr[k]
	move    b,y0                      ;save xi[N/2-k] 
	mpy     y0,y0,b      x:(r1)+,y0   ;compute xi[N/2-k]**2,
					  ;  get xr[N/2-k], r1 --> zi[k]
	mac     y0,y0,b      x:(r1)+n,y0  ;compute magnitude square of
					  ;  x[N/2-k],get xi[k]
					  ;  r1 --> zr[k]
	mpy     y0,y0,a      x:(r0)+,y0   ;compute xi[k]**2
					  ;  get xr[k], r0 -> zi[N/2-k]
	move    b0,x:(r0)+n               ;zi[N/2-k]=LSB of |x[N/2-k|**2 
					  ; r0 -> zr[N/2-k] 
	mac     y0,y0,a      b,x:(r0)+n  ;compute magnitude square of x[k]
					  ;  zr[N/2-k]=MSB of |x[N/2-k]|**2
					  ;  r0 --> zr[N/2-(k+1)]
	move    a,x:(r1)+                 ;zr[k]=MSB of |x[k]|**2
	move    a0,x:(r1)+                ;zi[k]=LSB of |x[k]|**2
					  ;  r1 --> zr[k+1]
					  ;  r0 --> zi[N/2-k-1]
	move    x:(r1)+,y1                ;get zr[k+1],r1 -> zi[k+1]
					  ;  r1 -> zi[k+1] 
_last
					  ;computations for k=N/4+1
					  ; at this stage r0 = r1
	move    y1,y0                      
	mpy     y0,y0,a       x:(r1)+n,y0
	mac     y0,y0,a
	move    a,x:(r1)+
	move    a0,x:(r1)
_end_rfft

	rts


    ENDSEC
;****************************** End of file *******************************

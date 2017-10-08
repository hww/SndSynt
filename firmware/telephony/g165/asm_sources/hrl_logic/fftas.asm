;****************************** Function **********************************
;
;  Function Name   : fftas
;  Author          : Abhay Sharma , Sanjay S.K.
;  Modified by     : Sandeep Sehgal
;
;**************************Revision History *******************************
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  11/10/95      0.0.1     Macro created                Abhay Sharma
;                                                       Sanjay S.K.
;  18/10/95      1.0.0     Macro modified               Abhay Sharma
;                                                       Sanjay S.K.
;  22/10/97      1.1.0     Macro modified:              Sim Boh Lim
;                          1. enable the fft to access both internal
;                             and external data memory by introducing a
;                             user-settable constant FFT_DATA_INT_RAM;
;                          2. changes the parameter input buffer address
;                             #data to input buffer pointer address
;                             x:data_ptr.
;                          3. Added lea (sp)+ before first use of stack
;                             pointer sp, and change last access to pop r2
;                             from x:(sp),r2
;                          4. Added calling requirements for stacks, m01 and
;                             hardware do loop resources, etc
;  11/11/97      1.1.1     Reviewed and modified        Sim Boh Lim
;  10/07/00      1.0.2     Converted macros to          Sandeep Sehgal
;                          functions    
;
;*************************** Function Description *************************
;
; 1. length : Number of points in FFT
; 2. data_ptr : Address of pointer to input buffer
; 3. twid   : Address of twiddle factors (stored in bit reversed order)
;
;***************************** Input and Output ***************************
;
; Input: Complex X(k) k=0,...,N-1. X(k) = Xr(k) + jXi(k)
;        Real and imaginary parts stored consecutively from x:data
;        to x:data+2*N-1, where data = x:data_ptr
;
;       FFT_DATA_INT_XRAM    For compilation purpose
;                            Indicates that all of x[n], from x:(x:data_ptr)
;                            to x:(x:data_ptr)+N-1, are located in internal
;                            XRAM (FFT_DATA_INT_XRAM=1), in external XRAM (=0),
;                            or in unknown location of XRAM until linking
;                            time (=0)
;
; Output: Complex X(k) k=0,...,N-1. X(k) = Xr(k) + jXi(k)
;         Real and imaginary parts stored consecutively from x:data
;         to x:data+2*N-1, where data = x:data_ptr
;
; NOTE :  Storage sequence is:Xr(0),Xi(0),Xr(1),Xi(1),..,Xr(N-1),Xi(N-1)
;         for both input and output
;         data is the location poited to by x:data_ptr
;
;*************************** Calling Requirements *************************
;
;  1. User has to provide input data in the following manner :
;     N point complex data from x:(x:data_ptr), with real and imaginary
;     values alternating.
;  2. To ensure that no overflow occurs at any point, the magnitude of 
;     every complex input data point must be < 1.0.
;         Xr(k)**2 + Xi(k)**2 < 1.0 for every k.
;  3. The twiddle factors must be provided in bit reversed order
;  4. N must be a power of 2
;  5. m01 = $ffff for linear addressing
;  6. At least 5 locations of software stacks must be available
;  7. All hardware looping resources including LA, LC and 2 locations of HWS
;     must be available for use in nested hardware do loop
;  8. Constant FFT_DATA_INT_XRAM must be defined to 1 or 0 by the calling
;     module or during compilation.
;
;****************************** Misc. Comments ****************************
;
;  1. Input data buffer need not be defined as modulo buffer.
;  2. All computations are in-place. 
;  3. Function 'bitrev_ip' from 'bitrev.asm' is called at the end of this 
;     Function
;  4. The rounding operation done here closely resembles the autoscale
;     rounding of DSP56100.
;
;**************************** Function Arguments **************************
;
;       This Function computes an N point DFT of a complex input sequence
;       using radix-2 DIT FFT.
;       Scaling down is done in all passes to avoid overflow. The output  
;       is the actual DFT value scaled down by N.
;
;       /* Scaling down is explicitly done */
;
;******************************* Pseudo Code ******************************
;
;               L=log(N)
;               for M=1 to L do
;                   Pass_M(M,N,X(0),...X(N-1))
;               endfor
;
;               Pass_M(M,N,X(0),..,X(N-1)) is given below :
;
;               for G=1 to 2**(M-1) do
;                   r=(G-1) in bit reversed format ((L-1) bits)
;                   W=WN**r   /* WN is the nth root of unity */ 
;                   Base=(N/(2**M))*2*(G-1)
;                   for bfly=0 to (N/(2**M))-1 do
;                       index=Base + bfly
;                       A = X(index)
;                       B = X(index+N/(2**M))
;                       Butterfly(A,B,W,C,D)
;                       X(index) = C
;                       X(index+N/(2**M)) = D
;                   endfor /* butterfly loop */
;               endfor     /* group loop */
;
;               Butterfly(A,B,W,C,D) is given below :
;
;               Cr = Ar + WrBr + WiBi
;               -Ci = -Ai - WrBi + WiBr
;               Dr = 2Ar - Cr
;               Di = 2Ai + (-Ci)
;               /* for first pass the butterfly computation becomes
;                  very simple since Wi= zero & Wr = 1*/  
;
;******************************* Resources ********************************
;
;                    Icycle Count  : (Int P/X RAM, FFT_DATA_INT_XRAM = 1)
;                                    1027  (N = 32)
;                                    2352  (N = 64)
;                                    5302  (N = 128)
;                                    11725 (N = 256)
;                                    25781 (N = 512)
;                                    56564 (N = 1024)
;                    Program Words : 146
;                    NLOAC         : 119
;
; Address Registers used : 
;                    r0 : used to address twiddle factors (Wr,Wi) in linear
;                         addressing mode 
;                    r1 : used to address inputs (Ar,Ai), outputs (Cr,Ci)
;                    r2 : used to address outputs (Dr,Di), in linear 
;                         addressing mode
;                    r3 : used to address inputs (Br,Bi), in linear 
;                             addressing mode
;
; Offset Registers used :
;                    n  : used as counter for number of butterflies per
;                         group & offset between groups of butterflies
;
; Data Registers used :
;                        a0  b0  x0  y0 
;                        a1  b1      y1   
;                        a2  b2
;
; Registers Changed :  
;                        r0  n   a0  b0   x0   y0   sr
;                        r1      a1  b1        y1   pc
;                        r2      a2  b2                             
;                        r3
;
;****************************** Assembly Code *****************************

    SECTION HRL_RFFT_CODE 

    include "equates.asm"


    GLOBAL  fftas
    
fftas                                   ;length=N, the number of FFT pts
                                        ;N point complex data buffer starts
                                        ;  at x:(x:data_ptr)
                    					;N/2 point complex twiddle factor
					                    ;  buffer starts at x:twid

_passes  equ     @cvi(@log(HRL_FRMLEN/2)/@log(2)+0.5)
					;Set number of passes to log2(N)


_Begin_fft
    move    x:frm_buf_ptr,r1            ;r1 -> 1st Ar of 1st pass
	move    #HRL_FRMLEN/2,n             ;offset for pointing to 1st Br 
                       					;  of first pass
                     					;n set to N, used for controlling
					                    ;  the number of butterflies per
                     					;  group in the pass. 
	move    r1,r3                       ;r3 -> 1st Ar of first pass
	move    r1,r2                       ;r2 -> 1st Ar of first pass
	lea     (r3)+n                      ;r3 -> 1st Br of 1st pass
	move    n,b                         ;Find no. of butterflies in
	asr     b                           ;  first pass , which is half 
	move    b,n                         ;  half the no. of DFT points
	move    r3,r0                       ;r0 -> 1st Br of first pass
	move    x:(r1)+,a                   ;Get 1st Ar of 1st pass 
	lea     (r0)-                       ;Adjust r0 so that in first 
					                    ;  pass previous Di could be
	                    				;  written in a parallel move 
    move    x:(r0),b                    ;Save the memory cotents so 
                    					;  that first parallel move 
					                    ;  doesn't corrupt the data 
	move    x:(r3)+,y0                  ;Get 1st Br of 1st pass
	do      n,_first_pass               ;The first pass has to be 
                    					;  repeated length/2 times
	add     y0,a    b,x:(r0)+           ;Find Cr,save Di in previous 
					;  Bi. r0 -> Br 
	asr     a       x:(r1)+,b           ;Find Cr/2,get Ai,r1 -> next Ar 
	rnd     a       x:(r3)+,x0          ;round, get Bi, r3 -> next Br 
	sub     y0,a    a,x:(r2)+           ;Find Dr/2 ,save Cr/2,r2 -> Ci 
	add     x0,b    a,x:(r0)+           ;Find Ci,save Dr/2 ,r0 ->Di
	asr     b       x:(r1)+,a           ;Find Ci/2, get next Ar,
					;  r1 -> next Ai
	rnd     b       x:(r3)+,y0          ;round Ci/2, get next Br,
					;  r3 -> next Bi
	sub     x0,b    b,x:(r2)+           ;Find Di/2, save Ci/2 ,
                      					;  r2 -> next Cr. Di/2 saved
                    					;  in the next loop 
_first_pass
	move    b,x:(r0)                    ;Save last Di/2 of the 1st pass 
    move    x:frm_buf_ptr,r1            ;r1 -> 1st Ar of 2nd pass
	move    r1,r3                       ;r3 -> 1st Ar of 2nd pass
                     					;n set to N, used for 
                    					;  controlling the no.of bflies
					                    ;  per group in the pass. 
    move    #<2,r2                      ;r2 set to 2,used for controlling
                    					;  the no. of groups in the pass
	lea     (r3)+n                      ;r3 -> first Br of second pass
	move    #(_passes-3),r0             ;Set counter for no. of passes
                    					; last pass is also separate
_second_pass
    lea     (sp)+                       ;Move to unused stack location
	move    r2,x:(sp)+                  ;Save r2 & r0 on software stack
	move    r0,x:(sp)+               
	move    #twids,r0                   ;r0 ->mem. location of the first  
                    					;  twiddle fac. ,twiddle fac. 
					                    ;  stored in bit reversed fashion
	move    n,b                         ;Move n to b for halving
	asr     b                           ;  n =n/2 
	move    b,n                         ;  butterflies per group is n
	move    r2,b                        ;Save the no. of groups/passin b
	move    r3,r2                       ;r2 -> first Br of the first pass        
	do      b,_end_group                ;Middle loop is done b times
                    					;  b=2**(pass number-1)
					                    ;  b = no. of groups/pass 
	move    la,x:(sp)+                  ;Save the current lc and 
	move    lc,x:(sp)+                  ;  la onto software stack
        move    x:(r0)+,y0
        move    x:(r3)+,x0                  ;y0=Wr,x0=Br,r0 ->Wi, r3 ->Bi
	move    x:(r0)+,y1                  ;y1=Wi, r0 -> next Wr
                       					;  (in bit reversed order)
	move    r0,x:(sp)                   ;Save twiddle factor 
	move    r1,r0                       ;Move r1 to r0
	lea     (r2)-

	move    x:(r2),b                    ;Save the contents so that the 
                    					;  mem. contents aren't corrupted
					                    ;  in the first middle loop
	do      n,_end_bfly                 ;Inner loop is done n times
                     					;  n=2**(L-passnumber)
                    					;  n=no. of butterflies/group
	mpy     y0,x0,b      b,x:(r2)+      ;b=WrBr,store the previous 
					                    ;  butterfly's Di,r1->current Ar
	mpy     y1,x0,a      x:(r3)+,x0     ;a=+WiBr,get Bi
	mac     -y0,x0,a                    ;a=-WrBi+WiBr
	mac     y1,x0,b      x:(r1)+,x0     ;b=WrBr+WiBi,x0=Ar,r1 -> Ai
	add     x0,b                        ;Find Cr in b
	asr     b                           ;b=Cr/2,Scale down for storage
	rnd     b                           ;Round.The rounding done here 
                    					;  closely matches with the  
					                    ;  autoscale mode rounding
	sub     b1,x0                       ;Find Dr/2
	neg     a            b,x:(r0)+      ;a= WrBi-WiBr
                      					;  Store Cr/2
	move    x:(r1)+,b                   ;fetch Ai into b,r1 -> next Ar
	add     b,a          x0,x:(r2)+     ;Find Ci ,store Dr/2,r2 -> Di
	asr     a            x:(r3)+,x0     ;a=Ci/2,x0 = Next Br, 
                    					;  r3 -> Next Bi
	rnd     a                           ;Round
	sub     a,b          a,x:(r0)+      ;b = Di/2, a = Ci/2
					                    ;  store Ci/2
                    					;  Di/2 stored in next loop 
_end_bfly                                 


	move    b,x:(r2)+               ;Store last butterfly's Ci
	pop     r0                      ;Restore the pointer pointing
					                ;  to the twiddle factors
	pop     lc                      ;Restore lc
	move    x:(sp),la               ;Restore la 
	move    r2,r1                   ;r1 -> next group's first Ar
	lea     (r2)+n                   
	lea     (r2)+n                  ;r2 -> next group's first Br
	move    r2,r3                   ;r3 -> next group's first Br
_end_group
	lea     (sp)-
	pop     r0                      ;Restore no. of passes
    pop     r2                      ;Restore no. of group's
    move    x:frm_buf_ptr,r1        ;r1 ->1st Ar,at start of each pass
	move    r1,r3                   ;r3 ->1st Ar,at start of each pass
	move    r2,b                    ;double the no of groups for next
	asl     b            x:(r3)+n,x0
                   					;  pass,Dummy read  to adjust r3
					                ;  r3 -> first Br of the next pass
	move    b,r2                      
	tstw    (r0)-                   ;Test the pass counter for Zero
	bne     _second_pass            ;If less than zero then go to 
                        			;  last pass 
	move    #twids,r0               ;Get address of twiddle factors 
	do      b,_last_pass            ;N/2 groups in last pass
        move    r3,r2

        move    x:(r0)+,y0
        move    x:(r3)+,x0          ;y0=Wr,x0=Br,r0 -> Wi,r3 -> Bi

	mpy     x0,y0,b      x:(r0)+,y1 ;b=BrWr, y1=Wi, r0 ->Next Wr
	mpy     y1,x0,a      x:(r3)+,x0 ;a=WiBr 
	mac     -y0,x0,a                ;a=-WrBi+WiBr
	mac     y1,x0,b      x:(r1)+,x0 ;b=WiBi+WrBr, x0=Ar, r1 -> Ai
	add     x0,b                    ;Find Cr
	asr     b                       ;Find Cr/2
	rnd     b                       ;Round
	sub     b1,x0                   ;Find Dr/2 
	move    b,x:(r1+$ffff)          ;Store Cr/2 , r1 -> Ai 
	move    x:(r1)+,b               ;b = Ai, r1 -> Ai
	sub     b,a         x0,x:(r2)+  ;Find -Ci , store Dr/2,r2 ->Di
	asr     a           x:(r3)+n,x0 ;Find -Ci/2, Dummy read to 
                					;  adjust r3 to next Br
	rnd     a
	add     a,b         x:(r1)+n,x0 ;Find Di/2,Dummy read to 
				                	;  adjust r1
	neg     a           b,x:(r2)+   ;Find Ci/2 ,store Di/2 
	move    a,x:(r1+$fffd)          ;Store Ci/2
_last_pass
        ;bitrev_ip    length,data_ptr    ;Bit-reverse output to get
                 					;  DFT points
_End_fft

	rts


    ENDSEC
;******************************* End **************************************

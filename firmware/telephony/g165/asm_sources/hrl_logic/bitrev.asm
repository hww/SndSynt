;********************************* Function **************************************
;
;  Function Name   : bitrev_ip
;  Author          : Abhay Sharma , Sanjay S.K.
;  Modified by     : Sandeep Sehgal
;
;**************************Revision History *******************************
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  09/10/95      0.0.1     Macro created                Abhay Sharma
;                                                       Sanjay S.K.
;  12/10/95      1.0.0     Macro modified               Abhay Sharma
;                                                       Sanjay S.K.
;  22/10/97      1.1.0     Macro modified:              Sim Boh Lim
;                          1. changes the parameter input buffer address
;                             #data to input buffer pointer address
;                             x:data_ptr.
;                          2. Added calling requirements for m01 and
;                             hardware do loop resources
;  11/11/97     1.1.1     Reviewed and modified        Sim Boh Lim
;
;  10/07/00     1.1.2     Converted macros to        Sandeep Sehgal
;                         functions    
;
;**************************** Function Arguments **************************
;
; 1. length   : Number of points (M) in data buffer
; 2. data_ptr : Address of pointer to data buffer in X memory
;
;***************************** Input and Output *******************************
;
; Input:    Complex X(k) k=0,...,M-1. X(k) = Xr(k) + jXi(k)
;           Real and imaginary parts stored consecutively from x:data to 
;           x:data+2*M-1, where data = x:data_ptr.
;
; Output:   Complex X(k) k=0,...,M-1. X(k) = Xr(k) + jXi(k)
;           Real and imaginary parts stored consecutively from x:data to 
;           x:data+2*M-1, where data = x:data_ptr.
;
; NOTE :    Storage sequence is : Xr(0),Xi(0),Xr(1),Xi(1),....,Xr(M-1),Xi(M-1)
;           for both input and output
;           data is the location poited to by x:data_ptr
;
;*************************** Calling Requirements *****************************
;
;  1. User has to provide input data in the following manner :
;        M point complex data from x:(x:data_ptr), with real and imaginary
;        values alternating.
;  2. M must be a power of 2
;  3. m01 = $ffff for linear addressing
;  4. All hardware do loop resources, including 2 HWS, LA, LC, etc, must
;     be available
;
;****************************** Misc. Comments ********************************
;
;  1. Input data buffer need not be defined as modulo buffer.
;  2. All computations are in-place.
;
;*************************** Function Description *************************
;
;       This function performs an M point in-place bit reversal of a 
;       complex input sequence X(k), k=0,1,..,M-1 .
;
;******************************* Pseudo Code **********************************
;
;               IND = 1
;               K   = 1
;               NUM = M
;               for loop= 1 to M-2 do
;                   IND = Bit_rev_ind (IND)
;               /* Bit_rev_ind() reverses the bits of IND */             
;                   If (IND > K)
;                      Swap Xr(K) & Xr(IND)
;                      Swap Xi(K) & Xi(IND)
;                      K = K + 1           
;                      IND = K
;                   endif
;               endfor
;
;******************************* Resources ************************************
;
;                        Icycle Count  :
;                                        372   (M = 32)
;                                        832   (M = 64)
;                                        1852  (M = 128)
;                                        3993  (M = 256)
;                                        8617  (M = 512)
;                                        18257 (M = 1024)
;                        Program Words : 38
;                        NLOAC         : 41
;
; Address Registers used :
;                        r1 : used to point to Xr(IND) & Xi(IND), in linear
;                             addressing mode
;                        r3 : used to point to Xr(K) & Xi(K), in linear
;                             addressing mode
;                        r2 : used as storage register
;                        r0 : used as storage register
; Offset Registers used :
;                         n : used as storage register
;
; Data Registers used :
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
; Registers Changed :
;                        r0    n    a0    b0    x0    y0   sr
;                        r1         a1    b1          y1   pc
;                        r2         a2    b2
;                        r3
;
;****************************** Assembly Code *********************************
HRL_FRMLEN        equ      128

bitrev_ip                                 ;length=M , the number of points in
                                          ;   the complex data buffer
                                          ;M point complex data buffer starts
                                          ;  at x:(x:data_ptr)
_begin_bitrev_ip
        move    x:frm_buf_ptr,y0          ;Set y0 to the base of data buffer
        move    y0,b
        inc     b
        inc     b
        move    b,r3                      ;Set r3 to point to 2nd complex data
        move    y0,r1                     ;Initialize r1
        move    #<1,x0                    ;Set IND = 1
	    move	x0,b                      ;Set  K = 1
	    move    x:(r1),y1                 ;Done so that the first write using
	    move    #(HRL_FRMLEN/2-2),r2	  ;  r1 in the loop does not over-
                    					  ;  write the useful data . 
        clr     a                         ;Clear acc
	                                      ;Move zero to acc
	do      r2,_endl1                     ;Bit reversal is done for data point
					                      ; 1 to M-2
	move    lc,r2                     ;Save lc and la before entering the
	move    la,r0                     ; the second do loop (for reversing
					                  ;  the IND bits)
_N1      equ    @l10(HRL_FRMLEN/2)
_N2      equ    @l10(2)
_N3      set    @cvi(_N1/_N2)

	do     #_N3,_endl                 ;log2(M) = N3
	lsr    x0                         ;Get L_bit into carry,(x_reg>>1)
	rol    a                          ;L_bit_acc = carry, (acc<<1)
_endl                                 ;Code for bit reversal
                					  ; destroys IND (in x0) and
				                	  ; Bit_rev_ind in a  
	move    r0,la                     ;Get back loop address
    move    r2,lc
	cmp     b,a	x:(r3)+,x0            ;Compare IND & K,get Xr(K)
                					  ;  r3 -> Xi(K)
	ble     _no_swap                  ;If IND <= K ,don't swap
	asl     a       y1,x:(r1)+        ;Double Bit_rev_ind to get the 
					                  ; correct offset for Xr(K),Write
				                	  ; previous Xi(K) to Xi(IND)
	add     y0,a                      ;Get actual address for fetching
                					  ; Xr(IND).( add base address to the
				                	  ; offset value)
	move    a,r1                      ;Move actual address to addr. reg
	move    x:(r3)-,y1                ;Get Xi(K), r3 -> Xr(K)
	move    x:(r1)+,n                 ;Get Xr(IND), r1 -> Xi(IND)
	move    n,x:(r3)+                 ;Move Xr(IND) to Xr(K), /*SWAP*/
                					  ;  r3 -> Xi(K)
	move    x:(r1)-,n                 ;n = Xi(IND), r1 -> Xr(IND)
	move    n,x:(r3)                  ;Move Xi(IND) to Xi(K) /*SWAP*/
				                  	  ;  r3 -> Xi(K)
	move    x0,x:(r1)+                ;Move Xr(K) to Xr(IND)
_no_swap
    clr     a 
	inc     b 	x:(r3)+,x0            ;K = K + 1
                  					  ; dummy read to x0, r3 -> next 
				                 	  ; Xr(K) 
	move    b,x0                      ;IND = K
_endl1
	move    y1,x:(r1)                 ;Write last Xi(K) to Xi(IND)
_end_bitrev_ip

	rts



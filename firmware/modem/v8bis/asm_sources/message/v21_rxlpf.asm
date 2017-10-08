;***************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
; 
;  FILE NAME            : v21_rxlpf.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo
;
;  DATE CREATED         : 30/03/98 
;
;  FILE DESCRIPTION     : This module performs 3rd order butterworth 
;                         IIR LPF. The output is decimated before storing.
;                          
;  FUNCTIONS            : V21_RxLpf 
;
;  MACROS               : Nil 
;
;***************************************************************************
        
        include "v8bis_equ.asm"
        
        SECTION V21_RxLpf
 
        GLOBAL  V21_RxLpf   
     
;****************************** Module ************************************
;
;  Module Name    : V21_RxLpf 
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
; 
; This module implements 3rd order butterworth IIR LPF ,using transpose
; structure. The cut off frequency is 250 Hz.
; The grp. delay is 10.05. The output of LPF is decimated before storing.
; The equations are :
; 
;  y(n) = [ b0*x(n) + b1*x(n-1) + b2*x(n-2) + b3*x(n-3)
;           -a1*y(n-1) - a2*y(n-2) -a3*y(n-3) ]
; Where
;        y(n)=Output sample at time_index n
;        x(n)=Input sample at time_index n 
;        b = [0.0011 0.0032 0.0032 0.0011 ];
;        a = [1.000  -2.5645 2.2188 -0.6458 ]i;
;  In transpose method of implementation :
;
;  w(n) = x(n) - a1*w(n-1) - a2*w(n-2) - a3*w(n-3)
;  y(n) = b0*w(n) + b1*w(n-1) + b2*w(n-2) + b3*w(n-3)
; 
;  where 
;       w(n) = filter state inputs
;  As the co_efficients varies between -3 to +3 , equations are modified to 
;
;  w(n) = [b0*x(n) - a1/4*w(n-1) - a2/4*w(n-2) - a3/4*w(n-3)]*4
;  y(n) = w(n)/4 + b1/4b0*w(n-1) + b2/4b0*w(n-2) + b3/4b0*w(n-3)
;  
;  Calls :
;        Modules : None 
;        Macros  : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  14/05/98     Minati             Incorporated Review Comments
;  03/07/2000   N R Prasad         Ported on to Metrowerks.
;  07/08/2000   N R Prasad         Internal memory moved to 
;                                  external; hence dual parallel
;                                  moves converted into single
;                                  parallel moves.
;
;************************* Calling Requirements ***************************
;
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. Input Samples in x:fs_rl_buf/fs_im_buf
;     r1 -> fs_rl_buf/fs_im_buf
;     fs_rl_buf/fs_im_buf = | sfff ffff | ffff ffff |
;   
;  2. Filter coefficients in x:LPF_COEF
;     These are stored in X Rom in the order -> 
;     -a3/4,-a2/4,-a1/4,b0,b3/4*b0,b2/4*b0,b1/4*b0,
;     -a3/4,-a2/4,-a1/4,b0,-a3/4
;     LPF_COEF = | sfff ffff | ffff ffff |      
;
;  3. Filter state inputs in x:lpfst_rl_buf/lpfst_im_buf.
;     These are circular buffers of length 3 each.
;     r0 -> lpfst_rl_buf/lpfst_im_buf
;     lpfst_rl_buf/lpfst_im_buf = | sfff ffff | ffff ffff |
;          
;  Output :
;
;  1. Output samples in x:lpfout_rl_buf/lpfout_im_buf
;     r2 -> lpfout_rl_buf/lpfout_im_buf
;     lpfout_rl_buf/lpfout_im_buf = | sfff ffff | ffff ffff |
;
;  2. Updated filter states in x:lpfst_rl_buf/lpfst_im_buf
;     lpfst_rl_buf/lpfst_im_buf = | sfff ffff | ffff ffff |
;
;****************************** Resources *********************************
;
;  Registers Used:       a,b,x0,y0,y1,r0-r3,m01,n
;
;  Registers Changed:    a,b,x0,y0,r0-r3,m01
;                        
;  Number of locations 
;    of stack used:      Nil 
;
;  Number of DO Loops:   1              
;
;**************************** Assembly Code *******************************


        ORG     p:

V21_RxLpf    


        move    #LPF_COEF,r3              ;r3 -> LPF_COEF
        move    #(LPF_ORDER-1),m01        ;modulo 3
        move    m01,n
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;y0 = w(-3) ; r0 -> w(-2) 
                                          ;  x0 = -a3/4 ; r3 -> -a2/4
        move    r3,y1                     ;store r3 in y1
        
        do      #(SAMPLES_PER_BAUD/2),_lp_filter
                                          ;for n = 0 to 12 do LPF 
                                          ;  and Decimation

        mpy     x0,y0,a      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;w(n) = -a3*w(n-3)/4
                                          ;  y0 = w(n-2) ; r0 -> w(n-1) 
                                          ;  x0 = -a2/4 ; r3 -> -a1/4
        mac     x0,y0,a      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;w(n) += -a2*w(n-2)/4 
                                          ;  y0 = w(n-1) ; r0 -> w(n-3) 
                                          ;  x0 = -a1/4 ; r3 -> b0 
        mac     x0,y0,a      x:(r1)+,y0  
        move    x:(r3)+,x0
                                          ;w(n) += -a1*w(n-1)/4  
                                          ;  y0 = x(n) ; r1 -> x(n+1) 
                                          ;  x0 = b0 ; r3 -> b3/4*b0 
        mac     x0,y0,a      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;w(n) += b0*x(n)
                                          ;  y0 = w(n-3) ; r0 -> w(n-2)
                                          ;  x0 = b3/4*b0 ; r3 -> b2/4*b0
        mpy     x0,y0,b      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;y(n) = b3*w(n-3)/4*b0
                                          ;  y0 = w(n-2) ; r0 -> w(n-1) 
                                          ;  x0 = b2/4*b0 ; r3 -> b1/4*b0 
        mac     x0,y0,b      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;y(n) += b2*w(n-2)/4*b0 
                                          ;  y0 = w(n-1) ; r0 -> w(n-3)  
                                          ;  x0 = b1/4*b0 ; r3 -> -a3/4
        add     a,b                       ;y(n) = y(n) + w(n)
        macr    x0,y0,b      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;y(n) += b1*w(n-1)/4*b0  
                                          ;  y0 = w(n-3) ; r0 -> w(n-2)  
                                          ;  x0 = -a3/4 ; r3 -> -a2/4 
        asl     a            x:(r0)+n,y0  ;w(n) = w(n)*2
                                          ;  y0 = w(n-2) ; r0 -> w(n-3) 
        asl     a            b,x:(r2)+    ;w(n) = w(n)*2
                                          ;  store output y(n)
        rnd     a
        move    a,x:(r0)+n                ;store w(n) in w(n-3) position
                                          ;  r0 -> w(n-1) 
        mpy     x0,y0,a      x:(r0)+,y0  
        move    x:(r3)+,x0
                                          ;w(n+1) = -a3*w(n-2)/4
                                          ;  y0 = w(n-1) ; r0 -> w(n)
                                          ;  x0 = -a2/4 ; r3 -> -a1/4
        mac     x0,y0,a      x:(r0)+n,y0 
        move    x:(r3)+,x0
                                          ;w(n+1) += -a2*w(n-1)/4
                                          ;  y0 = w(n) ; r0 -> w(n-1)
                                          ;  x0 = -a1/4 ; r3 -> b0
        mac     x0,y0,a      x:(r1)+,y0  
        move    x:(r3)+,x0
                                          ;w(n+1) += -a1*w(n)/4
                                          ;  y0 = x(n+1) ; r1 -> x(n+2)
                                          ;  x0 = b0 ; r3 -> -a3/4 
        mac     x0,y0,a      x:(r0)+n,y0 
        move    x:(r3)+,x0
                                          ;w(n+1) += b0*x(n+1) 
                                          ;  y0 = w(n-1) ; r0 -> w(n-2) 
                                          ;  x0 = -a3/4  
        move    y1,r3                     ;r3 -> -a2/4 
        asl     a                         ;w(n+1) = w(n+1)*2
        asl     a                         ;w(n+1) = w(n+1)*2
        rnd     a
        move    a,x:(r0)+n                ;store w(n+1) in w(n-2) position
                                          ;  r0 -> w(n)
                                          
_lp_filter

        lea     (r0)+n   
        move    #-1,m01                   ;set up for linear arithmetic

        rts

        ENDSEC


;********************************** End of File ***************************

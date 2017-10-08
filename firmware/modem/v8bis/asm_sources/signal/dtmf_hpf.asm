;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : dtmf_hpf.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 18:03:98
;
; FILE DESCRIPTION     : High Pass filtering. 
;
; FUNCTIONS            : Dtmf_Hpf  
;
; MACROS               : -
;
;************************************************************************
  
         include  'tone_set.asm'
         include  'v8bis_equ.asm'
         
         SECTION  dtmf_hpf
         GLOBAL   Dtmf_Hpf


;**************************** Module ****************************************
;
;  Module Name   :  Dtmf_Hpf
;  Author        :  G.Prashanth
   
;************************* Module Description ******************************
;
; This module performs the High pass filtering. 
; The Highpass filter is a 4th order Chebyshev IIR with cutoff at 
;  1250hz and 0.5dB of passband ripple.
;
;      the equation is :
;      y(n) = [ b1*x(n) + b2*x(n-1) + b3*x(n-2) + b4*x(n-3) + b5*x(n-4)
;             + a2y(n-1) + a3y(n-2) + a4y(n-3) + a5y(n-4) ]
;
;      Each of the coefficients are scaled by 2 and stored since one of
;      the coefficient exceeds 1,and the numerator coefficients are 
;      negated and stored to simplify the computation for macc.
;
;   Calls   : N/A
;   Macros  : N/A
;
;************************ Revision History ***************************
;
;     Date                Person          Description 
;    ------              --------           --------
;  26:02:98           G.Prashanth        Module Created  
;  02:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks.
;  10:08:2000         N R Prasad
;                     and Sanjay         Roles of r3 and r0 interchanged
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
;
;************************ Calling Requirements ********************** 
;
;  1.  Define the HPF_coefficients
;  2.  Initial 8 samples are set to zero
;
;************************  Input and Output ************************
;
;  
;   1. Filter coefficients in x:HPF_mscratch
;   2. Input samples pointer in x:(sp-2)
;     
;        msgWord       = | s.fff ffff | ffff ffff | 
;                                          in x:(sp-2)          
;       The input data structure is :
;               yn1:    y(-4) = 0
;                       y(-3) = 0
;                       y(-2) = 0
;                       y(-1) = 0
;               yn:     x(-4) = 0
;                       x(-3) = 0
;                       x(-2) = 0
;                       x(-1) = 0
;               xn:     x(0)
;                       x(1)
;                       ...
;                       ...
;
;       The output data structure is :
;
;               yn1:    y(-4) = 0
;                       y(-3) = 0
;                       y(-2) = 0
;                       y(-1) = 0
;               yn      y(0)
;                       y(1)
;                       y(2)
;                       ...
;                       ...
;              y(n+143) y(143)
;                       x(140)
;                       x(141)
;                       x(142) 
;                       x(143)
;************************ Resources ********************************
;
; Registers used       : y0 x0 a r0 r1 r3 m01,n
;
; Registers Changed    : y0 x0 a r0 r1 r3 m01,n
;
; Number of locations
; of Stack used        : -
;
; Number of Do loops   : 1
;  used 
;
;*********************** Assembly Code ****************************

         ORG    p:
         

Dtmf_Hpf        

        move    #OUT_INDEX,n              ;set n = 4 to point to out_put
                                          ; samples.
        move    #HPF_mscratch,r3          ;r3 -> HPF_coeff
        move    x:(sp-2),r0               ;r0 -> input_buf
        move    r0,r1                     ;r1 -> input_buf
                             
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;y0 = a5 ; r0 -> a4
                                          ;x0 = y(-4); r3 -> y(-3)
        lea     (r1)+n                    ;r1 -> input_buf + 4
        move    #OUT_PTR,y1
        move    #NS,lc
        
        do      lc,_HP_FILTER
        move    #-1,n
        mpy     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0
                                          ;A = a5*y(n-4)
                                          ;y0 = a4; r0 -> a3
                                          ;x0 = y(n-3); r3 -> y(n-2)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0 
                                          ;A = A + a4*y(n-3)
                                          ;y0 = a3; r0 -> a2
                                          ;x0 = y(n-2); r3 -> y(n-1)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0 
                                          ;A = A + a3*y(n-2)
                                          ;y0 = a2; r0 -> b5
                                          ;x0 = y(n-1); r3 -> x(n-4)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0 
                                          ;A = A + a2*y(n-1)
                                          ;y0 = b5; r0 -> b4
                                          ;x0 = x(n-4); r3 -> x(n-3)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0
                                          ;A = A + b5*x(n-4)
                                          ;y0 = b4; r0 -> b3
                                          ;x0 = x(n-3); r3 -> x(n-2)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0  
                                          ;A = A + b4*x(n-3)
                                          ;y0 = b3; r0 -> b2
                                          ;x0 = x(n-2); r3 -> x(n-1)
        mac     x0,y0,a      x:(r0)+,y0   
        move    x:(r3)+,x0 
                                          ;A = A + b3*x(n-2)
                                          ;y0 = b2; r0 -> b1 
                                          ;x0 = x(n-1); r3 -> x(n)
        mac     x0,y0,a      x:(r0)+n,y0   
        move    x:(r3)+,x0
                                          ;A = A + b2*x(n-1)
                                          ;y0 = b1; r0 -> b
                                          ;x0 = x(n); r3 -> x(n-1)
        move    #HPF_mscratch,r3

        macr    x0,y0,a      x:(r0)+n,y0
        
        move    y1,n                                  
        move    x:(r3)+,x0 
                                          ;A = A + b1*x(n)
                                          ;y0 = a5; r0 -> a4
                                          ;x0 = x(n-1); r3 -> x(n-2)
        lea     (r0)+n                    ;r0 -> y(n-3)
        asl     a           x:(r0)+,y0    ;A = 2*A
                                          ;x0 = y(n-3) ie. next y(n-4)
        move    a,x:(r1)+                 ;r1 -> y(n-2) ie. next y(n-3)
_HP_FILTER

        rts
        
     ENDSEC
     
;********************** End Of File ********************************  
        
;***************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
; 
;  FILE NAME            : v21_rxtimejam.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo
;
;  DATE CREATED         : 08/04/98
;
;  FILE DESCRIPTION     : This module finds the first ever zero_cross 
;                         present in a message .
;
;  FUNCTIONS            : V21_RxTimejam 
;
;  MACROS               : Nil 
;
;***************************************************************************

        include "v8bis_equ.asm"
 
        SECTION V21_RxTimejam 
        
        GLOBAL    V21_RxTimejam 

 
;****************************** Module ************************************
;
;  Module Name    : V21_RxTimejam 
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  The output of V21_Demod  is given as input to this module.
;  The two samples between which the sign of [w(n)] changes is found. This
;  module finds the first ever zero_cross present in the V21_Demod o/p.
; 
;        Modules : None
;        Macros  : None 
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             ------------
;  02/06/98     Minati             Incorporated Review comments.
;  03/07/2000   N R Prasad         Ported on to Metrowerks
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP 
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. The address of avgout_buf in x:avgout_buf_ptr.This pointer 
;     points to the first sample of previous to previous baud.  
;     avgout_buf_ptr  = | iiii iiii | iiii iiii |
;
;  Output :
;
;  1. The variable used to determine the exact zero_cross location in x:tau 
;     tau  = | siii ifff | ffff ffff |
;  2. The address pointer which points to the sample from where the 
;     zero_cross search will be conducted for next baud after the first  
;     zero crossing is found in x:zero_cross_ptr.
;     zero_cross_ptr = | iiii iiii | iiii iiii |
;  3. The address pointer which points to the sample in avgout_buf from 
;     which the decision is taken in x:sampling_ptr.
;     sampling_ptr = | iiii iiii | iiii iiii |
;  4. No. of decisions taken in x:Fg_v21_rx_decision_length.
;     Fg_v21_rx_decision_length = | 0000 0000 | 0000 00ii |
;  5. The sample from which decision is taken in x:decision_buf
;     decision_buf = | sfff ffff | ffff ffff |
;  6. The first_zero_cross flag update in x:first_zero_cross
;     first_zero_cross = | 0000 0000 | 0000 000i |
;
;****************************** Resources *********************************
;
;  Registers Used:       a,b,x0,y0,r0,n 
;
;  Registers Changed:    a,b,x0,y0,r0,n
;                        
;  Number of locations 
;    of stack used:      Nil
;
;  Number of DO Loops:   1             
;
;**************************** Assembly Code *******************************
       
        ORG     p: 

V21_RxTimejam
                                         

;************************************************************************
;  
;  The search for zero crossing is done in the previous baud and not in
;  the current baud.For that 12 is needed to be added to the address 
;  pointer r0 so that r0 will point to the first sample of previous 
;  baud. Here 11 is added to the address pointer so that r0 points 
;  to the last sample of previous to previous baud . This is done to
;  check zero cross at the boundary.
;
;************************************************************************
        
        move    #(TIMREC_MODULO_LEN-1),m01
                                          ;modulo 36
        move    #(SAMPLES_PER_BAUD/2-1),n ;11 in n 
        move    x:avgout_buf_ptr,r0       ;r0 -> avgout_buf
        move    #0,x:Fg_v21_rx_decision_length
                                          ;no of decisions == 0
        lea     (r0)+n                    ;r0 -> last sample of previous to 
                                          ;  previous baud.

        move    x:(r0)+,y0                ;get previous sample [y(i-1)]
        tfr     y0,a         x:(r0)+,y0   ;y(i-1) in a & y(i) in y0
        mpy     a1,y0,b                   ;A = y(i-1)*y(i)

        do      #(SAMPLES_PER_BAUD/2),_check_zero_cross
                                          ;for i = 1 to 12,check for zero cross
   
        bgt     _not_zero_cross           ;if A>0 check for zero cross again  

        incw    x:first_zero_cross        ;set first_zero_cross flag 

;**************************************************************************
;
;  The exact zero_cross location is found by linear interpolation method.
;
;  tau = y(i-1)/[y(i-1)-y(i)];
;  As the sign of y(i-1) and y(i) are different ,so here tau is always  
;  a +ve fraction.
;
;**************************************************************************

        move    #-(DEF_ZERO_CROSS_INDEX+1),n
                                          ;-7 in n
        move    a,b                       ;get y(i-1)
        sub     y0,b         x:(r0)+n,x0  ;find y(i-1) - y(i)
                                          ;  & find zero_cross_ptr

;*****************************************************************************
;
;  zero_cross_ptr = the address of the sample where zero_cross is found -
;                   zero_cross_index +1;
;
;*****************************************************************************

        move    #(SAMPLES_PER_BAUD/2-1),n
        move    r0,x:zero_cross_ptr       ;store zero_cross_ptr
        abs     a            x:(r0)+n,x0  ;force dividend [y(i-1)] +ve
                                          ;  sampling_ptr = zero_cross_ptr+11
        move    r0,x:sampling_ptr
        abs     b                         ;force divisor[y(i-1)-y(i)] +ve 
        move    b,y0 
        bfclr   #$0001,sr                 ;clear carry bit
                                          ;  required for division inst.
        rep     #16
        div     y0,a                      ;tau = y(i-1)/[y(i-1)-y(i)] 
        move    a0,y0
        move    #4,x0
        asrr    y0,x0,y0                  ;change tau to 5.11 format
        move    y0,x:tau                  ;store tau
        clr     a1
        asl     a
        rnd     a                         ;round tau to nearest integer 
        move    a1,n                     
        incw    x:Fg_v21_rx_decision_length         
                                          ;no. of decision = 1
        move    x:(r0+n),x0               ;get the sample from which 
                                          ;  decision is taken
        move    x0,x:decision_buf         ;store the sample in decision_buf
        enddo                             ;terminate loop
        jmp     _check_zero_cross      

_not_zero_cross

        tfr     y0,a         x:(r0)+,y0   ;get y(i) in a & y(i+1) in y0
        mpy     a1,y0,b                   ;A = y(i)* y(i+1)
        nop

_check_zero_cross                         ;end of i loop

        move    #-1,m01                   ;set up for linear arithmetic
  
        jmp     V21_Rx_Nxt_Tsk

        ENDSEC 

;****************************** End of File *******************************

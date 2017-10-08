;***************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
; 
;  FILE NAME            : v21_rxtimrec.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo
;
;  DATE CREATED         : 10/04/98 
;
;  FILE DESCRIPTION     : This module performs Symbol Recovery. The algorithm
;                         tracks the symbol error in the presence of 0.02%
;                         timing error.   
;
;  FUNCTIONS            : V21_RxTim_Rec 
;
;  MACROS               : Nil 
;
;***************************************************************************

        include "v8bis_equ.asm"
        
        SECTION V21_RxTimrec 
        
        GLOBAL    V21_RxTimrec 


;****************************** Module ************************************
;
;  Module Name    : V21_RxTimrec
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  Symbol Recovery is accomplished using zero crossing at the output of the
;  V21_Demod as a measure of the symbol boundary . If there is no 
;  timing error , the zero crossings should occur at points in time separeted
;  by exactly multiples of symbol period.It means that with no timing error ,
;  the zero crossings are separeted by multiples of 12 samples (12 samples
;  per baud).
;  
;  The output of the V21_Demod is given as input to this module.
;  This module determines the sample/samples from which decision is taken.
;    
;  Calls :
;        Modules : None
;        Macros  : None 
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  02/06/98     Minati             Incorporated Review Comments.
;  03/07/2000   N R Prasad         Ported on to Metrowerks.
;
;************************* Calling Requirements ***************************
; 1. Initialize SP  
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. The variable used to determine the exact zero cross location in x:tau
;     tau = | siii ifff | ffff ffff | 
;  2. The address pointer which points to the sample from where the zero
;     cross search will be conducted in x:zero_cross_ptr
;     zero_cross_ptr = | iiii iiii | iiii iiii |
;  3. The address pointer which points to the sample in avgout_buf from
;     which the decision is taken in x:sampling_ptr
;     sampling_ptr = | iiii iiii | iiii iiii |
;  4. The variable zero_cross_index in x:zero_cross_index
;     zero_cross_index = | 0000 0000 | 0000 iiii |
;  
;  Output :
;
;  1. The sample/samples from which decision is taken in x:decision_buf
;     decision_buf = | sfff ffff | ffff ffff |
;  2. Number of decisions in x:Fg_v21_rx_decision_length
;     Fg_v21_rx_decision_length = | 0000 0000 | 0000 00ii |
;  3. Updated tau in x:tau
;     tau = | siii ifff | ffff ffff |
;  4. Updated zero_cross_ptr in x:zero_cross_ptr
;     zero_cross_ptr = | iiii iiii | iiii iiii |
;  5. Updated sampling_ptr in x:sampling_ptr
;     sampling_ptr = | iiii iiii | iiii iiii |
;  6. Updated zero_cross_index in x:zero_cross_index
;     zero_cross_index = | 0000 0000 | 0000 iiii | 
;
;****************************** Resources *********************************
;
;  Registers Used:       a,b,x0,y0,y1,r0,r2,n,m01 
;
;  Registers Changed:    a,b,x0,y0,y1,r0,r2,n,m01
;                        
;  Number of locations 
;    of stack used:      Nil 
;
;  Number of DO Loops:   1             
;
;**************************** Assembly Code *******************************
       
        ORG     p: 

V21_RxTimrec

        move    #(TIMREC_MODULO_LEN-1),m01
                                          ;modulo 36
        move    #SAMPLES_PER_BAUD/2,n
        move    x:sampling_ptr,r0
        move    #1,y1                     ;count = 1

;*************************************************************************
;
;  As the baud length is 12 , each time you call this module, you have to
;  incrment sampling_ptr and zero_cross_ptr by 12.
;
;************************************************************************

        lea     (r0)+n                    ;sampling_ptr=sampling_ptr+12
        move    r0,x:sampling_ptr
        move    x:zero_cross_ptr,r0
        move    #decision_buf,r2          ;r2 -> decision_buf[1]
        move    #0,x:Fg_v21_rx_decision_length
                                          ;no. of decision = 0
        lea     (r0)+n                    ;zero_cross_ptr=zero_cross_ptr+12
        move    r0,x:zero_cross_ptr
        move    x:(r0)+,y0                ;get current sample,y(i)
        tfr     y0,a         x:(r0)+,y0   ;y(i) in a & next sample y(i+1) 
                                          ;  in y0
        mpy     a1,y0,b                   ;A = y(i)*y(i+1)
 
        do      #(SAMPLES_PER_BAUD/2),_check_zero_cross
                                          ;for i = 1 to 12,check for zero cross
        bgt     _not_zero_cross           ;if A>0 ,check for zero cross again 
       
        move    a,b                       ;get y(i)
        sub     y0,b                      ;find y(i)-y(i+1)

;****************************************************************************
;
;  As the sign of y(i) and y(i+1) are different , so y(i)/[y(i)-y(i+1)]
;  is always a +ve fraction.
;
;***************************************************************************

        abs     a                         ;force dividend [y(i)] +ve
        abs     b                         ;force divisor [y(i)-y(i+1)] +ve
        move    b,y0 
        bfclr   #$0001,sr                 ;clear carry bit,reqd. for division
        rep     #16
        div     y0,a                      ;find y(i)/[y(i)-y(i+1)]
        clr     a1                        
        sub     x:zero_cross_index,y1     ;find (i - zero_cross_index)
        asl     a 
        add     y1,a                      ;tau_n = (i-zero_cross_index) 
                                          ;  +y(i)/[y(i)-y(i+1)]
        cmp     #(SAMPLES_PER_BAUD/2-4),y1  
                                          ;compare (i-zero_cross_index) with 
                                          ;  (Samples_per_baud - 4, i.e = 8)
        jlt     _check_too_negative       ;if (i-zero_cross_index) < 8, 
                                          ;  jump _check_too_negative else
        sub     #SAMPLES_PER_BAUD/2,a     ;tau_n = tau_n - samples_per_baud/2

        jmp     _within_limit
        
_check_too_negative             
        
        cmp     #(-SAMPLES_PER_BAUD/2+4),y1 
                                          ;compare (i-zero_cross_index) 
                                          ;  with -8
        jgt     _within_limit             ;if (i-zero_cross_index) > -8,
                                          ;  jump _within_limit else 
        add     #SAMPLES_PER_BAUD/2,a     ;tau_n = tau_n+samples_per_baud/2

_within_limit

        rep     #5
        asr     a                         ;to convert tau_n to 5:11 format  
        move    a0,y1                     ;tau_n in y1
        move    #(1-C_ZERO_CROSS),y0
        mpy     y0,y1,a                   ;find tau_n*(1-C_ZERO_CROSS)
        move    x:tau,x0
        move    #C_ZERO_CROSS,y1
        mac     x0,y1,a                   ;tau = tau*C_ZERO_CROSS + 
                                          ;  tau_n*(1-C_ZERO_CROSS) 
        move    a1,x:tau                  ;store tau
        enddo                             ;terminate loop
        jmp     _check_zero_cross 

_not_zero_cross
 
        incw    y1                        ;count += 1
        tfr     y0,a         x:(r0)+,y0   ;get y(i+1) in a & y(i+2) in y0
        mpy     a1,y0,b                   ;A = y(i+1)*y(i+2)

_check_zero_cross

        move    x:sampling_ptr,r0 

;***************************************************************************
;
;  If tau < 0 , we are running slower and have an extra sample .
;  If tau > 1 , we are running faster and we have to skip a sample.
;  If tau value lies between 0 and 1 , then we don't have to update tau.  
;
;************************************************************************        
        move    #ONE_IN_Q11,y0            ;1 in y0 in 5.11 format
        tstw    x:tau                     ;test if tau is -ve
        
        blt     _tau_negative             ;if tau is -ve jump _tau_negative
          
        move    x:tau,x0
        sub     y0,x0                     ;find (tau -1)
        jle     _no_change                ;if tau <= 1 , then don't change tau 

        move    x0,x:tau                  ;for tau > 1 , tau = tau -1
        incw    x:zero_cross_index        ;zero_cross_index=zero_cross_index+1 
        lea     (r0)+                     ;sampling_ptr = sampling_ptr +1 
        jmp     _no_change

_tau_negative

        add     y0,x:tau                  ;for tau < 0 , tau = tau + 1 
        decw    x:zero_cross_index        ;zero_cross_index=zero_cros_index-1 
        lea     (r0)-                     ;sampling_ptr= sampling_ptr - 1 

_no_change        
 
;*****************************************************************************
;
;  If zero_cross_index < 1 , we have to process one extra baud. 
;  If zero_cross_index > samples_per_baud/2(12) , we have to skip the 
;  current baud. 
;  Else make a decisionn on the received baud.
;
;***************************************************************************     
        move    x:zero_cross_index,y0
        cmp     #1,y0                     ;compare zero_cross_index with 1 
       
        jge     _check_baud_skip          ;if zero_cross_index >=1 check for
                                          ;  baud_skip, else process an 
                                          ;  extra baud 
        clr     a
        move    x:tau,a0
        rep     #5
        asl     a                         ;the integer part of tau in a1
                                          ;  and fractional part in a0
        rnd     a                         ;round tau to nearest integer
        move    a1,n
        incw    x:Fg_v21_rx_decision_length     
                                          ;no of decision = 1
        move    x:(r0+n),x0               ;get the sample from which 
                                          ;  decision is taken
        move    x0,x:(r2)+                ;store the sample in decision_buf 
        move    #SAMPLES_PER_BAUD/2,n
        add     #SAMPLES_PER_BAUD/2,y0    ;zero_cross_index is
                                          ;  incremented by 12 
        move    y0,x:zero_cross_index
        lea     (r0)+n                    ;sampling_ptr is incremented by 12

_check_baud_skip
 
        sub     #SAMPLES_PER_BAUD/2,y0    ;find (zero_cross_index - 12)        
        
        jle     _decision                 ;if(zero_cross_index <= 12 )      
                                          ;  make a decision on rcvd. baud
                                          ;  else skip the current baud
        move    #-SAMPLES_PER_BAUD/2,n
        move    y0,x:zero_cross_index     ;zero_cross_index is 
                                          ;  decremented by 12 
        lea     (r0)+n                    ;sampling_ptr is decremented by 12
        jmp     _end_timing_recovery 

_decision
        
        clr     a
        move    x:tau,a0
        rep     #5
        asl     a                         ;the integer part of tau in a1 and
                                          ;  the fractional part in a0
        rnd     a                         ;round tau to nearest integer
        move    a1,n
        incw    x:Fg_v21_rx_decision_length     
                                          ;no of decision = no of decision+1
        move    x:(r0+n),x0               ;get the sample from which
                                          ;  decision is made
        move    x0,x:(r2)+                ;store the sample in decision_buf

_end_timing_recovery

        move    r0,x:sampling_ptr         ;store sampling_ptr
        move    #-1,m01                   ;set up for linear arithmetic
        
        jmp     V21_Rx_Nxt_Tsk

        ENDSEC 

;****************************** End of File *******************************

;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxavg_fil.asm
;
; PROGRAMMER           : Minati Ku. Sahoo
;
; DATE CREATED         : 27/03/98
; 
; FILE DESCRIPTION     : This module performs 6-tap average filtering.
;
; FUNCTIONS            : V21_RxAvg_Filter
;
; MACROS               : Nil
;
;************************************************************************

        include "v8bis_equ.asm"

        SECTION  V21_RxAvg_Filter

        GLOBAL     V21_RxAvg_Filter      
              
;****************************** Module ************************************
;
;  Module Name    : V21_RxAvg_Filter
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This module performs average filtering . It is a 6-tap averaging filter.
;  The equation is :
;   
;    y(n) = [ x(n) + x(n-1) + x(n-2) + x(n-3) + x(n-4) + x(n-5) ]/6
;
;
;  Calls :
;        Modules : None
;        Macros  : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  16/05/98     Minati             Incorporated Review Comments 
;  03/07/2000   N R Prasad         Ported on to MW.
;
;************************* Calling Requirements ***************************
;
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. Input samples in x:divout_buf . First five samples of divout_buf
;     are the last 5 samples of previous baud. 
;     r3 -> divout_buf 
;     divout_buf  = | sfff ffff | ffff ffff |
;
;  Output :
;
;  1. Output samples in x:avgout_buf.avgout_buf is a circular buffer
;     of length 36.
;     r0 -> avgout_buf
;     avgout_buf = | sfff ffff | ffff ffff | 
;
;****************************** Resources *********************************
;
;  Registers Used:       a,x0,y0,r0,r3,m01,n 
;
;  Registers Changed:    a,x0,y0,r0,r3,m01 
;                        
;  Number of locations 
;    of stack used:      Nil
;
;  Number of DO Loops:   1               
;
;**************************** Assembly Code *******************************

        ORG     p:

V21_RxAvg_Filter

;**************************************************************************
; 
;  Here each sample is divided by 6 and then added to get rid of overflow.
;
;**************************************************************************

        move    #(TIMREC_MODULO_LEN-1),m01
                                          ;modulo 36
        move    #-4,n
        move    #AVG_FACTOR,x0            ;x0 = 1/AVG_LEN(6)
        move    x:(r3)+,y0                ;y0 = x(-5) ; r0 -> x(-4)
        
        do      #(SAMPLES_PER_BAUD/2),_avg_filter
                                          ;for n = 0 to 11

        mpy     x0,y0,a      x:(r3)+,y0   ;y(n) = x(n-5)/6 ; y0 = x(n-4)
                                          ;  r3 -> x(n-3)
        mac     x0,y0,a      x:(r3)+,y0   ;y(n) += x(n-4)/6 ; y0 = x(n-3)
                                          ;  r3 -> x(n-2)
        mac     x0,y0,a      x:(r3)+,y0   ;y(n) += x(n-3)/6 ; y0 = x(n-2)
                                          ;  r3 -> x(n-1)
        mac     x0,y0,a      x:(r3)+,y0   ;y(n) += x(n-2)/6 ; y0 = x(n-1)
                                          ;  r3 -> x(n)
        mac     x0,y0,a      x:(r3)+n,y0  ;y(n) += x(n-1)/6 ; y0 = x(n)
                                          ;  r3 -> x(n-4)
        macr    x0,y0,a      x:(r3)+,y0   ;y(n) += x(n)/6 ; y0 = x(n-4)
                                          ;  r3 -> x(n-3)
        move    a,x:(r0)+                 ;store output in avgout_buf

_avg_filter                               ;end of n loop

        move    #-1,m01                   ;set up for linear arithmetic

        rts
         
        ENDSEC 
 
;****************************** End of File *******************************

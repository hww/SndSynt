;***************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
; 
;  FILE NAME            : v21_rxdiv.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo
;
;  DATE CREATED         : 31/03/98
;
;  FILE DESCRIPTION     : This routine performs complex division to find only 
;                         the imaginary part of division. 
;
;  FUNCTIONS            : V21_RxDiv 
;
;  MACROS               : Nil
;
;***************************************************************************
       
        include "v8bis_equ.asm"
        
        SECTION V21_RxDiv
 
        GLOBAL  V21_RxDiv 
     
;****************************** Module ************************************
;
;  Module Name    : V21_RxDiv
;  Author         : Minati  Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This module performs complex division of the current sample by previous 
;  sample to find only the imaginary part of the division. 
;
;  If a+jb is the current sample and c+jd is the previous sample, then   
;  (a+jb)/(c+jd) = ((a*c+b*d)/(c**2+d**2))+j((b*c-a*d)/(c**2+d**2)).
;  This module finds only (b*c-a*d)/(c**2+d**2). 
;
;  Calls :
;        Modules : None   
;        Macros  : None 
;
;*************************** Revision History *****************************
;
;  Date         Author             Descrption 
;  ----         ------             ----------
;  15/05/98     Minati             Incorporated Review Comments 
;  03/07/2000   N R Prasad         Ported on to Metrowerks
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
;  1. Input Real samples in x:lpfout_rl_buf
;     r1 -> lpfout_rl_buf
;     lpfout_rl_buf = | sfff ffff | ffff ffff |
;
;  2. Input Imaginary samples in x:lpfout_im_buf
;     r3 -> lpfout_im_buf
;     lpfout_im_buf  = | sfff ffff | ffff ffff |        
;
;  Output :
;
;  1. Output samples in x:divout_buf
;     r2 -> divout_buf+5
;     divout_buf = | sfff ffff | ffff ffff |  
;
;****************************** Resources *********************************
;
;  Registers Used:       a,b,x0,y0,y1,r0-r3,n 
;
;  Registers Changed:    a,b,x0,y0,y1,r0-r3 
;                        
;  Number of locations 
;    of stack used:      Nil
;
;  Number of DO Loops:   1              
;
;**************************** Assembly Code *******************************

        ORG     p:
                                          
V21_RxDiv

        move    #-1,n

        do      #(SAMPLES_PER_BAUD/2),_div
                                          ;for i=1 to 12
                                          ;  devide sample by previous sample 
        
        clr     r0
        move    x:(r3)+,y0                ;y0=im_samp[i],r3 -> im_samp[i+1]
        mpy     y0,y0,a      x:(r1)+,y0   ;A=im_samp[i]**2,y0=rl_samp[i]
                                          ;  r1 -> rl_samp[i+1]
        mac     y0,y0,a      x:(r3)+n,x0  ;A+=rl_samp[i]**2,x0=im_samp[i+1]
                                          ;  r3 -> im_samp[i]
        
        mpy     y0,x0,b      x:(r1)+n,y0 
        move    x:(r3)+,x0 
                                          ;B=rl_samp[i]*im_samp[i+1] 
                                          ;  y0=rl_samp[i+1];r1 ->rl_samp[i] 
                                          ;  x0=im_samp[i];r3 ->im_samp[i+1]
        mac     -x0,y0,b                  ;B=B-im_samp[i]*rl_samp[i+1]
        move    #$7fff,x0                 ;Quotient is +/-1 if Dr =0 or Nr>Dr
        move    b,y0                      ;Save the sign
        abs     b                         ;Abs value for division
        cmp     a,b                       ;find B - A
        
        jge     _output_1                 ;if B>A , then B/A = 1
 
        tst     a                         ;cmp instruction affects U bit 
                                          ;  of sr,tst a is done to 
                                          ;  set U bit properly
        beq     _output_1
        rep     #15                       
        norm    r0,a                      ;no of left/right shift in r0
        move    a1,y1                     ;truncate A to 16 bit
        tstw    r0                        ;test if r0 is -ve

        blt     _do_asl                   ;if r0 is -ve ,then asl B 

        rep     r0
        asr     b                         ;do the correct manipulation with B 
 
        jmp     _start_division

_do_asl 

        move    r0,a                      ;store no of left shifts
        neg     a                         ;acc is negated to get exact no of 
                                          ;  left shift
        rep     a 
        asl     b                         ;do the correct manipulation with B

_start_division
 
        bfclr   #$0001,sr                 ;clear carry bit reqd. for DIV inst
        rep     #16
        div     y1,b                      ;form positve B/A in b0
        move    b0,x0                     ;store the result in x0

_output_1
        move    x0,a                      ;Save Quotient
        neg     a           x:(r1)+,y1    ;Negate Quotient,r1 -> rl_samp[i+1]
        tstw    y0                        ;If Nr >= 0, restore original
        tge     x0,a                      ;  quotient
        move    a,x:(r2)+                 ;store the result in divout_buf[5+i] 

_div                                      ;end of i loop
        rts 
 
        ENDSEC
 
;****************************** End of File *******************************
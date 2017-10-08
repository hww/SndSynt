;**************************************************************************                                  
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Rights Reserved 
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_PH_REVERS1
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver     Description                Author
;  --------     --------     -----------                ------
;  3/11/97      0.0.1        Macro Created              Qiu Lunji
;  17/11/97     1.0.0        Reviewed and Modified      Qiu Lunji
;  10/07/00     1.0.1        Converted macros to        Sandeep Sehgal
;                            functions    
;
;*************************** Function Description *************************
;
;  This module detects the phase reversal of the disabler tone on rcv chn 
;
;  Symbols Used :
;       zero_cross1    : Flag to indicate that zero crossing has occured
;       state_TD1      : State of tone detector
;       ph_rev_amp1    : No. of "good" zero-crossings detected which 
;                           indicated presence of a phase reversal between
;                           them
;       ph_rev_inst1   : Instance of phase reversal detected
;       tone_count1    : Sample counter for the valid tone 
;       hf_period1     : Estimate of the half period of 
;                           the modulated tone
;       hf_period_lim1 : Tolerance for good zero crossing distance
;       zc_amps1[6]    : Stack of six "good" zero crossings distances
;       sum_zc1        : Distance between 1st and 6th "good"
;                           zero crossings
;       fcount1        : Counter for number of samples between
;                           two zero crossings
;       zc_count1      : Count for the number of samples between
;                           two good zero crossings (modulo period)
;       first_zc_flag1 : First zero crossing indication flag
;  
;  Functions Called :
;       None  
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The function TD_INIT should be called before calling this function
;     for the first time. The constant and variable declarations are 
;     defined in file td_data.asm
;  2. Address of zc_amps1[0] should be loaded to x:zc_amps1_p before 
;     calling this function for the first time
;
;************************** Input and Output ******************************
;
;  Input  :
;       zero_cross1      = | 0000 0000 | 0000 000i | in x:zero_cross1
;
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       state_TD1       = | 0000 0000 | 0000 0iii |
;
;       ph_rev_amp1     = | iiii iiii | iiii iiii |
;
;       ph_rev_inst1    = | iiii iiii | iii  iiii |
;
;       tone_count1     = | iiii iiii | iiii iiii |
;
;       hf_period       = | iiii iiii | iiii ffff |
;
;       hf_period_lim1  = | iiii iiii | iiii ffff |
;
;       zc_amps1[k]     = | iiii iiii | iiii ffff | for k = 0 to 5
;
;       sum_zc1         = | iiii iiii | iiii ffff |
;
;       first_zc_flag1  = | 0000 0000 | 0000 000i |
;
;  Statics :
;       fcount1         = | iiii iiii | iiii ffff |  
;
;       zc_count1       = | iiii iiii | iiii ffff |
;
;****************************** Resources *********************************
;
;                        Cycle Count   :103 (Max)  
;                        Program Words :102  
;                        NLOAC         :84  
;
;  Address Registers used:
;                        r1 : used to read the array zc_amps1[] 
;                             in 6 modulo addressing mode
;
;  Offset Registers used:
;                        None
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r1  m01  a0  b0  x0  y0  sr
;                                 a1  b1      y1  pc
;                                 a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           fcount1 = fcount1+1
;           zc_count1 = zc_count1+1
;           tmp = 2*hf_period1
;           If ( zc_count1 > tmp )
;               zc_count1 = zc_count1 - tmp    % modulo period %
;           Endif
;
;           If ( zero_cross1 == 1 ) 
;               If ( first_zc_flag1 == 0 )
;                   fcount1 = 0
;                   zc_count1 = 0
;                   for p=0:5
;                      zc_amps1(p) = hf_period1 
;                   Endfor
;                   first_zc_flag1 = 1
;                   sum_zc1 = 0
;               Else
;                   diff = fcount1 - hf_period1
;                   adiff = abs(diff)
;                   If ( adiff <= hf_period_lim1 )
;                       sum_zc1 = sum_zc1 - zc_amps1(0)  % modulo period %
;                       sum_zc1 = sum_zc1 + zc_count1
;                       zc_amps1(0:4) = zc_amps1(1:5)
;                       zc_amps1(5) = zc_count1
;                       tmp = 2*hf_period1
;                       If ( sum_zc1 <= 0 )
;                           sum_zc1 = sum_zc1 + tmp 
;                       Elseif ( sum_zc1 > tmp )
;                           sum_zc1 = sum_zc1 - tmp 
;                       Endif
;                       diff = sum_zc1 - hf_period1
;                       adiff = abs(diff)
;                       If ( (state_TD1 == 4) & (4*adiff < hf_period1) 
;                           If(ph_rev_amp1 < 6)
;                               ph_rev_amp1 = ph_rev_amp1+1
;                               ph_rev_inst1 = tone_count1-6*hf_period1
;                           Endif
;                       Endif
;                       zc_count1 = 0
;                   Else
;                       zc_count1 = zc_count1 + hf_period1
;                   Endif
;                   fcount1 = 0
;               Endif
;           Endif
;       End
;                      
;**************************** Assembly Code *******************************
        
        SECTION TD_RCV_CODE
        
        GLOBAL  TD_PH_REVERS1 

        org     p:

 
TD_PH_REVERS1

_Begin_TD_PH_REVERS1
        move    #<$10,x0                  ;Add 1 in 12.4 format
        add     x0,x:fcount1              ;fcount1 = fcount1 + 1
        move    x:hf_period1,b
        move    x:zc_count1,a

        add     x0,a                      ;zc_count1+1 (in 12.4 format)       
        move    b,y1                      ;Restore hf_period1 for later use 
        asl     b                         ;tmp = 2*hf_perid
        move    a,x0                      ;Restore zc_count1 for later use
        move    b,y0                      ;Restore tmp for later use
        sub     b,a                       ;Evaluate zc_count1 - tmp
        tle     x0,a                      ;If (zc_count1 <= tmp) zc_count1 is 
        move    a,x:zc_count1             ;  the preincremented value
        tstw    x:zero_cross1             ;Check zero_cross1 flag
        jeq     _End_TD_PH_REVERS1        ;Branch if zero_cross1 = 0
        tstw    x:first_zc_flag1          ;Check first_zc_flag1
        bne     <_elsecase                ;Branch if first_zc_flag1 != 0
        move    #$8005,m01
        move    #zc_amps1,r1              ;r1 --> zc_amps1[0]
        rep     #4                        ;For k= 0 to 3
        move    y1,x:(r1)+                ;  zc_amps1[k] = hf_period1
        clr     b      y1,x:(r1)+         ;b = 0, zc_amps1[4] = hf_period1
        move    b,x:fcount1               ;fcount1 = 0
        move    b,x:zc_count1             ;zc_count1 = 0
        move    b,x:sum_zc1               ;sum_zc1 = 0
        inc     b      y1,x:(r1)+         ;b = 1, zc_amps1[5] = hf_period1
        move    b,x:first_zc_flag1        ;first_zc_flag1 = 1
        jmp     _End_TD_PH_REVERS1

_elsecase
        move    x:fcount1,b                 
        sub     y1,b                      ;diff = fcount1 - hf_period1
        abs     b                         ;Calculate adiff = abs(diff)
        cmp     x:hf_period_lim1,b        ;Compare adiff and hf_period_lim1
        jgt     _loop1                    ;Branch if adiff > hf_period_lim1
        move    #$8005,m01                ;m01 = 5 to make modulo 6 buffer
        move    x:zc_amps1_p,r1           ;r1 --> zc_amps1[i] 
        move    x:sum_zc1,b               
        move    x:(r1),x0                 ;Get zc_amps1[i]
                                          ;  r1 --> zc_amps1[i]
        sub     x0,b                      ;Compute sum_zc1 - zc_amps[i]
        add     a,b          a,x:(r1)+    ;sum_zc1 - zc_amps[i] + zc_count1
                                          ;  zc_amps1[i] = zc_count1
                                          ;  r1 --> zc_amps1[i+1] 
        move    r1,x:zc_amps1_p           ;Store the address of zc_amp1[i+1]
                                          ;  for next iteration
;From the zc_amps1 array we need the 6th previous value for subtration
;(sum_zc1 - zc_amps1[0] ) and the current value 'zc_count1' for addition
;This is done by reading first and then writing the new value to the same
;location of the array in circular mode

        tst     b                         ;Check sum_zc1 
        bgt     <_loop3                   ;Branch if sum_zc1 > 0
        add     y0,b                      ;sum_zc1 = sum_zc1 + tmp
        
        bra     <_loop4
_loop3
        move    b,a
        sub     y0,b                      ;Evaluate sum_zc1 - tmp
        tle     a,b                       ;If sum_zc1 <= tmp
                                          ;  restore sum_zc1
_loop4
        move    b,x:sum_zc1               ;Store sum_zc1 for next call 
        sub     y1,b                      ;diff = sum_zc1 - hf_period1
        abs     b                         ;Get adiff as abs(diff)
        move    x:state_TD1,a           
        move    b,y0                      ;Temperorily store adiff
        move    #<4,x0
        cmp     x0,a                      ;Compare state_TD1 with 4
        bne     <_loop5                   ;Branch if state_TD1 != 4
        impy    y0,x0,b                   ;Find adiff*4

        cmp     y1,b                      ;Compare adiff*4 and hf_period1
        bge     <_loop5                   ;Branch if adiff*4 >= hf_period1

        move    x:ph_rev_amp1,a
        cmp     #<6,a                     ;Compare ph_rev_amp1 with 6
        bge     <_loop5                   ;Branch if ph_rev_amp1 >= 6
        inc     a                         
        move    a,x:ph_rev_amp1           ;ph_rev_amp1 = ph_rev_amp1 + 1 
       
        move    #6.0/16.0,x0
        mpy     y1,x0,a                   ;6*hf_period1 in 12.4 format
        sub     x:tone_count1,a           ;6*hf_period1-tone_count1
        abs     a
        move    a,x:ph_rev_inst1          ;ph_rev_inst1 = tone_count1
       
_loop5
        move    #0,x:zc_count1            ;zc_count1 = 0
        bra     <_loop2
_loop1  
        add     y1,a                      ;Evaluate zc_count1 + hf_period1
        move    a,x:zc_count1             ;zc_count1 = zc_count1 + hf_period1
_loop2
        move    #0,x:fcount1              ;fcount1 = 0

_End_TD_PH_REVERS1

		rts

        ENDSEC
;****************************** End of File *******************************

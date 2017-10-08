;**************************************************************************                                   
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Rights Reserved 
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_PH_REVERS2
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver     Description                Author
;  --------     --------     -----------                ------
;  3/11/97      0.0.1        Macro Created              Qiu Lunji
;  17/11/97     1.0.1        Reviewed and modified      Qiu Lunji
;  10/07/00     1.0.2        Converted macros to        Sandeep Sehgal
;                            functions    
;
;*************************** Function Description *************************
;
;  This module detects the phase reversal of the disabler tone on snd chn 
;
;  Symbols Used :
;       zero_cross2    : Flag to indicate that zero crossing has occured
;       state_TD2      : State of tone detector
;       ph_rev_amp2    : No. of "good" zero-crossings detected which
;                           indicated presence of a phase reversal between
;                           them
;       ph_rev_inst2   : Instance of phase reversal detected
;       tone_count2    : Sample counter for the valid tone 
;       hf_period2     : Estimate of the half period of 
;                           the modulated tone
;       hf_period_lim2 : Tolerance for good zero crossing distance
;       zc_amps2[6]    : Stack of six "good" zero crossings distances
;       sum_zc2        : Distance between 1st and 6th "good"
;                           zero crossings
;       fcount2        : Counter for number of samples between
;                           two zero crossings
;       zc_count2      : Count for the number of samples between
;                           two good zero crossings (modulo period)
;       first_zc_flag2 : First zero crossing indication flag
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
;     defined in td_data.asm
;  2. Address of zc_amps2[0] should be loaded to x:zc_amps2_p before 
;     calling this function for the first time
;
;************************** Input and Output ******************************
;
;  Input  :
;       zero_cross2      = | 0000 0000 | 0000 000i | in x:zero_cross2
;
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       state_TD2       = | 0000 0000 | 0000 0iii |
;
;       ph_rev_amp2     = | iiii iiii | iiii iiii |
;
;       ph_rev_inst2    = | iiii iiii | iii  iiii |
;
;       tone_count2     = | iiii iiii | iiii iiii |
;
;       hf_period       = | iiii iiii | iiii ffff |
;
;       hf_period_lim   = | iiii iiii | iiii ffff |
;
;       zc_amps2[k]     = | iiii iiii | iiii ffff | for k = 0 to 5
;
;       sum_zc2         = | iiii iiii | iiii ffff |
;
;       first_zc_flag2  = | 0000 0000 | 0000 000i |
;
;  Statics :
;       fcount2         = | iiii iiii | iiii ffff |  
;
;       zc_count2       = | iiii iiii | iiii ffff |
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 103 (Max)
;                        Program Words : 102
;                        NLOAC         : 84
;
;  Address Registers used:
;                        r1 : used to read the array zc_amps2[] 
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
;           fcount2 = fcount2+1
;           zc_count2 = zc_count2+1
;           tmp = 2*hf_period2
;           If ( zc_count2 > tmp )
;               zc_count2 = zc_count2 - tmp    % modulo period %
;           Endif
;
;           If ( zero_cross2 == 1 ) 
;               If ( first_zc_flag2 == 0 )
;                   fcount2 = 0
;                   zc_count2 = 0
;                   for p=0:5
;                      zc_amps2(p) = hf_period2 
;                   Endfor
;                   first_zc_flag2 = 1
;                   sum_zc2 = 0
;               Else
;                   diff = fcount2 - hf_period2
;                   adiff = abs(diff)
;                   If ( adiff <= hf_period_lim2 )
;                       sum_zc2 = sum_zc2 - zc_amps2(0)  % modulo period %
;                       sum_zc2 = sum_zc2 + zc_count2
;                       zc_amps2(0:4) = zc_amps2(1:5)
;                       zc_amps2(5) = zc_count2
;                       tmp = 2*hf_period2
;                       If ( sum_zc2 <= 0 )
;                           sum_zc2 = sum_zc2 + tmp 
;                       Elseif ( sum_zc2 > tmp )
;                           sum_zc2 = sum_zc2 - tmp 
;                       Endif
;                       diff = sum_zc2 - hf_period2
;                       adiff = abs(diff)
;                       If ( (state_TD2 == 4) & (4*adiff < hf_period2) 
;                           If(ph_rev_amp2 < 6)
;                               ph_rev_amp2 = ph_rev_amp2+1
;                               ph_rev_inst2 = tone_count2-6*hf_period2
;                           Endif
;                       Endif
;                       zc_count2 = 0
;                   Else
;                       zc_count2 = zc_count2 + hf_period2
;                   Endif
;                   fcount2 = 0
;               Endif
;           Endif
;       End
;                      
;**************************** Assembly Code *******************************
       
        SECTION TD_SND_CODE
        
        GLOBAL  TD_PH_REVERS2


        org     p:
        

TD_PH_REVERS2


_Begin_TD_PH_REVERS2
        move    #<$10,x0                  ;Add 1 in 12.4 format
        add     x0,x:fcount2              ;fcount2 = fcount2 + 1
        move    x:hf_period2,b
        move    x:zc_count2,a

        add     x0,a                      ;zc_count2+1 (in 12.4 format)       
        move    b,y1                      ;Restore hf_period2 for later use 
        asl     b                         ;tmp = 2*hf_perid
        move    a,x0                      ;Restore zc_count2 for later use
        move    b,y0                      ;Restore tmp for later use
        sub     b,a                       ;Evaluate zc_count2 - tmp
        tle     x0,a                      ;If (zc_count2 <= tmp) zc_count2 is 
        move    a,x:zc_count2             ;  the preincremented value
        tstw    x:zero_cross2             ;Check zero_cross2 flag
        jeq     _End_TD_PH_REVERS2        ;Branch if zero_cross2 = 0
        tstw    x:first_zc_flag2          ;Check first_zc_flag2
        bne     <_elsecase                ;Branch if first_zc_flag2 != 0
        move    #$8005,m01
        move    #zc_amps2,r1              ;r1 --> zc_amps2[0]
        rep     #4                        ;For k= 0 to 3
        move    y1,x:(r1)+                ;  zc_amps2[k] = hf_period2
        clr     b      y1,x:(r1)+         ;b = 0, zc_amps2[4] = hf_period2
        move    b,x:fcount2               ;fcount2 = 0
        move    b,x:zc_count2             ;zc_count2 = 0
        move    b,x:sum_zc2               ;sum_zc2 = 0
        inc     b      y1,x:(r1)+         ;b = 1, zc_amps2[5] = hf_period2
        move    b,x:first_zc_flag2        ;first_zc_flag2 = 1
        jmp     _End_TD_PH_REVERS2

_elsecase
        move    x:fcount2,b                 
        sub     y1,b                      ;diff = fcount2 - hf_period2
        abs     b                         ;Calculate adiff = abs(diff)
        cmp     x:hf_period_lim2,b        ;Compare adiff and hf_period_lim2
        jgt     _loop1                    ;Branch if adiff > hf_period_lim2
        move    #$8005,m01                ;m01 = 5 to make modulo 6 buffer
        move    x:zc_amps2_p,r1           ;r1 --> zc_amps2[i] 
        move    x:sum_zc2,b               
        move    x:(r1),x0                 ;Get zc_amps2[i]
                                          ;  r1 --> zc_amps2[i]
        sub     x0,b                      ;Compute sum_zc2 - zc_amps[i]
        add     a,b          a,x:(r1)+    ;sum_zc2 - zc_amps[i] + zc_count2
                                          ;  zc_amps2[i] = zc_count2
                                          ;  r1 --> zc_amps2[i+1] 
        move    r1,x:zc_amps2_p           ;Store the address of zc_amp2[i+1]
                                          ;  for next iteration
;From the zc_amps2 array we need the 6th previous value for subtration
;(sum_zc2 - zc_amps2[0] ) and the current value 'zc_count2' for addition
;This is done by reading first and then writing the new value to the same
;location of the array in circular mode

        tst     b                         ;Check sum_zc2 
        bgt     <_loop3                   ;Branch if sum_zc2 > 0
        add     y0,b                      ;sum_zc2 = sum_zc2 + tmp
        
        bra     <_loop4
_loop3
        move    b,a
        sub     y0,b                      ;Evaluate sum_zc2 - tmp
        tle     a,b                       ;If sum_zc2 <= tmp
                                          ;  restore sum_zc2
_loop4
        move    b,x:sum_zc2               ;Store sum_zc2 for next call 
        sub     y1,b                      ;diff = sum_zc2 - hf_period2
        abs     b                         ;Get adiff as abs(diff)
        move    x:state_TD2,a           
        move    b,y0                      ;Temperorily store adiff
        move    #<4,x0
        cmp     x0,a                      ;Compare state_TD2 with 4
        bne     <_loop5                   ;Branch if state_TD2 != 4
        impy    y0,x0,b                   ;Find adiff*4

        cmp     y1,b                      ;Compare adiff*4 and hf_period2
        bge     <_loop5                   ;Branch if adiff*4 >= hf_period2

        move    x:ph_rev_amp2,a
        cmp     #<6,a                     ;Compare ph_rev_amp2 with 6
        bge     <_loop5                   ;Branch if ph_rev_amp2 >= 6
        inc     a                         
        move    a,x:ph_rev_amp2           ;ph_rev_amp2 = ph_rev_amp2 + 1 
       
        move    #6.0/16.0,x0
        mpy     y1,x0,a                   ;6*hf_period2 in 12.4 format
        sub     x:tone_count2,a           ;6*hf_period2-tone_count2
        abs     a
        move    a,x:ph_rev_inst2          ;ph_rev_inst2 = tone_count2
       
_loop5
        move    #0,x:zc_count2            ;zc_count2 = 0
        bra     <_loop2
_loop1  
        add     y1,a                      ;Evaluate zc_count2 + hf_period2
        move    a,x:zc_count2             ;zc_count2 = zc_count2 + hf_period2
_loop2
        move    #0,x:fcount2              ;fcount2 = 0

_End_TD_PH_REVERS2

		rts

        ENDSEC
;****************************** End of File *******************************

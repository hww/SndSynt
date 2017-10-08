;**************************************************************************                                    
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                                 
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_DTCT_LGIC1
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY     Code Ver        Description             Author
;  --------     --------        -----------             ------
;  5/11/97      0.0.1           Macro Created           Qiu Lunji
;  18/11/97     1.0.0           Reviewed and Modified   Qiu Lunji
;  10/07/00     1.0.1           Converted macros to     Sandeep Sehgal
;                               functions    
;
;*************************** Function Description *************************
;
;  Logic to determine whether Disabler tone was present or not. 
;  All the variables ending with 1 represent channel 1
;  
;  Symbols Used :
;       g165_tone_disable1 : Flag to disable G.165 echo-cancellor
;       tone_pass_count1   : Block counter to count number of vaild tone
;                             passes as (in accordance with Req B.1-B.3)
;       reset_TD1          : Flag to reset tone detector
;       ph_rev_flag1       : Flag for phase reversal detection
;       ph_rev_amp1        : No. of "good" zero-crossing detected which
;                             indicated presence of a phase reversal between
;                             them
;       ph_rev_amp11       : No. of "good" zero-crossing detected which
;                             indicated presence of a phase reversal between
;                             them at first phase reversal
;       ph_rev_amp21       : No. of "good" zero-crossing detected which 
;                             indicated presence of a phase reversal between
;                             them at second phase reversal
;       ph_rev_inst1       : Instance of phase reversal detected
;       ph_rev_inst11      : Instant of 1st phase reversal 
;       ph_rev_inst21      : Instant of 2nd phase reversal
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
;  1. The function TD_INIT should be called before the 1st call of this function
;     The constant and variable declarations are defined in file td_data.asm  
;
;************************** Input and Output ******************************
;
;  Input  :     
;       None
;
;  Output :
;       g165_tone_disable1 = | 0000 0000 | 0000 000i | in x:g165_tone_disable1
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       tone_pass_count1    = | iiii iiii | iiii iiii |
;
;       reset_TD1           = | 0000 0000 | 0000 000i |
;
;       ph_rev_flag1        = | 0000 0000 | 0000 000i |
;
;       ph_rev_amp1         = | 0000 0000 | 0000 0iii |
;
;       ph_rev_amp11        = | 0000 0000 | 0000 0iii |
;
;       ph_rev_amp21        = | 0000 0000 | 0000 0iii |
;
;       ph_rev_inst1        = | iiii iiii | iiii iiii |
;
;       ph_rev_inst11       = | iiii iiii | iiii iiii |
;
;       ph_rev_inst21       = | iiii iiii | iiii iiii |
;
;  Statics :
;       None 
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 69 (Max)
;                        Program Words : 58
;                        NLOAC         : 44
;
;  Address Registers used:
;                        None
;
;  Offset Registers used:
;                        None
;
;  Data Registers used:
;                        a0  b0 x0  y0
;                        a1  b1     y1
;                        a2  b2
;
;  Registers Changed:
;                        a0  b0 x0  y0  sr
;                        a1  b1     y1  pc
;                        a2  b2
;                        
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           ph_rev_flag1 = 0
;           ph_rev_amp21  = ph_rev_amp1
;           ph_rev_inst21 = ph_rev_inst1
;           If  ( ph_rev_inst11 == 0 )
;               If ( ph_rev_amp21 > 3 )
;                   ph_rev_flag1 = 1
;               Endif
;           ElseIf  ( ph_rev_inst21 == 0 )
;               If ( ph_rev_amp11 > 3 )
;                   ph_rev_flag1 = 1
;               Endif
;           Else
;               tmp1 = ph_rev_amp11 + ph_rev_amp21
;               tmp2 = abs(ph_rev_inst21 - ph_rev_inst11 - (450*8))
;               If ( (tmp1 > 5) & (tmp2 < (100*8)) )
;                   ph_rev_flag1 = 1
;               Endif
;           Endif
;           If ( (tone_pass_count1 >= 6500/20) & (ph_rev_flag1 == 1) ),
;               g165_tone_disable1 = 1
;           Endif 
;           reset_TD1 = 1
;       End
;
;**************************** Assembly Code *******************************
   
       SECTION TD_RCV_CODE
        
       GLOBAL  TD_DTCT_LGIC1
       
       org     p:
        

TD_DTCT_LGIC1

_Begin_TD_DTCT_LGIC1
       
        move    #0,x:ph_rev_flag1         ;ph_rev_flag1 = 0
        move    x:ph_rev_amp1,x0        
        move    x0,x:ph_rev_amp21         ;ph_rev_amp21 = ph_rev_amp1
        move    x:ph_rev_inst1,y0        
        move    y0,x:ph_rev_inst21        ;ph_rev_inst21 = ph_rev_inst1
        
        tstw    x:ph_rev_inst11           ;Check ph_rev_inst11 is zero
        bne     <_chk2                    ;Branch if ph_rev_inst11 != 0 
        cmp     #<3,x0                    ;Comare ph_rev_amp22 with 3 
        blt     _out                      ;Branch if 3 >= ph_rev_amp22
        move    #<1,x:ph_rev_flag1        ;ph_rev_flag1 = 1
        bra     _out
_chk2
        move    x:ph_rev_amp11,b
        cmp     #0,y0                     ;Check ph_rev_inst21 is zero
        bne     <_chk3                    ;Branch if ph_rev_inst21 != 0 
        cmp     #<3,b                     ;Comare ph_rev_amp12 with 3 
        blt     <_out                     ;Branch if 3 >= ph_rev_amp12
        move    #<1,x:ph_rev_flag1        ;ph_rev_flag1 = 1
        bra     <_out
_chk3      
        add     x0,b                      ;tmp1 = ph_rev_amp11 
                                          ;  + ph_rev_amp21
        cmp     #<5,b                     ;Compare tmp1 with 5
        ble     <_out                     ;Branch if tmp1 <= 5
        move    y0,a                      ;Get ph_rev_inst21
        move    x:ph_rev_inst11,y1  
        sub     y1,a                      ;ph_rev_inst21 - ph_rev_inst11
        sub     #3600,a                   ;Calculate tmp2
        abs     a                         ;tmp2 = abs(tmp2)
      
        cmp     #800,a                    ;Compare tmp2 with 800 
        bge     <_out                     ;Branch if tmp2 >= 800
        move    #<1,x:ph_rev_flag1        ;ph_rev_flag1 = 1
_out         
        tstw    x:ph_rev_flag1            ;Check ph_rev_flag1
        beq     <_reset_ton               ;Branch if ph_rev_flag1 = 0
        move    x:tone_pass_count1,a
        cmp     #6500/20,a                ;Compare tone_pass_count1 with 6500/20
        blt     <_reset_ton               ;Branch if tone_pass_count1 < 6500/20
        move    #<1,x:g165_tone_disable1  ;g165_tone_disable1 = 1
_reset_ton
        move    #<1,x:reset_TD1           ;reset_TD1 = 1

_End_TD_DTCT_LGIC1

		rts

        ENDSEC

;****************************** End of File *******************************

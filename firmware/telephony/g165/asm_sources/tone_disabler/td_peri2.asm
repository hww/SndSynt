;**************************************************************************                                    
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Rights Reserved                           
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_PERIOD_EST2
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;************************** Revision History ******************************
;
;  DD/MM/YY     Code Ver    Description                 Author    
;  --------     --------    -----------                 ------
;  1/10/97      0.0.1       Macro Created               Qiu Lunji
;  8/10/97      1.0.0       Reviewed and modified       Qiu Lunji
;  10/07/00     1.0.1       Converted macros to         Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  Estimation of period for disabler tone on snd channel
;  All the variables ending with 2 represent channel 2 (snd channel)
;
;  Symbols Used :
;       zero_cross2       : Flag to indicate zero crossing 
;       hf_period2        : Half of the period of the modulated tone
;       sum_hf_period2    : Sum of valid half periods
;       num_hf_period2    : Number of valid half periods
;       first_zc_flag2    : First zero crossing indication flag
;       count2            : Counter for counting number of samples 
;                           between two zero-crossings
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
;  1. The Function TD_INIT should be called before calling this function
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
;       hf_period2         = | iiii iiii |  iiii  ffff |
;
;       sum_hf_period2     = | iiii iiii |  iiii  iiii |
;
;       num_hf_period2     = | iiii iiii |  iiii  iiii |
;
;       first_zc_flag2     = | iiii iiii |  iiii  iiii |
;
;  Statics :
;       count2             = | iiii iiii |  iiii  iiii |
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 62 (Max)
;                        Program Words : 49
;                        NLOAC         : 42
;
;  Address Registers used:
;                        None
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
;                        a0  b0  x0  y0   sr
;                        a1  b1      y1   pc
;                        a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           count2 = count2+1
;           If ( zero_cross2 == 1 ) 
;               diff = count2 - hf_period2 
;               adiff = abs(diff)
;               If ( first_zc_flag2 == 2 )
;                   If ( adiff < 8 )
;                       num_hf_period2 = num_hf_period2+1
;                       sum_hf_period2 = sum_hf_period2+count2 
;                   Endif
;               Else 
;                   first_zc_flag2 = 1
;                   If ( adiff <= 15 )
;                       num_hf_period2 = num_hf_period2 + 1
;                       sum_hf_period2 = sum_hf_period2 + count2
;                       If (num_hf_period2 == 2)
;                           hf_period2 = sum_hf_period2 /2
;                           first_zc_flag2 = 2
;                       Endif
;                   Endif
;               Endif
;               count2 = 0 
;            Endif
;       End
;
;**************************** Assembly Code *******************************
 
        SECTION TD_SND_CODE
        
        GLOBAL  TD_PERIOD_EST2

        org     p:

TD_PERIOD_EST2

_Begin_TD_PERIOD_EST2 
        move    x:count2,y1               ;Get the value of count2
        inc     y1                        ;Count2 = Count2 + 1
        tstw    x:zero_cross2             ;Get the value of Zero_cross2
                                          ;  Check zero_cross2 flag
        beq     _comeout                  ;Exit the module if zero_cross2=0
        move    #<4,y0                    ;count2 << 4 to get 12.4 format 
        asll    y1,y0,a
        move    x:hf_period2,x0           ;Get the value of hf_period2
        sub     x0,a                      ;Evaluate count2 - hf_period2 
        abs     a                         ;adiff = abs(diff) in 12.4 format
        cmp     #2,b                      ;Compare first_zc_flag2 with 2
        bne     <_loop1                   ;Branch if first_zc_flag2 != 2
        cmp     #128,a                    ;Compare adiff with 8 << 4 since 
                                          ;  adiff is in 12.4 format   
        bge     _outofloop                ;Branch if adiff >= 128
                                          ;  (8 in 12.4 format)
        inc     x:num_hf_period2          ;Increment num_hf_period2
                                          ; num_hf_period2 = num_hf_period2 + 1
        add     y1,x:sum_hf_period2       ;Evaluate sum_hf_period2 + count2
        move    x:sum_hf_period2,a        ;sum_hf_period2 = sum_hf_period2+count2
        bra     <_outofloop               ;Branch out to set count2 = 0 
_loop1
   
        move    #<1,x:first_zc_flag2      ;Set first_zc_flag2 = 1
        cmp     #240,a                    ;Compare adiff with 15 << 4 since 
                                          ;  adiff is in 12.4 format
        bgt     <_outofloop               ;Branch if adiff > 240
                                          ;  (15 in 12.4 format)
        inc     x:num_hf_period2          ;Increment num_hf_period2
        move    x:num_hf_period2,a        ;num_hf_period2 = num_hf_period2 + 1
        move    x:sum_hf_period2,b
        add     y1,b                      ;Evaluate sum_hf_period2 + count2
        move    b,x:sum_hf_period2        ;sum_hf_period2 = sum_hf_period2+count2
        cmp     #2,a                      ;Compare num_hf_period2 with 2
        bne     <_outofloop               ;Branch if num_hf_period2 != 2
        move    #<3,y1                    ;Evaluate sum_hf_period2 / 2
        asll    b1,y1,b                   ;Convert hf_period2 in 12.4 format
        move    b,x:hf_period2            ;Store hf_period2 
        move    #0,x:first_zc_flag2       ;first_zc_flag2 = 2
_outofloop        
        move    #<0,y1                   ;For storing count2 = 0
_comeout
        move     y1,x:count2              ;Store count2 
_End_TD_PERIOD_EST2

		rts


        ENDSEC
;****************************** End of File *******************************

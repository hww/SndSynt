;**************************************************************************                                    
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Rights Reserved                           
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_PERIOD_EST1
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
;  Estimation of period for disabler tone on rcvchannel
;  All the variables ending with 1 represent channel 1 (rcvchannel)
;
;  Symbols Used :
;       zero_cross1       : Flag to indicate zero crossing 
;       hf_period1        : Half period of the modulated tone
;       sum_hf_period1    : Sum of valid half periods
;       num_hf_period1    : Number of valid half periods
;       first_zc_flag1    : First zero crossing indication flag
;       count1            : Counter for counting number of samples 
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
;  1. The function TD_INIT should be called before calling this function
;     The constant and variable declarations are defined in file td_data.asm
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
;       hf_period1         = | iiii iiii |  iiii  ffff |
;
;       sum_hf_period1     = | iiii iiii |  iiii  iiii |
;
;       num_hf_period1     = | iiii iiii |  iiii  iiii |
;
;       first_zc_flag1     = | iiii iiii |  iiii  iiii |
;
;  Statics :
;       count1             = | iiii iiii |  iiii  iiii |
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 60 (Max)
;                        Program Words : 47
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
;           count1 = count1+1
;           If ( zero_cross1 == 1 ) 
;               diff = count1 - hf_period1 
;               adiff = abs(diff)
;               If ( first_zc_flag1 == 2 )
;                   If ( adiff < 8 )
;                       num_hf_period1 = num_hf_period1+1
;                       sum_hf_period1 = sum_hf_period1+count1 
;                   Endif
;               Else 
;                   first_zc_flag1 = 1
;                   If ( adiff <= 15 )
;                       num_hf_period1 = num_hf_period1 + 1
;                       sum_hf_period1 = sum_hf_period1 + count1
;                       If (num_hf_period1 == 2)
;                           hf_period1 = sum_hf_period1 /2
;                           first_zc_flag1 = 2
;                       Endif
;                   Endif
;               Endif
;               count1 = 0 
;            Endif
;       End
;
;**************************** Assembly Code *******************************
     
        SECTION TD_RCV_CODE
        
        GLOBAL  TD_PERIOD_EST1

        org     p:

TD_PERIOD_EST1

_Begin_TD_PERIOD_EST1 
        move    x:count1,y1               ;Get the value of count1
        inc     y1                        ;Count1 = Count1 + 1
        tstw    x:zero_cross1             ;Get the value of Zero_cross1
                                          ;  Check zero_cross1 flag
        beq     _comeout                  ;Exit the module if zero_cross1=0
        move    #<4,y0                    ;count1 << 4 to get 12.4 format 
        asll    y1,y0,a
        move    x:hf_period1,x0           ;Get the value of hf_period1
        sub     x0,a                      ;Evaluate count1 - hf_period1 
        abs     a                         ;adiff = abs(diff) in 12.4 format
        cmp     #2,b                      ;Compare first_zc_flag1 with 2
        bne     <_loop1                   ;Branch if first_zc_flag1 != 2
        cmp     #128,a                    ;Compare adiff with 8 << 4 since 
                                          ;  adiff is in 12.4 format   
        bge     _outofloop                ;Branch if adiff >= 128
                                          ;  (8 in 12.4 format)
        inc     x:num_hf_period1          ;Increment num_hf_period1
                                          ; num_hf_period1 = num_hf_period1 + 1
        add     y1,x:sum_hf_period1       ;Evaluate sum_hf_period1 + count1
        move    x:sum_hf_period1,a        ;sum_hf_period1 = sum_hf_period1+count1
        bra     <_outofloop               ;Branch out to set count1 = 0 
_loop1
   
        move    #<1,x:first_zc_flag1      ;Set first_zc_flag1 = 1
        cmp     #240,a                    ;Compare adiff with 15 << 4 since 
                                          ;  adiff is in 12.4 format
        bgt     <_outofloop               ;Branch if adiff > 240
                                          ;  (15 in 12.4 format)
        inc     x:num_hf_period1          ;Increment num_hf_period1
        move    x:num_hf_period1,a        ;num_hf_period1 = num_hf_period1 + 1
        move    x:sum_hf_period1,b
        add     y1,b                      ;Evaluate sum_hf_period1 + count1
        move    b,x:sum_hf_period1        ;sum_hf_period1 = sum_hf_period1+count1
        cmp     #2,a                      ;Compare num_hf_period1 with 2
        bne     <_outofloop               ;Branch if num_hf_period1 != 2
        move    #<3,y1                    ;Evaluate sum_hf_period1 / 2
        asll    b1,y1,b                   ;Convert hf_period1 in 12.4 format
        move    b,x:hf_period1            ;Store hf_period1 
        move    #0,x:first_zc_flag1       ;first_zc_flag1 = 2
_outofloop        
        move    #<0,y1                    ;For storing count1 = 0
_comeout
        move     y1,x:count1              ;Store count1 
_End_TD_PERIOD_EST1


		rts


        ENDSEC
;****************************** End of File *******************************

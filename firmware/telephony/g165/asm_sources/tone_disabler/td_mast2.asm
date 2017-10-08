;**************************************************************************                                  
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                            
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_MASTER_SND
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Reversion History ****************************
;
;  DD/MM/YY     Code Ver        Description             Author
;  --------     --------        -----------             ------
;  5/11/97      0.0.1           Macro Created           Qiu Lunji
;  19/11/97     1.0.0           Reviewed and Modified   Qiu Lunji
;  10/07/00     1.0.1           Converted macros to     Sandeep Sehgal
;                               functions    
;
;*************************** Function Description *************************
;
;  To perform tone detection on send channel.
;  All the variables ending with 2 represents snd channel. 
;
;  Symbols Used :
;       sin_sample        : Input sample from snd channel
;       g165_tone_disable2 : Flag to disable G.165 echo-cancellor on snd chn
;       tone_count2       : Sample counter for the valid tone on snd chn 
;       dont_adapt2       : Flag to freeze adaptation on snd chn
;       state_TD2         : State of tone detector for snd chn
;       reset_TD2         : Flag to reset tone detector in snd chn
;  
;  Functions Called :
;       TD_BPF2           : Band pass filtering and valid tone 
;                            criteria-checking for every sample in snd chn
;       TD_LPF_MODLN2     : Modulation, Low pass filtering and zero cross 
;                            detection for snd chn
;       TD_SET_STAT2      : Function which sets state of the tone detector 
;                            depending on tone counter for snd chn
;                            and performs inits for the new state
;       TD_PERIOD_EST2    : Estimation of period for snd chn
;       TD_PH_REVERS2     : Function which detects the phase reversal of 
;                            the disabler tone for snd chn
;       TD_DTCT_LGIC2     : Logic to determine whether Disabler tone was 
;                            present or not on snd chn 
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The Function TD_INIT should be called before calling this function for
;     the first time. The constant and variable declarations are deined 
;     in file td_data.asm
;  2. TD_CONST_INI_XRAM must be defined in the calling module or during
;     compilation
;
;************************** Input and Output ******************************
;
;  Input  :
;       rin_sample         = | s.fff ffff | ffff ffff | in x:rin_sample
;
;  Output :
;       g165_tone_disable2  = | 0000 0000  | 0000 000i | 
;                                                in x:g165_tone_disable2
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       tone_count2      = | iiii iiii | iiii iiii |
;
;       dont_adapt2      = | 0000 0000 | 0000 000i |
;
;       state_TD2        = | 0000 0000 | 0000 0iii |
;
;       reset_TD2        = | 0000 0000 | 0000 000i |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                    Icycle Count  : 71 +
;                         ( cc of TD_BPF2, TD_SET_STAT2, TD_LPF_MODLN2, 
;			    TD_PERIOD_EST2, TD_PH_REVER2 and TD_DTCT_LGIC2) 
;                         Total: 428 = 71+357 for TD_CONSTANT_INIT_XRAM = 1
;			         436 = 71+365 for TD_CONSTANT_INIT_XRAM = 0
;
;                    Program Words : 48 +
;                         ( cc of TD_BPF2, TD_SET_STAT2, TD_LPF_MODLN2, 
;			    TD_PERIOD_EST2, TD_PH_REVER2 and TD_DTCT_LGIC2) 
;                         Total: 426 = 48+378 for TD_CONSTANT_INIT_XRAM = 1
;			         430 = 48+382 for TD_CONSTANT_INIT_XRAM = 0
;
;                    NLOAC         : 45
;
;  Address Registers used:
;                        r0 : used in TD_BPF2 and TD_LPF_MODLN2 modules in 
;                             circular addressing modes
;                        r1 : used in TD_SET_STAT2 and TD_PH_REVERS2 modules 
;                             in both circular and linear addressing modes
;                        r3 : used in TD_BPF2 and TD_LPF_MODLN2 modules in 
;                             circular addressing modes
;
;  Offset Registers used:
;                        n  : used as an offset for updating r1 in 
;                             TD_SET_STAT2 module
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  m01  n  a0  b0  x0  y0  sr
;                        r1          a1  b1      y1  pc
;                        r3          a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           TD_Bpf2(rin_sample)
;           If ( reset_TD2 == 1 )
;               state_TD2 = 0
;               tone_count2 =   0
;               tone_pass_count2 = 0
;               dont_adapt2 = 0
;               reset_TD2 = 0
;              
;           Else
;               tone_count2 = tone_count2 + 1
;               If ( tone_count2 == 8000 )
;                   g165_tone_disable2 = TD_dtct_lgic2()
;                  
;               Elseif ( tone_count2 >= 1600 )
;                   dont_adapt2 = 1
;                   state_TD2 = TD_Set_stat2(tone_count2)
;                   If (state_TD2 >= 1)
;                       zero_cross2 = TD_Lpf_modln2(rin_sample)
;                       If ( state_TD2 == 2 )
;                           TD_period_est2(zero_cross2)
;                       Elseif ( stat_TD2 >= 3 )
;                           TD_ph_reverse2(zero_cross2)
;                       Endif
;                   Endif
;               Endif
;           Endif    
;      
;      End
;  
;**************************** Assembly Code *******************************
       
        SECTION TD_SND_CODE
        
        GLOBAL  TD_MASTER_SND

        org     p:

TD_MASTER_SND

_Begin_TD_MASTER_SND

        jsr     TD_BPF2                   ;Calling the function TD_BPF2
        move    x:reset_TD2,x0
        cmp     #0,x0                     ;Test reset_TD2 with zero
        beq     <_caseelse                ;Branch if reset_TD2 = 0
        clr     a
        move    a,x:state_TD2             ;state_TD2 = 0
        move    a,x:tone_count2           ;tone_count2 = 0
        move    a,x:tone_pass_count2      ;tone_pass_count2 = 0
        move    a,x:dont_adapt2           ;dont_adapt2 = 0
        move    a,x:reset_TD2             ;reset_TD2 = 0
        jmp     _End_TD_MASTER_SND
_caseelse
        move    x:tone_count2,a             
        inc     a
        move    a,x:tone_count2           ;tone_count2 = tone_count2 + 1
        
        cmp     #8000,a                   ;Compare tone_count2 with 8000
        jne     _nextchk                  ;Branch if tone_count2 != 8000

        jsr     TD_DTCT_LGIC2             ;Call function TD_DTCT_LGIC2

        jmp     _End_TD_MASTER_SND
_nextchk
        cmp     #1600,a                   ;Compare tone_count2 with 1600
        jlt     _End_TD_MASTER_SND        ;Branch if tone_ct2 < 1600
        move    #<1,x:dont_adapt2         ;dont_adapt2 = 1
        move    x:tone_count2,a

        jsr     TD_SET_STAT2              ;Call function TD_SET_STAT2

        move    x:state_TD2,a            
        cmp     #<1,a                     ;Compare state_TD2 with 1
        jlt     _End_TD_MASTER_SND        ;Branch if state_TD2 < 1

        jsr     TD_LPF_MODLN2             ;Call function TD_LPF_MODLN2

        move    x:state_TD2,a            
        cmp     #<2,a                     ;Compare state_TD2 with 2
        jne     _next                     ;Branch if state_TD2 != 2

        jsr     TD_PERIOD_EST2            ;Call function TD_PERIOD_EST2

        jmp     _End_TD_MASTER_SND
_next
        move    x:state_TD2,a 
        cmp     #<3,a                     ;Compare state_TD2 with 3
        jlt     _End_TD_MASTER_SND        ;Branch if state_TD2 < 3

        jsr     TD_PH_REVERS2             ;Call function TD_PH_REVERS2

_End_TD_MASTER_SND
 
 		rts
 
        ENDSEC
;****************************** End of File *******************************

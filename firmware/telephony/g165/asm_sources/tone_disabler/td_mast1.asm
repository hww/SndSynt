;**************************************************************************                                    
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                            
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_MASTER_RCV
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
;  To perform tone detection on rcv channels.
;  All the variables ending with 1 represents rcv channel. 
;
;  Symbols Used :
;       rin_sample        : Input sample from rcv channel
;       g165_tone_disable1: Flag to disable G.165 echo-cancellor on rcv chn
;       tone_count1       : Sample counter for the valid tone on rcv chn 
;       dont_adapt1       : Flag to freeze adaptation on rcv chn
;       state_TD1         : State of tone detector for rcv chn
;       reset_TD1         : Flag to reset tone detector in rcv chn
;  
;  Functions Called :
;       TD_BPF1           : Band pass filtering and valid tone 
;                            criteria-checking for every sample in rcv chn
;       TD_LPF_MODLN1     : Modulation, Low pass filtering and zero cross 
;                            detection for rcv chn
;       TD_SET_STAT1      : Function which sets state of the tone detector 
;                            depending on tone counter for rcv chn
;                            and performs inits for the new state
;       TD_PERIOD_EST1    : Estimation of period for rcv chn
;       TD_PH_REVERS1     : Function which detects the phase reversal of 
;                            the disabler tone for rcv chn
;       TD_DTCT_LGIC1     : Logic to determine whether Disabler tone was 
;                            present or not on rcv chn 
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The function TD_INIT should be called before calling this function for
;     the first time. The constant and variable declarations are
;     defined in file td_data.asm
;  2. TD_CONST_INT_XRAM must be defined in the calling module or during 
;     compilation
;
;************************** Input and Output ******************************
;
;  Input  :
;       rin_sample         = | s.fff ffff | ffff ffff | in x:rin_sample
;
;  Output :
;       g165_tone_disable1 = | 0000 0000  | 0000 000i | 
;                                                in x:g165_tone_disable1
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       tone_count1      = | iiii iiii | iiii iiii |
;
;       dont_adapt1      = | 0000 0000 | 0000 000i |
;
;       state_TD1        = | 0000 0000 | 0000 0iii |
;
;       reset_TD1        = | 0000 0000 | 0000 000i |
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
;                   NLOAC         : 45
;
;  Address Registers used:
;                        r0 : used in TD_BPF1 and TD_LPF_MODLN1 modules in 
;                             circular addressing modes
;                        r1 : used in TD_SET_STAT1 and TD_PH_REVERS1 modules 
;                             in both circular and linear addressing modes
;                        r3 : used in TD_BPF1 and TD_LPF_MODLN1 modules in 
;                             circular addressing modes
;
;  Offset Registers used:
;                        n  : used as an offset for updating r1 in 
;                             TD_SET_STAT1 module
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
;**************************** Environment *********************************
;
;       Assembler : ASM56800 Version 6.0.1
;       Machine   : IBM PC
;       OS        : MSDOS Under Window NT Ver 4.0
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           TD_Bpf1(rin_sample)
;           If ( reset_TD1 == 1 )
;               state_TD1 = 0
;               tone_count1 =   0
;               tone_pass_count1 = 0
;               dont_adapt1 = 0
;               reset_TD1 = 0
;              
;           Else
;               tone_count1 = tone_count1 + 1
;               If ( tone_count1 == 8000 )
;                   g165_tone_disable1 = TD_dtct_lgic1()
;                  
;               Elseif ( tone_count1 >= 1600 )
;                   dont_adapt1 = 1
;                   state_TD1 = TD_Set_stat1(tone_count1)
;                   If (state_TD1 >= 1)
;                       zero_cross1 = TD_Lpf_modln1(rin_sample)
;                       If ( state_TD1 == 2 )
;                           TD_period_est1(zero_cross1)
;                       Elseif ( stat_TD1 >= 3 )
;                           TD_ph_reverse1(zero_cross1)
;                       Endif
;                   Endif
;               Endif
;           Endif    
;      
;      End
;  
;**************************** Assembly Code *******************************
       
        SECTION TD_RCV_CODE
        
        GLOBAL  TD_MASTER_RCV
        
        org     p:
        

TD_MASTER_RCV

_Begin_TD_MASTER_RCV

        jsr     TD_BPF1                   ;Calling the function TD_BPF1
        move    x:reset_TD1,x0
        cmp     #0,x0                     ;Test reset_TD1 with zero
        beq     <_caseelse                ;Branch if reset_TD1 = 0
        clr     a
        move    a,x:state_TD1             ;state_TD1 = 0
        move    a,x:tone_count1           ;tone_count1 = 0
        move    a,x:tone_pass_count1      ;tone_pass_count1 = 0
        move    a,x:dont_adapt1           ;dont_adapt1 = 0
        move    a,x:reset_TD1             ;reset_TD1 = 0
        jmp     _End_TD_MASTER_RCV
_caseelse
        move    x:tone_count1,a             
        inc     a
        move    a,x:tone_count1           ;tone_count1 = tone_count1 + 1
        
        cmp     #8000,a                   ;Compare tone_count1 with 8000
        jne     _nextchk                  ;Branch if tone_count1 != 8000

        jsr      TD_DTCT_LGIC1            ;Call function TD_DTCT_LGIC1

        jmp     _End_TD_MASTER_RCV
_nextchk
        cmp     #1600,a                   ;Compare tone_count1 with 1600
        jlt     _End_TD_MASTER_RCV        ;Branch if tone_ct1 < 1600
        move    #<1,x:dont_adapt1         ;dont_adapt1 = 1
        move    x:tone_count1,a

        jsr     TD_SET_STAT1              ;Call function TD_SET_STAT1

        move    x:state_TD1,a            
        cmp     #<1,a                     ;Compare state_TD1 with 1
        jlt     _End_TD_MASTER_RCV        ;Branch if state_TD1 < 1

        jsr     TD_LPF_MODLN1             ;Call function TD_LPF_MODLN1

        move    x:state_TD1,a            
        cmp     #<2,a                     ;Compare state_TD1 with 2
        jne     _next                     ;Branch if state_TD1 != 2

        jsr     TD_PERIOD_EST1            ;Call function TD_PERIOD_EST1

        jmp     _End_TD_MASTER_RCV
_next
        move    x:state_TD1,a 
        cmp     #<3,a                     ;Compare state_TD1 with 3
        jlt     _End_TD_MASTER_RCV        ;Branch if state_TD1 < 3

        jsr     TD_PH_REVERS1             ;Call function TD_PH_REVERS1

_End_TD_MASTER_RCV

		rts

        ENDSEC
;****************************** End of File *******************************

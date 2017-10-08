;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : G165_SAMP_PRO
;  Project ID     : G165EC
;  Author         : Qiu, Cindy, Boh Lim
;  Modified by    : Sandeep Sehgal
;
;************************* Revision History *******************************
;
;  DD/MM/YY     Code Ver   Description                Author
;  --------     --------   -----------                ------
;  27/11/97     0.0.1      Module created             Qiu, Cindy, Boh Lim
;  05/01/98     1.0.0      Modified per review        Qiu, Cindy, Boh Lim
;                          comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  The overall integration module of G165EC sample processing.
;  All the variables ending with 1 represents receive (rcv) channel 
;  All the variables ending with 2 represents send (snd) channel 
;
;  Symbols Used :
;       sin_sample         : Sample from snd channal
;       rin_sample         : Sample from rcv channal
;       sout_sample        : Output sample to snd channel
;       Disable_TD         : Flag to disable tone detect logic (set by user)
;       inhibit_converge   : Flag to freeze adaptation (set by user)
;       dont_adapt1        : Flag to freeze G.165 echo-cancellor in rcv chn
;       dont_adapt2        : Flag to freeze G.165 echo-cancellor in snd chn
;       dont_adapt         : Flag to freeze adaptation
;       g165_ec_enable     : Flag to enable or disable echo cancellation
;       g165_tone_disable1 : Flag to detect G.165 echo-cancellor in rcv chn
;       g165_tone_disable2 : Flag to detect G.165 echo-cancellor in snd chn
;       fstat_p            : Pointer to the filter states
;       hfilt_p            : Pointer to the filter coefficients
;  
;  Subroutines Called :
;       HRL_SAMP_PRO_subroutine     : To collect in-coming samples into input
;                                     buffer A or B and to set HRL_frm_full
;       HRL_RESTART_subroutine      : To re-initialise variables of
;                                     Hold-Release Logic
;       EC_SAMP_PRO_subroutine      : To perform sample processing for echo
;                                     cancellation
;       TD_MASTER_MODULE_subroutine : To perform tone detection in
;                                     rcv/snd channels
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The user options (Disable_TD, inhibit_converge, nl_option) must be set
;     before calling this function.
;  2. The function HRL_INIT, TD_INIT & EC_INIT should be called in the order
;     specified, before the first call of this function.
;  3. At least 2 locations must be available on the software stack :
;          Subroutine               Stacks required
;         ------------              ---------------
;         HRL_SAMP_PRO_subroutine :       2
;         HRL_RESTART_subroutine  :       2
;         TD_MASTER_MODULE_subroutine :   2
;         EC_SAMP_PRO_subroutine  :       2
;
;************************** Input and Output ******************************
;
;  Input  :
;       rin_sample        = | s.fff ffff | ffff ffff | in x:rin_sample
;
;       sin_sample        = | s.fff ffff | ffff ffff | in x:sin_sample
;
;  Output :
;       sout_sample       = | s.fff ffff | ffff ffff | in x:sout_sample
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       Disable_TD         = | 0000 0000 | 0000 000i  |
;
;       inhibit_converge   = | 0000 0000 | 0000 000i  |
;
;       dont_adapt1        = | 0000 0000 | 0000 000i  |
;
;       dont_adapt2        = | 0000 0000 | 0000 000i  |
;
;       dont_adapt         = | 0000 0000 | 0000 000i  |
;
;       g165_ec_enable     = | 0000 0000 | 0000 000i  |
;
;       g165_tone_disable1 = | 0000 0000 | 0000 000i  |
;
;       g165_tone_disable2 = | 0000 0000 | 0000 000i  |
;
;       fstat_p            = | iiii iiii  | iiii iiii |
;
;       hbak1_p            = | iiii iiii  | iiii iiii |
;
;
;  Statics :
;
;****************************** Resources *********************************
;
;                        Cycle Count   : 4*ECHOSPAN + 765
;                        Program Words : 49
;                        NLOAC         : 40
;
;  Address Registers used:
;                        r0 
;                        r1 
;                        r2 
;                        r3 
;
;  Offset Registers used:
;                        n
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  m01  a0  b0  x0  y0  sr
;                        r1  n    a1  b1      y1  pc
;                        r2       a2  b2                 
;                        r3
;
;***************************** Pseudo Code ********************************
;
;       Begin
;            If ( g165_ec_enable == 1 )
;                If ( Disable_TD == 0 )
;                    % Execute tone detection algorithm.%
;                    td_master()             
;                Endif         
;        
;                If (g165_tone_disable1 == 1) | (g165_tone_disable2 == 1)
;                    g165_ec_enable = 0;
;                    % No echo-cancellation performed %
;                    sout_sample = sin_sample ;                    
;                    % Re-initialize Hold-Release Logic %
;                    HRL_restart()
;                Else
;                    If (dont_adapt1 == 1) | (dont_adapt2 == 1) | 
;                        (inhibit_converge == 1)
;                        dont_adapt = 1
;                    Else
;                        dont_adapt = 0;
;                    Endif
;                    % Execute echo cancellation algorithm.%        
;                    sout_sample = ec_samp_pro();
;                Endif
;            Else
;                % No echo-cancellation performed %
;                sout_sample = sin_sample; 
;                % stores win*sample in a buffer %
;                HRL_samp_pro(); 
;            Endif   
;       End
;
;
;**************************** Assembly Code *******************************
 
        SECTION G165_CODE
        
        GLOBAL  G165_SAMP_PRO
        
        org     p:
        
G165_SAMP_PRO     

_Begin_G165_SAMP_PRO
        
        tstw    x:g165_ec_enable          ;If g165_ec_enable =0, branch
                                          ;  to HOLD-RELEASE LOGIC processing
        beq     _HRL_pro
        tstw    x:Disable_TD              ;Call TD_MASTER module
                                          ;  if Disable_TD = 0
        bne     _go_HRL_RESTART

        jsr     TD_MASTER_RCV_subroutine  ;Call TD_MASTER_MODULE subroutine
        jsr     TD_MASTER_SND_subroutine  ;Call TD_MASTER_MODULE subroutine

; Check (g165_tone_disable1 == 1) | (g165_tone_disable2 == 1)
        tstw    x:g165_tone_disable1      ;Test g165_tone_disable1 = 1
        bne     _go_HRL_RESTART           ; or g165_tone_disable2 = 1
        tstw    x:g165_tone_disable2      ;Branch if the above condition
        beq     _go_EC_SAMP_PRO           ; is not satisfied

_go_HRL_RESTART
        clr     a                         
        move    a,x:g165_ec_enable        ;g165_ec_enable = 0  
        move    x:sin_sample,a     
        move    a,x:sout_sample           ;sout_sample = sin_sample
        jsr     HRL_RESTART_subroutine    ;Call HOLD_RESTART subroutine
        bra     _endisr                   ;Branch to end of ISR  

_go_EC_SAMP_PRO
        move    x:dont_adapt1,x0          ;Check dont_adapt1 = 1
        move    x:dont_adapt2,a           ;  or dont_adapt2 = 1 or  
        or      x0,a                      ;  inhibit_converge = 1
        move    x:inhibit_converge,x0
        or      x0,a
        move    a,x:dont_adapt            ;Store result into dont_adapt

; Setup calling requirements of EC_SAMP_PRO_subroutine

        move    #$ffff,m01                ;Calling requirement 2 of
        move    #0,n                      ;  EC_SAMP_PRO module

        jsr     EC_SAMP_PRO_subroutine    ;Call EC_SAMP_PRO subroutine

        bra     _endisr

_HRL_pro
        move    x:sin_sample,a
        move    a,x:sout_sample           ;sout_sample = sin_sample, i.e.,
                                          ; no echo cancellation performed
        jsr     HRL_SAMP_PRO_subroutine   ;Call HRL sample processing
_endisr
        nop
_End_G165_SAMP_PRO
        rts

        ENDSEC

;****************************** End of File *******************************

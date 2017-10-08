;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_BPF2
;  Project ID     : G165EC
;  Author         : Sim Boh Lim
;  Modified by    : Sandeep Sehgal
;  
;**************************Revision History ******************************* 
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  30/9/97      0.0.1      Macro Created                Sim Boh Lim
;  6/10/97      1.0.0      Reviewed and Modified        Sim Boh Lim
;  10/11/97     1.0.1      Replace move b,a with        Sim Boh Lim
;                          tfr b,a
;  10/07/00    1.0.2        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  This function first computes the 2100 (+-21) Hz tone level and SNR for the
;  snd channel, and then compares them with their threshold values
;  in accordance with Req B.1-B.3 of the design doc.
;
;  Symbols Used :
;       sin_sample          : Input sample from snd channel
;       tone_pass_count2    : Block counter to count number of vaild tone
;                             passes (in accordance with Req B.1-B.3)
;       state_TD2           : State of tone disabler
;       reset_TD2           : Reset signal for tone disabler
;       TD_frm_energy2_high : MSW of 19-point frame energy for snd channel
;       TD_frm_energy2_low  : LSW of 19-point frame energy for snd channel
;       goertzel_count2     : Counter for goertzel algorithn, from 0 to 19
;       goertzel2[2]        ; States used in Goertzel algorithm
;       ave_TD_tone2_high   ; MSW of average tone (2100 +- 21 Hz) energy
;       ave_TD_tone2_low    ; LSW of average tone (2100 +- 21 Hz) energy
;       ave_TD_noise2_high  : MSW of average noise energy
;       ave_TD_noise2_low   : LSW of average noise energy
;       TD_TONE_THRES       : Tone threshold constant for Req B.1-B.2
;       TD_SNR_THRES        : SNR threshold constant for Req B.3
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
;  1. TD_INIT should be called before the 1st call of this function.
;  2. The constant and variable declarations for this function are defined in
;     file td_data.asm. The following variables should be declared
;     consecutively in the order:
;     TD_frm_energy2_high, TD_frm_energy2_low, goertzel_count2,
;     goertzel2[2], ave_TD_tone2_high, ave_TD_tone2_low, ave_TD_noise2_high
;     and ave_TD_noise2_low.
;************************** Input and Output ******************************
;
;  Input  :
;       sin_sample          = | s.fff ffff | ffff ffff |     in x:sin_sample
;
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       tone_pass_count2    = |  iiii iiii | iiii iiii |
;
;       state_TD2           = |  0000 0000 | 0000 0iii |
;
;       reset_TD2           = |  0000 0000 | 0000 000i |
;
;  Statics :
;  The following variables must be declared consecutively in the
;  following order:
;
;       TD_frm_energy2_high = | i.fff ffff | ffff ffff |
;
;       TD_frm_energy2_low  = |  ffff ffff | ffff ffff |
;                 (both correspond to 10*log10(2*TD_frm_energy2) dBm0, where
;                  TD_frame_energy2 = TD_frm_energy2_high:TD_frm_energy2_low)
;
;       goertzel_count2     = |  0000 0000 | 000i iiii |
;
;       goertzel2(k)        = | i.fff ffff | ffff ffff |  for k=1 to 2
;
;       ave_TD_tone2_high   = | i.fff ffff | ffff ffff |
;
;       ave_TD_tone2_low    = |  ffff ffff | ffff ffff |
;                 (both correspond to 10*log10(2*ave_TD_tone2) dBm0, where
;                  ave_TD_tone2 = ave_TD_tone2_high:ave_TD_tone2_low)
;
;       ave_TD_noise2_high  = | i.fff ffff | ffff ffff |
;
;       ave_TD_noise2_low   = |  ffff ffff | ffff ffff |
;                 (both correspond to 10*log10(2*ave_TD_noise2) dBm0, where
;                  ave_TD_noise2 = ave_TD_noise2_high:ave_TD_noise2_low)
;
;       TD_TONE_THRES       = 0.5*@POW(10.0,-33.0/10.0) or 2.5059E-4
;                             (corresponds to -33 dBm0)
;
;       TD_SNR_THRES        = @POW(10.0,5.25/10.0) or 3.349654
;                             (corresponds to 5.25 dB)
;
;       Note: TD_TONE_THRES and TD_SNR_THRES are constant values
;             declared using EQU directive.
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 65 (max)
;                        Program Words : 90
;                        NLOAC         : 81
;
;  Address Registers used:
;                        r2 : used to access static variable
;                             TD_frm_energy2_high, TD_frm_energy2_low,
;                             goertzel_count2 and goertzel2
;                        r3 : used to access static variable
;                             goertzel2, ave_TD_tone2_high,
;                             ave_TD_tone2_low, ave_TD_noise2_high and
;                             ave_TD_noise2_low
;  Offset Registers used:
;                        n
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;  Registers Changed:
;                        r2    a0  b0  x0  y0  sr
;                        r3    a1  b1      y1  pc
;                              a2  b2
;
;**************************** Environment *********************************
;
;       Assembler : ASM56800 Version 6.0.1
;       Machine   : IBM PC
;       OS        : MSDOS under Window NT Ver 4.0
;
;***************************** Pseudo Code ********************************
;
; The in-coming sample, except every 20th sample, is bandpass filtered
; using a 19-point Goertzel algorithm at 2100 Hz centre frequency.
; At every 20th sample, the tone level and SNR are calculated from
; the result of the Goertzel algorithm. The calculated tone level and SNR
; are compared with their threshold values. If both are above the threshold
; values, the tone_pass_count2 is incremented. Otherwise, the reset_TD flag
; is set to 1 (on an additional condition that the tone disabler is not
; in the phase-reversal detection state).
;
;      CK = 2.0 * cos(2*3.14159*5/19);
;
;if  (goertzel_count2 < 19),
;      tmp = goertzel2(1)*CK - goertzel2(2) + sin_sample*1.0/19.0;
;      goertzel2(2) = goertzel2(1);
;      goertzel2(1) = tmp;
;      goertzel_count2 = goertzel_count2 + 1;
;
;      TD_frm_energy2 = TD_frm_energy2 + sin_sample* sin_sample*1.0/19.0;
;else
;      % result of Goertzel algorithm %
;      tmp = 2.0*(goertzel2(2)*goertzel2(2) + goertzel2(1)*goertzel2(1)
;                - CK*goertzel2(1)*goertzel2(2));
;
;      ADAPT = 0.125;    % useful values : 0.0625, 0.125, 0.25 %
;      ave_TD_tone2  = ADAPT* (tmp-ave_TD_tone2) + ave_TD_tone2;
;
;      ave_TD_noise2  = ADAPT* (TD_frm_energy2-tmp-ave_TD_noise2)
;                         + ave_TD_noise2;
;      goertzel2(1) = 0;
;      goertzel2(2) = 0;
;      goertzel_count2 = 0;
;      TD_frm_energy2=0;
;
;      % Check tone level and SNR                   %
;      % TD_TONE_THRES corresponds to -33 dBm0      %
;      % TD_SNR_THRES corresponds to 5.25 dB        %
;
;      if ( (ave_TD_tone2 > TD_TONE_THRES)  &
;                         ( ave_TD_tone2/TD_SNR_THRES > ave_TD_noise2) ),
;             tone_pass_count2 = tone_pass_count2 + 1;
;      else
;          if ( state_TD2 ~= 4 ), % state_TD2=4 is the phase-reversal        %
;             reset_TD2 = 1;      % detection state. The estimated tone level%
;          endif                  % will dip at phase-reversal; such dip     %
;      endif                      % is ignored.                              %
;end
;
;**************************** Assembly Code *******************************
        
        SECTION TD_SND_CODE
        
        GLOBAL  TD_BPF2
        
        include "equates.asm"        

        org     p:
        

TD_BPF2

_Begin_TD_BPF2
        move    x:sin_sample,y0           ;Store in-coming sample
        move    x:goertzel_count2,a       ;Check if goertzel counter is equal
        cmp     #<19,a                    ; to 19
        beq     _CAL_TONE_INFO            ;Jmp if counter is equal to 19

; goertzel_count2 is less than 19
        incw    a                         ;Increment and save goertzel2_count
        move    a,x:goertzel_count2

; Execute goertzel algorithm
        move    #goertzel2+1,r3           ;Set goertzel2 pointer
        move    #-1,n
        move    #1.0/19.0,y1
        mpy     y1,y0,b  x:(r3)+n,x0      ;b = sin_sample*1.0/19.0
        tfr     b,a
        sub     x0,b     x:(r3)+n,x0
        move    #-0.16516,y1              ;y1 = CK
        macr    y1,x0,b  x:(r3)+,y1       ;b = goertzel2_val
        move    b,x:(r3)+                 ;Save goertzel2 states
        rnd     a        x0,x:(r3)+

;Cal frame energy TD_frm_energy2
        mpy     a1,y0,b                   ;b = sin_sample*sin_sample*1.0/19.0
        move    x:TD_frm_energy2_high,a   ;Load 32-bit frame energy
        move    x:TD_frm_energy2_low,a0
        add     b,a                       ;a = TD_frm_energy2 + b
        move    a,x:TD_frm_energy2_high   ;Save updated 32-bit frame energy
        move    a0,x:TD_frm_energy2_low
        bra     _END_TD_BPF2


_CAL_TONE_INFO
;goertzel_count2 is equal to 19, start calculation of average tone and noise
;energy and compare with the thresholds.

;Cal result of Goertzel algorithm
        move    #goertzel2+1,r3           ;Set goertzel2 pointer
        move    #-1,n
        move    #0.16516,y1               ;y1 = -CK
        move    x:(r3)-,y0                ;y0 = goertzel2(2)
        mpy     y0,y0,a  x:(r3)+,y0       ;a = goertzel2(2)*goertzel2(2)
                                          ; y0 = goertzel2(1)
        mpy     y0,y0,b                   ;b = goertzel2(1)*goertzel2(1)
        add     a,b                       ;b = goertzel2(2)*goertzel2(2)
                                          ;    + goertzel2(1)*goertzel2(1)
        mpy     y1,y0,a  x:(r3)+,y0       ;a = -CK*goertzel2(1)
                                          ; y0 = goertzel2(2)
        mpy     a1,y0,a  x:(r3)+,y1       ;a = -CK*goertzel2(1)*goertzel2(2);
                                          ; y1 = MSW of ave tone energy
        add     a,b
        asl     b        x:(r3)+n,y0      ;b = result of Goertzel algorithm
                                          ;    (tmp)
                                          ; y0 = LSW of ave tone energy
        tfr     b,a

;Cal ave tone energy
        sub     y,a                       ;a = tmp - ave_TD_tone2
        asr     a
        asr     a
        asr     a                         ;a = 0.125*(tmp - ave_TD_tone2)
        add     y,a                       ;a = updated ave_TD_tone2
        move    #TD_frm_energy2_high,r2   ;Load address of MSW of frame energy
        move    a,x:(r3)+                 ;Save 32-bit ave tone energy
        move    a0,x:(r3)+


;Cal ave noise energy
;Also clear frame energy, goertzel counter and states
        move    x:(r2)+,y1                ;Load MSW of frame energy
        move    x:(r2)+n,y0               ;Load LSW of frame energy

        sub     y,b                       ;b = tmp - TD_frm_energy2
        move    x:(r3)+,y1                ; y1 = MSW of ave noise energy
        move    x:(r3)+n,y0               ;y0 = LSW of ave noise energy

        clr     x0
        add     y,b
        neg     b     x0,x:(r2)+          ;b = TD_frm_energy2 -
                                          ;    tmp - ave_TD_noise2
        asr     b     x0,x:(r2)+
        asr     b     x0,x:(r2)+
        asr     b     x0,x:(r2)+          ;b = 0.125*(TD_frm_energy2 -
                                          ;           tmp - ave_TD_noise2)
        add     y,b                       ;Updated ave noise energy
        move    b,x:(r3)+                 ;Save 32-bit ave noise energy
        move    b0,x:(r3)

; Check tone level and SNR.
; a = ave tone energy,      b = ave noise energy

        move    #TD_TONE_THRES,y0         ;Load tone threshold
        cmp     y0,a    x0,x:(r2)+        ;Compare ave tone energy with threshold
                                          ; Clear goertzel2(2)
        ble     _RESET_TD2                ;Jump if energy is smaller

        move    #1.0/(TD_SNR_THRES),y0    ;Load 1/(SNR threshold)
        rnd     a
        move    a,a1                      ;Saturate a1 if a>1.0
        mpy     a1,y0,a                   ;a = ave_TD_tone2/TD_SNR_THRES
        cmp     b,a                       ;a - b = ave_TD_tone2/TD_SNR_THRES
                                          ;        - ave_TD_noise2
        ble     _RESET_TD2                ;Jump if difference is <=0

        incw    x:tone_pass_count2        ;Increment x:tone_pass_count2
        bra     _END_TD_BPF2
 
_RESET_TD2                                ;Reset Tone Disabler

;If state_TD2 ~= 4, reset the tone disabler. This is because
; state_TD2 = 4 is the phase-reversal detection state. The estimated
; tone level will dip at phase-reversal; such a dip should be ignored.
        move    x:state_TD2,a
        cmp     #<4,a
        beq     _END_TD_BPF2
        move    #<1,x0
        move    x0,x:reset_TD2

_END_TD_BPF2

	rts
	
	ENDSEC
;****************************** End of File *******************************

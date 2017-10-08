;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;
;  Function Name  : HRL_FRM_PRO
;  Project ID     : G165EC
;  Author         : Sim Boh Lim
;  Modified by    : Sandeep Sehgal
;  
;**************************Revision History ******************************* 
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  22/10/97      0.0.1     Macro Created                Sim Boh Lim
;  27/10/97      1.0.0     Reviewed and Modified        Sim Boh Lim
;  10/07/00      1.0.1     Converted macros to          Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  To process frame buffers for Hold-Release Logic
;
;  Symbols Used :
;       HRL_frm_full         : Flag to indicate that buffer A or B is full
;       flag_AB              : Flag to switch between buffer A and B
;       frm_buf_ptr          : Pointer to buffer A or B, on which RFFT is
;                              to be computed
;       prev_kmax            : Frequency index of spectral peak of previous
;                              RFFT frame
;       prev_tone_change     : Tone change status of previous frame
;       buf_A[HRL_FRMLEN+2]  : Buffer A for storing samples & RFFT results
;       buf_B[HRL_FRMLEN+2]  : Buffer B for storing samples & RFFT results
;       hann[HRL_FRMLEN/2]   : Hanning window coefficients (half a frame)
;       ave_HRL_tone_high    : MSW of average tone energy
;       ave_HRL_tone_low     : LSW of average tone energy
;       ave_HRL_noise_high   : MSW of average noise energy
;       ave_HRL_noise_low    : LSW of average noise energy
;       release_flag         : Release flag, if set,  indicates that Echo
;                              Canceller should be released from disable
;                              conditions
;       release_count        : Counter that increments by HRL_FRMSPAN if
;                              release conditions are met. If counter is >=
;                              RELEASE_TIME, then release_flag will be set
;       RELEASE_TIME         : Release time threshold (in ms, 250 +- 150 ms),
;                              to control setting of release_flag
;       HRL_FRMLEN           : Frame length for the input buffer
;                              (preferably 128)
;       HRL_FRMSPAN          : Frame span/duration in ms.
;       WINDOW_CORRECTION    : Correction for threshold calculation due to
;                              hanning window
;       HRL_TONE_THRES1      : Tone threshold constant for band 1 (390-700 Hz)
;       HRL_TONE_THRES2      : Tone threshold constant for band 2 (700-3000 Hz)
;       HRL_SNR_THRES        : SNR threshold constant
;       INDEX_200            : 200 Hz frequency index in the RFFT frame
;       INDEX_700            : 700 Hz frequency index in the RFFT frame
;       INDEX_3400           : 3400 Hz frequency index in the RFFT frame
;       kmax                 : Index of the peak in the power spectrum
;       sum3_spect           : Sum of 3 spectral amplitude around the maximum
;       sumtot_spect         : Sum of all power spectral magnitudes
;
;  Subroutine Called :
;      RFFT_subroutine       : computes the square of the magnitude of the FFT
;                              of a real sequence
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. HRL_INIT should be called before the first call of this module.
;     The constant and variable declarations for this module are defined in
;     file hrl_data.asm
;  2. 5 locations should be available in software stack (for rfft subroutine)
;  3. All hardware looping resources including LA, LC and 2 locations of HWS
;     must be available for use in nested hardware do loop (for rfft
;     subroutine)
;
;************************** Input and Output ******************************
;
;  Input  :
;       None
;
;  Output :
;       release_flag      = | 0000 0000 | 0000 000i |   in x:release_flag
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;
;       frm_count          = | iiii iiii | iiii iiii |
;                          = 0 to HRL_FRMLEN
;
;       HRL_frm_full       = | 0000 0000 | 0000 000i |
;
;       flag_AB            = | 0000 0000 | 0000 000i |
;
;       frm_buf_ptr        = | iiii iiii | iiii iiii |
;
;       prev_kmax          = | iiii iiii | iiii iiii |
;
;       prev_tone_change   = | 0000 0000 | 0000 000i |
;
;       buf_A(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN+1
;
;       buf_B(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN+1
;
;       hann(k)            = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN/2-1
;
;       ave_HRL_tone_high  = | i.fff ffff | ffff ffff |
;
;       ave_HRL_tone_low   = |  ffff ffff | ffff ffff |
;         (both correspond to 10*log10(4*ave_HRL_tone*WINDOW_CORRECTION) dBm0,
;          where ave_HRL_tone = ave_HRL_tone_high:ave_HRL_tone_low)
;
;       ave_HRL_noise_high = | i.fff ffff | ffff ffff |
;
;       ave_HRL_noise_low  = |  ffff ffff | ffff ffff |
;         (both correspond to 10*log10(4*ave_HRL_noise*WINDOW_CORRECTION) dBm0,
;          where ave_HRL_noise = ave_HRL_noise_high:ave_HRL_noise_low)
;
;       release_flag       = | 0000 0000 | 0000 000i |
;
;       release_count      = | 0000 000i | iiii iiii |
;                          = 0 to RELEASE_TIME
;
;       RELEASE_TIME       = 100 to 400 (250 +- 150)
;
;       HRL_FRMLEN         = 128 or 256
;
;       HRL_FRMSPAN        = HRL_FRMLEN/8
;
;       WINDOW_CORRECTION  = @cvf(HRL_FRMLEN)/(sum of all hanning coeff
;                             squares)
;
;       HRL_TONE_THRES1    = @POW(10.0,-28.5/10.0)/(4*WINDOW_CORRECTION)
;                            (corresponds to -28.5 dBm0)
;
;       HRL_TONE_THRES2    = @POW(10.0,-32.5/10.0)/(4*WINDOW_CORRECTION)
;                            (corresponds to -32.5 dBm0)
;
;       HRL_SNR_THRES      = @POW(10.0,5.5/10.0)
;                            (corresponds to 5.5 dB)
;
;       INDEX_200          = @CVI(200.0*HRL_FRMLEN/8000.0+0.5)
;
;       INDEX_700          = @CVI(700.0*HRL_FRMLEN/8000.0+0.5)
;
;       INDEX_3400         = @CVI(3400.0*HRL_FRMLEN/8000.0+0.5)
;
; Note that RELEASE_TIME, HRL_FRMLEN, HRL_FRMSPAN, WINDOW_CORRECTION,
; HRL_TONE_THRES1, HRL_TONE_THRES2, HRL_SNR_THRES, INDEX_200, INDEX_700 and
; INDEX_3400 are all constants.
;
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 1091 + Icycle Count of
;                                               RFFT_subroutine
;                                        (HRL_FRMLEN = 128)
;                        Program Words : 194
;                        NLOAC         : 154
;
;  Address Registers used:
;                        r0 : used in linear addressing mode 
;                        r1 : used in linear addressing mode
;                        r2 : used in linear addressing mode
;                        r3 : used in linear addressing mode 
;
;  Offset Registers used:
;                        n
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;  Registers Changed:
;                        r0  m01  n  a0  b0  x0  y0  sr
;                        r1          a1  b1      y1  pc
;                        r2          a2  b2
;                        r3
;
;***************************** Pseudo Code ********************************
;
;       Begin
;       %% Compute the spectrogram/periodogram of the filled buffer %%
;       if ( flag_AB == 1 ),
;          buf = buf_A;
;       else
;          buf = buf_B;
;       endif
;       HRL_frm_full = 0;
;
;       buf(0:HRL_FRMLEN-1) = buf(0:HRL_FRMLEN-1)*.hann(0:HRL_FRMLEN-1);
;       Real-FFT(buf, HRL_FRMLEN);      % In-place RFFT routine        %
;       spect = buf.*buf;               % periodogram = sqr mag of FFT %
;
;       %% Find out maxima of the spectrogram %%
;       sumtot_spect = 0;   kmax = 0;
;       sumtot_spect = sum(spect(0:HRL_FRMLEN-1));
;       kmax = maximum(spect(0:HRL_FRMLEN-1);
;
;       %% Check if the tone frequency is within 200 Hz to 3400 Hz %%
;       if ( (kmax <= INDEX_200) | (kmax > INDEX_3400) )
;          sum3_spect = 0;                          % Reset tone energy   %
;       else
;          sum3_spect = sum (spect(kmax-1:kmax+1)); % Compute tone energy %
;       endif
;
;       %% Calculate average tone level and noise level %%
;       % First, look for the larger spectral neighbour adjacent to kmax index %
;       if (spect(kmax-1) > spect(kmax+1) ),
;          kmax_neigh = kmax-1;
;       else
;          kmax_neigh = kmax+1;
;       endif
;
;       % check if the tone has not changed from previous frame %
;       % and adjust the ADAPT constant                         %
;       if (prev_kmax == kmax | prev_kmax == kmax_neigh),
;           ADAPT = 0.25;   % useful range: 0.25, 0.5 %
;           if (prev_tone_change == 1)
;               ADAPT = 1.0;  % max adaptation %
;           endif
;           prev_tone_change = 0;
;       else
;           ADAPT = 1.0;     % tone has changed: max adaptation %
;           prev_tone_change = 1;
;       endif
;
;       ave_HRL_tone = ADAPT*(sum3_spect - ave_HRL_tone) + ave_HRL_tone;
;       ave_HRL_noise = ADAPT*(sumtot_spect - sum3_spect - ave_HRL_noise)
;                       +  ave_HRL_noise;
;       prev_kmax = kmax;
;
;       % Mapping conditions in Req. C1-C3 %
;       cond1 = (ave_HRL_tone > HRL_TONE_THRES1) & (kmax <=  INDEX_700);
;       cond2 = (ave_HRL_tone > HRL_TONE_THRE2)  & (kmax > INDEX_700);
;       cond3 = (HRL_SNR_THRES*ave_HRL_noise - ave_HRL_tone) < 0;
;       cond123 = (cond1 | cond2) & cond3;
;
;       if ( cond123 ==1 ), % Hold EC and TD in disabled state %
;          release_count = 0;
;          release_flag  = 0;
;       else                % Consider releasing EC/TD from disabled state %
;          release_count = release_count + HRL_FRMSPAN;
;                           % HRL_FRMSPAN = duration of 1 frame %
;          if ( release_count >= RELEASE_TIME )
;                           % RELEASE_TIME = 250 +- 150  msec   %
;             release_count = RELEASE_TIME;
;             release_flag = 1;
;          endif
;       endif
;       End
;
;**************************** Assembly Code *******************************
 
        SECTION HRL_CODE
        
        GLOBAL  HRL_FRM_PRO
        
        include "equates.asm"    
        
        org     p:    
        
HRL_FRM_PRO   

_BEGIN_HRL_FRM_PRO

        move    #-1,m01                   ;Linear addressing mode
        move    #buf_A,r0
        move    #buf_B,r1
        tstw    x:flag_AB                 ;Check toggled flag_AB
        tne     x0,a         r0,r1        ;If toggled flag_AB = 1, set
                                          ; frm_buf_ptr to buf_A else to
                                          ; buf_B
        move    #<0,x0
        move    x0,x:HRL_frm_full         ;Clear frame full buffer flag
        move    r1,x:frm_buf_ptr          ;Set frm_buf_ptr pointer
        move    r1,r0

        move    #hann,r3                  ;Set hanning window pointer
        move    #HRL_FRMLEN/2,r2
        move    x:(r0)+,y0
        move    x:(r3)+,x0
        do      r2,_windowing1            ;Windowing on 1st half of frame
        mpyr    x0,y0,a      x:(r0)+,y0
        asr     a            x:(r3)+,x0
        move    a,x:(r1)+
_windowing1                               ;Store windowed samples in-place

        move    #-1,n
        move    x:(r3)-,x0
        move    x:(r3)-,x0
        do      r2,_windowing2            ;Windowing on 2nd half of frame
        mpyr    x0,y0,a      x:(r0)+,y0
        asr     a            x:(r3)+n,x0
        move    a,x:(r1)+
_windowing2                               ;Store windowed samples in-place



;Computes the squared magnitude of the FFT of buf_A or buf_B using RFFT.
; Note that the squared magnitude has been scaled by a factor of 4/(N*N),
; where N = HRL_FRMLEN. This means that if Z[i] is the unscaled complex FFT,
; then the squared magnitude of this RFFT is |Z[i]|*|Z[i]|*4/(N*N).

        jsr     RFFT_subroutine



;Find index of maximum spectral magnitude and at the same time, sum up
; spectral mags |Z[i]|*|Z[i]|*4/(N*N), for i from 0 to N/2+1, where
; N = HRL_FRMLEN.

        move    #-1,m01
        move    x:frm_buf_ptr,r0
        move    r0,r1
        move    #HRL_FRMLEN/2+1,x0
        clr     a
        move    a,y1                      ;y = sumtot_spect
        move    a,y0
        do      x0,_find_max_and_sumtot
        move    x:(r0)+,b
        move    x:(r0)+,b0
        cmp     b,a                       ;Compare current spectral magnitude
                                          ;  with max.
        tlt     y1,a         r0,r1        ;r1 = r0 if a < b
        tlt     b,a                       ;a = b if a < b
        add     y,b
        move    b,y1
        move    b0,y0
_find_max_and_sumtot
        move    y1,x:tmp                  ;Save 32-bit sumtot_spect
        move    y0,x:tmp+1                ;sumtot_spect = y =
                                          ; |Z[i]|*|Z[i]|*4/(N*N), for i from
                                          ; 0 to N/2+1
;Calculate sum3_spect
        move    r1,r0                     ;r0 points to spect(kmax+1)
        move    #-5,n
        move    x:(r1)+,y1                ;y = spect(kmax+1)
        move    x:(r1)+n,y0               ;r1 points to spect(kmax-1)
        move    r1,r2
        nop
        move    x:(r2)+,a                 ;a = spect(kmax-1)
        move    x:(r2)+,a0
        move    r2,x0                     ;r2 points to spect(kmax),
                                          ; x0 = 2*kmax + x:frm_buf_ptr
        move    x:(r2)+,b                 ;b = spect(kmax)
        move    x:(r2)+,b0
        add     y,b
        add     a,b                       ;b = spect(kmax-1) + spect(kmax)
                                          ;    + spect(kmax+1)


;Check if kmax is within 200 Hz to 3400 Hz. If false, let sum3_spect equal
; to zero
        sub     x:frm_buf_ptr,x0          ;x0 = 2*kmax
        asr     x0                        ;x0 = kmax
        move    y0,r3                     ;Save y0
        move    #<0,y0
        cmp     #INDEX_200,x0             ;Check if kmax <= 200 Hz index
        tle     y0,b                      ;If true, let sum3_spect = 0
        cmp     #INDEX_3400,x0            ;Check if kmax > 3400 Hz index
        tgt     y0,b                      ;If true, let sum3_spect = 0
                                          ; b = updated sum3_spect
        move    r3,y0                     ;Retrieve y0
        move    b,x:tmp+2                 ;Save 32-bit sum3_spect for
        move    b0,x:tmp+3                ; testing purposes

;Find larger neighbour: spect(kmax_neigh) = max(spect(kmax-1), spect(kmax+1))
        sub     y,a                       ;a = spect(kmax-1) - spect(kmax+1)
        tlt     x0,a         r0,r1        ;r1 points to spect(kmax_neigh)
        move    r1,y0
        sub     x:frm_buf_ptr,y0
        asr     y0                        ;y0 = kmax_neigh


;Check if the freq of the tone has changed from previous frame
; if (prev_kmax == kmax | prev_kmax == kmax_neigh), then assume that tone
; has not changed.
;
        cmp     x:prev_kmax,x0            ;Check current kmax - previous kmax
        beq     _same_tone
        cmp     x:prev_kmax,y0            ;Check kmax_neigh - previous kmax
        beq     _same_tone                ;Branch if prev_kmax == kmax_neigh

;Tone has changed
        move    #<1,x:prev_tone_change    ;Save tone change status
        move    #0,r3                     ;ADAPT = 2^(-r3) = 1.0
        bra     _cal_energy

_same_tone
;tone has not changed. If there is a tone change in previous frame,
;then let ADAPT = 1.0. Otherwise, let ADAPT = 0.25.
        move    #<2,a
        move    #0,y1
        tstw    x:prev_tone_change
        tne     y1,a
        move    a,r3                      ;ADAPT = 2^(-r3) = 1.0 or 0.25
        move    y1,x:prev_tone_change     ;Save tone change status


_cal_energy
;Cal ave tone energy: ave_HRL_tone = ADAPT*(sum3_spect - ave_HRL_tone)
;                                       + ave_HRL_tone
        move    x:ave_HRL_tone_high,y1    ;Load 32-bit ave_HRL_tone
        move    x:ave_HRL_tone_low,y0     
        tfr     b,a                       ;a = b = sum3_spect
        sub     y,a                       ;a = sum3_spect - ave_HRL_tone
        rep     r3
        asr     a                         ;a = ADAPT*(sum3_spect-ave_HRL_tone)
        add     y,a                       ;a = ADAPT*(sum3_spect-ave_HRL_tone)
                                          ;    + ave_HRL_tone
        move    a,x:ave_HRL_tone_high     ;Store 32-bit ave_HRL_tone
        move    a0,x:ave_HRL_tone_low

;Cal ave noise energy: ave_HRL_noise = ADAPT*(sumtot_spect - sum3_spect
;                                       - ave_HRL_noise) +  ave_HRL_noise
        move    x:ave_HRL_noise_high,y1   ;Load 32-bit ave_HRL_noise
        move    x:ave_HRL_noise_low,y0
        move    x:tmp,a                   ;Load sumtot_spect
        move    x:tmp+1,a0
        sub     b,a                       ;a = sumtot_spect - sum3_spect
        sub     y,a                       ;a = sumtot_spect - sum3_spect
                                          ;      - ave_HRL_noise
        rep     r3
        asr     a                         ;a = ADAPT*(sumtot_spect - sum3_spect
                                          ;               - ave_HRL_noise)
        add     y,a                       ;a = ADAPT*(sumtot_spect - sum3_spect
                                          ;                - ave_HRL_noise)
                                          ;     + ave_HRL_noise
        move    a,x:ave_HRL_noise_high    ;Store 32-bit ave_HRL_noise
        move    a0,x:ave_HRL_noise_low


_map_req_C_conditions
;Mapping conditions in Req. C1-C3

;Check cond1 = (ave_HRL_tone > HRL_TONE_THRES1) & (kmax <=  INDEX_700)
;  and cond2 = (ave_HRL_tone > HRL_TONE_THRE2)  & (kmax > INDEX_700);

        move    x0,x:prev_kmax            ;Save current kmax

        move    #HRL_TONE_THRES1*8,y0     ;The threshold has been upscaled
        move    #HRL_TONE_THRES2*8,b      ; to avoid underflow
        cmp     #INDEX_700,x0             ;kmax - INDEX_700
        tle     y0,b                      ;b = HRL_TONE_THRES1 if less than
                                          ; or equal, else b = HRL_TONE_THRES2
        asr     b
        asr     b
        asr     b
        move    x:ave_HRL_tone_high,a     ;Load 32-bit ave_HRL_tone
        move    x:ave_HRL_tone_low,a0
        cmp     b,a                       ;ave_HRL_tone - HRL_TONE_THRES
        ble     _cond123_failed           ;Branch if less than or equal

;Check  cond3 = (ave_HRL_noise - ave_HRL_tone/HRL_SNR_THRES) < 0
        move    #1/HRL_SNR_THRES,x0   ;Load 1/(SNR threshold)
        move    x:ave_HRL_tone_high,y1    ;Load 32-bit ave_HRL_tone
        move    x:ave_HRL_tone_low,y0
        mpysu   x0,y0,a
        move    a1,a0
        move    a2,a1
        mac     x0,y1,a                   ;a = ave_HRL_tone/HRL_SNR_THRES
        move    x:ave_HRL_noise_high,b    ;Load 32-bit ave_HRL_noise
        move    x:ave_HRL_noise_low,b0
        cmp     a,b                       ;b - a = ave_HRL_noise -
                                          ;        ave_HRL_tone/HRL_SNR_THRES
        bge     _cond123_failed           ;Branch if greater or equal to


;Condition cond123 = (cond1 | cond2) & cond3 is true, so
; hold EC and TD in disabled state.
        move    #<0,y0
        move    y0,x:release_count        ;Clear release counter
        move    y0,x:release_flag         ;Clear release flag
        bra     _END_HRL_FRM_PRO

_cond123_failed
;Condition cond123 = (cond1 | cond2) & cond3 is false, so
; consider releasing EC and TD from disabled state.

        move    x:release_count,a         ;Load release_count
        add     #HRL_FRMSPAN,a            ;release_count = release_count +
                                          ; HRL_FRMSPAN
        move    #RELEASE_TIME,y0
        move    #<1,r0
        move    x:release_flag,r1
        cmp     y0,a                      ;If (release_count >= RELEASE_TIME),
        tge     y0,a       r0,r1          ; let release_count = RELEASE_TIME
                                          ; and let release_flag = 1
        move    a,x:release_count         ;Save release counter
        move    r1,x:release_flag         ;Save release flag

_END_HRL_FRM_PRO

		rts


        ENDSEC
;****************************** End of File *******************************

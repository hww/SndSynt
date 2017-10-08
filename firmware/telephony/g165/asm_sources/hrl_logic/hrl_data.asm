;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Module ************************************
;  
;  Module Name    : HRL_DATA
;  Project ID     : G165EC
;  Author         : Sim Boh Lim
;  Modified by    : Sandeep Sehgal
;  
;**************************Revision History ******************************* 
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  22/10/97      0.0.1     Module Created               Sim Boh Lim
;  27/10/97      1.0.0     Reviewed and Modified        Sim Boh Lim
;  11/11/97      1.0.1     Added cross references       Sim Boh Lim
;                          for HRL_CODE
;  10/07/00      1.0.2     Converted macros to          Sandeep Sehgal
;                          functions    
;
;************************** Module Description ****************************
;
;  Declaration of constants and variables for Hold-Release Logic
;
;  Symbols Used    :
;       frm_count            : Counter for samples in a buffer
;       HRL_frm_full         : Flag to indicate that buffer A or B is full
;       flag_AB              : Flag to switch between buffer A and B
;       buf_ptr              : Pointer to buffer A or B, for storing incoming
;                              sample
;       frm_buf_ptr          : Pointer to buffer A or B, on which RFFT is
;                              computed (used in hrl_frm.asm)
;       prev_kmax            : Frequency index of spectral peak of previous
;                              RFFT frame
;       prev_tone_change     : Tone change status of previous frame
;       buf_A[HRL_FRMLEN+2]  : Buffer A for storing samples & RFFT results
;       buf_B[HRL_FRMLEN+2]  : Buffer B for storing samples & RFFT results
;       hann[HRL_FRMLEN/2]   : Hanning window coefficients (half a frame)
;       twids[HRL_FRMLEN/2]  : Twiddle factors for RFFT function
;       coefs[HRL_FRMLEN/2+2]: Cos/Sin coeffs for RFFT function
;       ave_HRL_tone_high    : MSW of average tone energy
;       ave_HRL_tone_low     : LSW of average tone energy
;       ave_HRL_noise_high   : MSW of average noise energy
;       ave_HRL_noise_low    : LSW of average noise energy
;       release_flag         : Release flag, if set,  indicates that Echo
;                              Canceller should be released from disabled
;                              state
;       release_count        : Counter that increments by HRL_FRMSPAN if
;                              release conditions are met. If counter is >=
;                              RELEASE_TIME, then release_flag will be set
;       RELEASE_TIME         : Release time threshold (in ms, 250 +- 150 ms),
;                              to control setting of release_flag
;       HRL_FRMLEN           : Frame length for the input buffer
;                              (preferably 128)
;       HRL_FRMSPAN          : Frame span or duration in ms.
;       WINDOW_CORRECTION    : Correction for threshold calculation due to
;                              hanning window
;       HRL_TONE_THRES1      : Tone threshold constant for band 1 (390-700 Hz)
;       HRL_TONE_THRES2      : Tone threshold constant for band 2 (700-3000 Hz)
;       HRL_SNR_THRES        : SNR threshold constant
;       INDEX_200            : 200 Hz frequency index in the RFFT frame
;       INDEX_700            : 700 Hz frequency index in the RFFT frame
;       INDEX_3400           : 3400 Hz frequency index in the RFFT frame
;       HRL_VAR_INT_XRAM     : For compilation purpose
;                              Indicates that section HRL_VAR lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
;       HRL_CONST_INT_XRAM   : For compilation purpose
;                              Indicates that section HRL_CONST lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
;       FFT_DATA_INT_XRAM    : For compilation of RFFT function. Equals to
;                              HRL_VAR_INT_XRAM
;       FFT_COEF_INT_XRAM    : For compilation of RFFT function. Equals to
;                              HRL_CONST_INT_XRAM
;
;  Note:  1. If HRL_VAR_INT_XRAM is set to 1, then second parallel reads
;            (where appropriate) will be compiled and used resulting in
;            faster execution. Since DSP56800 only supports second parallel
;            reads on internal XRAM, section HRL_VAR has to be located in
;            internal XRAM for correct operation.
;         2. If HRL_VAR_INT_XRAM is set to 0, then section HRL_VAR can be
;            located in internal or external XRAM. This is because second
;            parallel reads (where appropriate) will not be compiled
;            and used.
;         3. Likewise for HRL_CONST_INT_XRAM and section HRL_CONST
;
;  Functions Called    :
;
;       none
;
;**************************** Function Arguments **************************
;
;       None
;
;************************* Calling Requirements ***************************
;
;  1. HRL_FRMLEN should be 128, any other value would require different
;     entries for twids and coefs buffers.
;  2. HRL_VAR_INT_XRAM and HRL_CONST_INT_XRAM must be defined in the calling
;     module or during compilation.
;
;************************** Input and Output ******************************
;
;  Input   :
;       None
;
;  Output  :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals : 
;
;       frm_count          = | iiii iiii | iiii iiii |
;                          = 0 to HRL_FRMLEN
;
;       HRL_frm_full       = | 0000 0000 | 0000 000i |
;
;       flag_AB            = | 0000 0000 | 0000 000i |
;
;       buf_ptr            = | iiii iiii | iiii iiii |
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
;       twids(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN/2-1
;
;       coefs(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN/2+1
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
;       HRL_VAR_INT_XRAM   = 1   indicates that section HRL_VAR lies
;                                strictly in internal XRAM
;                          = 0   indicates that section HRL_VAR lies
;                                in external or unknown location
;                                of XRAM until linking time
;
;       HRL_CONST_INT_XRAM = 1   indicates that section HRL_CONST lies
;                                strictly in internal XRAM
;                          = 0   indicates that section HRL_CONST lies
;                                in external or unknown location
;                                of XRAM until linking time
;
;       FFT_DATA_INT_XRAM  = 1   if HRL_VAR_INT_XRAM = 1
;                            0   if HRL_VAR_INT_XRAM = 0
;
;       FFT_COEF_INT_XRAM  = 1   if HRL_CONST_INT_XRAM = 1
;                            0   if HRL_CONST_INT_XRAM = 0
;
; Note that RELEASE_TIME, HRL_FRMLEN, HRL_FRMSPAN, WINDOW_CORRECTION,
; HRL_TONE_THRES1, HRL_TONE_THRES2, HRL_SNR_THRES, INDEX_200, INDEX_700 and
; INDEX_3400, FFT_DATA_INT_XRAM and FFT_COEF_INT_XRAM are all constants.
; They are defined using EQU directive. HRL_VAR_INT_XRAM and
; HRL_CONST_INT_XRAM must be defined in the calling module or during
; compilation.
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 0
;                        Program Words : 0
;                        NLOAC         : 86
;
;  Address Registers used:
;                        none
;  Offset Registers used:
;                        none
;  Data Registers used:
;                        none
;  Registers Changed:
;                        none
;
;***************************** Pseudo Code ********************************
;
;        Begin
;          Declaration of constants
;          Declaration of variables
;        End
;
;**************************** Assembly Code *******************************


;Section HRL_CONST contains the definition of all the constants used in HRL
; thread.

        SECTION HRL_CONST


        GLOBAL  FFT_COEF_INT_XRAM
        GLOBAL  hann,twids,coefs,WINDOW_CORRECTION
        GLOBAL  RELEASE_TIME,HRL_FRMLEN,HRL_FRMSPAN,HRL_TONE_THRES1
        GLOBAL  HRL_TONE_THRES2,HRL_SNR_THRES
        GLOBAL  INDEX_200,INDEX_700,INDEX_3400

_BEGIN_HRL_CONST
        org     x:

       
        include "equates.asm"

;Only half a frame of Hanning window coeffs is required because the other
; half is symmetrical

twids       dc       $7fff,$0000,$0000
            dc       $7fff,$5a82,$5a82,$a57e,$5a82,$7642,$30fc,$cf04
            dc       $7642,$30fc,$7642,$89be,$30fc,$7d8a,$18f9,$e707
            dc       $7d8a,$471d,$6a6e,$9592,$471d,$6a6e,$471d,$b8e3
            dc       $6a6e,$18f9,$7d8a,$8276,$18f9,$7f62,$0c8c,$f374
            dc       $7f62,$5134,$62f2,$9d0e,$5134,$70e3,$3c57,$c3a9
            dc       $70e3,$2528,$7a7d,$8583,$2528,$7a7d,$2528,$dad8
            dc       $7a7d,$3c57,$70e3,$8f1d,$3c57,$62f2,$5134,$aecc
            dc       $62f2,$0c8c,$7f62,$809e,$0c8c

coefs       dc       $0,$7fff,$648,$7fd9,$c8c,$7f62,$12c8,$7e9d
            dc       $18f9,$7d8a,$1f1a,$7c2a,$2528,$7a7d,$2b1f,$7885
            dc       $30fc,$7642,$36ba,$73b6,$3c57,$70e3,$41ce,$6dca
            dc       $471d,$6a6e,$4c40,$66d0,$5134,$62f2,$55f6,$5ed7
            dc       $5a82,$5a82,$5ed7,$55f6,$62f2,$5134,$66d0,$4c40
            dc       $6a6e,$471d,$6dca,$41ce,$70e3,$3c57,$73b6,$36ba
            dc       $7642,$30fc,$7885,$2b1f,$7a7d,$2528,$7c2a,$1f1a
            dc       $7d8a,$18f9,$7e9d,$12c8,$7f62,$c8c,$7fd9,$648
            dc       $7fff,$0

;Equate constant FFT_COEF_INT_XRAM (for RFFT function) to HRL_CONST_INT_XRAM


_END_HRL_CONST

        ENDSEC



;Section HRL_VAR contains the declaration of all the variables used in HRL
; thread.
        SECTION HRL_VAR


        GLOBAL  HRL_frm_full,release_flag,release_count,flag_AB
        GLOBAL  FFT_DATA_INT_XRAM
        GLOBAL  ave_HRL_tone_high,ave_HRL_tone_low
        GLOBAL  ave_HRL_noise_high,ave_HRL_noise_low
        GLOBAL  frm_count,prev_kmax,prev_tone_change
        GLOBAL  buf_A,buf_B,buf_ptr,frm_buf_ptr
        GLOBAL  tmp

_BEGIN_HRL_DATA
        org     x:
                  
ave_HRL_tone_high     ds       1
ave_HRL_tone_low      ds       1
ave_HRL_noise_high    ds       1
ave_HRL_noise_low     ds       1
HRL_frm_full          ds       1
release_flag          ds       1
release_count         ds       1
flag_AB               ds       1
frm_count             ds       1
prev_kmax             ds       1
prev_tone_change      ds       1
buf_A                 ds       HRL_FRMLEN+2          ;2 extra locations for
buf_B                 ds       HRL_FRMLEN+2          ; spectral output storage
buf_ptr               ds       1
frm_buf_ptr           ds       1
tmp                   ds       4


;Equate constant FFT_DATA_INT_XRAM (for RFFT function) to HRL_VAR_INT_XRAM
        
HRL_VAR_INT_XRAM              equ   0      ;For section HRL_VAR
FFT_DATA_INT_XRAM             equ   HRL_VAR_INT_XRAM

_END_HRL_VAR

        ENDSEC


;****************************** End of File *******************************

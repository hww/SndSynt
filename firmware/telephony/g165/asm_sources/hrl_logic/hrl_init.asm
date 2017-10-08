;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : HRL_INIT
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
;  11/11/97      1.0.1     Section renamed              Sim Boh Lim
;                          Calling Requirement updated
;  10/07/00      1.0.2     Converted macros to          Sandeep Sehgal
;                          functions    
;
;*************************** Function Description *************************
;
;  Initialization of variables for Hold-Release Logic
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
;
;  Note: The constant and variable declarations for this module are defined
;        in file hrl_data.asm

;
;  Functions Called    :
;
;       None
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  None
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
; Note that RELEASE_TIME and HRL_FRMLEN are constants declared using
; EQU directive.
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 29
;                        Program Words : 29
;                        NLOAC         : 28
;
;  Address Registers used:
;                        none
;  Offset Registers used:
;                        none
;  Data Registers used:
;                        a0
;                        a1
;                        a2
;  Registers Changed:
;                        a0   sr
;                        a1   pc
;                        a2
;
;***************************** Pseudo Code ********************************
;
;        Begin
;             release_count = 0;
;             release_flag  = 0;
;             HRL_frm_full  = 0;
;             flag_AB       = 0;
;             buf_ptr       = buf_A;
;             frm_count     = HRL_FRMLEN;
;             ave_HRL_tone  = 0;
;             ave_HRL_noise = 0;
;             prev_kmax     = -1;
;             prev_tone_change = 1;
;
;        End
;
;**************************** Assembly Code *******************************

        SECTION HRL_INIT_CODE

        GLOBAL  HRL_INIT
        
        include "equates.asm" 
        
        org     p: 
              
HRL_INIT
   
_Begin_HRL_INIT
        clr     a
        move    a,x:release_count
        move    a,x:release_flag
        move    a,x:HRL_frm_full
        move    a,x:flag_AB
        move    #buf_A,x:buf_ptr
        move    #HRL_FRMLEN,x:frm_count

        move    a,x:ave_HRL_tone_high
        move    a0,x:ave_HRL_tone_low
        move    a,x:ave_HRL_noise_high
        move    a0,x:ave_HRL_noise_low
        move    #-1,x:prev_kmax
        move    #<1,x:prev_tone_change

_END_HRL_INIT

		rts


        ENDSEC
;****************************** End of File *******************************

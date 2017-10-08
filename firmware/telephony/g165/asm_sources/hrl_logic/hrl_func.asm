;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Module ************************************
;
;  Module Name    : HRL_FUNC
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
;  10/11/97      1.0.1     Comments and section name    Sim Boh Lim
;                          updated
;  10/07/00      1.0.2     Converted macros to          Sandeep Sehgal
;                          functions    
;
;*************************** Module Description ****************************
;
;  Contains all the subroutines of Hold-Release logic:
;                    HRL_INIT_subroutine
;                    HRL_FRM_PRO_subroutine  (calls RFFT_subroutine)
;                    HRL_SAMP_PRO_subroutine
;                    HRL_RESTART_subroutine
;                    RFFT_subroutine
;
;  Symbols Used :
;       HRL_FRMLEN    : Frame length for the input buffer
;                       (preferably 128)
;       frm_buf_ptr   : Pointer to buffer A or B, on which RFFT is
;                       to be computed
;       twids[HRL_FRMLEN/2]  : Twiddle factors for RFFT function
;       coefs[HRL_FRMLEN/2+2]: Cos/Sin coeffs for RFFT function
;
;  Functions Called :
;       HRL_INIT        : Initializes variables for Hold-Release Logic
;       HRL_FRM_PRO     : Processes frame buffers; calls RFFT_subroutine
;       HRL_SAMP_PRO    : Collects in-coming samples into input buffer
;       HRL_RESTART     : Re-initializes variables
;       rfft            : Computes the square of the magnitude of the FFT
;                         of a real sequence
;       fftas           : Computes an M point DFT of a complex input sequence
;                         using radix-2 DIT FFT; required by function rfft
;       bitrev_ip       : Performs an M point in-place bit reversal of a
;                         complex input sequence; required by function fftas
;
;**************************** Module Arguments *****************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The constant and variable declarations for this module are defined in
;     file hrl_data.asm
;  2. HRL_VAR_INT_XRAM and HRL_CONST_INT_XRAM (see hrl_data.asm) must be
;     defined in the calling module or during compilation
;  3. At least 9 locations should be available in the software stack:
;          Subroutine               Stacks required
;         ------------              ---------------
;         HRL_INIT_subroutine     :       2
;         HRL_FRM_PRO_subroutine  :       9
;         HRL_SAMP_PRO_subroutine :       2
;         HRL_RESTART_subroutine  :       2
;         RFFT_subroutine         :       7
;  4. All hardware looping resources including LA, LC and 2 locations of HWS
;     must be available for use in nested hardware do loop (for rfft
;     subroutine)
;
;************************** Input and Output ******************************
;
;  Input  :
;       None
;
;  Output :
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       HRL_INIT_subroutine     = | iiii iiii | iiii iiii |
;
;       HRL_FRM_PRO_subroutine  = | iiii iiii | iiii iiii |
;
;       HRL_SAMP_PRO_subroutine = | iiii iiii | iiii iiii |
;
;       HRL_RESTART_subroutine  = | iiii iiii | iiii iiii |
;
;       RFFT_subroutine         = | iiii iiii | iiii iiii |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;              Icycle Count  : (Internal PRAM and XRAM, HRL_FRMLEN = 128)
;                   HRL_INIT_subroutine     : 34
;                   HRL_FRM_PRO_subroutine  : 1096 + Icycle Count of
;                                                    RFFT_subroutine
;                   HRL_SAMP_PRO_subroutine : 38 (max)
;                   HRL_RESTART_subroutine  : 23
;                   RFFT_subroutine         : 6262 for HRL_VAR_INT_XRAM   = 1
;                                                      HRL_CONST_INT_XRAM = 1
;                                             6388 for HRL_VAR_INT_XRAM   = 0
;                                                      HRL_CONST_INT_XRAM = 0
;
;              Program Words : (Internal PRAM and XRAM, HRL_FRMLEN = 128)
;                   HRL_INIT_subroutine     : 30
;                   HRL_FRM_PRO_subroutine  : 195
;                   HRL_SAMP_PRO_subroutine : 33
;                   HRL_RESTART_subroutine  : 19
;                   RFFT_subroutine         : 199 for HRL_VAR_INT_XRAM   = 1
;                                                     HRL_CONST_INT_XRAM = 1
;                                             203 for HRL_VAR_INT_XRAM   = 0
;                                                     HRL_CONST_INT_XRAM = 0
;
;              NLOAC         : 41
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
;
;       Define HRL_INIT_subroutine;
;
;       Define HRL_FRM_PRO_subroutine;
;
;       Define HRL_SAMP_PRO_subroutine;
;
;       Define HRL_RESTART_subroutine;
;
;       Define RFFT_subroutine;
;
;       End
;
;**************************** Assembly Code *******************************

        SECTION  HRL_INIT_CODE
        
        GLOBAL   HRL_INIT_subroutine
        GLOBAL   FHRL_INIT_subroutine

        org      p:
        
HRL_INIT_subroutine
FHRL_INIT_subroutine
        jsr		 HRL_INIT                          ;Initialization
        rts
        ENDSEC


        SECTION  HRL_CODE
        
        GLOBAL   HRL_FRM_PRO_subroutine
        GLOBAL   HRL_SAMP_PRO_subroutine
        GLOBAL   HRL_RESTART_subroutine

        org      p:
        
HRL_FRM_PRO_subroutine
        jsr		 HRL_FRM_PRO                       ;Frame processing
        rts

        org      p:
        
HRL_SAMP_PRO_subroutine
        jsr		 HRL_SAMP_PRO                      ;Sample processing
        rts

        org      p:
        
HRL_RESTART_subroutine
        jsr		 HRL_RESTART                       ;Re-initialization
        rts

        ENDSEC


        SECTION  HRL_RFFT_CODE
        
        GLOBAL   RFFT_subroutine

        org      p:
        
RFFT_subroutine
        jsr		 rfft                             ;call to RFFT routine
        rts

        ENDSEC

;****************************** End of File *******************************

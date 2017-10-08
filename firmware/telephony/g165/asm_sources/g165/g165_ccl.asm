;**************************************************************************
;
;   (C) 1997 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Module ************************************
;  
;  Module Name    : G165_CCL
;  Project ID     : G165EC
;  Author         : Qiu, Cindy, Boh Lim
;  
;************************** Revision History ****************************** 
;
;  DD/MM/YY     Code Ver   Description                Author
;  --------     --------   -----------                ------
;  11/11/97     0.0.1      Macro Created              Qiu, Cindy, Boh Lim
;  05/01/98     1.0.0      Modified per review        Qiu, Cindy, Boh Lim
;                          comments
;
;************************** Module Description ****************************
;  This module contains global constants/variables of EC, TD and HRL 
;  threads for C-callability
;         
;
;  Symbols Used    :
;
;       FG165_SAMP_PRO_subroutine : Alias of G165_SAMP_PRO_subroutine,
;                                   integration module of G165EC sample
;                                   processing
;       FG165_FRM_PRO_subroutine  : Alias of G165_FRM_PRO_subroutine,
;                                   integration module of G165EC frame
;                                   processing
;       FTD_INIT_subroutine       : Alias of TD_INIT_subroutine,
;                                   initialises variables for TD thread
;       FTD_MASTER_subroutine     : Alias of TD_MASTER_subroutine,
;                                   master module for TD thread
;       FEC_INIT_subroutine       : Alias of EC_INIT_subroutine
;                                   initialises variables for EC thread
;       FEC_FRM_PRO_subroutine    : Alias of EC_FRM_PRO_subroutine
;                                   frame processing for EC thread
;       FEC_SAMP_PRO_subroutine   : Alias of EC_SAMP_PRO_subroutine
;                                   sample processing for EC thread
;       FEC_RESTART_subroutine    : Alias of EC_RESTART_subroutine
;                                   re-initializes variables for EC thread
;       FHRL_INIT_subroutine      : Alias of HRL_INIT_subroutine,
;                                   initializes variables for HRL thread
;       FHRL_FRM_PRO_subroutine   : Alias of HRL_PRO_subroutine,
;                                   processes frame buffers for HRL thread
;       FHRL_SAMP_PRO_subroutine  : Alias of HRL_SAMP_PRO_subroutine,
;                                   collects in-coming samples into input
;                                   buffer and set HRL_frm_full flag for
;                                   HRL thread
;       FHRL_RESTART_subroutine   : Alias of HRL_RESTART_subroutine,
;                                   re-initializes variables for HRL thread
;       Fec_frm_full              : Alias of ec_frm_full
;       FHRL_frm_full             : Alias of HRL_frm_full,
;                                   flag to indicate that buffer A or B is
;                                   full for HRL thread
;       Fsin_sample               : Alias of sin_sample,
;                                   in-coming sample on send channel
;       Frin_sample               : Alias of rin_sample,
;                                   in-coming sample on receive channel
;       Fsout_sample              : Alias of sout_sample,
;                                   processed sample on send channel
;       Fnl_option                : Alias of nl_option,
;                                   Non-linear supression option
;       FDisable_TD               : Alias of disable_TD,
;                                   flag to disable tone detect logic
;                                   (set by user)
;       Finhibit_converge         : Alias of inhibit_converge,
;                                   flag to freeze adaptation (set by user)
;                                   for EC thread
;       Freset_coef               : Alias of reset_coef,
;                                   flag for resetting coefficients for EC
;                                   thread
;
;  Macros Called    :
;
;       None
;
;**************************** Macro Arguments *****************************
;
;       None
;
;************************* Calling Requirements ***************************
;
;       None
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
;       FG165_SAMP_PRO_subroutine   = | iiii iiii | iiii iiii |
;
;       FG165_FRM_PRO_subroutine    = | iiii iiii | iiii iiii |
;
;       FTD_INIT_subroutine         = | iiii iiii | iiii iiii |
;
;       FTD_MASTER_subroutine       = | iiii iiii | iiii iiii |
;
;       FEC_INIT_subroutine         = | iiii iiii | iiii iiii |
;
;       FEC_FRM_PRO_subroutine      = | iiii iiii | iiii iiii |
;
;       FEC_SAMP_PRO_subroutine     = | iiii iiii | iiii iiii |
;
;       FEC_RESTART_subroutine      = | iiii iiii | iiii iiii |
;
;       FHRL_INIT_subroutine        = | iiii iiii | iiii iiii |
;
;       FHRL_FRM_PRO_subroutine     = | iiii iiii | iiii iiii |
;
;       FHRL_SAMP_PRO_subroutine    = | iiii iiii | iiii iiii |
;
;       FHRL_RESTART_subroutine     = | iiii iiii | iiii iiii |
;
;       Fec_frm_full                = | 0000 0000 | 0000 000i |
;
;       FHRL_frm_full               = | 0000 0000 | 0000 000i |
;
;       Fsin_sample                 = | s.fff ffff | ffff ffff |
;
;       Frin_sample                 = | s.fff ffff | ffff ffff |
;
;       Fsout_sample                = | s.fff ffff | ffff ffff |
;
;       Fnl_option                  = | 0000 0000  | 0000 00ii |
;
;       FDisable_TD                 = | 0000 0000  | 0000 00ii |
;
;       Finhibit_converge           = | 0000 0000  | 0000 00ii |
;
;       Freset_coef                 = | 0000 0000  | 0000 00ii |
;
;  Statics :
;       None
;
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 0
;                        Program Words : 0
;                        NLOAC         : 46
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
;**************************** Environment *********************************
;
;       Assembler : ASM56800 Version 6.0.1
;       Machine   : IBM PC
;       OS        : MSDOS under Window NT Ver 4.0
;
;***************************** Pseudo Code ********************************
;
;        Begin
;          Declaration of constants
;          Declaration of variables
;        End
;
;**************************** Assembly Code *******************************

        SECTION   G165_DATA
        GLOBAL   FG165_SAMP_PRO_subroutine
        XREF	 EC_SAMP_PRO_subroutine
        GLOBAL   FG165_FRM_PRO_subroutine
        GLOBAL   FTD_INIT_subroutine
        GLOBAL   FTD_MASTER_RCV_subroutine         
        GLOBAL   FTD_MASTER_SND_subroutine         
        GLOBAL   FEC_INIT_subroutine
        GLOBAL   FEC_FRM_PRO_subroutine
        GLOBAL   FEC_SAMP_PRO_subroutine
        GLOBAL   FEC_RESTART_subroutine
        GLOBAL   FHRL_INIT_subroutine
        GLOBAL   FHRL_FRM_PRO_subroutine
        GLOBAL   FHRL_SAMP_PRO_subroutine
        GLOBAL   FHRL_RESTART_subroutine
        GLOBAL   Fec_frm_full
        GLOBAL   FHRL_frm_full
        GLOBAL   Fsin_sample
        GLOBAL   Frin_sample
        GLOBAL   Fsout_sample
        GLOBAL   Fnl_option
        GLOBAL   FDisable_TD
        GLOBAL   Finhibit_converge
        GLOBAL   Freset_coef                      


;Global constants/variables of EC, TD and HRL threads
;for C-callability

FG165_SAMP_PRO_subroutine     equ   G165_SAMP_PRO_subroutine
FG165_FRM_PRO_subroutine      equ   G165_FRM_PRO_subroutine
FTD_INIT_subroutine           equ   TD_INIT_subroutine
FTD_MASTER_RCV_subroutine     equ   TD_MASTER_RCV_subroutine
FTD_MASTER_SND_subroutine     equ   TD_MASTER_SND_subroutine 
FEC_INIT_subroutine           equ   EC_INIT_subroutine
FEC_FRM_PRO_subroutine        equ   EC_FRM_PRO_subroutine
FEC_SAMP_PRO_subroutine       equ   EC_SAMP_PRO_subroutine
FEC_RESTART_subroutine        equ   EC_RESTART_subroutine
FHRL_INIT_subroutine          equ   HRL_INIT_subroutine
FHRL_FRM_PRO_subroutine       equ   HRL_FRM_PRO_subroutine
FHRL_SAMP_PRO_subroutine      equ   HRL_SAMP_PRO_subroutine
FHRL_RESTART_subroutine       equ   HRL_RESTART_subroutine
Fec_frm_full                  equ   ec_frm_full
FHRL_frm_full                 equ   HRL_frm_full
Fsin_sample                   equ   sin_sample
Frin_sample                   equ   rin_sample
Fsout_sample                  equ   sout_sample
Fnl_option                    equ   nl_option
FDisable_TD                   equ   Disable_TD
Finhibit_converge             equ   inhibit_converge
Freset_coef                   equ   reset_coef


        ENDSEC

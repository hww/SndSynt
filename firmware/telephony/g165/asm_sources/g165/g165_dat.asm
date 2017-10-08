;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Module ************************************
;  
;  Module Name    : G165_DATA
;  Project ID     : G165EC
;  Author         : Qiu, Cindy, Boh Lim
;  Modified by    : Sandeep Sehgal
;  
;************************** Revision History ****************************** 
;
;  DD/MM/YY     Code Ver   Description                Author
;  --------     --------   -----------                ------
;  11/12/97     0.0.1      Macro Created              Qiu, Cindy, Boh Lim
;  05/01/98     1.0.0      Modified per review        Qiu, Cindy, Boh Lim  
;                          comments
;  10/07/00     1.0.1      Converted macros to        Sandeep Sehgal
;                          functions    
;
;************************** Module Description ****************************
;
;  This module contains constant flags for indicating EC, TD and HRL data 
;  sections within  internal or external XRAM (to optionally compile 
;  second parallel memory reads in EC, TD and HRL threads)
;
;  Symbols Used    :
;   
;
;       EC_VAR_INT_XRAM      : For compilation purpose
;                              Indicates that section EC_VAR lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
;       EC_CONST_INT_XRAM    : For compilation purpose
;                              Indicates that section EC_CONST lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
;       TD_VAR_INT_XRAM      : For compilation purpose
;                              Indicates that section TD_VAR lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
;       TD_CONST_INT_XRAM    : For compilation purpose
;                              Indicates that section TD_CONST lies strictly
;                              in internal XRAM (=1), lies in external
;                              XRAM (=0), or lies in unknown location of XRAM
;                              until linking time (=0)
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
;
;
;       Note :  1. If EC_VAR_INT_XRAM is set to 1, then second parallel reads
;                  (where appropriate) will be compiled and used resulting in
;                  faster execution. Since DSP56800 only supports second
;                  parallel reads on internal XRAM, section EC_VAR has to be
;                  located in internal XRAM for correct operation.
;               2. If EC_VAR_INT_XRAM is set to 0, then section EC_VAR can
;                  be located in internal or external XRAM. This is because
;                  second parallel reads (where appropriate) will not be
;                  compiled and used.
;               3. Likewise for EC_CONST_INT_XRAM, TD_VAR_INT_XRAM,
;                  TD_CONST_INT_XRAM, HRL_VAR_INT_XRAM, HRL_CONST_INT_XRAM
;               4. For link-time relocatability, all the above constant
;                  flags should be set to 0, unless the user is sure
;                  that the particular section will be located in internal
;                  XRAM.
;
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
;       EC_VAR_INT_XRAM      : 0 or 1
;
;       EC_CONST_INT_XRAM    : 0 or 1
;
;       TD_VAR_INT_XRAM      : 0 or 1
;
;       TD_CONST_INT_XRAM    : 0 or 1
;
;       HRL_VAR_INT_XRAM     : 0 or 1
;
;       HRL_CONST_INT_XRAM   : 0 or 1
;
;  Note : All the above globals are constants declared using EQU directive
;
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 0
;                        Program Words : 0
;                        NLOAC         : 14
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


        SECTION G165_DATA 
        GLOBAL  EC_VAR_INT_XRAM
        GLOBAL  EC_CONST_INT_XRAM
        GLOBAL  TD_VAR_INT_XRAM
        GLOBAL  TD_CONST_INT_XRAM
        GLOBAL  HRL_VAR_INT_XRAM
        GLOBAL  HRL_CONST_INT_XRAM

;Constant flags for indicating EC, TD and HRL data sections within
;internal or external XRAM (to optionally compile second parallel
;memory reads in EC, TD and HRL threads).

        include "equates.asm"

        ENDSEC

;****************************** End of File *******************************

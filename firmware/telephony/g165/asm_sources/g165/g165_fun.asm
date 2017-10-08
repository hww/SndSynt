;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Module ************************************
;
;  Module Name    : G165_FUNC
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
;  10/07/00     1.0.1      Converted macros to        Sandeep Sehgal
;                          functions    
;
;*************************** Module Description ****************************
;
;  Contains the G165 main subroutines :
;                    G165_SAMP_PRO_subroutine
;                    G165_FRM_PRO_subroutine
;  Symbols Used :
;
;                    None
;  Functions Called :
;       G165_SAMP_PRO  : Overall integration module of G165EC sample
;                        processing
;       G165_FRM_PRO   : Overall integration module of G165EC frame
;                        processing
;
;**************************** Module Arguments *****************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The constant and variable declarations for this module are defined in
;     files ec_data.asm, td_data.asm, hrl_data.asm and G165_data.asm.
;  2. At least 9 locations should be available in the software stack:
;          Subroutine               Stacks required
;         ------------              ---------------
;         G165_SAMP_PRO_subroutine :      2
;         G165_FRM_PRO_subroutine  :      9
;
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
;       None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       G165_SAMP_PRO_subroutine = | iiii iiii | iiii iiii |
;
;       G165_FRM_PRO_subroutine  = | iiii iiii | iiii iiii |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;              Icycle Count  : 
;                  G165_SAMP_PRO_subroutine : (ECHOSPAN *320) + 774 (max)
;                  G165_FRM_PRO_subroutine  : 11104 (max)
;
;              Program Words :
;                  G165_SAMP_PRO_subroutine : 50
;                  G165_FRM_PRO_subroutine  : 34
;              NLOAC                        : 14
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
;       Define G165_FRM_PRO_subroutine;
;
;       Define G165_SAMP_PRO_subroutine;
;
;       End
;
;**************************** Assembly Code *******************************


        SECTION  G165_CODE
        
        org x:
        
        GLOBAL   temp_store_x0

temp_store_x0  ds  1  
      
        GLOBAL   G165_SAMP_PRO_subroutine
        GLOBAL   FG165_SAMP_PRO_subroutine


        org      p:
        
G165_SAMP_PRO_subroutine 
FG165_SAMP_PRO_subroutine      ;Overall integration module of G165EC sample

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Modified according to the calling conventions for pasing rin and sin values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        move     x:(r2),y0 
        move     x:(r3),x0
        move     y0,x:rin_sample
        move     x0,x:sin_sample

        jsr      G165_SAMP_PRO          ; processing

;;;;Frame processing moved here

        jsr      G165_FRM_PRO           ; processing
        move     x:sout_sample,y0

;;Reset m01 for linear addressing
        move     #$ffff,m01

        rts

        ENDSEC

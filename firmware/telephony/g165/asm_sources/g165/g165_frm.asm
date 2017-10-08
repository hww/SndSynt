;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : G165_FRM_PRO
;  Project ID     : G165EC
;  Author         : Qiu, Cindy, Boh Lim
;  Modified by    : Sandeep Sehgal
;
;************************* Revision History *******************************
;
;  DD/MM/YY     Code Ver   Description                Author
;  --------     --------   -----------                ------
;  27/11/97     0.0.1      Macro created              Qiu, Cindy, Boh Lim
;  29/12/97     1.0.0      Modified per review        Qiu, Cindy, Boh Lim
;                          comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  The overall integration module of G165EC frame processing
;
;  Symbols Used :
;       HRL_frm_full    : Flag to indicate that a buffer is full
;       ec_frm_full     : Flag to indicate echo-cancln frame is full
;       g165_ec_enable  : Flag to enable or disable echo cancellation
;       release_flag    : Flag for releasing disable conditions
;  
;  Subroutines Called :
;       HRL_FRM_PRO_subroutine : Does processing of frame buffers for
;                                Hold-Release Logic
;       EC_FRM_PRO_subroutine  : Does EC frame processing
;       EC_RESTART_subroutine  : Does re-initialisation of variables used in
;                                EC and TD threads
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The user options (Disable_TD, inhibit_converge, nl_option) must be 
;     set before calling this function
;  2. The functions HRL_INIT, TD_INIT & EC_INIT should be called in the order
;     specified before the first call of this function
;  3. At least 9 locations must be available on the software stack :
;          Subroutine               Stacks required
;         ------------              ---------------
;         HRL_FRM_PRO_subroutine  :       9
;         EC_FRM_PRO_subroutine   :       2
;         EC_RESTART_subroutine   :       2
;  4. All hardware looping resources including LA, LC and 2 locations of HWS
;     must be available for use in nested hardware do loop (for HRL_FRM_PRO
;     subroutine  )
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
;       HRL_frm_full     = | 0000 0000 | 0000 000i |
;
;       ec_frm_full      = | 0000 0000 | 0000 000i |
;
;       g165_ec_enable   = | 0000 0000 | 0000 000i |
;
;       release_flag     = | 0000 0000 | 0000 000i |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Cycle Count   : 11104 (max)
;                        Program Words : 33
;                        NLOAC         : 26
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
;                        r0  n  a0  b0  x0  y0  sr
;                        r1     a1  b1      y1  pc
;                        r2     a2  b2
;                        r3
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           % Logic for Frame processings %
;      
;            If  ( (ec_frm_full == 1) & (g165_ec_enable == 1) ),
;                ec_frm_full = 0;
;                ec_frm_pro();  
;            Elseif ( (HRL_frm_full == 1) & (g165_ec_enable == 0) ),
;                HRL_frm_full = 0;
;                release_flag = HRL_frm_pro();
;                If ( release_flag == 1 )
;                    % Restart G.165 echo-cancellation %
;                    ec_restart();       
;                    % Enable G.165 echo-cancellation %          
;                    g165_ec_enable = 1;  
;                Endif
;            Endif
;       End
;
;**************************** Assembly Code *******************************

        SECTION G165_CODE
        
        GLOBAL  G165_FRM_PRO
        
        org     p:
        
G165_FRM_PRO  
   
_Begin_G165_FRM_PRO
        
        move    x:ec_frm_full,a           ;If ec_frm_full = 1 &
        move    x:g165_ec_enable,x0       ; g165_ec_enable =1,
        and     x0,a                      ; do EC frame processing
        beq     _check_HRL_frm_pro        ; if condition satisfied

;Setup calling requirments of EC_FRM_PRO
        move    #<0,x:ec_frm_full         ;Clear ec_frm_full
        move    #$ffff,m01
        move    #0,n
        jsr     EC_FRM_PRO_subroutine     ;Call EC_FRM_PRO subroutine
        move    #$ffff,m01        
        bra     _End_G165_FRM_PRO

_check_HRL_frm_pro
        tstw    x:HRL_frm_full            ;Check the HRL_frm_full = 1
        beq     _End_G165_FRM_PRO         ; and g165_ec_enable = 0,
        tstw    x0                        ; branch if condition is satisfied
        bne     _End_G165_FRM_PRO

        move    #<0,x:HRL_frm_full        ;Clear HRL_frm_full
        jsr     HRL_FRM_PRO_subroutine    ;Call HLR frame processing

        tstw    x:release_flag
        beq     _End_G165_FRM_PRO
        jsr     EC_RESTART_subroutine     ;Call EC_RESTART if release_flag=1
        move    #<1,x:g165_ec_enable      ;g165_ec_enable = 1
_End_G165_FRM_PRO
        rts

        ENDSEC

;****************************** End of File *******************************

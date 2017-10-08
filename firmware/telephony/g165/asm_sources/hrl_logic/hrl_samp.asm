;**************************************************************************
;
;   (C) 2000 MOTOROLA, INC. All Rights Reserved
;
;**************************************************************************

;****************************** Function **********************************
;
;  Function Name  : HRL_SAMP_PRO
;  Project ID     : G165EC
;  Author         : Sim Boh Lim
;  Modified by    : Sandeep Sehgal
;  
;**************************Revision History ******************************* 
;
;  DD/MM/YY     Code Ver   Description                  Author
;  --------     --------   -----------                  ------
;  22/10/97      0.0.1     Macro Created               Sim Boh Lim
;  27/10/97      1.0.0     Reviewed and Modified        Sim Boh Lim
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  To collect in-coming samples into input buffer A or B and to set
;  HRL_frm_full
;
;  Symbols Used :
;       rin_sample          : Sample from rcv channel
;       sin_sample          : Sample from snd channel
;       g165_tone_disable1  : Flag to indicate that the Disabler tone is
;                             detected on rcv channel.
;       frm_count           : Counter for samples in a buffer
;       HRL_frm_full        : Flag to indicate that buffer A or B is full
;       flag_AB             : Flag to switch between buffer A and B
;       buf_ptr             : Pointer to buffer A or B, for storing incoming
;                             sample
;       buf_A[HRL_FRMLEN+2] : Buffer A for storing samples & RFFT results
;       buf_B[HRL_FRMLEN+2] : Buffer B for storing samples & RFFT results
;       HRL_FRMLEN          : Frame length for the input buffer
;                             (preferably 128)
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
;  1. HRL_INIT should be called before the first call of this module.
;     The constant and variable declarations for this module are defined in
;     file hrl_data.asm
;
;************************** Input and Output ******************************
;
;  Input  :
;       rin_sample       = | s.fff ffff | ffff ffff |   in x:rin_sample
;
;       sin_sample       = | s.fff ffff | ffff ffff |   in x:sin_sample
;
;  Output :
;       HRL_frm_full     = | 0000 0000 | 0000 000i |    in x:HRL_frm_full
;
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       g165_tone_disable1 = | 0000 0000  | 0000 000i |
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
;       buf_A(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN+1
;
;       buf_B(k)           = | s.fff ffff | ffff ffff |
;                                                   for k=0 to HRL_FRMLEN+1
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 33 (max)
;                        Program Words : 32
;                        NLOAC         : 25
;
;  Address Registers used:
;                        r0 : used to access buf_B
;                        r1 : used to access buf_ptr/buf_A/buf_B
;
;  Offset Registers used:
;                        none
;  Data Registers used:
;                        a0  x0
;                        a1
;                        a2
;  Registers Changed:
;                        r0    m01  a0   x0  sr
;                        r1         a1       pc
;                                   a2
;
;
;***************************** Pseudo Code ********************************
;
;        Begin
;            If ( g165_tone_disable1 == 1 ),
;                tmp = rin_sample;
;            Else
;                tmp = sin_sample;
;            End
;            *buf_ptr++ = tmp;
;            frm_count = frm_count - 1;
;            If ( frm_count == 0 ),
;                HRL_frm_full = 1;
;                If ( flag_AB == 0 ),
;                    buf_ptr = buf_B;
;                    flag_AB = 1;
;                Else
;                    buf_ptr = buf_A;
;                    flag_AB = 0;
;                End
;                frm_count = HRL_FRMLEN;
;
;            End
;        End
;
;**************************** Assembly Code *******************************
       
        SECTION HRL_CODE
        
        GLOBAL  HRL_SAMP_PRO
        
        include "equates.asm" 
        
        org     p:
               
HRL_SAMP_PRO   

_BEGIN_HRL_SAMP_PRO
        move    #-1,m01                   ;Linear addressing
        move    x:buf_ptr,r1              ;Read current buf_ptr of data
        move    x:rin_sample,x0
        move    x:sin_sample,a
        tstw    x:g165_tone_disable1      ;Check tone_disable1 flag
        tne     x0,a                      ;If g165_tone_disable1 is set
                                          ;  accept rin_sample else 
                                          ;  sin_sample
        move    a,x:(r1)+                 ;Store the input sample
        decw    x:frm_count               ;Decrement and check frm_count
        bne     <_save_buf_ptr            ; for frame full condition
        move    #<1,x0
        move    x0,x:HRL_frm_full         ;Set HRL_frm_full flag
        move    #buf_A,r1
        move    #buf_B,r0
        bfchg   #$0001,x:flag_AB          ;Check and toggle flag_AB
        tcc     x0,a         r0,r1        ;If flag_AB = 0, set buf_ptr
                                          ; to buf_B else to buf_A
        move    #HRL_FRMLEN,a             ;frm_count =  HRL_FRMLEN
        move    a,x:frm_count             ;Store the updated frm_count
_save_buf_ptr
        move    r1,x:buf_ptr              ;Store the updated buf_ptr
_END_HRL_SAMP_PRO

		rts

        ENDSEC
;****************************** End of File *******************************

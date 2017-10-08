;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_FRM_PRO
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  06/11/97    0.0.1        Macro Created              Quay Cindy
;  21/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  Processing after a frame of data is received.
; 
;  Symbols Used :
;       hfilt[Filt_Len+1] : Filter coefficients
;       hbak1[Filt_Len+1] : First backup of filter coeff 
;       hbak2[Filt_Len+1] : Second backup of filter coeff 
;       dbl_tlk           : Double talk detection flag
;       dont_adapt        : Flag to stop adaptation
;       trn_lvl           : Level of training
;       reset_coef        : Flag for resetting coefficients
;       nl_option         : Non - linear supression option
;       nl_supress        : Non - linear supression 
;       ener_sin_low      : LS word of ener_sin (energy of simulated samp)
;       ener_sin_high     : MS word of ener_sin
;       ener_sout_low     : LS word of ener_sout (energy of echo residue)
;       ener_sout_high    : MS word of ener_sout
;       change_flag       : Flag to indicate change in the coefficients
;       mu_base           : Base for calculating adaptation constant
;       NL_HANGOVER       : No of frames of delay before activating 
;                         :   non-linear supression
;
;  Function called
;       None  
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. EC_INIT should be called before the 1st call of this function
;     The constant and variable declarations are defined in
;     file ec_data.asm
;  2. m01 = $ffff       
;  3. Hardware looping resources including LA, LC and 1 location
;     of HWS must be available for use.
;
;************************** Input and Output ******************************
;
;  Input  :
;       None
;
;  Output :
;       None
;
;************************* Globals and Statics ****************************
;
;  Globals : 
;
;       hfilt[k]       = | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       hbak1[k]       = | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       hbak2[k]       = | s.fff ffff | ffff ffff | k = 0 to Filt_Len
;
;       dbl_tlk        = | 0000 0000  | 0000 000i |
;
;       trn_lvl        = | 0000 0000  | 0000 00ii |
;
;       nl_option      = | 0000 0000  | 0000 000i |
;
;       nl_supress     = | 0000 0000  | 0000 0iii |
;
;       mu_base        = | i.fff ffff | ffff ffff |
;
;       ener_sin_high  = | i.fff ffff | ffff ffff | 
;
;       ener_sin_low   = | ffff ffff  | ffff ffff |
;
;       ener_sout_high = | i.fff ffff | ffff ffff | 
;
;       ener_sout_low  = | ffff ffff  | ffff ffff |
;
;       reset_coef     = | 0000 0000  | 0000 000i |
;
;       dont_adapt     = | 0000 0000  | 0000 000i |
;
;       change_flag    = | 0000 0000  | 0000 000i |
;
;  Statics : 
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 3*ECHOSPAN + 68 (max)
;                        Program Words : 101
;                        NLOAC         : 80
;
;  Address Registers used:
;                        r0 : used to address hbak2 in 
;                             linear addressing mode
;                        r1 : used to address hbak1 in 
;                             linear addressing mode
;                        r3 : used to address hfilt in 
;                             linear addressing mode
;
;  Offset Registers used:
;                        None
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  a0  b0  x0  y0  sr
;                        r1  a1  b1      y1  pc
;                        r3  a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           If ( reset_coef == 1 ),
;               mu_base = 1;    
;               For ( k=0 to Filt_Len )
;                   hfilt[k] = 0;    
;                   hbak1[k] = 0;    
;                   hbak2[k] = 0;    
;               Endfor
;               trn_lvl = 0;    
;               reset_coef = 0;    
;           Elseif ( dont_adapt == 0 )
;               If ( dbl_tlk == 0 )
;                   For ( k=0 to Filt_Len )
;                       hbak2[k] = hbak1[k];    
;                       hbak1[k] = hfilt[k];    
;                   Endfor
;                   If ( ener_sout <= ener_sin/4 )
;                       trn_lvl = 1;               
;                   Endif
;                   If ( (ener_sout < 2^(-15)) & (nl_option == 1) )
;                       If ( nl_supress < NL_HANGOVER )
;                           nl_supress = nl_supress+1;      
;                       Endif
;                   Endif
;               Else
;                   If (change_flag == 1)
;                       For ( k=0 to Filt_Len )
;                           hfilt[k] = hbak2[k];     
;                           hbak1[k] = hbak2[k];     
;                       Endfor
;                       change_flag = 0
;                   Endif
;                   dbl_tlk = 0;    
;               Endif
;               If ( ener_sout > 2*ener_sin ),
;                   trn_lvl = 0;             
;               Endif;    
;               If ( trn_lvl == 1 ),    /*   Set mu_base value depending */
;                   mu_base = 1/2;          /*  upon the mode */
;               Else
;                   mu_base = 1;    
;               Endif
;           Endif
;      End
;
;**************************** Assembly Code *******************************

	SECTION EC_CODE   
	
	GLOBAL  EC_FRM_PRO
	
    include "equates.asm"	
	      
    org     p:

EC_FRM_PRO

_Begin_EC_FRM_PRO
        move    x:hbak2_p,r0              ;r0 --> hbak2[0] or hbak1[0]  
        move    x:hbak1_p,r1              ;r1 --> hbak1[0] or hbak2[0]
        move    #hfilt,r3                 ;r3 --> hfilt[0]
        move    x:EchoSpan,x0             ;Get order of filter
        move    #<0,y1                    ;Store 0 for later use
        move    x:reset_coef,a            ;Test reset_coef for zero
        tst     a                           
        beq     <_change                  ;Branch if reset_coef = 0

        move    a,x:change_flag           ;change_flag = 1
        do      x0,_resetcoffs            ;For k=0 to Filt_Len
        move    y1,x:(r0)+                ;Reset hbak2 buffer
        move    y1,x:(r1)+                ;Reset hbak1 buffer
        move    y1,x:(r3)+                ;Reset hfilt buffer
_resetcoffs
        move    y1,x:reset_coef           ;reset_coef = 0
        move    y1,x:trn_lvl              ;trn_lvl = 0
        jmp     _nochange
_change
        move    x:ener_sout_high,b        ;Get residue energy (energy_sout)
        move    x:ener_sout_low,b0           
        tstw    x:dont_adapt              ;Test dont_adapt flag
        jne     _nochange                 ;If dont_adapt = 1 branch
        tstw    x:dbl_tlk                 ;Test dbl_tlk flag

        bne     _dbl_tlk_case             ;If dbl_tlk = 1 branch

        move    r0,x:hbak1_p              ;Swap hbak1 and hbak2 pointers
        move    r1,x:hbak2_p                       

        do      x0,_storecoffs            ;For k= 0 to Filt_Len
        move    x:(r3)+,y0                ;  store hfilt[k] to hbak2[k]
        move    y0,x:(r0)+                
_storecoffs

        move    x:ener_sin_high,a         ;Get energy of simulated echo
        move    x:ener_sin_low,a0          
        asr     a                         ;Compute simulated echo
        asr     a                         ;  energy / 4
        cmp     a,b                       ;Compare ener_sout & ener_sin/4
        bgt     _noset_trn_lvl            ;Branch if ener_sout > ener_sin/4
        move    #<1,x:trn_lvl             ;Set trn_lvl = 1

_noset_trn_lvl
        tstw    x:nl_option 
        beq     _bad_trn_chk              ;Branch if nl_option =0
        tstw    x:ener_sout_high          ;Test ener_sout
        bne     _bad_trn_chk              ;Branch if ener_sout_high != 0
                                          
        move    x:nl_supress,a            ;Get nl_supress 
        cmp     #NL_HANGOVER,a            ;Compare nl_supress and NL_HANGOVER
        bge     _bad_trn_chk              ;Branch if nl_supress>=NL_HANGOVER
        incw    a                         ;nl_supress = nl_supress+1
        move    a,x:nl_supress            ;Store nl_supress
        bra     _bad_trn_chk              ;Branch to bad training case
_dbl_tlk_case

        tstw    x:change_flag             ;Test change_flag
        beq     _backup_dbltlk            ;Branch if change_flag = 0
        move    y1,x:change_flag          ;change_flag = 0
        do      x0,_backup_dbltlk         ;For k= 0 to Filt_Len
        move    x:(r0)+,a                 ;Read hbak2[k] ; r0 --> hbak2[k+1]
        move    a,x:(r1)+                 ;Store hbak2[k] to hbak1[k]
        move    a,x:(r3)+                 ;Store hbak2[k] to hfilt[k]
_backup_dbltlk

        move    y1,x:dbl_tlk              ;dbl_tlk = 0
_bad_trn_chk
        move    x:ener_sin_high,a         ;Get energy of simulated echo
        move    x:ener_sin_low,a0           
        asl     a                         ;Calculate 2*ener_sin 
        cmp     a,b                       ;Compare ener_sout and 2*ener_sin 
        ble     _noreset_trn_lvl          ;Branch if ener_sout <= 2*ener_sin
        move    y1,x:trn_lvl              ;trn_lvl = 0
_noreset_trn_lvl
        move    #$4000,b
        move    b,y0
        asl     b                         ;Store 1 and 1/2 in registers
        tstw    x:trn_lvl                 ;Check trn_lvl flag
        tne     y0,b                      
        move    b1,x:mu_base              ;Store  mu_base
_nochange
        nop
_End_EC_FRM_PRO
        
        rts
        
        ENDSEC  

;****************************** End of File *******************************

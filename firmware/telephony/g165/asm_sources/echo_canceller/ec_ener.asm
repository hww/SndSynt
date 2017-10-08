;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC
;  Function Name  : EC_ENER
;  Author         : Quay Cindy
;  Modified by    : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  22/09/97	   0.0.1	    Module created	           Quay Cindy
;  26/09/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           functions    
;
;*************************** Function Description *************************
;
;  This function performs the computation of energy of one sample
; 
;  Symbols Used :
;       sig_ener_high   : MS word of signal energy  
;       sig_ener_low    : LS word of signal energy  
;       sample          : Input sample
;  
;  Function called
;       None
;
;**************************** Function Arguments **************************
;
;       None
;
;************************* Calling Requirements ***************************
;
;  1. sig_ener_high and sig_ener_low should be in consecutive
;       memory locations and r1 --> sig_ener_high 
;  2. sample should be in y0
;
;
;************************** Input and Output ******************************
;
;  Input  :
;       sig_ener_high = | i.fff ffff| ffff ffff | in x:sig_ener_high
;
;       sig_ener_low  = | ffff ffff | ffff ffff | in x:sig_ener_low
;
;       sample        = | s.fff ffff| ffff ffff | in reg y0
;
;  Output :
;       sig_ener_high = | i.fff ffff| ffff ffff | in x:sig_ener_high
;
;       sig_ener_low  = | ffff ffff | ffff ffff | in x:sig_ener_low
;
;  Update :
;       None
;
;************************* Globals and Statics ****************************
;
;  Globals : 
;       None
;
;  Statics : 
;       None
;
;****************************** Resources *********************************
;
;                        Icycle Count  : 19
;                        Program Words : 10
;                        NLOAC         : 16
;
;  Address Registers Used:
;                        r1 : points to sig_energy in linear addressing mode
;
;  Offset Registers Used:
;                        None
;
;  Data Registers Used:
;                        a0  b0  y0  
;                        a1  b1    
;                        a2  b2
;
;  Registers Changed:
;                        a0  b0  sr
;                        a1  b1  pc
;                        a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;           sig_ener = sig_ener + 1/128(sample*sample - sig_ener + 1/2^25);
;                /* 1/(2^32) for rounding before right shift */ 
;       End
;
;**************************** Assembly Code *******************************

        SECTION EC_CODE
        
        GLOBAL  EC_ENER

        org     p:

EC_ENER

_Begin_EC_ENER
        clr     b            x:(r1)+,a    ;Loading msw of signal energy 
        move    x:(r1),a0                 ;Loading lsw of signal energy
        move    #$40,b0                   ;Loading 1/(2^25)
        mac     y0,y0,b                   ;Compute sample*sample
        sub     a,b                       ;Compute sample*sample - sig_ener
        rep     #7
        asr     b                         ;Dividing by 128
        add     b,a                       ;Adding the output to sig_ener
        move    a0,x:(r1)-                ;Saving lsw of signal energy 
        move    a1,x:(r1)                 ;Saving msw of signal energy 
_End_EC_ENER
        rts
        
	    ENDSEC	
;****************************** End of File *******************************

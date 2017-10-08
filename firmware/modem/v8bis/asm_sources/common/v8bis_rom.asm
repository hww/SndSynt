;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v8bis_rom.asm
;
; PROGRAMMER           : Binuraj K.R.
;
; DATE CREATED         : 1/4/1998
;
;**********************MODULE  DESCRIPTION ******************************
; Description:  This module contains the memory constant (DC) definitions
;               for V.21 Modem and DTMF detection. Note that these constants are
;               a good candidate for x-rom.
;
;*************************** Revision History *****************************
;
;  Date         Person             Change
;  ----         ------             ------
;  01/4/1998    Binuraj K.R.       Collated all the rom files and created this
;                                  file
;  24/4/1998    Minati             Added LPF_COEF 
;
;  14/5/1998    Minati             LPF_COEF are stored in X ROM
;
;  12/6/1998    Varadrajan G       Added NBY16_TABLE
;
;  03/6/2000    N R Prasad         Ported on to Metrowerks.
;------------------------------------------------------------------------------

;***********************************************************************
;*
;*   Constants for DTMF Modules
;*
;***********************************************************************
        
        include "v8bis_equ.asm"
        
        SECTION  dtmf_rom  GLOBAL
        include  "tone_set.asm"

;***********************************************************************
;*
;*  Cosine Values and thresholds used for MG_Filter in DTMF detection
;*
;***********************************************************************

        org     x:
; *****************************
; HPF x-rom modulo constants
;******************************

HPF_coeff        dc         $f7ec           ;a5 constant  
                 dc         $084f           ;a4 give the a coeff in -ve
                 dc         $c6b2           ;a3 and /2 the coefficients
                 dc         $34e4           ;a2 to avoid saturation.
                 dc         $0b40           ;b5
                 dc         $d305           ;b4
                 dc         $4378           ;b3
                 dc         $d305           ;b2 
                 dc         $0b40           ;b1
        

;************************
; DTMF x-memory constants
;************************
cosval_dtmf  
                dc      @cos(2.0*F0*PI/FS)    ;cosval_dtmf(0) 
                dc      @cos(2.0*F1*PI/FS)    ;cosval_dtmf(1) 
                dc      @cos(2.0*F2*PI/FS)    ;cosval_dtmf(2) 
                dc      @cos(2.0*F3*PI/FS)    ;cosval_dtmf(3) 

Thresh1a
                dc      0.1259              ;Table for Test 2 threshold 
                                            ;-9dB X_THRESH 
Thresh2a 
                dc      0.2512              ;-6dB Y_THRESH
Thresh3a 
                dc      0.1                 ;-10dB TWIST_THRESH_MINUS 
                dc      0.25                ;+6dB  TWIST_THRESH_PLUS

Thresh_s        dc      0.1                 ;-10dB for SINGLE_TONE_THRESH  


; *******************************
; Single_Tone X_memory constants
; *******************************
                 
cosval_stf
                dc      @cos(2.0*FS0*PI/FS)    ;cosval_stf(0) 
                dc      @cos(2.0*FS1*PI/FS)    ;cosval_stf(1) 
                dc      @cos(2.0*FS2*PI/FS)    ;cosval_stf(2) 
                dc      @cos(2.0*FS3*PI/FS)    ;cosval_stf(3) 
                dc      @cos(2.0*FS4*PI/FS)    ;cosval_stf(4)
                dc      @cos(2.0*FS5*PI/FS)    ;cosval_stf(5)

         ENDSEC

;***********************************************************************
;*
;*  Sinetables used by V21_modem
;*
;***********************************************************************

        SECTION  v21_prom1    GLOBAL

        ORG      x:

v21_prom1


SINE_TABLE2     dsm     144
        dupf    i,0,143
        dc      @sin(2.0*PI*i/144.0)
        endm

        ENDSEC
        
 
        SECTION  v21_prom2    GLOBAL

        ORG      x:

v21_prom2


SINE_TABLE1     dsm     360
        dupf    i,0,359
        dc      @sin(2.0*PI*i/360.0)
        endm

        ENDSEC
 
;***********************************************************************
;
;  LPF co_efficients  used by  v21_demod
;  
;**********************************************************************       
        
        SECTION v21_xrom  GLOBAL          ; This section MUST BE in
                                          ; in internal memory.
  
        ORG     x:

v21_xrom
                                       
LPF_COEF        dc      -(-0.6458/4)      ;-a3/4
                dc      -(2.2188/4)       ;-a2/4
                dc      -(-2.5645/4)      ;-a1/4
                dc      0.0011            ;b0
                dc      0.0011/(4*0.0011) ;b3/4*b0
                dc      0.0032/(4*0.0011) ;b2/4*b0
                dc      0.0032/(4*0.0011) ;b1/4*b0
                dc      -(-0.6458/4)      ;-a3/4
                dc      -(2.2188/4)       ;-a2/4
                dc      -(-2.5645/4)      ;-a1/4
                dc      0.0011            ;b0
                dc      -(-0.6458/4)      ;-a3/4 
        
NBY16_TABLE     dc     $7fff              ;1/1
                dc     $4000              ;1/2
                dc     $2aaa              ;1/3
                dc     $2000              ;1/4
                dc     $1999              ;1/5
                dc     $1555              ;1/6
                dc     $1249              ;1/7
                dc     $1000              ;1/8
                dc     $0e38              ;1/9
                dc     $0ccc              ;1/10
                dc     $0ba2              ;1/11
                dc     $0aaa              ;1/12
                dc     $09d8              ;1/13
                dc     $0924              ;1/14
                dc     $0888              ;1/15
                dc     $0800              ;1/16
                dc     $0800              ;1/16 (added intentionally to 
                                          ;  take care of boundary condition 
                                          ;  v21_rxctr = 0)

        ENDSEC

;******************* End Of File *****************************

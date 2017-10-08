;**************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
;
;  FILE NAME            : v21_mod.asm
;
;  PROGRAMMER           : Minati Ku. Sahoo 
;
;  DATE CREATED         : 20/3/1998 
;
;  FILE DESCRIPTION     : This file initializes all the variables used in
;                         V.21 Modulation and performs V.21 Modulation.  
;
;  FUNCTIONS            : FV21_Mod_Init, FV21_Mod
;
;  MACROS               : Nil
;
;*************************************************************************** 

        include "v8bis_equ.asm"

 
        SECTION V21_Mod
 
        GLOBAL  FV21_Mod
        GLOBAL  FV21_Mod_Init


;****************************** Module ************************************
;
;  Module Name    : V21_Mod_Init
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This Module initializes all the control variables required for 
;  V.21 Modulation unit. Initializations are made on the basis of
;  whether data is to be transmitted  from responding station or 
;  initiating station.
;  
;
;  Calls :
;        Modules : Nil
;        Macros  : Nil
;
;
;*************************** Revision History *****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  22/05/98     Minati             Created the module
;  03/07/2000   N R Prasad         Ported on to MW.
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. The center frequency of V21(L) Mod(1080 Hz)/V21(H) Mod(1750 Hz)in y0
;     fc = | 0000 0iii | iiii iiii | 
;     
;  Output :
;
;  1. The address of SINE_TABLE1/SINE_TABLE2 in x:tx_sinetable_ptr
;     tx_sinetable_ptr = | iiii iiii | iiii iiii |
;  2. The set up for modulo sine table in x:tx_sinetable_len
;     tx_sinetable_len = | 0000 000i | iiii iiii |
;  3. The offset increment reqd. if bit is '1' in x:index_inc1
;     index_inc1 = | 0000 0000 | 00ii iiii |
;  4. The offset increment reqd. if bit is '0' in x:index_inc0
;     index_inc0 = | 0000 0000 | 00ii iiii |
;
;****************************** Resources *********************************
;
;  Registers Used:       y0
;
;  Registers Changed:    Nil
;
;  Number of locations
;    of stack used:      Nil
;
;  Number of DO Loops:   Nil
;
;**************************** Assembly Code *******************************

        ORG     p:

FV21_Mod_Init

        cmp     #V21_L_FC,y0              ;compare with v21_l_fc, ie 1080
        beq     _v21_l_mod                ;if fc == 1080 then do v21(l) mod.
                                          ;  else do v21(h) modulation

        move    #V21_H_INDEX1,x:index_inc1
        move    #V21_H_INDEX0,x:index_inc0
        move    #(SINE_TABLE2_LEN-1),x:tx_sinetable_len
        move    #SINE_TABLE2,x:tx_sinetable_ptr
        jmp     _end_v21_mod_init

_v21_l_mod

        move    #V21_L_INDEX1,x:index_inc1
        move    #V21_L_INDEX0,x:index_inc0
        move    #(SINE_TABLE1_LEN-1),x:tx_sinetable_len
        move    #SINE_TABLE1,x:tx_sinetable_ptr

;**************************************************************************
;  
;  The sine_table_len is #360 for V.21(L) and #144 for  V.21(H) Modulation. 
;  index_inc0 is #59 for V.21(L) and #37 for V.21(H) Modulation , and 
;  index_inc1 is #49 for V.21(L) and #33 for V.21(H) Modulation.  
;
;**************************************************************************

_end_v21_mod_init

        
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Mod 
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
; 
;  This module performs V.21 Modulation . Messages from the initiating 
;  station are transmitted using the V.21(L) Modulation(1080 Hz nominal),
;  and messages from the responding station are transmitted using the
;  V.21(H) Modulation(1750 Hz nominal). The symbol rate is 300 baud and
;  CPFSK is generated . 
;
;  V.21 (L) modulates binary 1 as 980 Hz and binary 0 as 1180 Hz.      
;  V.21 (H) modulates binary 1 as 1650 Hz and binary 0 as 1850 Hz.     
;
;  As the sampling rate is 7200 Hz , this module generates 24 samples/bit. 
;
;  Calls :
;        Modules : None 
;        Macros  : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  12/05/98     Minati             Incorporated Review Comments
;  18/05/98     Minati             Changed EQU SAMPLES_PER_BIT to
;                                  SAMPLES_PER_BAUD
;  22/05/98     Minati             Changed the way of accessing
;                                  input & output
;  03/07/2000   N R Prasad         Ported on to MW.
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP. 
;  2. V21_Mod_Init is to be called before calling this module.
; 
;************************** Input and Output ******************************
;
;  Input  :
;
;        1. Data bit in y0
;           bit = | 0000 0000 | 0000 000i |
;        2. The address of SINE_TABLE1/SINE_TABLE2 in x:tx_sinetable_ptr
;           tx_sinetable_ptr = | iiii iiii | iiii iiii | 
;        3. The set up for modulo sine table in x:tx_sinetable_len 
;           tx_sinetable_len = | 0000 000i | iiii iiii | 
;        4. The offset increment reqd. if bit is '1' in x:index_inc1
;           index_inc1 = | 0000 0000 | 00ii iiii | 
;        5. The offset increment reqd. if bit is '0' in x:index_inc0
;           index_inc0 = | 0000 0000 | 00ii iiii | 
;        6. The output buffer pointer (for storing output samples)
;           in x:Fg_samples_buf_ptr 
;           Fg_samples_buf_ptr = | iiii iiii | iiii iiii |
; 
;  Output :
;
;        1. 24 Samples in location starting from x:Fg_samples_buf_ptr 
;           samples = | sfff ffff | ffff ffff |
;        2. The updated sine_table address in x:tx_sinetable_ptr 
;           tx_sinetable_ptr = | iiii iiii | iiii iiii | 
;
;****************************** Resources *********************************
;
;  Registers Used:       a,x0,y0,y1,r0,r2,n,m01 
;
;  Registers Changed:    a,x0,y0,r0,r2,m01
;                        
;  Number of locations 
;    of stack used:      Nil
;
;  Number of DO Loops:   1               
;
;**************************** Assembly Code *******************************


FV21_Mod

;**************************************************************************
;  
;  The sine_table_len is #360 for V.21(L) and #144 for  V.21(H) Modulation. 
;  index_inc0 is #59 for V.21(L) and #37 for V.21(H) Modulation , and 
;  index_inc1 is #49 for V.21(L) and #33 for V.21(H) Modulation.  
;
;**************************************************************************
       
        move    x:tx_sinetable_len,m01    ;m01 set up for a buffer size
                                          ;  #sine_table_len
        move    x:tx_sinetable_ptr,r0     ;r0 -> sine_table
        move    x:index_inc0,y1           ;get the offset increment reqd. 
                                          ;  if bit is 0 (index_inc0) in y1
        move    x:index_inc1,a            ;get the offset increment reqd.
                                          ;  if bit is 1 (index_inc1) in a
        asr     y0                        ;get the bit
        tcc     y1,a                      ;if bit == 0 , index_inc0 in a
        move    a,n                       ;index_inc in n 
        move    x:Fg_samples_buf_ptr,r2   ;r2 -> first location for storing
                                          ;  output samples
                             
        neg     a            x:(r0)+n,x0  ;(-index_inc) in a
                                          ;  index = index + index_inc 
        
        do      #SAMPLES_PER_BAUD,_sine_val
                                          ;for i = 1 to 24 
       
        move    x:(r0)+n,x0               ;get the value from sine_table      
                                          ;  TBD 7
        move    x0,x:(r2)+                ;store sine_val in buffer
         
_sine_val                                 ;end of i loop  

        move    a,n  
        nop
        lea     (r0)+n                    ;index = index - index_inc
        move    r0,x:tx_sinetable_ptr     ;store the address of sine_table
                                          ;  reqd. for CPFSK
        move    #-1,m01                   ;set up for linear arithmetic  

        rts 
       
        ENDSEC
  
;****************************** End of File *******************************

;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxfreq_shift.asm
;
; PROGRAMMER           : Minati Ku. Sahoo
;
; DATE CREATED         : 01/06/98
;
; FILE DESCRIPTION     : This module brings the input signal down
;                        to base band. 
;
; FUNCTIONS            : V21_RxFreq_Shift
;
; MACROS               : Nil
;
;****************************** Module ***********************************
;
;  Module Name    : V21_RxFreq_Shift
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ***************************
;
;  The input signal is multiplied by the nominal center frequency
;  ( Signal * exp(jwc) ; fc = 1080 Hz if V21(L) , 1750 Hz if V21(H))
;  and brought down to base band. 
;
;  Calls :
;        Modules : Nil 
;        Macros  : Nil
;
;*************************** Revision History ****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  01/06/98     Minati             Created the module.
;  03/07/2000   N R Prasad         Ported on to Metrowerks.
;                                  Macro converted to function.
;
;************************* Calling Requirements **************************
;
;
;************************** Input and Output *****************************
;
;  Input  :
;
;  1. The input samples(24) are in location starting from pointer
;     x:Fg_samples_buf_ptr 
;     samples  = | sfff ffff | ffff ffff |
;  2. The address of SINE_TABLE1/SINE_TABLE2 in x:rx_sinetable_ptr
;     rx_sinetable_ptr = | iiii iiii | iiii iiii |
;  3. The set up for modulo sine_table(for both r0 & r1)in x:rx_sinetable_len
;     rx_sinetable_len = | 1000 000i | iiii iiii |
;  4. The offset reqd. to search for sine value in x:sine_index
;     sine_index = | 0000 0000 | 00ii iiii |
;  5. The offset reqd. to search for cos value in x:cos_index
;     cos_index = | 0000 0000 | 0iii iiii |
;  6. The agc gain in x:v21_agcg
;     v21_agcg = | 0000 0000 | 0000 00ii | 
;
;  Output :
; 
;  1. The real part of multiplication result in x:fs_rl_buf
;     fs_rl_buf = | sfff ffff | ffff ffff |
;  2. The imaginary part of the multiplication result in x:fs_im_buf
;     fs_im_buf = | sfff ffff | ffff ffff |     
;  3. The updated sine table address in x:rx_sinetable_ptr
;     rx_sinetable_ptr = | iiii iiii | iiii iiii |
;     
;****************************** Resources ********************************
;
;  Registers Used:       a,x0,y0,r0-r3,m01,n 
;
;  Registers Changed:    a,x0,y0,r0-r3,m01,n 
;
;  Number of locations
;    of stack used:      Nil
;
;  Number of DO Loops:   1
;
;**************************** Assembly Code ******************************

        include "v8bis_equ.asm"
        
        SECTION V21_RxDemod
 
        GLOBAL  V21_RxDemod 
        GLOBAL  V21_RxFreq_Shift

        ORG     p:

V21_RxFreq_Shift 
                                          
        move    x:Fg_samples_buf_ptr,r3   ;r3 -> input samples
        move    #fs_rl_buf,r1             ;r1 -> fs_rl_buf[1]
        move    x:v21_agcg,r2             ;get agc gain
        tstw    r2                        
        blt     _divide_agcgain           ;if agc gain is -ve devide 
                                          ;  input samples by agc gain
                                          ;  else multiply by agc gain
 
        do      #SAMPLES_PER_BAUD,_agc_multiply
                                          ;for i = 1 to 24
        move    x:(r3)+,x0                ;get input sample
        rep     r2
        asl     x0                        ;multiply by agc gain
        move    x0,x:(r1)+                ;store the result in fs_rl_buf

_agc_multiply                             ;end of i loop

        jmp     _agc_divide 

_divide_agcgain

        do      #SAMPLES_PER_BAUD,_agc_divide
                                          ;for i = 1 to 24
        move    x:(r3)+,x0                ;get input sample
        rep     r2
        asr     x0                        ;divide input sample by agc gain
        move    x0,x:(r1)+                ;store the result in fs_rl_buf

_agc_divide                               ;end of i loop

        
        move    x:rx_sinetable_len,m01   ;m01 set up for both r0 & r1 for a
                                         ;  buffer size of #sine_table_len
        move    x:rx_sinetable_ptr,r0    ;r0 -> sine_table
 
;**************************************************************************
;
;  The sine table length is #360 for V21(L) demodulation and #144 for  
;  v21(H) demodulation . cos_index is #90 for V21(L) and #36 for V21(H)
;  demodulation. sine_index is #54 for V21(L)  and #35 for V21(H) 
;  demodulation.
;
;  The input signal samples(24) are in fs_rl_buf. Input signal is
;  multiplied separately with cos(wc) and sin(wc). The real part of
;  the multiplication is in fs_rl_buf and the imaginary part of  the
;  multiplication is in fs_im_buf.
;
;**************************************************************************

        move    r0,r1
        move    x:cos_index,n             ;get the offset reqd. to search
                                          ;  for cos value
        move    #fs_im_buf,r2             ;r2 -> fs_im_buf[1]
        lea     (r1)+n                    ;r1 -> cos(theta)
        move    x:sine_index,n            ;get the offset reqd. to search
                                          ;  for sine value
        move    #fs_rl_buf,r3             ;r3 -> fs_rl_buf[1]
        lea     (r2)-
        move    x:(r2),a
 
        do      #SAMPLES_PER_BAUD,_freq_shift
                                          ;for i = 1 to 24
 
        move    x:(r1)+n,y0               ;get the cos value 
        move    x:(r3),x0                 ;get the input sample 
        mpy     x0,y0,a      a,x:(r2)+    ;multiply the input sample with 
                                          ;  cos value and store the sine  
                                          ;  multiplication result.
        move    x:(r0)+n,y0               ;get the sine value from sine_table
        mpy     x0,y0,a      a,x:(r3)+    ;multiply the input sample with
                                          ;  sine value and store the cos 
                                          ;  multiplication result.
 
_freq_shift                               ;end of i loop

        move    a,x:(r2)                  ;store the last sine multiplication
                                          ;  result in fs_im_buf
        move    r0,x:rx_sinetable_ptr     ;store sine_table address (reqd. for
                                          ;  next baud multiplication)
        move    #-1,m01                   ;set up for linear arithmetic

        rts

        ENDSEC
        
;*****************************End of File************************************


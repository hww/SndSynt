;*************************************************************************** 
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v8_cd.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 14.05.98
;
; FILE DESCRIPTION     : computes the AGCGain based on 16 bauds of
;                        mark signal during preamble.   
;
; FUNCTIONS            : v8_cd
;
; MACROS               : None
;
;*************************************************************************** 
        
        include "v8bis_equ.asm"
        
        SECTION v8_cdagc

        GLOBAL   V21_RxCd


;****************************** Module ************************************
;
;  Module Name    : V8_RxCd 
;  Author         : G.Prashanth
;
;************************** Module Description ****************************
; implements the carreer detection.Declares the presence of the signal
; if it is greater than -43dBm.Assuming 0 dBm to be the full scale
; sine wave, -43dBm => 10^(-43/10) = 5.0119e-05. This is the value
; of NEG43DB_THRESH. But -45dBm is kept as a threshold with a safety 
; marging of 2dBm.
; 
;  Calls :
;        Modules : None 
;        Macros  : None
;
;*************************** Revision History *****************************
;
;     Date         Person          Description        
;     ----         ------             ------
;   14/05/98     G.Prashanth       Module Created  
;   04/06/98     Varadarajan G     Added the energy accumulation 
;   03/07/2000   N R Prasad        Ported on to Metrowerks 
;
;************************** Input and Output ******************************
;
;  Input  :  
;      real samples | ssff ffff | ffff ffff | in x:lpfout_rl_buf+1 till 
;                                                x:lpfout_rl_buf+12
;      imag samples | ssff ffff | ffff ffff | in x:lpfout_im_buf+1 till 
;                                                x:lpfout_im_buf+12
;      acc. energy  | sfff ffff | ffff ffff | in x:v21_acenergy & +1
;
;  Output :
;      x:baud_ener  | 0fff ffff | ffff ffff|     32 bit positive no.
;   
;      x:v21_cdflag | 0000 0000 | 0000 000i|      career detection
;                                                 decision  
;      acc. energy  | sfff ffff | ffff ffff | in x:v21_acenergy & +1
;
;****************************** Resources *********************************
;
;  Registers Used:         a,b,x0,y0,y1
;                          r0,r1,r2 
;
;  Registers Changed:      a,b,x0,y0,y1
;                          r0,r1,r2  
;                        
;  Number of locations 
;    of stack used:        NIL 
;
;  Number of DO Loops:     1                 
;
;**************************** Assembly Code ******************************

V21_RxCd
        move    #lpfout_rl_buf+1,r0
        move    #lpfout_im_buf+1,r1
        move    #EIGHT_BY_12,x0           ;get constat value to find avg
                                          ;  avg energy = energy/12. 
        clr     a            x:(r0)+,y0   ;clear accumulator,get 
                                          ;  the first real value. 
        do      #(SAMPLES_PER_BAUD/2),_end_energy
        asr     y0                        ;to avoid saturation devide
                                          ;  each sample by two. 
        mac     y0,y0,a      x:(r1)+,y0   ;Fetch Complex sample
        asr     y0 
        mac     y0,y0,a      x:(r0)+,y0   ;Fetch real sample
_end_energy
        asr     a                         ;energy = energy/8
;***********************************
;Perform double precision multiplication 
; to find out avg mean energy - energy/12.
;************************************                                  
        move    a0,y0                    
        move    a,y1
        mpysu   x0,y0,a
        move    a1,b0
        move    a2,a
        move    b0,a0
        mac     y1,x0,a
        move    #NEG43DB_THRESH_HI,b
        move    #NEG43DB_THRESH_LO,b0     ;
        move    #v21_acenergy,r2
        move    a1,x:baud_enrg            ;store the double precision 
                                          ;  value of energy. Note it wont
        move    a0,x:baud_enrg+1          ;  saturate
        move    #0,x:v21_cdflag           ;Clear the cd flag before testing
        cmp     b,a        x:(r2)+,b      ;compare with career energy.
                                          ;  to find the decision.
        blt     _NOT_PRESENT
        move    #1,x:v21_cdflag           ;1 => signal present.
_NOT_PRESENT
        move    x:(r2)-,b0
        add     a,b
        move    b,x:(r2)+                 ;Store the accumulated energy
        move    b0,x:(r2)                 ;  for computing the agcgain
End_V21_RxCd

        jmp     V21_Rx_Nxt_Tsk
        
        ENDSEC
        
;******************* End Of File ******************************        

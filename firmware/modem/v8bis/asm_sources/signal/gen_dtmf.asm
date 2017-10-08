;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : gen_dtmf.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 9:04:98
;
; FILE DESCRIPTION     : Initialise the dualtone variables and generates
;                        144 samples of DTMF.  
;
; FUNCTIONS            : FDtmf_Init,FDtmf_Buff_Gen 
;
; MACROS               : -
;
;************************************************************************  
        
        include "tone_set.asm"         ; include definitions.
        include "v8bis_equ.asm"

        SECTION gen_dtmf                                        
        GLOBAL  FDtmf_Init
        GLOBAL  FDtmf_Buff_Gen  

        
;****************************** Module *************************************
;
; Module Name  :   FDtmf_Init 
; Author       :   G.prashanth
;
;************************* Module Description *************************** 
;     This module is designed to provide the low-level routines
;     invoked by the routines found in Signal_Gen.c.  These
;     routines perform the necessary computations for DTMF tone
;     generation.
;     This initializes the pair of initial states and the 
;     coefficients of the corresponding digital oscillator,depending on 
;     signal.The signal coefficients should be stored as shown below
;    
;                    ___________
;     sl1 ->        |___________| 
;     sl2 ->        |___________|
;     sh1 ->        |___________| 
;     sh2 ->        |___________|
;
;    Calls : 
;          Modules :  N/A
;          Macros  :  N/A
;
;************************** Revision History *****************************
;
;      Date               Author              Discription 
;      ----               ------               --------
;  25:03:98           G.Prashanth        Module Created
;  24:04:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
;
;************************* Calling Requirements *************************
;
;  1.Initialise frequency offset. 
;  2.Initialise the amplitude.
; 
;*************************** Input and Output ****************************
;
;  Inputs : N/A
;
;  Outputs:
;        
;     sl1     = | s.fff ffff | ffff ffff |
;     [initial state 1 of the low group oscillator.]
;
;     al_2    = | 0.fff ffff | ffff ffff |
;     [coefficient of the low group oscillator].
;
;     sl2     = | s.fff ffff | ffff ffff |
;     [initial state 2 of the low  group oscillator.]
;
;     sh1     = | s.fff ffff | ffff ffff |
;     [initial state 1 of the low group oscillator.]
;
;     sh2     = | s.fff ffff | ffff ffff |
;     [initial state 2 of the high group oscillator.]
;
;     ah_2    = | 0.fff ffff| ffff ffff |
;     [ coefficient of the high group oscillator]
;
;
;***************************** Resources **********************************
;
;  Registers Used       :   b,r3,n,r0
;                           y1,y0,x0
;
;  Registers Changed    :   b,y1,r3,r0
;                           n,x0,y0
;
;  Number of locations
;  stack used           :   N/A 
;
;  Number of DO Loops   :   1
;
;******************************** Assembly Code **************************

        ORG     p:
FDtmf_Init

;***********************************************************************
;
; Store low group coeff in al_2  and high group coeff in ah_2 
;  calculate initial sine generator states for low and high
;  group sine waves
;
;***********************************************************************

        move    #cosval_dtmf,r3
        move    x:Fg_dual_offset,n 
        nop
        lea     (r3)+n                    ;get the signal type
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;low freq value in x0,
                                          ;  dummy move of r0 to y0 
                                          ;  is done. 
        move    x0,x:al_2                 ;store off al_2 in memory
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;high freq in x0
                                          ;  dummy move of r0 to y0 and 
                                          ;  dummy incr. of r3 is done.
        move    x0,y0                     ;move high_freq value.
        move    x:al_2,x0                 ;get low_freq value in x0. 
        move    y0,x:ah_2                 ;store off ah_2 in memory
        move    x:Fg_signal_amp,y1        ;get amplitude in y1
        mpyr    x0,y1,b                   ;sl1=amp*al_2 in b
        move    b,x:sl1                   ;Store sl1
        move    y1,x:sl2                  ;Store sl2=amp
        mpyr    y1,y0,b                   ;sh1=amp*ah_2 in b
        move    b,x:sh1                   ;Store sh1
        move    y1,x:sh2                  ;Store sh2=amp
        rts


;***************************** Module ************************************
;
;  Module Name   : FDtmf_Buff_Gen
;  Author        : G.Prashanth
;
;*************************** Description *******************************
;
;  This module generates the DTMF tone using two digital oscillators,one
;  producing each of the low group and high group frequencies.The output
;  is the sum of the outputs of the two oscillators and this also 
;  updates the states of the oscillator. 
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Discription 
;  ------              ----------              ---------
;  22:03:98             G.Prashanth           Module Created
;  24:04:98             G.Prashanth           Incorporated Review comments
;  03:07:2000           N R Prasad            Ported on to Metrowerks
;
;************************ Calling Requirements *************************
;
;  1. Initialise x:sl1
;  2. Initialise x:sh1
;  3. Initialise x:sl2
;  4. Initialise x:sh2
;  5. Initialize x:Fg_samples_buf_ptr
;
;
;************************* Input and Output ****************************
;
;  Inputs :     [assumes state setup for dtmf gen by FDtmf_Init or
;                a previous call to FDtmf_Buff_Gen]
;
;     sl1     = | s.fff ffff | ffff ffff | 
;     [initial state 1 of the low group oscillator.]
;
;     sl2     = | s.fff ffff | ffff ffff |
;     [initial state 2 of the low  group oscillator.]
;
;     al_2    = | 0.fff ffff | ffff ffff |
;     [coefficient of the low group oscillator]  
;
;     sh1     = | s.fff ffff | ffff ffff |
;     [initial state 1 of the high group oscillator.]
;
;     sh2     = | s.fff ffff | ffff ffff |
;     [initial state 2 of the high group oscillator.]
;
;     ah_2    = | 0.fff ffff | ffff ffff |
;     [coefficient of the high group oscillator]
;
;    Outputs :  144 samples of DTMF signal at x:Fg_samples_buf_ptr
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b
;                        r0,r2,r3,n  
;
;  Registers Changed   : x0,y0,y1,a,b 
;                        r0,r2,r3,n
;
;  Number of locations :  N/A
;  of stack used  
;
;  Number of Do loops  : 1 
;
;************************** Assembly Code *****************************
 
FDtmf_Buff_Gen
                
        move    x:Fg_samples_buf_ptr,r0   ;get the output buff pointer 
        move    #NS,lc                    ;get the number of samples 
        move    #sl1,r2                   ;r2 -> sl1
        move    #sh1,r3                   ;r3 -> sh1
        move    x:al_2,x0                 ;move the coefficients to 
        move    x:ah_2,y0                 ;registers. 
        move    #-1,n                     ;move $ffff to n
        lea     (r0)-                     ;let r0 point to previos locn
        move    x:(r0),b                  ;dummy move to b.             
        move    x:(r2)+,y1                ;get sl1
        do      lc,_END_DTMF_GEN
                             
        mpy     x0,y1,b      b,x:(r0)+    ;(al_2*sl1) in b and move
                                          ;  b to output buffer
        move    x:(r2),a                  ;get sl2  
        asl     b            y1,x:(r2)+n  ;compensate for al_2 and
                                          ;  sl2 now = sl1 old
        sub     a,b          x:(r3)+,y1   ;term1 = (al*sl1 - sl2)
                                          ;  get sh1 
        mpy     y0,y1,b      b,x:(r2)+    ;(ah_2*sh1) in b and 
                                          ;  sl1 = term1. 
        move    x:(r3),a                  ;get sh2
        asl     b            y1,x:(r3)+n  ;compensate for ah_2 and
                                          ;  sh2 now = sh1 old
        lea     (r2)-                     ;r2 -> sl1
        sub     a,b          x:(r2)+,y1   ;term2 = (ah*sh1 - sh2) and
                                          ;  get sl1.
        add     y1,b         b,x:(r3)+    ;term = term1+term2 and
                                          ;  sh1 = term2
        rnd     b            x:(r3)+n,a   ;round the value before movi
                                          ;  to output and dummy move
                                          ;  of r3 done so that r3->sh1 
_END_DTMF_GEN
        move    b,x:(r0)+                 ;move the last sample to 
                                          ;  out buffer
        rts
        ENDSEC           
        
;*************************** End of File *********************************** 

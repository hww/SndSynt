;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : gen_single.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 10:04:98
;
; FILE DESCRIPTION     : Initialises the single tone variables and 
;                        generates STF depending on frequency.
;
; FUNCTIONS            : FStf_Init,FStf_Buff_Init
;
; MACROS               :  -
;
;************************************************************************  

        include "tone_set.asm"          ; include definitions
        include "v8bis_equ.asm"
        
        SECTION gen_single                                              
        GLOBAL  FStf_Init
        GLOBAL  FStf_Buff_Gen

        
;***************************** Module ********************************
;
;  Module Name   : FStf_Init 
;  Author        : G.Prashanth 
;
;*************************** Description *******************************
;
;   This module is designed to provide the low_level routines invoked
;   by the routines found in Signal_gen. These routines perform the 
;   necessary computations for single tone generation. 
;   This module initializes single tone states and the coefficients 
;   of the corresponding digital oscillator,depending on v8bis single
;   tone signal. 
;
;  Calls:
;       Modules  : N/A 
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description 
;  ------              ----------              ---------
;  28:03:98            G.Prashanth        Module Created
;  24:04:98            G.Prashanth        Incorporated Review comments 
;  03:07:2000          N R Prasad         Ported on to Metrowerks 
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
;************************ Calling Requirements *************************
;
;  1. Initialize frequency offset x:Fg_single_offset
;  2. Initialise amplitude        x:Fg_signal_amp 
;
;
;************************* Input and Output ****************************
;
;  Inputs : N/A
;
;  Outputs:
;        
;     sl1    = | s.fff ffff | ffff ffff |
;     [initial state 1 of oscillator.]
;
;     al_2   = | 0.fff ffff | ffff ffff |
;     [coefficient of the oscillator].
;
;     sl2    = | s.fff ffff | ffff ffff |
;     [initial state 2 of the oscillator.]
;
;
;**************************** Resources *******************************
;
;  Registers Used      :  x0,y1,b,y0
;                         r3,n,a,r0 
;
;  Registers Changed   :  x0,y1,b,y0
;                         r3,n,a,r0
;
;  Number of locations :  N/A
;  of stack used  
;
;  Number of Do loops  :  N/A 
;
;************************** Assembly Code *****************************

       ORG      p:  

FStf_Init
;**********************************************************************
;
; Fetch coefficients from tables cosval_stf 
;  and store in al_2 (coeff)
;  calculate initial sine generator states for 
;  sine waves
;
;**********************************************************************

        move    #cosval_stf,r3
        move    x:Fg_single_offset,n    
        lea     (r3)+n                    ;calc. address in table

        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;al_2 in x0,dummy move of
                                          ;  r0 to y0 is done.
        move    x0,x:al_2                 ;store off al_2 in memory
        move    x:Fg_signal_amp,a         ;get amplitude/2  
        asl     a                         ;multiply by 2 sinse it 
                                          ;  is single_tone.
        move    a,y1                      ;get amplitude  
        mpyr    x0,y1,b                   ;sl1=amp*al/2 
        move    b,x:sl1                   ;Store sl1
        move    y1,x:sl2                  ;Store sl2=amp
        rts

;***************************** Module ********************************
;
;  Module Name   :  FStf_Buff_Gen
;  Author        :  G.Prashanth 
;
;*************************** Description *******************************
;
;  This module generates the STF tone using  digital oscillator, 
;  The output of the oscillator produces the frequencis and also
;  states of the oscillator are updated.
;
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author              Discription 
;  ------              ----------             ---------
;  28:03:98            G.Prashanth           Module Created
;  24:04:98            G.Prashanth           Incorporated Review comments 
;  03:07:2000          N R Prasad            Ported on to Metrowerks 
;
;************************ Calling Requirements *************************
;
;  1. Initialise x:sl1
;  2. Initialise x:sl2
;  3. Initlalize x:Fg_samples_buf_ptr
;
;
;************************* Input and Output ****************************
;
;  Inputs :     [assumes state setup for single tone gen by FStf_Init 
;                or a previous call to FStf_Buff_Gen]
;
;     sl1     = | s.fff ffff | ffff ffff | 
;     [initial state 1 of the oscillator.]
;
;     sl2     = | s.fff ffff | ffff ffff |
;     [initial state 2 of the oscillator]
;
;     al_2    = | 0.fff ffff | ffff ffff |
;     [coefficient of the oscillator]  
;    
;   Outputs : 144 samples of single tone of specified frequency.    
;
;**************************** Resources *******************************
;
;  Registers Used      :  x0,y1,a,
;                         r0,b
;
;  Registers Changed   :  x0,y1,a,
;                         r0,b
;
;  Number of locations :  N/A
;  of stack used  
;
;  Number of Do loops  :  1 
;
;************************** Assembly Code *****************************
FStf_Buff_Gen

        move    x:Fg_samples_buf_ptr,r0   ;get the output buffer ptr    
        move    #NS,lc                    ;get the number of samples
        lea     (r0)- 
        move    x:al_2,x0                 ;get ampplitude 
        move    x:sl1,y1                  ;Get sl1
        move    x:sl2,a                   ;Get sl2
        do      lc,_END_STF_GEN
;*******************************
;  Sine sample generation
;******************************
        mpy     y1,x0,b      b,x:(r0)+    ;Save sl1 in y1 for update
                                          ;  (al/2*sl1) in b move tone
                                          ;  to output buffer.   
        asl     b                         ;compensate for al_2
        sub     a,b                       ;term1=(al*sl1-sl2) in b
        move    y1,a                      ;sl2 now = old sl1
        move    b,y1                      ;Update sl1=term1
        rnd     b                         ;round the value before
                                          ;  outputting to buffer.   
_END_STF_GEN
        move    b,x:(r0)+                 ;move tone sample to 
                                          ;  output buffer
        move    y1,x:sl1                  ;update the phase value
        move    a,x:sl2                   ;  and copy it.
        rts
        ENDSEC

;*************************** End of File *****************************  

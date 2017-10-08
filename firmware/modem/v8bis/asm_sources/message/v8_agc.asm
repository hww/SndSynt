;**********************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v8_agc.asm
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 14 May 1998
;
; FILE DESCRIPTION     : computes the AGCGain based on 16 bauds of
;                        mark signal during preamble.   
;
; FUNCTIONS            : V21_Rxagcgjam
;                       
; MACROS               : None
;
;*************************************************************************** 
        
        include "v8bis_equ.asm"
        
        SECTION V21_Rxagcgjam

        GLOBAL   V21_Rxagcgjam
        
        
;****************************** Module ************************************
;
;  Module Name    : V21_Rxagcgjam
;  Author         : G.Prashanth
;
;************************** Module Description ****************************
; computes the AGCGain based on the 16bauds of mark signal during 
;  preamble. 
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
;   10/06/98     Varadarajan G     Removed the baud checking code from this
;                                  module and moved it to calling module.
;                                  Made this module called from V21_Rxagc
;   03/07/2000   N R Prasad        Ported on to Metrowerks.  
;   07/08/2000   N R Prasad        Internal memory moved to 
;                                  external; hence dual parallel
;                                  moves converted into single
;                                  parallel moves.
;
;************************* Calling Requirements ***************************
;
;  1. v21_rxctr should be within 0-16
;  2. m01 = -1
;   
;************************** Input and Output ******************************
;
;  Input  :    
;      acc.energy   | 0fff ffff | ffff ffff|     in x:v21_acenergy &
;                   | ffff ffff | ffff ffff|     in x:v21_acenergy+1
;
;      Baud elapsed | 0000 0000 | 000i iiii|     in x:v21_rxctr (Maxval 16)
;      NBY16_TABLE  | 0fff ffff | ffff ffff|     in x:NBY16_TABLE(0:15)
;                                                   in XROM
;  Output :
;      Agcgain      | ssss ssss | ssss iiii|     in x:v21_agcg represented
;                                                as the no. of shifts reqd.
;
;****************************** Resources *********************************
;
;  Registers Used:        a,b,r0,r3,x0,y0,y1
;
;  Registers Changed:     a,b,r0,r3,x0,y0,y1
;                        
;  Number of locations    
;    of stack used:       NIL
;
;  Number of DO Loops:    None
;
;**************************** Assembly Code *******************************

        ORG     p:
V21_Rxagcgjam
        move    #16,x0
        sub     x:v21_rxctr,x0            ;16 - no.of bauds elapsed
        move    x0,n                      ;Find Agclength
        move    #NBY16_TABLE,r3
        move    #v21_acenergy,r0  
        lea     (r3)+n
        move    x:(r0)+,y1     
        move    x:(r3)+,x0                ;get energy,should be a 32 bit
        clr     b              x:(r0)+,y0 ;  fraction. Fetch 1/Agclength
        mpysu   x0,y0,a                   ;Double precision multiplication
        move    a1,y0
        move    a2,a
        move    y0,a0
        mac     x0,y1,a                   ;aven = en*1/Agclength
        clr     r0

        rep     #NORM_CNT
        norm    r0,a                      ;Normalise aven (equivalent to
                                          ;  quanize 1/aven to power of 2)
        move    r0,a                      ;Get the floor(log2(1/aven))
        move    #ROUND_CONST,b0
        abs     a
        asr     a                         ;Equivalent of finding sqrt of 1/aven
        add     b,a
        move    #0,a0                     ;2s complement rounding of aven
        sub     #2,a                      ;Energy limited to 0.0625
        move    a,x:v21_agcg              ;Store the 1/2*floor(log2(1/aven))
End_V21_Rxagcgjam
        rts
        
        ENDSEC
;******************* End Of File ******************************************        

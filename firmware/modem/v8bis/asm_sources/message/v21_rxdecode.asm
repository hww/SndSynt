;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxdecode.asm
;
; PROGRAMMER           : Minati Ku. Sahoo
;
; DATE CREATED         : 01/06/98
;
; FILE DESCRIPTION     : This module decodes +ve sample as 1 , and 
;                        _ve sample as 0.  
;
; FUNCTIONS            : V21_RxDecode
;
; MACROS               : Nil
;
;************************************************************************
 

        SECTION V21_RxDecode

        GLOBAL    V21_RxDecode
        
 
;****************************** Module ************************************
;
;  Module Name    : V21_RxDecode
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This module gets the samples from which decision is to be taken as
;  input. If the sample is +ve ,the decoded bit is 1 , else it is 0. 
;
;  Calls :
;        Modules : Nil
;        Macros  : Nil
;
;*************************** Revision History *****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  01/06/98     Minati             Created the module. 
;  03/07/2000   N R Prasad         Ported on to Metrowerks
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  1. The sample/samples from which decision is taken in x:decision_buf
;     decision_buf = | sfff ffff | ffff ffff |
;  2. Number of decisions in x:Fg_v21_rx_decision_length
;     Fg_v21_rx_decision_length = | 0000 0000 | 0000 00ii |
;
;  Output :
;
;  1. The data bit/bits in x:Fg_v21_rxdemod_bits 
;     Fg_v21_rxdemod_bits  = | 0000 0000 | 0000 00ii |
;
;****************************** Resources *********************************
;
;  Registers Used:       y0,x0,r2 
;
;  Registers Changed:    y0,x0,r2 
;
;  Number of locations
;    of stack used:      Nil
;
;  Number of DO Loops:   1
;
;**************************** Assembly Code *******************************
 
        ORG     p:

V21_RxDecode


        clr     y0
        tstw    x:Fg_v21_rx_decision_length
        
        jeq     _end_decision             ;if no. of decisions == 0 then
                                          ;  no decision is taken.
       
        move    #decision_buf,r2          ;r2 -> decision_buf[1]
        move    x:Fg_v21_rx_decision_length,lc      
                                          ;count = no of decisions
        do      lc,_end_decision          ;for i = 1 to no of decisions
 
        move    x:(r2)+,x0                ;get the sample ( from which
                                          ;  decision is to be taken)
        not     x0                        ;1 in MSB of x0 if the sample 
                                          ;  is +ve else 0 in MSB
        asl     x0                        ;MSB of x0 in carry,
                                          ;  carry is the decoded bit
        rol     y0                        ;store the bit at the LSB of y0

_end_decision

        move    y0,x:Fg_v21_rxdemod_bits

;************************************************************************ 
; 
;  if there are 2 decisions then 1st bit of y0 is the first decision
;  and 0th bit is the 2nd decision.
;
;*************************************************************************
        jmp     V21_Rx_Nxt_Tsk 

        ENDSEC
 
;****************************** End of File *******************************
       

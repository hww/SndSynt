;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : calc_crc_ccitt.asm
;
; PROGRAMMER           : Minati Ku. Sahoo
;
; DATE CREATED         : 19/05/98
;
; FILE DESCRIPTION     : This module finds the CRC of message octets.  
;
; FUNCTIONS            : FCalc_Crc_Ccitt,FCrc_BitReversed
;
; MACROS               : Nil
;
;************************************************************************


        SECTION Calc_Crc_Ccitt

        GLOBAL  FCalc_Crc_Ccitt   
        GLOBAL  FCrc_BitReversed
           
;****************************** Module ************************************
;
;  Module Name    : Calc_Crc_Ccitt
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;  
;  This module computes the CRC of message octets as per the rule given
;  in 7.2.7 of V.8bis Standard. 
;  
;  Calls :
;        Modules : Nil 
;        Macros  : Nil
;
;*************************** Revision History *****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  20/05/98     Minati             Created the module
;  03/07/2000   N R Prasad         Ported on to Mwtrowerks.
; 
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;************************** Input and Output ******************************
;
;  Input  :
;
;  Buffer containing inputs in order
;  1.  No of message octets to be transmitted
;      no of message octets = | iiii iiii | iiiii iiiii |
;  2.  Message octets packed into words 
;      Message octets = | 0000 0000 | iiii iiii |
;  r2 -> first location of the buffer  
;
;  Output :
;        
;  1.  CRC of the message octets in y0
;  CRC = | iiii iiiii | iiii iiii |
;      
;
;****************************** Resources *********************************
;
;  Registers Used:       a,b,x0,y0,y1,r2
;
;  Registers Changed:    a,b,x0,y0,y1,r2
;
;  Number of locations
;    of stack used:      Nil
;
;  Number of DO Loops:   2 
;
;**************************** Assembly Code *******************************

        include "v8bis_equ.asm"
                
        ORG     p:
         
        
FCalc_Crc_Ccitt


        move    x:(r2)+,b                 ;get the no. of octets 
        move    #2,y1                     ;to complement first 2 octets
        move    #0,y0                     
        
_start_crc
 
        move    x:(r2)+,a1                ;get the message octet
        decw    y1 
        jlt     _no_inv                   ;complement the first 
                                          ;  2 message octets
        move    #$00ff,x0
        eor     x0,a

_no_inv

        move    #CRC_CCITT_DIVISOR,x0     ;Take CRC divisor,ie $1021
        ror     a                         ;Take bits from ls side
        rol     y0                        ;Put them on ls side of o/p
        
        do      #(OCTET_LENGTH-1),_crc_byte_loop     
                                          ;for i = 1 to 7

        jcc     _no_exor                  ;If the thrown ls bit is set,
        eor     x0,y0                     ;  Eor the data with divisor
_no_exor
        
        ror     a                         ;Take bits from ls side
        rol     y0                        ;Put them on ls side of o/p
        nop

_crc_byte_loop                            ;end of i loop

        jcc     _not_exor                 ;If the thrown ls bit is set,
        eor     x0,y0                     ;  Eor the data with divisor
_not_exor

        decw    b                         ;no. of octets = no of octets -1
        jne     _start_crc                ;if no. of octets != zero,
                                          ;  jump to start_crc

        clr     a
        decw    y1
        jlt     _no_inv1
        move    #$00ff,x0
        eor     x0,a
_no_inv1

        move    #CRC_CCITT_DIVISOR,x0     ;Take CRC divisor
        ror     a                         ;Take bits from ls side
        rol     y0                        ;Put them on ls side of o/p
        
        do      #(WORD_LENGTH-1),_crc_byte_loop_1       
                                          ;for i = 1 to 15
        jcc     _no_exor_1                ;If the thrown ls bit is set,
        eor     x0,y0                     ;  Eor the data with divisor
_no_exor_1
        
        ror     a                         ;Take bits from ls side
        rol     y0                        ;Put them on ls side of o/p
        nop

_crc_byte_loop_1                          ;end of i loop

        jcc     _not_exor_1               ;If the thrown ls bit is set,
        eor     x0,y0                     ;  Eor the data with divisor
_not_exor_1

        rts

;****************************** Module ************************************
;
;  Module Name    : Crc_BitReversed
;  Author         : Minati Ku. Sahoo
;
;************************** Module Description ****************************
;
;  This module performs bit reversing .
;
;  Calls :
;        Modules : Nil 
;        Macros  : Nil 
;
;*************************** Revision History *****************************
;
;  Date         Author             Description
;  ----         ------             -----------
;  28/05/98     Minati             Created the module
;  03/07/2000   N R Prasad         Ported on to Mwtrowerks.
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;************************** Input and Output ******************************
;
;  Input  : 
;
;  1. The data byte to be bit reversed in y0
;  byte = | iiii iiii | iiii iiii |  
;
;  Output :
;
;  1. The bit reversed value in y0
;  output = | iiii iiii | iiii iiii |    
;
;****************************** Resources *********************************
;
;  Registers Used:       x0,y0
;
;  Registers Changed:    x0,y0 
;
;  Number of locations   
;    of stack used:      Nil
;
;  Number of DO Loops:   1
;
;**************************** Assembly Code *******************************

FCrc_BitReversed

        clr     x0                        ;A = 0
  
        do      #WORD_LENGTH,_crc_bit_reversed     
                                          ;for i = 0 to 15
        ror     y0                        ;get the LSB bit in carry
        rol     x0                        ;put the bit at LSB of o/p 

_crc_bit_reversed                         ;end of i loop
        
        move    x0,y0

        rts
       
        ENDSEC 

;******************************** End of File *****************************        

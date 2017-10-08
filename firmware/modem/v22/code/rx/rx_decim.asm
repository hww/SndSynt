;********************************MODULE***********************************
;
;  Macro Name     : rx_decim.asm
;  Author         : N.R.Sanjeev
;  Date of Origin : 01/08/1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;**************************MODULE DESCRIPTION*****************************
;
; This module takes the output of the demodulator and computes a low
;pass filtered version of the energies of each of the samples. The energi-
;es are stored in a buffer. The module also decimates the set of 12 inputs
;by a factor of 4 to give 3 samples as outputs per baud.
;
;************************ CALLING REQUIREMENTS****************************
;
;  None
;
;***************************INPUTS AND OUTPUTS****************************
;
; INPUT 
; 1. 12 values each of I and Q components of the output of the demodulator
;    stored in the buffer RXCB2A in alternate locations. The location
;    from where the samples are taken for decimation is pointed by 
;    x:RXCBPTR(Need not be 1st location)
;      
; 2. 12 values of the previous energy stored in a buffer PREV_ENERGY 
;    starting at the memory location pointed by x:PRV_ENPTR 
;
; OUTPUT
; 1. The decimated values are stored in the buffer RXCB from the location
;    pointed by x:RXCBIN_PTR. 6 values (3 I & 3 Q) are stored in the buffer
;    While exiting the module the pointer points to the next free memory
;    location.
;
; 2. The present 12 energy values stored in the x:memory in the buffer 
;    ENER_BUF starting at the location pointed by x:ENBUF_PTR. While 
;    exiting the module the pointer will be pointing to the next free
;    location.
;
; UPDATE
; 1. The updated previous energy buffer.
;
;****************************** RESOURCES ********************************
;
;                       Cycle Count     : 142
;                       Program Words   :  43
;                               NLOAC   :  34
;
; Address Registers used: r0,r1 and r3
;
; Offset Registers  used: n
;
; Data Registers used:
;                         a0  b0   x0   y0
;                         a1  b1        y1
;                         a2  b2      
; Registers Changed:
;                         a0  b0   x0   y0   sr   la
;                         a1  b1        y1   pc   lc
;                         a2  b2      
;
;********************************PSEUDO CODE******************************
;BEGIN
;    /*Energy computation*/
;      WR_PTR = PRV_ENPTR
;      RD_PTR = RXCBPTR
;
;      for i = 0 to 11
;         PREV_EN = *WR_PTR
;         SIGI = *RD_PTR++
;         SIGQ = *RD_PTR++
;         EN = SIGI^2 + SIGQ^2
;         ENERGY = EN/8 + PREV_EN*($7000)
;         *WR_PTR++ = ENERGY
;         *ENBUF_PTR++ = ENERGY
;      endfor
;
;   /*Decimation*/
;      RD_PTR = RXCBPTR
;      WR_PTR = RXCBIN_PTR
;  
;      for i= 0 to 2     
;         *WRPTR++ = *RDPTR++
;         *WRPTR++ = *RDPTR++
;         RDPTR = RDPTR + 7
;      endfor
;END            /*end of module*/
;********************************ENVIRONMENT******************************
; 
;            Assembler : asm56800 version 6.0.20
;            Simulator : Motorola DSP56800 simulator ver. 6.0.33
;            Machine   : SunSparc
;            OS        : SunOS 4.1.3_U1
;
;*******************************ASSEMBLY CODE***************************** 

        include "rxmdmequ.asm"

        SECTION V22B_RX 

        GLOBAL RXDECIM


        org p:

RXDECIM                                   ;
        move    x:PRV_ENPTR,r3            ;initialize r3  
        move    #RXCB2A,r1                ;initialize r0
        move    x:ENBUF_PTR,r0            ;initialize r1

        move    #ENBUF_SIZ,x0
        sub     #1,x0
        move    x0,m01                    ;r0 points at a circular buffer 
        move    #$7000,b                  ;store constant in b
        move    #0,n                      ;store 0 offset in n
                                          ;  to cheat DSP
        move    x:(r1)+,y0                ;read first I value

        do      #12,ENDLOOP               ;Start of do loop to compute 
                                          ;  the low-pass filtered 
                                          ;  energy
        mpy     y0,y0,a       x:(r1)+,y0  ;compute I^2 and fetch Q
        mac     y0,y0,a                   ;compute Q^2 and add to I^2
                                          ;  to generate E
        asr     a                         ;multiply a by 2^-1
        asr     a                         ;multiply a by 2^-1
        asr     a             x:(r3)+n,y1 ;multiply a by 2^-1 and get 
                                          ;  preven. a contains E*2^-3 
        mac     b1,y1,a       x:(r1)+,y0  ;multiply preven by $7000 
                                          ;  and add to a. Fetch I 
                                          ;  value for the next loop.
                                          ;  a contains energy.
        move    a,x:(r3)+                 ;store energy in prev_energy
        move    a,x:(r0)+                 ;store energy in enbuf

ENDLOOP
        move    r0,x:ENBUF_PTR            ; 
RX_DECM
        move    x:RXCBPTR,r3              ;Initialize r0
        move    x:RXCBIN_PTR,r0           ;Initialize r3

        move    #RXCB_SIZ,x0
        sub     #1,x0
        move    x0,m01
        move    #7,n                      ;Initialize n

        do      #3,ENDDECIM               ;Decimation loop 
        move    x:(r3)+,x0                ;Read from rxcbuf and 
                                          ;  advance r0
        move    x0,x:(r0)+                ;Store in rxcbin_buf
        move    x:(r3)+n,x0               ;Read from rxcbuf and advance r0
                                          ;  by 7 places
        move    x0,x:(r0)+                ;Store in rxcbin_buf

ENDDECIM
        move    r0,x:RXCBIN_PTR
        move    #$ffff,m01
End_RXDECIM
        jmp     rx_next_task

        ENDSEC

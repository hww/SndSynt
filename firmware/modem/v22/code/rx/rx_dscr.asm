;******************************** Module **********************************
;
;  Module Name     : rx_dscr
;  Author          : Abhay Sharma ,V.Shyam Sundar
;  Date of origin  :  1 Dec 95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
; 
;  This module descrambles the bit sequence sent by the decoder block of 
;  the receiver modedm and sends the output  to the  DTE (data  terminal 
;  equipment).This is done to get back the originally transmitted dibit. 
;
;  With ds(nT) as the input to this descrambler unit ,the output d(nT) is
;  given by the equation :
;
;       d(nT) = ds(nT) (+) ds((n-14)T) (+) ds((n-17)T)  where (+)
;       denotes the exclusive or operation.
;
;  The signal flowgraph of modem receiver descrambler is shown below :
;
;        Ds--->--->- D1 -> D2 -> ......-> D14 -> D15 -> D16 -> D17
;               |                           |                    |
;               V                           V                    |     
;        Di<---(+)<------------------------(+)--------------------
;
;  This module includes the provision to detect a sequence of 64 one's
;  at the descrambler input (Ds) and if detected , invert the next output
;  of the descrambler.                                                   
;  
;  Symbols used :
;  
;          Di       <==>  Output data sequence from the descrambler
;          Ds       <==>  Input to this unit
;          D1,..D17 <==>  Delayed versions of Ds 
;
;
;************************** Calling Requirements **************************
;  
;  1>.Following initializations in the X-memory should be done when this 
;     module is called for the first time in this modem receiver impleme-
;     ntation .Subsequent updates are done inside the module itself .
;
;     1. Two memory locations starting from #rx_dscr_buff should be initi
;        alized to zero.These two locations are used to store the 17 
;        delayed  versions of the scrambler output(Ds).
;     2. The memory location x:dscr_cntr  should be initialized to 64. 
;   
;
;*************************** Input and Output *****************************
;
;  Inputs : 
;
;    rx_data : The bit sequence to be descrambled in  x:rx_data 
;
;        For V22_1 :-
;          rx_data = | xxxx xxxx xxxx xxxb |   b ->  bit  to be descrambled
;            /* 1 bit per baud */
;
;        For V22_2 :-
;          rx_data = | xxxx xxxx xxxx xxbb |  bb ->  bits to be descrambled 
;            /* 2 bits per baud , current bit in msb,oldest in lsb */
;
;        For V22_4 :-
;          rx_data = | xxxx xxxx xxxx bbbb | bbbb -> bits to be descrambled 
;            /* 4 bits per baud , current bit in msb,oldest in lsb */
;
;        x - don't care 
;
;    rx_dscr_buff : The delayed versions of the descrambler input (Ds)
;                   in x:rx_scr_buff & x:rx_scr_buff + 1
;                  
;                   D1    : contained in x:rx_dscr_buff (lsb)
;        D2,D3 ...,D17    : contained in x:rx_dscr_buff+1
;
;        x:rx_dscr_buff+1  = | 0000 0000 0000 000 D1 |
;                           <------- 16 bits -------> 
;
;        x:rx_dscr_buff    = | D2 D3 D4 ...........D14 D15 D16 D17 |
;                           <--------------16 bits --------------->
;
; 
;
;  Outputs:
;    rx_data  in x:rx_data
;
;        For V22_1 :-
;           rx_data = | xxxx xxxx xxxx xxxb |   b ->  descrambled  bit
;            /* 1 bit per baud */
;
;        For V22_2 :-
;           rx_data = | xxxx xxxx xxxx xxbb |  bb ->  descrambled  bits
;            /* 2 bits per baud , current bit in msb,oldest in lsb */
;
;        For V22_4 :-
;           rx_data = | xxxx xxxx xxxx bbbb | bbbb -> descrambled  bits
;            /* 4 bits per baud , current bit in msb,oldest in lsb */
;
;******************************* Resources ********************************
;
;           Bits/baud                  Cycle Count
;              1                           52
;              2                           68
;              4                           97
;
;                        Program Words  :  69
;                        NLOAC          :  63
;
; Address Registers used: 
;                         r1 : to store and retrieve the delayed versions   
;                              of the descrambler  input.
;
; No. of DO loops used inside the module : 1
;
; Offset Registers used : 
;                          n : used as a data storage register
;
; Data Registers used   : a0  b0  x0  y0
;                         a1  b1         
;                         a2  b2
;                        
; Registers Changed     : a0  b0  x0  y0  r1  sr  pc  n
;                         a1  b1        
;                         a2  b0  
;
;**************************** Environment *********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;***************************** Pseudo Code ********************************
;
;       The following routine is executed once for each bit unscrambled
;
;       Begin
;         D17 = D16
;         D16 = D15
;          .     .
;          .     .               /* Update the scrambler state buffer */
;          .     .
;         D2  = D1
;         D1  = in_bit                  /* in_bit is the incoming bit */
;         out_bit = D17 ^ D14 ^ in_bit
;         if (ctr = 64)
;             ctr = 0
;             out_bit = ~outbit
;         endif
;         if(in_bit==1)
;             ctr++
;         endif
;       End  
;         
;**************************** Assembly Code *******************************

        include "gmdmequ.asm"

        SECTION V22B_RX 

        GLOBAL RXDESCR2
        GLOBAL RXDESCR4
        GLOBAL RXDESCR16
        GLOBAL rx_dscr
        GLOBAL dscr_upd

        org p:

RXDESCR2 
	move    #1,n
	move    #1,x0                     ;Get mask for 1 bit/baud
	bra     rx_dscr
RXDESCR4 
	move    #2,n
	move    #3,x0                     ;Get mask for 2 bits/baud
	bra     rx_dscr
RXDESCR16
	move    #4,n
	move    #15,x0                    ;Get mask for 4 bits/baud
rx_dscr   
    move    x0,x:dscr_mask            ;For masking output
    move    x:RXDATA,a
    move    a,x:rx_data               ;For compatibility with difdec
	move    #rx_dscr_buff,r1          ;r1 -> dscr_buff, bit 1
	move    x:rx_data,y0              ;Get the input to the descrambler
                                      ;  it can be 1,2or 4 bits
	move    x:(r1)+,a1                ;Get bit 1 of rx_dscr_buff in the
                                      ;  ls bit position of a1
	move    x:(r1)-,a0                ;Get bit - 2 to bit 17 of the
                                      ;  rx_dscr_buff into a0
                                      ;  r1 -> dscr_buff
	and     x0,y0                     ;Mask the rx_data
	move    a0,y1                     ;Save the bit 2 - bit 17 of the
                                      ;  rx_dscr_buff
	lsl     y0                        ;in_bit << 1
	or      y0,a                      ;Append with the dscr_buff for 
                                      ;  dscr_buff updation
	rep     n                         ;Update the buffer 
	asr     a                                           
	move    #3,x0                     ;Get constant to shift buffer by
                                      ;  3 bits , to align the bits
                                      ;  for xoring
	lsrr    y1,x0,b                   ;Shift buffer by three bits
	move    a1,x:(r1)+                ;Save rx_dscr_buff, 1-bit
	eor     y1,b                      ;Find   b14 ^ b17 
                                      ;       b13 ^ b16
                                      ;       b12 ^ b15       
                                      ;       b11 ^ b14
                                      ;  ^ -> xor operation
    move    x:dscr_mask,y1
    and     y1,b                      ;Mask output to contain significant
                                      ;  bits only
	lsr     y0                        
    nop               ;;;;;;;;;
	eor     y0,b                      ;Find the descrambled output
	move    a0,x:(r1)                 ;  Save bit 1 of the dscr buff
	move    x:dscr_cntr,a             ;Get the 64 1s counter
    move    x:mode_flg,y1             ;Check the operation mode
    move    #hndshk,x0
    cmp     x0,y1
	move    #64,x0                    ;Get 64 into x0 for resetting
                                      ;  the counter
    teq     x0,a                      ;Reset counter if in Handshake mode
	move    #1,y1                     ;Set invert bit to the first pos.

    do      n,dscr_upd                ;Do no. of bits/baud times
	tst     a                         ;Check if 64 ones have been
                                      ;  detected
    nop                 ;;;;;;;;;;;
	teq     x0,a                      ;Reset counter if 64 ones have
                                      ;  been detected
	beq     _invert                   ;invert the output bit
	ror     y0                        ;Get the input bit in the carry
                                      ;  bit.
	tcc     x0,a                      ;Reset counter if 0 encountered
	bcc     _continue                 ;continue
	dec     a                         ;Countdown 64 ones
	bra     _continue
_invert
	ror     y0                        ;Set for next bit
	eor     y1,b                      ;Invert current bit
_continue
	lsl     y1                        ;Shift invert bit to next posn.
	nop
	nop

dscr_upd
	move    a,x:dscr_cntr             ;Save the counter for next baud
	move    b1,x:rx_data              ;Store the output
 
End_rx_dscr
	jmp     rx_next_task
       
;**************************** Module Ends ********************************
    
    ENDSEC

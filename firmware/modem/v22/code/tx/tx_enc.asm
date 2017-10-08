;******************************* Module **********************************
;
;  Module Name          : tx_enc
;  Author               : Sanjay S. K. and  Alok N. Singh
;  Date of origin       : 28 Nov 1995
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* Module Discription ****************************
;
;  This module does encoding for v22_1 (input data rate 600bps), v22_2
;  (input data rate 1200bps) and v22bis (input data rate 2400bps).This also
;  includes the module tx_sbit for generating 2 pt training sequences.The
;  submodules for the encoding formats v22_1, v22_2 and v22bis are tx_enc1,
;  tx_enc2 and tx_enc4 respectively. The input data can be either scrambled
;  or non-scrambled.
;
;   Note :-> The quadrants are numbered as below:
;
;                                   |
;                            01     |     03
;                                   |
;                        -----------|-----------
;                                   |
;                            00     |     02
;                                   |
;
;  The submodules functions are described below.
;
;  tx_enc1 - In this module only the LS bit is encoded, i.e., the vector
;  can be in either of the two adjacent quadrants. The amplitude bits, i.e.
;  bits 3 and 2 are always forced to 10 to keep the amplitude constant.
;
;  * Note - For data formats refer to inputs and outputs column. 
;
;  tx_enc2 - In this module only the LS two bits (Dibit) are encoded,
;  i.e., the vector can be in any one of the four quadrants. The amplitude
;  bits i.e., bits 3 and 2 are forced to 10 to keep the amplitude constant.
;
;  tx_enc4 - In this module all the four bits are encoded. The LS two
;  bits indicate phase change and the MS two bits give the amplitude.
;
;  The Dibit-to-Phase Change Correspondence is given below. In each 
;  dibit LSB is the current bit.
;
;                 |-----------|------------------|
;                 |   Dibit   |    Phase Change  |
;                 |-----------|------------------|
;                 |    00     |    90 degrees    |
;                 |    01     |     0 degrees    |
;                 |    10     |   180 degrees    |
;                 |    11     |   270 degrees    |
;                 |-----------|------------------|
;
;  * Note - In this module the LS two bits of the input to the encoder
;           are in reversed order i.e., LSB is the oldest bit.
;           e.g. The dibit 01 corresponds to a phase change of 180 degrees
;
;  tx_sbit - This is for 2-pt training. The (I,Q) vector oscillates between
;            zeroth and third quadrant taking the values (-3,-1) and (3,1)
;            respectively.
;
;************************* Calling Requirements **************************
; 
;  1. The quadrant table starting from location 'tx_quad' and the (I,Q)
;     table starting from location tx_IQmap in x- memory should be 
;     initialised before calling this module. The values to be stored in 
;     these tables are given in 'Tables and Constants' column.
;
;  2. The unused bits of x:txdata should be zero.
;
;     * Note : For 2-pt training LS 4 bits (LSB) are significant.
;              For enc1 LS bit is significant.
;              For enc2 LS 2 bits are significant.
;              For enc4 LS 4 bits are significant.
;
;  3. This module uses two stack locations.
;
;  4. Any submodule can be called as a subroutine by using the instruction
;       jsr 'label'. The allowed labels are tx_sbit, tx_enc1, tx_enc2 and
;       tx_enc4.
;
;*********************** Inputs and Outputs *******************************
;
;  Input : 
;      1.  x:txdata - contains the data to be encoded. The contents of
;          this location are given below.
;
;          /* LSB is the oldest bit. */
;          * Note - 'Bit 0' refers to LSB */
;       
;          For 2-pt training :
;          x:txdata = | 0000 0000 0000 xxxx | 
;          /* The bits are updated inside the module */ 
;     
;          For enc1; input data rate - 600bps  (v22)
;          x:txdata = | 0000 0000 0000 000x |  x-> bit to be encoded 
;          
;          For enc2; input data rate - 1200bps (v22)
;          x:txdata = | 0000 0000 0000 00xx |  xx-> bits to be encoded 
;          
;          For enc4; input data rate - 2400bps (v22bis)
;          x:txdata = | 0000 0000 0000 xxxx |  xxxx-> bits to be encoded 
;
;      2.  x:txquad - Contains the previous quadrant number. The contents
;          of this location are given below
;
;          For 2-pt training :
;          x:txquad = | xxxx xxxx xxxx xxxx | 
;          /* bits are modified inside the module */
;
;          For enc1, enc2 and enc4
;          x:txquad = | 0000 0000 0000 00xx |  xx-> previous quad. number
;
;  Output : 
;      1.  x:txquad - | 0000 0000 0000 00xx |  xx-> present quadrant number
;          /* It contains the present quadrant number. */
;      2.  a1 - | xxxx 0000 0000 0000 | xxxx-> integer number in signed
;          two's complement form. ( Real part (symbol I) )
;      3.  b1 - | xxxx 0000 0000 0000 | xxxx-> integer number in signed
;          two's complement form. ( Imaginary part (symbol Q) )
;
;*********************** Tables and Constants *****************************
;
;     The memory locations starting from #tx_quad should be intialised
;     with the following values.
;
;        dc      2,0,3,1,3,2,1,0,0,1,2,3,1,3,0,2
;
;                /* These values represent the quadrant number */
;
;     The memory locations starting from #tx_IQmap should be intialised
;     with the following values.
;
;         dc      $f000,$f000,$f000,$1000
;         dc      $1000,$f000,$1000,$1000
;         dc      $f000,$d000,$d000,$1000
;         dc      $3000,$f000,$1000,$3000
;         dc      $d000,$f000,$f000,$3000
;         dc      $1000,$d000,$3000,$1000
;         dc      $d000,$d000,$d000,$3000
;         dc      $3000,$d000,$3000,$3000
;
;                 /* These values represent the I and Q levels. In each
;                    row I and Q values are stored consecutively. */
;
;     * Note : These tables are stored in the itx_enc.asm file 
;
;**************************** Pseudo code *********************************
;
;                /* For 2-pt training */
;                   Retain only the LSBit of tx_data
;                   tx_quad = 0x0001  /* This will ensure a phase shift
;                                       of 180 */
;                   go to enc1
;
;                /* For enc1 */
;                   offset =  1| 0| LSBit of tx_data| Lsbit of tx_data
;                   go to tx_encd 
;
;                /* For enc2 */
;                   offset =  1| 0| 2LSBits of tx_data
;                   go to tx_encd
;
;                /* For enc4*/
;                   offset = tx_data
;                   go to tx_encd
;
;                /* module tx_encd */
;                 
;                   tx_encd  /* Encoding module */
;
;                   offset = 2LSBits of tx_data| 2LSBits of tx_quad
;                   index = Base address of quadrant table + offset
;                   tx_quad = x:index /* contains new quadrant number */
;                   offset = bit3| bit2(of txdata)| 2LSBits of tx_quad
;                   index = Base address of IQ table + offset
;                        I = x:index
;                        Q = x:(index + 1)
;                 
;******************************* Resources ********************************
;
;                    Cycle Count   : 49
;                    Program Words : 48
;                    NLOAC         : 41
;
; Address Registers used : 
;                     r1 : Used as a pointer to Quadrant table and also
;                            as a pointer to I and Q levels table ( in
;                            linear addressing mode )
;
; Data Registers used :
;                        a0  b0  x0  y0 
;                        a1  b1
;                        a2  b2
;
; Registers Changed :  
;                        r1  a0  b0  x0  y0  sr
;                            a1  b1          pc
;                            a2  b2
;  Flags                  :
;                          None
;  Counters               :
;                          None
;  Buffers                :
;                          tx_quadtab(16L), tx_IQmap(32L)
;  Pointers               :
;                          None
;  Memory locations       :
;                          *tx_data, *tx_quad
;  Macros                 :
;                          None
;
; ** Note :  In the ' Resources ' part of the template -
;            1. 'L' refers to Linear buffer/pointer to linear buffer
;            2. '*' - memory location is any one of the first 64 locations
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;****************************** Assembly Code *****************************;

        SECTION V22B_TX 

        GLOBAL  tx_sbit
        GLOBAL  tx_enc_1
        GLOBAL  tx_enc_2
        GLOBAL  tx_enc_4

        org   p:

tx_sbit                               ;2-pt training module
	andc   #$1,x:tx_data              ;Only LS bit is retained
	move   #$1,x:tx_quad              ;01 is stored in x:tx_quad so
                                      ;  that the vector keeps on
                                      ;  oscillating between 0 and 3rd
                                      ;  quadrants with levels (+3,+1)
                                      ;  and (-3,-1) respectively

tx_enc_1                              ;This module does encoding w.r.t.
                                      ;  v22 for data rate of 600bps
	move   x:tx_data,a                ;Get the data to be encoded
	move   a,x0                       ;Save the data
	lsl    a                          ;
	add    x0,a                       ;bit1 = bit0
	move   #$08,x0                    ;Get the amplitude bits; 10
	or     x0,a                       ;Append the amplitude bits
	jmp    tx_encd                    ;Go to encoding module

tx_enc_2                              ;This module does encoding w.r.t.
                                      ;  v22 for data rate of 1200bps
	move   x:tx_data,a                ;Get the data to be encoded
	move   #$08,x0                    ;Get the amplitude bits; 10
	or     x0,a                       ;Append the amplitude bits
	jmp    tx_encd                    ;Go to encoding module

tx_enc_4                              ;This module does encoding w.r.t.
                                      ;  v22bis at data rate of 2400bps
	move   x:tx_data,a                ;Get the data to be encoded
                                      ;  and go to encoding

tx_encd                               ;Encoding module

	move   a1,y0                      ;Save the data to be encoded
	lsl    a                          ;
	lsl    a                          ;Get the phase bits in bit2 and
                                      ;  bit3 positions
	move   x:tx_quad,x0               ;Get the previous quadrant number
	or     x0,a                       ;  put in bit0 and bit1 positions
	andc   #$0f,a                     ;Mask the amplitude bits
	move   #tx_quadtab,b              ;Get the starting address of the
                                      ;  quadrant table
	add    a,b                        ;Add the offset and get the
                                      ;  address of the new quadrant
	move   #$0c,a1                    ;Get amplitude mask factor
	and    y0,a                       ;Mask the phase bits
	move   b,r1                       ;Get the quadrant address
	move   #tx_IQmap,b                ;Get the starting address of
                                      ;  I Q table.
	move   x:(r1)+,y1                 ;Get the new quadrant in y1
	or     y1,a                       ;
	move   y1,x:tx_quad               ;Store the recent quadrant
	asl    a                          ;Get the offset for I Q table
	add    b,a                        ;Get the actual address of I
	move   a,r1                       ;  in r1
	nop
    move   x:(r1)+,a1                 ;Get the I level
    move   x:(r1)+,b1                 ;Get the Q level
    move   a1,x:Ival                  ;Store for test purpose only
    move   b1,x:Qval
    jmp    next_task                  ;Return to the calling routine

;*************************** End of Module *********************************

    ENDSEC

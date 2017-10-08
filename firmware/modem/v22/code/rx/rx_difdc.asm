;********************************* MODULE **********************************
;
;  Module Name     : rx_difdc        
;  Author          : N.R. Sanjeev
;  Date of Origin  : 01/03/1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;***************************MODULE DESCRIPTION*****************************
;
; This module takes inputs from the equaliser and determines the hard 
; decision points in the signal constellation. The corresponding absolute 
; data bits are also generated. The absolute data bits are then used to 
; decode the differentially encoded data bits by making use of the previous
; quadrant values.
;
;**************************CALLING REQUIREMENTS****************************
;
;The inputs to this module EQX and EQY should be in the following format
;                 | ssss. ffff | ffff ffff |
;
;***********************INPUTS, OUTPUTS AND UPDATES ***********************
;
; INPUT
;   1. Equalizer filter soft decisions stored in x:EQX and x:EQY in the 
;      following format:
;           EQX = | ssss. ffff | ffff ffff |
;           EQY = | ssss. ffff | ffff ffff |
;
; OUTPUT
;   1. Hard decisions about the constellation points stored in x:DECX and 
;      x:DECY in the following format:
;          DECX = | ssss. ffff | ffff ffff |
;          DECY = | ssss. ffff | ffff ffff |
;
;   2. The received absolute data bits stored in x:RXDATA stored in the 
;      followhing format:
;          RXDATA = | 0000 0000 | 0000 xxxx | 
;
; UPDATE
;   1. x:RXODAT in the following format:
;          RXODAT = | 0000 0000 | 0000 00xx |
;
;***************************TABLES AND CONSTANTS***************************
;
; constants         cost = cos(26.56degrees)
;                   sint = cos(26.56degrees)
; tables 
;       tx_IQmap    contains the constellation points corresponding to 
;                   bit patterns
;       tx_quadtab  helps in computing the change in quadrants
;       rx_absdat   gives the actual bit pattern received  
;
;******************************RESOURCES USED******************************
;
;       Program Words           120
;               NLOAC            89
;       Worst Case Cycle Count   70
;
;       Address Registers Used  r0
;
;          Data Registers Used  a0   b0   x0   y0
;                               a1   b1        y1
;                               a2   b2    
;
;            Registers Changed 
;                               a0   b0   x0   y0   r0  sr   pc
;                               a1   b1        y1
;                               a2   b2
;    
;*******************************ENVIRONMENT********************************
;
;       Machine                 SunSparc
;       OS                      SunOS 4.1.3_U1
;       Assembler               Motorola DSP56800 Assembler Ver 5.3.3.60
;       Simulator               Motorola DSP56800 Simulator Ver 6.0.33
;
;*******************************PSEUDO CODE********************************
;
;      begin
;       case:1.2kbps
;                 equalizer_output = eqx + j*eqy
;                 all bits of rxdata = 0
;                 rot_equalizer_output = (equalizer_output)*exp(j*26.56deg)
;                 if (Re(rot_equalizer_output)>0)
;                     bit 2 of rxdata = 1 
;                 endif
;                 if (Im(rot_equalizer_output)>0)
;                     bit 1 of rxdata = 1
;                 endif
;
;                 break
;
;       case:2.4kbps
;                 temp1 = eqx 
;                 temp1 = temp1 asr'ed by 2 bits
;                 temp2 = eqy
;                 temp1 = temp1&&$0600
;                 temp2 = temp2&&$1800
;                 temp1 = temp1+temp2
;                 temp2 = temp1 asr'ed by 9 bits
;                 temp2 = *(absdata+temp2)
;                 rxdata = temp2       
;                 temp2 = temp2 asl'ed by 1 bit
;                 temp2 = (tx_IQmap+temp2)
;                 temp1 = temp2++
;                 temp2 = *(temp2)
;                 temp1 = *(temp1)       
;                 decx = temp2 asr'ed by 2 bits
;                 decy = temp1 asr'ed by 2 bits
;                 break
;          
;       temp1 = rxdata lsl'ed by 2 bits
;       temp1 = rxodat or'ed with temp1
;       temp1 = temp1&&$000f
;      rxodat = rxdata&&$0003       
;       temp1 = temp1+tx_quadtab
;       temp3 = *(temp1)
;       temp1 = rxdata&&$000c
;      rxdata = temp3 or'ed with temp1
;
;******************************ASSEMBLY CODE*******************************

        include "rxmdmequ.asm"

        SECTION V22B_RX 

        GLOBAL RXDEC4
        GLOBAL DECA
        GLOBAL DECB
        GLOBAL RXDEC16
        GLOBAL RXDIFDEC
        GLOBAL RXNODEC

        org p:
 
RXDEC4  clr      b                        ;The default value of the 
                                          ;  decoded bits is stored in 
                                          ;  register b
        move     #cost,x0                 ;cos(26.56) is stored in x0
        move     #sint,y0                 ;sin(26.56) is stored in y0
        move     x:EQX,y1                 ;The rotated x value is 
                                          ;  computed
        nop
        mpy      x0,y1,a                  ;
        move     x:EQY,y1                 ;
        macr     -y1,y0,a                 ;
        jle      DECA                     ;If the computed value of 
                                          ;  xrot is negative branch to
                                          ;  DECA without perturbing b
        move     #$0002,b1                ;If the value is negative set 
                                          ;  2nd LSB of b1 high.

DECA
        mpy      y1,x0,a                  ;The rotated value yrot is 
                                          ;  computed
        move     x:EQX,y1                 ;
        macr     y1,y0,a                  ;
        jle      DECB                     ;If the computed value of 
                                          ;  yrot is negative branch to
                                          ;  DECB without perturbing b
        move     #>1,x0                   ;If the value of a is negative
        or       x0,b                     ;  set LSB of b1 high.


DECB
        move     b1,x:RXDATA              ;Store b1 as received data
        lsl      b                        ;Left shift b to enable 
                                          ;  vectoring to two locations
                                          ;   in v32map
        move     #tx_IQmap,x0
        add      #16,x0                   ;Load the relevant address
                                          ;  in the tx_IQmap as the  
                                          ;  base address
        add     x0,b                      ;Compute the absolute location
        move    b1,r0                     ;  in tx_IQmap 
        nop                               ;Nop to satisfy processor
                                          ;  constraints
        move    x:(r0)+,a                 ;Transfer I value to a
        asr     a                         ;Scaling down a appropriately 
        asr     a            
        move    x:(r0)+,b                 ;Finish scaling down a and 
                                          ;  read q value to b.
        move    a,x:DECX                  ;Store contents of a in decoded
                                          ;  I location
        asr     b                         ;Scale down b appropriately 
        asr     b                         ;  and move the contents to the
        move    b,x:DECY                  ;  decoded Q location
End_RXDEC4       
        jmp     rx_next_task

RXDEC16
        move    x:EQX,b                   ;read eqx value into b
        asr     b                         ;  and scale it down so that 
                                          ;  the info bits are in 
        asr     b                         ;  locations 9 and 8
        move    x:EQY,a                   ;read eqy value into a
        andc    #$1800,a                  ;strip off bits 12 and 11
                                          ;  from a
        andc    #$0600,b                  ;strip off bits 10 and  9
                                          ;  from b
        add     a,b                       ;concatenate stripped off bits 
                                          ;  to form location of the point 
                                          ;  in the signal constellation
        move    b1,x0                     ;x0 contains the location 
        move    #$0040,y0                 ;loading a constant which would
                                          ;  help in lsr'ing x0
        mpy     x0,y0,a                   ;lsr'ing x0 by 9 positions
        move    #absdat,y0                ;loading the origin of the 
                                          ;  absdata table 
        add     y0,a                      ;calculating the location 
                                          ;  corresponding to the present
                                          ;  point and moving it into
        move    a1,r0                     ;  the address register r0 
        nop                               ;  from the absdata table 
        move    x:(r0)+,a                 ;read the absolute data bits 
        move    a,x:RXDATA                ;store the absolute data bits 
                                          ;  in memory 
        asl     a                         ;left shift a to facilitate
                                          ;  computing two memory
                                          ;  locations
        move    #tx_IQmap,b               ;load tx_IQmap base address
                                          ;  in b
        add     b,a                       ;compute the address of the 
                                          ;  value corresponding to the
                                          ;  current
        move    a1,r0                     ;  absolute data bits
        nop
        move    x:(r0)+,a                 ;retrieve the I value from
                                          ;  memory
        asr     a                         ;scale I appropriately
        asr     a          
        move    x:(r0)+,b                 ;retrieve the Q value from 
        asr     b                         ;  memory and scale it down
        asr     b                         ;  appropriately
        move    a,x:DECX                  ;store I value in memory
        move    b,x:DECY                  ;store Q value in memory
End_RXDEC16
        jmp     rx_next_task

RXDIFDEC
        move    x:RXDATA,a                ;read the absolute bits to a
        lsl     a                         ;last two positions in a are
        lsl     a                         ;  vacated
        move    x:RXODAT,x0               ;old data is read into x0
        or      x0,a                      ;it is concatenated with a
        andc    #$000f,a                  ;preserve only the last four bits
                                          ;  in a
        add     #tx_quadtab,a             ;add the contents of a to the
                                          ;  base address of tx_quadtab
                                          ;  to produce the correct address
        move    x:RXDATA,b                ;read the absolute bits 
        andc    #0003,b                   ;strip off quadrant number from b
        move    a1,r0                     ;load the address of the quadrant
                                          ;  number in r0
        move    x:RXDATA,a                ;
        andc    #$000c,a                  ;strip off the amplitude bits
        move    b,x:RXODAT               
        move    x:(r0)+,x0                ;read the precise phase bits
        or      x0,a                      ;append them to a
        move    a,x:RXDATA                ;store the decoded data in memory
        jmp     rx_next_task

;This routine saves the coded bits which will be
;used in the diferential decoder.

RX_NODEC
        move    x:RXDATA,x0
        andc    #0003,x0
        move    x0,x:RXDATA
End_RXDIFDEC
        jmp     rx_next_task

        ENDSEC

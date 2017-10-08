;******************************** Module **********************************
;
;  Module name     : tx_scr
;  Module Author   : Abhay Sharma & Shyam Sundar
;  Date of origin  : 30 Nov 95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
; 
;  This module scrambles the input bit sequence sent by the DTE (data
;  terminal equipment)  to the  encoder of the calling modem.
;  With d(nT) as the input to this scrambler unit , the output ds(nT) is
;  given by the equation :
;
;        ds(nT) = d(nT) (+) ds((n-14)T) (+) ds((n-17)T)
;
;  where (+) denotes the exclusive or operation.
;
;  The signal flowgraph of modem transmitter scrambler is shown below :
;
;        Ds<-------->D1 -> D2 -> ......-> D14 -> D15 -> D16 -> D17
;               ^                           |                    |
;               |                           V                    |     
;        Di--->(+)<------------------------(+)<-------------------
;
;  This module includes the provision to detect a sequence of 64 one's
;  at the scrambler output (Ds) and if detected , invert the next input 
;  to the scrambler and reset the counter.Inverting the input is equivalent 
;  to inverting the output before it is sent out of the scrambler unit.But
;  this provision starts functioning when the handshake mode is complete.
;  
;  Symbols used :
;  
;          Di       <=>  Input data sequence from DTE
;          Ds       <=>  Scrambled bits , the output of this unit
;          D1,..D17 <=>  Delayed versions of Ds 
;
;************************** Calling Requirements **************************
;  
;  1. The following memory locations must be defined and initialized in the
;     X memory.
;
;  (i)   tx_data     : The input and output point of the module
;  (ii)  tx_scr_buff : The 2 word buffer of scrambler states maintained by
;                      this module must be initialized to zero before the
;                      first call to this module. 
;  (iii) tx_scr_ctr  : The count of the number of ones appearing in the
;                      output of the scrambler maintained by this module
;                      must be initialized to 65 before the first call to
;                      this module.
;  (iv)  mode_flg    : The mode of operation of the modem (viz : hndshk
;                      or datamd must be appropriately set.) 
;
;  Note : The locations tx_scr_buff and tx_scr_ctr should not be disturbed
;         in between calls to this module. They should be initialized only
;         once before the first call to this module.
;   
;*************************** Input and Output *****************************
;
;  Inputs : 
;       tx_data = | 0000 0000 | 0000 xxxx | in x:tx_data
;  Outputs:
;       tx_data = | 0000 0000 | 0000 xxxx | in x:tx_data(scrambled data)
;
;  Note : tx_data has 1, 2 or 4 significant bits corresponding to the
;         type of scrambling desired. By executing the module from the
;         appropriate locations described in the documentation column
;         in the code portion of the module, the desired scrambling mode
;         may be entered
;
;******************************* Resources ********************************
;
;                        Cycle Count   :
;                        Program Words :
;                        NLOAC         :
;
; Address Registers used: 
;                         r1 : to point to tx_scr_buff   
;
; No. of do loops inside the module : 1
;
; No. of software stack locations used : None
;
; Offset Registers used : 
;                          n : used as a data storage register
;
; Data Registers used   : a0  b0  x0  y0
;                         a1  b1      y1   
;                         a2  b2
;                        
;
; Registers Changed     : a0  b0  x0  y0  r1  sr  pc  n
;                         a1  b1      y1  
;                         a2  b0  
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;***************************** Pseudo Code ********************************
;
;       begin
;          /* Scramble the input */
;          out_bit = D17 ^ D14 ^ in_bit
;          if ( cntr == 64 )
;             out_bit = ~out_bit
;             cntr = 0
;          endif
;          if ( out_bit == 1 )
;             cntr ++ 
;          else    
;             cntr = 0
;          endif
;          /* Update the buffer */
;          buff = buff >> 1
;          D1 or buff[0] = outbit
;       end     
;         
;**************************** Assembly Code ******************************

        include "gmdmequ.asm"

        SECTION V22B_TX 

        GLOBAL tx_scr
        GLOBAL tx_scr_1
        GLOBAL tx_scr_2
        GLOBAL tx_scr_4

        org p:

tx_scr_1                                  ;Location to start execution for
        move    #1,n                      ;  1 bit scrambling mode
        move    #1,b                      ;Mask to extract the input bit
        bra     tx_scr
tx_scr_2                                  ;Location to start execution for
        move    #2,n                      ;  2 bits scrambling mode
        move    #3,b                      ;Mask to extract input bits
        bra     tx_scr
tx_scr_4                                  ;Location to start execution for
        move    #4,n                      ;  4 bits scrambling mode
        move    #15,b                     ;Mask for 4 bits/baud
tx_scr                                    ;THE SCRAMBLER ROUTINE
        move    x:tx_data,x0              ;Get the input bits to be 
                                          ;  scrambled
        move    #tx_scr_buf,r1            ;r1 -> scr_buff ,D2 to D17
        move    #3,y0                     ;Get constant to shift buffer by
                                          ;  3 bits , to align the bits
                                          ;  for xoring
        clr     a      x:(r1)+,y1         ;Get the D2 - D17  
                                          ;  D1 is in tx_scr_buff + 1
                                          ;  r1 -> scr_buff + 1
        asrr    y1,y0,y0                  ;Shift buffer by three bits 
        nop
        eor     y1,y0                     ;Find   b14 ^ b17 
                                          ;       b13 ^ b16
                                          ;       b12 ^ b15       
                                          ;       b11 ^ b14
                                          ;  ^ -> xor operation
        eor     y0,x0                     ;Find the scrambled output
        and     b1,x0                     ;Mask the tx_data
        move    x:(r1)-,a1                ;Get  first bit of the scr_buff
                                          ;  into lsb of accumulator a
                                          ;  r1 -> scr_buff
        move    y1,a0                     ;Get the 2 - 17 buffer bits 
                                          ;  into LSP  
        lsl     x0                        ;Scrambled op << 1
        or      x0,a                      ;Append with the scr_buff for 
                                          ;  scr_buff updation
        move    x:tx_scr_ctr,b            ;Get the counter into b, this
                                          ;  counter keeps track of the
                                          ;  no.  of consecutive ones 
                                          ;  Initial value should be 65
        move    x:mode_flg,x0
        move    #hndshk,y0
        cmp     y0,x0
        move    #65,y0                    ;Get 65 into y0 for resetting
                                          ;  the counter if zero is 
                                          ;  detected
        teq     y0,b                      ;If handshake reset counter or
                                          ;  in a way disable the logic
                                          ;  to detect 64 consecutive ones

        do      n,scr_upd                 ;Do ( no. of bits/baud) times
        asr     a                         ;Push the output bit into the
                                          ;  the scrambler stater buffer
                                          ;  the D1 position
        dec     b                         ;Decreament the conter. This will
                                          ;  also set the flags.If the 
                                          ;  counter is zero then it means
                                          ;  that 64 consecutive ones have
                                          ;  been detected.
        bne     _not_invert
        bfchg   #$0001,a1                 ;Invert the scrambled bit if
                                          ;  64 consecutive one's are
                                          ;  detected.               
        tfr     y0,b                      ;Reset the counter 
_not_invert
        bftstl  #$0001,a1                 ;Check the scrambled output
                                          ;  if the output bit is zero
                                          ;  reset the counter
        tcs     y0,b                      ;Reset the counter if a zero 
                                          ;  is detected

scr_upd
        move    a0,x:(r1)+                ;Save the updated scr_buff
        move    a1,x:(r1)-                ;  bits 2 - 17 & first bit      
        asr     a
        move    b,x:tx_scr_ctr            ;Save the counter for next baud
        rep     n                         ;Get the baud output
        asl     a                         ;  in x:tx_scr_out
        move    a1,x:tx_data              ;Save the output
end_tx_scr
                                          ;Comment if not in use
        jmp     next_task

;**************************** Module Ends *********************************

        ENDSEC

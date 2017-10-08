;******************************* Module **********************************
;
;  Module Name          : rx_int
;  Author               : Sanjay S. K.  
;  Date of origin       : 05 Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* Module Description ****************************
;
;  This module performs the FIR filtering for the Interpolation. The 12
;  filter coefficients are from the 64 filter banks. The A/D converter
;  samples are stored in a buffer of length 34 after DCTAP adjustment. 
;  The 12 output samples are stored in a buffer.
;
;             Symbols used :
;                   IBPTR  : A memory location which holds the current
;                            pointer to the input buffer
;                   RDPTR  : Holds the address of the current sample to
;                            be fetched from the input buffer
;                   temp   : Scratch location
;                   WR_PTR : Pointer to the output buffer
;                   RXSB   : Starting location of the output buffer
;                   FPTR   : Pointer to the filter coefficient buffer
;                   ICOEFF : Starting location of the filter coefficient
;                          : buffer
;
;************************* Calling Requirements **************************
; 
;  1. The memory location x:IBPTR should be loaded with the appropriate
;     address to the input modulo buffer of length 34. These 34 locations 
;     should be cleared when this module is called for the first time.  
;
;  2. The input buffer should be loaded with 12 samples of A/D starting
;     from location held by x:IBPTR and then x:IBPTR should be loaded with
;     (x:IBPTR + 12) mod34.
;
;  3. 12 interpolation filter coefficients should be stored consecutively
;     in a buffer starting from location ICOEFF. These coefficients are
;     selected from 64 banks of 12 coefficients each.
;
;  4. An output buffer of length 12 should be provided starting at RXSB
;
;  NOTE :
;     This module has one do loop, hence the calling module should take 
;     care of stack initializations and saving of la and lc registers
;
;  /* The file init_mdm contains all initializations for this module */
;
;*********************** Inputs and Outputs *******************************
;
;  Input  :
;         1. 12 A/D samples from location pointed by x:IBPTR
;         2. 12 filter coefficients in a buffer starting from ICOEFF
;
;  Output : 
;            12 samples of
;            RXSB(n) = | siii iiii | iiii iiii |   starting at RXSB 
;                                                  n = 0, 1, ... , 11
;
;*********************** Tables and Constants *****************************
;
;          Coefs(n)  = | siii iiii | iiii iiii |   starting at ICOEFF 
;                                                  n = 0, 1, ... , 11
;
;******************************* Resources ********************************
;
;                    Cycle Count   : 279
;                    Program Words : 25
;                    NLOAC         : 21
;
; Modifier register used : 
;                    m01 : For modulo addressing of r0
;
; Address Registers used : 
;                     r0 : Used as a pointer to Input buffer in modulo
;                          34 addressing mode.
;                     r2 : Used as a pointer to the output buffer of
;                          length 12 in linear addressing mode.
;                     r3 : Used as a pointer to Filter coefficient
;                          buffer of length 12 in linear addressing
;                          mode.
;                     n  : used as an offset register to Input buffer
;
; Data Registers used    :
;                         a0  x0  y0
;                         a1      y1
;                         a2  
;
; Registers Changed      :  
;                         r0  a0  x0  y0  sr  n
;                         r2  a1      y1  pc
;                         r3  a2
;
;**************************** Pseudo code *********************************
;
;         Begin
;             temp   = IBPTR - 23     /* Pointer to the input buffer */
;             WRPTR  = RXSB           /* Pointer to the output buffer */
;             for i = 0 to 11
;                 FPTR = ICOEFF       /* Pointer to the filter coeff.
;                 RDPTR = temp++         buffer */
;                 sum = 0
;                 for j = 0 to 11
;                      sum = sum + ( *RD_PTR++) * ( *FPTR++)
;                 endfor
;                 *WR_PTR++ = sum
;             endfor
;         END
;                          
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;****************************** Assembly Code *****************************

        include "rxmdmequ.asm"

        SECTION V22B_RX 


        GLOBAL  RXINTP

        org p:

RXINTP
        move    #IBSIZ,x0
        sub     #1,x0
        move    x0,m01                    ;R0 is used in mod 34 addressing

        move    x:IBPTR,r0                ;Load pointer to Input buffer
        move    #-23,n                    ;Load offset to Input buffer
        move    #RXSB,r2                  ;WR_PTR = RXSB ; pointer to the 
                                          ;  output buffer
                                          ;  to get the first sample
        lea     (r0)+n                    ;RD_PTR = IBPTR - 23.
        move    r0,y1                     ;temp = RD_PTR
        do      #12,end_rx_int            ;Repeat 12 times
        move    y1,r0                     ;Get RD_PTR
        incw    y1                        ;temp = RD_PTR+1
        move    #ICOEFF,r3                ;Get the pointer to the filter
                                          ;  coefficient buffer
                                          ;  FPTR = ICOEFF
        clr     a                         ;sum = 0
        move    x:(r0)+,y0   x:(r3)+,x0   ;y0 = *temp, x0 = *FPTR
        rep     #11                       ;Repeat 11 times
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
                                          ;sum = sum + (*RD_PTR++)*(*FPTR++)
        macr    x0,y0,a                   ;Get the sum in a1
        move    a,x:(r2)+                 ;*WR_PTR++ = sum
end_rx_int
End_RXINTP
        move    #-1,m01
        jmp     rx_next_task              ;Go to next task

        ENDSEC

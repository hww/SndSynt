;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    dfr16Cbitrev.asm
;
; Description:  Assembly module for Bit Reverse
;
; Modules
;    Included:  Fdfr16Cbitrev
;
; Author(s):    Sandeep S
;
; Date:         18 Jan 2001
;
;********************************************************************        

        SECTION rtlib
    
		include "portasm.h"

		
		GLOBAL  Fdfr16Cbitrev

;********************************************************************
;
; Module Name:  Fdfr16Cbitrev
;
; Description:  Bit Reverses the Input Array
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: 1. r2 -> Pointer to Input Buffer.
;               2. r3 -> Pointer to Output Buffer.
;               3. y0 -> Length of the input/output buffer
;
; C Callable:   Yes
;
; Reentrant:    Yes
;
; Globals:      None
;
; Statics:      None
;
; Registers 
;      Changed: All
;
; DO loops:     1
;
; REP loops:    None
;
; Environment:  MetroWerks on PC
;
; Special
;     Issues:   This code uses big-endian convention. But MW compiler
;               uses little-endian convention. Hence all variables
;               should not be altered in C.
;
;******************************Change History************************
;
;    DD/MM/YY     Code Ver     Description      Author(s)
;    --------     --------     -----------      ------
;    18/01/2001   0.1          Module created   Sandeep S
;    18/01/2001   1.0          Baselined        Sandeep S
;
;********************************************************************		
				
Fdfr16Cbitrev

    lea    (sp)+
    move   r3,x:(sp)          ;Store output pointer
    move   y0,a               ;Buffer size 
    move   r2,r1 
    lsr    a                  ;Half the number of points
    clr    b                  ;Bit reverse index
    dec    y0
    clr    x0                 ;Normal index
    move   r2,a0              ;Store input buf pointer 

    do     y0,_end_loop   
    move   x:(sp),r0
    cmp    x0,b    x:(r2)+,y0 ;Compare if the bitrev index is
                              ; larger than the present index
                              ; real part of normal index
    blt    _elsepart
    asl    b                  ;Shift left to take care of real-imag
                              ; addressing
    move   b,n                ; move the bitrev index to n
    lea    (r0)+n             ;output buffer bit rev address for  
                              ; storing swapped data
    lea    (r1)+n             ;input buffer bit rev address for
                              ; reading the data
    move   x:(r1)+,y1         ;Real data at Bit rev address
    move   y0,x:(r0)+         ;store real data at the bit rev address  
    move   y1,x:(r3)+         ;store real data from bit rev address
                              ; to normal index
    move   x:(r2),y0         ;imag data from normal indexing 
    move   x:(r1)+,y1         ;imag data from bit rev index
    asr    b     y0,x:(r0)+         ; store at the bit rev address
    move   y1,x:(r3)-        ; store at norm address (imag)

_elsepart
    lea    (r3)+
    
_nextindice

    ;----------------------------------
    ; Getting the next bit rev index
    ;----------------------------------    
    
    move   a1,y0
    cmp    y0,b    x:(r3)+,y1 ;Is bit rev index >= N/2 ? no, jump
                              ;  dummy move to inc. the pointer
    blt    _skip_change   
_chk_again    
    sub    y0,b               ; bitrev index -=N
    asr    y0                 ; N /= 2
    cmp    b1,y0                    
    ble    _chk_again         ; Is bit rev index >= N/2 ? yes, jump 
_skip_change
    add    y0,b    x:(r2)+,y1 ; bitrev index += N, dummy move
    incw   x0                 ; increment normal index
    move   a0,r1
_end_loop 

    lea    (sp)-              ;Restore SP before rts
    move   x:(r2)+,y0         ;Copy last real imag pair from
    move   x:(r2)+,y1         ; input buffer to the output buffer
    move   y0,x:(r3)+
    move   y1,x:(r3)+    
    
    rts
    
    
    ENDSEC       
    
    
    
    

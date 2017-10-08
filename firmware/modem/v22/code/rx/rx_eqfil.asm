;*******************************rx_eqfil***************************************
;
; Module name    : rx_eqfil
; Module authors : V. Ch. Venkaiah
; Date of Origin : 3rd Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;***************************Module description*********************************
;
; This module performs 15 point FIR filtering on I and Q channel signals for
; 2T/3 complex equalisation. It also rotates the output with JITTER angle.
;
;**************************Calling Requirements*******************************
;1.  This module has one do loop, hence the calling module should take care
;    of stack initializations and saving of la and lc registers.
;
;************************Inputs and Outputs*********************************
;
; READ:
;  1. Three sets of I and Q samples from the buffer RXCB, from the location
;     pointed by RXCBOUT_PTR. The pointer is incremented each time when a sample
;     is read.RXCB is a circular buffer of length 30.
;  2. EQRT buffer which contain equaliser filter's real coefficients.
;     It's a linear buffer of 15 long.
;  3. EQIT buffer which contain equaliser filter's imaginary coefficients.
;     It's a linear buffer of 15 long.
;  4. JITTER which is the phase angle by which the output of the equaliser
;     filter should be rotated.
;  5. SIN_TBL which contains 256 sampled values of sine wave of one period. 
;  
;       All the above values except pointers are stored in 
;            | s.fff ffff ffff ffff | format.
;
; Update:
; 1. EQRSB will be loaded with 3 more new I samples and at the end,x:EQRBIN
;    points to the next free location.It's a circular buffer of length 30.
;    The pointer will be decremented each time a sample is loaded.
; 2. EQISB will be loaded with 3 more new Q samples and at the end, x:EQIBIN
;    points to the next free location.It's a circular buffer of length 30.
;    The pointer will be decremented each time a sample is loaded.
;
;       All the above values except pointers are stored in 
;            | s.fff ffff ffff ffff | format.
;
; Output:
; 1. EQX, real part of the output of equaliser filter.
; 2. EQY, imaginary part of the output of equaliser filter.
;    in | s.sss ffff ffff ffff | format.
;
;***********************Tables and Constants********************************
;
; 1.  256 value sine table , SIN_TBL
;
;*****************************Resources*************************************
;
;               Cycle count   : 160
;               Program words : 112
;               NLOAC         : 85
;
; Modifier register used :
;                   m01  : For modulo addressing of r0 and r1
;
; Address registers used : 
;                   r0   : Used as a pointer to input buffer pointed by
;                          x:RXCBOUT_PTR 
;                   r1   : Used as a pointer to the buffers pointed by
;                          x:EQRBIN, x:EQIBIN, and the SIN_TBL
;                   r3   : Used as a pointer to the buffers EQRT and EQIT
;                   n    : Used as an offset register for the buffers
;                          pointed by x:RXCBOUT_PTR, x:EQRBIN, x:EQIBIN,
;                          and the SIN_TBL
;
; Data registers used    :
;                   a0   b0   x0   y0
;                   a1   b1        y1
;                   a2   b2
;
; Registers changed      : 
;                   a0   b0   x0   y0   m01   n   r0   sr
;                   a1   b1        y1             r1   pc
;                   a2   b2                       r3 
;
;*****************************Pseudo code*************************************
;
;         Begin
;           for i = 0 to 2
;               *EQRBIN-- = *RXCBOUT_PTR++
;               *EQIBIN-- = *RXCBOUT_PTR++
;           endfor
;           sum = 0
;           for i = 0 to 14
;               sum = sum + (*EQRT++)*(*EQRBIN)
;               EQRBIN = EQRBIN - 2
;           endfor
;           for i = 0 to 14
;               sum = sum - (*EQIT++)*(*EQIBIN)
;               EQIBIN = EQIBIN -2
;           endfor
;           EQX = sum
;           sum = 0
;           for i = 0 to 14
;               sum = sum + (*EQRT++)*(*EQIBIN)
;               EQIBIN = EQIBIN - 2
;           endfor
;           for i = 0 to 14
;               sum = sum + (*EQIT++)*(*EQRBIN)
;               EQRBIN = EQRBIN -2
;           endfor
;           EQY = sum
;           offset = ( 2*JITTER ) > 11 + $0080
;           sin = SIN_TBL(offset)
;           cos = SIN_TBL(offset+$0040)
;           EQX = -EQX*cos+EQY*sin
;           EQY = -EQX*sin-EQY*cos
;           Limit EQX and EQY between $f000 to $0fff 
;         end
;
;*****************************Environment***********************************
;
;         Assembler  : ASM56800 version 5.3.3.60
;         Machine    : SUN SPARC
;         OS         : SUN OS
;
;*************************Assembly code*************************************

        SECTION V22B_RX 


        GLOBAL  RXEQFIL

        org p:

RXEQFIL
         move     #$801d,m01                     ;Make r0 and r1 point to
                                                 ;  modulo buffers of size 30
         move     #2,n                           ;To extract the I samples
                                                 ;  which are stored in 
                                                 ;  alternate locations of the
                                                 ;  buffer pointed by
                                                 ;  RXCBOUT_PTR
         move     x:RXCBOUT_PTR,r0               ;Get the address of the buffer
                                                 ;  in which the samples are
                                                 ;  stored
         move     x:EQRBIN,r1                    ;Get the address of the buffer
                                                 ;  in which I samples need to
                                                 ;  be stored
         do       #3,rx_eqfil_l1                 ;Transfer the 3 I samples
         move     x:(r0)+n,y0
         move     y0,x:(r1)-
rx_eqfil_l1
         move     r1,x:EQRBIN                    ;Store the updated I samples
                                                 ;  buffer pointer

         move     x:RXCBOUT_PTR,r0               ;Get the address of the buffer
                                                 ;  in which the samples are
                                                 ;  stored
         move     x:EQIBIN,r1                    ;Get the address of the buffer
                                                 ;  in which Q samples need to
                                                 ;  be stored

         lea      (r0)+                          ;Q sample starts from the next
                                                 ;  location
         do       #3,rx_eqfil_l2                 ;Transfer the 3 Q samples
         move     x:(r0)+n,y0
         move     y0,x:(r1)-
rx_eqfil_l2
         move     r1,x:EQIBIN                    ;Store the updated Q samples
                                                 ;  buffer pointer

         move     x:EQRBIN,r1                    ;Get the address of the buffer
                                                 ;  in which I samples are 
                                                 ;  stored
         move     #-2,n                          ;Offset required to compute
                                                 ;  the filter output using
                                                 ;  alternate samples
         move     #EQRT,r3                       ;Get the pointer to the buffer
                                                 ;  in which real taps of the
                                                 ;  adaptive fractionally 
                                                 ;  spaced equaliser is stored
         clr      a                x:(r1)+n,y0   ;Set sum=0 and get the I 
                                                 ;  sample               
         move     x:(r3)+,x0                     ;Get the real part of filter 
                                                 ;  tap
         rep      #15                            ;Compute the sum
         mac      x0,y0,a          x:(r1)+n,y0    x:(r3)+,x0
         move     #EQIT,r3                       ;Get the pointer to the buffer
                                                 ;  in which imaginary part of
                                                 ;  the taps of the adaptive
                                                 ;  fractionally spaced 
                                                 ;  equaliser is stored 
         move     x:EQIBIN,r1                    ;Get the address of the buffer
                                                 ;  in which Q samples are
                                                 ;  stored.
         move     x:(r3)+,x0                     ;Get the imaginary part of the
                                                 ;  filter tap
         move     x:(r1)+n,y0                    ;Get the Q sample

         neg      a
         rep      #15                            ;Compute the sum
         mac      x0,y0,a          x:(r1)+n,y0    x:(r3)+,x0
         neg      a
         move     a,x:EQX                        ;Set EQX=sum

         move     #EQRT,r3                       ;Get the pointer to the buffer
                                                 ;  in which real part of the
                                                 ;  taps of the adaptive
                                                 ;  fractionally spaced 
                                                 ;  equaliser is stored
         move     x:EQIBIN,r1                    ;Get the address of the buffer
                                                 ;  in which Q samples are
                                                 ;  stored.
         move     x:(r3)+,x0                     ;Get the real part of the
                                                 ;  filter tap
         clr      a                 x:(r1)+n,y0  ;Set sum=0 and get Q sample
         rep      #15                            ;Compute the sum
         mac      x0,y0,a           x:(r1)+n,y0       x:(r3)+,x0
         move     #EQIT,r3                       ;Get the pointer to the buffer
                                                 ;  in which imaginary part of 
                                                 ;  the taps of the adaptive
                                                 ;  fractionally spaced 
                                                 ;  equaliser is stored
         move     x:EQRBIN,r1                    ;Get the address of the buffer
                                                 ;  in which I samples are 
                                                 ;  stored
         move     x:(r3)+,x0                     ;Get the imaginary part of the
                                                 ;  filter tap
         move     x:(r1)+n,y0                    ;Get I sample
         rep      #15                            ;Compute the sum
         mac      x0,y0,a           x:(r1)+n,y0   x:(r3)+,x0
         move     a,x:EQY                        ;Set EQY=sum

         move     #-1,m01                        ;Reset m01 to $ffff so that
                                                 ;  r0 and r1 will NO longer
                                                 ;  point to modulo buffers
         move     x:EQY,a                        ;y0 contains EQY
         move     x:EQX,b                        ;y1 contains EQX

         asl      b                              ;Limit the updated EQX so
         asl      b                              ;  that $f000<EQX<$0fff
         asl      b
         move     b,x0
         move     #$1000,y0
         mpy      x0,y0,b
         move     b1,x:EQX                       ;Store the updated and limited
                                                 ;  EQX
         asl      a                              ;Limit the updated EQY so
         asl      a                              ;  that $f000<EQY<$0fff
         asl      a
         move     a,x0
         mpy      x0,y0,a                   
         move     a1,x:EQY                       ;Store this updated EQY
End_RXEQFIL
         jmp      rx_next_task

         ENDSEC

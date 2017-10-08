;*********************************rx_equpd.asm********************************
;
; Module name    : rx_equpd.asm
; Module authors : V. Ch. Venkaiah
; Date of Origin : 8th Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;******************Module description*****************************************
;
; This module 
;
; 1. Updates the real and imaginary equaliser filter taps
;
; 2. Updates phase jitter filter coefficients, Delay line and
;
; 3. Performs phase jitter filtering
;
;**************************Calling Requirements******************************
;
;1.  This module has one do loop, hence the calling module should take care
;    of stack initializations and saving of la and lc registers.
;
;************************Inputs and Outputs*********************************
;
; READ:
;  1. The EQRSB buffer values to update equaliser filter coefficients.
;     This buffer is a circular of 30 length. And it is pointed by x:EQRBIN.
;  2. The EQISB buffer values to update equaliser filter coefficients.
;     This buffer is a circular of 30 length. And it is pointed by x:EQIBIN.
;  3. DX value to update equaliser filter coefficients.
;     It is in |s.sss ffff ffff fffff| format.
;  4. DY value to update equaliser filter coefficients.
;     It is in |s.sss ffff ffff fffff| format.
;  5. LUPALP, scaling factor, to update equaliser filter coefficients.
;  6. DP,phase error,to calculate input to phase jitter filter and to calculate
;     ACODE.  
;
; Update:
;       1. Buffer EQRT (linear of length 15)
;       2. Buffer EQIT (linear of length 15)
;       3. Buffer THBUF (linear of length 6)
;       4. Buffer RCBUF (linear of length 6)
;       5. Buffer BBUF (circular of length 30)
;       6. The memory location x:BBUFPTR which points to BBUF.
;       7. JITTER
;       8. ACODE
;
;***********************Tables and Constants********************************
;
; 1.  x:JITG1, scaling factor for ACODE
; 2.  x:JITG2, scaling factor for input to jitter filter.
;
;     Both the above values should be in the |s.fff ffff ffff ffff| format.
;
; 3.  Number of equaliser tap coefficients, EQTSIZ22
;
;*****************************Resources*************************************
;
;               Cycle count   : 164+12*EQTSIZ22
;               Program words : 94
;               NLOAC         : 74
;
; Modifier register used :
;                   m01  : For modulo addressing of r0 
;
; Address registers used : 
;                   r0   : Used for BBUFPTR, and as a pointer to EQRT,
;                          DX, DY, EQRBIN, EQIBIN.
;                   r1   : Used as a pointer to the buffer EQRBIN, as a
;                          pointer to the buffer RCBUF.
;                   r2   : Used as a pointer to the buffer EQIT, as a 
;                          pointer to the buffer THBUF.
;                   r3   : Used as a pointer to the buffer EQIBIN, as a
;                          pointer to the buffer ACODE, as a pointer to
;                          the buffer RCBUF.
;                   n    : Used as an offset register for the buffer
;                          pointed by x:BBUFPTR, for the buffer EQRBIN, 
;                          for the buffer EQIBIN.
;
; Data registers used    :
;                   a0   b0   x0   y0
;                   a1   b1        y1
;                   a2   b2
;
; Registers changed      : 
;                   a0   b0   x0   y0   m01   n   r0   sr
;                   a1   b1        y1             r1   pc
;                   a2   b2                       r2     
;                                                 r3
;
;*****************************Pseudo code*************************************
;
;         Begin
;           /* Complex LMS update of equaliser tap coefficients */ 
;           for i = 0 to EQTSIZ22-1 
;               *EQRT++=*EQRT-LUPALP*DX*(*EQRBIN)-LUPALP*DY*(*EQIBIN) 
;               *EQIT++=*EQIT-LUPALP*DY*(*EQRBIN)+LUPALP*DX*(*EQIBIN) 
;               EQRBIN = EQRBIN - 2
;               EQIBIN = EQIBIN - 2
;           endfor
;
;        /* Phase Jitter filter coefficients updating and delay 
;           line updating */
;                  
;           *BBUFPTR = (2**8)*DP*JITG2+JITTER     
;           temp = *BBUFPTR       
;           *ACODE = (2**8)*DP*JITG1       
;           BBUFPTR = BBUFPTR + 2        
;           for i = 0 to 5
;               temp1 = *BBUFPTR 
;               *BBUFPTR=temp1-temp*(*RCBUF)+(*THBUF++)*(*RCBUF) 
;               BBUFPTR=BBUFPTR+2 
;               *RCBUF++=(*RCBUF)+temp1*(*ACODE) 
;           endfor
;        /* Phase Jitter filtering */   
;           sum = 0 
;           for i = 0 to 5 
;               *THBUF++=sum
;               sum=sum+(*RCBUF++)*(*BBUFPTR)
;               BBUFPTR=BBUFPTR+2
;           endfor 
;           JITTER=sum
;           BBUFPTR=BBUFPTR-1
;         end
;
;*****************************Environment***********************************
;
;         Assembler  : ASM56800 version 5.3.3.60
;         Machine    : SUN SPARC
;         OS         : SUN OS
;
;*************************Assembly code*************************************

         include "rxmdmequ.asm"

         SECTION V22B_RX 
         

         GLOBAL   RXEQUD

         org p:

RXEQUD

         move    x:DX,y0                     ;Get DX
         move    x:DY,y1                     ;Get DY
         move    x:EQRBIN,r1                 ;Get EQRBIN
         move    x:EQIBIN,r0                 ;Get EQIBIN
         move    #$801d,m01                  ;Make EQRBIN and EQIBIN circular
                                             ;  of length 30.
         move    x:LUPALP,x0                 ;Get LUPALP,step size
         mpy     x0,y0,b                     ;Calculate DX*LUPALP
         mpy     x0,y1,a                     ;Calculate DY*LUPALP
         move    b,y0                        ;Store DX*LUPALP for future use
         move    a,y1                        ;Store DY*LUPALP for future use

         move    #-2,n
         move    #EQRT,r3                    ;r0 points to EQRT buffer
         move    #EQIT,r2                    ;r2 points to EQIT buffer

         move    #EQTSIZ22,lc                ;No. of equaliser tap coeff.

         move    x:(r3),a                    ;Get *EQRT
         move    x:(r2),b                    ;Get *EQIT

         do      lc,EQUD1                    ;for i=0 to EQTSIZ22-1
         move    x:(r1)+n,x0                 ;Get *EQRBIN,EQRBIN=EQRBIN-2
         macr    -x0,y0,a                    ;*EQRT=*EQRT-DX*LUPALP*(*EQRBIN)
         macr    -x0,y1,b                    ;*EQIT=*EQIT-DY*LUPALP*(*EQRBIN)
         move    x:(r0)+n,x0                 ;Get *EQIBIN,EQIBIN=EQIBIN-2
         macr    -x0,y1,a                    ;*EQRT=*EQRT-DX*LUPALP*(*EQRBIN)
         macr    x0,y0,b         a,x:(r3)+   ;*EQIT=*EQIT-DY*LUPALP*(*EQRBIN)
         move    b,x:(r2)+
         move    x:(r3),a                    ;Get *EQRT
         move    x:(r2),b                    ;Get *EQIT
EQUD1

         move    #0,x:JITTER                 ;

         move    #-1,m01                     ;Make r0 and r1 linear
End_RXEQUD
         jmp     rx_next_task

         ENDSEC

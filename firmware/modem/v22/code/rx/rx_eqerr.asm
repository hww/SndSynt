;*********************************rx_eqerr.asm*********************************
;
; Module name    : rx_eqerr
; Module authors : V. Ch. Venkaiah
; Date of Origin : 4th Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;******************Module description******************************************
;
; This module calculates
;
; 1. The normalised phase error, DP, for carrier recovery
;
; 2. The error, DX and DY, in I and Q for equalisation tap updates
;
; 3. Accumulated NOISE
;
;**************************Calling Requirements*******************************
;
; 1.  Hard decision values of I and Q should be present in x:DECX and x:DECY 
;     respectively. 
; 
; 2.  Soft decision values of I and Q should be present in x:EQX and x:EQY 
;     respectively. 
;
; 3.  Previously computed NOISE should be present in the memory location 
;     x:NOISE. 
;
; 4.  WRPFLG should be present in the memory location x:WRPFLG. 
;
; 5.  LASTDP should be present in the memory location x:LASTDP  
;
; 6.  WRAP value should be present in the memory location x:WRAP
;     
;************************Inputs and Outputs*********************************
;
; Input :
;       1. Soft decision value of I should be present in x:EQX 
;       2. Soft decision value of Q should be present in x:EQY 
;       3. Hard decision value of I should be present in x:DECX 
;       4. Hard decision value of Q should be present in x:DECY
;       The format for the above four inputs is
;           | s.sss ffff ffff ffff |
;       5. WRPFLG value should be present x:WRPFLG 
;           format | 0000 0000 0000 000i |
; Update:
;       1. The memory location x:LASTDP
;       2. The memory location x:WRAP
;       3. The memory location x:NOISE
;       The format for the above inputs is
;           | s.fff ffff ffff ffff |
; Output:
;       1. Normalized phase value stored in x:DP
;           format | ssss siii iiii iiii |
;       2. Error value stored in x:DX
;       3. Error value stored in x:DY
;       The format for the above inputs is
;           | s.sss ffff ffff ffff |
;
;*****************************Resources*************************************
;
;               Cycle count   : 
;               Program words : 125
;               NLOAC         : 95
;
; Data registers used    :
;                   a0   b0   x0   y0
;                   a1   b1        y1
;                   a2   b2
;
; Registers changed      : 
;                   a0   b0   x0   y0   sr
;                   a1   b1        y1   pc
;                   a2   b2 
;
;*****************************Pseudo code*************************************
;
;         Begin
;           DP = DECY*EQX-DECX*EQY 
;           DX = EQX-DECX
;           DY = EQY-DECY 
;           NOISE=4*(DX*DX+DY*DY)+$7000*NOISE 
;            
;           /* Normalise DP */  
;       
;           If ( DP !=0 ) then 
;              realp = EQX*DECX+EQY*DECY 
;              If ( |realp|>|DP| ) then 
;                   temp=DP/realp 
;                   temp=temp>>5          /* Calculate (phase error/32) */
;              else 
;                   temp=$0400     /* Fix max phase error to 45 degrees */
;                                  /* i.e. temp = 1/32 */
;              endif  
;              If ((DP > 0 && realp > 0) || (DP < 0 && realp < 0)) then    
;                 DP = temp 
;              endif 
;              If ((DP < 0 && realp > 0) || (DP > 0 && realp < 0)) then 
;                 DP = -temp 
;              endif 
;           endif 
;   
;           /* Phase error unwrap routine */ 
;            
;           if ( WRPFLG >= 0 ) then
;              if ((DP-LASTDP) >= 0) then 
;                 temp = $0400 
;              else
;                 temp = $fc00
;              endif
;              if ((|DP-LASTDP|-$0400) >= 0) then
;                 WRAP=WRAP-temp
;              endif
;              LASTDP=DP
;              DP=DP+WRAP
;           else 
;              WRAP = 0
;              LASTDP = 0
;           endif
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
  
         GLOBAL RXEQERR

         org p:

RXEQERR       

         move    x:DECX,y0                   ;Get the hard decision value of I
         move    x:DECY,y1                   ;Get the hard decision value of Q
         move    x:EQX,x0                    ;Get the soft decision value of I

         move    x0,b                        ;Calculate DX=EQX-DECX
         sub     y0,b
         
         mpy     x0,y1,a                     ;Calculate EQX*DECY
         move    x:EQY,x0
         macr    -x0,y0,a                    ;Calculate DP=EQX*DECY-EQY*DECX
         move    a,x:DP                      ;Store the calculated DP
         move    x0,a                        ;Calculate DY=EQY-DECY
         sub     y1,a
         move    b,x:DX                      ;Store DX=EQX-DECX
         move    a,x:DY                      ;Store DY=EQY-DECY
         move    b,y0                        ;Calculate DX*DX
         mpy     y0,y0,b
         move    a,y0                        ;Calculate DX*DX+DY*DY
         mac     y0,y0,b
         asl     b                           ;Compute 4*(DX*DX+DY*DY)
         asl     b

; Update the noise
         move    #$7000,y0                   ;Compute NOISE
         move    x:NOISE,x0                  ;  NOISE=4*(DX*DX+DY*DY)+
         mac     x0,y0,b                     ;  $7000*NOISE
         move    b,x:NOISE                   ;Store the accumulated NOISE

EQUD22
         move    #0,y1                       ;If the phase error is positive,
                                             ;  y1 will be set to zero. Else 
                                             ;  it will be set to $8000
         move    x:DP,a                      ;Get the phase error
         tst     a                           ;If the phase error is zero then 
                                             ;  skip normalization process
         jeq     CAR_NOR                     ;If the phase error is negative
         jgt     APOS                        ;If the phase error is negative
         move    #$0100,y1                   ;  set y1 to $8000

APOS
         move    x:EQX,x0                    ;Get the soft decision value of
                                             ;  I sample,EQX
         move    x:DECX,y0                   ;Get the hard decision value of
                                             ;  I sample,DECX
         mpy     x0,y0,b                     ;Compute EQX*DECX
         move    x:EQY,x0                    ;Get the soft decision value of
                                             ;  Q sample
         move    x:DECY,y0                   ;Get the hard decision value of
                                             ;  Q sample
         macr    x0,y0,b                     ;Calculate realp=EQX*DECX+EQY*DECY
         move    #0,x0                       ;If realp value is +ve set x0 to 
                                             ;  zero
         tst     b                           ;Test whether realp value is +ve 
                                             ;  or not
         jgt     BPOS

         move    #$0100,x0                   ;If found -ve set x0 to $8000

BPOS
         abs     b                           ;Compute |realp|
         move    b,y0                        ;Move |realp| into a register for
                                             ;  the division operation
         abs     a                           ;Compute |DP|
         cmp     a,b                         ;Check whether |realp|>|DP| or not
         move    x0,b1                       ;Get the sign information of realp
                                             ;  in b1
         jgt     DIVID                       ;If the divisor > dividend let the
                                             ;  division takes place
         move    #$0400,a                    ;Otherwise fix max phase error to
                                             ;  45 degrees
         eor     y1,b                        ;Computation to determine the sign
         jmp     TSTSGN                      ;  of the phase error
DIVID
         eor     y1,b                        ;Computation to determine the sign
                                             ;  of the phase error
         bfclr   #$0001,sr                   ;Set the carry bit clear
         rep     #11       
         div     y0,a
         move    a0,a     
TSTSGN                                       
         tst     b                           ;Determine the sign of the phase
         jeq     TANOK                       ;  error and set accordingly
         neg     a                           
TANOK
         move    a,x:DP                      ;Store the normalized phase error

CAR_NOR
;PHASE ERROR UNWRAP ROUTINE

         move    x:WRPFLG,b                  ;Get the WRPFLG
         move    x:DP,a                      ;Get the phase error
         tst     b                           ;Test the WRPFLG 
                                             ;If WRPFLG >= 0 goto _start
         jge     start                       ;If WRPFLG >= 0 goto _start
         clr     a                           ;  else set WRAP = 0 and
         move    a,x:WRAP                    ;  LASTDP = 0 and go to 
         move    a,x:LASTDP                  ;  next task
         jmp     rx_next_task          

start
         move    x:LASTDP,b                  ;Get LASTDP
         move    a,y1                        ;Store DP in y1
         move    #$0400,x0                   ;Set temp = $0400
         sub     b,a                         ;Compute DP-LASTDP
                                             ;If DP-LASTDP < 0
         jge     POS                         ;If DP-LASTDP < 0

         move    #$fc00,x0                   ;  set temp = $fc00
POS     
         abs     a                           ;Compute |DP-LASTDP| 
         move    #$0400,y0                   
         move    x:WRAP,b                    ;Get the value of WRAP
         cmp     y0,a                        ;Compare |DP-LASTDP| and 
                                             ;  $0400
         jlt     NOWRAP                      ;If |DP-LASTDP|<$0400 then
                                             ;  jump to _NOWRAP 
         sub     x0,b                        ;  else WRAP = WRAP-temp
         move    b,x:WRAP

NOWRAP

         move    y1,x:LASTDP                 ;Set LASTDP = DP
         add     y1,b                        ;DP=DP+WRAP and go to next
         move    b,x:DP                      ;  task
_Ecar22_nor
End_EQERR
         jmp     rx_next_task
   
         ENDSEC

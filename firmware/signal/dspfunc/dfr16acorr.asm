; File: dfr16acorr.asm 

;--------------------------------------------------------------
; Revision History:
;
; VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
; -------    ----------    -----------      -----      --------
;   0.1      Meera S. P.        -          07-01-2000   Reviewed.
; 
;-------------------------------------------------------------*/

           SECTION rtlib
           GLOBAL  Fdfr16AutoCorr

	        include "portasm.h"
	
;========================================================================
; EXPORT Result  dfr16AutoCorr (UInt16 options, Frac16 *pX, 
;                                Frac16 *pZ, UInt16 nx, UInt16 nz);
; {
;   Register utilization upon entry:

;    Y0    - options
;    Y1    - nx
;    r2    - pX
;    r3    - pZ
;    SP-2  - nz
;
;   Registers utilized during execution
;   A, B, Y0, Y1, X0, X1
 
 DEFINE nz      'x:(SP-8)'
 DEFINE bias    'x:(SP-5)'
 DEFINE temp    'x:(SP-4)'
 DEFINE options 'x:(SP-3)'
 DEFINE nX      'x:(SP-2)'
 DEFINE old_omr 'x:(SP-1)'
;
;   Address Registers used :
;   R0  - Points to input vector for calculation purpose
;   R1  - Points to input vector for calculation purpose
;   R2  - Points to input vector
;   R3  - Points to the output vector
;
;   Return values :
;   Y0  - contains 0 for successful execution of function, -1 otherwise
;   R2  - pointer to output vector
;
;   }
;
;=========================================================================
     
           org    p:
Fdfr16AutoCorr:
           move   #6,N              ; create a scratch stack of length 6
           lea    (SP)+N                      
           move   omr,old_omr
           bfclr  #$10,omr
           move   nz,a              ; a = length of output buffer
           move   y1,b              ; b = length of input buffer
           asl    b                 ; b = 2nx
           dec    b                 ; b = 2nx-1
           bfset  #$0100,omr
           cmp    #PORT_MAX_VECTOR_LEN,b ; check if 2nx-1 is greater than 8191
           bls    AcorrCont         ; Yes, return -1
           move   #-1,y0            ;Yes, return -1
           jmp    EndAcorr           
AcorrCont:           
           cmp    #PORT_MAX_VECTOR_LEN,a ; check if length of output buffer is greater than 8191
           bfclr  #$0100,omr
           bls    Length_OK         ;No, Continue
AcorrFail:           
           move   #-1,y0            ;Yes, return -1
           jmp    EndAcorr           

Length_OK:

           move   y0,options        ; move value of option to options
           move   y1,nX             ; nX = length of input buffer
Comp0:      
           cmp    #$0,y0            ; is option = CORR_RAW
           bne    Comp1             ; No, check for 1
           move   #$7fff,bias       ; Yes, bias = 1
           jmp    Loop1
Comp1:
           cmp    #1,y0             ; is option = CORR_BIAS
           bne    Loop1             ; No, check for 2
           move   #>1,a             ; Yes, bias = 1/nx
           bfclr  #$0001,sr         ; Clear carry bit, required for first DIV instr 
           rep    #16         
           div    y1,a              ; a = 1/nX
           move   a0,bias           ; bias = 1/nX
Loop1:
           move   y1,a              ; a - length of input vecotr(nx)
           dec    a                 ; a - nx-1
           move   a,n               ; n = nx - 1
           do     y1,endl1          ;
Comp2:           
           move   options,y0
           cmp    #2,y0             ; is option = CORR_UNBIAS
           bne    Cont_Loop1        ; No, Continue
           move   nz,a              ; move the value of nZ to a
           move   n,b
           sub    b,a               ; nz-j
           move   a,y0
           move   #1,b              ; b = 1
           bfclr  #$0001,sr
           rep    #16
           div    y0,b              ; 1/(nz-j)
           move   b0,bias           ; bias = 1/(nz-j)
Cont_Loop1:

           move   r2,r0             ; r0 - points to input vector
           move   n,x0              ; x0 = j
           move   y1,a              ; a = nX
           sub    x0,a              ; Inner Loop count
           move   r2,r1             ; r1 - points to input vector
           clr    b                 ;
           lea    (sp)+
           move   la,x:(sp)+        ; store loop address
           move   lc,x:(sp)         ; store loop count
           lea    (r0)+n            ; r0 - points to last member of input buffer
           move   x:(r0)+,y1
           do     a,endl2           ;
           move   x:(r1)+,x0        ;
           macr   y1,x0,b     x:(r0)+,y1
endl2
           pop    lc
           pop    la
           move   n,a               ;
           dec    a                 ;
           move   a,n               ;
           move   b,b
           rnd    b                 ;
           move   bias,y1
           mpyr   b1,y1,a
           move   a,x:(r3)+
           move   nX,y1
endl1                               ;
Loop2:     
           move   #1,n
           move   nX,a
           do     a,endloop1        ; 
compl2:           
           move   options,y0
           cmp    #2,y0             ;
           bne    Cont_Loop2        ;
           move   nz,a              ;move the value of nZ to a
           move   n,x0
           sub    x0,a              ;nz-j
           move   a,y0
           move   #1,b              ;
           bfclr  #$0001,sr
           rep    #16
           div    y0,b              ;1/(nz-j)
           move   b0,bias           ;bias = 1/(nz-j)
           clr    b
Cont_Loop2:                         ;

           move   r2,r0
           move   nX,b
           move   n,x0
           sub    x0,b
           move   r2,r1
           clr    a
           lea    (r1)+n
           lea    (sp)+
           move   la,x:(sp)+
           move   lc,x:(sp)
           move   x:(r0)+,y1
           tstw   b
           beq    endloop2
           do     b,endloop2
           move   x:(r1)+,x0
           macr   y1,x0,a     x:(r0)+,y1
endloop2
           pop    lc
           pop    la
           move   a,a
           rnd    a
           move   a,y1
           move   bias,b1
           mpyr    b1,y1,a
           move   a,x:(r3)+
           move   n,a
           inc    a
           move   a,n
           nop
endloop1                            ;
           move   #0,y0             ;
           lea    (r3)-
           move   r3,r2             ;the pointer to output vector is returned
EndAcorr           
           move   old_omr,omr
           move   #-6,N
           lea    (SP)+N          
           rts                      ;
            
           ENDSEC

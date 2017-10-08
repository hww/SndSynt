; File: dfr16corr.asm 

;--------------------------------------------------------------
; Revision History:
;
; VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
; -------    ----------    -----------      -----      --------
;   0.1      Meera S. P.        -          25-01-2000   Review.
; 
;-------------------------------------------------------------*/
  
   
           SECTION rtlib
           GLOBAL  Fdfr16Corr

	        include "portasm.h"
	
;========================================================================
; EXPORT Result  dfr16Corr (UInt16 options, Frac16 *pX, Frac16 *pY, 
;                           Frac16 *pZ, UInt16 nx, UInt16 ny);
; {
;   Register utilization upon entry:

;    Y0    - options
;    Y1    - nx
;    r2    - pX
;    r3    - pY
;    SP-2  - pZ
;    SP-3  - ny
;
;   Registers utilized during execution
;   A, B, Y0, Y1, X0
;
; In the code below a scratch is allocated for storing these values.
 
 DEFINE old_omr 'x:(SP-8)' 
 DEFINE nY      'x:(SP-7)'
 DEFINE itr     'x:(SP-6)'
 DEFINE nZ      'x:(SP-5)'
 DEFINE bias    'x:(SP-4)'
 DEFINE temp    'x:(SP-3)'
 DEFINE options 'x:(SP-2)'
 DEFINE nX      'x:(SP-1)'

;
;   Address Registers used :
;   R0  - Stores the length of second input array nY.
;   R1  - Points to output vector for calculation purpose pZ
;   R2  - Points to input vector pX
;   R3  - Points to the input vector pY
;
;   Return values :
;   Y0  - contains 0 for successful execution of function, -1 otherwise
;   R2  - pointer to output vector
;
;   }
;
;=========================================================================
     
           org    p:
Fdfr16Corr:
           move   #10,N
           lea    (SP)+N
           move   omr,old_omr     ;save omr
           bfclr  #$10,omr

           move   x:(sp-12),r1    ;r1 -> output vector
           move   x:(sp-13),r0    ;r0 = nY
           move   x:(sp-13),a     ;a = ny
           add    y1,a            ;a = nx+ny
           dec    a               ;a = (nx+ny-1) - Length of output vector
           bfset  #$0100,omr
           cmp    #PORT_MAX_VECTOR_LEN,a         ;is (nx+ny-1) > 8191
           bfclr  #$0100,omr
           bls    Length_OK       ;No, Continue
           move   #-1,y0          ;Yes, return -1
           jmp    EndCorr

Length_OK:
           move   x:(sp-13),b
           cmp    y1,b
           tgt    y1,b
           move   a,nZ            ;nZ = (nx+ny-1)
           move   b,itr
           move   y0,options     ;
           move   y1,nX
           
Comp0:      
           cmp    #$0,y0         ;is option = CORR_RAW
           bne    Comp1          ;No, check for 1
           move   #$7fff,bias    ;Yes, bias = 1
           jmp    Loop1
Comp1:
           cmp    #1,y0          ;is option = CORR_BIAS
           bne    Loop1          ;No, check for 2
           move   #1,b       ;Yes, bias = 1/(nx+ny-1)
           bfclr  #$0001,sr
           move   nZ,y1           ;y1 = (nx+ny-1)
           rep    #16      
           div    y1,b           ;b0 = 1/(nx+ny-1)
           move   b0,bias        ;bias = 1/(nx+ny-1)
Loop1:
           move   nX,a            ;a - length of input vecotr(nx)
           dec    a               ;a - nx-1
           move   a,n             ;n = nx - 1
           move   nX,y1
           do     y1,endl1        ;
Comp2:           
           move   options,y0
           cmp    #2,y0           ;is option = CORR_UNBIAS
           bne    Start_lpcnt     ;No, Continue
           move   nZ,a            ;move the value of nZ to a
           move   n,b
           sub    b,a             ;(nx+ny-1-j)
           move   a,y0
           move   #1,b        ;b = 1
           bfclr  #$0001,sr
           rep    #16
           div    y0,b            ;1/(nx+ny-1-j)
           move   b0,bias         ;bias = 1/(nx+ny-1-j)
Start_lpcnt:
           move   n,x0            ; x0 = j
           move   nX,b            ; b = nX
           sub    x0,b            ; b =nx-j
           move   itr,x0
           cmp    x0,b          ;
           bgt    Cont_lpcnt
           move   b,y0           ; y0 = inner loopcount (lpcnt)
           jmp    End_lpcnt
Cont_lpcnt:
           move   x0,y0          ; y0 = inner loopcount (lpcnt)
End_lpcnt: 
           lea    (sp)+
           move   r2,x:(sp)+
           move   r3,x:(sp)+
           move   la,x:(sp)+
           move   lc,x:(sp)
           clr    b               ;
           lea    (r2)+n          ;
           move   x:(r2)+,y1
           do     y0,endl2         ;
           move   x:(r3)+,x0      ;
           mac    y1,x0,b          x:(r2)+,y1
endl2
           pop    lc
           pop    la
           pop    r3
           pop    r2
           move   n,a             ;
           dec    a               ;
           move   a,n             ;
           rnd    b               ;
           move   b,b
           move   bias,y1
           mpyr   b1,y1,a
           move   a,x:(r1)+
           move   nX,y1
endl1                             ;
Loop2:
           move   #1,n             ;n =  1
           move   r0,y1
           dec    y1
           do     y1,endsl1        ;
SComp2:           
           move   options,y0
           cmp    #2,y0           ;is option = CORR_UNBIAS
           bne    SStart_lpcnt    ;No, Continue
           move   nZ,a            ;move the value of nZ to a
           move   n,b
           sub    b,a             ;(nx+ny-1-j)
           move   a,y0
           move   #1,b            ;b = 1
           bfclr  #$0001,sr
           rep    #16
           div    y0,b            ;1/(nx+ny-1-j)
           move   b0,bias         ;bias = 1/(nx+ny-1-j)
SStart_lpcnt:
           move   n,x0            ; x0 = j
           move   r0,b            ; b = nY
           sub    x0,b            ; b =ny-j
           move   itr,x0
           cmp    x0,b            
           bgt    SCont_lpcnt
           move   b,y0           ; y0 = inner loopcount (lpcnt)
           jmp    SEnd_lpcnt
SCont_lpcnt:
           move   x0,y0          ; y0 = inner loopcount (lpcnt)
SEnd_lpcnt:
           lea    (sp)+
           move   r2,x:(sp)+
           move   r3,x:(sp)+
           move   la,x:(sp)+
           move   lc,x:(sp)
           clr    b                
           lea    (r3)+n           
           move   x:(r2)+,y1
           do     y0,endsl2          
           move   x:(r3)+,x0       
           mac    y1,x0,b     x:(r2)+,y1
endsl2
           pop    lc
           pop    la
           pop    r3
           pop    r2
           move   n,a             ;
           inc    a               ;
           move   a,n             ;
           rnd    b               ;
           move   b,b
           move   bias,y1
           mpyr    b1,y1,a
           move   a,x:(r1)+
           move   nX,y1
endsl1                             ;

           move   #0,y0
           move   r1,r2

EndCorr
           move   old_omr,omr
           move   #-10,N
           lea    (sp)+N
           rts  

           ENDSEC
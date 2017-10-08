;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_biq.asm
;
; Description:  Biquad filter code
;
; Modules
;    Included:  BIQUAD and BIQUAD1
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

        SECTION CAS_DETECT

        GLOBAL  BIQUAD
        
        GLOBAL  BIQUAD1
        
        include "cas_equ.asm"
        include "portasm.h"

        org p:

;**************************************************************************
;
;   CHANGE HISTORY
;
;   DD/MM/YY   Code Ver      Description        Author
;   --------   --------      -----------        ------
;   27/02/98    0.00         Module created     A.Buvaneswari
;   06/03/98    0.01         Review changes     A.Buvaneswari
;   15/07/98    0.02         two biquad filters Andy T.W.Lam
;   14/11/2000  1.00         Optimized          Sandeep S.
;
;**************************************************************************
;
;   PROCESSOR : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  :
;
;   This module is the Biquad filter implementation. 
;
;**************************************************************************
;
;   INPUT         - r0->zdelay : buffer holding previous filter states, 
;                                initially set to zero.
;                   r3->bq_hpf : buffer containing biquad filter coeffi
;                                -cients. The co-efficients should be arra
;                                -nged as follows :
;                                -------
;                                |  N  |  N is the num of stages
;                                -------
;                                | bi0 |
;                                -------                                
;                                | bi1 |
;                                -------                                
;                                | bi2 |
;                                -------                                
;                                | ai1 |
;                                -------                                
;                                | ai2 |
;                                -------                                
;                                | b11 |
;                                -------                                
;                                | ... |
;                                -------                                
;                                | ... |
;                                -------                                
;                                | ... |
;                                -------                                
;                                | aN2 |
;                                -------                                
;                   y1 : input sample
;
;   OUTPUT        - b : has the filtered output sample.
;
;   UPDATE        - None
;
;   MACROS
;    CALLED       - None         
;
;   CALLING
;    REQUIREMENTS - Rounding mode should be 2's complement - (i.e) bit
;                   5 of omr should be set, and the saturation mode should
;                   be ON (bit-8 to be set) if the results have to match 
;                   with that of c-code.
;
;
;   RESOURCES     - stack used : None
;    (local)        do loop depth : 1
;                   scratch : None
;                   Cycle Count    : 45
;                   Program Memory : 29
;                   NLOAC : 36          
;**************************************************************************


BIQUAD
        move  x:(r3)+,lc                        ;Get number of stages
	move	x:(r3)+,x0			;Get b00

	move	#<2,n				
 if V2_WORKAROUND==1
	doslc _biquad_loop1		;for i = 0 to NBQ-1
 else
	do	lc,_biquad_loop1		;for i = 0 to NBQ-1
 endif
	move	r0,r1				;save r0
	mpy	y1,x0,a	x:(r0)+,y0	x:(r3)+,x0
						;find (x * bi0)
						;Get z(i-1,1) in y0
						;Get bi1 in x0
	mac	x0,y0,a	x:(r0)+,y0	x:(r3)+,x0
						;a = a + (z(i-1,1) * bi1)
						;Get z(i-1,2) in y0
						;Get bi2 in x0
	mac	x0,y0,a	x:(r0)+,y0	x:(r3)+,x0
						;a = a + (z(i-1,2) * bi2)
						;Get z(i,1) in y0
						;Get (-ai1) in x0

    mac y0,x0,a x:(r0)+,y0 x:(r3)+,x0  ;a = a - (z(i,1) * ai1)
                                       ;Get z(i,2) in y0
						               ;Get (-ai2) in x0
	move	r1,r0	            		;r0->z(i-1,1)
	
	mac	y0,x0,a x:(r1)+,y0 x:(r3)+,x0	;a = a - (z(i,2) * ai2)
	                					;dummy read into y0
		                			 	;Get b[i+1]0 in x0
    tfr   a,b                           ;save a before rounding
    asl     a                           ; *2 for compensate of coeff

    rnd     a       x:(r0)+,y0 		    ;Get z(i-1,1) in y0
				         
	move	y0,x:(r0)-			;save z(i-1,1) as z(i-1,2)
	move	y1,x:(r0)+n			;save x in z(i-1,1)
					         	;r0->z(i,1)
	move	a,y1				;Get input for the next
                                ;  stage(x) into y1
_biquad_loop1
	move	x:(r0)+,y0			;Get z(NBQ,1)
	move	y0,x:(r0)-			;save it as z(NBQ,2)
	move	y1,x:(r0)			;save 'y' as z(NBQ,1)
    move    a,b

	rts

;***********************************************************;
;* similar to BIQUAD except the ouput do not multiply by 2 *;
;***********************************************************;
BIQUAD1

	move	x:(r3)+,lc			;Get number of stages
	move	x:(r3)+,x0			;Get b00

	move	#<2,n				
 if V2_WORKAROUND==1
	doslc  _biquad_loop1		;for i = 0 to NBQ-1
 else
	do	lc,_biquad_loop1		;for i = 0 to NBQ-1
 endif
	move	r0,r1				;save r0
	mpy	y1,x0,a	x:(r0)+,y0	x:(r3)+,x0
						;find (x * bi0)
						;Get z(i-1,1) in y0
						;Get bi1 in x0
	mac	x0,y0,a	x:(r0)+,y0	x:(r3)+,x0
						;a = a + (z(i-1,1) * bi1)
						;Get z(i-1,2) in y0
						;Get bi2 in x0
	mac	x0,y0,a	x:(r0)+,y0	x:(r3)+,x0
						;a = a + (z(i-1,2) * bi2)
						;Get z(i,1) in y0
						;Get ai1 in x0
	mac	y0,x0,a	x:(r0)+,y0 x:(r3)+,x0	;a = a - (z(i,1) * ai1)
                						;Get z(i,2) in y0
				                		;Get ai2 in x0
	move	r1,r0			        	;r0->z(i-1,1)
	mac	y0,x0,a	x:(r1)+,y0 x:(r3)+,x0	;a = a - (z(i,2) * ai2)
                  						;dummy read into y0
				                	 	;Get b[i+1]0 in x0

	tfr	a,b			        	;save a before rounding

    rnd     a       x:(r0)+,y0
			        			;Get z(i-1,1) in y0
	move	y0,x:(r0)-			;save z(i-1,1) as z(i-1,2)
	move	y1,x:(r0)+n			;save x in z(i-1,1)
	         					;r0->z(i,1)
	move	a,y1				;Get input for the next
                                ;  stage(x) into y1
_biquad_loop1
	move	x:(r0)+,y0			;Get z(NBQ,1)
	move	y0,x:(r0)-			;save it as z(NBQ,2)
	move	y1,x:(r0)			;save 'y' as z(NBQ,1)
    move  a,b

    rts

    ENDSEC

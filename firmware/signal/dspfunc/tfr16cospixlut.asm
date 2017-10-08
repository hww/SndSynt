		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16CosPIxLUT
		
; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 


		;  Frac16 tfr16CosPIxLUT(tfr16_tCosPIxLUT * pSWG, Frac16 PhasePIx)

		;  Register usage upon Entry:
		;      R2  - tfr16_tCosPIxLUT * input value 
		;      Y0  - PhasePIx input value
		 
		;  Register usage during execution
		;      X0  - temp
		;      Y0  - temp
		;      Y1  - Table Length
		;      R2  - tfr16_tCosPIxLUT
		;      R1  - shift
		;      R0  - pSineTable
		;      N   - index into table
		;      A   - temp
		;      B   - temp

		ORG	P:

Ftfr16CosPIxLUT:

 if SWG_USE_NON_MODULO_OPT==1

	lea (SP+7)
	move x:(r2+2),x0       ; put shift into x0
	move x0,x:(SP-1)       ; store shift
	move x:(r2),r0         ; put pSineTable into r0
	
	tstw y0                ; test initial phase
	bgt CosPIxLUTStart
	move x0,x:(SP-6)       ; put shift onto stack
	move #-1,x0
	impy16 x0,y0,y0        ; change sign convention of phase
	move x:(SP-6),x0       ; restore x0

CosPIxLUTStart:
	move #-16384,b         ; put -90 degrees into b
	add  y0,b              
	move b1,y0             ; store shifted phase into y0     

	tstw y0                ; test initial phase
	blt  CosPIxLUTTest1
	asrr y0,x0,x0          ; find index into table
	move x0,x:(SP-5)       ; store index
	bfclr #$FFC0,y0
	move y0,x:(SP-4)       ; store sine delta
	move #-1,x:(SP-3)      ; store sign
	bra  CosPIxLUTValue

CosPIxLUTTest1:
	move y0,b
	abs  b                 ; take the mag of phase
	move b1,y0
	asrr y0,x0,x0
	move x0,x:(SP-5)       ; store index
	move b1,x0
	bfclr #$FFC0,x0
	move x0,x:(SP-4)       ; store sine delta
	move #1,x:(SP-3)       ; store sign
	
CosPIxLUTValue:
	move x:(SP-5),N        ; put index into N
	nop
	move x:(r0+N),x0       ; get sine value
	move x0,x:(SP-2)       ; store sine value

	move x:(SP-5),x0
	incw x0
	move x0,N              ; put index2 into N
	move x:(r0+N),x0       ; get sine value

	sub  x:(SP-2),x0       ; get difference
	move x:(SP-4),y0       ; put sine delta in y0
	impy16 x0,y0,y0 

	move x:(SP-1),x0       ; put shift into x0
	asrr y0,x0,y0          
	add  x:(SP-2),y0       ; add delta to sine value
	move x:(SP-3),x0       ; get sign
	impy16 x0,y0,y0        ; get return value

	lea  (SP-7)            ; reset SP

 endif

	rts
_end


    	ENDSEC
		END                 


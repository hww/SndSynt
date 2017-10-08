		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16SineWaveGenDOM

; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 

		;  void tfr16SineWaveGenDOM(tfr16_tSineWaveGenDOM * pSWG, Frac16 * pValues, UInt16 Nsamples)
		;  Register usage upon Entry:
		;      R2  - tfr16_tSineWaveGenDOM * input value 
		;      R3  - pValues input address
		;      Y0  - Nsample input value
	
		;  Register usage:
		;      X0  - temp
		;      Y0  - Nsamples
		;      Y1  - temp
		;      R2  - Private data structure
		;      R3  - pValues
		;      A   - temp

Ftfr16SineWaveGenDOM:

 if SWG_USE_NON_MODULO_OPT==1

  	tstw  y0               ; nsamples == 0?
	beq   EndDOM
	move x:(r2),x0         ; put filter state 1 into x0
		
	do y0,EndDOM           ; do nsamples
    move x:(r2+2),y1       ; put filter coef into y1
	mpy  x0,y1,a           ; put product into a
	move a1,x:(r3)         ; put sine value in pValue
	move x:(r2+1),x0       ; put filter state 2 into x0
	move #16384,y1         ; put .5 into y1
	mpy  x0,y1,a           ; put product into a
	move a1,x:(r2+1)       ; store new filter state 2
	move x:(r3),y1         ; put pValue in y1
	sub  a1,y1             ; substract filter state 2 from pValue
	move y1,x:(r3)         ; store new pValue
	move x:(r3),x0         ; put pValue in x0
	add  y1,x0             ; add pValue and pValue
	move x0,x:(r3)         ; store new pValue
	move x:(r2),y1         ; put filter state 1 in y1
	move y1,x:(r2+1)       ; store new filter state 2
	move x0,x:(r2)         ; store new filter state 1
	lea  (r3)+             ; increment address of pValue 

EndDOM:

 endif

	rts
_end


    	ENDSEC
		END                 


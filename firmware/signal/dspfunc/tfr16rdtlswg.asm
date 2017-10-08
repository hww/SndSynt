		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16SineWaveGenRDTL
	
; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 

		;  void tfr16SineWaveGenRDTL(tfr16_tSineWaveGenRDTL * pSWG, Frac16 * pValues, UInt16 Nsamples)
		;  Register usage upon Entry:
		;      R2  - tfr16_tSineWaveGenRDTL * input value 
		;      R3  - pValues input address
		;      Y0  - Nsample input value
		 
		;  Register usage during execution
		;      X0  - Phase
		;      Y0  - Nsamples
		;      Y1  - Address of Sine Table end
		;      R2  - Sine Table Index
		;      R3  - pValues
		;      R0  - pIndex into sine table
		;      N   - Index for sine table
		;      A   - temp
		;      B   - Delta

Ftfr16SineWaveGenRDTL:

 if SWG_USE_NON_MODULO_OPT==1

	tstw  y0               ; Nsamples == 0?
	beq   EndRDTL
	move  x:(r2),x0		   ; put current phase in x0
	move  x:(r2+3),y1      ; put table length in y1
	move  x:(r2+1),b	   ; put delta in b
	move  x:(r2+2),r0      ; pSineTable
 
 	do y0,EndRDTL          ; do nsamples
	mpy   y1,x0,a          ; store offset in a
	move  a,N              ; put index in offset register
	move  x:(r0+N),a       ; store sine value in a
	move  a1,x:(r3)+       ; store sine value in pValue
	add   b1,x0            ; find new phase
	cmp   #32767,x0        ; see if need to reset phase 
	blt   NoPhaseReset
	move  #32767,a
	move  x:(r2),x0        
	sub   x0,a             
	move  b1,x0
	sub   a1,x0            ; reset phase   
NoPhaseReset:
	move  x0,x:(r2)        ; store new phase
	nop
	nop
EndRDTL:

 endif

	rts
_end


    	ENDSEC
		END                 


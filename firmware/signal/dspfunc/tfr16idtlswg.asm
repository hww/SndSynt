		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16SineWaveGenIDTL
		
; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 
	define  SWG_USE_MODULO_OPT       '1'


		;  void tfr16SineWaveGenIDTL(tfr16_tSineWaveGenIDTL * pSWG, Frac16 * pValues, UInt16 Nsamples)

		;  Register usage upon Entry:
		;      R2  - tfr16_tSineWaveGenIDTL * input value 
		;      R3  - pValues input address
		;      Y0  - Nsample input value
		 
		;  Register usage during execution
		;      X0  - Table Length
		;      Y0  - temp
		;      Y1  - address of sine table end
		;      R2  - Sine table index
		;      R3  - pValue
		;      R0  - pIndex into sine table
		;      N   - Delta for sine table
		;      A   - temp
		;      B   - temp

		ORG	P:

Ftfr16SineWaveGenIDTL:
	move  x:(r2+1),r0      ; put pIndex into r0
	tstw  Y0               ; Nsamples == 0?
	beq   EndIDTL
	move  x:(r2+2),N       ; put delta into N  
	move  x:(r2+3),y1      ; put table end into y1
	move  x:(r2+4),x0      ; put length of table in x0 

 if SWG_USE_NON_MODULO_OPT==1
 
 if SWG_USE_MODULO_OPT==1
 		
  	tstw  x:(r2)           ; bAligned?
	bne   DoModuloIDTL     ; branch to modulo if bAligned is true

 endif
	
	do    Y0,EndDoIDTL
	move  x:(r0)+N,y0      ; put sine value into y0
	move  y0,x:(r3)+       ; put sine value into pValue
	
	move  r0,A             ; check if index over upper bound
	cmp   y1,A           
	blo   NoWrapIDTL  
	
	sub   x0,A             ; get new pIndex 
NoWrapIDTL:
	move  A,r0
	nop
	nop
EndDoIDTL:
	bra   EndIDTL

 endif
	

 if SWG_USE_MODULO_OPT==1
 		
DoModuloIDTL:
	move  M01,B            ; save M register
	move  x0,A             ; Set Modulo addressing value 
	decw  A
	move  A,M01
	do    Y0,EndModDoIDTL
	move  x:(r0)+N,y0      ; put sine value into y0
	move  y0,x:(r3)+       ; put sine value into pValue
EndModDoIDTL:
	move  B,M01            ; restore M register

 endif
	
EndIDTL:
	move  r0,X:(r2+1)      ; Save current index
	rts
		

    	ENDSEC
		END                 


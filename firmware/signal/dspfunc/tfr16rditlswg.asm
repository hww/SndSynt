		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16SineWaveGenRDITL
		
; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 


		;  void tfr16SineWaveGenRDITL(tfr16_tSineWaveGenRDITL * pSWG, Frac16 * pValues, UInt16 Nsamples)

		;  Register usage upon Entry:
		;      R3  - pValues
		;      R2  - tfr16_tSineWaveGenRDITL * input value 
		;      Y0  - Nsamples input value
		 
		;  Register usage during execution
		;      X0  - temp
		;      Y0  - temp
		;      R2  - tfr16_tWaveGenRDITL
		;      R1  - shift
		;      R0  - pSineTable
		;      N   - index into table
		;      A   - temp
		;      B   - temp

		ORG	P:

Ftfr16SineWaveGenRDITL:

 if SWG_USE_NON_MODULO_OPT==1

	lea (SP+5)

	move x:(r2+4),r0       ; put shift into r0
	move y0,r1             ; move nsample into r1
	move x:(r2),y0         ; put current phase into y0

	do r1,SWGEndRDITL
	move x:(r2+4),r0       ; put shift into r0
	tstw y0                ; test phase
	blt  SWGRDITLTest1

	move #16384,a          ; put .5 into a
	cmp  y0,a
	ble  SWGRDITLTest2
	clr  a
	move y0,a              ; put phase into y0
	bfclr #$FFC0,y0
	move y0,x:(SP-3)       ; store sine delta
	move #1,x:(SP-2)       ; store sign
	bra  SWGRDITLShiftTest1

SWGRDITLTest1:
	move #-16384,a         ; put -.5 in a
	cmp  y0,a
	ble  SWGRDITLTest3
	
	clr  a
	clr  b
	move #-32768,a0
	move y0,b0             ; put phase in b0
	add  b,a
	move a0,a1
	clr  b
	move #63,b1
	and  b1,y0
	move y0,x:(SP-3)       ; store sine delta 
	move #-1,x:(SP-2)      ; store sign
	bra  SWGRDITLShiftTest1

SWGRDITLTest2:
	clr  a
	clr  b
	move #-32768,a0
	move y0,b0             ; put phase in b0
	sub  b,a
	move a0,y0
	clr  b
	move y0,a1
	move #63,b1
	and  b1,y0
	move y0,x:(SP-3)       ; store sine delta
	move #1,x:(SP-2)       ; store sign
	bra  SWGRDITLShiftTest1

SWGRDITLTest3:
	clr  a
	move y0,b
	abs  b                 ; take the mag of phase
	nop
	move b1,x0
	move x0,a1
	bfclr #$FFC0,x0
	move x0,x:(SP-3)       ; store sine delta
	move #-1,x:(SP-2)      ; store sign

SWGRDITLShiftTest1:
	tstw (r0)-
	beq  SWGRDITLShiftTest2
	asr  a                 ; shift phase by 1
	bra  SWGRDITLShiftTest1

SWGRDITLShiftTest2:
	bftsth #-32768,a0
	bcc  SWGRDITLShiftEnd
	incw a

SWGRDITLShiftEnd:
	move a1,x0             ; put index into x0
	move x0,x:(SP-4)       ; store index

SWGRDITLValue:
	move x:(r2+2),r0       ; put pSineTable into r0
	move x:(SP-4),N        ; put index into N
	nop
	move x:(r0+N),x0       ; get sine value        
	move x0,x:(SP-1)       ; store sine value

	move x:(SP-4),x0
	incw x0
	move x0,N              ; put index2 into N
	move x:(r0+N),x0       ; get sine value          

	sub  x:(SP-1),x0       ; get difference
	move x:(SP-3),y0       ; put sine delta in y0
	impy16 x0,y0,y0 

	move x:(r2+4),x0       ; put shift into x0
	asrr y0,x0,y0          
	add  x:(SP-1),y0       ; add delta to sine value
	move x:(SP-2),x0       ; get sign
	impy16 x0,y0,b         ; get return value

	move x:(r2),y0         ; move current phase into y0
	move x:(r2+1),x0       ; put phase increment into x0
	add  x0,y0
	move #32767,a          ; put MAX_16 into a
	cmp  y0,a
	bgt  SWGRDITLNoResetPhase
	move x:(r2),y0         ; put phase into y0
	sub  y0,a 
	move x:(r2+1),y0       ; put phase increment into y0
	sub  a1,y0
	add  #-32768,y0

SWGRDITLNoResetPhase:
	nop
	move y0,x:(r2)         ; store new phase
	move b1,x:(r3)+        ; put return value into pValue

SWGEndRDITL:
	lea  (SP-5)            ; reset SP

 endif

	rts

_end


    	ENDSEC
		END                 


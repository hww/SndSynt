		SECTION rtlib
	
		include "portasm.h"
		
		GLOBAL  Ftfr16WaveGenRDITLQ
		
; 
; The following symbols can be used to exclude portions (using '0') of 
; the SWG implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to SWG will satisfy the
; constraints placed upon the limited implementation.
;
	define  SWG_USE_NON_MODULO_OPT   '1' 


		;  Frac16 tfr16WaveGenRDITLQ(tfr16_tWaveGenRDITLQ * pSWG, Frac16 PhaseIncrement)

		;  Register usage upon Entry:
		;      R2  - tfr16_tWaveGenRDITLQ * input value 
		;      Y0  - PhaseIncrement input value
		 
		;  Register usage during execution
		;      X0  - temp
		;      Y0  - temp
		;      Y1  - Table Length
		;      R2  - tfr16_tWaveGenRDITLQ
		;      R1  - shift
		;      R0  - pSineTable
		;      N   - index into table
		;      A   - temp
		;      B   - temp

		ORG	P:

Ftfr16WaveGenRDITLQ:

 if SWG_USE_NON_MODULO_OPT==1

	lea (SP+6)
	move x:(r2+3),x0       ; put shift into x0
	move x:(r2+1),r0       ; put pSineTable into r0
	move y0,x:(SP-5)       ; store phase increment
	move x:(r2),y0         ; put current phase into y0

	tstw y0                ; test initial phase
	blt  WaveGenRDITLQTest1

	move #16384,a          ; put .5 into a
	cmp  y0,a
	ble  WaveGenRDITLQTest2
	asrr y0,x0,x0          ; find index into table
	
	move x0,x:(SP-4)       ; store index
	bfclr #$FFC0,y0
	move y0,x:(SP-3)       ; store sine delta
	move #1,x:(SP-2)       ; store sign
	bra  WaveGenRDITLQValue

WaveGenRDITLQTest1:
	move #-16384,a         ; put -.5 in a
	cmp  y0,a
	ble  WaveGenRDITLQTest3
	
	clr  a
	clr  b
	move #-32768,a0
	move y0,b0             ; put phase in b0
	add  b,a
	move a0,y0
	asrr y0,x0,x0
	move x0,x:(SP-4)       ; store index
	clr  b
	move #63,b1
	and  b1,y0
	move y0,x:(SP-3)       ; store sine delta
	move #-1,x:(SP-2)      ; store sign
	bra  WaveGenRDITLQValue

WaveGenRDITLQTest2:
	clr  a
	clr  b
	move #-32768,a0
	move y0,b0             ; put phase in b0
	sub  b,a
	move a0,y0
	asrr y0,x0,x0
	move x0,x:(SP-4)       ; store index
	clr  b
	move #63,b1
	and  b1,y0
	move y0,x:(SP-3)       ; store sine delta
	move #1,x:(SP-2)       ; store sign
	bra  WaveGenRDITLQValue

WaveGenRDITLQTest3:
	move y0,b
	abs  b                 ; take the mag of phase
	move b1,y0
	asrr y0,x0,x0
	move x0,x:(SP-4)       ; store index
	move b1,x0
	bfclr #$FFC0,x0
	move x0,x:(SP-3)       ; store sine delta
	move #-1,x:(SP-2)      ; store sign
	
WaveGenRDITLQValue:
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

	move x:(r2+3),x0       ; put shift into x0
	asrr y0,x0,y0          
	add  x:(SP-1),y0       ; add delta to sine value
	move x:(SP-2),x0       ; get sign
	impy16 x0,y0,b         ; get return value

	move x:(r2),y0         ; move current phase into y0
	move x:(SP-5),x0       ; put phase increment into x0
	add  y0,x0
	move #32767,a          ; put MAX_16 into a
	cmp  x0,a
	bgt  WaveGenRDITLQEnd
	sub  y0,a 
	move x:(SP-5),x0       ; put phase increment into x0
	sub  a1,x0
	add  #-32768,x0

WaveGenRDITLQEnd:
	move x0,x:(r2)         ; store new phase
	move b1,y0             ; put return value into y0
	lea  (SP-6)            ; reset SP

 endif

	rts
_end


    	ENDSEC
		END                 


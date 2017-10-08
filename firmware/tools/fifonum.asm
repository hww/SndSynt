	SECTION rtlib
	
	include "portasm.h"
	include "fifoasm.h"
	
	GLOBAL  FfifoNum


; extern UWord16 fifoNum (fifo_sFifo * pFifo)
;{
; See C implementation in fifo.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pFifo
;
;	Register utilization during execution:
;     R2    - pFifo
;     Y0    - cnt
;     X0    - temp

FfifoNum:
;
;	if (((fifo_sFifoPriv *)pFifo)->threshold > 0) {
;		num = 0;
;	} else {
;		num = (put >= get ? put - get : size + put - get);
;	}
;
	clr      Y0
	tstw     X:(R2+Offset_threshold)
	bgt      GotNum
	move     X:(R2+Offset_get),X0
	move     X:(R2+Offset_put),Y0
	sub      X0,Y0
	bge      GotNum
	move     X:(R2+Offset_size),X0
	add      X0,Y0                   ; Y0 now contains num
GotNum:
	rts
	
	ENDSEC

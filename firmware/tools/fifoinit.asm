	SECTION rtlib
	
	include "portasm.h"
	include "fifoasm.h"
	
	GLOBAL  FfifoInit


; void fifoInit (fifo_sFifo * pFifo, UWord16 size, UWord16 threshold)
;{
; See C implementation in fifo.c for pseudo code model
;
; Register utilization upon entry:
;     R2    - pFifo
;     Y0    - size
;     Y1    - threshold
;
;	Register utilization during execution:
;     R2    - pFifo
;     Y0    - size
;     Y1    - threshold
;     X0    - temp

FfifoInit:

  if ASSERT_ON_INVALID_PARAMETER==1
 
;
;	assert (pFifo != NULL);
;	assert (((fifo_sFifoPriv *)pFifo) -> pCircBuffer != NULL);
;
	tstw      R2
	bne       pFifoNonZero
	debug                   ; Error: pFifo == NULL !
pFifoNonZero:
	tstw      X:(R2+Offset_pCircBuffer)
	bne       pCircBufferNonZero
	debug                   ; Error: pCircBufferNonZero == NULL !
pCircBufferNonZero:		

  endif
  
;																				 (size_t)(size + 1));
;	if ( threshold > size ) threshold = size;
;
	cmp      Y0,Y1
	ble      SizeGEThreshold
	move     Y0,Y1
SizeGEThreshold:	
;
;	((fifo_sFifoPriv *)pFifo)->threshold      = threshold;
;	((fifo_sFifoPriv *)pFifo)->origThreshold  = threshold;
;
	move     Y1,X:(R2+Offset_threshold)
	move     Y1,X:(R2+Offset_origThreshold)
;
;	((fifo_sFifoPriv *)pFifo)->get            = 0;
;	((fifo_sFifoPriv *)pFifo)->put            = 0;
;
	clr      X0
	move     X0,X:(R2+Offset_get)
	move     X0,X:(R2+Offset_put)
;
;	((fifo_sFifoPriv *)pFifo)->size           = size + 1;
;
	incw     Y0
	move     Y0,X:(R2+Offset_size)          ; keep size+1 for next call
;
;	((fifo_sFifoPriv *)pFifo)->bIsAligned     = memIsAligned ((void *)(((fifo_sFifoPriv *)pFifo) -> pCircBuffer), 
;															 (size_t)(size + 1));
;
	push     R2
	move     X:(R2+Offset_pCircBuffer),R2
	jsr      FmemIsAligned
	pop      R2
	nop
	move     Y0,X:(R2+Offset_bIsAligned)
	
	rts
	
	ENDSEC

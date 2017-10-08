	SECTION rtlib
	
	include "portasm.h"
	include "fifoasm.h"
	
	GLOBAL  FfifoPreview

; asm UWord16 fifoPreview ( fifo_sFifo * pFifo,
;							Word16     * pData,
;							UWord16      Number)
;{
; See C implementation in fifo.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pFifo
;		R3    - pData
;		Y0    - Number
;
;	Register utilization during execution:
;     R0    - pPut
;     R2    - pFifo
;     R3    - pData
;     Y0    - cnt
;     Y1    - temp
;     X0    - pEnd
;     A     - temp
;     B     - temp

FfifoPreview:
;
;	if (((fifo_sFifoPriv *)pFifo)->threshold > 0) {
;		num = 0;
;	} else {
;		num = (put >= get ? put - get : size + put - get);
;	}
;
	clr      B
	tstw     X:(R2+Offset_threshold)
	bgt      GotNum
	move     X:(R2+Offset_get),A
	move     X:(R2+Offset_put),B
	sub      A,B
	bge      GotNum
	move     X:(R2+Offset_size),A
	add      A,B                     ; B now contains num
GotNum:
;
;	if (num < Number) {
;		return 0;
;	}
;
	tstw     Y0
	bne      NumberGT0
	rts
NumberGT0:
	cmp      Y0,B
	bge      Enough
	clr      Y0
	rts
	
Enough:	

;	
;	pGet = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + get;
;
	move     X:(R2+Offset_pCircBuffer),R0
	move     X:(R2+Offset_get),N
	nop
	lea      (R0)+N                  ; R0 contains pGet
		
  if FIFO_USE_MODULO_ADDRESSING_OPT==1
 
;
; Q: Aligned buffer?
:

  if FIFO_USE_LINEAR_ADDRESSING_OPT==1
  
	tstw     X:(R2+Offset_bIsAligned)
	beq      BufferNotAligned        ; Q: Is buffer modulo aligned?
	
  endif
  
BufferAligned:                       ; Buffer is modulo aligned
	move     X:(R2+Offset_size),Y1   ; size
	decw     Y1                      ; size - 1
	move     Y1,M01                  ; set Modulo register = size - 1
	do       Y0,EndDoAligned         ; loop through all data
	move     X:(R0)+,Y1
	move     Y1,X:(R3)+
EndDoAligned:
	move     #$FFFF,M01              ; restore modulo register
	bra      ExitPreview               ; now go adjust get value

  endif
  
  
  if FIFO_USE_LINEAR_ADDRESSING_OPT==1
  
BufferNotAligned:	                 ; Buffer is not modulo aligned
;
;	pEnd = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + size;
;	
	move     X:(R2+Offset_pCircBuffer),X0
	move     X:(R2+Offset_size),Y1
	add      Y1,X0                   ; X0 contains pEnd
;
;	for (i = 0; i < cnt; i++)
;	{
;		*pData++ = *pGet++;
;		if (pGet >= pEnd)
;		{
;			pGet = ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
;		}
;	}
;	
	move     R0,Y1                   ; Y1 contains pGet
	do       Y0,EndDoUnaligned       ; loop through data
	cmp      X0,Y1                   ; Q: pGet >= pEnd?
	blt      NotYetEnd               
	move     X:(R2+Offset_pCircBuffer),Y1
	move     Y1,R0                   ; pGet = pCircBuffer
	nop
NotYetEnd:
	move     X:(R0)+,Y1              ; Transfer data
	move     Y1,X:(R3)+
	move     R0,Y1                   ; Y1 contains pGet
EndDoUnaligned:
	cmp      X0,Y1                   ; Q: pGet >= pEnd?
	blt      NotYetEnd2
	move     X:(R2+Offset_pCircBuffer),Y1
	move     Y1,R0                   ; pGet = pCircBuffer
NotYetEnd2:

  endif
  
;
;	return cnt;
;
ExitPreview:
	rts      

	ENDSEC

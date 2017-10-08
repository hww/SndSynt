	SECTION rtlib
	
	include "portasm.h"
	include "fifoasm.h"
	
	GLOBAL  FfifoInsert

; asm UWord16 fifoInsert (  fifo_sFifo * pFifo,
;							Word16     * pData,
;						  	UWord16      num)
;{
; See C implementation in fifo.c for pseudo code model
;
; Register utilization upon entry:
;		R2    - pFifo
;		R3    - pData
;		Y0    - num
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

FfifoInsert:
;
;	population = (put >= get ? put - get : size + put - get);
;
	move     X:(R2+Offset_get),A
	move     X:(R2+Offset_put),B
	sub      A,B
	bge      PutGTGet
	move     X:(R2+Offset_size),A
	add      A,B                     ; B now contains population
PutGTGet:
;
; 	cnt = (num <= size - 1 - population ? num : size - 1 - population);
;
	move     X:(R2+Offset_size),A    ; A contains size
	decw     A                       ; size - 1
	sub      B,A                     ; size - 1 - population
	cmp      Y0,A                    ; num <= size - 1 - population
	bge      CntEQNum                
	move     A,Y0                    ; cnt = size - 1 - population
CntEQNum:
	tstw     Y0                      ; Q: cnt == 0?
	beq      ExitInsert              ; if so exit

;	
;	pPut = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + put;
;
	move     X:(R2+Offset_pCircBuffer),R0
	move     X:(R2+Offset_put),N
	nop
	lea      (R0)+N                  ; R0 contains pPut
		
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
	move     X:(R3)+,Y1
	move     Y1,X:(R0)+
EndDoAligned:
	move     #$FFFF,M01              ; restore modulo register
	bra      AdjustThreshold         ; now go adjust threshold value

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
;		*pPut++ = *pData++;
;		if (pPut >= pEnd) pPut = ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
;	}
;	
	move     R0,Y1                   ; Y1 contains pPut
	do       Y0,EndDoUnaligned       ; loop through data
	cmp      X0,Y1                   ; Q: pPut >= pEnd?
	blt      NotYetEnd               
	move     X:(R2+Offset_pCircBuffer),Y1
	move     Y1,R0                   ; pPut = pCircBuffer
NotYetEnd:
	move     X:(R3)+,Y1              ; Transfer data
	move     Y1,X:(R0)+
	move     R0,Y1                   ; Y1 contains pPut
EndDoUnaligned:
	cmp      X0,Y1                   ; Q: pPut >= pEnd?
	blt      NotYetEnd2
	move     X:(R2+Offset_pCircBuffer),Y1
	move     Y1,R0                   ; pPut = pCircBuffer
NotYetEnd2:

  endif
  
;
;	((fifo_sFifoPriv *)pFifo)->threshold = 
;		(cnt >= (Word16)(((fifo_sFifoPriv *)pFifo)->threshold) ? 0 : 
;								((fifo_sFifoPriv *)pFifo)->threshold - cnt);
;
AdjustThreshold:
	move     X:(R2+Offset_threshold),Y1
	sub      Y0,Y1
	bgt      ThresholdPos
	clr      Y1
ThresholdPos:
	move     Y1,X:(R2+Offset_threshold)
; 
; 	((fifo_sFifoPriv *)pFifo) -> put = pPut - ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
;
	move     R0,Y1
	move     X:(R2+Offset_pCircBuffer),X0
	sub      X0,Y1
	move     Y1,X:(R2+Offset_put)
;
;	return cnt;
;
ExitInsert:
	rts      

	ENDSEC

#include "port.h"
#include "stdlib.h"
#include "fifo.h"
#include "fifopriv.h"
#include "string.h"

#include "mem.h"

#include "assert.h"

fifo_sFifo * fifoCreate (UWord16 size, UWord16 threshold)
{	
	fifo_sFifoPriv *  pFifo;
	UWord16           AdjSize = size + 1;
	
	assert (sizeof(fifo_sFifo) >= sizeof(fifo_sFifoPriv));

	pFifo = (fifo_sFifoPriv *)memMallocEM(sizeof(fifo_sFifo));

	assert (pFifo != (fifo_sFifoPriv *)0);

	pFifo->pCircBuffer = (Word16 *)memMallocAlignedEM(sizeof(Word16)*AdjSize);

	assert (pFifo->pCircBuffer != (Word16 *)0);

	fifoInit ((fifo_sFifo *)pFifo, size, threshold);

	return (fifo_sFifo *)pFifo;
}

void fifoInitC (fifo_sFifo * pFifo, UWord16 size, UWord16 threshold);

void fifoInitC (fifo_sFifo * pFifo, UWord16 size, UWord16 threshold)
{	
	assert (pFifo != NULL);
	assert (((fifo_sFifoPriv *)pFifo) -> pCircBuffer != NULL);
	
	((fifo_sFifoPriv *)pFifo)->bIsAligned     = memIsAligned ((void *)(((fifo_sFifoPriv *)pFifo) -> pCircBuffer), 
																				 (size_t)(size + 1));
	if ( threshold > size ) threshold = size;
	
	((fifo_sFifoPriv *)pFifo)->size           = size + 1;
	((fifo_sFifoPriv *)pFifo)->threshold      = threshold;
	((fifo_sFifoPriv *)pFifo)->origThreshold  = threshold;
	((fifo_sFifoPriv *)pFifo)->get            = 0;
	((fifo_sFifoPriv *)pFifo)->put            = 0;
}


extern void fifoDestroy (fifo_sFifo * pFifo)
{
	free ((void *)(((fifo_sFifoPriv *)pFifo)->pCircBuffer));
	free ((void *)pFifo);
}


extern void fifoClear (fifo_sFifo * pFifo, UWord16 newThreshold)
{
	if ( newThreshold >= ((fifo_sFifoPriv *)pFifo)->size ) 
	   newThreshold = ((fifo_sFifoPriv *)pFifo)->size - 1;
	   
	((fifo_sFifoPriv *)pFifo)->get           = ((fifo_sFifoPriv *)pFifo)->put = 0;
	((fifo_sFifoPriv *)pFifo)->threshold     = newThreshold;
	((fifo_sFifoPriv *)pFifo)->origThreshold = newThreshold;
}

extern UWord16 fifoNumC (fifo_sFifo * pFifo);

extern UWord16 fifoNumC (fifo_sFifo * pFifo)
{  
	UWord16 num;
	Word16  get;
	Word16  put;
	Word16  size;
 
	get = ((fifo_sFifoPriv *)pFifo)->get;
	put = ((fifo_sFifoPriv *)pFifo)->put;
	size= ((fifo_sFifoPriv *)pFifo)->size;

	if (((fifo_sFifoPriv *)pFifo)->threshold > 0) {
		num = 0;
	} else {
		if (put >= get) {
			num = put - get;
		} else {
			num = size + put - get;
		}
	}

	return num;
}

extern UWord16 fifoExtractC (fifo_sFifo * pFifo,
							 Word16     * pData,
							 UWord16      Number);

extern UWord16 fifoExtractC (fifo_sFifo * pFifo,
							 Word16     * pData,
							 UWord16      Number)
{ 
	UWord16  cnt;
	Word16   i;
	UWord16  num;
	Word16   get;
	Word16 * pGet;
	Word16 * pEnd;
	Word16   put;
	Word16   size;

	cnt        = Number;
	get        = ((fifo_sFifoPriv *)pFifo)->get;
	put        = ((fifo_sFifoPriv *)pFifo)->put;
	size       = ((fifo_sFifoPriv *)pFifo)->size;

	if (((fifo_sFifoPriv *)pFifo)->threshold > 0) {
		num = 0;
	} else {
		num = (put >= get ? put - get : size + put - get);
	}

	if (num < Number) {
		return 0;
	}

	pEnd = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + size;
	pGet = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + get;
	
	for (i = 0; i < cnt; i++)
	{
		*pData++ = *pGet++;
		if (pGet >= pEnd)
		{
			pGet = ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
		}
	}
	
	((fifo_sFifoPriv *)pFifo)->get = pGet - ((fifo_sFifoPriv *)pFifo)->pCircBuffer;

	return cnt;
}

extern UWord16 fifoPreviewC(fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      Number);

extern UWord16 fifoPreviewC(fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      Number)
{ 
	UWord16  cnt;
	Word16   i;
	UWord16  num;
	Word16   get;
	Word16 * pGet;
	Word16 * pEnd;
	Word16   put;
	Word16   size;

	cnt        = Number;
	get        = ((fifo_sFifoPriv *)pFifo)->get;
	put        = ((fifo_sFifoPriv *)pFifo)->put;
	size       = ((fifo_sFifoPriv *)pFifo)->size;

	if (((fifo_sFifoPriv *)pFifo)->threshold > 0) {
		num = 0;
	} else {
		num = (put >= get ? put - get : size + put - get);
	}

	if (num < Number) {
		return 0;
	}

	pEnd = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + size;
	pGet = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + get;
	
	for (i = 0; i < cnt; i++)
	{
		*pData++ = *pGet++;
		if (pGet >= pEnd)
		{
			pGet = ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
		}
	}
	
	return cnt;
}


extern UWord16 fifoInsertC (fifo_sFifo * pFifo,
							Word16     * pData,
						  	UWord16      num);

extern UWord16 fifoInsertC (fifo_sFifo * pFifo,
							Word16     * pData,
						  	UWord16      num)
{ 
	UWord16  cnt;
	Word16   i;
	Word16   get;
	Word16   put;
	Word16   size;
	UWord16  population;
	Word16 * pEnd;
	Word16 * pPut;

	get        = ((fifo_sFifoPriv *)pFifo)->get;
	put        = ((fifo_sFifoPriv *)pFifo)->put;
	size       = ((fifo_sFifoPriv *)pFifo)->size;

	population = (put >= get ? put - get : size + put - get);
	 
	cnt = (num <= size - 1 - population ? num : size - 1 - population);
	
	pEnd = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + size;
	pPut = ((fifo_sFifoPriv *)pFifo)->pCircBuffer + put;
	
	for (i = 0; i < cnt; i++)
	{
		*pPut++ = *pData++;
		if (pPut >= pEnd)
		{
			pPut = ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;
		}
	}
	
	((fifo_sFifoPriv *)pFifo)->threshold = 
		(cnt >= (Word16)(((fifo_sFifoPriv *)pFifo)->threshold) ? 0 : 
								((fifo_sFifoPriv *)pFifo)->threshold - cnt);
 
 	((fifo_sFifoPriv *)pFifo) -> put = pPut - ((fifo_sFifoPriv *)pFifo) -> pCircBuffer;

	return cnt;
}

#ifndef _fifopriv_h
#define _fifopriv_h


#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************************************
* fifo_sFifoPriv 
*
* fifo_sFifoPriv is the data structure used to implement a FIFO queue.
*
* The member pCircBuffer points to memory dynamically allocated for the FIFO
* circular buffer.
*
* The member bIsAligned tells whether the circular buffer is aligned
* for modulo addressing.
*
* The member size tells how long the circular buffer is in 16-bit words.
*
* The member threshold is the amount of data which must be buffered before
* fifoNum reports anything in the FIFO;  this amounts to a hysterisis
* function to ensure an amount of data is available before starting processing
* in order to prevent underruns.  This value is set to zero after the threshold
* amount of data is buffered.
*
* The member origThreshold is the threshold value originally set when the FIFO
* was created.  OrigThreshold may be used to reset the threshold value which
* is zeroed during FIFO use.
* 
* The member get is the index into pCircBuffer (range 0..size-1) which 
* represents the head of the FIFO queue.
*
* The member put is the index into pCircBuffer (range 0..size-1) which 
* represents the tail of the FIFO queue.
*
*******************************************************************************/
typedef struct {
	Word16       *  pCircBuffer;
	bool            bIsAligned;
	UWord16         size;
	UWord16         threshold;
	UWord16         origThreshold;
	UWord16         get;
	UWord16         put;
} fifo_sFifoPriv;
									

#ifdef __cplusplus
}
#endif


#endif

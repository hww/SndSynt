#ifndef _fifo_h
#define _fifo_h


#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************************************
* FIFO Functions 
*
* The FIFO functions specified here implement an efficient circular buffer (or
* first-in, first-out queue).  
*
* A key requirement for the FIFO is to be able to use the insert and extract
* functions independently without any higher level mutual exclusion protection.
* Interrupt latency must also be minimized.  These requirements permit the 
* FIFO functions to be used both within ISRs and outside ISRs in order to
* serve as the circular buffer interface of choice for device drivers.
*
*******************************************************************************/


/*******************************************************************************
* fifo_sFifo 
*
* fifo_sFifo is the private data structure used to implement a FIFO queue.
* It is declared to be private in order to hide the implementation details
* of the FIFO routines in the interests of portability.  However, the 
* pCircBuffer member must point to an array of size + 1 elements which constitute
* the actual circular buffer.  (Note that the length of the circular buffer must
* be one greater that the 'size' of the FIFO.)  For the best efficiency, 
* align the circular buffer such that modulo address may be used by the FIFO routines.
*
*******************************************************************************/
typedef struct {
	Word16  * pCircBuffer;
	Word16    PrivData[6];
} fifo_sFifo;


/*******************************************************************************
* fifoCreate
*
* fifoCreate is the constructor for fifo_sFifo which allocates and
* initializes the object.  The parameter size specifies the number of entries
* that can be put in the circular buffer.  (Note that the actual length of the 
* circular buffer must be one greater that the 'size' of the FIFO.)  The parameter 
* threshold specifies the number of FIFO entries that must be queued before 
* fifoNum returns a non-zero value;  both origThreshold and threshold members 
* are set to this parameter value.
*
*******************************************************************************/
EXPORT fifo_sFifo * fifoCreate (UWord16 size, UWord16 threshold);


/*******************************************************************************
* fifoInit
*
* fifoInit initializes the fifo_sFifo data structure using previously
* allocated storage.  The parameter size specifies the number of entries that
* can be queued in the circular buffer.  
* The parameter threshold specifies
* the number of FIFO entries that must be queued before fifoNum returns
* a non-zero value;  both origThreshold and threshold members are set to this
* parameter value.
*
*******************************************************************************/
EXPORT void fifoInit (fifo_sFifo * pFIFO, UWord16 size, UWord16 threshold);


/*******************************************************************************
* fifoDestroy 
*
* fifoDestroy is the destructor for fifo_sFifo which deallocates FIFO 
* resources and destroys the FIFO object pointed to by pFifo.
*
*******************************************************************************/
EXPORT void fifoDestroy (fifo_sFifo * pFifo);


/*******************************************************************************
* fifoClear 
*
* fifoClear reinitializes a FIFO and sets a new threshold for FIFO contents.
* The original FIFO size is maintained;  no new memory allocation is done.
*
*******************************************************************************/
EXPORT void fifoClear (fifo_sFifo * pFifo, UWord16 newThreshold);


/*******************************************************************************
* fifoNum 
*
* fifoNum returns the number of data entries queued in the FIFO, 
* assuming that this number exceeds the threshold number of entries.  If
* the number of data entries actually queued in the FIFO is less than the
* threshold number, fifoNum returns 0.  Once the threshold number
* of entries is exceeded, the threshold number is set to zero (0).  Thus,
* the threshold mechanism provides a hysterisis function for FIFO contents.
*
*******************************************************************************/
EXPORT UWord16 fifoNum (fifo_sFifo * pFifo);


/*******************************************************************************
* fifoExtract 
*
* fifoExtract extracts num data entries from the FIFO object pointed
* to by pFifo into the array pointed to by pData.  The return value gives
* the number of entries actually extracted from the FIFO.  No entries will be
* returned if the FIFO contains fewer entries than the number requested.
*
*******************************************************************************/
EXPORT UWord16 fifoExtract (fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);


/*******************************************************************************
* fifoPreview 
*
* fifoPreview extracts num data entries from the FIFO object pointed
* to by pFifo into the array pointed to by pData.  The semantics of 
* fifoPreview are identical to fifoExtract.  However, the fifo 
* pointers are not changed so that a subsequent fifoExtract or 
* fifoPreview will obtain the same data values previewed.
*
*******************************************************************************/
EXPORT UWord16 fifoPreview (fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);


/*******************************************************************************
* fifoInsert
*
* fifoInsert inserts num data entries into the FIFO object pointed
* to by pFifo from the array pointed to by pData.  The return value gives
* the number of entries actually inserted into the FIFO;  the return value
* may be less than the number of entries specified because the FIFO is full.
*
*******************************************************************************/
EXPORT UWord16 fifoInsert ( fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);
									

#ifdef __cplusplus
}
#endif


#endif

/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "null.h"
#include "sdram.h"
#include "audiolib.h"
#
#define NBUFFERS       		32		// Buffers number	
#define MAX_BUFFER_LENGTH 	512		// Buffer size

#define START_DMA(addr,dst,size) sdram_load_64( (UInt32)addr, (UWord16*) dst, (size_t) size)

typedef UInt32 (*ALDMAproc)(UInt32 addr, UInt16 len, void *state);
typedef ALDMAproc (*ALDMANew)(void *state);
UInt32 dmaCallBack(UInt32 addr, UInt16 len, void *state);
ALDMAproc dmaNew(DMAState **state);

typedef struct 
{
    ALLink      node;
    UInt32      startAddr;			// Read address
    UInt16      lastFrame;			// When was last access
    char        *ptr;				// In memory
} DMABuffer;

typedef struct 
{
    u8          initialized;
    DMABuffer   *firstUsed;
    DMABuffer   *firstFree;
} DMAState;

DMAState    dmaState;
DMABuffer   dmaBuffs[NBUFFERS];
UInt16      gFrameCt;

void CleanDMABuffs(void);
void set_file(void);

/*****************************************************************************
 *
 * s32 dmaCallBack(s32 addr, s32 len, void *state)
 *
 *	addr	source address
 *	len		size
 *	state	state of DMAs
 *
 *****************************************************************************/

UInt32 dmaCallBack(UInt32 addr, UInt16 len, void *state)
{
    void        *freeBuffer;			// target
    UInt16       delta;					// index in buffer
    DMABuffer   *dmaPtr,*lastDmaPtr;	// DMA's pointers
    UInt32       addrEnd,buffEnd;		// block's ends


    lastDmaPtr = 0;
    dmaPtr = dmaState.firstUsed;
    addrEnd = addr+len;										
 
    while(dmaPtr)  // Find ready buffer
    {   buffEnd = dmaPtr->startAddr + MAX_BUFFER_LENGTH;	
        if(dmaPtr->startAddr > addr) 						
            break;                   						

        else if(addrEnd <= buffEnd) 						
        {
            dmaPtr->lastFrame = gFrameCt; 					
            freeBuffer = dmaPtr->ptr + addr - dmaPtr->startAddr;
            return (int) freeBuffer;						
        }
        lastDmaPtr = dmaPtr;
        dmaPtr = (DMABuffer*)dmaPtr->node.next;
    }
    /*
     * 	Buffer not found then get free one
     */
    dmaPtr 				= dmaState.firstFree;				
    dmaState.firstFree 	= (DMABuffer*)dmaPtr->node.next;
    alUnlink((ALLink*)dmaPtr);
    /*
     * 	Add to used list
     */
    if(lastDmaPtr != NULL) 							
    {	alLink((ALLink*)dmaPtr,(ALLink*)lastDmaPtr);
    }
    else if(dmaState.firstUsed != NULL)				
    {   lastDmaPtr = dmaState.firstUsed;
        dmaState.firstUsed 		= dmaPtr;
        dmaPtr->node.next 		= (ALLink*)lastDmaPtr;
        dmaPtr->node.prev 		= 0;
        lastDmaPtr->node.prev 	= (ALLink*)dmaPtr;
    }
    else 											
    {   dmaState.firstUsed 	= dmaPtr;
        dmaPtr->node.next 	= 0;
        dmaPtr->node.prev 	= 0;
    }
    
    freeBuffer = dmaPtr->ptr;						
    delta = addr & 0x1;								
    addr -= delta;									
    dmaPtr->startAddr = addr;						
    dmaPtr->lastFrame = gFrameCt;  					
 
    START_DMA((u32)addr,freeBuffer,MAX_BUFFER_LENGTH);

    return (UInt16) freeBuffer + delta;
}

/*****************************************************************************
 *
 *	ALDMAproc dmaNew(DMAState **state)
 *
 *	state	states of DMAs
 *	return	DMA callback procedure
 *	
 *****************************************************************************/

ALDMAproc dmaNew(DMAState **state)
{
    int         i;

    if(!dmaState.initialized)  /* only do this once */
    {
        dmaState.firstFree = &dmaBuffs[0];
        for (i=0; i<NBUFFERS-1; i++)
        {
            alLink((ALLink*)&dmaBuffs[i+1],(ALLink*)&dmaBuffs[i]);
            dmaBuffs[i].ptr = 0xC000 + (i*MAX_BUFFER_LENGTH);
        }

        dmaState.initialized = 1;
    }

    *state = &dmaState;  /* state is never used in this case */

    return dmaCallBack;
}

/*****************************************************************************
 *
 * 	void CleanDMABuffs(void)
 *
 *	Clear all DMA channels
 *
 *****************************************************************************/

void CleanDMABuffs(void)
{
    DMABuffer  *dmaPtr,*nextPtr;

    dmaPtr = dmaState.firstUsed;
    while(dmaPtr)
    {	nextPtr = (DMABuffer*)dmaPtr->node.next;

        /* Can change this value.  Should be at least one.  */
        /* Larger values mean more buffers needed, but fewer DMA's */

        if(dmaPtr->lastFrame + 2  < gFrameCt) /* remove from used list */
        {   if(dmaState.firstUsed == dmaPtr)
                dmaState.firstUsed = (DMABuffer*)dmaPtr->node.next;
            alUnlink((ALLink*)dmaPtr);
            if(dmaState.firstFree != NULL)
                alLink((ALLink*)dmaPtr,(ALLink*)dmaState.firstFree);
            else
            {
                dmaState.firstFree = dmaPtr;
                dmaPtr->node.next = 0;
                dmaPtr->node.prev = 0;
            }
        }
        dmaPtr = nextPtr;
    }
}

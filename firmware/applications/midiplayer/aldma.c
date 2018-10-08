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

#ifdef DMAS_ON

DMAState    dmaState;
DMABuffer   dmaBuffs[NBUFFERS];
UInt16      gFrameCt;

/*****************************************************************************
 *
 *  UInt16 dmaCallBack(UInt32 addr, UInt16 len, void *state)
 *
 *  addr    source address
 *  len     size
 *  state   pointer to the state of all DMAs
 *
 *****************************************************************************/

UInt16 dmaCallBack(UInt32 addr, UInt16 len, void *state)
{
    void        *freeBuffer;            // target
    UInt16       delta;                 // index in the frame
    DMABuffer   *dmaPtr,*lastDmaPtr;    // pointers to DMA
    UInt32       addrEnd,buffEnd;       // ends of blocks


    lastDmaPtr = 0;
    dmaPtr = dmaState.firstUsed;
    addrEnd = addr+len;

    while(dmaPtr)  // find prepaired buffer
    {   buffEnd = dmaPtr->startAddr + MAX_BUFFER_LENGTH;
        if(dmaPtr->startAddr > addr)
            break;

        else if(addrEnd <= buffEnd)
        {
            dmaPtr->lastFrame = gFrameCt;
            freeBuffer = dmaPtr->ptr + addr - dmaPtr->startAddr; байта
            return (int) freeBuffer;
        }
        lastDmaPtr = dmaPtr;
        dmaPtr = (DMABuffer*)dmaPtr->node.next;
    }
    /*
     *  Buffer is not found lets take free one
     */
    dmaPtr              = dmaState.firstFree;
    dmaState.firstFree  = (DMABuffer*)dmaPtr->node.next;
    alUnlink((ALLink*)dmaPtr);
    /*
     *  Add it to used list
     */
    if(lastDmaPtr != NULL)
    {   alLink((ALLink*)dmaPtr,(ALLink*)lastDmaPtr);
    }
    else if(dmaState.firstUsed != NULL)
    {   lastDmaPtr = dmaState.firstUsed;
        dmaState.firstUsed      = dmaPtr;
        dmaPtr->node.next       = (ALLink*)lastDmaPtr;
        dmaPtr->node.prev       = 0;
        lastDmaPtr->node.prev   = (ALLink*)dmaPtr;
    }
    else
    {   dmaState.firstUsed  = dmaPtr;
        dmaPtr->node.next   = 0;
        dmaPtr->node.prev   = 0;
    }

    freeBuffer = dmaPtr->ptr;
    delta = addr & 0x3;
    addr -= delta;
    dmaPtr->startAddr = addr;
    dmaPtr->lastFrame = gFrameCt;

    START_DMA((u32)addr,freeBuffer,MAX_BUFFER_LENGTH>>2);

    return (UInt16) freeBuffer + delta;
}

/*****************************************************************************
 *
 *  ALDMAproc dmaNew(DMAState **state)
 *
 *  state   state of all DMAs
 *  return  address of DMA callback
 *
 *****************************************************************************/

ALDMAproc dmaNew(DMAState **state)
{
    UInt16  i;

    gFrameCt = 0;

    if(!dmaState.initialized)  /* only do this once */
    {
        dmaState.firstFree = &dmaBuffs[0];
        for (i=0; i<NBUFFERS-1; i++)
        {
            alLink((ALLink*)&dmaBuffs[i+1],(ALLink*)&dmaBuffs[i]);
            dmaBuffs[i].ptr = (UInt16*)(0xC000 + (i*MAX_BUFFER_LENGTH));
        }

        dmaState.initialized = 1;
    }

    *state = &dmaState;  /* state is never used in this case */

    return dmaCallBack;
}

/*****************************************************************************
 *
 *  void CleanDMABuffs(void)
 *
 *  Clear all DMA buffers
 *
 *****************************************************************************/

void CleanDMABuffs(void)
{
    DMABuffer  *dmaPtr,*nextPtr;
    gFrameCt++;
    dmaPtr = dmaState.firstUsed;
    while(dmaPtr)
    {
        nextPtr = (DMABuffer*)dmaPtr->node.next;
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

#endif

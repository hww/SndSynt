#include "port.h"
#include "null.h"
#include "sdram.h"
#include "audiolib.h"
#
#define NBUFFERS       		32		// число буферов	
#define MAX_BUFFER_LENGTH 	512		// размер буфера

#define START_DMA(addr,dst,size) sdram_load_64( (UInt32)addr, (UWord16*) dst, (size_t) size)

typedef UInt32 (*ALDMAproc)(UInt32 addr, UInt16 len, void *state);
typedef ALDMAproc (*ALDMANew)(void *state);
UInt32 dmaCallBack(UInt32 addr, UInt16 len, void *state);
ALDMAproc dmaNew(DMAState **state);

typedef struct 
{
    ALLink      node;
    UInt32      startAddr;			// Адрес откуда нужно прочитать
    UInt16      lastFrame;			// в каком каждре к нему обращались
    char        *ptr;				// где в памяти буфер
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

/*******************************************************************************
*
* s32 dmaCallBack(s32 addr, s32 len, void *state)
*
*	addr	адрес источника
*	len		размер
*	state	указатель на состояние всех DMA
*
*******************************************************************************/

UInt32 dmaCallBack(UInt32 addr, UInt16 len, void *state)
{
    void        *freeBuffer;			// куда сливать будем
    UInt16       delta;					// слово внутри фрейма
    DMABuffer   *dmaPtr,*lastDmaPtr;	// указатели на DMA
    UInt32       addrEnd,buffEnd;		// концы блоков


    lastDmaPtr = 0;
    dmaPtr = dmaState.firstUsed;
    addrEnd = addr+len;										// конец запрашиваемого блока
 
    while(dmaPtr)  // Ищем буфер который уже подготовлен
    {   buffEnd = dmaPtr->startAddr + MAX_BUFFER_LENGTH;	// конец буфера
        if(dmaPtr->startAddr > addr) 						// since buffers are ordered
            break;                   						// abort if past possible 

        else if(addrEnd <= buffEnd) 						// Да, один найден
        {
            dmaPtr->lastFrame = gFrameCt; 					// пометили его использовали 
            freeBuffer = dmaPtr->ptr + addr - dmaPtr->startAddr; // где в памяти место первого байта
            return (int) freeBuffer;						// требуемой информации
        }
        lastDmaPtr = dmaPtr;
        dmaPtr = (DMABuffer*)dmaPtr->node.next;
    }
	/*
     * 	Не нашли ни одного буфера, берём свободный буфер 
     */
    dmaPtr 				= dmaState.firstFree;				
    dmaState.firstFree 	= (DMABuffer*)dmaPtr->node.next;
    alUnlink((ALLink*)dmaPtr);
	/*
     * 	Добавим его в лист использованных
     */
    if(lastDmaPtr != NULL) 							// нормально
    {	alLink((ALLink*)dmaPtr,(ALLink*)lastDmaPtr);
    }
    else if(dmaState.firstUsed != NULL)				// впишем в начало листа занятых
    {   lastDmaPtr = dmaState.firstUsed;
        dmaState.firstUsed 		= dmaPtr;
        dmaPtr->node.next 		= (ALLink*)lastDmaPtr;
        dmaPtr->node.prev 		= 0;
        lastDmaPtr->node.prev 	= (ALLink*)dmaPtr;
    }
    else 											// нет занятых, это будет первый
    {   dmaState.firstUsed 	= dmaPtr;
        dmaPtr->node.next 	= 0;
        dmaPtr->node.prev 	= 0;
    }
    
    freeBuffer = dmaPtr->ptr;						// куда сгружать
    delta = addr & 0x1;								// байт во фрейме
    addr -= delta;									// к началу фрейма	
    dmaPtr->startAddr = addr;						
    dmaPtr->lastFrame = gFrameCt;  					// пометили
 
 	START_DMA((u32)addr,freeBuffer,MAX_BUFFER_LENGTH);

    return (UInt16) freeBuffer + delta;
}

/*******************************************************************************
*
*	ALDMAproc dmaNew(DMAState **state)
*
*	state	указатель на указатель на состояние каналов DMA
*	return	адрес процедуры DMA callback
*	
*******************************************************************************/

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

/*******************************************************************************
*
* 	void CleanDMABuffs(void)
*
*	очищает все DMA каналы
*
*******************************************************************************/

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

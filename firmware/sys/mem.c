/* File: memory.c */

#include "port.h"
#include "mem.h"
#include "arch.h"
#include "assert.h"
#include <string.h>
#include <stdio.h>

/*******************************************************
* memory Package
*******************************************************/


bool      bMemInitialized = false;

mem_sPool InternalMemoryPool;
mem_sPool ExternalMemoryPool;

mem_sState InitialState;

static void Initialize (void);

void *  memMallocIM (size_t size)
{
	void * pMem;
	
	pMem = memMalloc (&InternalMemoryPool, size);

	if (pMem == NULL) 
	{
		pMem = memMalloc (&ExternalMemoryPool, size);
	}

	return pMem;
}


void *  memCallocIM (size_t num, size_t size)
{
	void * pMem;

	pMem = memCalloc (&InternalMemoryPool, num, size);

	if (pMem == NULL) 
	{
		pMem = memCalloc (&ExternalMemoryPool, num, size);
	}

	return pMem;
}


void * memReallocIM ( void *memblock, size_t size )
{
	void * pMem;

	pMem = memRealloc (&InternalMemoryPool, memblock, size);

	if (pMem == NULL) 
	{
		pMem = memRealloc (&ExternalMemoryPool, memblock, size);
	}

	return pMem;
}


void *  memMallocAlignedIM (size_t size)  
{
	void * pMem;

	pMem = memMallocAligned (&InternalMemoryPool, size);

	if (pMem == NULL) 
	{
		pMem = memMallocAligned (&ExternalMemoryPool, size);
		
		if (pMem == NULL)
		{
			pMem = memMallocIM (size);
		}
	}

	return pMem;
}


void    memFreeIM   (void * memblock)
{
	if (memIsIM(memblock))
	{
		memFree (&InternalMemoryPool, memblock);
	}
	else
	{
		memFree (&ExternalMemoryPool, memblock);
	}
}


void *  memMallocEM (size_t size)
{
	void * pMem;

	pMem = memMalloc (&ExternalMemoryPool, size);

	if (pMem == NULL) 
	{
		pMem = memMalloc (&InternalMemoryPool, size);
	}

	return pMem;
}


void *  memCallocEM (size_t num, size_t size)
{
	void * pMem;

	pMem = memCalloc (&ExternalMemoryPool, num, size);

	if (pMem == NULL) 
	{
		pMem = memCalloc (&InternalMemoryPool, num, size);
	}

	return pMem;
}


void * memReallocEM ( void *memblock, size_t size )
{
	void * pMem;

	pMem = memRealloc (&ExternalMemoryPool, memblock, size);

	if (pMem == NULL) 
	{
		pMem = memRealloc (&InternalMemoryPool, memblock, size);
	}

	return pMem;
}


void *  memMallocAlignedEM (size_t size)  
{
	void * pMem;

	pMem = memMallocAligned (&ExternalMemoryPool, size);

	if (pMem == NULL) 
	{
		pMem = memMallocAligned (&InternalMemoryPool, size);
		
		if (pMem == NULL)
		{
			pMem = memMallocEM (size);
		}
	}

	return pMem;
}


void    memFreeEM   (void * memblock)
{
	if (memIsEM(memblock))
	{
		memFree (&ExternalMemoryPool, memblock);
	}
	else
	{
		memFree (&InternalMemoryPool, memblock);
	}
}



bool    memIsAligned (void * memblock, size_t size)  
{
	UInt16     Modulo;
	UInt16     ModuloMask;
	
	Modulo = 1;
	while (size > Modulo)
	{
		Modulo = Modulo << 1;
	}
	ModuloMask = Modulo - 1;
	
	return (((UInt16)memblock & ModuloMask) == 0);
}

/*
// -----------------------------------------------------------------------------
//
//                                Mem
//
//	Description:
//		General-purpose ANSI C-compliant memory pool manager.
//
//	Author:
//		Mark Glenn
//
//	Design:
//		These routines manage a memory buffer that you specify, internally
//		called the pool.  Blocks of memory are allocated from and returned
//		to this pool.
//
//		The first UInt32 of every block is the size of the block
//		in bytes, inclusive.  This value is positive if the block is free,
//		negative if the block is in use, and zero if this is the last block
//		of the pool.
//
// -----------------------------------------------------------------------------
*/


/*
// sBlockHead -- The header for each memory block in a pool.
*/
typedef struct {
#ifdef MEM_CHECK_CORRUPTION
	/*
	// Marker -- Filled with 0xEE's to help detect memory corruption
	// of the previous block.
	*/
	UInt16 Marker;
#endif

	/*
	// Size -- The size of the block.  This includes the size of this sBlockHead.
	*/
	Int32 Size;

#ifdef MEM_CHECK_CORRUPTION
	/*
	// pFile -- Points to the file name of the program that allocated this
	// block.
	*/
	const char * pFile;

	/*
	// Line -- Line number within the file that allocated this block.
	*/
	UInt16 Line;

	/*
	// AllocNumber -- Each allocation bumps this number, starting with 1.
	// This gives you the opportunity to stop a debugger in the memory
	// allocator at the point that a particular allocation is made.
	*/
	UInt32 AllocNumber;
#endif

} sBlockHead;

/*
// -----------------------------------------------------------------------------
// sPool -- Holds the state of a memory pool.
//
// -----------------------------------------------------------------------------
*/
typedef struct {
#ifdef MEM_STATISTICS
	/*
	// Allocation statistics.  To allow them to be easily viewed from a memory
	// dump, we bracket the values with recognizable markers.
	*/
	UInt16 FreeMarkerBegin;        /* FFFF (Free) */
	UInt16 Free;
	UInt16 FreeBlocks;
	UInt16 FreeMarkerEnd;          /* FFFF (Free) */

	UInt16 AllocatedMarkerBegin;   /* AAAA (Allocated) */
	UInt16 Allocated;
	UInt16 AllocatedBlocks;
	UInt16 AllocatedMarkerEnd;     /* AAAA (Allocated) */

	UInt16 ContiguousMarkerBegin;  /* CCCC (Contiguous) */
	UInt16 LargestAvailable;
	UInt32 OriginalSize;
	UInt16 ContiguousMarkerEnd;    /* CCCC (Contiguous) */
#endif

	/*
	// pFirst -- Points to the first block of the pool.
	*/
	sBlockHead * pFirst;

	/*
	// pLast -- Points to the last block of the pool.
	*/
	sBlockHead * pLast;

	/*
	// pCurrent -- Points to a block within the pool.  It is used
	// to remain "close" to memory most likely to be free.  We could just
	// start from the beginning of the pool each time, but then we would
	// very likely have to skip over many in-use blocks, especially as
	// memory is allocated from a fresh pool.  We wrap to pFirst if
	// there isn't enough memory between pCurrent and the end of the pool,
	// to satisfy the request.
	*/
	sBlockHead * pCurrent;

	/*
	// Assert -- If set, aborts the program when the memory pool is
	// exhausted.  Otherwise, behave as ANSI requires.
	*/
	bool Assert;

	/*
	// Protect -- True if we are to mutex-protect the pool.
	*/
	bool Protect;

	/*
	// Lock -- Mutex for the memory pool.
	*/
#ifdef MEM_THREADED_OS
	pthread_mutex_t Lock;
#endif

#ifdef MEM_CHECK_CORRUPTION
	/*
	// AllocNumber -- Current count of the number of allocations done so
	// far.  This helps to diagnose corruption problems.
	*/
	UInt32 AllocNumber;
#endif
} sPool;
/*
// -----------------------------------------------------------------------------
//
//  memProtect
//
// -----------------------------------------------------------------------------
*/
extern void memProtect(mem_sPool * pMemPool)
{
	sPool * pPool = (sPool *) pMemPool;

#ifdef MEM_THREADED_OS
	int     Return;

	Return = pthread_mutex_init(&pPool -> Lock, (void *) NULL);
	assert(Return == 0);
#endif

	pPool -> Protect = true;
}


extern void memValidate(const mem_sPool * pMemPool)
{
#ifdef MEM_VALIDATE
	bool            bSatMode;
	sPool         * pPool   = (sPool *) pMemPool;
	sBlockHead    * pBlock  = pPool -> pFirst;
	UInt16          Blocks  = 0;

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_lock(&pPool -> Lock);
	}
#endif

	bSatMode = archGetSetSaturationMode (false);
	
	while (true) {
		Int32 CurrentSize = pBlock -> Size;

#ifdef MEM_CHECK_CORRUPTION
		{
			size_t AbsSize;
			AbsSize = CurrentSize < 0 ? -CurrentSize : CurrentSize;
			assert(pBlock -> Marker == 0xEEEE);
			assert(AbsSize == 0 || AbsSize > sizeof(sBlockHead));
			assert(((sBlockHead*)(((char*)pBlock)+AbsSize))->Marker==0xEEEE);
		}
#endif

		if (CurrentSize == 0) 
			break;

		if (CurrentSize < 0)
			CurrentSize = -CurrentSize;

		pBlock = (sBlockHead *) (((char *) pBlock) + CurrentSize);
		Blocks += 1;
	}

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_unlock(&pPool -> Lock);
	}
#endif

	archGetSetSaturationMode (bSatMode);

#endif
}

/*
// -----------------------------------------------------------------------------
// memCalculateStatistics 
//
// -----------------------------------------------------------------------------
*/
extern void memCalculateStatistics(mem_sPool * pMemPool)
{
#ifdef MEM_STATISTICS
	bool            bSatMode;
	sPool         * pPool = (sPool *) pMemPool;
	sBlockHead    * pBlock = pPool -> pFirst;
	Int32           TotalSize;
	UInt32          Size;

	pPool -> Allocated         = 0;
	pPool -> AllocatedBlocks   = 0;
	pPool -> Free              = 0;
	pPool -> FreeBlocks        = 0;
	pPool -> LargestAvailable  = 0;

#ifdef MEM_CHECK_CORRUPTION
	assert(pBlock -> Marker == 0xEEEE);
#endif

	bSatMode = archGetSetSaturationMode(false);
	
	while (TotalSize = pBlock -> Size, TotalSize != 0) {
		if (TotalSize < 0) {
			TotalSize = -TotalSize;
			Size      = TotalSize - sizeof(sBlockHead);

			pPool -> Allocated       += Size;
			pPool -> AllocatedBlocks += 1;
		}
		else {
			Size = TotalSize - sizeof(sBlockHead);
			
			pPool -> Free       += Size;
			pPool -> FreeBlocks += 1;

			if (Size > pPool -> LargestAvailable)
				pPool -> LargestAvailable = Size;
		}

		pBlock = (sBlockHead *) (((char *) pBlock) + TotalSize);
#ifdef MEM_CHECK_CORRUPTION
		assert(pBlock -> Marker == 0xEEEE);
#endif
	}
	
	archGetSetSaturationMode (bSatMode);
#endif
}

/*
// -----------------------------------------------------------------------------
// memPrintStatistics 
//
// -----------------------------------------------------------------------------
*/
extern void memPrintStatistics(mem_sPool * pMemPool)
{
	sPool * pPool = (sPool *) pMemPool;

	printf("Statistics for pool @: (%#010lx)\n", (unsigned long) pPool);
#ifdef MEM_STATISTICS
	memCalculateStatistics(pMemPool);
	printf("  Original pool size: %7lu (%#07lx)\n", 
											(unsigned long) pPool -> OriginalSize,
											(unsigned long) pPool -> OriginalSize);
	printf("\n");
	printf("  Allocated Space:    %7lu (%#07lx)\n",
											(unsigned long) pPool -> Allocated,
											(unsigned long) pPool -> Allocated);
	printf("  Allocated Blocks:   %7lu (%#07lx)\n",
											(unsigned long) pPool -> AllocatedBlocks,
											(unsigned long) pPool -> AllocatedBlocks);
	printf("\n");
	printf("  Free Space:         %7lu (%#07lx)\n",
											(unsigned long) pPool -> Free,
											(unsigned long) pPool -> Free);
	printf("  Free Blocks:        %7lu (%#07lx)\n",
											(unsigned long) pPool -> FreeBlocks,
											(unsigned long) pPool -> FreeBlocks);
	printf("  Largest Available:  %7lu (%#07lx)\n",
											(unsigned long) pPool -> LargestAvailable,
											(unsigned long) pPool -> LargestAvailable);
#else
	printf("  .../tools/mem.c not compiled with MEM_STATISTICS!\n");
#endif
}

/*
// -----------------------------------------------------------------------------
// memCleanUp 
//
// Starting from the beginning of the pool, merge blocks that are not in
// use.  Stop at the first in-use block.
// -----------------------------------------------------------------------------
*/
extern size_t memCleanUp(mem_sPool * pMemPool)
{
	bool            bSatMode;
	sPool         * pPool       = (sPool *) pMemPool;
	sBlockHead    * pBlock      = pPool -> pFirst;
	sBlockHead    * pFirstBlock = pBlock;
	Int32           TotalSize   = 0;
	Int32           Size;

	bSatMode = archGetSetSaturationMode(false);
	
	pPool -> pCurrent = pBlock;

	while (Size = pBlock -> Size, Size != 0) {
		if (Size < 0) 
			break;

		TotalSize += Size;

		pBlock = (sBlockHead *) (((char *) pBlock) + Size);
	}

	pFirstBlock -> Size = TotalSize;
	
	archGetSetSaturationMode(bSatMode);
	
	return TotalSize;
}

/*
// -----------------------------------------------------------------------------
// memPrintAllocatedBlocks
//
// -----------------------------------------------------------------------------
*/
extern void memPrintAllocatedBlocks(mem_sPool * pMemPool)
{
#ifdef MEM_LEAK_TEST
	bool         bSatMode;
	sPool      * pPool  = (sPool *) pMemPool;
	sBlockHead * pBlock = pPool -> pFirst;
	Int32        Size;
	FILE       * pFile;

	bSatMode = archGetSetSaturationMode(false);
	
#ifdef MEM_CHECK_CORRUPTION
	assert(pBlock -> Marker == 0xEEEE);
#endif

	pFile = fopen ("dump", "w");

	while (Size = pBlock -> Size, Size != 0) {
		if (Size < 0) {
			Size = -Size;

			fprintf(pFile, "%s(%d)\n---------\n", pBlock->pFile, pBlock->Line);			
			utilDump(pBlock + 1, Size - sizeof(sBlockHead), "addr", pFile);
			fprintf(pFile, "\n");
		}

		pBlock = (sBlockHead *) (((char *) pBlock) + Size);
#ifdef MEM_CHECK_CORRUPTION
		assert(pBlock -> Marker == 0xEEEE);
#endif
	}
	fclose(pFile);
	
	archGetSetSaturationMode(bSatMode);
#endif
}


/*
// -----------------------------------------------------------------------------
//
//  MergeFree
//     Assumes that pBlock points to a block not in-use.  Checks the
//     block following to determine its state.  If it is not in-use,
//     merge it to the current block.  pBlock will not change, but the 
//     size of the block to which it points may increase.  
//
// -----------------------------------------------------------------------------
*/
static Int32 MergeFree(sPool* pPool, sBlockHead * pBlock, Int32 SizeNeeded)
{
	bool  bSatMode;
	Int32 CurrentSize = pBlock -> Size;

	bSatMode = archGetSetSaturationMode(false);
	
	while (true) {
		sBlockHead * pNext;
		Int32        NextSize;

#ifdef MEM_CHECK_CORRUPTION
		{
			size_t AbsSize = CurrentSize < 0 ? -CurrentSize : CurrentSize;
			assert(pBlock -> Marker == 0xEEEE);
			assert(AbsSize == 0 || AbsSize > sizeof(sBlockHead));
			assert(((sBlockHead*)(((char*)pBlock)+AbsSize))->Marker==0xEEEE);
		}
#endif

		/*
		// Get a pointer to the next block and retrieve it's size.
		*/
		pNext     = ((sBlockHead *)(((char *) pBlock) + CurrentSize));
		NextSize  = pNext -> Size;

#ifdef MEM_CHECK_CORRUPTION
		{
			/*
			// Check the validity of the next block before we try to use it.
			*/
			size_t AbsSize = NextSize < 0 ? -NextSize : NextSize;
			assert(pNext -> Marker == 0xEEEE);
			assert(AbsSize == 0 || AbsSize > sizeof(sBlockHead));
			assert(((sBlockHead*)(((char*)pNext)+AbsSize))->Marker==0xEEEE);
		}
#endif

		/*
		// If the next block is in use or is the last block (Size == 0), return.
		*/
		if (NextSize <= 0) {
			pBlock -> Size = CurrentSize;
			archGetSetSaturationMode (bSatMode);
			return CurrentSize;
		}

#ifdef MEM_CHECK_CORRUPTION
		pNext -> Marker = 0x1111;
		pNext -> Size   = 0x1111;
#endif

#ifdef MEM_STATISTICS
		pPool -> FreeBlocks -= 1;
#endif

		/*
		// Increment the known size of the current block.  We won't store it
		// until we are about to leave the routine.
		*/
		CurrentSize += NextSize;

		/*
		// If pCurrent happens to point to the block that we are about
		// to combine, reset it to point to the beginning of the merged block.
		*/
		if (pNext == pPool -> pCurrent)
			pPool -> pCurrent = pBlock;

		/*
		// Optimized to get out as soon as we know we can satisfy the request.
		*/
		if (CurrentSize >= SizeNeeded) {
			pBlock -> Size = CurrentSize;
			archGetSetSaturationMode (bSatMode);
			return CurrentSize;
		}
	}
}
/*
// -----------------------------------------------------------------------------
//	SplitBlock
//
//		Assumes that pBlock points to a block larger than SizeNeeded.
// 	If the block is large enough to contain SizeNeeded plus another block,
//		the block is split.  The area returned to the user is the user 
//		portion of the first block.  The remainder in its entirety will 
//		be set to describe a not-in-use block.
//
// -----------------------------------------------------------------------------
*/
static void * SplitBlock(sPool * pPool, sBlockHead * pBlock, Int32 SizeNeeded)
{
	bool           bSatMode;
	Int32          Remainder;
	sBlockHead   * pUser     = pBlock + 1;
	Int32          BlockSize = pBlock -> Size;

	bSatMode = archGetSetSaturationMode(false);
	
	#ifdef ADDRESSING_8
		/*
		// Allocate in 4 8-bit units only.
		*/
		SizeNeeded = (SizeNeeded + 3) & ~3;
	#endif


	if ((Remainder = BlockSize - SizeNeeded) > sizeof(sBlockHead)) {
		/*
		// Set the size of the first part of the split.
		*/
		pBlock -> Size = -SizeNeeded;

#ifdef MEM_STATISTICS
		pPool -> Allocated       += SizeNeeded - sizeof(sBlockHead);
		pPool -> AllocatedBlocks += 1;
#endif

		/*
		// Point to the next block of the split.
		*/
		pBlock          = (sBlockHead *) ((char *) pBlock + SizeNeeded);
		pBlock -> Size  = Remainder;

#ifdef MEM_CHECK_CORRUPTION
		pBlock -> Marker    = 0xEEEE;
		pBlock -> pFile     = "";
		pBlock -> Line      = 0;
#endif

#ifdef MEM_STATISTICS
		pPool -> Free -= SizeNeeded;
#endif
	}
	else {
		/*
		// Don't split block.
		*/
		pBlock -> Size = -BlockSize;
		pBlock         = (sBlockHead *) ((char *) pBlock + BlockSize);

#ifdef MEM_STATISTICS
		pPool -> Allocated       += BlockSize - sizeof(sBlockHead);
		pPool -> AllocatedBlocks += 1;
		pPool -> Free            -= BlockSize;
		pPool -> FreeBlocks      -= 1;
#endif
	}

	/*
	// Store a pointer to a likely candidate block.
	*/
	pPool -> pCurrent = pBlock;
	archGetSetSaturationMode(bSatMode);
	return pUser;
}
/*
// -----------------------------------------------------------------------------
//	SplitBlockRev
//
//		Assumes that pBlock points to a block larger than SizeNeeded.
// 	If the block is large enough to contain SizeNeeded plus another block,
//		the block is split.  The area returned is the 
//		portion of the end of the block.  The remainder in its entirety will 
//		be set to describe a not-in-use block.
//
// -----------------------------------------------------------------------------
*/
static void * SplitBlockRev(sPool * pPool, sBlockHead * pBlock, UInt32 SizeNeeded)
{
	bool           bSatMode;
	Int32          Remainder;
	sBlockHead   * pUser;
	Int32          BlockSize = pBlock -> Size;

	bSatMode  = archGetSetSaturationMode(false);
	
	#ifdef ADDRESSING_8
		/*
		// Allocate in 4 8-bit units only.
		*/
		SizeNeeded &= ~3;
	#endif

	if (SizeNeeded > sizeof(sBlockHead)) {
		/*
		// Set the size of the user part of the split.
		*/
		pUser          = (sBlockHead *)(((char *)pBlock) + SizeNeeded);
		pUser -> Size  = BlockSize - SizeNeeded;
	
		pBlock -> Size = SizeNeeded;

#ifdef MEM_CHECK_CORRUPTION
		pUser -> Marker    = 0xEEEE;
		pUser -> pFile     = "";
		pUser -> Line      = 0;
#endif

#ifdef MEM_STATISTICS
		pPool -> Allocated       += SizeNeeded - sizeof(sBlockHead);
		pPool -> AllocatedBlocks += 1;
#endif

#ifdef MEM_STATISTICS
		pPool -> Free -= SizeNeeded;
#endif
	}
	else {
		pUser = pBlock;
	}

	/*
	// Store a pointer to a likely candidate block.
	*/
	archGetSetSaturationMode(bSatMode);
	return pUser;
}
/*
// -----------------------------------------------------------------------------
//  memInitializePool
//
//     Initializes the memory pool to all zeroes.  Brackets the pool with
//     two blocks: The last sizeof(UInt32) bytes will be set to 0 to
//     indicate the last block of the pool.  The first sizeof(UInt32) bytes
//     of the pool will be set to the size of the remainder of the pool.
//
// -----------------------------------------------------------------------------
*/
extern void memInitializePool(mem_sPool * pMemPool, 
										void      * pMem, 
										size_t      Size,
										bool        Protect, 
										bool        Assert)
{
	bool         bSatMode;
	sBlockHead * pFirst = (sBlockHead *)pMem;
	sBlockHead * pLast;
	sPool      * pPool = (sPool *) pMemPool;

	bSatMode = archGetSetSaturationMode(false);
	
	/*
	// Ensure that enough memory has been allocated
	*/
	assert (Size >= 2 * sizeof(sBlockHead));

	/*
	// Make sure that we've allocated enough space for the mem pool.
	*/
	assert(sizeof(mem_sPool) >= sizeof(sPool));

	/*
	// Clear the entire memory pool.  
	*/
	memset((void *)pFirst, 0, Size);

	/*
	// Mark the first block with the size of the entire allocatable memory
	// pool.  The size always includes the size of the sBlockHead.
	*/
	Size -= sizeof(*pLast);
	pFirst -> Size = Size;

#ifdef MEM_STATISTICS
	pPool -> OriginalSize          = Size;

	pPool -> FreeMarkerBegin       = 0xFFFF;
	pPool -> Free                  = Size;
	pPool -> FreeBlocks            = 1;
	pPool -> FreeMarkerEnd         = 0xFFFF;

	pPool -> AllocatedMarkerBegin  = 0xAAAA;
	pPool -> Allocated             = 0;
	pPool -> AllocatedBlocks       = 0;
	pPool -> AllocatedMarkerEnd    = 0xAAAA;

	pPool -> ContiguousMarkerBegin = 0xCCCC;
	pPool -> LargestAvailable      = Size;
	pPool -> ContiguousMarkerEnd   = 0xCCCC;
#endif

#ifdef MEM_CHECK_CORRUPTION
	pFirst -> Marker = 0xEEEE;
	pFirst -> pFile  = "";
	pFirst -> Line   = 0;
#endif

	/*
	// Point pLast to end of the memory pool and mark the end block with a 
	// zero end marker.
	*/
	pLast          = (sBlockHead *) ((char *) pFirst + Size);
	pLast -> Size  = 0;

#ifdef MEM_CHECK_CORRUPTION
	pLast -> Marker   = 0xEEEE;
	pLast -> pFile    = "";
	pLast -> Line     = 0;
#endif

	/*
	// If the user wants atomic access to this memory pool...
	*/
	if (Protect) {
		memProtect((mem_sPool *) pPool);
	}

	/*
	// Prime the memory pool.
	*/
	pPool -> Assert      = Assert;
	pPool -> pFirst      = pFirst;
	pPool -> pLast       = pLast;
	pPool -> pCurrent    = pFirst;
	pPool -> Protect     = Protect;

#ifdef MEM_CHECK_CORRUPTION
	pPool -> AllocNumber = 0;
#endif

#ifdef MEM_FILL
	memset(pFirst + 1, (char) 0xFFFF, Size - sizeof(*pFirst));
#endif

	archGetSetSaturationMode(bSatMode);
}
/*
// -----------------------------------------------------------------------------
//  memExtendPool
//
//     Initializes the memory pool extension to all zeroes.  Extends the
//     pool previously initialized with memInitializePool.
//
// -----------------------------------------------------------------------------
*/
void memExtendPool ( mem_sPool * pMemPool, 
							void      * pMem, 
							size_t      Size
							)
{
	bool         bSatMode;
	sBlockHead * pFirst = (sBlockHead *)pMem;
	sBlockHead * pLast;
	sBlockHead * pTemp;
	sBlockHead * pNext;
	sPool      * pPool  = (sPool *) pMemPool;

	bSatMode = archGetSetSaturationMode(false);
	
	/*
	// Ensure that enough memory has been allocated
	*/
	assert (Size >= 2 * sizeof(sBlockHead));

#if 0
	/*
	// Do a memory test on this memory pool partition  
	*/
	{ 	volatile UInt16 * pWord;
		size_t   i;
		
		pWord = (UInt16 *)pMem;
		for (i=0; i<Size; i++)
		{
			*pWord = 0xA5A5;
			assert (*pWord == 0xA5A5);
			*pWord = 0x5A5A;
			assert (*pWord == 0x5a5a);
			*pWord = (UInt16)pWord;
			pWord++;
		}
		pWord = (UInt16 *)pMem;
		for (i=0; i<Size; i++)
		{
			assert (*pWord == (UInt16)pWord);
			pWord++;
		}
	}
#endif
	
	/*
	// Clear the entire memory pool.  
	*/
	memset((void *)pFirst, 0, Size);

	/*
	// Mark the first block with the size of the entire extension
	// The size always includes the size of the sBlockHead.
	*/
	Size -= sizeof(*pLast);
	pFirst -> Size = Size;

#ifdef MEM_STATISTICS
	pPool -> OriginalSize          += Size;
	pPool -> Free                  += Size;
	pPool -> FreeBlocks            += 1;

	if (Size > pPool -> LargestAvailable)
	{
		pPool -> LargestAvailable    = Size;
	}
#endif

#ifdef MEM_CHECK_CORRUPTION
	pFirst -> Marker = 0xEEEE;
	pFirst -> pFile  = "";
	pFirst -> Line   = 0;
#endif

	/*
	// Point pLast to end of the memory pool and mark the end block with a 
	// zero end marker.
	*/
	pLast         = (sBlockHead *) ((char *) pFirst + Size);

#ifdef MEM_CHECK_CORRUPTION
	pLast -> Marker   = 0xEEEE;
	pLast -> pFile    = "";
	pLast -> Line     = 0;
#endif

	/* 
	// Link the extension into the pool 
	*/
	if (pLast < pPool->pFirst)
	{
		pLast->Size   = (UInt32)pLast - (UInt32)(pPool->pFirst);
		pPool->pFirst = pFirst;
	}
	else if (pFirst > pPool->pLast)
	{
		pPool->pLast->Size = ((UInt32)pPool->pLast) - ((UInt32)pFirst);
		pLast->Size  = 0;
		pPool->pLast = pLast;
	}
	else
	{
		pTemp = pPool->pFirst;
		
		while (true)
		{
			if (pTemp->Size > 0)
			{
				pTemp = (sBlockHead *)(((char *)pTemp) + pTemp->Size);
			} 
			else 
			{
				pNext = (sBlockHead *)(((char *)pTemp) - pTemp->Size);
			
				if (pFirst > pTemp && pLast < pNext)
				{
					pTemp->Size = (UInt32)pTemp - (UInt32)pFirst;
					pLast->Size = (UInt32)pLast - (UInt32)pNext;
					break;
				}
				
				pTemp = pNext;
			}		
		}
	}

#ifdef MEM_FILL
	memset(pFirst + 1, (char) 0xFFFF, Size - sizeof(*pFirst));
#endif

	archGetSetSaturationMode (bSatMode);
}
/*
// -----------------------------------------------------------------------------
// memFree
//
// -----------------------------------------------------------------------------
*/
extern void memFree(mem_sPool * pMemPool, void * pData)
{
	bool         bSatMode;
	sBlockHead * pBlock = pData;

	/* 
		The following two lines are a check to ensure that
		dynamic memory has been enabled in the SDK application.
		If the user has failed to either "#define INCLUDE_MEMORY"
		in the appconfig.h file or include a dynamic memory
		partition list in the linker.cmd file, he will now get
		a link error.
	*/
		
	extern UInt16 memNumEMpartitions;
	bSatMode = memNumEMpartitions;

	assert (bMemInitialized);
	
#ifdef MEM_VALIDATE
	memValidate(pMemPool);
#endif

	/* 
	// If pData is NULL, return, per ANSI C.
	*/
	if (pData == NULL)
		return;

	bSatMode = archGetSetSaturationMode(false);
	
	pBlock -= 1;

	if (pBlock -> Size > 0) {
		assert(!"Attempt to free memory never allocated or previously freed");
	}

#ifdef MEM_CHECK_CORRUPTION
	{
		size_t AbsSize = -(pBlock -> Size);
		assert(pBlock -> Marker == 0xEEEE);
		assert(AbsSize == 0 || AbsSize > sizeof(sBlockHead));
		assert(((sBlockHead*)(((char*)pBlock)+AbsSize))->Marker==0xEEEE);
	}
#endif

#ifdef MEM_STATISTICS
		{
			sPool * pPool  = (sPool *) pMemPool;
			pPool -> Free            += (-pBlock -> Size);
			pPool -> FreeBlocks      += 1;
			pPool -> Allocated       -= (-pBlock -> Size) - sizeof(sBlockHead);
			pPool -> AllocatedBlocks -= 1;
		}
#endif

#ifdef MEM_FILL
	memset(pBlock + 1, (char) 0xFFFF, -(pBlock -> Size)-sizeof(sBlockHead));
#endif

	/*
	// Make the block available.
	*/
	pBlock -> Size = -(pBlock -> Size);
	
	archGetSetSaturationMode (bSatMode);
}
/*
// -----------------------------------------------------------------------------
//  memMallocWrapper
//
// -----------------------------------------------------------------------------
*/
extern void * memMallocWrapper(mem_sPool * pPool, size_t Size,
																const char *pFile, int Line)
{
	void       * pData;

	/*
	// Call the base allocator.  We use the parenthesis to prevent the 
	// preprocessor from substituting memMalloc with memMallocWrapper,
	// causing endless recursion into this routine.
	*/
	pData = (memMalloc)(pPool, Size);

	if (pData == NULL)
		return (void *) NULL;

#ifdef MEM_CHECK_CORRUPTION
	{
		sBlockHead * pBlock = pData;
		/* 
		// Back up to the beginning of the memory block's header.
		*/
		pBlock -= 1;

		/*
		// Initialize the block with useful bug-catching and reporting 
		// information.  Don't touch member Size, it is owned by the 
		// underlying memory manager.
		*/
		pBlock -> pFile    = pFile;
		pBlock -> Line     = Line;
	}
#endif

	return pData;
}
/*
// -----------------------------------------------------------------------------
//
//  memMalloc
//     If the size requested is 0, return NULL, per ANSI C.
//
//  LABEL:
//     WHILE we haven't yet allocated a block DO
//       Skip blocks in use.
//
//       IF we hit the tail block of the pool THEN
//         IF we have already wrapped through the pool once THEN
//           return NULL to indicate failure to allocate.
//         ELSE
//           Reset the block pointer to the first block of the pool.
//           Indicate that we have wrapped around.
//           Continue from LABEL.
//       ENDIF
//
//       Merge all contiguous free blocks from the current block to the
//         first in-use block or the end of the pool.
//       IF the consolidated block satisfies the request THEN
//         Split the block, if it is large enough and return the first block
//           of the split.
//       ENDIF
//
//       Bump the block search pointer to the next block
//     ENDWHILE
//
// -----------------------------------------------------------------------------
*/
void * (memMalloc)(mem_sPool * pMemPool, size_t Size)
{
	bool         bSatMode;
	Int32        SizeNeeded = (Int32) Size;
	Int32        BlockSize;
	int          Wrapped;
	sBlockHead * pBlock;
	void       * pMemory    = (void *) NULL;
	sPool      * pPool      = (sPool *) pMemPool;

	/* 
		The following two lines are a check to ensure that
		dynamic memory has been enabled in the SDK application.
		If the user has failed to either "#define INCLUDE_MEMORY"
		in the appconfig.h file or include a dynamic memory
		partition list in the linker.cmd file, he will now get
		a link error.
	*/	
	extern UInt16 memNumEMpartitions;
	BlockSize = memNumEMpartitions;

	if(bMemInitialized == false)
	{
		Initialize();
	}
	
#ifdef MEM_VALIDATE
	memValidate(pMemPool);
#endif

	if (SizeNeeded == 0)
		return (void *) NULL;
		
	bSatMode = archGetSetSaturationMode(false);
	
#ifdef ADDRESSING_8
	/*
	// Allocate in 4 8-bit units only.
	*/
	SizeNeeded = ((SizeNeeded + 3) & ~3);
#endif

	SizeNeeded += sizeof(sBlockHead);

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_lock(&pPool -> Lock);
	}
#endif

	pBlock  = pPool -> pCurrent;
	Wrapped = false;

	while (true) {
		/*
		// Skip blocks in use.
		*/
		while (true) {
			BlockSize = pBlock -> Size;

#ifdef MEM_CHECK_CORRUPTION
			{
				size_t Abs = BlockSize < 0 ? -BlockSize : BlockSize;
				assert(pBlock -> Marker == 0xEEEE);
				assert(Abs == 0 || Abs > sizeof(sBlockHead));
				assert(((sBlockHead*)(((char*)pBlock)+Abs))->Marker==0xEEEE);
			}
#endif

			if (BlockSize >= 0)
				break;

			pBlock = (sBlockHead *) (((char *) pBlock) + -BlockSize);
		}

		/*
		// Found a block that is not in use.  If it's the last block of the pool,
		// wrap to the beginning. If we reach the end after wrapping, then we're
		// out of memory.
		*/
		if (BlockSize == 0) {
			if (Wrapped) {
				break;
			}

			pBlock  = pPool -> pFirst;
			Wrapped = true;
			continue;
		}

		/*
		// We're now at a block that is not in use.  We optimize for
		// the hopeful case, where the current blocksize is big 
		// enough and we don't have to make a costly call to merge
		// free blocks.  If the block is big enough, we split it
		// and leave the loop. 
		*/
		if (BlockSize >= SizeNeeded) {
			pMemory = SplitBlock(pPool, pBlock, SizeNeeded);
			break;
		}

		/* 
		// Merge free blocks that immediately follow this one in an
		// attempt to make the current block big enough.
		*/
		BlockSize = MergeFree(pPool, pBlock, SizeNeeded);

		/* If the (now merged) free block is big enough, we split it in two 
		// if the remainder is big enough to make it worthwhile.  
		//
		// If the block still isn't big enough, at least we made a bigger
		// free block that will make for faster allocations later.
		*/
		if (BlockSize >= SizeNeeded) {
			pMemory = SplitBlock(pPool, pBlock, SizeNeeded);
			break;
		}

		/*
		// Move to the next candidate block and loop back up to try again
		*/
		pBlock = (sBlockHead *) ((char *) pBlock + BlockSize);
	}

#ifdef MEM_CHECK_CORRUPTION
	pBlock-> AllocNumber = ++pPool -> AllocNumber;
#endif

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_unlock(&pPool -> Lock);
	}
#endif

	if (pPool -> Assert && pMemory == NULL) {
#ifdef MEM_STATISTICS
		printf("\n");
		printf("Not enough memory to allocate %lu (%#07lx) bytes!!\n",
										(unsigned long) Size, (unsigned long) Size);
		memPrintStatistics((mem_sPool*)pPool);
		printf("\n");
#endif

#ifdef MEM_VERBOSE
		memPrintAllocatedBlocks(pMemPool);
#endif
		assert(!"Out of Memory");
	}

	archGetSetSaturationMode(bSatMode);
	
	if (pMemory == NULL)
		return (void *) NULL;

#ifdef MEM_FILL
	memset(pMemory, (char) 0xAAAA, -(pBlock -> Size) - sizeof(sBlockHead));
#endif

#ifdef MEM_CHECK_CORRUPTION
	pBlock -> Marker = 0xEEEE;
	pBlock -> pFile  = NULL;
	pBlock -> Line   = 0;
#endif

	return pMemory;
}
/*
// -----------------------------------------------------------------------------
//
//  memMallocAligned
//     Allocate memory aligned so that it ends on a 2**k boundary.
//
//     If the size requested is 0, return NULL, per ANSI C.
//
//  LABEL:
//     WHILE we haven't yet allocated a block DO
//       Skip blocks in use.
//
//       IF we hit the tail block of the pool THEN
//         IF we have already wrapped through the pool once THEN
//           return NULL to indicate failure to allocate.
//         ELSE
//           Reset the block pointer to the first block of the pool.
//           Indicate that we have wrapped around.
//           Continue from LABEL.
//       ENDIF
//
//       Merge all contiguous free blocks from the current block to the
//         first in-use block or the end of the pool.
//       IF the consolidated block satisfies the request THEN
//         Split the block, if it is large enough, and return the 
//           aligned block of the split.
//       ENDIF
//
//       Bump the block search pointer to the next block
//     ENDWHILE
//
// -----------------------------------------------------------------------------
*/
void * (memMallocAligned)(mem_sPool * pMemPool, size_t Size)
{
	bool         bSatMode;
	Int32        SizeNeeded = (Int32) Size;
	Int32        BlockSize;
	int          Wrapped;
	sBlockHead * pBlock;
	void       * pMemory    = (void *) NULL;
	sPool      * pPool      = (sPool *) pMemPool;
	UInt32		 Modulo;
	UInt32       ModuloMask;
	sBlockHead * pStartOfModBuffer;
	sBlockHead * pEndOfModBuffer;
	Int32        SpareWords;

	if(bMemInitialized == false)
	{
		Initialize();
	}
	
#ifdef MEM_VALIDATE
	memValidate(pMemPool);
#endif

	if (SizeNeeded == 0)
		return (void *) NULL;

	bSatMode = archGetSetSaturationMode(false);
	
	Modulo = 1;
	while (SizeNeeded > Modulo)
	{
		Modulo = Modulo << 1;
	}
	ModuloMask = Modulo - 1;
	ModuloMask = ~ ModuloMask;
		
#ifdef ADDRESSING_8
	/*
	// Allocate in 4 8-bit units only.
	*/
	SizeNeeded = ((SizeNeeded + 3) & ~3);
#endif

	SizeNeeded += sizeof(sBlockHead);

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_lock(&pPool -> Lock);
	}
#endif

	pBlock  = pPool -> pCurrent;
	Wrapped = false;

	while (true) {
		/*
		// Skip blocks in use.
		*/
		while (true) {
			BlockSize = pBlock -> Size;

#ifdef MEM_CHECK_CORRUPTION
			{
				size_t Abs = BlockSize < 0 ? -BlockSize : BlockSize;
				assert(pBlock -> Marker == 0xEEEE);
				assert(Abs == 0 || Abs > sizeof(sBlockHead));
				assert(((sBlockHead*)(((char*)pBlock)+Abs))->Marker==0xEEEE);
			}
#endif

			if (BlockSize >= 0)
				break;

			pBlock = (sBlockHead *) (((char *) pBlock) + -BlockSize);
		}

		/*
		// Found a block that is not in use.  If it's the last block of the pool,
		// wrap to the beginning. If we reach the end after wrapping, then we're
		// out of memory.
		*/
		if (BlockSize == 0) {
			if (Wrapped) {
				break;
			}

			pBlock  = pPool -> pFirst;
			Wrapped = true;
			continue;
		}

		/* 
		// Merge free blocks that immediately follow this one in an
		// attempt to make the current block big enough;  ask for 2 * SizeNeeded
		// in order to bracket an aligned area
		*/
		BlockSize = MergeFree(pPool, pBlock, SizeNeeded+SizeNeeded);

		/* If the (now merged) free block is big enough, we split it in two 
		// if the remainder is big enough to make it worthwhile.  
		//
		// If the block still isn't big enough, at least we made a bigger
		// free block that will make for faster allocations later.
		*/
		if (BlockSize >= SizeNeeded) {
			pStartOfModBuffer = (sBlockHead *)(((((UInt32)pBlock) + Modulo  - 1)
															& ModuloMask) - sizeof(sBlockHead));
			
			while (true) 
			{
				SpareWords = ((UInt32)pStartOfModBuffer) - ((UInt32)pBlock);
				if ((SpareWords == 0) || (SpareWords >= sizeof(sBlockHead)))
				{
					break;
				}
				pStartOfModBuffer = (sBlockHead *)(((UInt32)pStartOfModBuffer) + Modulo);
			}
			pEndOfModBuffer = (sBlockHead *)(((UInt32)pStartOfModBuffer) + SizeNeeded - 1);
															
			if (pEndOfModBuffer < (sBlockHead *)(((UInt32)pBlock) + BlockSize))
			{
				pMemory = SplitBlockRev(pPool, 
												pBlock, 
												SpareWords);
				pMemory = SplitBlock   (pPool, 
												pMemory, 
												SizeNeeded);
				break;
			}
		}

		/*
		// Move to the next candidate block and loop back up to try again
		*/
		pBlock = (sBlockHead *) ((char *) pBlock + BlockSize);
	}

#ifdef MEM_CHECK_CORRUPTION
	pBlock-> AllocNumber = ++pPool -> AllocNumber;
#endif

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_unlock(&pPool -> Lock);
	}
#endif

	if (pPool -> Assert && pMemory == NULL) {
#ifdef MEM_STATISTICS
		printf("\n");
		printf("Not enough memory to allocate %lu (%#07lx) bytes!!\n",
										(unsigned long) Size, (unsigned long) Size);
		memPrintStatistics((mem_sPool*)pPool);
		printf("\n");
#endif

#ifdef MEM_VERBOSE
		memPrintAllocatedBlocks(pMemPool);
#endif
		assert(!"Out of Memory");
	}

	archGetSetSaturationMode (bSatMode);
	
	if (pMemory == NULL)
		return (void *) NULL;

#ifdef MEM_FILL
	memset(pMemory, (char) 0xAAAA, -(pBlock -> Size) - sizeof(sBlockHead));
#endif

#ifdef MEM_CHECK_CORRUPTION
	pBlock -> Marker = 0xEEEE;
	pBlock -> pFile  = NULL;
	pBlock -> Line   = 0;
#endif

	return pMemory;
}
/*
// =============================================================================
// memRealloc
//
// =============================================================================
*/
extern void * memRealloc(mem_sPool * pMemPool,void * pData,
																			size_t SizeRequested)
{
	bool           bSatMode;
	Int32          OriginalSize;
	Int32          SizeNeeded;
	Int32          Size = (Int32) SizeRequested;
	sBlockHead    * pBlock = (sBlockHead *) pData;
	void          * pMem;
	sPool         * pPool = (sPool *) pMemPool;

	if(bMemInitialized == false)
	{
		Initialize();
	}
	
#ifdef MEM_VALIDATE
	memValidate(pMemPool);
#endif

	if (Size == 0) {
		memFree(pMemPool, pData);
		return (void *) NULL;
	}

	if (pData == NULL) {
		return (memMalloc)(pMemPool, Size);
	}

	bSatMode = archGetSetSaturationMode(false);
	
	/*
	// Back up to the block's header.
	*/
	pBlock -= 1;

#ifdef MEM_CHECK_CORRUPTION
	assert(pBlock -> Marker == 0xEEEE);
	assert(pBlock -> Size < 0);
#endif

#ifdef ADDRESSING_8
	/*
	// Allocate in 4 complete 8-bit units only.
	*/
	SizeNeeded = ((Size + 3) & ~3);
#else
	SizeNeeded = Size;
#endif

	SizeNeeded += sizeof(sBlockHead);

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_lock(&pPool -> Lock);
	}
#endif

	pBlock -> Size = -(pBlock -> Size);
	OriginalSize = pBlock -> Size - sizeof(sBlockHead);

	/*
	// Merge free memory blocks immediately following the one pointed to 
	// by pBlock to see if we can avoid having to copy the data.
	*/
	if (MergeFree(pPool, pBlock, SizeNeeded) >= SizeNeeded) {
		pMem = SplitBlock(pPool, pBlock, SizeNeeded);
	}
	else {
		pMem = (void *) NULL;
		pBlock -> Size = -(pBlock -> Size);
	}

#ifdef MEM_THREADED_OS
	if (pPool -> Protect) {
		pthread_mutex_unlock(&pPool -> Lock);
	}
#endif

	archGetSetSaturationMode (bSatMode);
	
	/*
	// If the allocation was successful, we're done.
	*/
	if (pMem != NULL) {
		return pMem;
	}

	/*
	// We were not able to extend the block in place.  Now we have to 
	// allocate a brand new block.
	*/
	if ((pMem = (memMalloc)(pMemPool, Size)) == NULL)  {
		return (void *) NULL;
	}

	/*
	// Copy the data from the old memory area to the new.  If the new
	// block is larger than the old block, copy all the original data.
	// If the new size is smaller (the user is trimming the data), only 
	// copy as much old data as will fit into the new area.
	*/
	memcpy(pMem, pData, Size < OriginalSize ? Size : OriginalSize);

	/* 
	// Once the original data is copied to the new memory, free the 
	// original memory.
	*/
	memFree(pMemPool, pData);
	return pMem;
}
/*
// =============================================================================
// memCalloc
//
// =============================================================================
*/
extern void * memCalloc(mem_sPool * pPool, size_t Elements,
																			size_t ElementSize)
{
	size_t      TotalSize = Elements * ElementSize;
	void      * pMemory   = (memMalloc)(pPool, TotalSize);

	if (pMemory == (void *) NULL)
		return (void *) NULL;

	memset(pMemory, 0, TotalSize);
	return pMemory;
}
/*
// =============================================================================
// memMemset
//
// =============================================================================
*/

#if 0
/* LS000218 - Replaced with ASM routine */
void * memMemset (void *dest, int c, size_t count)
{
#pragma interrupt
	int    i;
	char * pDest = (char *)dest;
	
	for (i=0; i<count; i++)
	{
		*pDest++ = c;
	}
	return dest;
}
#endif



static sBlockHead EmptyInternalMemoryPool[2];
static sBlockHead EmptyExternalMemoryPool[2];

static void Initialize (void)
{
	UInt16                 i;
	const mem_sPartition * pPartitionList;

	/* Initialize empty pools */	
	memInitializePool (  &InternalMemoryPool, 
								EmptyInternalMemoryPool, 
								sizeof (EmptyInternalMemoryPool),
								false,
								false
							);

	memInitializePool (  &ExternalMemoryPool, 
								EmptyExternalMemoryPool, 
								sizeof (EmptyExternalMemoryPool),
								false,
								false
							);
							
	switch (InitialState.EXbit)
	{
		case 0:

				/* Clear EX bit in OMR */
				asm(bfclr  #$0008,OMR);

				pPartitionList = InitialState.intPartitionList;
				
				for (i=0; i<InitialState.numIntPartitions; i++)
				{
					assert (memIsIM(pPartitionList -> partitionAddr));
					
					memExtendPool (&InternalMemoryPool, 
										pPartitionList -> partitionAddr, 
										pPartitionList -> partitionSize
										);
					pPartitionList++;
				}

				pPartitionList = InitialState.extPartitionList;
				
				for (i=0; i<InitialState.numExtPartitions; i++)
				{
					assert (memIsEM(pPartitionList -> partitionAddr));
					
					memExtendPool (&ExternalMemoryPool, 
										pPartitionList -> partitionAddr, 
										pPartitionList -> partitionSize
										);
					pPartitionList++;
				}
				break;

	
		case 1:
			
				/* Set EX bit in OMR */
				asm(bfset  #$0008,OMR);

				/* 
					Ensure that no internal partitions were specified
					with the external memory map
				*/
				assert (InitialState.numIntPartitions == 0);
				
				pPartitionList = InitialState.extPartitionList;
				
				for (i=0; i<InitialState.numExtPartitions; i++)
				{
					assert (memIsEM(pPartitionList -> partitionAddr));
					
					memExtendPool (&ExternalMemoryPool, 
										pPartitionList -> partitionAddr, 
										pPartitionList -> partitionSize
										);
					pPartitionList++;
				}
					
				break;
				
		default:
			
				assert (false);
				break;
	}
	
	bMemInitialized = true;

}

EXPORT void    memInitialize (mem_sState * pMemoryState)
{
	memcpy((void *)&InitialState, (const void *)pMemoryState, sizeof(mem_sState));
}







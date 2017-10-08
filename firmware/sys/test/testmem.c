#include "port.h"
#include "arch.h"
#include "test.h"
#include "prototype.h"
#include "stdio.h"
#include "mem.h"
#include "appconst.h"

/*-----------------------------------------------------------------------*

    testmem.c  -  test mem.* files
	
*------------------------------------------------------------------------*/

extern int  PConstData16[4];
extern long PConstData32[8];
extern int  PData16[4];
extern long PData32[8];

extern int  PConstData16C[4];
extern long PConstData32C[8];
extern int  PData16C[4];
extern long PData32C[8];

Result testmem(test_sRec *);

Result testmem(test_sRec *pTestRec)
{
	void    * allocations[1000];
	UInt16    numAllocations;
	int       i, j;
	char      s[256];
	void *    pTemp;
		
	long LocalTemp32 [8];


	testStart (pTestRec, "Test mem.* files");
	
	testComment (pTestRec, "Please wait -- this test takes 5 minutes in the simulator");

	/*****************************************/
   /* Test memMemset                        */
	/*****************************************/

	testComment (pTestRec, "Testing memset");
	
	for (i=0; i<sizeof(s); i++)
	{
		s[i] = 0;
	}
	
	memMemset (s, 0x1234, sizeof(s)-1);

	if (s[sizeof(s)-1] != 0)
	{
		testFailed(pTestRec, "memMemset overrun");
	}
		
	for (i=0; i<sizeof(s)-1; i++)
	{
		if (s[i] != 0x1234)
		{
			testFailed(pTestRec, "memMemset did not work");
		}
	}
	
	memset (s, 0x4321, sizeof(s)-1);

	if (s[sizeof(s)-1] != 0)
	{
		testFailed(pTestRec, "memset overrun");
	}
		
	for (i=0; i<sizeof(s)-1; i++)
	{
		if (s[i] != 0x4321)
		{
			testFailed(pTestRec, "memset did not work");
		}
	}
	
	
	/*****************************************/
   /* Test memMemcpy                        */
	/*****************************************/

	testComment (pTestRec, "Testing memcpy");
	
	for (i=0; i<sizeof(s); i++)
	{
		s[i] = 0;
	}
	
	memMemset ((void *)s, 0x1234, sizeof(s)/2);
	memMemcpy ((void *)(&s[sizeof(s)/2]), (void *)(s), sizeof(s)/2-1); 

	if (s[sizeof(s)-1] != 0)
	{
		testFailed(pTestRec, "memMemcpy overrun");
	}
		
	for (i=0; i<sizeof(s)-1; i++)
	{
		if (s[i] != 0x1234)
		{
			testFailed(pTestRec, "memMemcpy did not work");
			break;
		}
	}
	
	memset ((void *)(&s[sizeof(s)/2]), 0x4321, sizeof(s)/2-1);
	memcpy ((void *)s, (void *)(&s[sizeof(s)/2]), sizeof(s)/2-1);

	for (i=0; i<sizeof(s)/2-1; i++)
	{
		if (s[i] != 0x4321)
		{
			testFailed(pTestRec, "memcpy did not work");
			break;
		}
	}
	
	
	/*****************************************/
   /* Test P memory routines on ASM data    */
	/*****************************************/

	testComment (pTestRec, "Testing P mem routines on data allocated in ASM");
	
	for (i=0; i<sizeof(PConstData16); i++)
	{
		if (memReadP16((UWord16 *)&PConstData16[i]) != LocalPData16[i])
		{
			testFailed (pTestRec, "memReadP16 failed");
			break;
		}
	}

	for (i=0; i<sizeof(PConstData32)/sizeof(long); i++)
	{
		if (memReadP32((UWord32 *)&PConstData32[i]) != LocalPData32[i])
		{
			testFailed (pTestRec, "memReadP32 failed");
			break;
		}
	}
	
	for (i=0; i<sizeof(LocalPData16); i++)
	{
		memWriteP16 (LocalPData16[i], (Word16 *)&PData16[i]);
	}

	for (i=0; i<sizeof(LocalPData16); i++)
	{
		if (memReadP16((UWord16 *)&PData16[i]) != LocalPData16[i])
		{
			testFailed (pTestRec, "memWriteP16 failed");
			break;
		}
	}

	for (i=0; i<sizeof(LocalPData32)/sizeof(long); i++)
	{
		memWriteP32 (LocalPData32[i], &PData32[i]);
	}
	
	for (i=0; i<sizeof(LocalPData32)/sizeof(long); i++)
	{
		if (memReadP32((UWord32 *)&PData32[i]) != LocalPData32[i])
		{
			testFailed (pTestRec, "memWriteP32 failed");
			break;
		}
	}

	pTemp = memCopyPtoX ((void *)LocalTemp32, 
								(void *)PConstData32, 
								sizeof(PConstData32) - sizeof(long));
								
	if (pTemp != &LocalTemp32[7])
	{
		testFailed (pTestRec, "memCpyFromP pointer update");
	}
	
	for (i=0; i<(sizeof(LocalTemp32)-sizeof(long))/sizeof(long); i++)
	{
		if (LocalTemp32[i] != LocalPData32[i])
		{
			testFailed (pTestRec, "memCpyFromP failed");
		}
	}
								
	pTemp = memCopyXtoP ( (void *)PData32, 
							  (void *)LocalTemp32, 
							  sizeof(LocalTemp32) - sizeof(long) );

	if (pTemp != &PData32[7])
	{
		testFailed (pTestRec, "memCpyToP pointer update");
	}
	
	for (i=0; i<(sizeof(LocalTemp32)-sizeof(long))/sizeof(long); i++)
	{
		if (LocalTemp32[i] != memReadP32((UWord32 *)&PData32[i]))
		{
			testFailed (pTestRec, "memCpyFromP failed");
		}
	}
								

	/*****************************************/
   /* Test P memory routines on C data      */
	/*****************************************/

	testComment (pTestRec, "Testing P mem routines on data allocated in C");
	
	for (i=0; i<sizeof(PConstData16C); i++)
	{
		if (memReadP16((UWord16 *)&PConstData16C[i]) != LocalPData16[i])
		{
			testFailed (pTestRec, "memReadP16 failed");
			break;
		}
	}

	for (i=0; i<sizeof(PConstData32C)/sizeof(long); i++)
	{
		if (memReadP32((UWord32 *)&PConstData32C[i]) != LocalPData32[i])
		{
			testFailed (pTestRec, "memReadP32 failed");
			break;
		}
	}
	
	for (i=0; i<sizeof(LocalPData16); i++)
	{
		memWriteP16 (LocalPData16[i], (Word16 *)&PData16C[i]);
	}

	for (i=0; i<sizeof(LocalPData16); i++)
	{
		if (memReadP16((UWord16 *)&PData16C[i]) != LocalPData16[i])
		{
			testFailed (pTestRec, "memWriteP16 failed");
			break;
		}
	}

	for (i=0; i<sizeof(LocalPData32)/sizeof(long); i++)
	{
		memWriteP32 (LocalPData32[i], &PData32C[i]);
	}
	
	for (i=0; i<sizeof(LocalPData16); i++)
	{
		if (memReadP32((UWord32 *)&PData32C[i]) != LocalPData32[i])
		{
			testFailed (pTestRec, "memWriteP32 failed");
			break;
		}
	}

	pTemp = memCopyPtoX ((void *)LocalTemp32, 
								(void *)PConstData32C, 
								sizeof(PConstData32C) - sizeof(long));
								
	if (pTemp != &LocalTemp32[7])
	{
		testFailed (pTestRec, "memCpyFromP pointer update");
	}
	
	for (i=0; i<(sizeof(LocalTemp32)-sizeof(long))/sizeof(long); i++)
	{
		if (LocalTemp32[i] != LocalPData32[i])
		{
			testFailed (pTestRec, "memCpyFromP failed");
		}
	}
								
	pTemp = memCopyXtoP ( (void *)PData32C, 
							  (void *)LocalTemp32, 
							  sizeof(LocalTemp32) - sizeof(long) );

	if (pTemp != &PData32C[7])
	{
		testFailed (pTestRec, "memCpyToP pointer update");
	}
	
	for (i=0; i<(sizeof(LocalTemp32)-sizeof(long))/sizeof(long); i++)
	{
		if (LocalTemp32[i] != memReadP32((UWord32 *)&PData32C[i]))
		{
			testFailed (pTestRec, "memCpyFromP failed");
		}
	}
								

	/**********************************/
   /* Test memMallocEM and memFreeEM */
	/**********************************/
		
	testComment (pTestRec, "Testing memMallocEM");
	
	/* 
		Beware of this magic number (4050) which assumes that 0x1000 was allocated to 
		external memory.
	*/
	pTemp = memMallocEM(4050);
		
	if (pTemp == NULL) 
	{
		testFailed(pTestRec, "Insufficient external memory was originally allocated");
	}
	memFreeEM (pTemp);

	for (i=0; i<10; i++)
	{
		for (j=1; j<1000; j++)
		{
			allocations[j] = memMallocEM (j);
			
			if (allocations[j] == NULL) 
			{
				break;
			}
		}
		numAllocations = j;
							
		for (j=1; j<numAllocations; j++)
		{
			memFreeEM (allocations[j]);
		}
		
		/* 
			Beware of this magic number (4050) which assumes that 0x1000 was allocated to 
			external memory.
		*/
		pTemp = memMallocEM(4050);
		
		if (pTemp == NULL || !memIsEM (pTemp)) 
		{
			testFailed(pTestRec, "Not all externally allocated data was freed");
		}
		memFreeEM (pTemp);
		
		if (numAllocations <= 0) 
		{
			testFailed(pTestRec, "mallocEM number of allocations failed");
		}

	}

	/**********************************/
   /* Test memMallocIM and memFreeIM */
	/**********************************/

	testComment (pTestRec, "Testing memMallocIM");
	
	/* 
		Beware of this magic number (0x5A0) which assumes that at least 0x600 was 
		allocated to internal memory.
	*/
	pTemp = memMallocIM(0x5a0);
		
	if (pTemp == NULL) 
	{
		testFailed(pTestRec, "Insufficient internal memory was originally allocated");
	}
	memFreeIM (pTemp);

	for (i=0; i<10; i++)
	{
		for (j=1; j<1000; j++)
		{
			allocations[j] = memMallocIM (j);
			
			if (allocations[j] == NULL) 
			{
				break;
			}
		}
		numAllocations = j;
							
		for (j=1; j<numAllocations; j++)
		{
			memFreeIM (allocations[j]);
		}

		/* 
			Beware of this magic number (0x5a0) which assumes that at least 0x600 was 
			allocated to internal memory.
		*/
		pTemp = memMallocIM(0x5a0);
		
		if (pTemp == NULL || !memIsIM (pTemp)) 
		{
			testFailed(pTestRec, "Not all internally allocated data was freed");
		}
		memFreeIM (pTemp);
	}
	
	/*****************************************/
   /* Test memMallocAlignedIM and memFreeIM */
	/*****************************************/

	testComment (pTestRec, "Testing memMallocAlignedIM");
	
	/* 
		Beware of this magic number (0x5A0) which assumes that at least 0x600 was 
		allocated to internal memory.
	*/
	pTemp = memMallocIM(0x5a0);
		
	if (pTemp == NULL) 
	{
		testFailed(pTestRec, "Error in internal memory allocation");
	}
	memFreeIM (pTemp);

	for (i=1; i<=2048; i*=2)
	{
		for (j=1; j<1000; j++)
		{
			allocations[j] = memMallocAlignedIM (i);

			if (allocations[j] == NULL) 
			{
				break;
			}
			
			if (!memIsAligned (allocations[j], i))
			{
				memFreeIM (allocations[j]);
				break;
			}			
			
			if (((int)allocations[j] & (i-1)) != 0)
			{
				testFailed(pTestRec, "memIsAligned failed");
			}
		}
		numAllocations = j;
							
		for (j=1; j<numAllocations; j++)
		{
			memFreeIM (allocations[j]);
		}

		/* 
			Beware of this magic number (0x5a0) which assumes that at least 0x600 was 
			allocated to internal memory.
		*/
		pTemp = memMallocIM(0x5a0);
		
		if (pTemp == NULL || !memIsIM (pTemp)) 
		{	
			testFailed(pTestRec, "Not all internally allocated aligned data was freed");
		}
		memFreeIM (pTemp);
	}
	

	testEnd (pTestRec);
	
   return PASS;
}






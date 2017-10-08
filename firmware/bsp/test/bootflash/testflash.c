/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000, 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   testflash.c
*
* DESCRIPTION: source file that tests the SDK flash and bootflash drivers
*
*******************************************************************************/

#include "stdio.h"

#include "io.h"
#include "fcntl.h"
#include "bsp.h"

#include "test.h"
#include "assert.h"
#include "mempx.h"


#include "flashdrv.h" /* for use FLASH_DBG_MEM define */

#include "testflash.h" 
#include "testflash_target.h"

/*-----------------------------------------------------------------------*

    testflash.c  -  test for Flash driver
	
*------------------------------------------------------------------------*/

/* To run boot flash test Boot mode jumper must be set for internaal boot mode */
/* And file flash.cfg must be copied into ./Debug subfolder (it`s a Metrowerks */
/* CodeWarrior 3.5 bug) */

Result testflash(test_sRec *);

#define TST_DX  0
#define TST_P2D 1
#define TST_PD  1
#define TST_BD  2

#define TST_FLASH_PAGE_MASK    0x00ffu
#define TST_FLASH_PAGE_LENGTH  0x0100u

#define TST_BUF_MAX_LENGTH    (PORT_MAX_VECTOR_LEN + 4)
#define TST_BUF_MAX_LENGTH_PROGRAM  0x0200

#if defined(TEST_FOR_BOOTFLASH)
#if defined(DSP56807EVM)
#define TST_PROGRAM_RAM    0x7000
#else /* defined(DSP56807EVM) */
#define TST_PROGRAM_RAM    0x7E00
#endif/* defined(DSP56807EVM) */
#else /* defined(TEST_FOR_BOOTFLASH) */
#define TST_PROGRAM_RAM    0xC000
#endif /* defined(TEST_FOR_BOOTFLASH) */


#define TST_MAX_PERMITED      PORT_MAX_VECTOR_LEN

static UWord16 TstDataBuf1[TST_BUF_MAX_LENGTH];
static UWord16 TstDataBuf2[TST_BUF_MAX_LENGTH];


UWord16 TstProgramBuf1  = TST_PROGRAM_RAM;

typedef struct 
{
   const char    *   DeviceName;
   UWord16 *         StartAddress;
   UWord16           Length;
   UWord16           Pages;
   UWord16           FirstPageLength;    /* for program flash, where first page 4 words less than all others */
   UWord16           PageLength;
   mem_eMemoryType   MemType;
} sFiuParameter;


sFiuParameter FiuParameter[3] = 
{
   {
      BSP_DEVICE_NAME_FLASH_X,
      (UWord16 *)FLASH_X_START_ADDR,
      FLASH_X_SIZE,
      FLASH_X_PAGES,
      TST_FLASH_PAGE_LENGTH,
      TST_FLASH_PAGE_LENGTH,
      XData
   },
#if defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH)
   {
      BSP_DEVICE_NAME_FLASH_P2,
      (UWord16 *)FLASH_P2_START_ADDR,
      FLASH_P2_SIZE,
      FLASH_P2_PAGES,
      TST_FLASH_PAGE_LENGTH,
      TST_FLASH_PAGE_LENGTH,
      PData
   },
#else /* defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH) */
   {
      BSP_DEVICE_NAME_FLASH_P,
      (UWord16 *)FLASH_P_START_ADDR,
      FLASH_P_SIZE,
      FLASH_P_PAGES,
      TST_FLASH_PAGE_LENGTH - 4,
      TST_FLASH_PAGE_LENGTH,
      PData
   },
#endif /* defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH) */
   {
      BSP_DEVICE_NAME_FLASH_B,
      (UWord16 *)FLASH_B_START_ADDR,
      FLASH_B_SIZE,
      FLASH_B_PAGES,
      TST_FLASH_PAGE_LENGTH,
      TST_FLASH_PAGE_LENGTH,
      PData
   }
};
	
UWord16	Len[4];
UWord16	offset;

char message[256];

Result TestOneFlash(test_sRec *pTestRec, sFiuParameter * pFiuPar);
Result TestAllFlash(test_sRec *pTestRec);


/*************************************************************************/
Result TestOneFlash(test_sRec *pTestRec, sFiuParameter * pFiuPar)
{

   UWord16  i, j;
   int      res;
	int      FlashHandle;
   UWord16  Address;
   UWord16  Length;
   UWord16  Offset;
   UWord16  OneWriteLength;
   UWord16  TmpWord1;
   UWord16  TmpWord2;
   UWord16  Mode;
      
   switch ( (UWord16)pFiuPar->DeviceName )
   {
      case (UWord16)BSP_DEVICE_NAME_FLASH_X:
      {
         sprintf(message, "Flash driver X ");
      }
      break;
      case (UWord16)BSP_DEVICE_NAME_FLASH_P:
      {
         sprintf(message, "Flash driver P ");
      }
      break;
#if defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH)
      case (UWord16)BSP_DEVICE_NAME_FLASH_P2:
      {
         sprintf(message, "Flash driver P2 ");
      }
      break;
#endif /* defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH) */
      case (UWord16)BSP_DEVICE_NAME_FLASH_B:
      {
         sprintf(message, "Flash driver B ");
      }
      break;
      default:
      {
         message[0] = 0;
      }
   }
	
	
	testStart (pTestRec, message);
	

   /* Open */

	testComment(pTestRec, "Open");   


   FlashHandle = open(pFiuPar->DeviceName, 0, NULL );

   if (FlashHandle == -1)
   {
		testFailed(pTestRec, "Open #1");   
      return FAIL;
   }


//	testComment(pTestRec, "Erase all ");   
//	res = ioctl(FlashHandle, FLASH_CMD_ERASE_ALL, NULL);

   /* Write one word */
	testComment(pTestRec, "Write one word");   

   TstDataBuf1[0] = 0xABCD;

   res = write(FlashHandle, &(TstDataBuf1[ 0 ]), 1); 

   /* Write one page */

	testComment(pTestRec, "Write one page ");   
   
   Address  = 0x0000;

   ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
   
   for ( i = 0; i < TST_FLASH_PAGE_LENGTH; i++)
   {
      TstDataBuf1[i] = 0x7000 + i;
   }

   res = write(FlashHandle, &(TstDataBuf1[0]), TST_FLASH_PAGE_LENGTH); 
   
   /* Read one page */

	testComment(pTestRec, "Read one page");   

   Address  = 0x0000;

   ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
   
   res = read(FlashHandle, &(TstDataBuf2[0]), TST_FLASH_PAGE_LENGTH); 
   
   /* Write page by page */

	testComment(pTestRec, "Write page by page");   
   
   Address  = 0x0000;

   ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);

   for ( j = 0; j < pFiuPar->Pages; j++ )
   {
      for ( i = 0; i < TST_FLASH_PAGE_LENGTH; i++)
      {
         TstDataBuf1[i] = 0x8000 + (j << 8) + i;
         TstDataBuf2[i] = 0xABCD;
      }

      if (j == 0)
      {
         Length = pFiuPar->FirstPageLength;
         Offset = pFiuPar->PageLength - pFiuPar->FirstPageLength;
/*         res = write(FlashHandle, &(TstDataBuf1[ pFiuPar->PageLength - pFiuPar->FirstPageLength ]), Length); */
         res = write(FlashHandle, TstDataBuf1 + Offset, Length); 
      }
      else
      {
         Length = pFiuPar->PageLength;   
         res = write(FlashHandle, TstDataBuf1, Length);
      }


      if (res != Length)
      {
		   testFailed(pTestRec, "Write #1");   
      }
   }

   /* Read maximum permitted size  */

	testComment(pTestRec, "Read");   

   Address  = 0x0000;

   ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);

   for ( j = 0; j < pFiuPar->Length / TST_MAX_PERMITED; j++ )
   {
		if ( j == 0)
		{
			Offset = pFiuPar->PageLength - pFiuPar->FirstPageLength;
		}
		else
		{
			Offset = 0;
		}

		Length = TST_MAX_PERMITED - Offset;

      for ( i = 0 ; i < TST_MAX_PERMITED; i++)
      {
         TstDataBuf1[i] = 0x8000 + j*TST_MAX_PERMITED + i;
         TstDataBuf2[i] = 0xABCD;
      }

      res = read(FlashHandle, TstDataBuf2, Length);

      if (res != Length)
      {
	      testFailed(pTestRec, "Read #1");   
      }

      for ( i = 0 ; i < Length; i++)
      {
   		if (TstDataBuf1[i + Offset] != TstDataBuf2[i])
   		{
	      	sprintf(message, "Verify #1 %4d, 0x%4x != 0x%4x", i , TstDataBuf1[i + (pFiuPar->PageLength - pFiuPar->FirstPageLength)], TstDataBuf2[i]);
	      	testFailed(pTestRec, message);
	      }
      }
      
   }

   for ( i = 0; i < pFiuPar->Length % TST_MAX_PERMITED; i++)
   {
      TstDataBuf1[i] = 0x8000 + (j * TST_MAX_PERMITED) + i;
      TstDataBuf2[i] = 0xABCD;
   }

   res = read(FlashHandle, TstDataBuf2, pFiuPar->Length % TST_MAX_PERMITED);

   if (res != pFiuPar->Length % TST_MAX_PERMITED)
   {
      testFailed(pTestRec, "Read #1.1");   
   }

	if ( j == 0)
	{
		Offset = pFiuPar->PageLength - pFiuPar->FirstPageLength;
	}
	else
	{
		Offset = 0;
	}
   for ( i = Offset; i < pFiuPar->Length % TST_MAX_PERMITED; i++)
   {
 		if (TstDataBuf1[i] != TstDataBuf2[i - Offset])
 		{
      	sprintf(message, "Verify #1.1 %4d, 0x%4x != 0x%4x", i , TstDataBuf1[i], TstDataBuf2[i - Offset]);
		   testFailed(pTestRec, message);   
      }
   }

   /***************** Test random write with verification ******************/

	testComment(pTestRec, "Random write with verification");   

   for ( i = 0; i < TST_MAX_PERMITED; i++)
   {
      TstDataBuf1[i] = i;
   }

   Address = 0x0000;


	res = ioctl(FlashHandle, FLASH_SET_VERIFY_ON, NULL);
	res = ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
	
	Offset = 0;
	j = 0;
	
   OneWriteLength = Len[0] + Len[1] + Len[2] + Len[3];

   while ( j < ( pFiuPar->Length - OneWriteLength))
   {
		for ( i = 0; i < 4; i++)
		{
	   	res = write(FlashHandle, &(TstDataBuf1[Offset]), Len[i]);

      	if (res != Len[i])
      	{
		   	sprintf(message, "Write #2 (Offset = %d )", Offset);
		   	testFailed(pTestRec, message);   
      	}
      	
      	Offset 	+= Len[i];
      	j 			+=	Len[i];
		}
     	if (Offset >= TST_MAX_PERMITED - OneWriteLength)
     	{
     		Length = Offset; /* save value to read */
     		Offset = 0;
     		
     	}
   }

   res = write(FlashHandle, &(TstDataBuf1[Offset]), (pFiuPar->Length - j));

   if (res != pFiuPar->Length - j)
   {
      sprintf(message, "Write #3 (j = %x )", j);
	   testFailed(pTestRec, message);
   }


   /************************ Test read with verification ********************/

	testComment(pTestRec, "Read with verification");   

   Address = 0x0000;

	res = ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
	res = ioctl(FlashHandle, FLASH_SET_VERIFY_ON, NULL);

	if (pFiuPar->Length > TST_MAX_PERMITED)
	{
		Length =  TST_MAX_PERMITED - OneWriteLength;
	}
	else
	{
		Length =  pFiuPar->Length;
	}
	
   res = read(FlashHandle, TstDataBuf1, Length);

   if (res != Length)
   {
      testFailed(pTestRec, "Verify #2");   
   }

   /************************ Test write and Verify to program memory  ********************/

	testComment(pTestRec, "Write and Verify from P memory");   

   Address = 0x0000;

	res = ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
	res = ioctl(FlashHandle, FLASH_SET_VERIFY_ON, NULL);
	res = ioctl(FlashHandle, FLASH_SET_USER_P_DATA, NULL);

#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)
   archDisableInt();
      
   Mode = archSetOperatingMode(0x0000);
#endif /* !defined(FLASH_DBG_MEM) */
#endif defined(TEST_FOR_BOOTFLASH)
      
   for (i = 0; i < TST_BUF_MAX_LENGTH_PROGRAM; i++)
   {
      TmpWord1 = 0x7000 + i;
      memCopyXtoP((UWord16 *)(TstProgramBuf1 + i), &TmpWord1, sizeof(UWord16));
   }

#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)
   archSetOperatingMode(Mode);

   archEnableInt();
#endif /* !defined(FLASH_DBG_MEM) */
#endif defined(TEST_FOR_BOOTFLASH)
   
	if (pFiuPar->Length > TST_BUF_MAX_LENGTH_PROGRAM)
	{
		Length =  TST_BUF_MAX_LENGTH_PROGRAM;
	}
	else
	{
		Length =  pFiuPar->Length;
	}
	
   res = write(FlashHandle, (UWord16 *)(TstProgramBuf1), Length);

   if (res != Length)
   {
      testFailed(pTestRec, "Write #4");   
   }

   /************************ Test read from program memory  ********************/
 
	testComment(pTestRec, "Read data to P memory");   

#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)
   archDisableInt();
      
   Mode = archSetOperatingMode(0x0000);
#endif /* !defined(FLASH_DBG_MEM) */
#endif /* defined(TEST_FOR_BOOTFLASH) */
      
      /* save buffer */
   for (i = 0; i < TST_BUF_MAX_LENGTH_PROGRAM; i++)
   {
      memCopyPtoX( &(TstDataBuf1[i]), (UWord16 *)(TstProgramBuf1 + i), sizeof(UWord16));
      TmpWord2 = 0xABCD;
      memCopyXtoP((UWord16 *)(TstProgramBuf1 + i), &TmpWord2, sizeof(UWord16));
   }

#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)
   archSetOperatingMode(Mode);

   archEnableInt();
#endif /* !defined(FLASH_DBG_MEM) */
#endif /* defined(TEST_FOR_BOOTFLASH) */

   Address = 0x0000;

	res = ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);
	res = ioctl(FlashHandle, FLASH_SET_VERIFY_OFF, NULL);
	
   res = read(FlashHandle, (UWord16 *)(TstProgramBuf1), Length);

   if (res != Length)
   {
      testFailed(pTestRec, "Write #4");   
   }
   
#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)
   archDisableInt();
      
   Mode = archSetOperatingMode(0x0000);
#endif /* !defined(FLASH_DBG_MEM) */
#endif /* defined(TEST_FOR_BOOTFLASH) */

   for (i = 0; i < Length; i++)
   {
      memCopyPtoX(&TmpWord1, (UWord16 *)(TstProgramBuf1 + i), sizeof(UWord16));
      memCopyXtoX(&TmpWord2, &(TstDataBuf1[i]), sizeof(UWord16));
      if ( TmpWord1 != TmpWord2 )
      {
         testFailed(pTestRec, "Verify #3");           
      }
   }
   
#if defined(TEST_FOR_BOOTFLASH)
#if !defined(FLASH_DBG_MEM)

   archSetOperatingMode(Mode);

   archEnableInt();
   
#endif /* !defined(FLASH_DBG_MEM) */
#endif /* defined(TEST_FOR_BOOTFLASH) */

   /***************************** Test erase ***************************/

#if 1
	testComment(pTestRec, "Erase");   

	res = ioctl(FlashHandle, FLASH_SET_USER_X_DATA, NULL);
	res = ioctl(FlashHandle, FLASH_CMD_ERASE_ALL, NULL);

	if (pFiuPar->MemType == XData)
	{
   	for (i = 0; i < pFiuPar->Length; i++)
   	{
      	if (*(pFiuPar->StartAddress + i) != 0xffffu )
      	{
      		sprintf(message, "Verify #4 (i = %d)", i);
	      	testFailed(pTestRec, message);         
      	}	
   	}
   }
   else
   {
#if !defined(FLASH_DBG_MEM)

      UWord16 Mode;
      archDisableInt();
      
      Mode = archSetOperatingMode(0x0000);
#endif /* !defined(FLASH_DBG_MEM) */
      
   	for (i = 0; i < pFiuPar->Length; i++)
   	{
      	if (memReadP16(pFiuPar->StartAddress + i) != 0xffff)
      	{
      		sprintf(message, "Verify #4 (i = %d)", i);
	      	testFailed(pTestRec, message);         
      	}	
   	}

#if !defined(FLASH_DBG_MEM)
      archSetOperatingMode(Mode);

      archEnableInt();
#endif /* !defined(FLASH_DBG_MEM) */

   	/* Program memory */
   }
#endif 
   
   /********************** test incorrect parameters ************************/

	testComment(pTestRec, "Test incorrect parameters ");   

   Address = 0x0000;

	res = ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);

   res = close(FlashHandle);

   testEnd (pTestRec);
	
   return PASS;
}


/*************************************************************************/
Result TestAllFlash(test_sRec *pTestRec)
{

   int      res = 0;
      
	Len[0] = 11;
	Len[1] = 3;
	Len[2] = 111;
	Len[3] = 33;

#if defined(FLASH_DBG_MEM)

#if defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH)
   FiuParameter[TST_DX].StartAddress = (UWord16 *)(((UWord16)DataFlashBuffer & ~TST_FLASH_PAGE_MASK) + TST_FLASH_PAGE_LENGTH);
   FiuParameter[TST_PD].StartAddress = (UWord16 *)ProgramFlashBuffer;
#else /* defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH) */
   FiuParameter[TST_P2D].StartAddress = (UWord16 *)ProgramFlashBuffer;
#endif /* defined(DSP56807EVM) && defined(TEST_FOR_BOOTFLASH) */
   FiuParameter[TST_BD].StartAddress = (UWord16 *)BootFlashBuffer;

#endif /* defined(FLASH_DBG_MEM) */

#if !defined(TEST_FOR_BOOTFLASH)
   res |= TestOneFlash(pTestRec, &(FiuParameter[TST_DX]));      
      
   res |= TestOneFlash(pTestRec, &(FiuParameter[TST_PD]));
#endif /* !defined(TEST_FOR_BOOTFLASH) */

#if defined(TEST_FOR_BOOTFLASH)
#if defined(DSP56807EVM)
   res |= TestOneFlash(pTestRec, &(FiuParameter[TST_P2D]));
#endif /* defined(DSP56807EVM) */

   /* NB: test complitly overwrite and erase Boot Flash !!! */
   res |= TestOneFlash(pTestRec, &(FiuParameter[TST_BD]));
#endif /* defined(TEST_FOR_BOOTFLASH) */

   return res;

}

/*************************************************************************/
int main(void)
{
	int res  = 0;
	int i    = 0;
   UWord16  Mode;
   
   test_sRec testRec;

   /* Read data from programm memory flash for manual testing */

#if 0

   for ( i = 0; i < TST_MAX_PERMITED; i++)
   {
      TstDataBuf1[i] = 0xABCD;
   }

   archDisableInt();
      
   Mode = archSetOperatingMode(0x0000);
      
   memCopyPtoX( &(TstDataBuf1[0]), (UWord16 *)(0x0000), TST_MAX_PERMITED);
   
   archSetOperatingMode(Mode);

   archEnableInt();
     
#endif
      
   res |= TestAllFlash (&testRec);

	return res;
}



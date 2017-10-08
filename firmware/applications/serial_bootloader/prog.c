/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         prog.c
*
* Description:       Flash programming and received data writing
*
* Modules Included:  progPlaceData()
*                    progWriteFlashPage()
*                    progSaveData()
*                    progGetMemDescription()
*                    flashHWErasePage()
*                    flashHWProgramWord()
*                    
* 
*****************************************************************************/

#include "arch.h"
#include "periph.h"

#include "bootloader.h"
#include "com.h"
#include "sparser.h"
#include "prog.h"

extern void * archStartDelayAddress;

/*****************************************************************************/
/***                    Flash Programing Defenitions                       ***/
/*****************************************************************************/

/* if NO_FLASH_PROGRAM defined, flash programming is not perfomed */
//#define NO_FLASH_PROGRAM


/* Control bits description */

#define FLASH_FIU_CNTL_BUSY   0x8000u
#define FLASH_FIU_CNTL_IFREN  0x0040u
#define FLASH_FIU_CNTL_XE     0x0020u
#define FLASH_FIU_CNTL_YE     0x0010u
#define FLASH_FIU_CNTL_PROG   0x0008u
#define FLASH_FIU_CNTL_ERASE  0x0004u
#define FLASH_FIU_CNTL_MAS1   0x0002u
#define FLASH_FIU_CNTL_NVSTR  0x0001u

#define FLASH_FIU_PE_DPE      0x8000u
#define FLASH_FIU_PE_IPE      0x4000u
#define FLASH_FIU_PE_ROW      0x03ffu

#define FLASH_FIU_EE_DEE      0x8000u
#define FLASH_FIU_EE_IEE      0x4000u
#define FLASH_FIU_EE_PAGE     0x007fu

#define FLASH_FIU_IE_0        0x0001u
#define FLASH_FIU_IE_1        0x0002u
#define FLASH_FIU_IE_2        0x0004u
#define FLASH_FIU_IE_3        0x0008u
#define FLASH_FIU_IE_4        0x0010u
#define FLASH_FIU_IE_5        0x0020u
#define FLASH_FIU_IE_6        0x0040u
#define FLASH_FIU_IE_7        0x0080u
#define FLASH_FIU_IE_8        0x0100u
#define FLASH_FIU_IE_9        0x0200u
#define FLASH_FIU_IE_10       0x0400u
#define FLASH_FIU_IE_11       0x0800u

#define FLASH_FIU_IS_0        0x0001u
#define FLASH_FIU_IS_1        0x0002u
#define FLASH_FIU_IS_2        0x0004u
#define FLASH_FIU_IS_3        0x0008u
#define FLASH_FIU_IS_4        0x0010u
#define FLASH_FIU_IS_5        0x0020u
#define FLASH_FIU_IS_6        0x0040u
#define FLASH_FIU_IS_7        0x0080u
#define FLASH_FIU_IS_8        0x0100u
#define FLASH_FIU_IS_9        0x0200u
#define FLASH_FIU_IS_10       0x0400u
#define FLASH_FIU_IS_11       0x0800u

/* Flash Interface Units parameters */

#define FLASH_PAGE_LENGTH     0x0100u
#define FLASH_PAGE_MASK       0x00ffu 
#define FLASH_PAGE_SHIFT      8u

#define FLASH_RAW_LENGTH      0x0020u
#define FLASH_RAW_MASK        0x001fu
#define FLASH_RAW_SHIFT       5u

/*****************************************************************************/
/***                   Memory map definition                               ***/
/*****************************************************************************/

#define  AREA_DISABLED     0x0001
#define  AREA_FLASH        0x0002
#define  AREA_RAM          0x0000
#define  AREA_DELAYED      0x0004
#define  AREA_P_MEMORY     0x0040
#define  AREA_X_MEMORY     0x0000
      
typedef struct {
   UWord16        StartAddress;
   UWord16        EndAddress;
   UWord16        Description;
   arch_sFlash  * FIUBaseAddress;
} Area;

/* P memory map */
static Area progPBaundary[] =
   { 
#if defined(DSP56801EVM)
 /* Boot flash (Reset and COP vectors) */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x0003,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Program flash */
      {
         /* StartAddress    */      0x0004,
         /* EndAddress      */      0x1fff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.ProgramFlash,
      },
      /* Reserved 1 */
      {
         /* StartAddress    */      0x2000,
         /* EndAddress      */      0x7bff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },      
      /* Program RAM */
      {
         /* StartAddress    */      0x7C00,
         /* EndAddress      */      0x7fff,
         /* Description     */      AREA_P_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Boot flash, bootloader code location */
      {
         /* StartAddress    */      0x8000,
         /* EndAddress      */      0x87ff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      
      /* External Program memory */
      {
         /* StartAddress    */      0x8800,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_P_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }

#endif /* defined(DSP56801EVM) */


#if defined(DSP56803EVM) || defined(DSP56805EVM) || defined(DSP56826EVM)
      /* Boot flash (Reset and COP vectors) */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x0003,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Program flash */
      {
         /* StartAddress    */      0x0004,
         /* EndAddress      */      0x7dff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.ProgramFlash,
      },
      /* Program RAM */
      {
         /* StartAddress    */      0x7e00,
         /* EndAddress      */      0x7fff,
         /* Description     */      AREA_P_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Boot flash, bootloader code location */
      {
         /* StartAddress    */      0x8000,
         /* EndAddress      */      0x87ff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* External Program memory */
      {
         /* StartAddress    */      0x8800,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_P_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }
#endif /* defined(DSP56803EVM) || defined(DSP56805EVM) || defined(DSP56826EVM) */

#if defined(DSP56807EVM)
      /* Boot flash (Reset and COP vectors) */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x0003,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Program flash */
      {
         /* StartAddress    */      0x0004,
         /* EndAddress      */      0x7fff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.ProgramFlash,
      },
      /* Program flash 2 */
      {
         /* StartAddress    */      0x8000,
         /* EndAddress      */      0xefff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.ProgramFlash2,
      },
      /* Program RAM */
      {
         /* StartAddress    */      0xf000,
         /* EndAddress      */      0xf7ff,
         /* Description     */      AREA_P_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Boot flash, bootloader code location */
      {
         /* StartAddress    */      0xf800,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_P_MEMORY | AREA_FLASH | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }
#endif /* defined(DSP56807EVM) */
   };

   
/* X memory map */
static Area progXBaundary[] = 
   {
#if defined(DSP56801EVM)
      /* Internal data RAM, used for bootloader stack and buffers */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x03ff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Reserved 1 */
      {
         /* StartAddress    */      0x0400,
         /* EndAddress      */      0x0Bff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Peripheral registers */
      {
         /* StartAddress    */      0x0C00,
         /* EndAddress      */      0x0fff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Data Flash */
      {
         /* StartAddress    */      0x0C00,
         /* EndAddress      */      0x17ff,
         /* Description     */      AREA_X_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.DataFlash,
      },
      /* External Data Memory */
      {
         /* StartAddress    */      0x2000,
         /* EndAddress      */      0xff7f,
         /* Description     */      AREA_X_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Core Configuration Registers */
      {
         /* StartAddress    */      0xff80,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }

#endif /* defined(DSP56801EVM) */

#if defined(DSP56803EVM) || defined(DSP56805EVM) 
      /* Internal data RAM, used for bootloader stack and buffers */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x07ff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Reserved 1 */
      {
         /* StartAddress    */      0x0800,
         /* EndAddress      */      0x0Bff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Peripheral registers */
      {
         /* StartAddress    */      0x0C00,
         /* EndAddress      */      0x0fff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Data Flash */
      {
         /* StartAddress    */      0x1000,
         /* EndAddress      */      0x1fff,
         /* Description     */      AREA_X_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.DataFlash,

      },
      /* External Data Memory */
      {
         /* StartAddress    */      0x2000,
         /* EndAddress      */      0xff7f,
         /* Description     */      AREA_X_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Core Configuration Registers */
      {
         /* StartAddress    */      0xff80,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }
#endif /* defined(DSP56803EVM) || defined(DSP56805EVM)  */


#if defined(DSP56807EVM) 
      /* Internal data RAM, used for bootloader stack and buffers */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x0fff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Peripheral registers */
      {
         /* StartAddress    */      0x1000,
         /* EndAddress      */      0x17ff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Reserved 1 */
      {
         /* StartAddress    */      0x1800,
         /* EndAddress      */      0x1fff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Data Flash */
      {
         /* StartAddress    */      0x2000,
         /* EndAddress      */      0x3fff,
         /* Description     */      AREA_X_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16 *)&ArchIO.DataFlash,
      },
      /* External Data Memory */
      {
         /* StartAddress    */      0x4000,
         /* EndAddress      */      0xff7f,
         /* Description     */      AREA_X_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Core Configuration Registers */
      {
         /* StartAddress    */      0xff80,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }
#endif /* defined(DSP56807EVM) */

#if defined(DSP56826EVM) 
      /* Internal data RAM, used for bootloader stack and buffers */
      {
         /* StartAddress    */      0x0000,
         /* EndAddress      */      0x0fff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Peripheral registers */
      {
         /* StartAddress    */      0x1000,
         /* EndAddress      */      0x13ff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Reserved 1 */
      {
         /* StartAddress    */      0x1400,
         /* EndAddress      */      0x17ff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      },
      /* Data Flash */
      {
         /* StartAddress    */      0x1800,
         /* EndAddress      */      0x1fff,
         /* Description     */      AREA_X_MEMORY | AREA_FLASH,
         /* FIUBaseAddress  */      (arch_sFlash *)(UWord16  * )&ArchIO.DataFlash,
      },
      /* External Data Memory */
      {
         /* StartAddress    */      0x2000,
         /* EndAddress      */      0xff7f,
         /* Description     */      AREA_X_MEMORY | AREA_RAM,
         /* FIUBaseAddress  */      0,
      },
      /* Core Configuration Registers */
      {
         /* StartAddress    */      0xff80,
         /* EndAddress      */      0xffff,
         /* Description     */      AREA_X_MEMORY | AREA_RAM | AREA_DISABLED,
         /* FIUBaseAddress  */      0,
      }
#endif /* defined(DSP56826EVM) */

   };

#define P_BAUNDARY_NUMBER  (sizeof(progPBaundary) / sizeof(Area))
#define X_BAUNDARY_NUMBER  (sizeof(progXBaundary) / sizeof(Area))

typedef void * (*tpMemCopy)( void *, const void *, size_t  );
typedef int    (*tpMemCmp)( const void *, const void *, size_t );

static UWord16           progData    [SPRS_BUFFER_LEN];
static UWord16         * progDataPointer = progData;
static UWord16           progAddress;
static UWord16           progLength;
static bool              progMoreData;
static mem_eMemoryType   progMemoryType = XData;
static tpMemCopy         pToMemCopy;
static tpMemCopy         pFromMemCopy;

static UWord16           progFlashBuffer  [FLASH_PAGE_LENGTH];
static Area            * progFlashArea;        /* if NULL no current area */
static UWord16           progFlashPageAddress; /* current flash page address */

UWord16                  progProgCounter;
UWord16                  progDataCounter;
UWord16                  progIndicatorCounter;

UWord16                  progDelayFlag;
UWord16                  progDelayValue;

/* Local functions prototypes */

static Area * progGetMemDescription  ( Area * AreaArray, 
                                       UWord16 AreaNumber,  
                                       UWord16 Address );

static void progWriteFlashPage      ( void );
static void flashHWErasePage        ( arch_sFlash * FiuBase, 
                                      tpMemCopy pMemCopy, 
                                      UWord16 Address );
static void flashHWProgramWord      ( arch_sFlash * FiuBase, 
                                      tpMemCopy pMemCopy, 
                                      UWord16 Address, 
                                      UWord16 * pData );


/*****************************************************************************
*
* Module:         progPlaceData()
*
* Description:    Place binary data into appropriate memory location
*
* Returns:        None
*
* Arguments:      ProgEnableFlag - true enables flash programming
*
* Range Issues:   None
*
* Special Issues: Use a lot of global variables
*
* Test Method:    boottest.mcp
*
*****************************************************************************/
void progPlaceData(bool ProgEnableFlag)
{
   UWord16        i;
   UWord16        CurrentLength;
   Area        *  TmpProgArea;
   
   
#if defined(DEBUG_LED)
#if defined(DSP56805EVM)
   ArchIO.PortB.DataReg   ^= GPIOB_GREEN;   
#endif /* defined(DSP56805EVM) */
#endif /* defined(DEBUG_LED) */
  
   if (progMoreData)
   {
      /* check for bootloader delay variable */
      if ((progMemoryType == PData) && 
         ((progAddress <= (UInt16)&archStartDelayAddress) && ((UInt16)&archStartDelayAddress < (progAddress + progLength))))
      {
         /* set flag, save value and replace to new temporary value for Delay variable */
         progDelayFlag     = true;
         progDelayValue    =  *(progDataPointer + ((UInt16)&archStartDelayAddress - progAddress ));         
         *(progDataPointer + ((UInt16)&archStartDelayAddress - progAddress)) = 0xfffe;
      }
      while (progLength)
      {
         if (progMemoryType == PData)
         {
            TmpProgArea = progGetMemDescription ( progPBaundary, P_BAUNDARY_NUMBER, progAddress );
         }
         else
         {
            TmpProgArea = progGetMemDescription ( progXBaundary, X_BAUNDARY_NUMBER, progAddress );
         }
         
         if ((( progFlashArea != NULL ) && ( progFlashArea != TmpProgArea )) ||
               ( ( progFlashArea == TmpProgArea ) && 
               ( (progAddress ^ progFlashPageAddress) & ~FLASH_PAGE_MASK )))
         {  
            if ( ProgEnableFlag )
            {  /* save flash previus data */
               progWriteFlashPage();

               progFlashArea = NULL;
            }
            else
            {
               comStopReceive();
               break;
            }
         }
         else
         {
            CurrentLength = (TmpProgArea->EndAddress - progAddress) + 1;
         
            CurrentLength = (CurrentLength > progLength) ? progLength: CurrentLength;
               
            if ((TmpProgArea->Description & AREA_DISABLED) == 0)
            {
               if (progFlashArea->Description & AREA_P_MEMORY )
               {
                  pFromMemCopy  = bootmemCopyPtoX;
                  pToMemCopy    = bootmemCopyXtoP;
               }
               else
               {
                  pFromMemCopy  = bootmemCopyXtoX;
                  pToMemCopy    = bootmemCopyXtoX;
               }
               if (TmpProgArea->Description & AREA_FLASH)
               {  /* Flash */           
                  if (progFlashArea == NULL)
                  {  /* save data from flash */
                     
                     pFromMemCopy(progFlashBuffer, (void *)(progAddress & ~FLASH_PAGE_MASK), FLASH_PAGE_LENGTH);
                     
                     pFromMemCopy = NULL;
                     
                     progFlashPageAddress = progAddress & ~FLASH_PAGE_MASK;
                     if (((progFlashPageAddress ^ TmpProgArea->StartAddress) & ~FLASH_PAGE_MASK) == 0)
                     {
                        progFlashPageAddress = TmpProgArea->StartAddress;
                     }
                     progFlashArea = TmpProgArea;
                  }
                  if ( CurrentLength > ( FLASH_PAGE_LENGTH - ( progAddress & FLASH_PAGE_MASK )))
                  {
                     CurrentLength =  FLASH_PAGE_LENGTH - (progAddress & FLASH_PAGE_MASK);
                  }                     
                  /* save data into flash page buffer */
                  bootmemCopyXtoX(&(progFlashBuffer[progAddress & FLASH_PAGE_MASK]), progDataPointer, CurrentLength);
                                    
               }
               else
               {  /* area RAM */
                  pToMemCopy((void *)progAddress, (void *)progDataPointer, CurrentLength);
                  progFlashArea = NULL;
               }
            }
            else
            {
            /* skip space ??? */
            }
            progLength        -= CurrentLength; 
            progAddress       += CurrentLength;
            progDataPointer   += CurrentLength;
   
         }
      }
      if (progLength == 0)
      {
         progMoreData = false;
      }
   }
   else
   {
      if (ProgEnableFlag && (progFlashArea != NULL) )
      {
         /* save flash buffer */
         progWriteFlashPage();

         progFlashArea = NULL;
      }
   }
}

/*****************************************************************************
*
* Module:         progPlaceDelayValue()
*
* Description:    Write stored value of Delay timeout 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: a lot of global vars
*
* Test Method:    boottest.mcp
*
*****************************************************************************/
void progPlaceDelayValue ( void )
{
   if (progDelayFlag)
   {
      flashHWProgramWord ( &ArchIO.ProgramFlash, bootmemCopyXtoP, (UInt16)&archStartDelayAddress, &progDelayValue );
   
   }
}

/*****************************************************************************
*
* Module:         progWriteFlashPage()
*
* Description:    Write one page into flash
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: a lot of global vars
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void progWriteFlashPage(void)
{
   int        i;
   UWord16    TmpWord;
   UWord16  * TmpFlashAddress;

   TmpFlashAddress = (UWord16 *)(progFlashPageAddress - (progFlashPageAddress & FLASH_PAGE_MASK));

   if (progFlashArea->Description & AREA_P_MEMORY )
   {
      pToMemCopy    = bootmemCopyXtoP;
      pFromMemCopy  = bootmemCopyPtoX;
   }
   else
   {
      pToMemCopy    = bootmemCopyXtoX;
      pFromMemCopy  = bootmemCopyXtoX;
   }

   /* Erase page */
   for (i= progFlashPageAddress & FLASH_PAGE_MASK; i < FLASH_PAGE_LENGTH; i++)
   {
      *(pFromMemCopy)( &TmpWord, (TmpFlashAddress + i), 1);
      if (TmpWord != 0xffff)
      {
#if !defined(NO_FLASH_PROGRAM)
         flashHWErasePage( progFlashArea->FIUBaseAddress, pToMemCopy, progFlashPageAddress);
#endif /* !defined(NO_FLASH_PROGRAM) */
         break;
      }
   }      
   
   for (i= progFlashPageAddress & FLASH_PAGE_MASK; i < FLASH_PAGE_LENGTH; i++)
   {
      *(pFromMemCopy)( &TmpWord, (TmpFlashAddress + i), 1);
      if (TmpWord != 0xffff)
      {
         userError(INDICATE_ERROR_FLASH);      
      }
   }      

   /* program flash */
   for (i= progFlashPageAddress & FLASH_PAGE_MASK; i < FLASH_PAGE_LENGTH; i++)
   {
#if !defined(NO_FLASH_PROGRAM)
      flashHWProgramWord ( progFlashArea->FIUBaseAddress, pToMemCopy, 
                           (UWord16)(TmpFlashAddress + i), 
                            progFlashBuffer + i );
#endif /* !defined(NO_FLASH_PROGRAM) */
   }      

   /* verify flash */
   for (i= progFlashPageAddress & FLASH_PAGE_MASK; i < FLASH_PAGE_LENGTH; i++)
   {
      *(pFromMemCopy)( &TmpWord, (TmpFlashAddress + i), 1);
#if !defined(NO_FLASH_PROGRAM)
      if (TmpWord != progFlashBuffer[i] )
      {
         userError(INDICATE_ERROR_FLASH);
      }
#endif /* !defined(NO_FLASH_PROGRAM) */
   }      

   pToMemCopy    = NULL;
   pFromMemCopy  = NULL;
}

/*****************************************************************************
*
* Module:         progSaveData()
*
* Description:    Save data after S-Record parser into progData buffer, call
*                 progPlaceData()
*
* Returns:        None
*
* Arguments:      pData - pointer to data
*                 Length - data length
*                 Address - start address to put data 
*                 MemoryType - memory space to put data
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    boottest.mcp
*
*****************************************************************************/
void progSaveData ( UWord16 * pData, UWord16 Length, UWord16 Address, mem_eMemoryType MemoryType)
{
   
   if (progMoreData)
   {
      userError(INDICATE_ERROR_OVERRUN);
   }
   
   bootmemCopyXtoX(progData,pData,SPRS_BUFFER_LEN);

   progDataPointer   = progData;
   progLength        = Length;
   progAddress       = Address;
   progMemoryType    = MemoryType;
   
   if (MemoryType == PData)
   {
      progProgCounter  += Length;   /* 0xffff overflow does not detected */
   }
   else
   {
      progDataCounter  += Length;
   }

#if PROG_INDICATION_UNIT != 0

   progIndicatorCounter  += Length;

   if ( progIndicatorCounter > PROG_INDICATION_UNIT )
   {
      comPrintString((UWord16 *)StringBuffer);  /* print progres indication item */
      progIndicatorCounter -= PROG_INDICATION_UNIT;
   }

#endif

   progMoreData      = true;
   
   progPlaceData(false);
   
}

/*****************************************************************************
*
* Module:         progGetMemDescription()
*
* Description:    Search through AreaArray and find memory area that contains 
*                 Address
*
* Returns:        pointer to found memory area description
*
* Arguments:      AreaArray - pointer to memory array
*                 AreaNumber - number of items in AreaArray
*                 Address  - address to search 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

Area * progGetMemDescription(Area * AreaArray, UWord16 AreaNumber, UWord16 Address)
{
   int i;
   for (i = 0; i < AreaNumber; i++)
   {
      if (Address <= AreaArray[i].EndAddress )
      {
         return &(AreaArray[i]);
      }
   }
}


/*****************************************************************************
*
* Module:         flashHWErasePage()
*
* Description:    Erase flash page
*
* Returns:        None
*
* Arguments:      FiuBase - base address of Flash Information Unit register 
*                           block
*                 pMemCopy - pointer to function that can copy data from X 
*                           memory into destination memory
*                 Address  - address anywhere within page 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    None
*
*****************************************************************************/
static void flashHWErasePage( arch_sFlash * FiuBase, tpMemCopy pMemCopy, UWord16 Address )
{

   
   UWord16 TmpData = 0;
   UWord16 TmpWord;

   /* Check flash mode - it shoud be Standby or Read */

   while ( periphBitTest( ~FLASH_FIU_CNTL_IFREN, &FiuBase->ControlReg ))
   {
   }
   
   /* disable all interrupts */
   periphMemWrite( 0, &FiuBase->IntSourceReg);

   /* Enable erase by setting IEE and page number in FIU_EE register */
   periphMemWrite( FLASH_FIU_EE_IEE | ((Address & 0x7FFF)>> FLASH_PAGE_SHIFT), 
                  &FiuBase->EraseReg);

   /* Write any value to page to start erase */
   (*pMemCopy)((UWord16 *)Address, &TmpData, sizeof(UWord16));
   

   /* wait while erase operation will be completed */
   while (periphBitTest( FLASH_FIU_CNTL_BUSY, &FiuBase->ControlReg ))
   {
   }

#if 0
   /* check errors */
   TmpWord = periphMemRead( &FiuBase->IntSource );
   
   if (TmpWord & 0x0003)   /* IS[2] has been set in this moment */
                         /* Illegal read/write access to flash during erase */
   {
//      assert (false); /* Illegal read/write access to flash during erase */
   }
#endif 

   periphMemWrite( 0, &FiuBase->EraseReg);
   periphMemWrite( 0, &FiuBase->IntSourceReg);

}

/*****************************************************************************
*
* Module:         flashHWProgramWord()
*
* Description:    Program one word into flash
*
* Returns:        None
*
* Arguments:      FiuBase - base address of Flash Information Unit register 
*                           block
*                 pMemCopy - pointer to function that can copy data from X 
*                           memory into destination memory
*                 Address  - address anywhere within page 
*                 pData    - pointer to data word.
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    None
*
*****************************************************************************/

static void flashHWProgramWord ( arch_sFlash * FiuBase, tpMemCopy pMemCopy, 
                                 UWord16 Address, UWord16 * pData )
{
   UWord16 TmpWord;
   UWord16 TmpWord2;

   /* Check flash mode - it shoud be Standby or Read */
   while ( periphBitTest( ~FLASH_FIU_CNTL_IFREN , &FiuBase->ControlReg))
   {
//      assert (false) /* Flash busy. */
   }

   /* clear all interrupts */   
   periphMemWrite( 0, &FiuBase->IntSourceReg );
   
   /* disable all interrupts */
   periphMemWrite( 0, &FiuBase->IntReg);

   /* Enable programming by setting IPE and raw number in FIU_PE register */
   periphMemWrite( FLASH_FIU_PE_IPE | ((Address) >> FLASH_RAW_SHIFT), 
                   &FiuBase->ProgramReg);
  
   /* Write the data */
   
   (*pMemCopy)((UWord16 *)Address, pData, sizeof(UWord16));

   while ( periphBitTest( FLASH_FIU_CNTL_BUSY, &FiuBase->ControlReg))
   {
   }

#if 0
   /* Check errors */
   TmpWord = periphMemRead( &FiuBase->IntSourceReg );

   if (TmpWord & 0x0005)   /* IS[1] has been set in this moment  */
                           /* Illegal read/write access to flash during programming */
   {
      assert (false) /* Illegal read/write access to flash during programming */
   }
#endif

   periphMemWrite( 0, &FiuBase->ProgramReg);
   periphMemWrite( 0, &FiuBase->IntSourceReg);

}

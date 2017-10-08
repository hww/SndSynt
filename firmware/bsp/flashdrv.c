/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         flashdrv.c
*
* Description:       Flash driver for DSP5680x
*
* Modules Included:  
*                    flashOpen()
*                    flashClose()
*                    flashRead()
*                    flashWrite()
*                    flashIoctl()
*                    flashDevCreate()
*                    flashGetCorrectSize()
*                    flashHWDisableISR()
*                    flashHWClearConfig()
*                    flashHWErase()
*                    flashHWErasePage()
*                    flashHWProgramWord()
*                    flashSetAddressMode()
*                    flashRestoreAddressMode()
*                    memCmpXtoX()
*                    memCmpXtoP()
*                    memCmpPtoX()
*                    memCmpPtoP()
*                    archSetOperatingMode()
*                    
* 
*****************************************************************************/

#include <string.h>

#include "arch.h"
#include "periph.h"
#include "mempx.h"
#include "io.h" 
#include "fcntl.h"
#include "assert.h"
#include "bsp.h"
#include "types.h"

#include "flashdrv.h"

/******************************************************************************
*
*  NB: maximum permitted length to write or to read into/from Flash
*      is PORT_MAX_VECTOR_LEN 
*  
*      Row Programming Mode is not supported.
*     
*      Flash Info Blocks are not supported.
*
*
******************************************************************************/


/*****************************************************************************/
/*                     Registers and constants definition                    */
/*****************************************************************************/

/* Page and raw parameters */

#define FLASH_PAGE_LENGTH     0x0100u
#define FLASH_PAGE_MASK       0x00ffu 
#define FLASH_PAGE_SHIFT      8u

#define FLASH_RAW_LENGTH      0x0020u
#define FLASH_RAW_MASK        0x001fu 
#define FLASH_RAW_SHIFT       5u

/* Flash location in memory map */

#if !defined(FLASH_DBG_MEM)

#define FLASH_DF_START        0x1800u
#define FLASH_DF_LENGTH       0x0800u
#define FLASH_DF_INFOLENGTH   0x0040u

#define FLASH_PF_START        0x0004u
#define FLASH_PF_LENGTH       0x7DFCu
#define FLASH_PF_INFOLENGTH   0x003Cu

#define FLASH_BF_START        0x8000u
#define FLASH_BF_LENGTH       0x0800u
#define FLASH_BF_INFOLENGTH   0x0040u

#else /* !defined(FLASH_DBG_MEM) */

/* only for mem test mode */ 
/* NB: if change have a  look to linker.cmd */

#define FLASH_DF_START        (UWord16)&(DataFlashBuffer[0])
#define FLASH_DF_LENGTH       0x0800u
#define FLASH_DF_INFOLENGTH   0x0040u

#define FLASH_PF_START        0x0004u
#define FLASH_PF_LENGTH       0x7DFCu
#define FLASH_PF_INFOLENGTH   0x003Cu

#define FLASH_BF_START        0xC000u 
#define FLASH_BF_LENGTH       0x0800u
#define FLASH_BF_INFOLENGTH   0x0040u

UWord16 DataFlashBuffer[FLASH_DF_LENGTH + FLASH_PAGE_LENGTH];
UWord16 ProgramFlashBuffer   = FLASH_PF_START;
UWord16 BootFlashBuffer      = FLASH_BF_START; 

#endif /* !defined(FLASH_DBG_MEM) */

/* Flash registers offsets */

#define FLASH_FIU_CNTL        0x0000u
#define FLASH_FIU_PE          0x0001u
#define FLASH_FIU_EE          0x0002u
#define FLASH_FIU_ADDR        0x0003u
#define FLASH_FIU_DATA        0x0004u
#define FLASH_FIU_IE          0x0005u
#define FLASH_FIU_IS          0x0006u
#define FLASH_FIU_IP          0x0007u
#define FLASH_FIU_CKDIVISOR   0x0008u
#define FLASH_FIU_TERASEL     0x0009u
#define FLASH_FIU_TMEL        0x000Au
#define FLASH_FIU_TNVSL       0x000Bu
#define FLASH_FIU_TPGSL       0x000Cu
#define FLASH_FIU_TPROGL      0x000Du
#define FLASH_FIU_TNVHL       0x000Eu
#define FLASH_FIU_TNVH1L      0x000Fu
#define FLASH_FIU_TRCVL       0x0010u

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

/* Flash Interface Units base addresses */

#define FLASH_DFIU_BASE_ADDRESS        ((const UWord16)(&ArchIO.DataFlash))
/* 0x1060u */
#define FLASH_PFIU_BASE_ADDRESS        ((const UWord16)(&ArchIO.ProgramFlash))
/* 0x1020u */
#define FLASH_BFIU_BASE_ADDRESS        ((const UWord16)(&ArchIO.BootFlash))
/* 0x1080u */

#define FLASH_FIU(base, offset)        ((volatile UWord16 *)(base + offset))   

/*****************************************************************************/
/*                        Driver data structures                             */
/*****************************************************************************/

static const io_sInterface  InterfaceVT =
{ 
   flashClose, 
   flashRead, 
   flashWrite, 
   flashIoctl 
};

typedef void * (*tpMemCopy)( void *, const void *, size_t );
typedef int    (*tpMemCmp)( const void *, const void *, size_t );

typedef struct
{
   tpMemCopy   pCopyFtoX;
   tpMemCopy   pCopyFtoP;
   tpMemCopy   pCopyXtoF;
   tpMemCopy   pCopyPtoF;
   tpMemCmp    pCmpFtoX;
   tpMemCmp    pCmpFtoP;
} sFlashMemFunction;

#define FLASH_HANDLE_DD       0
#define FLASH_HANDLE_PD       1
#define FLASH_HANDLE_BD       2
#define FLASH_HANDLE_NUMBER   3

#define FLASH_BUFFER_LENGTH   FLASH_PAGE_LENGTH

typedef struct
{
   const          sFlashMemFunction FlashMemFunction[ 2 ]; 
   UWord16        DeviceBuffer[ FLASH_BUFFER_LENGTH ];     

} sFlashDriver; 
 
#define  FLASH_TYPE_D            0x0001u
#define  FLASH_TYPE_P            0x0002u
#define  FLASH_TYPE_B            0x0004u

/* NB: if pointer array is used bit order is important */
#define  FLASH_STATE_INITIALIZE  0x8000u
#define  FLASH_STATE_NONBLOCKING 0x4000u
#define  FLASH_STATE_VERIFY      0x0004u
#define  FLASH_STATE_DATA_P      0x0001u

typedef struct
{
   const sFlashMemFunction  * pFlashMemFunction;
   const UWord16              Base;

#if defined(FLASH_DBG_MEM)
         UWord16              Start;
#else  /* defined(FLASH_DBG_MEM) */
   const UWord16              Start;
#endif /* defined(FLASH_DBG_MEM) */

   const UWord16              Length;
   const UWord16              Type;       /* see FLASH_TYPE_... for bit masks */
   UWord16                  * pDeviceBuffer;
   UWord16                    Address;
   UWord16                    State;      /* see FLASH_STATE_... for bit masks */
} sFlashDevice;

/*****************************************************************************/

sFlashDriver FlashDriver = 
{
   {
      { /* Flash is located in Data mem */
         memcpy,
         memCopyXtoP,
         memcpy,
         memCopyPtoX,
         memCmpXtoX,
         memCmpXtoP
      },
      {  /* Flash is located in Program mem */
         memCopyPtoX,
         memCopyPtoP,
         memCopyXtoP,
         memCopyPtoP,
         memCmpPtoX,
         memCmpPtoP
      }                              
   },
   {}
};

static sFlashDevice FlashDevice[ FLASH_HANDLE_NUMBER ] =   
{
   {
      &(FlashDriver.FlashMemFunction[0]),
      FLASH_DFIU_BASE_ADDRESS, 
      FLASH_DF_START, 
      FLASH_DF_LENGTH,
      FLASH_TYPE_D,
      FlashDriver.DeviceBuffer,
      FLASH_DF_START,
      0
   }, 
   {
      &(FlashDriver.FlashMemFunction[1]),
      FLASH_PFIU_BASE_ADDRESS, 
      FLASH_PF_START, 
      FLASH_PF_LENGTH, 
      FLASH_TYPE_P,
      FlashDriver.DeviceBuffer,
      FLASH_PF_START,
      0
   }, 
   {
      &(FlashDriver.FlashMemFunction[1]),
      FLASH_BFIU_BASE_ADDRESS, 
      FLASH_BF_START, 
      FLASH_BF_LENGTH, 
      FLASH_TYPE_B,
      FlashDriver.DeviceBuffer,
      FLASH_BF_START,                      
      0
   }
};


static const io_sDriver Driver[FLASH_HANDLE_NUMBER] = 
	{
		{(io_sInterface *)&InterfaceVT, (int)&FlashDevice[0]},
		{(io_sInterface *)&InterfaceVT, (int)&FlashDevice[1]},
		{(io_sInterface *)&InterfaceVT, (int)&FlashDevice[2]},
	};

/* Constants for time programming */

/*****************************************************************************/
/*               Internal Functions prototypes                               */
/*****************************************************************************/

static UWord16 flashGetCorrectSize ( sFlashDevice * pFlashDevice, size_t Size );

static void flashHWDisableISR    ( UWord16 FiuBase );
static void flashHWClearConfig   ( UWord16 FiuBase );

static UWord16 flashSetAddressMode  ( sFlashDevice * pFlashDevice);
static void flashRestoreAddressMode ( sFlashDevice * pFlashDevice, UWord16 Mode);
 
static void flashHWErase         ( UWord16 FiuBase, tpMemCopy pMemCopy, 
                                   UWord16 Address );

static void flashHWErasePage     ( UWord16 FiuBase, tpMemCopy pMemCopy, 
                                   UWord16 Address );

static void flashHWProgramWord   ( UWord16 FiuBase, tpMemCopy pMemCopy, 
                                   UWord16 Address, UWord16 * pData );

/*****************************************************************************/
/*                             ISR subroutins                                */
/*****************************************************************************/
/* Not used */

/*****************************************************************************/
/*                             API functions                                 */
/*****************************************************************************/

/*****************************************************************************
*
* Module:         flashOpen()
*
* Description:    Open specified Flash device for user. 
*
* Returns:        Device descriptor if success
*                 -1 if specified device name is not Flash device name
*
* Arguments:      pName - BSP Flash device name
*                 OFlags - open mode flags. 
*                          O_NONBLOCK mode is not supported.
*                          Îther flags are ignored
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
io_sDriver * flashOpen(const char * pName, int OFlags, ...)
{
   sFlashDevice * pFlashDevice = NULL;
   io_sDriver * pDriver;

   switch ( (UWord16)pName )
   {
      case (UWord16)BSP_DEVICE_NAME_FLASH_X:
      {
         pFlashDevice = &(FlashDevice[FLASH_HANDLE_DD]);
         pDriver      = (io_sDriver *)&Driver[FLASH_HANDLE_DD];
      }
      break;
      case (UWord16)BSP_DEVICE_NAME_FLASH_P:
      {
         pFlashDevice = &(FlashDevice[FLASH_HANDLE_PD]);
         pDriver      = (io_sDriver *)&Driver[FLASH_HANDLE_PD];
      }
      break;
      case (UWord16)BSP_DEVICE_NAME_FLASH_B:
      {
         pFlashDevice = &(FlashDevice[FLASH_HANDLE_BD]);
         pDriver      = (io_sDriver *)&Driver[FLASH_HANDLE_BD];
      }
      break;
      default:
      {
         return (io_sDriver *) -1;
      }
   }
      
   pFlashDevice->Address   = pFlashDevice->Start;

      
   assert(!((UWord16)OFlags & O_NONBLOCK)); /* NonBlocking Mode is not supported for Flash Driver */
   
   pFlashDevice->State = FLASH_STATE_INITIALIZE;

   return pDriver;
}

/*****************************************************************************
*
* Module:         flashClose()
*
* Description:    Close specified Flash device
*
* Returns:        0 
*
* Arguments:      FileDesc - device descriptor
*
* Range Issues:   None
*
* Special Issues: Just change device state to 0.
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
int flashClose(int FileDesc)
{
   sFlashDevice * pFlashDevice   = (sFlashDevice *) FileDesc;
   
   pFlashDevice->State           = 0;
   
   return 0;
}

/*****************************************************************************
*
* Module:         flashRead()
*
* Description:    Read or verify flash context, depends on FLASH_STATE_VERIFY
*                 bit in device state. 
*
* Returns:        Actual processed size
*
* Arguments:      FileDesc - device descriptor
*                 pBuffer - pointer to users buffer
*                 Size - User buffer size
*        
* Range Issues:   Deneral limitation : 0 <= Size <= PORT_MAX_VECTOR_LEN
*                 Perticular limitation is calculated in flashGetCorrectSize()
*                 function, based on Flash size and current flash address.
*                 Corrected size is used in function.
*
* Special Issues: To have access to Flash module function set appropriate 
*                 proccesor addressing mode. See flashSetAddressMode() and 
*                 flashRestoreAddressMode() functions
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
ssize_t flashRead(int FileDesc, void * pBuffer, size_t Size)
{
   tpMemCmp             pMemCmpFunction   = NULL ;
   sFlashDevice      *  pFlashDevice      = (sFlashDevice *)FileDesc;
   UWord16           *  pUserData         = (UWord16 *) pBuffer;
   UWord16              CorrectSize       = Size;
   UWord16              FlashAdderess     = pFlashDevice->Address;
   UWord16              Mode;

   /* Check size boundares */
   
   CorrectSize = flashGetCorrectSize(pFlashDevice, Size);
   
   if (CorrectSize != 0)
   {

      /* get proper function */
   
      Mode = flashSetAddressMode(pFlashDevice);

      if (pFlashDevice->State & FLASH_STATE_VERIFY )
      {
         if ( pFlashDevice->State & FLASH_STATE_DATA_P )
         {                                                  /* Verify P data */
            pMemCmpFunction = pFlashDevice->pFlashMemFunction->pCmpFtoP;         
         }
         else
         {                                                  /* Verify D data */
            pMemCmpFunction = pFlashDevice->pFlashMemFunction->pCmpFtoX;
         }

         /* perform verification */
         if ( (*pMemCmpFunction)( pUserData, (UWord16 *)FlashAdderess, CorrectSize ) != 0 )
         {
            FlashAdderess    += CorrectSize;
            CorrectSize     = 0;
         }
      }
      else
      {
         /* Perform reading */
         if ( pFlashDevice->State & FLASH_STATE_DATA_P )
         {                                                  /* Read P data */
            (*pFlashDevice->pFlashMemFunction->pCopyFtoP)(  pUserData, (const UWord16 *)FlashAdderess, 
                                                      CorrectSize );
         }
         else
         {                                                  /* Read D data */
            (*pFlashDevice->pFlashMemFunction->pCopyFtoX)(  pUserData, (const UWord16 *)FlashAdderess, 
                                                      CorrectSize );
         }
      }

      flashRestoreAddressMode(pFlashDevice, Mode);

      pFlashDevice->Address = FlashAdderess + CorrectSize;
   }  

   
   return CorrectSize;
}

/*****************************************************************************
*
* Module:         flashWrite()
*
* Description:    Write data from user buffer into flash. Memory type (P: or X:) 
*                 of user determine based on FLASH_STATE_DATA_P bit in device 
*                 Perform verification if FLASH_STATE_VERIFY bit in device 
*                 state is set.
*
*                 Determine page to write, 
*                 Check is it empty page or not
*                 If not empty, 
*                    save data from this page into driver buffer and erase page                    
*                 Merge saved data and data from user buffer
*                 Program data from driver buffer into flash page
*                 Continue while end of user buffer
*
* Returns:        Actual processed size
*
* Arguments:      FileDesc - device descriptor
*                 pBuffer - pointer to users buffer
*                 Size - User buffer size
*        
* Range Issues:   Deneral limitation : 0 <= Size <= PORT_MAX_VECTOR_LEN
*                 Perticular limitation is calculated in flashGetCorrectSize()
*                 function, based on Flash size and current flash address.
*                 Corrected size is used in function.
*
* Special Issues: To have access to Flash module function set appropriate 
*                 proccesor addressing mode. See flashSetAddressMode() and 
*                 flashRestoreAddressMode() functions
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
ssize_t flashWrite(int FileDesc, const void * pBuffer, size_t Size)
{
   UWord16              i;
   UWord16              Counter;
   UWord16              PageCounter;
   UWord16              RawCounter;
   UWord16            * pWriteData         = NULL;
   tpMemCopy            pMemCopyFunction   = NULL;
   bool                 bErase         = false;
   bool                 bContinue      = true;
   bool                 bContinuePage  = true;
   sFlashDevice       * pFlashDevice   = (sFlashDevice *) FileDesc;
   UWord16            * pUserData      = (UWord16 *) pBuffer;
   UWord16              CorrectSize    = Size;
   UWord16              FlashAddress   = pFlashDevice->Address;
   UWord16              Mode;

   /* Check size boundares */
   
   CorrectSize = flashGetCorrectSize(pFlashDevice, Size);
      
   if ( CorrectSize != 0 )
   {

      Counter = CorrectSize;

      Mode = flashSetAddressMode(pFlashDevice);

      /* write Flash page by page */
      while (bContinue)
      {
        
         PageCounter = FLASH_PAGE_LENGTH - ( FlashAddress & FLASH_PAGE_MASK );
        
         if ( PageCounter >= Counter )
         {
            PageCounter = Counter;
            bContinue   = false;
         }
         else
         {
            Counter -= PageCounter;
         }
         
         /* Check write space - is it 0xffff  ? */
         memset ( pFlashDevice->pDeviceBuffer, 0xffffu, FLASH_PAGE_LENGTH);
         
         if ( (*(pFlashDevice->pFlashMemFunction->pCmpFtoX))( pFlashDevice->pDeviceBuffer, 
                                                        ( UWord16 * )FlashAddress, 
                                                        PageCounter ) != 0 )
         {
            bErase = true;
         }
         

         if (( bErase == true ) && ( PageCounter < FLASH_PAGE_LENGTH) ) 
         {     /* Save page  and merge data */
            
            (*(pFlashDevice->pFlashMemFunction->pCopyFtoX)) ( pFlashDevice->pDeviceBuffer, 
                                                       (UWord16 *)(FlashAddress & ~FLASH_PAGE_MASK),   
                                                       FLASH_PAGE_LENGTH
                                                       );            
            if (pFlashDevice->State & FLASH_STATE_DATA_P )
            {
               memCopyPtoX(   &(pFlashDevice->pDeviceBuffer[FlashAddress & FLASH_PAGE_MASK]), 
                              pUserData,
                              PageCounter);
            } 
            else
            {
               memCopyXtoX(   &(pFlashDevice->pDeviceBuffer[FlashAddress & FLASH_PAGE_MASK]), 
                              pUserData, 
                              PageCounter);
            }

            /* correct PageCounter and start address */
            
            pWriteData         = pFlashDevice->pDeviceBuffer;
            pUserData         += PageCounter;
            FlashAddress      &= ~FLASH_PAGE_MASK;
            PageCounter        = FLASH_PAGE_LENGTH;
            pMemCopyFunction   = pFlashDevice->pFlashMemFunction->pCopyXtoF;
         }
         else
         {
            pWriteData         = pUserData;
            pUserData         += PageCounter;

            /* get proper copy function */

            if ( pFlashDevice->State & FLASH_STATE_DATA_P )
            {
               pMemCopyFunction = pFlashDevice->pFlashMemFunction->pCopyPtoF;         
            }
            else
            {
               pMemCopyFunction = pFlashDevice->pFlashMemFunction->pCopyXtoF;         
            }  
         }  /* if buffered */
                     
         if ( bErase == true )
         {                          /* Erase page  */
            flashHWErasePage( pFlashDevice->Base, pFlashDevice->pFlashMemFunction->pCopyXtoF, 
                              FlashAddress ); 
         }

         bContinuePage  = true;

         while (bContinuePage)
         {
            RawCounter = FLASH_RAW_LENGTH - (FlashAddress & FLASH_RAW_MASK);
         
            if ( RawCounter >= PageCounter )
            {
               RawCounter     = PageCounter;
               bContinuePage  = false;
            }
            else
            {
               PageCounter   -= RawCounter;
            }

            /* perform intellectual programming word by word */
            for ( i = 0; i < RawCounter ; i++ )
            {
               flashHWProgramWord(pFlashDevice->Base, pMemCopyFunction, FlashAddress, pWriteData);

               FlashAddress++;
               pWriteData++;
            }                              
         }  /* while (bPageContinue) */           
      }  /* while (bContinue) */
   
      flashRestoreAddressMode(pFlashDevice,Mode);

      /* perform verification if needed */
      if (pFlashDevice->State & FLASH_STATE_VERIFY)
      {
         CorrectSize = flashRead( FileDesc, (void *)pBuffer, Size);
      }
      else
      {
         pFlashDevice->Address += CorrectSize;                 /* Set correct address after writing */
      }

   }  /* if (CorrectSize == 0) */

   return CorrectSize;      
}


/*****************************************************************************
*
* Module:         flashIoctl()
*
* Description:    Function to change device modes. See flash.h file for mode
*                 descriptions
*
* Returns:        0
*
* Arguments:      FileDesc  - device descriptor
*                 Cmd      - commnad for driver 
*                 pParams  - pointer to optional command parameters
*  
* Range Issues:   Not supported command will be ignored
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
UWord16 flashIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...)
{
   sFlashDevice   * pFlashDevice = (sFlashDevice *) FileDesc;

   switch(Cmd)
   {
      case FLASH_RESET:
      {
         pFlashDevice->Address   = pFlashDevice->Start;
         pFlashDevice->State     = FLASH_STATE_INITIALIZE;
         
         /* wait for BUSY flag */               
         break;
      }
      case FLASH_SET_VERIFY_ON:
      {
         pFlashDevice->State |= FLASH_STATE_VERIFY;
         break;
      }
      case FLASH_SET_VERIFY_OFF:
      {
         pFlashDevice->State &= ~FLASH_STATE_VERIFY;        
         break;
      }
      case FLASH_CMD_SEEK:
      {
         /* protect from overwriting */
         
         pFlashDevice->Address = ( pFlashDevice->Start + (*(UWord16*)pParams));
         
         if (pFlashDevice->Address  > ( pFlashDevice->Start +  pFlashDevice->Length ))
         {
            pFlashDevice->Address = ( pFlashDevice->Start +  pFlashDevice->Length ); 
         }  
   
         break;
      }
      case FLASH_SET_USER_X_DATA:
      {
         pFlashDevice->State &= ~FLASH_STATE_DATA_P;
         break;
      }
      case FLASH_SET_USER_P_DATA:
      {
         pFlashDevice->State |= FLASH_STATE_DATA_P;         
         break;
      }
      case FLASH_CMD_ERASE_ALL:
      {
         UWord16  Mode;

         Mode = flashSetAddressMode(pFlashDevice);

         flashHWErase( pFlashDevice->Base, pFlashDevice->pFlashMemFunction->pCopyXtoF, 
                       pFlashDevice->Start );

         flashRestoreAddressMode(pFlashDevice,Mode);

         pFlashDevice->Address   = pFlashDevice->Start;
         
         break;
      }
      default:
         break;
   }

   return 0;
}

                                                      
/*****************************************************************************
*
* Module:         flashDevCreate()
*
* Description:    Register flash driver, see flashdrv.h. Initilaize all flash 
*                 devices
*
* Returns:        0
*
* Arguments:      pFlashInitialize - pointer to driver structure
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
UWord16 flashDevCreate(const sFlashInitialize * pFlashInitialize)
{
   int i;

   for ( i = 0; i < FLASH_HANDLE_NUMBER; i++ )  /* Disable all Flash related interrupts */      
   {
      flashHWDisableISR(FlashDevice[ i ].Base);                                 
      flashHWClearConfig(FlashDevice[ i ].Base);
   }

#if defined(FLASH_DBG_MEM)
   FlashDevice[FLASH_HANDLE_DD].Start     = (FlashDevice[FLASH_HANDLE_DD].Start & ~FLASH_PAGE_MASK) + FLASH_PAGE_LENGTH;
#endif /* defined(FLASH_DBG_MEM) */

   for ( i = 0; i < FLASH_HANDLE_NUMBER; i++ )        /* Set start address and state  */
   {
#if defined(FLASH_DBG_MEM)
   /* FlashDevice[i].Start    = (FlashDevice[i].Start & ~FLASH_PAGE_MASK) + FLASH_PAGE_LENGTH; */
#endif /* defined(FLASH_DBG_MEM) */
      FlashDevice[i].Address  = FlashDevice[i].Start;
      FlashDevice[i].State    = 0;      
   }


   for ( i = 0; i < FLASH_FIU_TIMER_NUMBER ; i++)     /* Initialize flash timer registers */
   {                                                  /* is has to be a separate HW specific function */
      if ( pFlashInitialize->pDfiuInitTime != 0 )
      {
         periphMemWrite( *(pFlashInitialize->pDfiuInitTime + i), 
            FLASH_FIU(FlashDevice[ FLASH_HANDLE_DD ].Base, ( FLASH_FIU_CKDIVISOR + i)));
      }

      if ( pFlashInitialize->pPfiuInitTime != 0 )
      {
         periphMemWrite( *(pFlashInitialize->pPfiuInitTime + i), 
            FLASH_FIU(FlashDevice[ FLASH_HANDLE_PD ].Base, ( FLASH_FIU_CKDIVISOR + i)));      
      }

      if ( pFlashInitialize->pBfiuInitTime != 0 )
      {
         periphMemWrite( *(pFlashInitialize->pBfiuInitTime + i), 
            FLASH_FIU(FlashDevice[ FLASH_HANDLE_BD ].Base, ( FLASH_FIU_CKDIVISOR + i)));
      }
   }

   ioDrvInstall(flashOpen);

   return 0;
}
                              
/*****************************************************************************
*
* Module:         flashGetCorrectSize()
*
* Description:    Calculate correct operation size for particular flash device.
*                 
*
* Returns:        Corrected size
*
* Arguments:      pFlashDevice - device context
*                 Size  - requested size 
*
* Range Issues:   None
*
* Special Issues: Works with 32 bit data to avoid overflow
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static UWord16  flashGetCorrectSize(sFlashDevice * pFlashDevice, size_t Size)
{
   UWord16 TmpCorrectSize = Size;
   UWord32 TmpLong1; 
   UWord32 TmpLong2; 

   if ( TmpCorrectSize > pFlashDevice->Length )
   {
      TmpCorrectSize = pFlashDevice->Length;
   }
#if defined(FLASH_DBG_MEM)
   TmpLong1 = (UWord32)pFlashDevice->Address;
   TmpLong1 -= (UWord32)pFlashDevice->Start;
   TmpLong1 += (UWord32)TmpCorrectSize;

   TmpLong2 = pFlashDevice->Length;

   if (TmpLong1 > TmpLong2)
   {
      TmpCorrectSize = pFlashDevice->Length - (pFlashDevice->Address - pFlashDevice->Start);
   }

#else
   if ((TmpCorrectSize + (UWord32)pFlashDevice->Address ) > ( pFlashDevice->Length + pFlashDevice->Start ))
   {
      TmpCorrectSize = ( pFlashDevice->Length + pFlashDevice->Start ) - pFlashDevice->Address;
   }
#endif /* defined(FLASH_DBG_MEM) */
   if ( TmpCorrectSize > PORT_MAX_VECTOR_LEN )
   {
      TmpCorrectSize = PORT_MAX_VECTOR_LEN;
   }

   return TmpCorrectSize;
}

/*****************************************************************************/
/*                      HW Registers specific functions                      */
/*****************************************************************************/

/*****************************************************************************
*
* Module:         flashHWDisableISR()
*
* Description:    Disable flash related ISR, clear all Flash ISR flags
*
* Returns:        None
*
* Arguments:      FiuBase  - FIU base address 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashHWDisableISR( UWord16 FiuBase )
{
#if defined(FLASH_DBG_MEM)   
   /* do nothing */
#else
   while (periphBitTest( FLASH_FIU_CNTL_BUSY, FLASH_FIU(FiuBase, FLASH_FIU_CNTL)))
   {
   }
   /* disable all flash related interrupts */
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IE));
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS));
#endif
}

/*****************************************************************************
*
* Module:         flashHWClearConfig()
*
* Description:    Clear FIU configuration
*
* Returns:        None
*
* Arguments:      FiuBase  - FIU base address 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashHWClearConfig( UWord16 FiuBase )
{
#if defined(FLASH_DBG_MEM)

#else


   while (periphBitTest( FLASH_FIU_CNTL_BUSY, FLASH_FIU(FiuBase, FLASH_FIU_CNTL)))
   {
   }

   periphBitClear( FLASH_FIU_CNTL_IFREN, FLASH_FIU(FiuBase, FLASH_FIU_CNTL));


   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_PE));
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_EE));

#endif /* defined(FLASH_DBG_MEM) */
}


/*****************************************************************************
*
* Module:         flashHWErase()
*
* Description:    Erase entire Flash memory.
*
* Returns:        None
*
* Arguments:      FiuBase  - FIU base address 
*                 pMemCopy - copy from data memory into flash memory space 
*                             function
*                 Address  - address whithin Flash address range
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashHWErase( UWord16 FiuBase, tpMemCopy pMemCopy, UWord16 Address)
{
#if defined(FLASH_DBG_MEM)
   
   UWord16        TmpAddress;
   UWord16        TmpData = 0xAAAA;
   UWord16        i;
   sFlashDevice   * pFlashDevice = NULL;

   for ( i = 0; i < FLASH_HANDLE_NUMBER; i++)
   {
      if ( FlashDevice[i].Base == FiuBase )
      {
         pFlashDevice = &(FlashDevice[i]);
      }
   }

   assert (!(pFlashDevice == NULL));        /* Wrong base address */

   (*pMemCopy)((UWord16 *)Address, &TmpData, sizeof(UWord16));

   TmpAddress = pFlashDevice->Start;

   TmpData = 0xffff;

   for ( i = 0; i < pFlashDevice->Length; i++)
   {
      (*pMemCopy)((UWord16 *)TmpAddress, &TmpData, sizeof(UWord16));
      TmpAddress++;
   }

#else

   /* NB: code has been copied from flashErasePage() with minor modification */
   /* (set MAS1 to enable mass erase) */ 

   UWord16 TmpWord;
   UWord16 TmpData = 0;

   /* Check flash mode - it shoud be Standby or Read */
   assert ( !periphBitTest(~FLASH_FIU_CNTL_IFREN, FLASH_FIU(FiuBase, FLASH_FIU_CNTL))); /* Flash busy. */
   
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS ));

   /* Set IE[8] bit in the FIU_IE register to enable to Trcv interrupt if desired */
   // periphBitClear( FLASH_FIU_IE_8, FLASH_FIU(FiuBase, FLASH_FIU_IE));

   /* Enable erase by setting IEE and page number in FIU_EE register */
   periphMemWrite ( FLASH_FIU_EE_IEE , FLASH_FIU(FiuBase, FLASH_FIU_EE));

   /* NB: Correction for doc - use 0 page in mas erase mode */
   
   /* set MAS1 to enable mass erase */
   periphBitSet( FLASH_FIU_CNTL_MAS1, FLASH_FIU(FiuBase, FLASH_FIU_CNTL) );
   
   /* Write any value to page to start erase */
   (*pMemCopy)((UWord16 *)Address, &TmpData, sizeof(UWord16));

   /* wait while erase operation will be completed */
   while ( periphBitTest( FLASH_FIU_CNTL_BUSY, FLASH_FIU(FiuBase, FLASH_FIU_CNTL) ))
   {
   }

   TmpWord = periphMemRead( FLASH_FIU(FiuBase, FLASH_FIU_IS ));
 
                         /* IS[2] has been set in this moment */
                         /* Illegal read/write access to flash during erase */
   assert(!(TmpWord & 0x0003)); /* access to flash while erase */

   periphBitClear( FLASH_FIU_CNTL_MAS1, FLASH_FIU(FiuBase, FLASH_FIU_CNTL) );

   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_EE));
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS));

#endif /* defined(FLASH_DBG_MEM) */

}

/*****************************************************************************
*
* Module:         flashHWErasePage()
*
* Description:    Erase page where Address is located.                 
*
* Returns:        None
*
* Arguments:      FiuBase  - FIU base address 
*                 pMemCopy - copy from data memory into flash memory space 
*                             function
*                 Address  - address whithin erased page
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashHWErasePage( UWord16 FiuBase, tpMemCopy pMemCopy, UWord16 Address )
{
#if defined(FLASH_DBG_MEM)
   
   UWord16        i;
   UWord16        TmpAddress;
   UWord16        TmpData = 0xAAAA;

   (*pMemCopy)((UWord16 *)Address, &TmpData, sizeof(UWord16));

   TmpAddress = Address & ~FLASH_PAGE_MASK;

   TmpData = 0xffff;

   for ( i = 0; i < FLASH_PAGE_LENGTH; i++)
   {
      (*pMemCopy)((UWord16 *)TmpAddress, &TmpData, sizeof(UWord16));
      TmpAddress++;
   }

#else

   UWord16 TmpData = 0;
   UWord16 TmpWord;

   /* Check flash mode - it shoud be Standby or Read */
   assert ( !periphBitTest( ~FLASH_FIU_CNTL_IFREN, FLASH_FIU(FiuBase, FLASH_FIU_CNTL) )); /* flash busy */
   
   /* Set IE[8] bit in the FIU_IE register to enable to Trcv interrupt if desired */
   // periphBitClear ( FLASH_FIU_IE_8, FLASH_FIU(FiuBase, FLASH_FIU_IE));

   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS ));

   /* Enable erase by setting IEE and page number in FIU_EE register */
   periphMemWrite( FLASH_FIU_EE_IEE | ((Address)>> FLASH_PAGE_SHIFT), FLASH_FIU(FiuBase, FLASH_FIU_EE));

   /* Write any value to page to start erase */
   (*pMemCopy)((UWord16 *)Address, &TmpData, sizeof(UWord16));
   

   /* wait while erase operation will be completed */
   while (periphBitTest( FLASH_FIU_CNTL_BUSY, FLASH_FIU(FiuBase, FLASH_FIU_CNTL) ))
   {
   }

   TmpWord = periphMemRead( FLASH_FIU(FiuBase, FLASH_FIU_IS ));
   
                           /* IS[2] has been set in this moment */
                           /* Illegal read/write access to flash during erase */
   assert(!(TmpWord & 0x0003));  /* access to flash while erase */

   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_EE));
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS));

#endif /* defined(FLASH_DBG_MEM) */

}

/*****************************************************************************
*
* Module:         flashHWProgramWord()
*
* Description:    Program one word into Flash using intellectual programming 
*                 mode. 
*                 
* Returns:        None
*
* Arguments:      FiuBase  - FIU base address 
*                 pMemCopy - copy function
*                 Address  - address for programming
*                 pData    - pointer to word 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashHWProgramWord ( UWord16 FiuBase, tpMemCopy pMemCopy, 
                                 UWord16 Address, UWord16 * pData )
{
#if defined(FLASH_DBG_MEM)
   
   (*pMemCopy)((UWord16 *)Address, pData, sizeof(UWord16));

#else

   UWord16 TmpWord;
   UWord16 TmpWord2;

   /* Check flash mode - it should be Standby or Read */
   assert ( !periphBitTest( ~FLASH_FIU_CNTL_IFREN , FLASH_FIU(FiuBase, FLASH_FIU_CNTL) )); /* Flash busy */ 
   
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS ));
   
   /* set IE[8] bit in FIU_IE to enable Trcv interrupt */
   /* periphBitClear( FLASH_FIU_IE_8, FLASH_FIU(FiuBase, FLASH_FIU_IE)); */
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IE));

   /* Enable programming by setting IPE and raw number in FIU_PE register */
   periphMemWrite( FLASH_FIU_PE_IPE | ((Address) >> FLASH_RAW_SHIFT), 
                   FLASH_FIU(FiuBase, FLASH_FIU_PE));
  
/*   TmpWord2  = Address;

   TmpWord2  = FLASH_FIU_PE_IPE | ((TmpWord2) >> FLASH_RAW_SHIFT);

   periphMemWrite( TmpWord2, FLASH_FIU(FiuBase, FLASH_FIU_PE));
*/

   /* Write the data */
   
   // *(UWord16 *)Address = *pData;
   (*pMemCopy)((UWord16 *)Address, pData, sizeof(UWord16));

   while ( periphBitTest( FLASH_FIU_CNTL_BUSY, FLASH_FIU(FiuBase, FLASH_FIU_CNTL)))
   {
   }

   TmpWord = periphMemRead( FLASH_FIU(FiuBase, FLASH_FIU_IS ));

                           /* IS[1] has been set in this moment  */
                           /* Illegal read/write access to flash during programm */
   assert (!(TmpWord & 0x0005));   /* Access to flash while programming */

   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_PE));
   periphMemWrite( 0, FLASH_FIU(FiuBase, FLASH_FIU_IS));

#endif /* defined(FLASH_DBG_MEM) */

}


/*****************************************************************************
*
* Module:         flashSetAddressMode()
*
* Description:    Set internal addressing mode for Boot and Program flash 
*                 to get access to flash
*
* Returns:        Old addressing mode
*
* Arguments:      pFlashDevice - device context
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
/* To do: save and restore interrupt mask */

static UWord16 flashSetAddressMode  ( sFlashDevice * pFlashDevice)
{

   UWord16 Mode = 0;

#if !defined(FLASH_DBG_MEM)

   if ( pFlashDevice->Type & ( FLASH_TYPE_B | FLASH_TYPE_P ))
   {
      archDisableInt();
   
      Mode = archSetOperatingMode(0x0000);

   }

#endif /* !defined(FLASH_DBG_MEM) */

   return Mode;
  
}

/*****************************************************************************
*
* Module:         flashRestoreAddressMode()
*
* Description:    Restore saved addressing mode.
*
* Returns:        None
*
* Arguments:      pFlashDevice - device context
*                 Mode - saved mode
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
static void flashRestoreAddressMode ( sFlashDevice * pFlashDevice, UWord16 Mode)
{
   
#if !defined(FLASH_DBG_MEM)

   if ( pFlashDevice->Type & ( FLASH_TYPE_B | FLASH_TYPE_P ))
   {
      archSetOperatingMode(Mode);

      archEnableInt();
   }

#endif /* !defined(FLASH_DBG_MEM) */

}








/*****************************************************************************/

/*****************************************************************************
*
* Module:         memCmpXtoX()
*
* Description:    Compare len words in X:src1 and X:src2 buffers 
*                 
* Returns:        0 if equal 
*
* Arguments:      src1  - first buffer
*                 src2  - second buffer
*                 len   - length to be compared 
*
* Range Issues:   0 <= len < PORT_MAX_VECTOR_LEN 
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
int      memCmpXtoX(const void * src1, const void * src2, size_t len)
{
   assert ( !(len > PORT_MAX_VECTOR_LEN) );

   return memcmp(src1, src2, len);
}

/*****************************************************************************
*
* Module:         memCmpXtoP()
*
* Description:    Compare len words in P:src1 and X:src2 buffers 
*                 
* Returns:        0 if equal 
*
* Arguments:      src1  - first buffer
*                 src2  - second buffer
*                 len   - length to be compared 
*
* Range Issues:   0 <= len < PORT_MAX_VECTOR_LEN 
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
int      memCmpXtoP(const void * src1, const void * src2, size_t len)
{
   int     Diff = 0;
	UWord16  *  p1 = (UWord16 *)src1;
	UWord16  *  p2 = (UWord16 *)src2;


   assert( !(len > PORT_MAX_VECTOR_LEN ));

	while (len)
	{
		Diff = *p2 - memReadP16(p1);
		if (Diff) 
      {
         break;
      }
		p1++;
		p2++;
		len--;
	}
	
	return Diff;
}

/*****************************************************************************
*
* Module:         memCmpPtoX()
*
* Description:    Compare len words in X:src1 and P:src2 buffers 
*                 
* Returns:        0 if equal 
*
* Arguments:      src1  - first buffer
*                 src2  - second buffer
*                 len   - length to be compared 
*
* Range Issues:   0 <= len < PORT_MAX_VECTOR_LEN 
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
int      memCmpPtoX(const void * src1, const void * src2, size_t len)
{
   int     Diff = 0;
	UWord16  *  p1 = (UWord16 *)src1;
	UWord16  *  p2 = (UWord16 *)src2;

   assert( !(len > PORT_MAX_VECTOR_LEN) );

   while (len)
	{
		Diff =  memReadP16(p2) - *p1;
		if (Diff) 
      {
         break;
      }
		p1++;
		p2++;
		len--;
	}

	return Diff;
}

/*****************************************************************************
*
* Module:         memCmpPtoP()
*
* Description:    Compare len words in P:src1 and P:src2 buffers 
*                 
* Returns:        0 if equal 
*
* Arguments:      src1  - first buffer
*                 src2  - second buffer
*                 len   - length to be compared 
*
* Range Issues:   0 <= len < PORT_MAX_VECTOR_LEN 
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/
int      memCmpPtoP(const void * src1, const void * src2, size_t len)
{
   int     Diff = 0;
	UWord16  *  p1 = (UWord16 *)src1;
	UWord16  *  p2 = (UWord16 *)src2;

   assert( !(len > PORT_MAX_VECTOR_LEN) );

   while (len)
	{
		Diff =  memReadP16(p2) - memReadP16(p1);
		if (Diff) 
      {
         break;
      }
		p1++;
		p2++;
		len--;
	}

	return Diff;
}

/*****************************************************************************
*
* Module:         archSetOperatingMode()
*
* Description:    Set requred processor operation mode
*                 
* Returns:        Previos operation mode
*
* Arguments:      Y0 - opeartion mode to set
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/

UWord16 archSetOperatingMode( UWord16 )
{
   asm 
   {
      bfclr 0xfffc, Y0
      move  OMR, X0
      bfclr 0x0003, X0
      or    Y0,X0
      move  OMR, Y0
      bfclr 0xfffc, Y0      
      move  X0, OMR
   }

}






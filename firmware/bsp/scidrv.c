/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         scidrv.c
*
* Description:       SCI driver for DSP5680x
*
* Modules Included:  
*                    sciOpen
*                    sciClose()
*                    sciRead()
*                    sciWrite()
*                    ioctlSCI_DATAFORMAT_EIGHTBITCHARS()
*                    ioctlSCI_DATAFORMAT_RAW()
*                    ioctlSCI_DEVICE_RESET()
*                    ioctlSCI_SET_READ_LENGTH()
*                    ioctlSCI_GET_STATUS()
*                    ioctlSCI_GET_EXCEPTION()
*                    sciDevCreate()
*                    sciSetConfig()
*                    sciReadClear()
*                    sciWriteClear()
*                    sciDeviceOff()
*                    sciDeviceOn()
*                    sciRestoreInterrupts()
*                    sciHWDisableInterrupts()
*                    sciHWEnableRxInterrupts()
*                    sciHWDisableRxInterrupts()
*                    sciHWEnableTxCompleteInterrupt()
*                    sciHWEnableTxReadyInterrupt()
*                    sciHWDisableTxInterrupts()
*                    sciHWConfigure()
*                    sciHWDisableDevice()
*                    sciHWEnableDevice()
*                    sciHWClearRxInterrupts()
*                    sciHWInstallISR()
*                    sciHWReceiveByte()
*                    sciHWSendByte()
*                    sciHWWaitStatusRegister()
*                    sci0ReceiverISR()
*                    sci0TransmitterISR()
*                    sci1ReceiverISR()
*                    sci1TransmitterISR()
*                    sciHWReceiver()
*                    sciHWTransmitter()
* 
*****************************************************************************/

#include "arch.h"
#include "port.h"
#include "io.h"
#include "bsp.h"
#include "fcntl.h"
#include "sim.h"

#include "fifo.h"
#include "stdlib.h"
#include "string.h"
#include "periph.h"

#include "stdarg.h"

#include "assert.h"

#include "scidrv.h"

#include "types.h"


/*****************************************************************************/
/*                         Driver Data types                                 */
/*****************************************************************************/

const io_sInterface  InterfaceVT =
{ 
   sciClose, 
   sciRead, 
   sciWrite, 
   NULL 
};


/* Configuration and Status constants */
#define  SCI_CONFIG_INITIALIZE   0x8000u
#define  SCI_CONFIG_NONBLOCKING  0x4000u

#define  SCI_STATE_HIBIT         0x0100u
#define  SCI_STATE_EIGHTBITCHAR  0x0010u
#define  SCI_STATE_INPROGRESS    0x0002u
#define  SCI_STATE_LOWBYTE       0x0001u

#define SCI0_BASE_ADDRESS        ((const UWord16)(&ArchIO.Sci0))
#if defined(BSP_DEVICE_NAME_SCI_1)
#define SCI1_BASE_ADDRESS        ((const UWord16)(&ArchIO.Sci1))
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
#define SCI2_BASE_ADDRESS        ((const UWord16)(&ArchIO.Sci2))
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */

#define SCI_ISROFFSET(field)     ((UWord32)&(((arch_sInterrupts *)0x0000)->field))
#define SCI_ISROFFSET2ADDR(archIsr,off)   \
                                 (UWord32*)( (UWord16*)( archIsr ) + ( off ))

#define SCI0_ISR_BASE_OFFSET     SCI_ISROFFSET(Sci0.TransmitterComplete)
#if defined(BSP_DEVICE_NAME_SCI_1)
#define SCI1_ISR_BASE_OFFSET     SCI_ISROFFSET(Sci1.TransmitterComplete)
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
#define SCI2_ISR_BASE_OFFSET     SCI_ISROFFSET(Sci2.TransmitterComplete)
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */


#define SCI0_NUMBER              0 
#if defined(BSP_DEVICE_NAME_SCI_1)
#define SCI1_NUMBER              1
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
#define SCI2_NUMBER              2
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */


sSciDriver SciDriver; 

sSciDevice SciDevice[SCI_HANDLE_NUMBER] = 
{
   {
      SCI0_BASE_ADDRESS,
      SCI0_ISR_BASE_OFFSET,
      SCI0_NUMBER,
      0,
      0,
      0,
      NULL,
      NULL,
      NULL,
   },
#if defined(BSP_DEVICE_NAME_SCI_1)   
   {
     SCI1_BASE_ADDRESS,
     SCI1_ISR_BASE_OFFSET,
     SCI1_NUMBER,
     0,
     0, 
     0,
     NULL,
     NULL,
     NULL,
   },
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)   
   {
     SCI2_BASE_ADDRESS,
     SCI2_ISR_BASE_OFFSET,
     SCI2_NUMBER,
     0,
     0, 
     0,
     NULL,
     NULL,
     NULL,
   }
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */
};

const io_sDriver scidrvIODevice[3] =
	{
		{ &InterfaceVT, (int)&SciDevice[SCI_HANDLE_0] },
		{ &InterfaceVT, (int)&SciDevice[SCI_HANDLE_1] },
#if defined(BSP_DEVICE_NAME_SCI_2)	
		{ &InterfaceVT, (int)&SciDevice[SCI_HANDLE_2] },
#endif
	};
	
/*****************************************************************************/
/*                         Driver Function prototypes                        */
/*****************************************************************************/

static void sciSetConfig                   (sSciDevice * pSciDevice, sci_sConfig * pSciConfig);

static void sciHWDisableInterrupts         (UWord16 BaseAddress);
static void sciHWEnableRxInterrupts        (UWord16 BaseAddress);
static void sciHWDisableRxInterrupts       (UWord16 BaseAddress);
static void sciHWEnableTxCompleteInterrupt (UWord16 BaseAddress);
static void sciHWEnableTxReadyInterrupt    (UWord16 BaseAddress);
static void sciHWDisableTxInterrupts       (UWord16 BaseAddress);
static void sciHWConfigure                 (UWord16 BaseAddress, sci_sConfig * pSciConfig);
static void sciHWDisableDevice             (UWord16 BaseAddress);
static void sciHWEnableDevice              (UWord16 BaseAddress);
static void sciHWClearRxInterrupts         (UWord16 BaseAddress);
static void sciHWInstallISR                (UWord16 * pISRBaseAddress, 
                                            void (*pISR_TX)(void), void (*pISR_RX)(void));
static UWord16 sciHWReceiveByte            (sSciDevice * pSciDevice);
static void sciHWSendByte                  (sSciDevice * pSciDevice, UWord16 SendWord);
static void sciHWWaitStatusRegister        (UWord16 Mask, UWord16 Address);

static void sciRestoreInterrupts           (sSciDevice * pSciDevice);

static void sciHWReceiver                  (sSciDevice * pSciDevice);
static void sciHWTransmitter               (sSciDevice * pSciDevice);

static void sci0ReceiverISR                (void);
static void sci0TransmitterISR             (void);
static void sci1ReceiverISR                (void);
static void sci1TransmitterISR             (void);
static void sci2ReceiverISR                (void);
static void sci2TransmitterISR             (void);

/*****************************************************************************/
/*                                 API                                       */
/*****************************************************************************/

/*****************************************************************************
*
* Module:         sciOpen
*
* Description:    Open SCI device.
*                 Initialize device context, install SCI isr in O_NONBLOCK
*                 mode.
*
* Returns:        Device handle in success
*                 -1 if device name does not supported
*
* Arguments:      pName - BSP SCI device name
*                 OFlags - open mode (O_NONBLOCK or O_BLOCK for detail see
*                          sci.h file)
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
io_sDriver * sciOpen(const char * pName, int OFlags, ...)
{
   UWord16  BaseAddress;
   sSciDevice * pSciDevice;
   io_sDriver * pDriver;

   va_list    Args;
   sci_sConfig * pSciConfig;
    
   va_start(Args, OFlags);
   pSciConfig = va_arg(Args, void *);
   va_end(Args);


   if (pName == BSP_DEVICE_NAME_SCI_0)
   {
      pSciDevice = &(SciDevice[SCI_HANDLE_0]);
      pDriver    = (io_sDriver *)&scidrvIODevice[SCI_HANDLE_0];            
   }
#if defined(BSP_DEVICE_NAME_SCI_1)
   else if (pName == BSP_DEVICE_NAME_SCI_1)
   {
      pSciDevice = &(SciDevice[SCI_HANDLE_1]);      
      pDriver    = (io_sDriver *)&scidrvIODevice[SCI_HANDLE_1];            
   }
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
 
#if defined(BSP_DEVICE_NAME_SCI_2)
   else if (pName == BSP_DEVICE_NAME_SCI_2)
   {
      pSciDevice = &(SciDevice[SCI_HANDLE_2]);      
      pDriver    = (io_sDriver *)&scidrvIODevice[SCI_HANDLE_2];            
   }
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */ 
  
   else
   {
      return (io_sDriver *) -1;
   }
   
   BaseAddress    = pSciDevice->Base; 

   /* clear device configuration */
/*
   memset(&(pSciDevice->Send), 0x0000, sizeof(sOneDirectionState));
   memset(&(pSciDevice->Receive), 0x0000, sizeof(sOneDirectionState));
*/

   sciSetConfig(pSciDevice, pSciConfig);

   pSciDevice->Config = SCI_CONFIG_INITIALIZE;

#if defined(SCI_NONBLOCK_MODE)
   fifoInit (&(pSciDevice->Send.Fifo), pSciDevice->Send.BufferLength, 0);
   fifoInit (&(pSciDevice->Receive.Fifo), pSciDevice->Receive.BufferLength, 0);

//   pSciDevice->Send.State           = 0;
//   pSciDevice->Send.ReadLength      = 0;
//   pSciDevice->Send.TmpWord         = 0;

//   pSciDevice->Receive.State        = 0;
   pSciDevice->Receive.ReadLength   = 0;
//   pSciDevice->Receive.TmpWord      = 0;

   pSciDevice->pReceiveCallback     = NULL;
   pSciDevice->pSendCallback        = NULL;
   pSciDevice->pErrorCallback       = NULL;
#endif defined(SCI_NONBLOCK_MODE)

   if((UWord16)OFlags & O_NONBLOCK)
   {
#if defined(SCI_NONBLOCK_MODE)
      if ( pSciDevice->DeviceNumber == SCI0_NUMBER )
      {
         sciHWInstallISR ( SCI_ISROFFSET2ADDR( pArchInterrupts, SCI0_ISR_BASE_OFFSET), 
                           sci0TransmitterISR, sci0ReceiverISR);
      }
#if defined(BSP_DEVICE_NAME_SCI_1)
      else if ( pSciDevice->DeviceNumber == SCI1_NUMBER )
      {
         sciHWInstallISR ( SCI_ISROFFSET2ADDR( pArchInterrupts, SCI1_ISR_BASE_OFFSET), 
                           sci1TransmitterISR, sci1ReceiverISR);
      }
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
      else if ( pSciDevice->DeviceNumber == SCI2_NUMBER )
      {
         sciHWInstallISR ( SCI_ISROFFSET2ADDR( pArchInterrupts, SCI2_ISR_BASE_OFFSET), 
                           sci2TransmitterISR, sci2ReceiverISR);
      }
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */


      pSciDevice->Config |= SCI_CONFIG_NONBLOCKING;    
   
      sciHWClearRxInterrupts(BaseAddress);
      sciHWEnableRxInterrupts( BaseAddress );

#else  /* defined(SCI_NONBLOCK_MODE) */

      assert(false); /* O_NONBLOCK mode is not supported in this configuration */

#endif /* defined(SCI_NONBLOCK_MODE) */
   }
   else
   {
#if !defined(SCI_BLOCK_MODE)

      assert(false); /* O_BLOCK mode is not supported in this configuration */

#endif !defined(SCI_BLOCK_MODE)   
   }

   if ( pSciDevice->DeviceNumber == SCI0_NUMBER )
   {
      simControl(SIM_SELECT_SCI);
   }
#if defined(BSP_DEVICE_NAME_SCI_1)
   else if (pSciDevice->DeviceNumber == SCI1_NUMBER)
   {
      simControl(SIM_SELECT_SCI);      
   }
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
   else if (pSciDevice->DeviceNumber == SCI2_NUMBER)
   {
      simControl(SIM_SELECT_SCI);      
   }
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */

   sciHWEnableDevice( BaseAddress );

   return pDriver;
}

/*****************************************************************************
*
* Module:         sciClose()
*
* Description:    Close SCI device. Uninstall ISR vectors, if used.
*
* Returns:        0
*
* Arguments:      FileDesc - device context
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static int sciClose(int FileDesc)
{                                                        
   sciDeviceOff(FileDesc);

#if defined(SCI_NONBLOCK_MODE)
   if ( ((sSciDevice *)FileDesc)->Config & SCI_CONFIG_NONBLOCKING )    
   {
      sciHWInstallISR ( SCI_ISROFFSET2ADDR( pArchInterrupts, ((sSciDevice *)FileDesc)->ISRBaseOffset), 
                        NULL, NULL);
   }
#endif /* defined(SCI_NONBLOCK_MODE) */

   // ((sSciDevice *)pHandle)->Config = 0;

   return 0;
}

/*****************************************************************************
*
* Module:         sciRead()
*
* Description:    Read data from SCI driver into user buffer
*                 For Blocked mode:
*                    Wait in "for" cycle any changes in SCI status register 
*                    Read SCI datum, 
*                    If RAW mode is on wait the second half of word and merge 
*                       hight byte and low byte into one word
*                    Put word in user buffer
*                     
*                 For NonBlocked mode:
*                    Copy data from fifo buffer into user buffer with disabled 
*                    device interrupt. Does not wait if existing data length 
*                    less then requred in Size, just copy all present data and 
*                    exit.
*
* Returns:        Actual read size
*
* Arguments:      pHandle - device context
*                 pBuffer - user buffer
*                 Size    - size to read in words
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
ssize_t sciRead(int FileDesc, void * pBuffer, size_t Size)
{
   sSciDevice   * pHandle         = (sSciDevice *)FileDesc;
   UWord16        ReceivedSize    = Size;
   UWord16        ReceivedNow     = 0;
   UWord16        BaseAddress     = ((sSciDevice *)FileDesc)->Base;


#if defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)
   if ( ((sSciDevice *)pHandle)->Config & SCI_CONFIG_NONBLOCKING )
#endif defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)

#if defined(SCI_NONBLOCK_MODE)
   {                                      /** NonBlocking mode */
      sciHWDisableRxInterrupts(BaseAddress);
         
      ReceivedNow = fifoNum(&(((sSciDevice *)pHandle)->Receive.Fifo));      
   
      if (ReceivedNow >= Size )
      {
         ReceivedNow = Size;
      }

      ReceivedSize = fifoExtract(&(((sSciDevice *)pHandle)->Receive.Fifo), pBuffer, ReceivedNow);
      
      if (fifoNum(&(((sSciDevice *)pHandle)->Receive.Fifo)) < ((sSciDevice *)pHandle)->Receive.ReadLength )
      {
         ((sSciDevice *)pHandle)->Receive.State |= SCI_STATE_INPROGRESS;   
      }

      ((sSciDevice *)pHandle)->Exception = 0;          /* Clear exception status */
                                                       /* In NonBlocking mode exception contain  */ 
                                                       /* driver status befor read operation     */
   
      sciHWEnableRxInterrupts(BaseAddress);
   }
#endif /* defined(SCI_NONBLOCK_MODE) */

#if defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)
   else                                   
#endif defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)

#if defined(SCI_BLOCK_MODE)
   {                                      /** Blocking mode */
                                                      
      ((sSciDevice *)pHandle)->Exception = 0;       /* Clear previos exception status */
                                                    /* In Blocking mode exception contains    */
                                                    /* status of last read operation          */

      for ( ReceivedSize = 0; ReceivedSize < Size; ReceivedSize++)
      {
                                          /* wait while SCI receive comleted */
         sciHWWaitStatusRegister(SCI_SCISR_RDRF | SCI_SCISR_PF | SCI_SCISR_OR | SCI_SCISR_FE, BaseAddress);

         ReceivedNow = sciHWReceiveByte(((sSciDevice *)pHandle));     /* Receive byte, */
                /* clear SCI flags and check driver exceptions and errors */
         
         if ((((sSciDevice *)pHandle)->Receive.State & SCI_STATE_EIGHTBITCHAR) == 0)
         {
            ReceivedNow <<= 8;
                                          /* wait while lo byte receive comleted */ 
            sciHWWaitStatusRegister(SCI_SCISR_RDRF | SCI_SCISR_PF | SCI_SCISR_OR | SCI_SCISR_FE, BaseAddress);
                           
            ReceivedNow |= sciHWReceiveByte(((sSciDevice *)pHandle)) & 0x00ffu;  /* Receive lo byte      */
                                                                                 /* and check exeptions  */
         }

         *((UWord16 *)pBuffer + ReceivedSize) = ReceivedNow;

      }         
   }
#endif /* defined(SCI_BLOCK_MODE) */

   return ReceivedSize;
}

/*****************************************************************************
*
* Module:         sciWrite()
*
* Description:    Transfer data thorough SCI.
*                 Blocking mode:
*                 Send all requesed data within "for" loop. 
*
*                 Non Blocking mode: 
*                 Put data into fifo with disabled device interrupt
*                 If there is no transfer in progress send first byte and 
*                 enable device interrupts
*
* Returns:        Actual send size
*
* Arguments:      pHandle - device context
*                 pBuffer - user data to send 
*                 Size    - user data size
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
ssize_t sciWrite(int FileDesc, const void * pBuffer, size_t Size)
{
   sSciDevice   * pHandle         = (sSciDevice *)FileDesc;
   UWord16        SendWord;
   UWord16        SendSize    = Size;
   UWord16        BaseAddress = ((sSciDevice *)pHandle)->Base;
   

#if defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)
   if ( ((sSciDevice *)pHandle)->Config & SCI_CONFIG_NONBLOCKING )
#endif /* defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE) */

#if defined(SCI_NONBLOCK_MODE)
   {     /* NonBlocking mode */
      if ( SendSize != 0 )
      {
         sciHWDisableTxInterrupts(BaseAddress);

         if (( ((sSciDevice *)pHandle)->Send.State & SCI_STATE_INPROGRESS ) == 0 )
         {                             /* Driver should send first byte */
            SendSize = fifoInsert(&(((sSciDevice *)pHandle)->Send.Fifo), (UWord16 *)pBuffer, SendSize);

            fifoExtract(&(((sSciDevice *)pHandle)->Send.Fifo), &SendWord, 1);
         
            if ((((sSciDevice *)pHandle)->Receive.State & SCI_STATE_EIGHTBITCHAR) == 0 )
            {
               ((sSciDevice *)pHandle)->Send.State |= SCI_STATE_LOWBYTE;

               ((sSciDevice *)pHandle)->Send.TmpWord = SendWord;

               SendWord >>= 8;
            }
                                          /* wait while SCI transmitter become free */
            sciHWWaitStatusRegister(SCI_SCISR_TDRE, BaseAddress);

            sciHWSendByte(((sSciDevice *)pHandle), SendWord );     /* Set hi bit, Send byte, */         

            ((sSciDevice *)pHandle)->Send.State |= SCI_STATE_INPROGRESS;

            if (( ((sSciDevice *)pHandle)->Send.State & SCI_STATE_EIGHTBITCHAR ) && 
                ( fifoNum(&(((sSciDevice *)pHandle)->Send.Fifo)) == 0 ))
            {
               sciHWEnableTxCompleteInterrupt(BaseAddress);
            }
            else
            {
               sciHWEnableTxReadyInterrupt(BaseAddress);               
            }
         }
         else
         {
            SendSize = fifoInsert(&(((sSciDevice *)pHandle)->Send.Fifo), (UWord16 *)pBuffer, SendSize);
            sciHWEnableTxReadyInterrupt(BaseAddress);
         }
      }  /* if (Size != 0) */
   }
#endif /* defined(SCI_NONBLOCK_MODE) */

#if defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE)
   else
#endif /* defined(SCI_NONBLOCK_MODE) && defined(SCI_BLOCK_MODE) */

#if defined(SCI_BLOCK_MODE)
   {  /* Blocking mode */

      for ( SendSize = 0; SendSize < Size; SendSize++)
      {

         SendWord = *((UWord16 *)(pBuffer) + SendSize);

                                          /* wait while SCI transmitter become free */
         sciHWWaitStatusRegister(SCI_SCISR_TDRE, BaseAddress);
         
         if ((((sSciDevice *)pHandle)->Receive.State & SCI_STATE_EIGHTBITCHAR) == 0 )
         {
            sciHWSendByte(((sSciDevice *)pHandle), SendWord >> 8 );     /* Set hi bit, Send hi byte, */
   
                                          /* wait while SCI transmitter become free */
            sciHWWaitStatusRegister(SCI_SCISR_TDRE, BaseAddress);
                        
            SendWord &= 0x00ff;
         }

         sciHWSendByte(((sSciDevice *)pHandle), SendWord );     /* Set hi bit, Send byte, */         
      }  /* for */
                                    /* wait while transfer comleted */ 
      sciHWWaitStatusRegister(SCI_SCISR_TIDLE, BaseAddress);

   }
#endif /* defined(SCI_BLOCK_MODE) */

   return SendSize;
}


/*****************************************************************************
*  Some ioctl calls cancel current SCI driver operations.
*/

/*****************************************************************************
*
* Module:         ioctlSCI_DATAFORMAT_EIGHTBITCHARS()
*
* Description:    Set EIGHTBITCHARS mode for SCI device. Clear read and write 
*                 buffers.
*
* Returns:        0 
*
* Arguments:      pHandle - device context
*                 pParams - not used
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 ioctlSCI_DATAFORMAT_EIGHTBITCHARS(int FileDesc, void * pParams)
{
   sSciDevice   * pHandle         = (sSciDevice *)FileDesc;

#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableInterrupts(((sSciDevice *) pHandle)->Base);
#endif /* defined(SCI_NONBLOCK_MODE) */

   ((sSciDevice *) pHandle)->Send.State     |= SCI_STATE_EIGHTBITCHAR;
   ((sSciDevice *) pHandle)->Receive.State  |= SCI_STATE_EIGHTBITCHAR;

   sciWriteClear(FileDesc);

   sciReadClear(FileDesc);

#if defined(SCI_NONBLOCK_MODE)
   sciRestoreInterrupts(pHandle);
#endif /* defined(SCI_NONBLOCK_MODE) */

   return 0;
}


/*****************************************************************************
*
* Module:         ioctlSCI_DATAFORMAT_RAW()
*
* Description:    Set RAW mode for SCI device. Clear read and write 
*                 buffers.
*
* Returns:        0 
*
* Arguments:      pHandle - device context
*                 pParams - not used
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 ioctlSCI_DATAFORMAT_RAW(int FileDesc, void * pParams)
{
   sSciDevice   * pHandle         = (sSciDevice *)FileDesc;

#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableInterrupts(((sSciDevice *) pHandle)->Base);
#endif /* defined(SCI_NONBLOCK_MODE) */

   ((sSciDevice *) pHandle)->Send.State     &= ~SCI_STATE_EIGHTBITCHAR;
   ((sSciDevice *) pHandle)->Receive.State  &= ~SCI_STATE_EIGHTBITCHAR;         

   sciWriteClear(FileDesc);

   sciReadClear(FileDesc);

#if defined(SCI_NONBLOCK_MODE)
   sciRestoreInterrupts((sSciDevice *) pHandle);
#endif /* defined(SCI_NONBLOCK_MODE) */

   return 0;
}


/*****************************************************************************
*
* Module:         ioctlSCI_DEVICE_RESET()
*
* Description:    Reset SCI device and set new configuration. 
*                 
* Returns:        0
*                 
* Arguments:      pHandle - device context
*                 pParams - not used
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 ioctlSCI_DEVICE_RESET(int FileDesc, void * pParams)
{
   sciDeviceOff(FileDesc);

   sciSetConfig( (sSciDevice *)FileDesc, (sci_sConfig *)pParams);

   sciDeviceOn(FileDesc);

   return 0;
}


/*****************************************************************************
*
* Module:         ioctlSCI_SET_READ_LENGTH()
*
* Description:    Set ReadLength value. After driver receives ReadLength words 
*                 (in RAW mode, in EIGHTBITCHAR bytes) of data the user defined
*                 callback will be called.
*
* Returns:        0
*
* Arguments:      pHandle - device context
*                 pParams - pointer to requested length 
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
UWord16 ioctlSCI_SET_READ_LENGTH(int FileDesc, void * pParams)
{
   sSciDevice   * pHandle         = (sSciDevice *)FileDesc;

   ((sSciDevice *) pHandle)->Receive.ReadLength = ( *(UWord16 *)pParams < 
                                    ((sSciDevice *) pHandle)->Receive.BufferLength) ?
                                     *(UWord16 *)pParams: 
                                     ((sSciDevice *) pHandle)->Receive.BufferLength;
                                 
                                 /* NB: user`s read callback is not called */

   if ( fifoNum(&(((sSciDevice *) pHandle)->Receive.Fifo)) < ((sSciDevice *) pHandle)->Receive.ReadLength )
   {
      ((sSciDevice *) pHandle)->Receive.State  |= SCI_STATE_INPROGRESS;
   }
   else
   {
      ((sSciDevice *) pHandle)->Receive.State  &= ~SCI_STATE_INPROGRESS;
   }
   return 0;
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         ioctlSCI_GET_STATUS()
*
* Description:    Read SCI device status               
*
* Returns:        device status
*
* Arguments:      pHandle - device descriptor
*                 pRarams - not used
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 ioctlSCI_GET_STATUS(int FileDesc, void * pParams)
{
   UWord16 ReturnValue = 0;
   sSciDevice * pHandle         = (sSciDevice *)FileDesc;
   
#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableInterrupts(((sSciDevice *) pHandle)->Base);
#endif /* defined(SCI_NONBLOCK_MODE) */

   if ( ((sSciDevice *) pHandle)->Exception != 0)
   {
      ReturnValue |= SCI_STATUS_EXCEPTION_EXIST;
   }
         
   if (((sSciDevice *) pHandle)->Send.State & SCI_STATE_INPROGRESS)
   {
      ReturnValue |= SCI_STATUS_WRITE_INPROGRESS;            
   }

   if (((sSciDevice *) pHandle)->Receive.State & SCI_STATE_INPROGRESS)
   {
      ReturnValue |= SCI_STATUS_READ_INPROGRESS;            
   }

#if defined(SCI_NONBLOCK_MODE)
   sciRestoreInterrupts((sSciDevice *) pHandle);
#endif /* defined(SCI_NONBLOCK_MODE) */

   return ReturnValue;
}

/*****************************************************************************
*
* Module:         ioctlSCI_GET_EXCEPTION()
*
* Description:    Get the latest error from SCI               
*
* Returns:        SCI Error
*
* Arguments:      pHandle - device context
*                 pParams - not used
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 ioctlSCI_GET_EXCEPTION(int FileDesc, void * pParams)
{
   UWord16 ReturnValue = 0;
   sSciDevice * pHandle         = (sSciDevice *)FileDesc;

#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableInterrupts(((sSciDevice *) pHandle)->Base);
#endif /* defined(SCI_NONBLOCK_MODE) */

   ReturnValue = ((sSciDevice *) pHandle)->Exception;
   ((sSciDevice *) pHandle)->Exception = 0;

#if defined(SCI_NONBLOCK_MODE)
   sciRestoreInterrupts((sSciDevice *) pHandle);
#endif /* defined(SCI_NONBLOCK_MODE) */

   return ReturnValue;
}


/*****************************************************************************
*
* Module:         ioctlSCI_GET_READ_SIZE()
*
* Description:    Get number of items recived via SCI and located in the 
*                 driver buffer               
*
* Returns:        read size
*
* Arguments:      pHandle - device descriptor
*                 pRarams - not used
*
* Range Issues:   None
*
* Special Issues: For executive loop only 
*                 For non blocking mode only
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
UWord16 ioctlSCI_GET_READ_SIZE(int FileDesc, void * pParams)
{
   UWord16 ReturnValue;
   
   sciHWDisableRxInterrupts(((sSciDevice *) FileDesc)->Base);

   ReturnValue = fifoNum(&(((sSciDevice *) FileDesc)->Receive.Fifo));
   
   sciRestoreInterrupts((sSciDevice *) FileDesc);

   return ReturnValue;
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciDevCreate()
*
* Description:    Register SDI driver in i/o subsystem
*                 
* Returns:        0
*
* Arguments:      pSciInitialize - devices configuration
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
UWord16 sciDevCreate(const sSciInitialize * pSciInitialize)
{
//   sciDeviceOff(&(SciDevice[0]));
//   sciDeviceOff(&(SciDevice[1]));
   
   SciDriver.pSciBaudRate = pSciInitialize->pSciBaudRate;

#if defined(SCI_NONBLOCK_MODE) 
   SciDevice[0].Send.BufferLength = pSciInitialize->SendSci0.Length;
   SciDevice[0].Send.Fifo.pCircBuffer = pSciInitialize->SendSci0.pBuffer;

   SciDevice[0].Receive.BufferLength = pSciInitialize->ReceiveSci0.Length;
   SciDevice[0].Receive.Fifo.pCircBuffer = pSciInitialize->ReceiveSci0.pBuffer;

#if defined(BSP_DEVICE_NAME_SCI_1)
   SciDevice[1].Send.BufferLength = pSciInitialize->SendSci1.Length;
   SciDevice[1].Send.Fifo.pCircBuffer = pSciInitialize->SendSci1.pBuffer;

   SciDevice[1].Receive.BufferLength = pSciInitialize->ReceiveSci1.Length;
   SciDevice[1].Receive.Fifo.pCircBuffer = pSciInitialize->ReceiveSci1.pBuffer;
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */

#if defined(BSP_DEVICE_NAME_SCI_2)
   SciDevice[2].Send.BufferLength = pSciInitialize->SendSci2.Length;
   SciDevice[2].Send.Fifo.pCircBuffer = pSciInitialize->SendSci2.pBuffer;

   SciDevice[2].Receive.BufferLength = pSciInitialize->ReceiveSci2.Length;
   SciDevice[2].Receive.Fifo.pCircBuffer = pSciInitialize->ReceiveSci2.pBuffer;
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */
#endif /* defined(SCI_NONBLOCK_MODE)  */

   ioDrvInstall(sciOpen);

   return 0;
}

/*****************************************************************************/
/***                  Internal Functions                                   ***/
/*****************************************************************************/

/*****************************************************************************
*
* Module:         sciSetConfig()
*
* Description:    Set new configuration for SCI device and driver
*
* Returns:        None
*
* Arguments:      pSciDevice - device context
*                 PSciConfig - new configuration
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
void sciSetConfig(sSciDevice * pSciDevice, sci_sConfig * pSciConfig)
{

   assert( !(pSciConfig->BaudRate > SCI_MAX_BAUD_RATE_INDEX)) /* Wrong SCI baud rate index */
   
   sciHWConfigure(pSciDevice->Base, pSciConfig);

   pSciDevice->Exception = 0;

   if ( pSciConfig->SciCntl & SCI_SCICR_M )
   {
      if ( pSciConfig->SciCntl & SCI_SCICR_PE )
      {
         pSciDevice->Mask = SCI_SCIDR_8BIT_MASK;
      }
      else
      {
         pSciDevice->Mask = SCI_SCIDR_9BIT_MASK;      
      }
   }
   else
   {
      if ( pSciConfig->SciCntl & SCI_SCICR_PE )
      {
         pSciDevice->Mask = SCI_SCIDR_7BIT_MASK;
      }
      else
      {
         pSciDevice->Mask = SCI_SCIDR_8BIT_MASK;      
      }
   }
   
   if (pSciConfig->SciHiBit)
   {
      pSciDevice->Send.State     = SCI_STATE_HIBIT;
      pSciDevice->Receive.State  = SCI_STATE_HIBIT;
   }
   else
   {
      pSciDevice->Send.State     = 0;
      pSciDevice->Receive.State  = 0;
   }
}

/*****************************************************************************
*
* Module:         sciReadClear()
*
* Description:    Clear read fifo and read related status for device
*
* Returns:        None
*
* Arguments:      pSciDevice - device descriptor
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
void sciReadClear(int FileDesc)
{
	sSciDevice * pSciDevice = (sSciDevice *)FileDesc;
	UWord16        BaseAddress     = pSciDevice->Base;

#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableRxInterrupts(BaseAddress);

#endif /* defined(SCI_NONBLOCK_MODE) */

   pSciDevice->Receive.State  &= ~( SCI_STATE_LOWBYTE | SCI_STATE_INPROGRESS );

#if defined(SCI_NONBLOCK_MODE)
   fifoClear(&(pSciDevice->Receive.Fifo),0);
#endif /* defined(SCI_NONBLOCK_MODE) */

   sciHWClearRxInterrupts(BaseAddress);

#if defined(SCI_NONBLOCK_MODE)

   if (pSciDevice->Config & SCI_CONFIG_NONBLOCKING)
   {
      if (pSciDevice->Receive.ReadLength != 0 )
      {
         pSciDevice->Receive.State  |= SCI_STATE_INPROGRESS;
      }

      sciHWEnableRxInterrupts(BaseAddress);
   }
#endif /* defined(SCI_NONBLOCK_MODE) */
}

/*****************************************************************************
*
* Module:         sciWriteClear()
*
* Description:    Clear write fifo and write related status for device
*
* Returns:        None
*
* Arguments:      pSciDevice - device descriptor
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
void sciWriteClear(int FileDesc)
{
	sSciDevice * pSciDevice = (sSciDevice *)FileDesc;
	
#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableTxInterrupts(pSciDevice->Base);
#endif /* defined(SCI_NONBLOCK_MODE) */

   pSciDevice->Send.State  &= ~( SCI_STATE_LOWBYTE | SCI_STATE_INPROGRESS );

#if defined(SCI_NONBLOCK_MODE)
   fifoClear(&(pSciDevice->Send.Fifo),0);
#endif /* defined(SCI_NONBLOCK_MODE) */
}

/*****************************************************************************
*
* Module:         sciDeviceOff()
*
* Description:    Switch device off, disable device related interrupts
*
* Returns:        None
*
* Arguments:      pSciDevice - device context
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
void sciDeviceOff(int FileDesc)
{
	sSciDevice * pSciDevice = (sSciDevice *)FileDesc;
   UWord16 BaseAddress = pSciDevice->Base;

#if defined(SCI_NONBLOCK_MODE)
   sciHWDisableInterrupts(BaseAddress);
#endif /* defined(SCI_NONBLOCK_MODE) */

   sciHWClearRxInterrupts(BaseAddress);
   sciHWDisableDevice(BaseAddress);
}
         
/*****************************************************************************
*
* Module:         sciDeviceOn()
*
* Description:    Switch device on, clear read and write buffers, enable 
*                 reciver related interrupts
*
* Returns:        None
*
* Arguments:      pSciDevice - device context
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
void sciDeviceOn(int FileDesc)
{
	sSciDevice * pSciDevice = (sSciDevice *)FileDesc;
   UWord16 BaseAddress = pSciDevice->Base;

   sciHWEnableDevice(BaseAddress);
   sciWriteClear(FileDesc);
   sciReadClear(FileDesc);
   sciHWClearRxInterrupts(BaseAddress);

#if defined(SCI_NONBLOCK_MODE)
   sciRestoreInterrupts(pSciDevice);
#endif /* defined(SCI_NONBLOCK_MODE) */
}

/*****************************************************************************
*
* Module:         sciRestoreInterrupts()
*
* Description:    Enable receiver interrupt for NonBlocking mode.
*                 If there is any data to transfer (SCI_STATE_INPROGRESS bit 
*                 is set) enable transmitter interrupt 
*
* Returns:        None
*
* Arguments:      PsciDevice - device context
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciRestoreInterrupts(sSciDevice * pSciDevice)
{
   UWord16 BaseAddress  = pSciDevice->Base;

   if (pSciDevice->Config & SCI_CONFIG_NONBLOCKING)
   {
      sciHWEnableRxInterrupts(BaseAddress);

      if ( pSciDevice->Send.State & SCI_STATE_INPROGRESS ) /* interrupts mask */
                                                           /* is not save */
      {
         sciHWEnableTxCompleteInterrupt(BaseAddress);
      }
      else
      {
         sciHWEnableTxReadyInterrupt(BaseAddress);            
      }
   }
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************/
/*                           Hardware functions                              */
/*****************************************************************************/

/*****************************************************************************
*
* Module:         sciHWDisableInterrupts()
*
* Description:    Disable all SCI device interrupt
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWDisableInterrupts(UWord16  BaseAddress)
{
   periphBitClear(SCI_SCICR_TEIE | SCI_SCICR_TIIE | SCI_SCICR_RIE | SCI_SCICR_REIE, 
                  SCI_REG(BaseAddress, SCI_SCICR));
}

/*****************************************************************************
*
* Module:         sciHWEnableRxInterrupts()
*
* Description:    Enable Receive Complited and Error interrupts
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWEnableRxInterrupts(UWord16  BaseAddress)
{
   periphBitSet(SCI_SCICR_RIE | SCI_SCICR_REIE, SCI_REG(BaseAddress, SCI_SCICR));
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWDisableRxInterrupts()
*
* Description:    Disable Receive Complited and Error interrupts
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWDisableRxInterrupts(UWord16  BaseAddress)
{
   periphBitClear(SCI_SCICR_RIE | SCI_SCICR_REIE, SCI_REG(BaseAddress, SCI_SCICR));
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWEnableTxCompleteInterrupt()
*
* Description:    Enable Transfer Completed interrupt 
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWEnableTxCompleteInterrupt(UWord16  BaseAddress)
{
   periphBitSet(SCI_SCICR_TIIE, SCI_REG(BaseAddress, SCI_SCICR));
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWEnableTxReadyInterrupt()
*
* Description:    Enable Transmitter Ready interrupt 
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWEnableTxReadyInterrupt(UWord16  BaseAddress)
{
   periphBitSet(SCI_SCICR_TEIE, SCI_REG(BaseAddress, SCI_SCICR));
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWDisableTxInterrupts()
*
* Description:    Disable both Transmitter interrupts
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI registers block
*
* Range Issues:   None
*
* Special Issues: can be implemented as macro
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWDisableTxInterrupts(UWord16  BaseAddress)
{
   periphBitClear(SCI_SCICR_TEIE | SCI_SCICR_TIIE, SCI_REG(BaseAddress, SCI_SCICR));
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWConfigure()
*
* Description:    Set SCI device hardware configuration (Baud rate and control 
*                 register)
*
* Returns:        None
*
* Arguments:      BaseAddress - address of SCI register block
*                 pSciConfig  - device configuration
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWConfigure(UWord16 BaseAddress, sci_sConfig * pSciConfig)
{
   periphMemWrite(SciDriver.pSciBaudRate[pSciConfig->BaudRate], SCI_REG(BaseAddress, SCI_SCIBR));
   periphMemWrite(pSciConfig->SciCntl & SCI_SCICR_USER_MASK, SCI_REG(BaseAddress, SCI_SCICR));
}

/*****************************************************************************
*
* Module:         sciHWDisableDevice()
*
* Description:    Disable SCI transmitter and receiver
*
* Returns:        None
*
* Arguments:      BaseAddress - base address of SCI register block
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWDisableDevice(UWord16 BaseAddress)
{
   periphBitClear(SCI_SCICR_TE | SCI_SCICR_RE, SCI_REG(BaseAddress, SCI_SCICR));
}

/*****************************************************************************
*
* Module:         sciHWEnableDevice()
*
* Description:    Disable SCI transmitter and receiver
*
* Returns:        None
*
* Arguments:      BaseAddress - base address of SCI register block
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWEnableDevice(UWord16 BaseAddress)
{
   periphBitSet(SCI_SCICR_TE | SCI_SCICR_RE, SCI_REG(BaseAddress, SCI_SCICR));
}

/*****************************************************************************
*
* Module:         sciHWClearRxInterrupts()
*
* Description:    Clear all receiver related interrupts
*
* Returns:        None
*
* Arguments:      BaseAddress - base address of SCI register block
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWClearRxInterrupts(UWord16 BaseAddress)
{
   UWord16 TmpWord;
   TmpWord = periphMemRead(SCI_REG(BaseAddress, SCI_SCISR));
   TmpWord = periphMemRead(SCI_REG(BaseAddress, SCI_SCIDR));
   periphMemWrite(0x0000, SCI_REG(BaseAddress, SCI_SCISR));
}

/*****************************************************************************
*
* Module:         sciHWInstallISR()
*
* Description:    Install all SCI interrupts
*
* Returns:        None
*
* Arguments:      pISRBaseAddress - interrupt base address
*                 pISR_TX  - transmitter interrupt
*                 pISR_RX - receiver interrupt
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE)
static void sciHWInstallISR ( UWord16 * pISRBaseAddress, void (*pISR_TX)(void), void (*pISR_RX)(void))
{
   archInstallISR(pISRBaseAddress,     pISR_TX);
   archInstallISR(pISRBaseAddress + 2, pISR_TX);
   archInstallISR(pISRBaseAddress + 4, pISR_RX);
   archInstallISR(pISRBaseAddress + 6, pISR_RX);
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sciHWReceiveByte()
*
* Description:    Read data byte from SCI, clear SCI status and set driver 
*                 status. Detect Break symbol and Address mark.
*
* Returns:        Recived byte in low bits of UWord16
*
* Arguments:      pSciDevice - device context
*
* Range Issues:   None
*
* Special Issues: Set pSciDevice->Exception value.
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static UWord16 sciHWReceiveByte(sSciDevice * pSciDevice)
{
   UWord16 TmpReadWord;
   UWord16 BaseAddress     = pSciDevice->Base;

   /* Clear SCI rx and errror related flags */
   
   pSciDevice->Exception |= periphMemRead(SCI_REG(BaseAddress,SCI_SCISR)) &
                           ( SCI_SCISR_OR | SCI_SCISR_NF | SCI_SCISR_FE | SCI_SCISR_PF );

   TmpReadWord = periphMemRead(SCI_REG(BaseAddress,SCI_SCIDR));

   periphMemWrite(0x0000, SCI_REG(BaseAddress, SCI_SCISR));

   if ((TmpReadWord == 0) && ( pSciDevice->Exception & SCI_SCISR_FE ))      
   {
      pSciDevice->Exception |= SCI_EXCEPTION_BREAK_SYMBOL;  /* Break Symbol detected */
   }

   TmpReadWord &= pSciDevice->Mask;

   if (pSciDevice->Receive.State & SCI_STATE_HIBIT)   /* data bit length must be checked in ioctl */
   {
      if(((TmpReadWord & SCI_SCIDR_MSB) == 0) && (( pSciDevice->Exception & SCI_SCISR_FE ) == 0))
      {
         pSciDevice->Exception |= SCI_EXCEPTION_ADDRESS_MARK;
      }
   }

   return TmpReadWord;
}

/*****************************************************************************
*
* Module:         sciHWSendByte()
*
* Description:    Send byte located in low bits of SendWord via SCI.
*
* Returns:        None
*
* Arguments:      pSciDevice - device context
*                 SendWord - data to send
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWSendByte(sSciDevice * pSciDevice, UWord16 SendWord)
{
   volatile UWord16 TmpSendWord;    /* volatile declaration to prevent CW with L2 optimization */
                                    /* from ignoring memory access to SCI Status Register */
   UWord16 BaseAddress     = pSciDevice->Base;
   

   /* Clear SCI tx related flags */
   
   TmpSendWord = periphMemRead(SCI_REG(BaseAddress,SCI_SCISR));   /* access to Status register must */ 
          /* be performed before write to Data register to clear SCI Transmitter Ready & Idle flags */

   if (( pSciDevice->Send.State & SCI_STATE_EIGHTBITCHAR ) == 0)
   {
      if (pSciDevice->Send.State & SCI_STATE_HIBIT)
      {
         SendWord |= SCI_SCIDR_MSB;
      }
      else
      {
         SendWord &= ~SCI_SCIDR_MSB;      
      }
   }

   SendWord  &= pSciDevice->Mask;                     
            
        /* send byte */
   periphMemWrite(SendWord, SCI_REG(BaseAddress, SCI_SCIDR));            
}

/*****************************************************************************
*
* Module:         sciHWWaitStatusRegister()
*
* Description:    Wait while Mask bits in Address register will be set on.
*
* Returns:        None
*
* Arguments:      Mask - bitmask to test 
*                 Address - register address
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
static void sciHWWaitStatusRegister(UWord16 Mask, UWord16 Address)
{
   while ( periphBitTest ( Mask, SCI_REG( Address, SCI_SCISR )) == 0 )
   {
   }
}

/*****************************************************************************/
/*                                 ISRs                                      */
/*****************************************************************************/
/*****************************************************************************
*
*  NB:
*   - Receiver Full  and Receive Error for one device must have equal 
*     priorites
*   - Transmitter Idle  and Transmit completed for one device must have 
*     equal priorites.
*
*****************************************************************************/


/*****************************************************************************
*
* Module:         sci0ReceiverISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 0 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
static void sci0ReceiverISR(void)
{
   sciHWReceiver(&SciDevice[SCI_HANDLE_0]);
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sci0TransmitterISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 0 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
static void sci0TransmitterISR(void)
{
   sciHWTransmitter(&SciDevice[SCI_HANDLE_0]);
}
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sci1ReceiverISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 0 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
#if defined(BSP_DEVICE_NAME_SCI_1)
static void sci1ReceiverISR(void)
{
   sciHWReceiver(&SciDevice[SCI_HANDLE_1]);
}
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sci1TransmitterISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 0 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
#if defined(BSP_DEVICE_NAME_SCI_1)
static void sci1TransmitterISR(void)
{
   sciHWTransmitter(&SciDevice[SCI_HANDLE_1]);
}
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sci2ReceiverISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 2 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
#if defined(BSP_DEVICE_NAME_SCI_2)
static void sci2ReceiverISR(void)
{
   sciHWReceiver(&SciDevice[SCI_HANDLE_2]);
}
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */
#endif /* defined(SCI_NONBLOCK_MODE) */

/*****************************************************************************
*
* Module:         sci2TransmitterISR()
*
* Description:    ISR to call driver ISR subroutine with SCI 2 device context 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
#if defined(BSP_DEVICE_NAME_SCI_2)
static void sci2TransmitterISR(void)
{
   sciHWTransmitter(&SciDevice[SCI_HANDLE_2]);
}
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */
#endif /* defined(SCI_NONBLOCK_MODE) */


/*****************************************************************************
*
* Module:         sciHWReceiver()
*
* Description:    ISR for SCI receiver, used only in NonBlocked mode
*                 
* Returns:        None
*
* Arguments:      pSciDevice - device descriptor
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
static void sciHWReceiver                (sSciDevice * pSciDevice)
{
   UWord16  ReadWord;

   ReadWord  = sciHWReceiveByte(pSciDevice); /* Receive byte, save exseption and errors */

   if (pSciDevice->Receive.State & SCI_STATE_EIGHTBITCHAR)
   {
      pSciDevice->Receive.TmpWord  = ReadWord;

      if ( fifoInsert(&(pSciDevice->Receive.Fifo), &ReadWord, 1) != 1 )
      {
         pSciDevice->Exception |= SCI_EXCEPTION_BUFFER_OVERFLOW;      
      } 
   }
   else
   {
      if ( pSciDevice->Receive.State & SCI_STATE_LOWBYTE )
      {
         ReadWord  = pSciDevice->Receive.TmpWord | ( ReadWord & 0x00ff ); 

         if ( fifoInsert(&(pSciDevice->Receive.Fifo), &ReadWord, 1) != 1 )
         {
            pSciDevice->Exception |= SCI_EXCEPTION_BUFFER_OVERFLOW;      
         }

         pSciDevice->Receive.State  &= ~SCI_STATE_LOWBYTE;  
      }
      else
      {
         pSciDevice->Receive.TmpWord = ReadWord << 8;          

         pSciDevice->Receive.State |= SCI_STATE_LOWBYTE;        
      }
   }

   /* call users callbacks with disabled interrupts */

   if ((pSciDevice->pErrorCallback != NULL) && (pSciDevice->Exception != 0))
   {
      (* pSciDevice->pErrorCallback )(pSciDevice->Exception);
      pSciDevice->Exception = 0;          /* clear exseption after proccessing */
   }

   if (( pSciDevice->Receive.ReadLength != 0 ) && 
       ( fifoNum(&(pSciDevice->Receive.Fifo)) >= pSciDevice->Receive.ReadLength ))
   {
      pSciDevice->Receive.State &= ~SCI_STATE_INPROGRESS;   /* NB: In exseption INPROGRESS flag still set */
      
      if ( pSciDevice->pReceiveCallback != NULL ) 
      {
         (* pSciDevice->pReceiveCallback)();
      }
   }
}
#endif /* defined(SCI_NONBLOCK_MODE) */


/*****************************************************************************
*
* Module:         sciHWTransmitter()
*
* Description:    ISR for SCI transmitter, used only in NonBlocked mode
*                 
* Returns:        None
*
* Arguments:      pSciDevice - device descriptor
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/
#if defined(SCI_NONBLOCK_MODE) 
static void sciHWTransmitter (sSciDevice * pSciDevice)
{
   UWord16  SendWord;
   UWord16        BaseAddress     = pSciDevice->Base;

   if (( pSciDevice->Send.State & SCI_STATE_EIGHTBITCHAR ) || 
       (( pSciDevice->Send.State & SCI_STATE_LOWBYTE ) == 0 ))
   {
      if ( fifoExtract(&(pSciDevice->Send.Fifo), &SendWord, 1) != 1 )
      {
         sciHWDisableTxInterrupts(BaseAddress);
         
         pSciDevice->Send.State &= ~SCI_STATE_INPROGRESS;

         /* call users callback */
         if ((pSciDevice->pSendCallback != NULL) )
         {
            (* pSciDevice->pSendCallback )();
         }
         return;
      } 
      else
      {
         if (( pSciDevice->Send.State & SCI_STATE_EIGHTBITCHAR ) == 0 )
         {
            pSciDevice->Send.TmpWord = SendWord;

            SendWord >>= 8;

            pSciDevice->Send.State |= SCI_STATE_LOWBYTE;
         }
         
      }
   }
   else
   {
      if ( pSciDevice->Send.State & SCI_STATE_LOWBYTE ) 
      {
         SendWord = pSciDevice->Send.TmpWord & 0x00ffu;

         pSciDevice->Send.State &= ~SCI_STATE_LOWBYTE;
      }
   }
      
   sciHWSendByte(pSciDevice, SendWord);
      
   if ((( pSciDevice->Send.State & SCI_STATE_EIGHTBITCHAR ) ||
        ((( pSciDevice->Send.State & SCI_STATE_EIGHTBITCHAR ) == 0 ) && 
         (( pSciDevice->Send.State & SCI_STATE_LOWBYTE ) == 0 ))) &&
       (fifoNum(&(pSciDevice->Send.Fifo)) == 0 ))
   {
      sciHWDisableTxInterrupts(BaseAddress);
      sciHWEnableTxCompleteInterrupt(BaseAddress);
   }   
}   

#endif /* defined(SCI_NONBLOCK_MODE) */

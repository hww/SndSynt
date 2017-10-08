/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         sci56805.h
*
* Description:       Header file for the DSP56805 SCI device driver.      
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


#ifndef SCIDRV_H
#define SCIDRV_H

#ifndef SDK_LIBRARY
   #include "configdefines.h"

   #ifndef INCLUDE_SCI
      #error INCLUDE_SCI must be defined in appconfig.h to initialize the SCI Library
   #endif

#endif

#include "fifo.h"
#include "periph.h"
#include "sci.h"
#include "types.h"

#define SCI_NONBLOCK_MODE
#define SCI_BLOCK_MODE

#ifdef __cplusplus
extern "C" {
#endif

/*****************************************************************************/
/***               Initializition  data sturcture                          ***/
/*****************************************************************************/

typedef struct {
   UWord16     Length;
   UWord16  *  pBuffer;
} sSciBufferDescription;


typedef struct {
   UWord16 * pSciBaudRate;
   sSciBufferDescription SendSci0;
   sSciBufferDescription ReceiveSci0;
#if defined(BSP_DEVICE_NAME_SCI_1)
   sSciBufferDescription SendSci1;
   sSciBufferDescription ReceiveSci1;
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
#if defined(BSP_DEVICE_NAME_SCI_2)
   sSciBufferDescription SendSci2;
   sSciBufferDescription ReceiveSci2;
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */
} sSciInitialize;


/*****************************************************************************/
/*                         API Function prototypes                           */
/*****************************************************************************/

EXPORT io_sDriver * sciOpen   (const char * pName, int OFlags, ...);   
EXPORT int          sciClose  (int FileDesc);
EXPORT ssize_t      sciRead   (int FileDesc, void * pBuffer, size_t NBytes);
EXPORT ssize_t      sciWrite  (int FileDesc, const void * pBuffer, size_t Size);


/*****************************************************************************
*
* Module:      sciDevCreate()   
*
* Description:    
*     The sciDevCreate() function creates SCI device by registering 
*     it with the ioLib library. Once the driver is registered, the SCI 
*     driver services are available for use by application via ioLib and 
*     POSIX calls. To access installed SCI devices, user must use following
*     names: BSP_DEVICE_NAME_SCI_0, BSP_DEVICE_NAME_SCI_1 BSP_DEVICE_NAME_SCI_2
*
* Returns:        
*     The function will return a value of zero.
*
* Arguments:      pSciInitilaize - pointer to parameters
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    sci.mcp
*
*****************************************************************************/

EXPORT UWord16 sciDevCreate(const sSciInitialize * pSciInitialize);


#define SCI_REG(base, offset)    ((volatile UWord16 *)((base) + (offset)))   

/* SCI register offsets description */

#define SCI_SCIBR             0x0000u
#define SCI_SCICR             0x0001u
#define SCI_SCISR             0x0002u
#define SCI_SCIDR             0x0003u

/* SCI baud rate */
#define SCI_SCIBR_BAUD_MASK   0x1fffu

/* SCICR mode select bits */
#define SCI_SCICR_LOOP        0x8000u
#define SCI_SCICR_SWAI        0x4000u
#define SCI_SCICR_RSRC        0x2000u
#define SCI_SCICR_M           0x1000u
#define SCI_SCICR_WAKE        0x0800u
#define SCI_SCICR_POL         0x0400u
#define SCI_SCICR_PE          0x0200u
#define SCI_SCICR_PT          0x0100u
#define SCI_SCICR_TEIE        0x0080u
#define SCI_SCICR_TIIE        0x0040u
#define SCI_SCICR_RIE         0x0020u
#define SCI_SCICR_REIE        0x0010u
#define SCI_SCICR_TE          0x0008u
#define SCI_SCICR_RE          0x0004u
#define SCI_SCICR_RWU         0x0002u
#define SCI_SCICR_SBK         0x0001u

#define SCI_SCICR_USER_MASK ( SCI_SCICR_LOOP | \
                              SCI_SCICR_SWAI | \
                              SCI_SCICR_RSRC | \
                              SCI_SCICR_M    | \
                              SCI_SCICR_WAKE | \
                              SCI_SCICR_POL  | \
                              SCI_SCICR_PE   | \
                              SCI_SCICR_PT   ) 

/* SCI Status Registers bits */
#define SCI_SCISR_TDRE        0x8000u
#define SCI_SCISR_TIDLE       0x4000u
#define SCI_SCISR_RDRF        0x2000u
#define SCI_SCISR_RIDLE       0x1000u
#define SCI_SCISR_OR          0x0800u
#define SCI_SCISR_NF          0x0400u
#define SCI_SCISR_FE          0x0200u
#define SCI_SCISR_PF          0x0100u
#define SCI_SCISR_RAF         0x0001u

/* SCI Data Register  data mask */
#define SCI_SCIDR_7BIT_MASK   0x007fu
#define SCI_SCIDR_8BIT_MASK   0x00ffu
#define SCI_SCIDR_9BIT_MASK   0x01ffu
#define SCI_SCIDR_MSB         0x0100u

typedef void (*tpSciDataCallback)( void );
typedef void (*tpSciErrorCallback)(UWord16 );

typedef struct
{
#if defined(SCI_NONBLOCK_MODE)
   UWord16              BufferLength;
   fifo_sFifo           Fifo;
   UWord16              ReadLength;
#endif /* defined(SCI_NONBLOCK_MODE) */
   UWord16              State;
   UWord16              TmpWord;
} sOneDirectionState;

#define SCI_MAX_BAUD_RATE_INDEX  16

typedef struct 
{
   UWord16 * pSciBaudRate;
} sSciDriver;

typedef struct
{
   const UWord16        Base;
   const UWord16        ISRBaseOffset;
   const UWord16        DeviceNumber;
   UWord16              Config;
   UWord16              Mask;
   UWord16              Exception;
   tpSciDataCallback    pReceiveCallback;
   tpSciDataCallback    pSendCallback;
   tpSciErrorCallback   pErrorCallback;
   sOneDirectionState   Send;
   sOneDirectionState   Receive;
} sSciDevice;

#define SCI_HANDLE_0             0

#if defined(BSP_DEVICE_NAME_SCI_1)
#define SCI_HANDLE_1             1
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */

#if defined(BSP_DEVICE_NAME_SCI_2)
#define SCI_HANDLE_2             2
#endif /* defined(BSP_DEVICE_NAME_SCI_2) */


#if defined(BSP_DEVICE_NAME_SCI_2)
#define SCI_HANDLE_NUMBER        (SCI_HANDLE_2 + 1)
#endif

#if defined(BSP_DEVICE_NAME_SCI_1) & !defined(BSP_DEVICE_NAME_SCI_2)
#define SCI_HANDLE_NUMBER        (SCI_HANDLE_1 + 1)
#endif

#if !defined(BSP_DEVICE_NAME_SCI_1) & !defined(BSP_DEVICE_NAME_SCI_2)
#define SCI_HANDLE_NUMBER        (SCI_HANDLE_0 + 1)
#endif 

extern sSciDriver SciDriver; 
extern sSciDevice SciDevice[SCI_HANDLE_NUMBER];

extern void sciReadClear                   (int FileDesc);
extern void sciWriteClear                  (int FileDesc);
extern void sciDeviceOff                   (int FileDesc);
extern void sciDeviceOn                    (int FileDesc);

#ifdef __cplusplus
}
#endif

#endif

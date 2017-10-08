/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         sci.h
*
* Description:       API header file for DSP5680x SCI driver
*
* Modules Included:  
*                    
* 
*****************************************************************************/


#ifndef __SCI_H
#define __SCI_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SCI
		#error INCLUDE_SCI must be defined in appconfig.h to initialize the SCI driver
	#endif
#endif


#include "port.h"
#include "io.h"
#include "fcntl.h"

#include "scidrv.h"

/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56805 processor has two SCI module: SCI0 and SCI1. 
*
*  In SDK each SCI module is represented as a separate device so the 
*  application has to use the driver oriented API to work with SCI devices.
* 
*  The SCI driver supports both NonBlocking and Blocking modes.
* 
*  If Blocking is selected, API calls return control to the application when 
*  the required operation is completed. 
*
*  If the application opens a SCI device in NonBlocking mode, 
*  services return control immediately after the start of 
*  the operation. There are two ways to indicate completion of the operation.  
*  SCI driver can call a user defined callback function at the end of operation, 
*  or the application can check the status of the operation via "ioctl" call.
*
*  All SCI Driver API calls are non reentrant. 
*
*  Before using any of the SCI devices, the application must open the 
*  device via "open" call and save the device descriptor. 
*  Use the "/sci0" device name for SCI0 module and 
*  "/sci1" for the SCI1 module. Blocking and NonBlocking mode is indicated in 
*  the second argument of "open" function. This mode cannot be changed via an
*  "ioctl" call. The last argument is a pointer to the configuration structure. 
*  You must fill in all fields in the configuration structure to define SCI mode 
*  and baud rate.
*
*  To send data via SCI, the application should use a "write" call. In 
*  NonBlocking mode, the write callback is called by the driver if the 
*  operation is finished. In Blocking mode, "write" waits while the operation 
*  is completed and then returns.
*
*  To receive data from SCI, the application should use a "read" call. In 
*  NonBlocking mode, "read" returns whatever data has already been received from 
*  the SCI device;  it returns the length of the actual data received and 
*  transferred.  To determine when all the data has actually
*  been read in NonBlocking mode, set the required data length via ioctl 
*  SCI_SET_READ_LENGTH command. And then
*  install the Read callback via ioctl IO_CALLBACK_RX command. When the driver 
*  has received the required amount of data, it calls the user's callback. 
*  In the callback, the application can read data from driver via "read" call. 
*  If any errors are detected while receiving data, the Error callback is called. 
*
*  To change SCI device modes, or to disable or enable the device, use the
*  "ioctl" call.
* 
*  After completing all SCI operations, close the SCI device with a call to 
*  "close".
* 
*  For more references, see this file and io.h file.
*
******************************************************************************/


/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, sci_sConfig * pSciConfig);
*
* Semantics:
*     Open particular SCI device for operations. Argument is the particular SCI 
*     device name. The SCI device is always opened for read and for write.
*     Default mode for open is IO_DATAFORMAT_RAW data format.
*
* Parameters:
*     name     - device name. Use BSP_DEVICE_NAME_SCI_0 for SCI 0 ,
*                                 BSP_DEVICE_NAME_SCI_1 for SCI 1.
*
*     OFlags   - open mode flags. Specify O_RDWR.  Use O_NONBLOCK flags for 
*                          NonBlocking mode.
*
*     pSciConfig - pointer to configuration structure. The structure has the 
*                          following field:
*
*           SciCntl     -  This field determines the SCI working mode. 
*                          For more detail see comments for the SCI_CNTL_* constants 
*                          in this file.
*                          
*           SciHiBit    -  Value for 8th data bit. This field is placed into 8th bit 
*                          of all transferred data words if SCI_CNTL_PARITY_NONE and 
*                          SCI_CNTL_WORD_9BIT set in SciCntl and device mode is 
*                          IO_DATAFORMAT_RAW. If in this configuration is 
*                          IO_DATAFORMAT_EIGHTBITCHARS the 8th bit of data word is used.
*
*           BaudRate    -  index in permitted baud rates table for SCI device. This file 
*                          contains set of SCI_BAUD_* constants to program standard baud 
*                          rates. Actual SCI baud rate value is calculated from PLL_MUL 
*                          on compilation stage. User can define two (SCI_USER_BAUD_RATE_1
*                          and SCI_USER_BAUD_RATE_2) own baud rates in appconfig.c file.
*                          To refer in open call on user defined baud rates SCI_BAUD_USER1
*                          and SCI_BAUD_USER2 indexes must be used.
*                          
* 
* Return Value: 
*     SCI device descriptor if open is successful.
*     -1  if open failed.
*     
* Examples:
*
*  open SCI in 9600 mode :
*
*     int SciFD; 
*     sci_sConfig SciConfig;
*
*     SciConfig.SciCntl    =  SCI_CNTL_LOOP_NO | SCI_CNTL_WORD_8BIT | 
*                             SCI_CNTL_PARITY_NONE | SCI_CNTL_TX_NOT_INVERTED;
*     SciConfig.SciHiBit   =  SCI_HIBIT_1;
*     SciConfig.BaudRate   =  SCI_BAUD_9600;
* 
*     // open SCI 0 in Blocking mode with 8 bit word length without parity
*     // and on 1800 baud rate.  
*     SciFD = open(BSP_DEVICE_NAME_SCI_0, 0, &SciConfig); 
*
*  open SCI with user defined baud rate:
*  
*  - file appconfig.h 
*   
*     #define SCI_USER_BAUD_RATE_1  SCI_GET_SBR(1800u) // define 1800 baud rate 
*                                                      // that calculated based on PLL_MUL
*     #define SCI_USER_BAUD_RATE_2  22u                // define immidate value to place
*                                                      // into SCI Baud Rate register
*
*  - user application :
*
*     int SciFD; 
*     sci_sConfig SciConfig;
*
*     SciConfig.SciCntl    =  SCI_CNTL_LOOP_NO | SCI_CNTL_WORD_8BIT | 
*                             SCI_CNTL_PARITY_NONE | SCI_CNTL_TX_NOT_INVERTED;
*     SciConfig.SciHiBit   =  SCI_HIBIT_1;
*     SciConfig.BaudRate   =  SCI_BAUD_USER1;
* 
*     // open SCI 0 in Blocking mode with 8 bit word length without parity
*     // and on 1800 baud rate.  
*     SciFD = open(BSP_DEVICE_NAME_SCI_0, 0, &SciConfig); 
*     
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*
*     Change SCI device modes. SCI driver supports the following commands:
*
*  SCI_DATAFORMAT_EIGHTBITCHARS     Set data format as 8 bit. No parameter.
*
*  SCI_DATAFORMAT_RAW               Set data format as 16 bit. No parameter.
*
*  SCI_DEVICE_RESET                 Set SCI new configuration and reset device.
*                                   Cancel all nonBlocking operations.
*                                   (Parameter: sci_sConfig * pSciconfig)
*
*
*  SCI_DEVICE_OFF                   Disable receiver and transmitter, disable 
*                                   SCI related interrupts.
*                                   Don`t change internal device state. 
*                                   No parameter.
*
*  SCI_DEVICE_ON                    Enable SCI device. No parameter.
*
*  SCI_CALLBACK_RX                  Install Read completed callback function. 
*                                   (Parameter is void (*sciDataCallback)( void )).  
*                                   If pParams is equal to NULL, no callback is used.
* 
*  SCI_CALLBACK_TX                  Install Transfer completed callback. 
*                                   (Parameter is void (*sciDataCallback)( void )).  
*                                   If pParams is equal to NULL, no callback is used.
*  
*  SCI_CALLBACK_EXCEPTION           Install Error callback. 
*                                   (Parameter is void (*sciErrorCallback)(UWord16 Exception )).  
*                                   If pParams is equal to NULL, no callback is used.  
*                                   See SCI_EXCEPTION_* constant. 
*
*  SCI_SET_READ_LENGTH              Set number of words for Read callback. After 
*                                   this number of words is received, the RX callback is called. 
*                                   Parameter: UWord16 length, 
*                                   0 < length <= SCI_BUFFER_LENGTH 
*
*  SCI_GET_STATUS                   Get device status. No  parameter. 
*                                   Return:   UWord16 Status bit field that indicate 
*                                   read in progress, write in progress, exception occured. 
*                                   See SCI_STATUS_* constant. 
*  SCI_GET_EXCEPTION                Get device exception status. No  parameter. 
*                                   Return:   UWord16 Exception status bit field.
*                                   See SCI_EXCEPTION_* constant. 
*
*  SCI_CMD_SEND_BREAK               Send break symbol via SCI.
*                                   No parameter.
*
*  SCI_CMD_WAIT                     Put SCI device in wait state. 
*                                   SCI Interrupts, transceiver and receiver are 
*                                   not disabled.
*                                   No parameter.
*
*  SCI_CMD_WAKEUP                   Wakeup device from wait mode 
*                                   No parameter.
*
*  SCI_CMD_READ_CLEAR               Clear Read buffer  
*                                   No parameter
*        
*  SCI_CMD_WRITE_CANCEL             Cancel data transmition after Write operation 
*                                   in nonBlocking mode.
*                                   No parameter.
*
*  If pParams is not used, then NULL should be passed into the function.
*
* Parameters:
*     FileDesc    - SCI Device descriptor returned by "open" call.
*     Cmd         - command for driver 
*     pParams     - pointer to the parameter for the command
*
* Return Value: 
*     Zero 
*
* Example:
*
*     extern void ReadCompleted(void); // users callback function
*     UWord16  Length   = 10;
*     
*     // set raw data format. Read and write operations is operated with 
*     // whole words
*     ioctl(SciFD, IO_DATAFORMAT_RAW, NULL); 
*     
*     // set data length to call users` callback function
*     ioctl(SciFD, SCI_SET_READ_LENGTH, &Length); 
*
*     // install read callback
*     ioctl(SciFD, IO_CALLBACK_RX, ReadCompleted); 
*
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Transfer user data via SCI.
* 
*     In Blocking mode, "write" waits while all required data is transferred.
*
*     In NonBlocking mode, "write" starts the transfer operation and returns control 
*     to the application. It does not wait while all data is transferred 
*     via SCI.
*
* Parameters:
*     FileDesc    - SCI Device descriptor returned by "open" call.
*
*     pBuffer     - pointer to user buffer. Buffer is located in X Data memory.
*
*     Size        - number of data words to be transferred via SCI. 
*                   If device works in IO_DATAFORMAT_EIGHTBITCHARS mode the
*                   driver transfers via SCI the least
*                   significant 8-bit byte of each word in the user buffer.
*
*                   In IO_DATAFORMAT_RAW mode, for each word in the user buffer, 
*                   the driver transfers via SCI 2 8-bit bytes of data. 
*                   It transfers the most significant 8-bit byte, followed by
*                   the least significant 8-bit byte of the first word in user buffer.
*                    
*
* Return Value: 
*     - Actual number of transferred words.
*
*****************************************************************************/

/*****************************************************************************
*
* READ
*
*     ssize_t read(int FileDesc, void * pBuffer, size_t Size);
*
* Semantics:
*     Read data from the SCI buffer to the user buffer. 
*
*     In Blocking mode, "read" waits until some data will be avalable.
*
*     In NonBlocking mode, "read" returns the actual data that already have been 
*     received from the SCI device. It does not wait for more data, if Size is 
*     greater than data size already contained in the buffer.
*
* Parameters:
*     FileDesc    - SCI Device descriptor returned by "open" call.
*
*     pBuffer     - pointer to user buffer. Buffer is located in X Data memory.
*
*     Size        - number of data words to be transferred via SCI. 
*                   If device works in IO_DATAFORMAT_EIGHTBITCHARS mode the
*                   driver transfers via SCI the least
*                   significant 8-bit byte of each word in the user buffer.
*
*                   In IO_DATAFORMAT_RAW mode, for each word in the user buffer, 
*                   the driver transfers via SCI 2 8-bit bytes of data. 
*                   It transfers the most significant 8-bit byte, followed by
*                   the least significant 8-bit byte of the first word in user buffer.
*
* Return Value: 
*     - Actual number of received words.
*
*****************************************************************************/

/*****************************************************************************
*
* CLOSE
*
*     int close(int FileDesc);  
*
* Semantics:
*     Close SCI device.
*
* Parameters:
*     FileDesc    - SCI Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif


typedef struct
{
   UWord16  SciCntl;
   UWord16  SciHiBit;      /* Value for 8th bit. This field is used if SCI_CNTL_PARITY_NONE and */
                           /* SCI_CNTL_WORD_8BIT set in SciCntl and device mode is */
                           /* IO_DATAFORMAT_EIGHTBITCHARS */
   UWord16  BaudRate;
} sci_sConfig;              

typedef struct
{
   UWord16    length;
   UWord16  * pSciBuffer;
} sci_sBuffer;              /* description for user defined buffer */

/* constants for sci_sConfig.SciHiBit*/ 

#define SCI_HIBIT_0                  0x0000u  
#define SCI_HIBIT_1                  0x0001u  

/* bit masks for sci_sConfig.SciCntl */ 

#define SCI_CNTL_LOOP_NO               0x0000u  /* no loop mode */
#define SCI_CNTL_LOOP                  0x8000u  /* loop mode with internal TXD feedback to RXD */
#define SCI_CNTL_LOOP_SINGLE_WIRE      0xA000u  /* loop mode with internal TXD feedback to RXD */
    
#define SCI_CNTL_TRANSMITTER_ENABLE    0x0008u  /* Enable transmitter   ??? */
#define SCI_CNTL_RECEIVER_ENABLE       0x0004u  /* Enable receiver      ??? */

#define SCI_CNTL_DISABLE_IN_WAIT       0x4000u  /* Disable SCI in wait mode ??? */
#define SCI_CNTL_ENABLE_IN_WAIT        0x0000u  /* Enable  SCI in wait mode */

#define SCI_CNTL_WAKE_BY_ADDRESS       0x0800u  /* Address mark wakeup */
#define SCI_CNTL_WAKE_BY_IDLE          0x0000u  /* Idle line wakeup */

                                                /* data format modes */
#define SCI_CNTL_WORD_9BIT             0x1000u  
#define SCI_CNTL_WORD_8BIT             0x0000u  
#define SCI_CNTL_PARITY_NONE           0x0000u  
#define SCI_CNTL_PARITY_ODD            0x0300u  
#define SCI_CNTL_PARITY_EVEN           0x0200u  
                                                
#define SCI_CNTL_TX_INVERTED           0x0400u  
#define SCI_CNTL_TX_NOT_INVERTED       0x0000u  


/* SCI baud rate index values */

#define SCI_BAUD_230400          0u
#define SCI_BAUD_115200          1u
#define SCI_BAUD_76800           2u
#define SCI_BAUD_57600           3u         
#define SCI_BAUD_38400           4u
#define SCI_BAUD_28800           5u
#define SCI_BAUD_19200           6u
#define SCI_BAUD_14400           7u
#define SCI_BAUD_9600            8u
#define SCI_BAUD_7200            9u
#define SCI_BAUD_4800           10u
#define SCI_BAUD_2400           11u
#define SCI_BAUD_1200           12u
#define SCI_BAUD_600            13u
#define SCI_BAUD_USER1          14u
#define SCI_BAUD_USER2          15u

/* values for exception status */

#define SCI_EXCEPTION_OVERRUN_ERROR       0x0800u
#define SCI_EXCEPTION_NOISE_ERROR         0x0400u
#define SCI_EXCEPTION_FRAME_ERROR         0x0200u
#define SCI_EXCEPTION_PARITY_ERROR        0x0100u
#define SCI_EXCEPTION_BUFFER_OVERFLOW     0x0008u
#define SCI_EXCEPTION_ADDRESS_MARK        0x0004u
#define SCI_EXCEPTION_BREAK_SYMBOL        0x0002u

#define SCI_STATUS_WRITE_INPROGRESS       0x0010u
#define SCI_STATUS_READ_INPROGRESS        0x0020u
#define SCI_STATUS_EXCEPTION_EXIST        0x0040u

/*  ioctl commands */

#define   SCI_CALLBACK_RX                 1 /* void (*sciDataCallback).  NULL - no callbacks  */
#define   SCI_CALLBACK_TX                 2 /* void (*sciDataCallback)  */
#define   SCI_CALLBACK_EXCEPTION          3 /* void (*sciErrorCallback)(UWord16 error ) */
#define   SCI_DATAFORMAT_EIGHTBITCHARS    4 /* none. Set data format as 8 bit. */
#define   SCI_DATAFORMAT_RAW              5 /* none. Set data format as 16 bit. */
#define   SCI_DEVICE_RESET                6 /* none. Reset device and change device configuration. */
#define   SCI_DEVICE_OFF                  7 /* none. Disable receiver and transmitter, disable SCI related interrupts. */
#define   SCI_DEVICE_ON                   8 /* none. Enable SCI device. */


#define   SCI_SET_READ_LENGTH             9
#define   SCI_GET_STATUS                 10
#define   SCI_GET_EXCEPTION              11
#define   SCI_CMD_SEND_BREAK             12
#define   SCI_CMD_WAIT                   13
#define   SCI_CMD_WAKEUP                 14
#define   SCI_CMD_READ_CLEAR             15
#define   SCI_CMD_WRITE_CANCEL           16
#define   SCI_GET_READ_SIZE              17


UWord16 ioctlSCI_DATAFORMAT_EIGHTBITCHARS(int FileDesc, void * pParams);
UWord16 ioctlSCI_DATAFORMAT_RAW(int FileDesc, void * pParams);
UWord16 ioctlSCI_DEVICE_RESET(int FileDesc, void * pParams);
UWord16 ioctlSCI_SET_READ_LENGTH(int FileDesc, void * pParams);
UWord16 ioctlSCI_GET_STATUS(int FileDesc, void * pParams);
UWord16 ioctlSCI_GET_EXCEPTION(int FileDesc, void * pParams);
UWord16 ioctlSCI_GET_READ_SIZE(int FileDesc, void * pParams);

/*****************************************************************************/
#define ioctlSCI_CALLBACK_RX(pHandle,pParams) \
   (((sSciDevice *) pHandle)->pReceiveCallback = (tpSciDataCallback)pParams)

#define ioctlSCI_CALLBACK_TX(pHandle,pParams) \
   (((sSciDevice *) pHandle)->pSendCallback = (tpSciDataCallback)pParams)

#define ioctlSCI_CALLBACK_EXCEPTION(pHandle,pParams) \
   (((sSciDevice *) pHandle)->pErrorCallback = (tpSciErrorCallback)pParams)

#define ioctlSCI_DEVICE_OFF(pHandle,pParams) \
   sciDeviceOff(pHandle)

#define ioctlSCI_DEVICE_ON(pHandle,pParams)  \
   sciDeviceOn(pHandle)

#define ioctlSCI_CMD_SEND_BREAK(pHandle,pParams)   \
   ( periphBitSet(SCI_SCICR_SBK, SCI_REG(((sSciDevice *) pHandle)->Base, SCI_SCICR)), \
     periphBitClear(SCI_SCICR_SBK, SCI_REG(((sSciDevice *) pHandle)->Base, SCI_SCICR)), 0 )

#define ioctlSCI_CMD_WAIT(pHandle,pParams) \
   ( periphBitSet(SCI_SCICR_RWU, SCI_REG(((sSciDevice *) pHandle)->Base, SCI_SCICR)), 0)

#define ioctlSCI_CMD_WAKEUP(pHandle,pParams) \
   ( periphBitClear(SCI_SCICR_RWU, SCI_REG(((sSciDevice *) pHandle)->Base, SCI_SCICR)), 0)

#define ioctlSCI_CMD_READ_CLEAR(pHandle,pParams) \
   (sciReadClear(pHandle), 0)

#define ioctlSCI_CMD_WRITE_CANCEL(pHandle,pParams) \
   (sciWriteClear(pHandle), 0)

#ifdef __cplusplus
}
#endif

#endif


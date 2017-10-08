/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         flash.h
*
* Description:       API header file for DSP5680x Flash driver
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#ifndef __FLASH_H
#define __FLASH_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_FLASH
		#error INCLUDE_FLASH must be defined in appconfig.h to initialize the FLASH driver
	#endif
#endif


#include "port.h"
#include "bsp.h"
#include "io.h"
#include "fcntl.h"


/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56805 processor has three Flash Memory blocks:
*     4K  words of Data Flash are located in X memory space from 0x1000 - 0x1FFF;
*     32K words of Program Flash are located in P memory space from 0x0004 - 0x7DFF
*     2K  words of Boot Flash are located in P memory from 0x8000 - 0x87FF.
* 
*  In SDK each Flash memory block is represented as separate device so the application 
*  has to use the driver oriented API to work with Flash devices.
* 
*  The NonBlocking mode is not supported by this driver;  only the Blocking mode
*  is supported, so all calls are synchronous.  API calls return control to the 
*  application only when the required operation is fully completed. 
*
*  All Flash Driver API calls are not reentrant. 
*
*  Application can not read or write more then PORT_MAX_VECTOR_LEN (8191) data words 
*  in one API call.
* 
*  The Flash Driver uses an internal start address for "read" and "write" calls. 
*  This address saves the position within the Flash address space for "read" and "write" 
*  operations. The address is incremented by the 'size' value after "read" and "write" 
*  calls. User can change the current address value via "ioctl" call.
*
*  Before using any Flash device, the application has to open device via "open" call 
*  and save the device descriptor. 
*
*  There are two ways to read data from Flash:
*
*  1. Flash is located in standard processor address space, so application
*  can directly read data from flash address range. The following SDK functions 
*  will be useful in such case:
*     memcpy()        - copy data from X memory to X memory;
*     memCopyXtoP()   - copy data from X to P memory;
*     memCopyPtoX()   - copy data from P to X memory;
*     memCopyPtoP()   - copy data from P to P memory.
*
*  2. Application can regard Flash as a device and use "read" call to read data 
*  from Flash. "read" can place data in both X memory and P memory; for details 
*  see "ioctl" call.
*
*  To write data into Flash, the application should use a "write" call.
*  
*  Driver supports verification mode for flash operations. 
*  If verification mode is on "write" compare actually written data from flash 
*  with the user's data buffer. If the data does not compare, the zero value is 
*  returned. The internal address is incremented in any case.
*
*  While verification mode is on, the "read" service does not perform actual data 
*  transfer to the user buffer. It just compares data from flash with data 
*  from the buffer. If data does not compare, the zero value is returned. 
*  Internal address is incremented in any case. If verification succeeds, 
*  then both "read" and "write" return the actual processed data length.
* 
*  To change device modes or to set a new internal address for future operations 
*  "ioctl" call has to be used.
* 
*  After all Flash operations are completed, the Flash device has to be closed via
*  a "close" call.
* 
*  For more reference see this file and io.h file.
*
******************************************************************************/


/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, ...);
*
* Semantics:
*     Open the particular Flash device for operations. Argument pName is the 
*     particular Flash device name. The Flash device is always opened for read
*     and for write.
*
* Parameters:
*     pName    - device name. Use   BSP_DEVICE_NAME_FLASH_X for Data Flash,
*                                   BSP_DEVICE_NAME_FLASH_P for Program Flash,
*                                   BSP_DEVICE_NAME_FLASH_B for Boot Flash.
*     OFlags   - open mode flags. Ignored. 
* 
* Return Value: 
*     Flash device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*
*     int FlashFD; 
* 
*     FlashFD = open(BSP_DEVICE_NAME_FLASH_X, 0, NULL);
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*     Change Flash device modes. Flash driver supports the following commands:
*
*  FLASH_RESET                   Reset internal flash address to initial state.
*                                No parameter.
*  FLASH_SET_VERIFY_ON           Set verification mode on. No parameter.
*  FLASH_SET_VERIFY_OFF          Set verification mode on. No parameter.
*  FLASH_CMD_SEEK                Change internal address. 
*                                (Parameter is UWord16 * pParams)
*                                Address is real offset in 16-bit words from 
*                                the beginning of flash 
*                                address space. If set address to zero value 
*                                the following API call will be referenced to 
*                                the first flash word. 
*  FLASH_SET_USER_X_DATA         Set users data buffer location in X data 
*                                space. No parameter.
*  FLASH_SET_USER_P_DATA         Set users data buffer location in Program 
*                                memory space. No parameter.
*  FLASH_CMD_ERASE_ALL           Erase all data in flash. No parameter.
*
*  If pParams is not used then NULL should be passed into function.
*
* Parameters:
*     FileDesc    - Flash Device descriptor returned by "open" call.
*     Cmd         - command for driver 
*     pParam      - pointer to commands` parameter
*
* Return Value: 
*     Zero 
*
* Example:
*
*     UWord16 Address = 0x0010;
*     
*     // set address in flash
*     ioctl(FlashFD, FLASH_CMD_SEEK, &Address); 
*
*     // set user buffer location to Program memory
*     ioctl(FlashFD, FLASH_SET_USER_P_DATA, NULL); 
*
*     // set Verification mode on 
*     ioctl(FlashFD, FLASH_SET_VERIFY_ON, NULL); 
*
*****************************************************************************/
/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Write user buffer into flash.     
*
* Parameters:
*     FileDesc    - Flash Device descriptor returned by "open" call.
*     pBuffer     - pointer to user buffer. Buffer location in X Data or 
*                   or in P memory is determined via "ioctl" call.
*     Size        - number of words to be written into flash. 
*
* Return Value: 
*     - Actual number of written words.
*     - Zero if verification mode is on and verification failed.
*
*****************************************************************************/

/*****************************************************************************
*
* READ
*
*     ssize_t read(int FileDesc, void * pBuffer, size_t Size);
*
* Semantics:
*     Read data from flash to user buffer or verify data from flash against 
*     users` buffer.
*
* Parameters:
*     FileDesc    - Flash Device descriptor returned by "open" call.
*     pBuffer     - pointer to user buffer. Buffer location in X Data or 
*                   or in Program memory is determined via "ioctl" call.
*     Size        - number of words to be read from flash. 
*
* Return Value: 
*     - Actual number of read or verified words.
*     - Zero if verification mode is on and verification failed.
*
*****************************************************************************/

/*****************************************************************************
*
* CLOSE
*
*     int close(int FileDesc);  
*
* Semantics:
*     Close flash device.
*
* Parameters:
*     FileDesc    - Flash Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

/* ioctl commands */

#define FLASH_RESET                    1
#define FLASH_SET_VERIFY_ON            2
#define FLASH_SET_VERIFY_OFF           3
#define FLASH_CMD_SEEK                 4
#define FLASH_SET_USER_X_DATA          5
#define FLASH_SET_USER_P_DATA          6
#define FLASH_CMD_ERASE_ALL            7


#ifdef __cplusplus
}
#endif


#include "flashdrv.h"
										
#endif

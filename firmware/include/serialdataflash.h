/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   serialdataflash.h
*
* DESCRIPTION: Public header file for the Atmel AT45DB011 SPI Bus Serial
*              DataFlash
*
*******************************************************************************/


#ifndef __SERIALDATAFLASH_H
#define __SERIALDATAFLASH_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SERIAL_DATAFLASH
		#error INCLUDE_SERIAL_DATAFLASH must be defined in appconfig.h to initialize the Serial DataFlash Library
	#endif
#endif

#include "port.h"

#include "io.h"
#include "fcntl.h"
#include "serialdataflashdrv.h"

#ifdef __cplusplus
extern "C" {
#endif


/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56F826EVM board has a Atmel AT45DB011 SPI Serial DataFlash
*  which a user   to write data to and read data from the DataFlash. 
*
*  The Atmel AT45DB011 device is a 2.7-volt only, serial inteface Flash
*  memory suitable for in-system reprogramming.  Its 1,081,344 bit of memory
*  are organized as 512 pages of 264 bytes each. In addition to the main
*  memory, the AT45DB011 also contains one SRAM data buffer of 264 bytes.
*  It is connected to DSP56F826 SPI1 interface in this particularly board.
*  The Atmel AT45DB011 DataFlash has a 0x21000 * 8 bit organization. The
*  DataFlash driver deals with words not with bytes. Word data written from
*  the driver to the DataFlash device is located MSB first.
*
*  The Serial DataFlash peripheral is configured by the following:
*  
*  1)  An "open" call is made to open the Serial DataFlash peripheral. 
*      For details see "open" call.
*
*  2)  An "ioctl" call is made to configure the Serial DataFlash
*      peripheral.  For details see "ioctl" call.
*
*  3)  A "write" call is made to write data to the Serial DataFlash device.
*      For details see "write" call.
* 
*  4)  A "read" call is made to read data from the Serial DataFlash device.
*      For details see "read" call.
*
*  5)  After all port operations are completed, the Serial DataFlash
*      peripheral has to be closed via a "close" call.  For details see
*      "close" call.
*
******************************************************************************/


/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, ...);
*
* Semantics:
*     Open the Serial DataFlash peripheral for operations. Argument pName
*     is the Serial DataFlash device name. The Serial DataFlash device is
*     always opened for read and for write calls.
*
* Parameters:
*     pName    - device name. Use   BSP_DEVICE_NAME_SERIAL_DATAFLASH_0 
*
*     OFlags   - open mode flags.   Ignored. 
* 
* Return Value: 
*     Serial DataFlash device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*     
*     // This example will open the Serial DataFlash device to receive
*     // data and return a file descriptor. 
*  
*     int SerialDataFlash; 
* 	        
*     SerialDataFlash = open(BSP_DEVICE_NAME_SERIAL_DATAFLASH_0, 0);
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*     The Serial DataFlash driver supports the following
*     commands:
*
*  SERIAL_DATAFLASH_DEVICE_RESET   Reset the Serial DataFlash
*
*  SERIAL_DATAFLASH_MODE_VERIFY	   Sets true verification mode to true 
* 
*  SERIAL_DATAFLASH_SEEK 		   Set start address for next operation  
*
*  SERIAL_DATAFLASH_PROTECT		            
*
*  If pParams is not used then NULL should be passed into function.
*
*  Parameters:
*     FileDesc    - Serial DataFlash Device descriptor returned by
*                   the "open" call.
*     Cmd         - Command for driver 
*     pParam      - Used in SERIAL_DATAFLASH_MODE_VERIFY and
*                   SERIAL_DATAFLASH_SEEK.  In SERIAL_DATAFLASH_MODE_VERIFY,
*                   it is a pointer to new start address.  In
*                   SERIAL_DATAFLASH_MODE_VERIFY it is a pointer to a
*                   boolean value.  If it is true, verification mode is on.
*                   If it is false, verification mode is off.
*                   
*
* Return Value: 
*     Zero 
*
* Example:
*       
*
*  // Set start address for next operation  
*     int Address;
*     
*     Address = 0x0000;
*     ioctl(SerialDataFlash, SERIAL_DATAFLASH_SEEK, &Address);
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Write user buffer to Serial DataFlash device.     
*
* Parameters:
*     FileDesc    - Serial DataFlash Device descriptor returned by
*                   the "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be written to Serial DataFlash
*                   device. 
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
*     Read data from Serial DataFlash device to user buffer.
*
* Parameters:
*     FileDesc    - Serial DataFlash Device descriptor returned by
*                   the "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be read from Serial DataFlash
*                   device. 
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
*     Close the Serial DataFlash device.
*
* Parameters:
*     FileDesc - Serial DataFlash Device descriptor returned by
*                "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/

/* Serial DataFlash specific commands for ioctl function */
#define  SERIAL_DATAFLASH_DEVICE_RESET  0x0001
#define  SERIAL_DATAFLASH_MODE_VERIFY   0x0100
#define  SERIAL_DATAFLASH_SEEK          0x0200
#define  SERIAL_DATAFLASH_PROTECT       0x0300

#ifdef __cplusplus
}
#endif

#endif

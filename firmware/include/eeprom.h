/*****************************************************************************
*
* eeprom.h - header file for the EEPROM
*
*****************************************************************************/


#ifndef __EEPROM_H
#define __EEPROM_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_EEPROM
		#error INCLUDE_EEPROM must be defined in appconfig.h to initialize the EEPROM Library
	#endif
#endif

#include "port.h"

#include "io.h"
#include "fcntl.h"
#include "eepromdrv.h"

#ifdef __cplusplus
extern "C" {
#endif


/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56824EVM board has a Microchip 25LC640 SPI EEPROM which a user 
*  to write data to and read data from the EEPROM. 
*
*  The Microchip 25LC640 device is a 64K bit Serial Electrically Erasable PROM
*  [EEPROM]. It is connected to DSP56824 SPI0 interface in this particularly
*  board. 25LC640 EEPROM has a 8192 * 8 bit organization so internal EEPROM
*  address range is from 0x0000 to 0x1fff. EEPROM driver deals with words not
*  with bytes. Word data written from driver to EEPROM device is located MSB first.
*
*  The EEPROM peripheral is configured by the following:
*  
*  1)  An "open" call is made to open the EEPROM peripheral.  For 
*      details see "open" call.
*
*  2)  An "ioctl" call is made to configure the EEPROM peripheral.
*      For details see "ioctl" call.
*
*  3)  A "write" call is made to write data to the EEPROM device.
*      For details see "write" call.
* 
*  4)  A "read" call is made to read data from the EEPROM device.
*      For details see "read" call.
*
*  5)  After all port operations are completed, the EEPROM peripheral
*      has to be closed via a "close" call.  For details see "close" call.
*
******************************************************************************/


/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, ...);
*
* Semantics:
*     Open the EEPROM peripheral for operations. Argument pName is the 
*     EEPROM device name. The EEPROM device is always opened for read
*     and for write calls.
*
* Parameters:
*     pName    - device name. Use   BSP_DEVICE_NAME_EEPROM_0 
*
*     OFlags   - open mode flags.   Ignored. 
* 
* Return Value: 
*     CODEC device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*     
*     // This example will open the EEPROM device to receive data and return
*     //  a file descriptor.   
*     int EEProm; 
* 	        
*     EEProm = open(BSP_DEVICE_NAME_EEPROM_0, 0);
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*     The EEPROM driver supports the following
*     commands:
*
*  EEPROM_DEVICE_RESET     Reset the EEPROM
*
*  EEPROM_MODE_VERIFY	   Sets true verification mode to true 
* 
*  EEPROM_SEEK 		      Set start address for next operation  
*
*  EEPROM_PROTECT		            
*
*  If pParams is not used then NULL should be passed into function.
*
*  Parameters:
*     FileDesc    - EEPROM Device descriptor returned by "open" call.
*     Cmd         - Command for driver 
*     pParam      - Used in EEPROM_MODE_VERIFY and EEPROM_SEEK.  In 
*                   EEPROM_MODE_VERIFY it is a pointer to new start address. 
*                   In EEPROM_MODE_VERIFY it is a pointer to a boolean value. 
*                   If it is true verification mode is on, if it is false
*                   verification is off.
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
*     ioctl(Eeeprom, EEPROM_SEEK,&Address);
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Write user buffer to EEPROM device.     
*
* Parameters:
*     FileDesc    - EEPROM Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be written to EEPROM device. 
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
*     Read data from EEPROM device to user buffer.
*
* Parameters:
*     FileDesc    - EEPROM Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be read from EEPROM device. 
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
*     Close EEPROM device.
*
* Parameters:
*     FileDesc - EEPROM Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/

/* EEPROM specific commands for ioctl function */
#define  EEPROM_DEVICE_RESET  0x0001
#define  EEPROM_MODE_VERIFY	0x0100
#define  EEPROM_SEEK 		   0x0200
#define  EEPROM_PROTECT		   0x0300

#ifdef __cplusplus
}
#endif

#endif

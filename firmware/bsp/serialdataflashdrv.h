/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   serialdataflashdrv.h
*
* DESCRIPTION: header file for the Atmel AT45DB011 SPI Bus Serial DataFlash
*
*******************************************************************************/


#ifndef __SERIALDATAFLASHDRV_H
#define __SERIALDATAFLASHDRV_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SERIAL_DATAFLASH
		#error INCLUDE_SERIAL_DATAFLASH must be defined in appconfig.h to initialize the serial DataFlash Library
	#endif
#endif

#include "port.h"

#include "io.h"
#include "serialdataflash.h"

#ifdef __cplusplus
extern "C" {
#endif


io_sDriver * serialdataflashOpen  (const char * pName, int OFlags, ...);
int          serialdataflashClose (int FileDesc);
ssize_t      serialdataflashRead  (int FileDesc, void * pBuffer, size_t NBytes);
ssize_t      serialdataflashWrite (int FileDesc, const void * pBuffer, size_t Size);
UWord16      serialdataflashIoctl (int FileDesc, UWord16 Cmd, void * pParams, ...);

/* Redefine ioctl calls to map to standard driver */
#define ioctlSERIAL_DATAFLASH_DEVICE_RESET(FD,Cmd) serialdataflashIoctl(FD, SERIAL_DATAFLASH_DEVICE_RESET, Cmd)
#define ioctlSERIAL_DATAFLASH_MODE_VERIFY(FD,Cmd)  serialdataflashIoctl(FD, SERIAL_DATAFLASH_MODE_VERIFY, Cmd)
#define ioctlSERIAL_DATAFLASH_SEEK(FD,Cmd)         serialdataflashIoctl(FD, SERIAL_DATAFLASH_SEEK, Cmd)
#define ioctlSERIAL_DATAFLASH_PROTECT(FD,Cmd)      serialdataflashIoctl(FD, SERIAL_DATAFLASH_PROTECT, Cmd)


/*****************************************************************************
*
* serialdataflashDevCreate
*
* Semantics:
*     The serialdataflashDevCreat() function creates SPI Serial DataFlash
*     Atmel AT45DB011 device by registering it with the ioLib library. 
*     Once the driver is registered, the Serial DataFlash driver services
*     are available for use by application via ioLib and POSIX calls. To
*     access installed Serial DataFlash device, the user must use following
*     name: BSP_DEVICE_NAME_SERIAL_DATAFLASH_0.
*
* Return Value: 
*     Upon successful completion, the function will return a value of zero.
*     Otherwise, a value of -1 will be returned and errno will be set to
*     indicate the error.
*
*****************************************************************************/

EXPORT UWord16 serialdataflashDevCreate(const char * pName, UWord16 OFlags);

#ifdef __cplusplus
}
#endif

#endif

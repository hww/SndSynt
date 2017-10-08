/*****************************************************************************
*
* fileiodrv.h - header file for the Motorola dsp56805 fileio device driver.
*
*****************************************************************************/
#ifndef __FILEIODRV_H
#define __FILEIODRV_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_FILEIO
		#error INCLUDE_FILEIO must be defined in appconfig.h to initialize the FILEIO Library
	#endif
#endif

#include "port.h"
#include "io.h"
#include "sci.h"
#include "fileio.h"
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Redefine ioctl calls to map to standard driver */
#define ioctlFILE_IO_DATAFORMAT_EIGHTBITCHARS(FD,Cmd)  fileioIoctl(FD, FILE_IO_DATAFORMAT_EIGHTBITCHARS, Cmd)
#define ioctlFILE_IO_DATAFORMAT_RAW(FD,Cmd)  fileioIoctl(FD, FILE_IO_DATAFORMAT_RAW, Cmd)
#define ioctlFILE_IO_GET_SIZE(FD,Cmd)  fileioIoctl(FD, FILE_IO_GET_SIZE,(void*)&Cmd)
#define ioctlFILE_IO_LOC(FD,Cmd)  fileioIoctl(FD, FILE_IO_LOC, (void*)&Cmd)


EXPORT io_sDriver * fileioOpen (const char * pName, int OFlags, ...);
EXPORT int          fileioClose(int FileDesc);
EXPORT ssize_t      fileioRead (int FileDesc, void * pBuffer, size_t NBytes);
EXPORT ssize_t      fileioWrite(int FileDesc, const void * pBuffer, size_t Size);
EXPORT UWord16      fileioIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...);

/*****************************************************************************
*
* FILEIODRVDEVCREAT
*
* Semantics:
*     The fileiodrvDevCreat() function creates FILEIO device by registering 
*     it with the ioLib library. Once the driver is registered, the FILEIO 
*     driver services are available for use by application via ioLib and 
*     POSIX calls. To access installed FILEIO devices, user must use following
*     names: "/spi/0" for SPI0 and "/spi/1" for SPI1.
*
* Return Value: 
*     Upon successful completion, the function will return a value of zero.
*     Otherwise, a value of -1 will be returned and errno will be set to
*     indicate the error.
*
*****************************************************************************/
EXPORT UWord16 fileioDevCreat(const char * pName, UWord16 OFlags);

#ifdef __cplusplus
}
#endif

#endif

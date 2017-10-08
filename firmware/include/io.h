/*****************************************************************************
*
* io.h - standard header 
*
*****************************************************************************/


#ifndef __IO_H
#define __IO_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_IO
		#error INCLUDE_IO must be defined in appconfig.h to initialize the IO Library
	#endif
#endif


#include "port.h"
#include "types.h"

#include "stdlib.h"

#ifdef __cplusplus
extern "C" {
#endif


typedef void DEV_HEADER;


typedef struct
{
	UWord16 Size;
	UWord16 Threshold;
} io_sBuffer;

typedef const struct 
{
	int                 (*pClose)(int);
	ssize_t             (*pRead)(int, void *, size_t);
	ssize_t             (*pWrite)(int, const void *, size_t);
	UWord16             (*pIoctl)(int, UWord16, void *, ...);
} io_sInterface;

typedef struct
{
	io_sInterface * pInterface;
	int             FileDesc;
} io_sDriver;

typedef struct{
	io_sDriver * (*pOpen)(const char *, int, ...);
} io_sDevice;

#define IO_NULL_DEVICE_HANDLE ((io_sDevice *) -1)

typedef struct
{
	UWord16       MaxDrivers;
	UWord16       MaxDevices;
	io_sDevice *  pDeviceTable;
} io_sState;

/*****************************************************************************
*
* IOCTL
*
* Implementation Status:
*     IMPLEMENTED
*
* Semantics:
*     The function ioctl() provides for control over opened I/O devices. 
*     The argument FileDesc is a file descriptor that is associated with 
*     the I/O device. Most requests are passed on to the driver for handling.
*
*     The available values for Cmd are defined by the I/O device driver.
*
* Return Value: 
*     Upon successful completion, the value returned will depend on Cmd.
*     Otherwise, a value of -1 will be returned.
*
*****************************************************************************/

/* EXPORT UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams, ...); */

#define ioctl(FD, Cmd, pParams) ioctl##Cmd(((io_sDriver *)(FD))->FileDesc,pParams)

/*****************************************************************************
*
* CLOSE
*
* Implementation Status:
*     IMPLEMENTED
*
* Semantics:
*     The close() function will deallocate the file descriptor indicated 
*     by FileDesc.
*
* Return Value: 
*     Upon successful completion, a value of zero will be returned. Otherwise,
*     a value of -1 will be returned.
*
*****************************************************************************/

/* EXPORT int close(int FileDesc); */

#define close(FD) ((io_sDriver *)(FD))->pInterface->pClose(((io_sDriver *)(FD))->FileDesc)



/*****************************************************************************
*
* WRITE
*
* Implementation Status:
*     IMPLEMENTED
*
* Semantics:
*     The write() function will attempt to write NBytes bytes from the 
*     buffer pointed to by pBuffer to the file associated with the open 
*     file descriptor, FileDesc.
*
*    If O_NONBLOCK is clear, write() will block the calling thread until 
*    all data is written. Upon exit, it will return NBytes.
*
*    If O_NONBLOCK is set, write() will write what it can and return the 
*    number of bytes written. Otherwise, it will return -1.
*
* Return Value: 
*    Upon successful completion, write() will return an integer indicating 
*    the number of bytes actually written. Otherwise, it will return a 
*    value of -1.
*
*****************************************************************************/

/* EXPORT ssize_t write(int FileDesc, const void * pBuffer, size_t NBytes); */

#define write(FD, pBuffer, NBytes) \
	((io_sDriver *)(FD))->pInterface->pWrite(((io_sDriver *)(FD))->FileDesc, pBuffer, NBytes)



/*****************************************************************************
*
* READ
*
* Implementation Status:
*     IMPLEMENTED
*
* Semantics:
*     The read() function will attempt to read NBytes bytes from the file   
*     associated with the open file descriptor, FileDesc, into the buffer 
*     pointed to by pBuffer.
*
*     If NBytes is zero, the read() function will return zero and will have
*     no other results.
*
*     Upon successful completion, the read() function will return the number 
*     of bytes actually read and placed in the buffer.
*
*     When attempting to read a file and no data currently available:
*        (1) If O_NONBLOCK is set, read() will return -1.
*        (2) If O_NONBLACK is clear, read() will block the calling thread 
*            until some data is available.
*        (3) The use of the O_NONBLOCK flag has no effect if there is some 
*            data available.
*
* Return Value: 
*     Upon successful completion, read() will return an integer indicating 
*     the number of bytes actually read. Otherwise, read() will return a 
*     value of -1.
*
*****************************************************************************/

/* EXPORT ssize_t read(int FileDesc, void * pBuffer, size_t NBytes); */

#define read(FD, pBuffer, NBytes) \
		((io_sDriver *)(FD))->pInterface->pRead(((io_sDriver *)(FD))->FileDesc, pBuffer, NBytes)


/*****************************************************************************
*
* ioDrvInstall
*
*****************************************************************************/

EXPORT Result ioDrvInstall(io_sDriver * (*pOpen)(const char *, int, ...));


/*****************************************************************************
*
* ioInitialize
*
*****************************************************************************/

EXPORT void ioInitialize(io_sState *);


#ifdef __cplusplus
}
#endif

#endif

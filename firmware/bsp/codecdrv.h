/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   codecdrv.h
*
* DESCRIPTION: header file for the Crystal CS4218 16-bit Stereo Audio
*              Codec device driver
*
*******************************************************************************/


#ifndef __CODECDRV_H
#define __CODECDRV_H

#include "port.h"
#include "arch.h"

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_CODEC
		#error INCLUDE_CODEC must be defined in appconfig.h to initialize the Codec Library
	#endif
#endif

#include "io.h"
#include "gpio.h"
#include "fifo.h"
#include "codec.h"
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif



/* USED TO DEFINE THE MODE OF THE CODEC */

#define CODEC_MONO                     0
#define CODEC_STEREO                   1

/* THE FOLLOWING LABELS CAN BE USED IN appconfig.h TO CONFIGURE THE CODEC.
   config.h CONTAINS THE DEFAULT SETTINGS FOR THE CODEC. */
   
#define CODEC_INTERRUPT_MASKED         0x0000
#define CODEC_INTERRUPT_UNMASKED       0x0800

#define CODEC_DIGITAL_OUTPUT_1_LOW     0x0000
#define CODEC_DIGITAL_OUTPUT_1_HIGH    0x0400

#define CODEC_MUTE_DISABLED            0x0000
#define CODEC_MUTE_ENABLED             0x0400

#define CODEC_LEFT_INPUT_LINE_1        0x0000
#define CODEC_LEFT_INPUT_LINE_2        0x0200

#define CODEC_RIGHT_INPUT_LINE_1       0x0000
#define CODEC_RIGHT_INPUT_LINE_2       0x0100



typedef struct
{
    io_sBuffer   Buffer;
    UWord16    * pOptimizationRxBuffer;
    UWord16    * pOptimizationTxBuffer;
    UWord16      OptimizationBufferSize;
    UWord16      Mode;                      /* CODEC_MONO or CODEC_STEREO */
    UWord16      RxConfig;
    UWord16      TxConfig;
} codec_sParams;



EXPORT io_sDriver * codecOpen(const char * pName, int OFlags, ...);
EXPORT int          codecClose(int FileDesc);
EXPORT ssize_t      codecRead(int FileDesce, void * pBuffer, size_t NBytes);
EXPORT ssize_t      codecWrite(int FileDesc, const void * pBuffer, size_t Size);

EXPORT UWord16      codecIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...);


/* Redefine ioctl calls to map to standard driver */
#define ioctlCODEC_DEVICE_RESET(FD,Cmd)   codecIoctl(FD, CODEC_DEVICE_RESET, Cmd)
#define ioctlCODEC_CONFIG(FD,Cmd)         codecIoctl(FD, CODEC_CONFIG, Cmd)


/*****************************************************************************
*
* CODECDEVCREATE
*
* Semantics:
*     The codecdrvDevCreate() function creates Codec device by registering 
*     it with the ioLib library. Once the driver is registered, the Codec 
*     driver services are available for use by application via ioLib and 
*     POSIX calls. To access the installed Codec device, user must use following
*     name: BSP_DEVICE_NAME_CODEC_CS4218.
*
* Return Value: 
*     Upon successful completion, the function will return a value of zero.
*     Otherwise, a value of -1 will be returned and errno will be set to
*     indicate the error.
*
*****************************************************************************/

EXPORT UWord16 codecDevCreate(const char * pName, codec_sParams * pParams);

EXPORT UWord16 simple_ssiInitialize(arch_sSSI * pInitialState);



#ifdef __cplusplus
}
#endif

#endif

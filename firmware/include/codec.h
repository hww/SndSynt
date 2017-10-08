/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   codec.h
*
* DESCRIPTION: header file for the Crystal CS4218 16-bit Stereo Audio
*              Codec device driver
*
*******************************************************************************/

#ifndef __CODEC_H
#define __CODEC_H

#include "port.h"
#include "io.h"
#include "fcntl.h"
#include "gpio.h"



#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56826EVM board has a Crystal CS4218 Codec peripheral which allows
*  a user to read stereo samples from and write stereo samples out of the device. 
*
*  The CODEC device is configured by the following:
*  
*  1)  An "open" call is made to open the CODEC peripheral.  For 
*      details see "open" call.
*
*  2)  An "ioctl" call is made to reset the CODEC peripheral.
*      For details see "ioctl" call.
*
*  3)  A "write" call is made to write data out of the CODEC device.
*      For details see "write" call.
* 
*  4)  A "read" call is made to read data from the CODEC device.
*      For details see "read" call.
*
*  5)  After all port operations are completed, the CODEC peripheral
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
*     Open the CODEC peripheral for operations. Argument pName is the 
*     CODEC device name. The CODEC device is always opened for read
*     and for write calls.
*
* Parameters:
*     pName    - device name. Use   BSP_DEVICE_NAME_CODEC_RX_CS4218 for RX,
*                                   BSP_DEVICE_NAME_CODEC_TX_CS4218 for TX.
*     OFlags   - open mode flags.   O_RDWR - ignored
*                                   O_WRONLY - ignored
*                                   O_NONBLOCK - non-blocking mode
*     CodecParams - configuration information
* 
* Return Value: 
*     CODEC device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*     
*     // This example will open the CODEC device to receive data and return
*     //  a file descriptor.   
*     UWord16 CodecRx;
*     UWord16 CodecTx; 
*     codec_sParams CodecParams;
*     CodecParams.mode = CODEC_MONO;
*	  CodecParams.Buffer.Size      = 32;
*	  CodecParams.Buffer.Threshold = 15;
* 	        
*     CodecRx = open(BSP_DEVICE_NAME_CODEC_RX_CS4218, O_RDWR | O_NONBLOCK, &CodecParams);
* 	  CodecTx = open(BSP_DEVICE_NAME_CODEC_TX_CS4218, O_WRONLY | O_NONBLOCK, &CodecParams);
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*     The CODEC driver supports the following commands:
*
*  CODEC_DEVICE_RESET           Resets the Codec device
*  CODEC_CONFIG                 Configures the Codec device
*
*  If pParams is not used then NULL should be passed into function.
*
*  Parameters:
*     FileDesc    - CODEC Device descriptor returned by "open" call.
*     Cmd         - Command for driver 
*     pParam      - ignored (CODEC_DEVICE_RESET)
*                 - contains configuration data (CODEC_CONFIG)
*
* Return Value: 
*     Zero 
*
* Example:
*
*     // Reset CODEC
*     ioctl(CodecFd, CODEC_DEVICE_RESET, NULL); 
*
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Write user buffer out of CODEC device.     
*
* Parameters:
*     FileDesc    - CODEC Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be written out of CODEC device. 
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
*     Read data from CODEC device to user buffer.
*
* Parameters:
*     FileDesc    - CODEC Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be read from CODEC device. 
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
*     Close CODEC device.
*
* Parameters:
*     FileDesc - CODEC Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/


#define CODEC_DEVICE_OFF               0
#define CODEC_DEVICE_ON                1
#define CODEC_DEVICE_TOGGLE            2
#define CODEC_DEVICE_RESET             3
#define CODEC_CALLBACK_RX              4
#define CODEC_CALLBACK_TX              5
#define CODEC_CALLBACK_EXCEPTION       6
#define CODEC_DATAFORMAT_EIGHTBITCHARS 7
#define CODEC_DATAFORMAT_RAW           8
#define CODEC_CONFIG                   9

/*****************************************************************************
*
* »ÌÚÂÙÂÈÒ  Œƒ≈ ¿ PCM 1717E 
*
*****************************************************************************/

/* REGISTRES OF PCM PCM1717 */

#define CODEC_REG(n) (n<<9)

/* REGISTERS ATTENUATION OF PCM1717 */

#define CODEC_ATTENUATION_MAX 255
#define CODEC_ATTENUATION_MIN 0
#define CODEC_ENA_ATT 256
#define CODEC_ATTEN_LEFT(v) (CODEC_REG(0) | (v & CODEC_ATTENUATION_MAX) | CODEC_ENA_ATT)
#define CODEC_ATTEN_RIGHT(v) (CODEC_REG(1) | (v & CODEC_ATTENUATION_MAX) | CODEC_ENA_ATT)

/* REGISTER 2 OF PCM1717 */

#define CODEC_MUTE 1
#define CODEC_DM_DIS 0<<1
#define CODEC_DM_480 1<<1
#define CODEC_DM_441 2<<1
#define CODEC_DM_320 3<<1
#define CODEC_OPE_OFF 1<<3  
#define CODEC_IZD 1<<4
#define CODEC_REG2_INI (CODEC_REG(2) | CODEC_DM_320 /* | CODEC_IZD */ )

/* REGISTER 3 OF PCM1717 */

#define CODEC_I2S 1
#define CODEC_LRC_IS_RIGHT 1<<1
#define CODEC_IW_16 0<<2
#define CODEC_IW_18 1<<2
#define CODEC_ATC_MONO 1<<3
#define CODEC_PL_MUTE 0<<4
#define CODEC_PL_STEREO 9<<4
#define CODEC_PL_REVERSE 6<<4
#define CODEC_PL_MONO 15<<4
#define CODEC_REG3_INI (CODEC_REG(3) | CODEC_IW_16 | CODEC_PL_STEREO | CODEC_LRC_IS_RIGHT)

#ifdef __cplusplus
}
#endif


#include "codecdrv.h"

#endif

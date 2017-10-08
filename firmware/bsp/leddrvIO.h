/*****************************************************************************
*
* leddrvIO.h - header file for IO Layer interface to LED driver
*
*****************************************************************************/


#ifndef __LEDDRVIO_H
#define __LEDDRVIO_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_LED
		#error INCLUDE_IO_LED must be defined in appconfig.h to initialize the IO Library for the LED Driver
	#endif
#endif


#include "port.h"
#include "io.h"
#include "gpio.h"
#include "bsp.h"

#ifdef __cplusplus
extern "C" {
#endif


/* define the ioctl calls */

#define ioctlLED_ON(FD,PortPin) \
	ledIoctl(FD, LED_ON, PortPin, BSP_DEVICE_NAME_LED_0)
	
#define ioctlLED_OFF(FD,PortPin) \
	ledIoctl(FD, LED_OFF, PortPin, BSP_DEVICE_NAME_LED_0)

#define ioctlLED_TOGGLE(FD,PortPin) \
	ledIoctl(FD, LED_TOGGLE, PortPin, BSP_DEVICE_NAME_LED_0)


/*
	Define leddrv IO Layer functions
*/
EXPORT io_sDriver * leddrvIOOpen  (const char * pName, int OFlags, ...);
EXPORT int          leddrvIOClose (int FileDesc);
/* EXPORT Result leddrvIOCreate(const char * pName) */
#define leddrvIOCreate(name) ledCreate(name)


#ifdef __cplusplus
}
#endif

#endif

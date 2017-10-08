/*****************************************************************************
*
* leddrv.h - header file for LEDs
*
*****************************************************************************/


#ifndef __LEDDRV_H
#define __LEDDRV_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_LED
		#error INCLUDE_LED must be defined in appconfig.h to initialize the LED Library
	#endif
#endif


#include "port.h"
#include "gpio.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Define the specific LED supported by this driver */
#define LED_RED     gpioPin(B,0)
#define LED_YELLOW  gpioPin(B,1)
#define LED_GREEN   gpioPin(B,2)
#define LED_RED2    gpioPin(B,3)
#define LED_YELLOW2 gpioPin(B,4)
#define LED_GREEN2  gpioPin(B,5)

/* define the ioctl calls */

#define ledIoctl(FD,Cmd,PortPin,ledDevice) ledIoctl##Cmd(FD, PortPin)


#define ledIoctlLED_ON(FD, PortPin) \
					gpioIoctl(FD, GPIO_SET, PortPin, BSP_DEVICE_NAME_GPIO_B)

#define ledIoctlLED_OFF(FD, PortPin) \
					gpioIoctl(FD, GPIO_CLEAR, PortPin, BSP_DEVICE_NAME_GPIO_B)

#define ledIoctlLED_TOGGLE(FD, PortPin) \
					gpioIoctl(FD, GPIO_TOGGLE, PortPin, BSP_DEVICE_NAME_GPIO_B)



/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT int ledOpen(const char * pName, int OFlags);
#define ledClose(FD) (0)
/* EXPORT Result ledCreate(const char * pName) */
#define ledCreate(name) (PASS)


#ifdef __cplusplus
}
#endif

#endif

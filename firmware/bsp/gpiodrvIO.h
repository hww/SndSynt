/*****************************************************************************
*
* giopdrvIO.h - header file for IO Layer interface to the GPIO Driver
*
* Multiply bits access is available for the current implementation of
* the GPIO driver. The "Mask" parameter for several bits can be defined 
* with or operation. For example:
*
* #define LEDs	(GPIOPORT_B_BIT0|GPIOPORT_B_BIT1|GPIOPORT_B_BIT2)
* 
* After that this mask is available as macro parameter. For example:
*
* ioctl( portB,	GPIO_SETAS_GPIO, LEDs );
* 
* Note 1: "Mask" parameter of ioctl macros must be GPIO pin defines 
* (or combination of pin defines) that are described in gpiodrv.h 
*
* Note 2: All pins in the one group must be from the same port.
* 
*****************************************************************************/
#ifndef GIOPDRVIO_H
#define GIOPDRVIO_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_GPIO
		#error INCLUDE_IO_GPIO must be defined in appconfig.h to initialize the IO Layer for the GPIO Driver
	#endif
#endif

#include "port.h"
#include "periph.h"
#include "io.h"
#include "gpio.h"
#include "gpiodrv.h"

#ifdef __cplusplus
extern "C" {
#endif


#define ioctlGPIO_SET(fd, Mask) \
			gpioIoctl(fd, GPIO_SET, Mask, (Mask >> 4))

#define ioctlGPIO_CLEAR(fd, Mask) \
			gpioIoctl(fd, GPIO_CLEAR, Mask, (Mask >> 4))

#define ioctlGPIO_TOGGLE(fd, Mask) \
			gpioIoctl(fd, GPIO_TOGGLE, Mask, (Mask >> 4))

#define ioctlGPIO_DISABLE_PULLUP(fd, Mask) \
			gpioIoctl(fd, GPIO_DISABLE_PULLUP, Mask, (Mask >> 4))

#define ioctlGPIO_ENABLE_PULLUP(fd, Mask) \
			gpioIoctl(fd, GPIO_ENABLE_PULLUP, Mask, (Mask >> 4))

#define ioctlGPIO_SETAS_INPUT(fd, Mask) \
			gpioIoctl(fd, GPIO_SETAS_INPUT, Mask, (Mask >> 4))
								
#define ioctlGPIO_SETAS_OUTPUT(fd, Mask) \
			gpioIoctl(fd, GPIO_SETAS_OUTPUT, Mask, (Mask >> 4))

#define ioctlGPIO_SETAS_GPIO(fd, Mask) \
			gpioIoctl(fd, GPIO_SETAS_GPIO, Mask, (Mask >> 4))
	
#define ioctlGPIO_SETAS_PERIPHERAL(fd, Mask) \
			gpioIoctl(fd, GPIO_SETAS_PERIPHERAL, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_ASSERT_DISABLE(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_ASSERT_DISABLE, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_ASSERT_ENABLE(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_ASSERT_ENABLE, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_DISABLE(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_DISABLE, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_ENABLE(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_ENABLE, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_DETECTION_ACTIVE_HIGH(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_DETECTION_ACTIVE_HIGH, Mask, (Mask >> 4))

#define ioctlGPIO_INTERRUPT_DETECTION_ACTIVE_LOW(fd, Mask) \
			gpioIoctl(fd, GPIO_INTERRUPT_DETECTION_ACTIVE_LOW, Mask, (Mask >> 4))

#define ioctlGPIO_CLEAR_INTERRUPT_PEND_REGISTER(fd, Mask) \
			gpioIoctl(fd, GPIO_CLEAR_INTERRUPT_PEND_REGISTER, Mask, (Mask >> 4))

#define ioctlGPIO_READ(fd, Mask) \
			gpioIoctl(fd, GPIO_READ, Mask, (Mask >> 4))


/*
	Define gpiodrv IO Layer functions
*/
EXPORT io_sDriver * gpiodrvIOOpen  (const char * pName, int OFlags, ...);
EXPORT int          gpiodrvIOClose (int FileDesc);
/* EXPORT Result gpiodrvIOCreate(const char * pName) */
#define gpiodrvIOCreate(name) gpioCreate(name)

#ifdef __cplusplus
}
#endif

#endif

/*****************************************************************************
*
* leddrv.c - LED driver
*
*****************************************************************************/

#include "port.h"
#include "arch.h"

#include "bit.h"
#include "periph.h"

#include "bsp.h"
#include "led.h"
#include "gpio.h"
#include "const.h"



/*****************************************************************************/
int ledOpen(const char * pName, int OFlags)
{
    if( pName != BSP_DEVICE_NAME_LED_0 )
    {
        return (-1); /* not my device */
    }

	/* 
		Here we take advantage of our internal knowledge of the GPIO driver
		and skip the gpioOpen and gpioClose
	*/
#ifdef DYNAMIC

#else //dynamic
#ifdef LED_RED
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 0), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 0), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 0), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif

#ifdef LED_YELLOW		 
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 1), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 1), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 1), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif

#ifdef LED_GREEN		 
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 2), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 2), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 2), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif

#ifdef LED_RED2
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 3), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 3), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 3), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif

#ifdef LED_YELLOW2		 
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 4), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 4), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 4), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif

#ifdef LED_GREEN2		 
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,  gpioPin(B, 5), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT,gpioPin(B, 5), 
																		BSP_DEVICE_NAME_GPIO_B);
	gpioIoctl ((int)BSP_DEVICE_NAME_GPIO_B, GPIO_CLEAR,       gpioPin(B, 5), 
																		BSP_DEVICE_NAME_GPIO_B);
#endif
#endif //dynamic	
	return (0);
}

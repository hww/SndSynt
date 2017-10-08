/* File: bsp.h */

#ifndef __BSP_H
#define __BSP_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_BSP
		#error INCLUDE_BSP must be defined in appconfig.h to initialize the BSP Library
	#endif
#endif


#include "port.h"
#include "arch.h"

#include "plldrv.h"
#include "coredrv.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Supported board type. */
#define DSP56826EVM


/* Devices available, with name shortcuts for driver 'open' call */

#define BSP_DEVICE_NAME_FLASH_X           ((const char *)1)    /* FLASH/X */
#define BSP_DEVICE_NAME_FLASH_P           ((const char *)2)    /* FLASH/P */
#define BSP_DEVICE_NAME_FLASH_B           ((const char *)3)    /* FLASH/B */
#define BSP_DEVICE_NAME_GPIO_A            ((const char *)0x11A0)    /* GPIO/A */
#define BSP_DEVICE_NAME_GPIO_B            ((const char *)0x11B0)    /* GPIO/B */
#define BSP_DEVICE_NAME_GPIO_C            ((const char *)0x11C0)    /* GPIO/C */
#define BSP_DEVICE_NAME_GPIO_D            ((const char *)0x11D0)    /* GPIO/D */
#define BSP_DEVICE_NAME_GPIO_E            ((const char *)0x11E0)    /* GPIO/E */
#define BSP_DEVICE_NAME_GPIO_F            ((const char *)0x11F0)    /* GPIO/F */
#define BSP_DEVICE_NAME_LED_0             ((const char *)10)   /* LED/0 */
#define BSP_DEVICE_NAME_CODEC_0           ((const char *)11)   /*CS4218 Codec*/
#define BSP_DEVICE_NAME_SERIAL_DATAFLASH_0 ((const char *)12)   /* serial DataFlash/0 */
#define BSP_DEVICE_NAME_QUAD_TIMER_A_0    ((const char *)0x10A0)   /* QTA/0 */
#define BSP_DEVICE_NAME_QUAD_TIMER_A_1    ((const char *)0x10A8)   /* QTA/1 */
#define BSP_DEVICE_NAME_QUAD_TIMER_A_2    ((const char *)0x10B0)   /* QTA/2 */
#define BSP_DEVICE_NAME_QUAD_TIMER_A_3    ((const char *)0x10B8)   /* QTA/3 */
#define BSP_DEVICE_NAME_SERIAL_0          ((const char *)29)   /* SCI/0 */
#define BSP_DEVICE_NAME_SCI_0             BSP_DEVICE_NAME_SERIAL_0   /* SCI/0 */
#define BSP_DEVICE_NAME_SERIAL_1          ((const char *)30)   /* SCI/1 */
#define BSP_DEVICE_NAME_SCI_1             BSP_DEVICE_NAME_SERIAL_1   /* SCI/1 */
#define BSP_DEVICE_NAME_SPI_0             ((const char *)31)   /* SPI/0 */
#define BSP_DEVICE_NAME_SPI_1             ((const char *)32)   /* SPI/1 */
#define BSP_DEVICE_TIME_OF_DAY            ((const char *)33)   /* TIME OF DAY */
#define BSP_DEVICE_NAME_BUTTON_A          ((const char *)39)   /* BUTTON/A */
#define BSP_DEVICE_NAME_BUTTON_B          ((const char *)40)   /* BUTTON/B */
#define BSP_DEVICE_NAME_SSI               ((const char *)0x10E0)     /* SSI */




#ifdef __cplusplus
}
#endif

#endif

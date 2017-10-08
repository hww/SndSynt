#ifndef __APPCONFIG_H
#define __APPCONFIG_H

/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP           /* BSP support */

#undef  INCLUDE_CODEC         /* codec driver */
#define  INCLUDE_IO            /* I/O support */
#define  INCLUDE_LED           /* led support for target board */
#undef  INCLUDE_SPI           /* spi support */
#undef  INCLUDE_TIMER         /* timer support */
#undef  INCLUDE_FLASH         /* flash support */
#undef  INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_ADC           /* ADC support */
#define  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_CAN           /* CAN support */

#undef  INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

#define INCLUDE_USER_TIMER_A_0  0
#define INCLUDE_USER_TIMER_A_1  0
#define INCLUDE_USER_TIMER_A_2  0

/*****************************************************************************
*
* Overwrite default component initialization from config/config.h
*
*****************************************************************************/


#endif
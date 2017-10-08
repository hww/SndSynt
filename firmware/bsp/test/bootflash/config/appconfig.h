/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP           /* BSP support */

#undef  INCLUDE_CODEC         /* codec driver */
#define INCLUDE_IO            /* I/O support */
#undef  INCLUDE_LED           /* led support for target board */
#undef  INCLUDE_SPI           /* spi support */
#undef  INCLUDE_TIMER         /* timer support */
#define INCLUDE_FLASH         /* flash support */
#undef  INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_ADC           /* ADC support */
#undef  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_CAN           /* CAN support */

#define  INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

#undef  INCLUDE_STACK_CHECK   /* stack utilization routines */

/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/

#define SIM_BOOT_MODE   SIM_BOOT_MODE_A

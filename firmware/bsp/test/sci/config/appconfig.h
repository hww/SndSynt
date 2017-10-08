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
#undef  INCLUDE_FLASH         /* flash support */
#define INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_ADC           /* ADC support */
#undef  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_CAN           /* CAN support */

#define INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/

#define BUS_CONTROL_EXT_X_MEM_WAIT_STATES 0
#define BUS_CONTROL_EXT_P_MEM_WAIT_STATES 0

/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP           /* BSP support */

#undef  INCLUDE_CODEC         /* codec driver */
#undef  INCLUDE_IO            /* I/O support */
#undef  INCLUDE_LED           /* led support for target board */
#undef  INCLUDE_SERIAL        /* serial support */
#undef  INCLUDE_SPI           /* spi support */
#undef  INCLUDE_TIMER         /* timer support */

#define  INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/

/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP           /* BSP support */

#define INCLUDE_CODEC         /* codec driver */
#define INCLUDE_IO            /* I/O support */
#undef  INCLUDE_LED           /* led support for target board */
#undef  INCLUDE_SERIAL        /* serial support */
#undef  INCLUDE_SPI           /* spi support */
#undef  INCLUDE_EEPROM        /* eeprom support */
#undef  INCLUDE_TIMER         /* timer support */
#undef  INCLUDE_GPIO          /* General purpose I/O ports support */
#undef  INCLUDE_FILEIO        /* File I/O support */

#define INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

/*****************************************************************************
*
* Overwrite default component initialization from config/config.h
*
*****************************************************************************/

#define CODEC_MODE           CODEC_MONO

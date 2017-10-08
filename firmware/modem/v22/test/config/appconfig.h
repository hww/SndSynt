/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP           /* BSP support */

#define INCLUDE_CODEC         /* codec driver */
#define INCLUDE_SSI           /* Codec device configuration */
#define INCLUDE_IO            /* I/O support */
#undef  INCLUDE_LED           /* led support for target board */
#undef  INCLUDE_SERIAL        /* serial support */
#undef  INCLUDE_SPI           /* spi support */
#undef  INCLUDE_TIMER         /* timer support */

#define  INCLUDE_MEMORY        /* memory support */
#undef  INCLUDE_DSPFUNC       /* dsp functional library */

/*****************************************************************************
*
* Overwrite default component initialization from config/config.h
*
*****************************************************************************/


/* The following definitions are for obtaining 7.2KHz sampling with codec */
 
#define CODEC_MODE   CODEC_MONO
#define CODEC_OPTIMIZATION_BUFFER_SIZE    2

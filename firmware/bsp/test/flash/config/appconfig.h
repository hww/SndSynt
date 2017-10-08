/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_MEMORY        /* memory support */
#define INCLUDE_BSP           /* BSP support */
#define INCLUDE_IO            /* I/O support */

#define INCLUDE_FLASH         /* flash support */

/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/

#define SIM_BOOT_MODE    SIM_BOOT_MODE_B
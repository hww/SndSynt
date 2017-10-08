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

#define INCLUDE_IO            /* I/O support */
#undef  INCLUDE_MEMORY        /* memory support */
#define INCLUDE_FLASH         /* flash driver */

/*****************************************************************************
*
* Overwrite default component initialization from config/config.h
*
*****************************************************************************/


#endif
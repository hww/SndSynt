/*****************************************************************************
*
* buttondrvIO.h - header file for the Button driver
*
*****************************************************************************/


#ifndef __BUTTONDRVIO_H
#define __BUTTONDRVIO_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_BUTTON
		#error INCLUDE_IO_BUTTON must be defined in appconfig.h to initialize the IO Layer for the Button Driver
	#endif
#endif


#include "port.h"
#include "time.h"
#include "button.h"
#include "io.h"
#include "fcntl.h"


#ifdef __cplusplus
extern "C" {
#endif


/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT io_sDriver * buttondrvIOOpen(const  char * pName, int OFlags, ...);

/* EXPORT Result buttondrvIOCreate(const char * pName) */
#define buttondrvIOCreate(name) buttonCreate(name)


#ifdef __cplusplus
}
#endif

#endif
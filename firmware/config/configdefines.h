#ifndef __CONFIGDEFINES_H
#define __CONFIGDEFINES_H

#ifdef __cplusplus
extern "C" {
#endif


/****************************************************************************
*
* Include user selected SDK components
*
****************************************************************************/
#include "appconfig.h"

/****************************************************************************
*
* Resolve include dependencies automatically
*
****************************************************************************/

#ifdef INCLUDE_BSP
	#ifndef INCLUDE_PLL
		#define INCLUDE_PLL
	#endif
	#ifndef INCLUDE_SIM
		#define INCLUDE_SIM
	#endif
	#ifndef INCLUDE_COP
		#define INCLUDE_COP
	#endif
	#ifndef INCLUDE_CORE
		#define INCLUDE_CORE
	#endif
	#ifndef INCLUDE_ITCN
		#define INCLUDE_ITCN
	#endif
#endif

/* Default all INCLUDE_IO_xxx to INCLUDE_xxx */

#ifdef INCLUDE_SOUND
	#ifndef INCLUDE_FILEIO
		#define INCLUDE_FILEIO
	#endif
	
	#ifndef INCLUDE_SYNT
		#define INCLUDE_SYNT
	#endif
#endif

#ifdef INCLUDE_SYNT
	#ifndef INCLUDE_FCODEC
		#define INCLUDE_FCODEC
	#endif
#endif

#ifdef INCLUDE_IO_CODEC
	#ifndef INCLUDE_CODEC
		#define INCLUDE_CODEC
	#endif
#endif
	
#ifdef INCLUDE_IO_BUTTON
	#ifndef INCLUDE_BUTTON
		#define INCLUDE_BUTTON
	#endif
#endif

#ifdef INCLUDE_IO_SERIAL_DATAFLASH
	#ifndef INCLUDE_SERIAL_DATAFLASH
		#define INCLUDE_SERIAL_DATAFLASH
	#endif
#endif

#ifdef INCLUDE_IO_FILEIO
	#ifndef INCLUDE_FILEIO
		#define INCLUDE_FILEIO
	#endif
#endif

#ifdef INCLUDE_IO_FLASH
	#ifndef INCLUDE_FLASH
		#define INCLUDE_FLASH
	#endif
#endif

#ifdef INCLUDE_IO_GPIO
	#ifndef INCLUDE_GPIO
		#define INCLUDE_GPIO
	#endif
#endif
	
#ifdef INCLUDE_IO_LED
	#ifndef INCLUDE_LED
		#define INCLUDE_LED
	#endif
#endif
	
#ifdef INCLUDE_IO_QUAD_TIMER
	#ifndef INCLUDE_QUAD_TIMER
		#define INCLUDE_QUAD_TIMER
	#endif
#endif
	
#ifdef INCLUDE_IO_SCI
	#ifndef INCLUDE_SCI
		#define INCLUDE_SCI
	#endif
#endif

#ifdef INCLUDE_IO_SPI
	#ifndef INCLUDE_SPI
		#define INCLUDE_SPI
	#endif
#endif

#ifdef INCLUDE_IO_SWITCH
	#ifndef INCLUDE_SWITCH
		#define INCLUDE_SWITCH
	#endif
#endif

#ifdef INCLUDE_SERIAL_DATAFLASH
    #ifndef INCLUDE_SPI
        #define INCLUDE_SPI
    #endif
    
    #ifndef INCLUDE_GPIO
        #define INCLUDE_GPIO
    #endif
#endif

#ifdef INCLUDE_PCMASTER
	#ifndef INCLUDE_SCI
		#define INCLUDE_SCI
	#endif
#endif

#ifdef INCLUDE_LED
	#ifndef INCLUDE_GPIO
		#define INCLUDE_GPIO
	#endif
#endif

#ifdef INCLUDE_CODEC
	#ifndef INCLUDE_SSI
		#define INCLUDE_SSI
	#endif
	
	#ifndef INCLUDE_GPIO
	    #define INCLUDE_GPIO
	#endif
#endif

#ifdef INCLUDE_FCODEC
	#ifndef INCLUDE_SSI
		#define INCLUDE_SSI
	#endif
	
	#ifndef INCLUDE_GPIO
	    #define INCLUDE_GPIO
	#endif
#endif

#ifdef INCLUDE_SWITCH
	#ifndef INCLUDE_GPIO
		#define INCLUDE_GPIO
	#endif
#endif

#ifdef INCLUDE_FILEIO
	#ifndef INCLUDE_SCI
		#define INCLUDE_SCI
	#endif
	
	#ifndef INCLUDE_MEMORY
		#define INCLUDE_MEMORY
	#endif
#endif

#ifdef INCLUDE_TIMER
	#ifndef INCLUDE_QUAD_TIMER
		#define INCLUDE_QUAD_TIMER
	#endif
#endif

#ifdef INCLUDE_IO
	
	#ifdef INCLUDE_BUTTON
		#ifndef INCLUDE_IO_BUTTON
			#define INCLUDE_IO_BUTTON
		#endif
	#endif

	#ifdef INCLUDE_CODEC
		#ifndef INCLUDE_IO_CODEC
			#define INCLUDE_IO_CODEC
		#endif
	#endif
	
	#ifdef INCLUDE_SERIAL_DATAFLASH
		#ifndef INCLUDE_IO_SERIAL_DATAFLASH
			#define INCLUDE_IO_SERIAL_DATAFLASH
		#endif
	#endif
	
	#ifdef INCLUDE_FILEIO
		#ifndef INCLUDE_IO_FILEIO
			#define INCLUDE_IO_FILEIO
		#endif
	#endif

	#ifdef INCLUDE_FLASH
		#ifndef INCLUDE_IO_FLASH
			#define INCLUDE_IO_FLASH
		#endif
	#endif

	#ifdef INCLUDE_GPIO
		#ifndef INCLUDE_IO_GPIO
			#define INCLUDE_IO_GPIO
		#endif
	#endif
	
	#ifdef INCLUDE_LED
		#ifndef INCLUDE_IO_LED
			#define INCLUDE_IO_LED
		#endif
	#endif
	
	#ifdef INCLUDE_QUAD_TIMER
		#ifndef INCLUDE_IO_QUAD_TIMER
			#define INCLUDE_IO_QUAD_TIMER
		#endif
	#endif
	
	#ifdef INCLUDE_SCI
		#ifndef INCLUDE_IO_SCI
			#define INCLUDE_IO_SCI
		#endif
	#endif

	#ifdef INCLUDE_SPI
		#ifndef INCLUDE_IO_SPI
			#define INCLUDE_IO_SPI
		#endif
	#endif

#endif

#if defined(INCLUDE_IO)               \
	|| defined(INCLUDE_IO_CODEC)      \
	|| defined(INCLUDE_IO_BUTTON)     \
	|| defined(INCLUDE_IO_SERIAL_DATAFLASH)     \
	|| defined(INCLUDE_IO_FILEIO)     \
	|| defined(INCLUDE_IO_FLASH)      \
	|| defined(INCLUDE_IO_GPIO)       \
	|| defined(INCLUDE_IO_LED)        \
	|| defined(INCLUDE_IO_QUAD_TIMER) \
	|| defined(INCLUDE_IO_SCI)        \
	|| defined(INCLUDE_IO_SPI)
		#ifndef INCLUDE_IO_IO
			#define INCLUDE_IO_IO
		#endif
#endif


#endif
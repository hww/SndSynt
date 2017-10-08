/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         const.h
*
* Description:       Description of SDK constant for const.c file
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#ifndef __CONST_H
#define __CONST_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"
#endif

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_IO)
  #include "io.h"
#endif


/*
	DSP FUNCTION Library constants
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_DSPFUNC)

  #include "dspfunc.h"
  
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable8[8];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable16[16];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable32[32];     
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable64[64];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable128[128];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable256[256];     
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable512[512];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable1024[1024];
    EXPORT const CFrac16 dfr16CFFTTwiddleFactorTable2048[2048];
    
    EXPORT const CFrac16 dfr16RFFTTwiddleTable8[]; 
    EXPORT const CFrac16 dfr16RFFTTwiddleTable8br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable16[]; 
    EXPORT const CFrac16 dfr16RFFTTwiddleTable16br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable32[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable32br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable64[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable64br[]; 
    EXPORT const CFrac16 dfr16RFFTTwiddleTable128[]; 
    EXPORT const CFrac16 dfr16RFFTTwiddleTable128br[]; 
    EXPORT const CFrac16 dfr16RFFTTwiddleTable256[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable256br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable512[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable512br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable1024[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable1024br[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable2048[];
    EXPORT const CFrac16 dfr16RFFTTwiddleTable2048br[];
    
#endif


/*
	GPIO Driver constants for IO Layer
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_GPIO)

	EXPORT const io_sInterface gpiodrvIOInterfaceVT;
	EXPORT const io_sDriver    gpiodrvIODevice;

#endif

/*
	LED Driver constants for IO Layer
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_LED)

	EXPORT const io_sInterface leddrvIOInterfaceVT;
	EXPORT const io_sDriver leddrvIODevice;

#endif

/* 
	Button Driver constants
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_BUTTON)

	EXPORT const io_sInterface buttondrvIOInterfaceVT;
	EXPORT const io_sDriver buttondrvIODeviceA;
	EXPORT const io_sDriver buttondrvIODeviceB;

#endif

/*  
	QT Driver constants
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_QUAD_TIMER)

	EXPORT const io_sInterface qtimerdrvIOInterfaceVT;

	EXPORT const io_sDriver qtimerdrvIODevice[];
	
#endif

/* 
	SPI Driver constants
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_SPI)

	EXPORT const io_sInterface spidrvIOInterfaceVT;
	EXPORT const io_sDriver spidrvIODevice[2];

#endif

/*
	TOD Driver constants
*/
#if defined(SDK_LIBRARY) || defined(INCLUDE_TIME_OF_DAY)

	EXPORT const UWord16 TodClockScaler;

#endif

#endif /* __CONST_H */
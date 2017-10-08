/* File: xfr16.h */

#ifndef __XFR16_H
#define __XFR16_H

#include "port.h"
#include "afr16.h"
#include "vfr16.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************
* To switch between C and assembly implementations 
*       #if 0  => assembly
*       #if 1  => C
*******************************************************/

#if 0
#define xfr16Mult xfr16MultC
#define xfr16Det  xfr16DetC
#define xfr16Inv  xfr16InvC
#define xfr16Sub  xfr16SubC
#define xfr16Trans xfr16TransC
#define xfr16Equal xfr16EqualC
#endif


/*******************************************************
* Matrix Math - 16 bit fractional
*******************************************************/

#if 0
EXPORT void xfr16Add  ( Frac16 *pX, int rows, int cols, 
								Frac16 *pY,
								Frac16 *pZ);
#else
#define xfr16Add(pX,rows,cols,pY,pZ)  afr16Add(pX,pY,pZ,rows*cols)
#endif


#if 0
EXPORT void xfr16Sub  ( Frac16 *pX, int rows, int cols, 
								Frac16 *pY,
								Frac16 *pZ);
#else
#define xfr16Sub(pX,rows,cols,pY,pZ)  afr16Sub(pX,pY,pZ,rows*cols)
#endif


EXPORT void xfr16Mult ( Frac16 *pX, int xrows, int xcols, 
								Frac16 *pY, int ycols, 
								Frac16 *pZ);


#if 0								
EXPORT bool xfr16Equal( Frac16 *pX, int rows, int cols, 
								Frac16 *pY);
#else
#define xfr16Equal(pX,rows,cols,pY)  afr16Equal(pX,pY,rows*cols)
#endif

								
EXPORT void xfr16Trans( Frac16 *pX, int xrows, int xcols, 
								Frac16 *pZ);
								
EXPORT Frac32 xfr16Inv( Frac16 *pX, int rowscols, 
								Frac16 *pZ);
								
EXPORT Frac32 xfr16Det( Frac16 *pX, int rowscols);
								

#ifdef __cplusplus
}
#endif

#endif

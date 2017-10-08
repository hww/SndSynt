/* File: vfr16.h */

#ifndef __VFR16_H
#define __VFR16_H

#include "port.h"

#include "afr16.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************
* To switch between C and assembly implementations 
*       #if 0  => assembly
*       #if 1  => C
*******************************************************/

#if 0
#define vfr16DotProd vfr16DotProdC
#define vfr16Length  vfr16LengthC
#define vfr16Mult    vfr16MultC
#define vfr16Scale   vfr16ScaleC
#endif


/*******************************************************
* Vector Math - 16 bit fractional
*******************************************************/

#if 0
EXPORT void    vfr16Add     (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
#else
#define vfr16Add afr16Add
#endif


EXPORT Frac32  vfr16DotProd (Frac16 *pX, Frac16 *pY, UInt16 n);

#if 0
EXPORT bool    vfr16Equal   (Frac16 *pX, Frac16 *pY, UInt16 n);
#else
#define vfr16Equal afr16Equal
#endif

EXPORT Frac16  vfr16Length  (Frac16 *pX, UInt16 n);

EXPORT void    vfr16Mult    (Frac16 c, Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    vfr16Scale   (Int16  k, Frac16 *pX, Frac16 *pZ, UInt16 n);

#if 0
EXPORT void    vfr16Sub     (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
#else
#define vfr16Sub afr16Sub
#endif


#ifdef __cplusplus
}
#endif

#endif

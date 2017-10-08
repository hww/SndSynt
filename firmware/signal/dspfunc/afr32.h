/* File: afr32.h */

#ifndef __AFR32_H
#define __AFR32_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************
* To switch between C and assembly implementations 
*       #if 0  => assembly
*       #if 1  => C
*******************************************************/

#if 0
#define afr32Abs     afr32AbsC
#define afr32Add     afr32AddC
#define afr32Sub     afr32SubC
#define afr32Div     afr32DivC
#define afr32Equal   afr32EqualC
#define afr32Mac     afr32MacC
#define afr32Mac_r   afr32Mac_rC
#define afr32Max     afr32MaxC
#define afr32Min     afr32MinC
#define afr32Msu     afr32MsuC
#define afr32Msu_r   afr32Msu_rC
#define afr32Mult    afr32MultC
#define afr32Mult_ls afr32Mult_lsC
#define afr32Negate  afr32NegateC
#define afr32Round   afr32RoundC
#define afr32Sqrt    afr32SqrtC
#endif


/*******************************************************
* Single dimension array operations - 16 bit fractional
*******************************************************/

EXPORT void    afr32Abs    (Frac32 *pX, Frac32 *pZ, UInt16 n);

EXPORT void    afr32Add    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);

EXPORT void    afr32Div    (Frac32 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT bool    afr32Equal  (Frac32 *pX, Frac32 *pY, UInt16 n);

EXPORT void    afr32Mac    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Mac_r  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT Frac32  afr32Max    (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex);

EXPORT Frac32  afr32Min    (Frac32 *pX, UInt16 n, UInt16 *pMinIndex);

EXPORT void    afr32Msu    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Msu_r  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr32Mult   (Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Mult_ls(Frac32 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);

EXPORT void    afr32Negate (Frac32 *pX, Frac32 *pZ, UInt16 n);

EXPORT void    afr32Round  (Frac32 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr32Sqrt   (Frac32 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr32Sub    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);


#ifdef __cplusplus
}
#endif

#endif

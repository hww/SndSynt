/* File: afr16.h */

#ifndef __AFR16_H
#define __AFR16_H

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
#define afr16Add     afr16AddC
#define afr16Abs     afr16AbsC
#define afr16Div     afr16DivC
#define afr16Equal   afr16EqualC
#define afr16Mac_r   afr16Mac_rC
#define afr16Msu_r   afr16Msu_rC
#define afr16Mult    afr16SubC
#define afr16Max     afr16MaxC
#define afr16Min     afr16MinC
#define afr16Mult_r  afr16Mult_rC
#define afr16Negate  afr16NegateC
#define afr16Rand    afr16RandC
#define afr16Sqrt    afr16SqrtC
#define afr16Sub     afr16SubC
#endif


/*******************************************************
* Single dimension array operations - 16 bit fractional
*******************************************************/

EXPORT void    afr16Abs    (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Add    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Div    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT bool    afr16Equal  (Frac16 *pX, Frac16 *pY, UInt16 n);

EXPORT void    afr16Mac_r  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT Frac16  afr16Max    (Frac16 *pX, UInt16 n, UInt16 *pMaxIndex);

EXPORT Frac16  afr16Min    (Frac16 *pX, UInt16 n, UInt16 *pMinIndex);

EXPORT void    afr16Msu_r  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Mult   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void    afr16Mult_r (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Negate (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Rand   (Frac16 *pZ, UInt16 n);

EXPORT void    afr16Sqrt   (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16Sub    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);


#ifdef __cplusplus
}
#endif

#endif

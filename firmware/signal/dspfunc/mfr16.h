/* File: mfr16.h */

#ifndef __MFR16_H
#define __MFR16_H

#include "port.h"
#include "prototype.h"
#include "mfr32.h"

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************
* Fractional Math Intrinsics 
*
* These math intrinsics are provided by the MetroWerks
* CodeWarrior C compiler for fractional types.  These
* declarations are included here as documentation only.
********************************************************
* 
* Frac16 abs_s          (Frac16 x);
* 
* Frac16 add            (Frac16 x, Frac16 y);
* 
* Frac16 div_s          (Frac16 x, Frac16 y);
*
* Frac16 mult           (Frac16 x, Frac16 y);
* Frac16 mult_r         (Frac16 x, Frac16 y);
* 
* Frac16 negate         (Frac16 x);
*
* Frac16 norm_s         (Frac16 x);
*
* Frac16 shl            (Frac16 x, Int16 n);
* Frac16 shr            (Frac16 x, Int16 n);
* Frac16 shr_r          (Frac16 x, Int16 n);
* 
* Frac16 sub            (Frac16 x, Frac16 y);
* 
*******************************************************/


/*******************************************************
* Misc Fractional Math
*******************************************************/

EXPORT Frac16  mfr16Rand        (void);

EXPORT void    mfr16SetRandSeed (Frac16 x);

#if 0
EXPORT Frac16  mfr16Sqrt        (Frac16 x);
#else
#define mfr16Sqrt(x) mfr32Sqrt(L_deposit_h(x))
#endif


#ifdef __cplusplus
}
#endif

#endif

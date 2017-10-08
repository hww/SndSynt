/* File: mfr32.h */

#ifndef __MFR32_H
#define __MFR32_H

#include "port.h"
#include "prototype.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************
* To switch between C and assembly implementations 
*       #if 0  => assembly
*       #if 1  => C
*******************************************************/

#if 0
#define mfr32Sqrt     mfr32SqrtC
#endif


/*******************************************************
* Fractional Math Intrinsics 
*
* These math intrinsics are provided by the MetroWerks
* CodeWarrior C compiler for fractional types.  These
* declarations are included here as documentation only.
********************************************************
*
* Frac32 L_abs          (Frac32 x);
* 
* Frac32 L_add          (Frac32 x, Frac32 y);
* 
* Frac32 div_ls         (Frac32 x, Frac16 y);
*
* Frac32 L_deposit_h    (Frac16 x); 
* Frac32 L_deposit_l    (Frac16 x);
* 
* Frac16 extract_l      (Frac32 x);
* Frac16 extract_h      (Frac32 x);
* 
* Frac16 mac_r          (Frac32 w, Frac16 x, Frac16 y);
* Frac32 L_mac          (Frac32 w, Frac16 x, Frac16 y);
* 
* Frac16 msu_r          (Frac32 w, Frac16 x, Frac16 y);
* Frac32 L_msu          (Frac32 w, Frac16 x, Frac16 y);
* 
* Frac32 L_mult         (Frac16 x, Frac16 y);
* Frac32 L_mult_ls      (Frac32 x, Frac16 y);
* 
* Frac32 L_negate       (Frac32 x);
* 
* Frac16 norm_l         (Frac32 x); 
*
* Frac16 round          (Frac32 x);
* 
* Frac32 L_shl          (Frac32 x, Int16 n);
* Frac32 L_shr          (Frac32 x, Int16 n);
* Frac32 L_shr_r        (Frac32 x, Int16 n);
* 
* Frac32 L_sub          (Frac32 x, Frac32 y);
* 
*******************************************************/


/*******************************************************
* Misc Fractional Math
*******************************************************/

EXPORT Frac16  mfr32Sqrt (Frac32 x);


#ifdef __cplusplus
}
#endif

#endif

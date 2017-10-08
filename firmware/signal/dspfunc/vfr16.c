/* File: vfr16.c */

/**************************************************************************
*
*  Copyright (C) 1999 Motorola, Inc. All Rights Reserved 
*
**************************************************************************/

#include "port.h"
#include "vfr16.h"
#include "mfr32.h"
#include "prototype.h"
#include "assert.h"


EXPORT Frac32  vfr16DotProdC (Frac16 *, Frac16 *, UInt16);
EXPORT Frac16  vfr16LengthC  (Frac16 *, UInt16);
EXPORT void    vfr16MultC    (Frac16, Frac16 *, Frac16 *, UInt16);
EXPORT void    vfr16ScaleC   (Int16, Frac16 *, Frac16 *, UInt16);

/*******************************************************
* Vector Math - 16-bit fractional
*******************************************************/

Frac32  vfr16DotProdC (Frac16 *pX, Frac16 *pY, UInt16 n)
{
	Frac32 Prod;
	UInt16 i;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 

	Prod = 0x0000;
	
	for (i=0; i<n; i++) {
		Prod = L_mac(Prod, *(pX + i), *(pY + i)); 
	}
	
	return Prod;
}


Frac16  vfr16LengthC  (Frac16 *pX, UInt16 n)
{
	Frac32 SumSquares;
	UInt16 i;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 

	SumSquares = 0x0000;
	
	for (i=0; i<n; i++) {
		SumSquares = L_mac(SumSquares, *(pX + i), *(pX + i)); 
	}
	
	return mfr32Sqrt(SumSquares);
}


void    vfr16MultC    (Frac16 c, Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mult(c, *(pX + i)); 
	}
}


void    vfr16ScaleC   (Int16  k, Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = shl(*(pX + i), k); 
	}
}




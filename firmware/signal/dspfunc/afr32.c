/* File: afr32.c */

/**************************************************************************
*
*  Copyright (C) 1999 Motorola, Inc. All Rights Reserved 
*
**************************************************************************/

#include "port.h"
#include "afr32.h"
#include "mfr32.h"
#include "stdlib.h"
#include "assert.h"

EXPORT void  afr32SubC    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32SqrtC   (Frac32 *pX, Frac16 *pZ, UInt16 n);
EXPORT void  afr32RoundC   (Frac32 *pX, Frac16 *pZ, UInt16 n);
EXPORT void  afr32NegateC (Frac32 *pX, Frac32 *pZ, UInt16 n);
EXPORT void  afr32Mult_lsC (Frac32 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32MultC   (Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32AbsC  (Frac32 *pX, Frac32 *pZ, UInt16 n);
EXPORT void  afr32AddC   (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32DivC   (Frac32 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT bool  afr32EqualC   (Frac32 *pX, Frac32 *pY, UInt16 n);
EXPORT void  afr32MacC    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32Mac_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT Frac32  afr32MaxC (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex);
EXPORT Frac32 afr32MinC (Frac32 *pX, UInt16 n, UInt16 *pMinIndex);
EXPORT void  afr32MsuC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void  afr32Msu_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

/*======================================================
* 32-bit fractional, single dimensioned array operations
========================================================*/

void  afr32AbsC  (Frac32 *pX, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_abs(*pX++); 
	}
}


void  afr32AddC   (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_add(*pX++, *pY++); 
	}
}


void  afr32DivC   (Frac32 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = div_ls(*pX++, *pY++); 
	}
}


bool  afr32EqualC   (Frac32 *pX, Frac32 *pY, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		if (*pX++ != *pY++)
		{
			return false;
		} 
	}
	
	return true;
}


void  afr32MacC    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_mac(*pW++, *pX++, *pY++); 
	}
}


void  afr32Mac_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = mac_r(*pW++, *pX++, *pY++); 
	}
}


Frac32  afr32MaxC (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex)
{
	UInt16 i;
	Frac32 Max;
	UInt16 MaxIndex;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 
	assert (n > 0);
	
	Max      = *pX++;
	MaxIndex = 0;
	
	for (i=1; i<n; i++) {
		if(*pX > Max)
		{
			Max = *pX;
			MaxIndex = i;
		} 
		
		pX++;
	}

	if (pMaxIndex != NULL)
	{
		*pMaxIndex = MaxIndex;
	}
	
	return Max;
}


Frac32 afr32MinC (Frac32 *pX, UInt16 n, UInt16 *pMinIndex)
{
	UInt16 i;
	Frac32 Min;
	UInt16 MinIndex;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 
	assert (n > 0);
	
	Min      = *pX++;
	MinIndex = 0;
	
	for (i=1; i<n; i++) {
		if(*pX < Min)
		{
			Min = *pX;
			MinIndex = i;
		}
		
		pX++; 
	}

	if (pMinIndex != NULL)
	{
		*pMinIndex = MinIndex;
	}
	
	return Min;
}


void  afr32MsuC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_msu(*pW++, *pX++, *pY++); 
	}
}


void  afr32Msu_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = msu_r(*pW++, *pX++, *pY++); 
	}
}


void  afr32MultC   (Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_mult(*pX++, *pY++); 
	}
}

void  afr32Mult_lsC (Frac32 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_mult_ls(*pX++, *pY++); 
	}
}


void  afr32NegateC (Frac32 *pX, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_negate(*pX++); 
	}
}


void  afr32RoundC   (Frac32 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = round (*pX++); 
	}
}


void  afr32SqrtC   (Frac32 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = mfr32Sqrt(*pX++); 
	}
}


void  afr32SubC    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*pZ++ = L_sub(*pX++, *pY++); 
	}
}

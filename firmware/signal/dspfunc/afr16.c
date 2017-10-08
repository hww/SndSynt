/* File: afr16.c */

/**************************************************************************
*
*  Copyright (C) 1999 Motorola, Inc. All Rights Reserved 
*
**************************************************************************/

#include "port.h"
#include "afr16.h"
#include "mfr16.h"
#include "stdlib.h"
#include "assert.h"


EXPORT void  afr16AbsC  (Frac16 *pX, Frac16 *pZ, UInt16 n);
EXPORT void  afr16AddC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void  afr16DivC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT bool  afr16EqualC   (Frac16 *pX, Frac16 *pY, UInt16 n);
EXPORT void  afr16Mac_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT Frac16  afr16MaxC (Frac16 *pX, UInt16 n, UInt16 *pMaxIndex);
EXPORT Frac16 afr16MinC (Frac16 *pX, UInt16 n, UInt16 *pMinIndex);
EXPORT void  afr16Msu_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void  afr16MultC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void  afr16Mult_rC (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void  afr16NegateC (Frac16 *pX, Frac16 *pZ, UInt16 n);
EXPORT void  afr16RandC   (Frac16 *pZ, UInt16 n);
EXPORT void  afr16SqrtC   (Frac16 *pX, Frac16 *pZ, UInt16 n);
EXPORT void  afr16SubC    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);


/*======================================================
* 16-bit fractional, single dimensioned array operations
========================================================*/

void  afr16AbsC  (Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = abs_s(*(pX + i)); 
	}
}


void  afr16AddC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = add(*(pX + i), *(pY + i)); 
	}
}


void  afr16DivC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = div_s(*(pX + i), *(pY + i)); 
	}
}


bool  afr16EqualC   (Frac16 *pX, Frac16 *pY, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		if (*(pX + i) != *(pY + i))
		{
			return false;
		} 
	}
	
	return true;
}


void  afr16Mac_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mac_r(L_deposit_h(*(pW + i)), *(pX + i), *(pY + i)); 
	}
}


Frac16  afr16MaxC (Frac16 *pX, UInt16 n, UInt16 *pMaxIndex)
{
	UInt16 i;
	Frac16 Max;
	UInt16 MaxIndex;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 
	assert (n > 0);
	
	Max      = *pX;
	MaxIndex = 0;
	
	for (i=1; i<n; i++) {
		if(*(pX + i) > Max)
		{
			Max = *(pX + i);
			MaxIndex = i;
		} 
	}

	if (pMaxIndex != NULL)
	{
		*pMaxIndex = MaxIndex;
	}
	
	return Max;
}


Frac16 afr16MinC (Frac16 *pX, UInt16 n, UInt16 *pMinIndex)
{
	UInt16 i;
	Frac16 Min;
	UInt16 MinIndex;
	
	assert (n <= PORT_MAX_VECTOR_LEN); 
	assert (n > 0);
	
	Min      = *pX;
	MinIndex = 0;
	
	for (i=1; i<n; i++) {
		if(*(pX + i) < Min)
		{
			Min = *(pX + i);
			MinIndex = i;
		} 
	}

	if (pMinIndex != NULL)
	{
		*pMinIndex = MinIndex;
	}
	
	return Min;
}


void  afr16Msu_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = msu_r(L_deposit_h(*(pW + i)), *(pX + i), *(pY + i)); 
	}
}


void  afr16MultC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mult(*(pX + i), *(pY + i)); 
	}
}

void  afr16Mult_rC (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mult_r(*(pX + i), *(pY + i)); 
	}
}


void  afr16NegateC (Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = negate(*(pX + i)); 
	}
}


void  afr16RandC   (Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mfr16Rand(); 
	}
}


void  afr16SqrtC   (Frac16 *pX, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = mfr16Sqrt(*(pX + i)); 
	}
}


void  afr16SubC    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n)
{
	UInt16 i;

	assert (n <= PORT_MAX_VECTOR_LEN); 

	for (i=0; i<n; i++) {
		*(pZ + i) = sub(*(pX + i), *(pY + i)); 
	}
}

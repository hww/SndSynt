/* File: mfr32.c */

#include "port.h"
#include "mfr32.h"

EXPORT Frac16 mfr32SqrtC (Frac32);

/*******************************************************
* Misc 32-bit Fractional Math
*******************************************************/

Frac16 mfr32SqrtC (Frac32 x)
{
	Frac16       Est;
	Frac16       EstR;
	Frac16       Bit = 0x4000;
	Frac32       Temp;
	UInt16       i;
	
	Est = 0x0000;
	
	for (i=0; i<14; i++)
	{
		Est = add(Est, Bit);

		Temp = L_mult(Est,Est);
		
		if (Temp > x)
		{
			Est = sub(Est, Bit);
		}
		
		Bit = shr (Bit, 1);
	}
	
	/* Choose between estimate & rounded estimate for most accurate result */
	 
	EstR = add(Est, 1);
	
	if (L_abs(L_sub(x,L_mult(EstR, EstR))) < L_sub(x,L_mult(Est,Est)))
	{
		Est = EstR;
	}
	
	return Est;
}

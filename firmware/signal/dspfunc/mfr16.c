/* File: mfr16.c */

#include "port.h"
#include "mfr16.h"


/*******************************************************
* Misc 16-bit Fractional Math
*******************************************************/

static volatile Int16 LastRandomNumber = 21845;

Frac16 mfr16Rand      (void)
{
	bool           bSaturationMode;
	
	/* Turn saturation mode off in order to get mod op */
	bSaturationMode = archGetSetSaturationMode(false);
	
	LastRandomNumber = (LastRandomNumber * 31821) + 13849;

	archGetSetSaturationMode (bSaturationMode);
	
	return *((Frac16 *)(&LastRandomNumber));
}


void mfr16SetRandSeed (Frac16 x)
{
	LastRandomNumber = *((Int16 *)(&x));
}

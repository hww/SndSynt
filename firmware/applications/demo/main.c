/* File: main.c */

#include "port.h"

/*******************************************************
* Skeleton C main program for use with Embedded SDK
*******************************************************/

extern sampleASM (void);

void main (void)
{
	/* 
		This program serves as a quick start guide to
		writing either C or ASM programs using the
		Embedded SDK.  Modify it at will
	*/
	
	sampleASM ();    /* Call a sample ASM routine from C */
	
	asm (nop);       /* Demonstrate use of inline ASM */
	
	return;          /* C statements */
}

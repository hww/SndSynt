/* File: memTarget.c */

#include "port.h"
#include "mem.h"
#include "arch.h"
#include "assert.h"
#include <string.h>
#include <stdio.h>


/*******************************************************
* specific memory Package for 56805
*******************************************************/

bool    memIsIM     (void * memblock)
{
	/* 
	   Register Usage:
	            R2     - input value of memblock
	            Y0     - output value (boolean)
	   
	   Can be called from a pragma interrupt ISR
	*/
	
	/* Using EX bit? */
	asm(bftsth  #$0008,OMR);
	asm(bcc     UsingInt);
	asm(clr     Y0);
	asm(rts);
	asm(UsingInt:);
	
	/* WARNING:  This check is 56805 specific      */
	/* return ((UInt16)memblock < (UInt16)0x2000); */
	asm(lea     (SP+2));
	asm(move    R2,X:(SP-1));
	asm(move    #$2000,Y0);
	asm(cmp     X:(SP-1),Y0);
	asm(clr     Y0);
	asm(bls     NotIM);
	asm(move    #1,Y0);
	asm(NotIM:);
	asm(lea     (SP-2));
	asm(rts);
}


bool    memIsEM     (void * memblock)
{
	/* 
	   Register Usage:
	            R2     - input value of memblock
	            Y0     - output value (boolean)
	   
	   Can be called from a pragma interrupt ISR
	*/
	
	/* Using EX bit? */
	asm(bftsth  #$0008,OMR);
	asm(bcc     UsingNormalMap);
	asm(movei   #1,Y0);
	asm(rts);
	asm(UsingNormalMap:);
	
	/* WARNING:  This check is 56805 specific       */
	/* return ((UInt16)memblock >= (UInt16)0x2000); */
	asm
	{
	   move  R2, Y0
	   cmp   #$2000, Y0
	   clr   Y0
	   bcs   L_Exit
	   movei #1,Y0
   L_Exit:	   
	}
}



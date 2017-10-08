/* File: stackcheck.c */

#include "port.h"
#include "stackcheck.h"

extern char * _StackAddr;     /* Defined in linker.cmd */
extern char * _StackEndAddr;

/*******************************************************
* Interface to check for stack overflow
*
* To enable the stack check, define #INCLUDE_STACK_CHECK in appconfig.h
*	
* stackcheckSizeAllocated() returns the stack size that was allocated in linker.cmd
*	
* stackcheckSizeUsed() returns the stack size actually used so far in the application	
*	
* Note that stack overflow has occurred if
*      stackcheckSizeUsed () > stackcheckSizeAllocated ()
*
*******************************************************/

asm void stackcheckInitialize (void)
{
	move   SP,X0
	incw   X0
	move   #_StackEndAddr,Y0
	sub    X0,Y0
	blo    EndStkChk
	move   X0, R2
	
	move   #$A55A,X0
StoreStk:
	move   X0,X:(R2)+
	decw   Y0
	bge    StoreStk
EndStkChk:
	rts	
}


asm UInt16 stackcheckSizeUsed (void)
{
	move   #_StackEndAddr,R2
	nop
UnusedLoop:
	move   X:(R2)-,Y0
	cmp    #$A55A,Y0
	beq    UnusedLoop
	move   #_StackAddr,X0
	move   R2,Y0
	sub    X0,Y0
	incw   Y0
	incw   Y0
	rts
}


asm UInt16 stackcheckSizeAllocated (void)
{
/*	return (int)_StackEndAddr - (int)_StackAddr + 1; */
	move   #_StackEndAddr,Y0
	move   #_StackAddr,X0
	sub    X0,Y0
	incw   Y0
	rts
}

/* File: stackcheck.h */

#ifndef __STACKCHECK_H
#define __STACKCHECK_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_STACK_CHECK
		#error INCLUDE_STACK_CHECK must be defined in appconfig.h to initialize Stack Check
	#endif
#endif

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


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

EXPORT UInt16 stackcheckSizeUsed (void);

EXPORT UInt16 stackcheckSizeAllocated (void);


EXPORT void   stackcheckInitialize (void);  /* called from config.c */



#ifdef __cplusplus
}
#endif

#endif

/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME: convert23.h 
* 
* This file is used to convert names that were changed between SDK versions 
* 2.2.2 and 2.3.
*
* It is highly recommended that SDK users review the name changes included
* here and update their applications to use the new names. This file is provided
* as a short term quick fix that will give users some time to determine the best
* time to convert to the new names with minimal schedule impact. This file is a
* temporary solution and will not be available in the next SDK version 2.4. At 
* that time, the new names will become standard convention.
*
*******************************************************************************/

#ifndef __CONVERT23_H
#define __CONVERT23_H

#ifdef __cplusplus
extern "C" {
#endif


/* 
	The name MAX_VECTOR_LEN, defined in portasm.h, is used in assembly language 
	files.  It has been changed to PORT_MAX_VECTOR_LEN per SDK naming conventions
*/
#define MAX_VECTOR_LEN   PORT_MAX_VECTOR_LEN


/*
   Routines for Peripheral Memory Access from mempx.h file. It has been changed to 
   periphMemRead() and periphMemWrite() per SDK naming conventions
*/
#include "periph.h"
#define memReadPeripheral(pSrc) periphMemRead(pSrc)
#define memWritePeripheral(Data,pDest) periphMemWrite(Data, pDest)

#ifdef __cplusplus
}
#endif

#endif

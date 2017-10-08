/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         pramdata.h
*
* Description:       Description of SDK variables located in Program RAM
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#include "port.h"
#include "arch.h"


#ifndef __PRAMDATA_H
#define __PRAMDATA_H

extern sUserISR UserISRTable[sizeof(arch_sInterrupts) / sizeof(UWord32)];

#endif /* __PRAMDATA_H */
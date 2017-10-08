/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         sim.h
*
* Description:       API header file for DSP56826 SIM driver
*
* Modules Included:  
*                    
* 
*****************************************************************************/


#ifndef __SIM_H
#define __SIM_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SIM
		#error INCLUDE_SIM must be defined in appconfig.h to initialize the SCI driver
	#endif
#endif

#include "simdrv.h"

/*****************************************************************************
*
* SIM Control
*
*     simControl(UWord16 Cmd); 
*
* Semantics:
*
*     Change SIM device modes. SIM driver supports the following commands:
*
*  SIM_SELECT_SCI                   Configure SPI/SCI port to be SCI
*
*  SIM_SELECT_SPI                   Configure SPI/SCI port to be SPI
*
* Parameters:
*     Cmd         - command for driver 
*
* Return Value: 
*     None 
*
* Example:
*
*     // configure to use SCI
*     simControl(SIM_SELECT_SCI); 
*     
*     // configure to use SPI
*     simControl(SIM_SELECT_SPI); 
*
*****************************************************************************/

/* Remapping */

#define simControl(Cmd)   simControl##Cmd()

#define SIM_SELECT_SCI   1    /* Select two SCIs instead of extra SPI */
#define SIM_SELECT_SPI   2    /* Select extra SPI instead of two SCIs */


#ifdef __cplusplus
}
#endif

#endif


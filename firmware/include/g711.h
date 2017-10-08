/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g711.h
*
* Description:  This include file is the master include file for the 
*               g711 functions. The applications using g711 should include 
*               this file
*
* Modules Included:
*                   None
*
* Author : Sandeep Sehgal
*
* Date   : 28 July 2000
*
*****************************************************************************/


#ifndef __G711_H
#define __G711_H

/* 
   PCM Encoding (A-law / Mu-law Conversion)
*/

/***************************
 Foundational Include Files
****************************/

#include "port.h"

/********************************************
 #define for G.711 configuration flags
*********************************************/

/********************************************
     Structure for G.711 Configuration
*********************************************/

/********************************************
     Commands for G.711 Control
*********************************************/

/***************************
 Function Prototypes
****************************/

EXPORT Result g711_linear2alaw( Int16 *pPCM_values, unsigned char *pA_values, UInt16 NumSamples);

EXPORT Result g711_alaw2linear(  unsigned char *pA_values, Int16 *pPCM_values, UInt16 NumSamples);

EXPORT Result g711_linear2ulaw(  Int16 *pPCM_values, unsigned char *pU_values, UInt16 NumSamples);

EXPORT Result g711_ulaw2linear(  unsigned char *pU_values, Int16 *pPCM_values, UInt16 NumSamples);

EXPORT Result g711_ulaw2alaw(  unsigned char	*pUval, unsigned char *pAval, UInt16 NumSamples);

EXPORT Result g711_alaw2ulaw(  unsigned char	*pAval, unsigned char *pUval, UInt16 NumSamples);

#endif

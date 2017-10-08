/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165.h
*
* Description:  This include file is the master include file for
*               G.165 library. The applications using G.165
*               should include this file
*
* Modules Included:
*                   None
*
* Author : Sandeep Sehgal
*
* Date   : 30 May 2000
*
*****************************************************************************/

#ifndef __G165_H
#define __G165_H

/* 
   Electronic Echo Cancellation (G.165) interface
*/

/***************************
 Foundational Include Files
****************************/

#include "port.h"


/********************************************
 #define for G.165 configuration flags
*********************************************/
#define G165_CONFIG_NL_OPTION              1
#define G165_CONFIG_DISABLE_TONE_DETECTION 2
#define G165_CONFIG_INHIBIT_CONVERGENCE    4
#define G165_CONFIG_RESET_COEFFICIENTS     8


/********************************************
     Structure for G.165 Configuration
*********************************************/

typedef struct
{
	void    (*pCallback) (  void           * pCallbackArg,
							Int16           * pSamples, 
							UInt16          NumSamples);
	void    * pCallbackArg;
} g165_sCallback;


typedef struct
{
	UInt16             Flags;
	g165_sCallback     callback;
	UInt16             EchoSpan;
} g165_sConfigure;

typedef struct
{
    Int16          * pOutBuf;
    Int16            context_buf_length;
    g165_sCallback * pCallback;
}g165_sHandle;   

/********************************************
     Commands for G.165 Control
*********************************************/

#define G165_DEACTIVATE          1
#define G165_INHIBIT_CONVERGENCE 2
#define G165_RESET_COEFFICIENTS  4
#define G165_REENABLE_CONVERGENCE 8

/***************************
 Function Prototypes
****************************/


 
EXPORT g165_sHandle   * g165Create ( g165_sConfigure * pConfig);

EXPORT Result           g165Init (   g165_sHandle    * pG165, 
									 g165_sConfigure * pConfig);

EXPORT Result           g165Process ( g165_sHandle * pG165, 
									  Int16 *pSamples_Rin,
									  Int16 *pSamples_Sin, 
									  UInt16 NumSamples);
												
EXPORT UWord16          g165Control ( g165_sHandle * pG165, UInt16 Command);

EXPORT void             g165Destroy ( g165_sHandle * pG165);

#endif

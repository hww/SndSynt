/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: dtmf.h
*
* Description:  This include file is the master include file for the 
*               DTMF generation function. The applications using DTMF
*               generator should include this file
*
* Modules Included:
*                   None
*
* Author : Meera S. P.
*
* Date   : 01 June 2000
*
*****************************************************************************

***************************** Change History ********************************
* 
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*    11/07/2001     2.0.0        Changed for      Sudarshan & Mahesh
*                                Multi Channel
*
****************************************************************************/

#ifndef __DTMF_H
#define __DTMF_H

/* 
   Dual-tone, Multiple Frequency (DTMF) interface
*/

/***************************
 Foundational Include Files
****************************/

#include "port.h"

/********************************************
 #define for DMTF configuration flags
*********************************************/

/* None */


/********************************************
     Structure for DTMF Configuration
*********************************************/

typedef struct
{
	UInt16     OnDuration;   /* Number of samples */
	UInt16     OffDuration;  /* Number of samples */
	UWord16    SampleRate;   /* Frequency of Samples */
	Frac16     amp;          /* Amplitude */
} dtmf_sConfigure;


/********************************************
     Handle for DTMF Interface
*********************************************/

typedef struct 
{
	/* Private Data for DTMF routines */
	UWord16    Dummy[5];
	Word16     Dummy1[16];
	UWord16    Dummy2[2];

} dtmf_sHandle;


/***************************
 Function Prototypes
****************************/

 
EXPORT dtmf_sHandle *dtmfCreate (dtmf_sConfigure *pConfig);

EXPORT Result dtmfInit (dtmf_sHandle *pDTMF, 
                        dtmf_sConfigure *pConfig);

EXPORT Result dtmfSetKey (dtmf_sHandle *pDTMF,
                          char Key);
		/* Establishes the current key for DTMF tone generation;
			returns FAIL if the Key is invalid
		*/
		
EXPORT Result dtmfGenerate (dtmf_sHandle *pDTMF, 
                            Int16 *pData, /* Pointer to output buffer */
                            UWord16 NumSamples);
		/* dtmfGenerate returns FAIL if generation is complete for
			the current key;  otherwise, PASS if generation is not
			yet complete
		*/
												
EXPORT void dtmfDestroy	(dtmf_sHandle *pDTMF);

#endif

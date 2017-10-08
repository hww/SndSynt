/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: vad.h
*
* Description:  This include file is the master include file for the 
*               CPT Detector . The applications using CPT
*               Detector should include this file
*
* Modules Included: None
*
* Author : Manohar Babu
*
* Date   : 26 Sept 2000
*
***********************************************************************/

#ifndef _cptdet_H
#define _cptdet_H

/* Definitiones Used */
/* The variable "return_value" used in CPTDet_sCallback
   below uses one of the following definitions
 */ 

#define   DIAL_TONE_DETECTED           0x11
#define   MSG_WAITING_TONE_DETECTED    0x12
#define   RECALL_DIAL_TONE_DETECTED    0x13
#define   BUSY_TONE_DETECTED           0x14
#define   REORDER_TONE_DETECTED        0x15
#define   RINGING_TONE_DETECTED        0x16


/***************************
 Foundational Include Files
****************************/
#include "port.h"

/*************************************************
     Structure for CPT  Detector Callback
**************************************************/

typedef struct
{
	void    (*pCallback) (  void    * pCallbackArg,
					        UWord16   return_value);

	void    *pCallbackArg;
} CPTDet_sCallback;


/*************************************************
     Structure for CPT  Detector Configuration
**************************************************/

typedef struct
{
	CPTDet_sCallback   CPTDetCallback;
}CPTDet_sConfigure;

/*************************************************
     Structure for CPT  Detector Handle
**************************************************/

typedef struct
{
    CPTDet_sCallback *pCallback;
} CPTDet_sHandle;
 

/***************************
 Function Prototypes
****************************/

 
EXPORT CPTDet_sHandle * CPTDetCreate (CPTDet_sConfigure * pConfig);

EXPORT void    CPTDetInit ( CPTDet_sHandle        * pCPTDet, 
		            		CPTDet_sConfigure     * pConfig);

EXPORT Result   CPTDetection ( CPTDet_sHandle        * pCPTDet, 
				               Word16                * pSamples, 
				               UWord16                 NumberSamples);
												
EXPORT void     CPTDetDestroy ( CPTDet_sHandle * pCPTDet);


#endif
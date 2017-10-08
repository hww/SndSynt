/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: dtmfdet.h
*
* Description:  This include file is the master include file for the 
*               DTMF receiver. The applications using DTMF
*               receiver should include this file
*
* Modules Included:
*                   None
*
* Author : Sarang Akotkar
*
* Date   : 14 June 2000
*
*****************************************************************************/

#ifndef _dtmf_det_H
#define _dtmf_det_H


/***************************
 Foundational Include Files
****************************/
#include "port.h"

/*******************************************
 Definitions to be used for the Flags in the
 dtmfdet_sConfigure structure
********************************************/
#define   DTMFDETECTION_INABSENCE_OF_SPEECH    0
#define   DTMFDETECTION_INPRESENCE_OF_SPEECH   1

/*******************************************
 Definitions used for the Status on Callback
********************************************/
#define   DTMFDET_KEY_DETECTED        1

typedef struct
{
	void    (*pCallback) (  void    * pCallbackArg,
                            UWord16   Status, 
					        UWord16   * pChar,
                            UWord16   Numchars );
	void    *pCallbackArg;
} dtmfdet_sCallback;


/*************************************************
     Structure for DTMF  receiver Configuration
**************************************************/

typedef struct
{
	UWord16             Flags;
	dtmfdet_sCallback   DTMFDetCallback;
}dtmfdet_sConfigure;

typedef struct
{
 Word16 *contextbuff;
 UWord16  length;
 dtmfdet_sCallback *pCallBck;
} dtmfdet_sHandle;
 
/***************************
 Function Prototypes
****************************/
EXPORT dtmfdet_sHandle *DTMFDetCreate (dtmfdet_sConfigure *pConfig);

EXPORT Result   DTMFDetInit (dtmfdet_sHandle        *pDTMFDet, 
				dtmfdet_sConfigure     *pConfig);

EXPORT Result   DTMFDetection   (dtmfdet_sHandle        *pDTMFDet, 
				Word16                  *pSamples, 
				UWord16                   NumberSamples);
												

EXPORT void     DTMFDetDestroy (dtmfdet_sHandle *pDTMFDet);


#endif
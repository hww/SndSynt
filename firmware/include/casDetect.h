/*********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
**********************************************************************
*
* File Name: casDetect.h
*
* Description: Contains the #define and the function prototypes for
*              CAS Detection.
*
* Modules Included: None
*
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

/* File: casDetect.h */

#ifndef __CASDETECT_H
#define __CASDETECT_H

/* 
   CPE Alerting Signal Detection interface
*/

/***************************
 Foundational Include Files
****************************/

#include "port.h"


/********************************************
 #define for CAS Detect flags, returns from 
    the CAS process function. CAS_PRESENT is 
    returned whenver valid CAS is detected 
    from the frame of 80 samples, otherwise
    CAS_NOT_PRESENT is returned.
*********************************************/

#define CAS_PRESENT      1 
#define CAS_NOT_PRESENT  0

/********************************************
     Structure for CAS Detect Configuration
*********************************************/

typedef struct
{
    Int16 *In_Context_buf;
    UInt16 context_buf_length;
}casDetect_sHandle;   

/***************************
 CAS Detect Function Prototypes
****************************/
 
EXPORT casDetect_sHandle * casDetectCreate (void);

EXPORT void casDetectInit (casDetect_sHandle * pCasDetect);

EXPORT Result casDetectProcess (casDetect_sHandle * pCasDetect,
                                Int16 *pSamples,
                                UInt16 NumSamples);
												
EXPORT void casDetectDestroy (casDetect_sHandle * pCasDetect);

#endif

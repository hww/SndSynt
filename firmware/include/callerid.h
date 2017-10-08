/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: callerid.h
*
* Description:     This include file is the master include file for the 
*                  CallerID receiver. The applications using CallerID
*                  receiver should include this file
*
* Modules Included:
*                   None
*
* Author : Meera S. P.
*
* Date   : 11 May 2000
*
*****************************************************************************/

#ifndef __CallerID_H
#define __CallerID_H


/***************************
 Foundational Include Files
****************************/

#include "port.h"

/*************************************************
 #define for CallerID receiver configuration flags
**************************************************/

#define  CALLERID_ONHOOK      0x0000
#define  CALLERID_OFFHOOK     0x0001

/* Status in the Callback procedure has the following bits */

#define  CALLERID_DATA_READY            0x0001 
#define  CALLERID_TIMEOUT               0x0002
#define  CALLERID_ERROR                 0x0004
#define  CALLERID_NO_TRANSMIT           0x0008
#define  CALLERID_CHECKSUM_ERROR        0x0010
#define  CALLERID_CSS_ERROR             0x0020 
#define  CALLERID_MARK_ERROR            0x0040
#define  CALLERID_LENGTH_ERROR          0x0080

/********************************************
     Commands for CallerID Control
*********************************************/

#define CALLERID_ACTIVATE    1
#define CALLERID_DEACTIVATE  2
#define CALLERID_STATUS      3    /* Returns CallerID Status */


/********************************************
     CallerID callback routine structure
*********************************************/

/* The status in the Callback routine below has 2 categories
   1. CALLERID_DATA_READY
   2. CALLERID_ERROR
   
   If the status is CALLERID_ERROR, the bit positions in the
   status represent the type of the error occured. 
   For example if there is CSS_ERROR (refer to the status bits
   defined above), the CALLERID_CSS_ERROR and the CALLERID_ERROR
   bits are set in the status.
   
 */ 
 
typedef struct
{
	void    (*pCallback) (  void    * pCallbackArg,
                            UWord16   Status, 
					        UWord16   * pChar,
                            UWord16   Numchars );
	void    * pCallbackArg;
} callerID_sCallback;



/*************************************************
     Structure for CallerID receiver Configuration
**************************************************/

typedef struct
{
	UWord16             Flags;
	callerID_sCallback  callerIDCallback;
} callerID_sConfigure;

/* This structure is not currently used; it
 * is given here for future use. */
typedef struct
{
   	UWord16             Flags;
} callerID_sHandle;




/***************************
 Function Prototypes
****************************/

EXPORT callerID_sHandle * callerIDCreate (  callerID_sConfigure * pConfig);

EXPORT Result   callerIDInit (  callerID_sHandle        * pCallerID, 
				callerID_sConfigure     * pConfig);

EXPORT Result   callerIDRX   (  callerID_sHandle        * pCallerID, 
				Word16                  * pSamples, 
				UWord16                   NumberSamples);
												

EXPORT void     callerIDDestroy ( callerID_sHandle * pCallerID);

EXPORT UWord16  callerIDControl( UWord16  Command);


#endif

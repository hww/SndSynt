/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: v8bis.h
*
* Description:  This include file is the master include file for the 
*               V.8bis function. The applications using V.8bis should
*               include this file.
*
* Modules Included:
*                   None
*
* Author : Prasad N. R.
*
* Date   : 03 Aug 2000
*
*****************************************************************************/

#ifndef __V8bis_H
#define __V8bis_H

/* 
   This include file is the master include file for the 
   V8bis protocol. The applications using v8bis should
   include this file
*/

/***************************
 Foundational Include Files
****************************/

#include "port.h"


/*************************
 Flags
 *************************/
 
 /* These are the flags returned by v8bisProcess()
  * function. Please refer Sec. 3.1.1.1.3 of the
  * V.8bis Library user manual for more details.
  */
  
 #define V8BIS_BUSY 0    
 #define V8BIS_FREE -1
 

/********************************************
     V8bis Message Types
*********************************************/

/* These are the inputs the user has to use during
 * the setting up of the V.8bis input buffer.
 * Please refer to:
 *    1. Appendix of the V.8bis Library User Manual (Sec. A.1).
 *    2. The test files of V.8bis: test_v8bisIS.c and test_v8bisRS.c
 */

#define  V8BIS_NIL_RX_HOST_MESSAGE            0x0000
#define  V8BIS_CONFIGURATION_MESSAGE          0x0001
#define  V8BIS_CAPABILITIES_MESSAGE           0x0002
#define  V8BIS_PRIORITIES_MESSAGE             0x0003
#define  V8BIS_REMOTE_CAPABILITIES_MESSAGE    0x0004
#define  V8BIS_TX_GAIN_FACTOR_MESSAGE         0x0007


/*******************
 Kind of station 
********************/
 
/* To be used by the user to configure V.8bis of
 * his end as either Initiating or Responding
 * station. Please refer test_v8bisIS.c or
 * test_v8bisRS.c for more details.
 */
     
typedef enum
{
    V8BIS_INIT_STATION,
    V8BIS_RESP_STATION,
} v8bis_eStation;


/*********************
 enums for host/user
**********************/
 
/* V8bis library returns one of the following messages
 * to the host followed by appropriate data. The host has
 * to use these, to check in his application, what type of
 * message is returned by V.8bis library, to take necessary
 * further action. Please refer to:
 *     1. Appendix of V.8bis Library User Manual (Sec. A.2).
 */
 
#define V8BIS_NIL_TX_HOST_MESSAGE             0x0000
#define V8BIS_ACK_MESSAGE                     0x0001
#define V8BIS_ERROR_MESSAGE                   0x0002
#define V8BIS_SUCCESS_INITIATE_HANDSHAKE      0x0003
#define V8BIS_SUCCESS_LOOK_FOR_HANDSHAKE      0x0004


/* These are the possible types of errors that the 
 * V.8bis library can return to the host, following the 
 * "V8BIS_ERROR_MESSAGE" message as defined above. The host
 * has to take appropriate action as per the error.
 */
 
#define V8BIS_NIL_ID                          0x0000
#define V8BIS_MODE_NOT_SUPPORTED              0x0001
#define V8BIS_RECEIVED_INVALID_MSG            0x0002
#define V8BIS_RECEIVED_NAK1_MSG               0x0003
#define V8BIS_TIMED_OUT                       0x0004
#define V8BIS_TRANSACTION_BEGUN               0x0005
#define V8BIS_INVALID_MSG_FORMAT              0x0006
#define V8BIS_RECEIVED_NAK2_Or_3_MSG          0x0007


/********************************************
     Structure for V8bis Capability List
*********************************************/

/* Receiver callback structure */

typedef struct
{
    void (*pCallback) (void *pCallbackArg,
                       Word16 *pChars,
                       UWord16 NumberChars);
    void *pCallbackArg;
} v8bis_sRXCallback;


/* Transmitter callback structure */

typedef struct
{
    void (*pCallback) (void *pCallbackArg,
                       Word16 *pSamples,
                       UWord16 NumberSamples);
    void *pCallbackArg;
} v8bis_sTXCallback;


/* User configurable structure. This is the format
 * in which the user can pass the parameters to V.8bis
 * library. Please see the test files: test_v8bisIS.c 
 * and test_v8bisRS.c for more details.
 */

typedef struct
{
    v8bis_eStation Station;        /* Station type */
    UWord16 *MessagePtr;           /* Input buffer pointer to V.8bis */
    v8bis_sTXCallback TXCallback;  /* Tx. Callback structure */
    v8bis_sRXCallback RXCallback;  /* Rx. Callback structure */
} v8bis_sConfigure;


/* V8bis handle structure. This is strictly for V.8bis
 * internal use only.
 */

typedef struct
{
    Word16 *Output;
    v8bis_eStation Station;
    UWord16 *MessagePtr;
    v8bis_sTXCallback *TXCallback;
    v8bis_sRXCallback *RXCallback;    
} v8bis_sHandle;


/***************************
 Function Prototypes
****************************/
 
EXPORT v8bis_sHandle *v8bisCreate (v8bis_sConfigure *pConfig);

EXPORT Result v8bisInit (v8bis_sHandle *pV8bis, v8bis_sConfigure *pConfig);

EXPORT Result v8bisProcess (v8bis_sHandle *pV8bis, 
                            Word16 *pSamples,
                            UWord16 NumSamples); 

EXPORT void v8bisDestroy (v8bis_sHandle *pV8bis);


#endif

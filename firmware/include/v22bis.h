/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: v22bis.h
*
* Description:  This include file is the master include file for the 
*               V22bis data pump. The applications using v22bis should
*               include this file
*
* Modules Included:
*                   None
*
* Author : Sanjay Karpoor
*
* Date   : 13 Sept 2000
*
*****************************************************************************/

#ifndef __V22bis_H
#define __V22bis_H


/***************************
 Foundational Include Files
****************************/

#include "port.h"

/********************************************
 #define for V22bis configuration flags
*********************************************/

#define  V22BIS_CALL_MODEM             0x0000
#define  V22BIS_ANSWER_MODEM           0x0001
#define  V22BIS_GUARD_TONE_ENABLE      0x0002
#define  V22BIS_GUARD_TONE_DISABLE     0x0000
#define  V22BIS_GUARD_TONE_550Hz       0x0000
#define  V22BIS_GUARD_TONE_1800Hz      0x0004
#define  V22BIS_SELF_RETRAIN_ENABLE    0x0008
#define  V22BIS_SELF_RETRAIN_DISABLE   0x0000
#define  V22BIS_V14_ENABLE_ASYNC_MODE  0x4000
#define  V22BIS_V14_DISABLE_ASYNC_MODE 0x0000
#define  V22BIS_LOOPBACK_ENABLE        0x8000
#define  V22BIS_LOOPBACK_DISABLE       0x0000

/********************************************
     Structure for V22bis Status
*********************************************/

typedef enum
{
      V22BIS_1200BPS_CONNECTION_ESTABLISHED,
      V22BIS_2400BPS_CONNECTION_ESTABLISHED,
      V22BIS_CONNECTION_LOST,
      V22BIS_DATA_AVAILABLE,
      V22BIS_RETRAINING
} v22bis_eStatus;
      

typedef struct
{
	void    (*pCallback) (  void           * pCallbackArg,
							v22bis_eStatus   Status, 
							char           * pBits, 
							UWord16          NumberBits);
	void    * pCallbackArg;
} v22bis_sRXCallback;

typedef struct
{
	void    (*pCallback) (  void           * pCallbackArg,
							v22bis_eStatus   Status, 
							Word16         * pSamples, 
							UWord16          NumberSamples);
	void    * pCallbackArg;
} v22bis_sTXCallback;


/* Please refer to the #defines above which go into
   Flags mentioned in the structure define below */
typedef struct
{
	UWord16             Flags;
	v22bis_sTXCallback  TXCallback;
	v22bis_sRXCallback  RXCallback;
} v22bis_sConfigure;

/* This structure is not currently used; it
 * is given here for future use. */
typedef struct
{
   	UWord16             Flags;
} v22bis_sHandle;

/********************************************
     Commands for V22bis Control
*********************************************/

#define V22BIS_ACTIVATE    1
#define V22BIS_DEACTIVATE  2


/***************************
 Function Prototypes
****************************/

EXPORT v22bis_sHandle * v22bisCreate ( v22bis_sConfigure * pConfig);
EXPORT Result           v22bisInit   ( v22bis_sHandle * pV22bis, 
                                       v22bis_sConfigure * pConfig);
EXPORT Result           v22bisTXDataInit ( v22bis_sHandle * pV22bis,
                                           char  * pBits,
                                           UWord16  NumBytes);
EXPORT Result           v22bisTX     (v22bis_sHandle * pV22bis);
												
EXPORT Result           v22bisRX     (	v22bis_sHandle * pV22bis,
                                        Word16  * pSamples, 
					                    UWord16 NumberSamples);
EXPORT Result           v22bisDestroy( v22bis_sHandle * pV22bis);
EXPORT Result           v22bisControl (UWord16  Command);


#endif

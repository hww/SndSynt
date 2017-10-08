/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         com.h
*
* Description:       Global parameters and functions for communication modulle
*
*****************************************************************************/
#if !defined(__COM_H)
#define __COM_H

/*****************************************************************************/
#define  COM_TIMEOUT_VALUE    ((UWord16)(ZCLOCK_FREQUENCY / 800000ul)* 10) 
#define  COM_TIMEOUT_INIT_SECOND ((UWord16)(ZCLOCK_FREQUENCY / 800000ul)* 500) 

/*****************************************************************************/
extern void comInit                     ( UWord16 InitTimeout );
extern void comMainLoop                 ( void );
extern void comExit                     ( void );
extern void comStopReceive              ( void );
extern void comResumeReceive            ( void );
extern void comRead                     ( UWord16 Length );
extern void comPrintString              ( UWord16 * pStr );
extern void comResetPeripheralRegisters ( void );
extern void comHex2String               ( UWord16 Data, char * pStr );

#endif /* !defined(__COM_H) */

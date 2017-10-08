/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         prog.h
*
* Description:       Global parameters and functions for programming module
*
*****************************************************************************/
#if !defined(__PROG_H)
#define __PROG_H

/*****************************************************************************/

extern void progSaveData   ( UWord16 * pData, UWord16 length, UWord16 Address, mem_eMemoryType MemoryType);
extern void progPlaceData  ( bool );
extern void progPlaceDelayValue ( void );

#define progFlush()        {  if ( progIndicatorCounter > 0 )     \
                              {  comPrintString((UWord16 *)StringBuffer);  }         \
                              progPlaceData(true);                \
                              progPlaceDelayValue();              \
                           }

#define progEnable()       {   progPlaceData(true);         \
                               comResumeReceive();    }

#define progInit() {/* all zero initialization is done in booArchStart() */}

extern UWord16 progProgCounter;
extern UWord16 progDataCounter;
extern UWord16 progIndicatorCounter;

#endif /* !defined(__PROG_H) */

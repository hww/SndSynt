/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         sparses.h
*
* Description:       Global parameters and functions for S record parser
*
*****************************************************************************/
#if !defined(__SPARSER_H)
#define __SPARSER_H

/*****************************************************************************/

#define SPRS_BUFFER_LEN  125

/*****************************************************************************/
extern void sprsInit    ( void );
extern void sprsReady   ( UWord16 * ReadBuffer, UWord16 ReadLength );

#endif /* !defined(__SPARSER_H) */

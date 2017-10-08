/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   testflash_target.h
*
* DESCRIPTION: header file that contains target specific information about
*              the flash memory map
*
*******************************************************************************/

#ifndef __TESTFLASH_TARGET_H
#define __TESTFLASH_TARGET_H 

#define FLASH_X_START_ADDR  0x1800
#define FLASH_X_SIZE        2048
#define FLASH_X_PAGES       8

#define FLASH_P_START_ADDR  0x0004
#define FLASH_P_SIZE        32252
#define FLASH_P_PAGES       126

#define FLASH_B_START_ADDR  0x8000
#define FLASH_B_SIZE        2048
#define FLASH_B_PAGES       8


#endif /* __TESTFLASH_TARGET_H */

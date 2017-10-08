/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         flashdrv.h
*
* Description:       Header file for the DSP5680x Flash driver
*
* Modules Included:  
*                    flashOpen()
*                    flashClose()
*                    flashRead()
*                    flashWrite()
*                    flashIoctl()
*                    flashDevCreate()
*                    flashGetCorrectSize()
*                    flashHWDisableISR()
*                    flashHWClearConfig()
*                    flashHWErase()
*                    flashHWErasePage()
*                    flashHWProgramWord()
*                    flashSetAddressMode()
*                    flashRestoreAddressMode()
* 
*****************************************************************************/


#ifndef FLASH56805_H
#define FLASH56805_H

#include "flash.h"
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifndef SDK_LIBRARY
   #include "configdefines.h"

   #ifndef INCLUDE_FLASH
      #error INCLUDE_FLASH must be defined in appconfig.h to initialize the FLASH Library
   #endif
#endif

/* if defined driver works with memory instead of Flash */
#undef FLASH_DBG_MEM         


#ifdef __cplusplus
}
#endif
                              
/* define memory buffers for FLASH_DBG_MEM test mode */

#if defined(FLASH_DBG_MEM)

extern UWord16 DataFlashBuffer[];
extern UWord16 ProgramFlashBuffer;
extern UWord16 BootFlashBuffer;

#endif /* defined(FLASH_DBG_MEM) */

/* Redefine ioctl calls to map to standard driver */
#define ioctlFLASH_RESET(FD,Cmd)           flashIoctl(FD, FLASH_RESET, Cmd)
#define ioctlFLASH_SET_VERIFY_ON(FD,Cmd)   flashIoctl(FD, FLASH_SET_VERIFY_ON, Cmd)
#define ioctlFLASH_SET_VERIFY_OFF(FD,Cmd)  flashIoctl(FD, FLASH_SET_VERIFY_OFF, Cmd)
#define ioctlFLASH_CMD_SEEK(FD,Cmd)        flashIoctl(FD, FLASH_CMD_SEEK, Cmd)
#define ioctlFLASH_SET_USER_X_DATA(FD,Cmd) flashIoctl(FD, FLASH_SET_USER_X_DATA, Cmd)
#define ioctlFLASH_SET_USER_P_DATA(FD,Cmd) flashIoctl(FD, FLASH_SET_USER_P_DATA, Cmd)
#define ioctlFLASH_CMD_ERASE_ALL(FD,Cmd)   flashIoctl(FD, FLASH_CMD_ERASE_ALL, Cmd)


#define FLASH_FIU_TIMER_NUMBER 9u

typedef struct  {
   const UWord16  * pDfiuInitTime;
   const UWord16  * pPfiuInitTime;
   const UWord16  * pBfiuInitTime;
} sFlashInitialize;


/*****************************************************************************/
/*                        Driver API definition                              */
/*****************************************************************************/

EXPORT io_sDriver * flashOpen(const char  * pName, int OFlags, ...);
EXPORT int          flashClose(int FileDesc);
EXPORT ssize_t      flashRead(int FileDesc, void * pBuffer, size_t NBytes);
EXPORT ssize_t      flashWrite(int FileDesc, const void * pBuffer, size_t Size);
EXPORT UWord16      flashIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...);


/*****************************************************************************
*
* Module:         flashDevCreate()   
*
* Description:    
*     The flashDevCreate() function creates DSP5680x Flash device driver 
*     by registering it with the ioLib library. Once the driver is registered, 
*     the Flash driver services are available for use by application
*     via ioLib and POSIX calls. To access installed Flash devices, user must 
*     use following names: BSP_DEVICE_NAME_FLASH_X, BSP_DEVICE_NAME_FLASH_P 
*     or BSP_DEVICE_NAME_FLASH_D.
*
* Returns:        
*     The function will return a value of zero.
*
* Arguments:      pFlashInitialize - pointer to initialization structure
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    flash.mcp, bootflash.mcp
*
*****************************************************************************/

EXPORT UWord16 flashDevCreate(const sFlashInitialize * pFlashInitialize);


/* it`s for mem.h */

/* #define memcmp(src1, src2, len)  memCmpXtoX(src1, src2, len) */

int      memCmpXtoX(const void * src1, const void * src2, size_t len);
int      memCmpXtoP(const void * src1, const void * src2, size_t len);
int      memCmpPtoX(const void * src1, const void * src2, size_t len);
int      memCmpPtoP(const void * src1, const void * src2, size_t len);

#define  memCopyXtoX(pDest,pSrc,Count) memcpy(pDest, pSrc, Count)

/* it`s for sys.h */

UWord16 archSetOperatingMode( UWord16 );



#ifdef __cplusplus
}
#endif


#endif

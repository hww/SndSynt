/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: fileio.h
*
*******************************************************************************/

#ifndef __FILEIO_H
#define __FILEIO_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_FILEIO
		#error INCLUDE_FILEIO must be defined in appconfig.h to initialize the FILEIO driver
	#endif
#endif


#include "port.h"

#include "port.h"
#include "io.h"
#include "fcntl.h"

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
*  The file i/o serves two purposes:
*  
*  1) To send data from the DSP to a file specified by the user.
*
*  2) To Receive data, from a file specified by the user, into the DSP.
* 
*  A write to a file from the DSP is done by the following:
* 
*  1)  Launch windows executable fileio.exe located at
*      src\x86\win32\applications\fileio\fileio.exe.
* 
*  2)  An "open" call is made.  For details see the "open" call.
*
*  3)  An "write" call is made.  For details see the "write" call.
*
*  4)  After all write operations are completed, the file is closed via a
*      "close" call.  For details see "close" call.
*
*  A read from a file into the DSP is done by the following:
*  
*  1)  Launch windows executable fileio.exe located at
*      src\x86\win32\applications\fileio\fileio.exe.
*
*  2)  An "open" call is made.  For details see the "open" call.
*
*  3)  An "read" call is made.  For details see the "read" call.
*
*  4)  After all read operations are completed, the file is closed via a
*      "close" call.  For details see "close" call.
*
*  The data format is defaulted to 8 bits and can be modified to 16 bits via
*  "ioctl" call.  For details see "ioctl" call.
*
******************************************************************************/

/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, ...);
*
* Semantics:
*     Opens a particular file for read/write operations. Argument pName is
*     the particular file name. A specific file needs to be opened before
*     read/write calls.
*
* Parameters:
*     pName    - device name.       Use "\\\\PC\\specificdrive\\yourfile.txt" 
*                                   or use "\\\\PC\\Embedded SDK\\yourfile.txt"
*
*     OFlags   - open mode flags.   Use O_RDONLY for a read operation
*                                   Use O_WRONLY for a write operation
* Return Value: 
*     File descriptor if open is successful.
*     -1 value if open failed.
* Examples:
*   // Opens file c:\test.txt for write operations
*   int FileIOFd; 
* 
*   FileIOFd  = open("\\\\PC\\c\\test.txt", O_WRONLY);
*    
*   // Will find registry path at:
*   // HKEY_LOCAL_MACHINE\SOFTWARE\MOTOROLA\Embedded SDK\ and open yourfile.txt
*   // at this location for write operations.
*   int FileIOFd; 
*
*   FileIOFd  = open("\\\\PC\\Embedded SDK\\yourfile.txt", O_WRONLY);
*
* Re-entrance: 
*     NOT for main interface 
*     NOT as a rule for alternative interface
*     
*
*****************************************************************************/


/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*     Change File I/O device data format. The File I/O driver supports the 
*     following commands:
*
*	  FILE_IO_DATAFORMAT_RAW           Data format will be set to 16 bits.
*                                  
*     FILE_IO_DATAFORMAT_EIGHTBITCHARS Data format will be set to 8 bits.
*
*
* If pParams is not used then NULL should be passed into function.
*
* Parameters:
*     FileDesc    - File I/O Device descriptor returned by "open" call.
*     Cmd         - Command for driver 
*     pParam      - NULL
* Return Value: 
*     Zero 
*
* Example:
*
*     // change File I/O's data format to 16 bits
*     ioctl(FileIOFd, FILE_IO_DATAFORMAT_RAW, NULL); 
*
* Re-entrance: 
*     NOT for main interface 
*     YES as a rule for alternative inline interface
*     The list of re-entrant statements:
*     
*
*
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Writes user buffer to a specified file.     
*
* Parameters:
*     FileDesc    - File descriptor returned by "open" call.  Where buffer 
*                   we be written.
*     pBuffer     - pointer to user buffer. 
*     Size        - number of words to be written to the file. 
*
* Return Value: 
*     - Actual number of written words.
*
* Re-entrance: 
*     NOT for main interface 
*     NOT as a rule for alternative interface
*
*****************************************************************************/

/*****************************************************************************
*
* READ
*
*     ssize_t read(int FileDesc, void * pBuffer, size_t Size);
*
* Semantics:
*     Reads data from a specified file.
*
* Parameters:
*     FileDesc    - File descriptor returned by "open" call.  Where data is
*                   read from.
*     pBuffer     - pointer to user buffer. 
*     Size        - number of words to be read from specified file. 
*
* Return Value: 
*     - Actual number of read words.
*
* Re-entrance: 
*     NOT for main interface 
*     NOT as a rule for alternative interface
*
*****************************************************************************/

/*****************************************************************************
*
* CLOSE
*
*     int close(int FileDesc);  
*
* Semantics:
*     Close port device.
*
* Parameters:
*     FileDesc    - File descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
* Re-entrance: 
*     NOT for main interface 
*
*****************************************************************************/

/* IOCTL Commands */
#define FILE_IO_DATAFORMAT_EIGHTBITCHARS 1
#define FILE_IO_DATAFORMAT_RAW           2
#define FILE_IO_GET_SIZE           		 3
#define FILE_IO_LOC						 4

#ifdef __cplusplus
}
#endif


#include  "fileiodrv.h"

										
#endif

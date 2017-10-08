/*****************************************************************************
*
* fcntl.h - standard header 
*
*****************************************************************************/

#ifndef __FCNTL_H
#define __FCNTL_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/* values for OFlags */

#define O_RDONLY   0x0001 
#define O_WRONLY   0x0002
#define O_RDWR     0x0003
#define O_NONBLOCK 0x0008 /* non blocking I/O */

/* values for Cmd */

#define F_SETFL    0x0005 /* set file status flags */

/*****************************************************************************
*
* FCNTL
*
* Implementation Status:
*     PARTIAL IMPLEMENTATION
*
* Semantics:
*     The function fcntl() provides for control over open files. The argument
*     FileDesc is a file descriptor. The available values for Cmd are defined
*     in this file and listed below.
*
*          F_SETFL  Set the file status flags for the open file description
*                   associated with FileDesc from the corresponding bits
*                   in the third argument, arg, taken as type int.
*
* Return Value: 
*     Upon successful completion, the value returned will depend on Cmd. The
*     various return values are shown below.
*
*          F_SETFL  Returns 0 if the call succeeds. Otherwise, it will return
*                   -1 and errno will be set to indicate the error.
*****************************************************************************/

EXPORT int fcntl(int FileDesc, int Cmd, ...);

/*****************************************************************************
*
* OPEN
*
* Implementation Status:
*     NOT IMPLEMENTED
*
* Semantics:
*     The open() function establishes the connection between a file and a
*     file descriptor. It creates an open file description that refers to a
*     file and a file descriptor that refers to that file description. The
*     file descriptor is used by other I/O functions to refer to that file.
*
*     The pName argument points to a pathname naming a device or file.  
*     Refer to the header file bsp.h for a list of names which refer to 
*     devices suitable for the "open" function in your particular environment.
*
*     The value of OFlags is the bitwise inclusive OR of values from the 
*     following list:
*
*          O_NONBLOCK The open() will return without waiting for the device
*                     to be ready or available. Subsequent behavior of the
*                     device is device-specific.
*                     If O_NONBLOCK is clear, the open() will block the 
*                     calling thread until the device is ready or available 
*                     before returning (O_NONBLOCK is clear by default).
*
* Return Value: 
*     Upon successful completion, the function will open the file and return
*     a nonnegative integer representing the file descriptor. Otherwise,
*     it will return -1 and errno will be set to indicate the error.
*
*****************************************************************************/

EXPORT int open(const char *pName, int OFlags, ...);


#ifdef __cplusplus
}
#endif

#endif

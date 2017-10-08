/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: led.h
*
*******************************************************************************/
#ifndef __LED_H
#define __LED_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_LED
		#error INCLUDE_LED must be defined in appconfig.h to initialize the LED driver
	#endif
#endif

#include "port.h"
#include "bsp.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_LED)
	#include "io.h"
	#include "fcntl.h"
#endif


#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      LED Interface Description
*
*  The LED interface manipulates the light emitting diodes. 
*  
******************************************************************************/

/******************************************************************************
*
*  LED Interfaces
* 
*     The LED interface can be used at two alternative levels, a low level
*     LED driver interface and the common IO layer interface.  The common IO 
*     layer interface invokes the lower level LED driver interface. 
*
*     The low level LED driver provides a non-standard interface that is
*     potentially more efficient that the IO layer calls, but less portable.  
*     The IO layer calls to the LED interface are standard and more 
*     portable than the low level LED interface, but potentially less efficient.
*    
*     Your application may use either the low level LED driver interface or
*     the IO layer interface to the LED driver, depending on your specific
*     goals for efficiency and portability.
*
*     The low level LED driver interface defines functions as follows:
*  
*          int  ledOpen  (const char *pName, int OFlags);
*          void ledIoctl (int FileDesc, UWord16 Cmd, UWord16 led, const char * ledDevice); 
*          int  ledClose (int FileDesc);  
*
*     The IO layer interface defines functions as follows:
*
*          int     open  (const char *pName, int OFlags, ...);
*          UWord16 ioctl (int FileDesc, UWord16 Cmd, void * pParams);      
*          int     close (int FileDesc);  
*
******************************************************************************/

/*****************************************************************************
*
* LOW LEVEL LED DRIVER INTERFACE
*
*   General Description:
*
*      The Low Level LED Driver is configured by the following:
*  
*         1)  The device is created and initialized by selecting it through defining the 
*             INCLUDE_LED variable in the appconfig.h file associated with the SDK Embedded 
*             Project created in CodeWarrior. 
*
*         2)  An "ledOpen" call is made to open the LED device
*
*         3)  The LED device is configured via "ledIoctl" calls.
*             See "ledIoctl" call below.
*
*         4)  After all LED operations are completed, the LED device
*             is closed via a "ledClose" call.
*
*
*   ledOpen
*
*      int ledOpen(const char *pName,0);
*
*         Semantics:
*            Opens a particular LED device. Argument pName is the 
*            particular device name. The LED device needs to be opened before
*            configuring the port with ledIoctl calls.
*
*         Parameters:
*            pName    - device name. See bsp.h for device names specific to this 
*                       platform.  Typically, the LED device name is
*                          BSP_DEVICE_NAME_LED_0
*
*            OFlags   - open mode flags. Ignored. 
* 
*         Return Value: 
*            Port file descriptor if open is successful.
*            -1 value if open failed.
*     
*         Example:
*
*            int ledFD; 
* 
*            ledFD = ledOpen(BSP_DEVICE_NAME_LED_0,0);
*
*
*   ledIoctl
*
*      void ledIoctl (int FileDesc, UWord16 Cmd, UWord16 led, const char * ledDevice); 
*
*         Semantics:
*            Modify LED port configuration or set/reset an LED
*
*         Parameters:
*            FileDesc  - The value returned by the ledOpen call
*
*            Cmd       - command for driver ioctl command;  these commands
*                        are listed in the description of the IO Layer ioctl 
*                        interface
*
*            led       - pin on which to perform the command, denoted as 
*                        LED_RED, LED_GREEN, LED_YELLOW
*
*            ledDevice - the LED device name from bsp.h;  typically,
*                        BSP_DEVICE_NAME_LED_0
*
*         Return Value: 
*            void 
*
*         Example:
*
*            // Turn the Red LED on
*            ledIoctl(ledFD, LED_ON, LED_RED, BSP_DEVICE_NAME_LED_0); 
*     
*            // Toggle the Green LED 
*            ledIoctl(ledFD, LED_TOGGLE, LED_GREEN, BSP_DEVICE_NAME_LED_0); 
*     
*   ledClose
*
*      int ledClose(int FileDesc);  
*
*         Semantics:
*            Close LED device.
*  
*         Parameters:
*            FileDesc    - File descriptor returned by "open" call.
*
*         Example:
*
*            // Close the LED driver 
*            ledClose(PortA); 
* 
*         Return Value: 
*            Zero
*
*****************************************************************************/


/*****************************************************************************
* 
* IO Layer Interface to the LED Driver
*
*   General Description:
*
*      A LED device is configured by the following:
*  
*  		  1)  The device is created and initialized by selecting it by defining
*             both the INCLUDE_LED variable and the INCLUDE_IO variable in the 
*             appconfig.h file associated with the SDK Embedded Project created 
*             in CodeWarrior. 
*
*         2)  An "open" call is made to initialize the LED device
*
*         3)  The LEDs are configured via "ioctl" calls.
*             See "IOCTL" call below.
*
*         4)  After all LED operations are completed, the LED device
*             is closed via a "close" call.
*
*
*
*   OPEN
*
*      int open(const char *pName, int OFlags, ...);
*
*         Semantics:
*            Opens the LED driver for operation. Argument pName is the name of 
*            a particular bank of LEDs;  see the bsp.h file for specific device name
*            definitions. The LED driver needs to be 'open'ed before
*            configuring the LED with IOCTL calls.
*
*         Parameters:
*            pName    - device name. See the bsp.h file for LED names, which
*                    are typically:
*                       BSP_DEVICE_NAME_LED_0
*
*            OFlags   - open mode flags. Ignored. 
* 
*         Return Value: 
*            If open is successful, a file descriptor is returned.  This file
*            descriptor is used in subsequent calls to ioctl and close. 
*
*            If open is unsuccessful, a -1 value is returned.
*     
*         Example:
*
*            int LedFD; 
* 
*            LedFD = open(BSP_DEVICE_NAME_LED_0, 0);
*
*
*   IOCTL
*
*      UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
*         Semantics:
*            Modify LED state. The LED ioctl call supports the following commands:
*
*               LED_OFF      -  Turn the LED off
*
*               LED_ON       -  Turn the LED on
*
*               LED_TOGGLE   -  Toggle the state of the LED
*
*            The pParams must be set to the following led designations:
*               LED_RED
*               LED_YELLOW
*               LED_GREEN
*            or other LED defined in the specific driver for this board
*               (see leddrv.h)
*
*        Parameters:
*           FileDesc    - Flash Device descriptor returned by "open" call.
*           Cmd         - command for driver 
*           pParam      - NULL
*
*        Return Value: 
*           Although the ioctl function is specified to return a UWord16 value, 
*           this return value is not returned by this driver and should not be 
*           checked by the application.  
*
*        Example:
*
*           // Turn the Red LED on
*           ioctl(LedFD, LED_ON, LED_RED); 
*     
*           // Toggle the Green LED 
*           ioctl(LedFD, LED_TOGGLE, LED_GREEN); 
*     
*
*   CLOSE
*
*      int close(int FileDesc);  
*
*         Semantics:
*            Close flash device.
*
*         Parameters:
*            FileDesc    - File descriptor returned by "open" call.
*
*         Return Value: 
*            Zero
*
*         Example:
*
*            // Close the LED driver
*            close(LedFD); 
*
*****************************************************************************/


		
/*********************************************************************
* The driver file is included at the end of this public include
* file instead of the beginning to avoid circular dependency problems.
**********************************************************************/ 
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_LED)
	#include "leddrvIO.h"
#endif

#include "leddrv.h"
								

#ifdef __cplusplus
}
#endif
										
#endif

/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: button.h
*
*******************************************************************************/
#ifndef __BUTTON_H
#define __BUTTON_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_BUTTON
		#error INCLUDE_BUTTON must be defined in appconfig.h to initialize the BUTTON driver
	#endif
#endif


#include "port.h"
#include "bsp.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_BUTTON)
	#include "io.h"
	#include "fcntl.h"
#endif



#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      Button Interface Description
*
*  The Button driver handles buttons on the EVM board.  The driver debounces
*  the button and calls the user's callback procedure when the button is pressed. 
*
******************************************************************************/


typedef void (*button_tCallback)(void *pCallbackArg);

typedef struct
{
	button_tCallback  pCallback;
	void             *pCallbackArg;
}button_sCallback;


/******************************************************************************
*
*  BUTTON Interfaces
* 
*     The BUTTON interface can be used at two alternative levels, a low level
*     BUTTON driver interface and the common IO layer interface.  The common IO 
*     layer interface invokes the lower level BUTTON driver interface. 
*
*     The low level BUTTON driver provides a non-standard interface that is
*     potentially more efficient that the IO layer calls, but less portable.  
*     The IO layer calls to the BUTTON interface are standard and more 
*     portable than the low level BUTTON interface, but potentially less efficient.
*    
*     Your application may use either the low level BUTTON driver interface or
*     the IO layer interface to the BUTTON driver, depending on your specific
*     goals for efficiency and portability.
*
*     The low level BUTTON driver interface defines functions as follows:
*  
*          int  buttonOpen  (const char *pName, int OFlags, button_sCallback * pCallbackParam);
*          int  buttonClose (int FileDesc);  
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
* LOW LEVEL BUTTON DRIVER INTERFACE
*
*   General Description:
*
*      The Low Level BUTTON Driver is configured by the following:
*  
*         1)  The device is created and initialized by selecting it through defining the 
*             INCLUDE_BUTTON variable in the appconfig.h file associated with the SDK Embedded 
*             Project created in CodeWarrior. 
*
*         2)  An "buttonOpen" call is made to open the BUTTON device
*
*         3)  The Button driver calls the user's callback functions when buttons are pressed
*
*         4)  After all BUTTON operations are completed, the BUTTON device
*             is closed via a "buttonClose" call.
*
*
*   buttonOpen
*
*      int buttonOpen(const char *pName, int OFlags, button_sCallback * pCallbackParam);
*
*         Semantics:
*            Opens a particular BUTTON device. Argument pName is the 
*            particular device name.  The pCallbackParam specifies which user function
*            to call when the button is pressed.
*
*         Parameters:
*            pName    - device name. See bsp.h for device names specific to this 
*                       platform.  Typically, the BUTTON device name is
*                          BSP_DEVICE_NAME_BUTTON_A
*                          BSP_DEVICE_NAME_BUTTON_B
*            OFlags   - General parameter to configure the button driver;  however,
*                       this parameter is not used at this time.
*            pCallbackParam - A pointer to a structure which specifies a function
*                       to call when the button is pressed.  This structure contains
*                       two values:  the address of the function to be called and
*                       the value of the parameter to that function.  The 
*                       parameter value can be used in the function for purposes
*                       such as designating which button was pressed, or refer to 
*                       an application specific structure which must be modified by 
*                       the callback function.
*
*         Return Value: 
*            File descriptor if open is successful.  This file descriptor must be
*            passed to other Button driver functions.
*            -1 value if open failed.
*     
*         Example:
*
*            void ButtonFunc (void *pCallbackArg)
*            {  volatile int * pCounter = (volatile int *)pCallbackArg;
*            
*               (*pCounter)++;
*            }
*
*
*            volatile int buttonAcounter;
* 
*            void main (void)
*            {
*
*               int buttonFD; 
*               button_sCallback ButtonACallbackSpec = {ButtonFunc, (void*) &buttonAcounter};
*
*               buttonFD = buttonOpen(BSP_DEVICE_NAME_BUTTON_A, 0, (void *)&ButtonACallbackSpec);
*               ...
*            }
*     
*   buttonClose
*
*      int buttonClose(int FileDesc);  
*
*         Semantics:
*            Close BUTTON device.
*  
*         Parameters:
*            FileDesc    - File descriptor returned by "buttonOpen" call.
*
*         Example:
*
*            // Close the BUTTON driver 
*            buttonClose(buttonFD); 
* 
*         Return Value: 
*            Zero
*
*****************************************************************************/


/*****************************************************************************
* 
* IO Layer Interface to the BUTTON Driver
*
*   General Description:
*
*      A BUTTON device is configured by the following:
*  
*  		  1)  The device is created and initialized by selecting it by defining
*             both the INCLUDE_BUTTON variable and the INCLUDE_IO variable in the 
*             appconfig.h file associated with the SDK Embedded Project created 
*             in CodeWarrior. 
*
*         2)  An "open" call is made to initialize the BUTTON device
*
*         3)  The Button driver calls the user's callback function when the
*             button is pressed.
*
*         4)  After all BUTTON operations are completed, the BUTTON device
*             is closed via a "close" call.
*
*
*
* 
*   OPEN
*
*      int open(const char *pName, int OFlags, button_sCallback * pCallbackSpec);
*
*         Semantics:
*            Opens the Buttons driver for operation. Argument pName is the name of 
*            the particular button;  see the bsp.h file for specific device name
*            definitions.  pCallbackSpec specifies the callback procedure to be 
*            called when the button is pressed. 
*
*
*         Parameters:
*            pName    - device name. See the bsp.h file for Button names, which
*                       are typically:
*                          BSP_DEVICE_NAME_BUTTON_A
*                          BSP_DEVICE_NAME_BUTTON_B
*
*            OFlags   - open mode flags. Ignored. 
*
*            pCallbackSpec - pointer to the button_sCallback structure which 
*                     specifies the procedure to be called when the button
*                     is pressed.  This structure contains
*                     two values:  the address of the function to be called and
*                     the value of the parameter to that function.  The 
*                     parameter value can be used in the function for purposes
*                     such as designating which button was pressed, or refer to 
*                     an application specific structure which must be modified by 
*                     the callback function.
* 
*         Return Value: 
*            If open is successful, a file descriptor is returned.  This file
*            descriptor is used in subsequent calls to close. 
*
*            If open is unsuccessful, a -1 value is returned.
*     
*         Example:
*
*            void ButtonFunc (void *pCallbackArg)
*            {  volatile int * pCounter = (volatile int *)pCallbackArg;
*            
*               (*pCounter)++;
*            }
*
*
*            volatile int buttonAcounter;
* 
*            void main (void)
*            {
*               int buttonFD; 
*               button_sCallback ButtonACallbackSpec = {ButtonFunc, (void*) &buttonAcounter};
*
*               buttonFD = open(BSP_DEVICE_NAME_BUTTON_A, 0, (void *)&ButtonACallbackSpec);
*               ...
*            }
*
*
*   IOCTL
*
*      UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
*         Semantics:
*            N/A -- Not used for the Button driver.
*
*         Parameters:
*            FileDesc    - Device descriptor returned by "open" call.
*            Cmd         - command for driver 
*            pParam      - command dependent parameter
*
*         Return Value: 
*
*            Although the ioctl function is specified to return a UWord16 value, 
*            this return value should not be checked by the application unless
*            the specific Cmd returns a non-NULL value.  
*
*         Example:
*
*            N/A 
*     
*
*   CLOSE
*
*      int close(int FileDesc);  
*
*         Semantics:
*            Close the Button driver.
*
*         Parameters:
*            FileDesc    - File descriptor returned by "open" call.
*
*         Return Value: 
*            Zero
*
*         Example:
*
*            // Close the Buttons driver
*            close(ButtonFD); 
*
*****************************************************************************/


		
/*********************************************************************
* The driver file is included at the end of this public include
* file instead of the beginning to avoid circular dependency problems.
**********************************************************************/ 
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_BUTTON)
	#include "buttondrvIO.h"
#endif

#include "buttondrv.h"
								



#ifdef __cplusplus
}
#endif
										
#endif

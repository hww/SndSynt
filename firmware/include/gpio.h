/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: gpio.h
*
*******************************************************************************/
#ifndef __GPIO_H
#define __GPIO_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_GPIO
		#error INCLUDE_GPIO must be defined in appconfig.h to initialize the GPIO driver
	#endif
#endif


#include "port.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_GPIO)
	#include "io.h"
	#include "fcntl.h"
#endif


#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
*  The General Purpose I/O interface manipulates external signals routed through
*  general purpose pins.  Typically, each pin may be may be programmed as an input, 
*  output, or level sensitive interrupt input.  However, peripherals may share
*  control of these general purpose I/O pins;  you may not use a pin for both a
*  peripheral and as a general purpose I/O pin.  Therefore, please consult the
*  appropriate technical reference to determine which pins are assigned to 
*  peripherals that you will use, and which pins may be available for general
*  purpose use. 
*  
*  The design of the general purpose I/O interface organizes pins according to
*  "ports".  Typically, each port has eight I/O pins. 
*  
******************************************************************************/

/******************************************************************************
*
*  GPIO Interfaces
* 
*     The GPIO interface can be used at two alternative levels, a low level
*     GPIO driver interface and the common IO layer interface.  The common IO 
*     layer interface invokes the lower level GPIO driver interface. 
*
*     The low level GPIO driver provides a non-standard interface that is
*     potentially more efficient that the IO layer calls, but less portable.  
*     The IO layer calls to the GPIO interface are standard and more 
*     portable than the low level GPIO interface, but potentially less efficient.
*    
*     Your application may use either the low level GPIO driver interface or
*     the IO layer interface to the GPIO driver, depending on your specific
*     goals for efficiency and portability.
*
*     The low level GPIO driver interface defines functions as follows:
*  
*          int gpioOpen  (const char *pName, int OFlags);
*          int gpioIoctl (int FileDesc, UWord16 Cmd, UWord16 Pin, const char * gpioDevice); 
*          int gpioClose (int FileDesc);  
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
* LOW LEVEL GPIO DRIVER INTERFACE
*
*   General Description:
*
*      The Low Level GPIO Driver is configured by the following:
*  
*         1)  The device is created and initialized by selecting it through defining the 
*             INCLUDE_GPIO variable in the appconfig.h file associated with the SDK Embedded 
*             Project created in CodeWarrior. 
*
*         2)  An "gpioOpen" call is made to open communications with the GPIO Port
*
*         3)  The GPIO port is configured via "gpioIoctl" calls.
*             See "gpioIoctl" call below.
*
*         4)  After all GPIO operations are completed, the GPIO peripheral
*             is closed via a "gpioClose" call.
*
*
*   gpioOpen
*
*      int gpioOpen(const char *pName);
*
*         Semantics:
*            Opens a particular port for operations. Argument pName is the 
*            particular port name. A particular port needs to be opened before
*            configuring the port with gpioIoctl calls.
*
*         Parameters:
*            pName    - device name. See bsp.h for device names specific to this 
*                       platform.  Typically, the GPIO device name is
*                          BSP_DEVICE_NAME_GPIO_A
*                          BSP_DEVICE_NAME_GPIO_B
*                          BSP_DEVICE_NAME_GPIO_D
*                          BSP_DEVICE_NAME_GPIO_E
* 
*         Return Value: 
*            Port file descriptor if open is successful.
*            -1 value if open failed.
*     
*         Example:
*
*            int PortA; 
* 
*            PortA = gpioOpen(BSP_DEVICE_NAME_GPIO_A);
*
*
*   gpioIoctl
*
*      int gpioIoctl (int FileDesc, UWord16 Cmd, UWord16 Params, const char * gpioDevice); 
*
*         Semantics:
*            Modify GPIO port configuration or set a GPIO signal.
*
*         Parameters:
*            FileDesc    - The file description returned by the gpioOpen call
*
*            Cmd         - command for driver ioctl command;  these commands
*                          are listed in the description of the IO Layer ioctl 
*                      interface
*
*            Params      - The Params is used to pass on a particular pin on a port in which to perform
*                          one of the above commands.  The gpioPin macro defined below is used to obtain
*                          a mask for that particular pin and port.  
*
*            gpioDevice  - The GPIO device defined in bsp.h
*
*         Return Value: 
*            Integer value returned by the gpioIoctl call.  
*
*            The only gpioIoctl command which currently returns a value (0 or 1) 
*            is GPIO_READ. 
*
*         Example:
*
*            // disable peripheral as the master of bit 0 on port A
*            gpioIoctl (PortA, GPIO_SETAS_GPIO, gpioPin(A, 0), BSP_DEVICE_NAME_GPIO_A); 
*     
*            // set bit 3 on port B as an output pin
*            gpioIoctl (PortB, GPIO_SETAS_OUTPUT, gpioPin(B, 3), BSP_DEVICE_NAME_GPIO_B);
*
*            // read the state of port D pin 5
*            state = gpioIoctl (PortD, GPIO_READ, gpioPin(D, 5), BSP_DEVICE_NAME_GPIO_D);  
*
*     
*   gpioClose
*
*      int gpioClose(int FileDesc);  
*
*         Semantics:
*            Close GPIO device.
*  
*         Parameters:
*            FileDesc    - Port file descriptor returned by "open" call.
*
*         Example:
*
*            // Close the GPIO driver on a specific port
*            gpioClose(PortA); 
* 
*         Return Value: 
*            Zero
*
*****************************************************************************/


/*****************************************************************************
* 
* IO Layer Interface to the GPIO Driver
*
*   General Description:
*
*      A GPIO port is configured by the following:
*  
*  		  1)  The device is created and initialized by selecting it by defining
*             both the INCLUDE_GPIO variable and the INCLUDE_IO variable in the 
*             appconfig.h file associated with the SDK Embedded Project created 
*             in CodeWarrior. 
*
*         2)  An "open" call is made to open communications with the GPIO Port
*
*         3)  The GPIO port is configured via "ioctl" calls.
*             See "IOCTL" call below.
*
*         4)  After all GPIO operations are completed, the GPIO peripheral
*             is closed via a "close" call.
*
*
*   OPEN
*
*      int open(const char *pName, int OFlags, ...);
*
*         Semantics:
*            Opens a particular port for operations. Argument pName is the 
*            particular port name. A particular port needs to be opened before
*            configuring the port with IOCTL calls.
*
*         Parameters:
*            pName    - device name. See bsp.h for device names specific to this 
*                       platform.  Typically, the GPIO device name is
*                          BSP_DEVICE_NAME_GPIO_A
*                          BSP_DEVICE_NAME_GPIO_B
*                          BSP_DEVICE_NAME_GPIO_D
*                          BSP_DEVICE_NAME_GPIO_E
*
*            OFlags   - open mode flags. Ignored. 
* 
*         Return Value: 
*            Port file descriptor if open is successful.
*            -1 value if open failed.
*     
*         Example:
*
*            int PortA; 
* 
*            PortA = open(BSP_DEVICE_NAME_GPIO_A, 0, NULL);
*
*
*   IOCTL
*
*      UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
*         Semantics:
*            Modify port configuration. GPIO driver supports the following commands:
*
*               GPIO_SETAS_GPIO                      When peripheral disabled DDR determines 
*                                                    direction of data flow in PER register

*               GPIO_SETAS_PERIPHERAL                A peripheral masters the gpio pin, in PER
*                                                    register
 
*               GPIO_SETAS_INPUT                     Sets a gpio pin as an input, in DDR register
*
*               GPIO_SETAS_OUTPUT                    Sets a gpio pin as an output, in DDR register
*
*               GPIO_INTERRUPT_DISABLE               Disables edge detection for any incoming
*                                                       interrupt, in IENR register.
*
*               GPIO_INTERRUPT_ENABLE                Enables edge detection for any incoming 
*                                                    interrupt, in IENR register.
*  
*               GPIO_DISABLE_PULLUP	                 Disable pull-up, in PUR register
*
*               GPIO_ENABLE_PULLUP                   Enable pull-up, in PUR register
*  
*               GPIO_INTERRUPT_ASSERT_DISABLE        Disables an interrupt assert, in IAR register  
*
*               GPIO_INTERRUPT_ASSERT_ENABLE         Enables an interrupt assert, used only
*                                                    in software testing, in IAR register
*
*               GPIO_INTERRUPT_DETECTION_ACTIVE_HIGH The interrupt seen at the PAD is active high
*
*               GPIO_INTERRUPT_DETECTION_ACTIVE_LOW  The interrupt seen at the PAD is active low 
*
*               GPIO_CLEAR_INTERRUPT_PEND_REGISTER   By writing zeros to this register the IPR is
*                                                    cleared
*
*               GPIO_SET                             Sets a GPIO signal
*
*               GPIO_CLEAR                           Clears a GPIO signal
*
*               GPIO_TOGGLE                          Toggles a GPIO signal 
*
*               GPIO_READ                            Reads the value of an input pin;
*                                                    returns 0 or 1 for the value 
*  
*            The pParams is used to pass on a particular pin on a port in which to perform
*            one of the above commands.  The gpioPin macro defined below is used to obtain
*            a mask for that particular pin and port.  
*
*         Parameters:
*            FileDesc    - GPIO Device descriptor returned by "open" call.
*            Cmd         - command for driver 
*            pParam      - pin on which to perform the command
*
*         Return Value: 
*            Integer value returned by the ioctl call.  
*
*            The only ioctl command which currently returns a value (0 or 1) 
*            is GPIO_READ. 
*
*         Example:
*
*            // disable peripheral as the master of bit 0 on port A
*            ioctl(PortA, GPIO_SETAS_GPIO, gpioPin(A,0)); 
*     
*            // set bit 2 on port D as an output pin
*            ioctl(PortD, GPIO_SETAS_OUTPUT, gpioPin(D,2)); 
*     
*            // read bit 7 on port B
*            state = ioctl(PortB, GPIO_READ, gpioPin(B,7));
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
*            FileDesc    - Port file descriptor returned by "open" call.
*
*         Example:
*
*            // Close the GPIO driver on a specific port
*            close(PortA); 
* 
*         Return Value: 
*            Zero
*
*****************************************************************************/

/*****************************************************************************
*
*  Macro used to define GPIO pins to be used by the ioctl functions. 
*
*  Example:  gpioPin(A,0)
*
*****************************************************************************/

#define gpioPin(Port,Bit) (((int)(GPIOPORT_##Port) << 4) | ((1 << Bit)&0x00FF))



/* ioctl commands */
#define GPIO_SETAS_GPIO                      0
#define GPIO_SETAS_PERIPHERAL                1
#define GPIO_SETAS_INPUT                     2
#define GPIO_SETAS_OUTPUT                    3
#define GPIO_INTERRUPT_DISABLE               4
#define GPIO_INTERRUPT_ENABLE                5
#define GPIO_DISABLE_PULLUP	                 6
#define GPIO_ENABLE_PULLUP                   7
#define GPIO_INTERRUPT_ASSERT_DISABLE        8
#define GPIO_INTERRUPT_ASSERT_ENABLE         9
#define GPIO_INTERRUPT_DETECTION_ACTIVE_HIGH 10
#define GPIO_INTERRUPT_DETECTION_ACTIVE_LOW  11
#define GPIO_CLEAR_INTERRUPT_PEND_REGISTER   12
#define GPIO_SET                             13
#define GPIO_CLEAR                           14
#define GPIO_TOGGLE                          15
#define GPIO_READ                            16

#ifdef __cplusplus
}
#endif
		
/*********************************************************************
* The driver file is included at the end of this public include
* file instead of the beginning to avoid circular dependency problems.
**********************************************************************/ 
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_GPIO)
	#include "gpiodrvIO.h"
#endif

#include "gpiodrv.h"
								
#endif

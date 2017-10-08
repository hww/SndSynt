/*****************************************************************************
*
* giopdrv.h - header file for the general purpose IO driver.
*
*  The DSP56805 processor has four general purpose I/O ports:
*     Port A which is located in memory space from 0x11B0 - 0x11BF
*     Port B which is located in memory space from 0x11C0 - 0x11CF
*     Port D which is located in memory space from 0x11E0 - 0x11EF
*     Port E which is located in memory space from 0x11F0 - 0x11FF
*  
*  Each Port is comprised of six registers.  GIOP registers are placed on 
*  the chip in groups of eight bits. They are as follows:
*
*  1) GPIO_Pull-Up Enable Register (PUR): This is a read/write register.
*     The PUR is for pull-up enabling, PUR set to one, and disabling, PUR
*     set to 0.
*     (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*      more details)
*
*  2) Data Register (DR): This is a read/write register.  The DR is for 
*     holding data that comes from the PAD or the IP Bus.
*     (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*      more details)
*
*  3) Data Direction Register (DDR):  This is a read/write register.  This
*     register configures a particular pin as either an input, set to one,
*     or an output, set to zero.    
*     (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*      more details)
* 	 
*	4) Peripheral Enable Register (PER):  This is a read/write register.  
*     This register determines the GPIOs configuration.  Setting a bit to 
*     one makes the peripheral master the GPIO pin.  When a bit is set to 
*     zero the Data Direction Register determines the direction of data 
*     flow through the pin.
*     (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*      more details)
*  
*  5)  Interrupt Assert Register (IAR):  This is a read/write register.  
*      The IAR register is used only in software testing.  When the IAR is 
*      a one an interrupt is asserted and can be cleared by writing zeros 
*      into the IAR.
*      (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*       more details)
*
*  6)  Interrupt Enable Register (IENR):  This is a read/write register.  It
*      enables or disables the edge detection for any incoming interrupt from
*      the PAD.  This register is set to one for interrupt detection.
*      (See DSP56F801/803/805/807 Chapter 7 General Purpose Input/Output for
*       more details)
*
*****************************************************************************/
#ifndef GIOPDRV_H
#define GIOPDRV_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_GPIO
		#error INCLUDE_GPIO must be defined in appconfig.h to initialize the GPIO Library
	#endif
#endif

#include "port.h"
#include "periph.h"
//#include "io.h"
#include "gpio.h"

#ifdef __cplusplus
extern "C" {
#endif

/* port pins */
#define GPIOPORT_A  0x01A0
#define GPIOPORT_B  0x01B0
#define GPIOPORT_C  0x01C0
#define GPIOPORT_D  0x01D0
#define GPIOPORT_E  0x01E0
#define GPIOPORT_F  0x01F0



#define GPIO_PULLUP_REG_OFFSET            0x1000
#define GPIO_DATA_REG_OFFSET              0x1001
#define GPIO_DATA_DIRECTION_REG_OFFSET    0x1002
#define GPIO_PERIPHERAL_ENABLE_REG_OFFSET 0x1003
#define GPIO_INT_ASSERT_REG_OFFSET        0x1004
#define GPIO_INT_ENABLE_REG_OFFSET        0x1005
#define GPIO_INT_POLARITY_REG_OFFSET      0x1006
#define GPIO_INT_PENDING_REG_OFFSET       0x1007
#define GPIO_INT_EDGE_SENS_REG_OFFSET     0x1008




#define gpioIoctl(FD,Cmd,Pin,gpioDevice) gpioIoctl##Cmd(Pin)



#define gpioIoctlGPIO_SET(Mask)                  			\
			periphBitSet   (((Mask) & 0x00FF), 			\
						(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_REG_OFFSET))

#define gpioIoctlGPIO_CLEAR(Mask)                			\
			periphBitClear (((Mask) & 0x00FF),  			\
						(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_REG_OFFSET))

#define gpioIoctlGPIO_TOGGLE(Mask)               			\
			periphBitChange(((Mask) & 0x00FF),  			\
						(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_REG_OFFSET))

#define gpioIoctlGPIO_DISABLE_PULLUP(Mask)       			\
			periphBitClear (((Mask) & 0x00FF),  			\
					(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_PULLUP_REG_OFFSET))

#define gpioIoctlGPIO_ENABLE_PULLUP(Mask)        			\
			periphBitSet   (((Mask) & 0x00FF),  			\
					(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_PULLUP_REG_OFFSET))

#define gpioIoctlGPIO_SETAS_INPUT(Mask)          			\
			periphBitClear (((Mask) & 0x00FF),  			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_DIRECTION_REG_OFFSET))
								
#define gpioIoctlGPIO_SETAS_OUTPUT(Mask)         			\
			periphBitSet   (((Mask) & 0x00FF),  			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_DIRECTION_REG_OFFSET))

#define gpioIoctlGPIO_SETAS_GPIO(Mask)           			\
			periphBitClear (((Mask) & 0x00FF),  			\
		(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_PERIPHERAL_ENABLE_REG_OFFSET))
	
#define gpioIoctlGPIO_SETAS_PERIPHERAL(Mask)     			\
			periphBitSet   (((Mask) & 0x00FF),  			\
		(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_PERIPHERAL_ENABLE_REG_OFFSET))

#define gpioIoctlGPIO_INTERRUPT_ASSERT_DISABLE(Mask)		\
			periphBitClear (((Mask) & 0x00FF),    			\
				(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_ASSERT_REG_OFFSET))

#define gpioIoctlGPIO_INTERRUPT_ASSERT_ENABLE(Mask)     	\
			periphBitSet   (((Mask) & 0x00FF),   			\
				(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_ASSERT_REG_OFFSET))

#define gpioIoctlGPIO_INTERRUPT_DISABLE(Mask)    			\
			periphBitClear (((Mask) & 0x00FF),  			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_ENABLE_REG_OFFSET))  

#define gpioIoctlGPIO_INTERRUPT_ENABLE(Mask)     			\
			periphBitSet   (((Mask) & 0x00FF), 			\
				(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_ENABLE_REG_OFFSET))

#define gpioIoctlGPIO_INTERRUPT_DETECTION_ACTIVE_HIGH(Mask) \
			periphBitClear(((Mask) & 0x00FF),    			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_POLARITY_REG_OFFSET))

#define gpioIoctlGPIO_INTERRUPT_DETECTION_ACTIVE_LOW(Mask)  \
			periphBitSet  (((Mask) & 0x00FF),   			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_POLARITY_REG_OFFSET))

#define gpioIoctlGPIO_CLEAR_INTERRUPT_PEND_REGISTER(Mask)   \
			periphBitClear(((Mask) & 0x00FF),    			\
			(UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_INT_EDGE_SENS_REG_OFFSET))

#define gpioIoctlGPIO_READ(Mask)							\
			(((periphMemRead((UWord16 *)((((Mask) >> 4) & 0x0FF0) + GPIO_DATA_REG_OFFSET))) & ((Mask) & 0x00FF)) >> (   ((Mask >> 1) & 0x0001) * 1 + \
																														((Mask >> 2) & 0x0001) * 2 + \
																														((Mask >> 3) & 0x0001) * 3 + \
																														((Mask >> 4) & 0x0001) * 4 + \
																														((Mask >> 5) & 0x0001) * 5 + \
																														((Mask >> 6) & 0x0001) * 6 + \
																														((Mask >> 7) & 0x0001) * 7))

/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
#define gpioOpen(pName,flags) ((int)pName)
#define gpioClose(FD) (0)
/* EXPORT Result gpioCreate(const char * pName) */
#define gpioCreate(name) (PASS)



#ifdef __cplusplus
}
#endif

#endif

/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   config.h
*
* DESCRIPTION: This file contains the default settings for the SDK
*              drivers.
*
*******************************************************************************/

#ifndef __CONFIG_H
#define __CONFIG_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************
*
* Undefine all SDK components 
*
*****************************************************************************/
#undef  INCLUDE_BSP           /* BSP support - includes SIM, COP, CORE, PLL, and ITCN */
#undef  INCLUDE_BUTTON        /* Button support */
#undef  INCLUDE_CODEC         /* Codec support */
#undef  INCLUDE_FCODEC         /* Codec support */
#undef  INCLUDE_COP           /* COP support (subset of BSP) */
#undef  INCLUDE_CORE          /* CORE support (subset of BSP) */
#undef  INCLUDE_DSPFUNC       /* DSP Function library */
#undef  INCLUDE_FILEIO        /* File I/O support */
#undef  INCLUDE_FLASH         /* Flash support */
#undef  INCLUDE_GPIO          /* General Purpose I/O support */
#undef  INCLUDE_IO            /* I/O support */
#undef  INCLUDE_ITCN          /* ITCN support (subset of BSP) */
#undef  INCLUDE_LED           /* LED support for target board */
#undef  INCLUDE_MCFUNC        /* Motor Control functional library */
#undef  INCLUDE_MEMORY        /* Memory support */
#undef  INCLUDE_PCMASTER      /* PC Master support */
#undef  INCLUDE_PLL           /* PLL support (subset of BSP) */
#undef  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_SERIAL_DATAFLASH /* Serial DataFlash support */
#undef  INCLUDE_SIM           /* SIM support (subset of BSP) */
#undef  INCLUDE_SPI           /* SPI support */
#undef  INCLUDE_SSI           /* SSI support */
#undef  INCLUDE_STACK_CHECK   /* Stack utilization routines */
#undef  INCLUDE_TIME_OF_DAY   /* Time of Day support */
#undef  INCLUDE_TIMER         /* Timer support */
#undef  INCLUDE_UCOS          /* uC/OS support */



/****************************************************************************
*
* Include user selected SDK components
*
****************************************************************************/
#include "configdefines.h"
#include "bsp.h"


/****************************************************************************
*
* Board specific oscillator frequency
*
****************************************************************************/

/* DSP56826EVM oscillator frequency is 4.0MHz */
#ifndef BSP_OSCILLATOR_FREQ
   #define BSP_OSCILLATOR_FREQ (8192000L/2L)
#endif


/****************************************************************************
*
* Interrupt Vector declaration
*
* - To place a user defined interrupt in the interrupt vector
*   define a preprocessor variable INTERRUPT_VECTOR_ADDR_<n> to the 
*   address of your ISR, where n is the interrupt number.  
*
*   For example,
*
*       #define INTERRUPT_VECTOR_ADDR_30 MyInterruptISR
*  
*   will set the interrupt vector #30 to the address of the MyInterruptISR
*   routine.
*
****************************************************************************/
EXPORT void configInterruptVector(void);


/****************************************************************************
*
* Stack Check
*
****************************************************************************/
#ifdef INCLUDE_STACK_CHECK

   #include "stackcheck.h"

#endif


/****************************************************************************
*
* Default SIM Initialization
*
****************************************************************************/
#ifdef INCLUDE_SIM

	#include "simdrv.h"

	/* Default System Integration Module (SIM) configuration */
	
	#ifndef SIM_BOOT_MODE
		#define SIM_BOOT_MODE                     SIM_BOOT_MODE_A
	#endif
	
	#ifndef SIM_CONTROL_REG
		#define SIM_CONTROL_REG                   SIM_BOOT_MODE
	#endif

#endif


/****************************************************************************
*
* Default COP Initialization
*
****************************************************************************/
#ifdef INCLUDE_COP

		#include "cop.h"

	/* Computer Operating Properly (COP) configuration */
	
	#ifndef INTERRUPT_VECTOR_ADDR_1                 
        #define INTERRUPT_VECTOR_ADDR_1                 archStart
	#endif

	#ifdef COP_TIMEOUT

        #define COP_OSCILLATOR_FREQ               (BSP_OSCILLATOR_FREQ * PLL_MUL / 2L / 1000000L)
        #define COP_TIMEOUT_TCK                   (COP_TIMEOUT * COP_OSCILLATOR_FREQ)
    
        #define COP_TIMEOUT_REG                   ((COP_TIMEOUT_TCK - 1L)/16384L)
        #define COP_CONTROL_REG                   COP_ENABLE

	#else
        /* COP module is disabled by default */
        #define COP_CONTROL_REG                   0
        #define COP_TIMEOUT_REG                   0x0FFF
    #endif


#endif


/****************************************************************************
*
* Default PLL Initialization
*
****************************************************************************/
#ifdef INCLUDE_PLL

	#include "plldrv.h"

	/* Default PLL configuration */
	
	#ifndef PLL_MUL
		#define PLL_MUL                           36
	#endif

	#ifndef PLL_DIVIDE_BY_REG
		#define PLL_DIVIDE_BY_REG                 (( PLL_MUL - 1 ) \
																| PLL_CLOCK_IN_DIVIDE_BY_2 \
																| PLL_CLOCK_OUT_DIVIDE_BY_1)
	#endif

	#ifndef PLL_CONTROL_REG
		#define PLL_CONTROL_REG                   ( PLL_LOCK_DETECTOR \
																| PLL_ZCLOCK_POSTSCALER) 
	#endif

	#ifndef PLL_TEST_REG
		#define PLL_TEST_REG                      0 
	#endif

	#ifndef PLL_SELECT_REG
		#define PLL_SELECT_REG                    ( PLL_CLKO_SELECT_ZCLK ) 
	#endif

#endif


/****************************************************************************
*
* Default ITCN Initialization
*
****************************************************************************/
#ifdef INCLUDE_ITCN

	#include "itcndrv.h"

	/* ITCN (Group Priority Registers) Configuration */
	
	#ifndef GPR_INT_PRIORITY_0
		#define GPR_INT_PRIORITY_0                0
	#endif

	#ifndef GPR_INT_PRIORITY_1
		#define GPR_INT_PRIORITY_1                0
	#endif

	#ifndef GPR_INT_PRIORITY_2
		#define GPR_INT_PRIORITY_2                0
	#endif

	#ifndef GPR_INT_PRIORITY_3
		#define GPR_INT_PRIORITY_3                0
	#endif

	#ifndef GPR_INT_PRIORITY_4
	  #ifdef INCLUDE_UCOS  /* uC/OS SWI Task Context Switch */
		#define GPR_INT_PRIORITY_4                1
	  #else 
		#define GPR_INT_PRIORITY_4                0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_5
		#define GPR_INT_PRIORITY_5                0
	#endif

	#ifndef GPR_INT_PRIORITY_6
		#define GPR_INT_PRIORITY_6                0
	#endif

	#ifndef GPR_INT_PRIORITY_7
		#define GPR_INT_PRIORITY_7                0
	#endif

	#ifndef GPR_INT_PRIORITY_8
	  #ifdef INCLUDE_BUTTON
		#define GPR_INT_PRIORITY_8                1
	  #else 
		#define GPR_INT_PRIORITY_8                0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_9
	  #ifdef INCLUDE_BUTTON
		#define GPR_INT_PRIORITY_9                1
	  #else 
		#define GPR_INT_PRIORITY_9                0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_10
		#define GPR_INT_PRIORITY_10               0
	#endif

	#ifndef GPR_INT_PRIORITY_11
	  #ifdef INCLUDE_FLASH
		#define GPR_INT_PRIORITY_11               1
	  #else 
		#define GPR_INT_PRIORITY_11               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_12
	  #ifdef INCLUDE_FLASH
		#define GPR_INT_PRIORITY_12               1
	  #else 
		#define GPR_INT_PRIORITY_12               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_13
	  #ifdef INCLUDE_FLASH
		#define GPR_INT_PRIORITY_13               1
	  #else 
		#define GPR_INT_PRIORITY_13               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_14
		#define GPR_INT_PRIORITY_14               0
	#endif

	#ifndef GPR_INT_PRIORITY_15
		#define GPR_INT_PRIORITY_15               0
	#endif

	#ifndef GPR_INT_PRIORITY_16
		#define GPR_INT_PRIORITY_16               0
	#endif

	#ifndef GPR_INT_PRIORITY_17
		#define GPR_INT_PRIORITY_17               0
	#endif

	#ifndef GPR_INT_PRIORITY_18
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_18               1
	  #else 
		#define GPR_INT_PRIORITY_18               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_19
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_19               1
	  #else 
		#define GPR_INT_PRIORITY_19               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_20
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_20               1
	  #else 
		#define GPR_INT_PRIORITY_20               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_21
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_21               1
	  #else 
		#define GPR_INT_PRIORITY_21               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_22
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_22               1
	  #else 
		#define GPR_INT_PRIORITY_22               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_23
	  #ifdef INCLUDE_GPIO
		#define GPR_INT_PRIORITY_23               1
	  #else 
		#define GPR_INT_PRIORITY_23               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_24
	  #ifdef INCLUDE_SPI
		#define GPR_INT_PRIORITY_24               1
	  #else 
		#define GPR_INT_PRIORITY_24               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_25
	  #ifdef INCLUDE_SPI
		#define GPR_INT_PRIORITY_25               1
	  #else 
		#define GPR_INT_PRIORITY_25               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_26
	  #ifdef INCLUDE_SPI
		#define GPR_INT_PRIORITY_26               1
	  #else 
		#define GPR_INT_PRIORITY_26               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_27
	  #ifdef INCLUDE_SPI
		#define GPR_INT_PRIORITY_27               1
	  #else 
		#define GPR_INT_PRIORITY_27               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_28
		#define GPR_INT_PRIORITY_28               0
	#endif

	#ifndef GPR_INT_PRIORITY_29
		#define GPR_INT_PRIORITY_29               0
	#endif

	#ifndef GPR_INT_PRIORITY_30
		#define GPR_INT_PRIORITY_30               0
	#endif

	#ifndef GPR_INT_PRIORITY_31
		#define GPR_INT_PRIORITY_31               0
	#endif

	#ifndef GPR_INT_PRIORITY_32
	  #if defined INCLUDE_TIME_OF_DAY
		#define GPR_INT_PRIORITY_32               1
	  #else 
		#define GPR_INT_PRIORITY_32               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_33
	  #if defined INCLUDE_TIME_OF_DAY
		#define GPR_INT_PRIORITY_33               1
	  #else 
		#define GPR_INT_PRIORITY_33               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_34
	  #if defined(INCLUDE_TIMER) || defined(INCLUDE_QUAD_TIMER)
		#define GPR_INT_PRIORITY_34               1
	  #else 
		#define GPR_INT_PRIORITY_34               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_35
	  #if defined(INCLUDE_TIMER) || defined(INCLUDE_QUAD_TIMER)
		#define GPR_INT_PRIORITY_35               1
	  #else 
		#define GPR_INT_PRIORITY_35               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_36
	  #if defined(INCLUDE_TIMER) || defined(INCLUDE_QUAD_TIMER)
		#define GPR_INT_PRIORITY_36               1
	  #else 
		#define GPR_INT_PRIORITY_36               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_37
	  #if defined(INCLUDE_TIMER) || defined(INCLUDE_QUAD_TIMER)
		#define GPR_INT_PRIORITY_37               1
	  #else 
		#define GPR_INT_PRIORITY_37               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_38
		#define GPR_INT_PRIORITY_38               0
	#endif

	#ifndef GPR_INT_PRIORITY_39
		#define GPR_INT_PRIORITY_39               0
	#endif
	
	#ifndef GPR_INT_PRIORITY_40
		#define GPR_INT_PRIORITY_40               0
	#endif

	#ifndef GPR_INT_PRIORITY_41
		#define GPR_INT_PRIORITY_41               0
	#endif

	#ifndef GPR_INT_PRIORITY_42
		#define GPR_INT_PRIORITY_42               0
	#endif

	#ifndef GPR_INT_PRIORITY_43
		#define GPR_INT_PRIORITY_43               0
	#endif

	#ifndef GPR_INT_PRIORITY_44
		#define GPR_INT_PRIORITY_44               0
	#endif

	#ifndef GPR_INT_PRIORITY_45
		#define GPR_INT_PRIORITY_45               0
	#endif

	#ifndef GPR_INT_PRIORITY_46
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_46               1
	  #else 
		#define GPR_INT_PRIORITY_46               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_47
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_47               1
	  #else 
		#define GPR_INT_PRIORITY_47               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_48
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_48               1
	  #else 
		#define GPR_INT_PRIORITY_48               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_49
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_49               1
	  #else 
		#define GPR_INT_PRIORITY_49               0
	  #endif
	#endif
	
	#ifndef GPR_INT_PRIORITY_50
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_50               1
	  #else 
		#define GPR_INT_PRIORITY_50               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_51
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_51               1
	  #else 
		#define GPR_INT_PRIORITY_51               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_52
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_52               1
	  #else 
		#define GPR_INT_PRIORITY_52               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_53
	  #ifdef INCLUDE_SCI
		#define GPR_INT_PRIORITY_53               1
	  #else 
		#define GPR_INT_PRIORITY_53               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_54
		#define GPR_INT_PRIORITY_54               0
	#endif

	#ifndef GPR_INT_PRIORITY_55
		#define GPR_INT_PRIORITY_55               0
	#endif

	#ifndef GPR_INT_PRIORITY_56
		#define GPR_INT_PRIORITY_56               0
	#endif

	#ifndef GPR_INT_PRIORITY_57
	  #ifdef INCLUDE_SSI
		#define GPR_INT_PRIORITY_57               1
	  #else 
		#define GPR_INT_PRIORITY_57               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_58
	  #ifdef INCLUDE_SSI
		#define GPR_INT_PRIORITY_58               1
	  #else 
		#define GPR_INT_PRIORITY_58               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_59
	  #ifdef INCLUDE_SSI
		#define GPR_INT_PRIORITY_59               1
	  #else 
		#define GPR_INT_PRIORITY_59               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_60
	  #ifdef INCLUDE_SSI
		#define GPR_INT_PRIORITY_60               1
	  #else 
		#define GPR_INT_PRIORITY_60               0
	  #endif
	#endif

	#ifndef GPR_INT_PRIORITY_61
		#define GPR_INT_PRIORITY_61               0
	#endif

	#ifndef GPR_INT_PRIORITY_62
		#define GPR_INT_PRIORITY_62               0
	#endif

	#ifndef GPR_INT_PRIORITY_63
		#define GPR_INT_PRIORITY_63               0
	#endif

	#ifndef GPR_REG_0
		#define GPR_REG_0                         (GPR_INT_PRIORITY_0 \
														       | GPR_INT_PRIORITY_1 << 4 \
														       | GPR_INT_PRIORITY_2 << 8 \
														       | GPR_INT_PRIORITY_3 << 12)
	#endif

	#ifndef GPR_REG_1
		#define GPR_REG_1                         (GPR_INT_PRIORITY_4 \
														       | GPR_INT_PRIORITY_5 << 4 \
														       | GPR_INT_PRIORITY_6 << 8 \
														       | GPR_INT_PRIORITY_7 << 12)
	#endif

	#ifndef GPR_REG_2
		#define GPR_REG_2                         (GPR_INT_PRIORITY_8 \
														       | GPR_INT_PRIORITY_9 << 4 \
														       | GPR_INT_PRIORITY_10 << 8 \
														       | GPR_INT_PRIORITY_11 << 12)
	#endif

	#ifndef GPR_REG_3
		#define GPR_REG_3                         (GPR_INT_PRIORITY_12 \
														       | GPR_INT_PRIORITY_13 << 4 \
														       | GPR_INT_PRIORITY_14 << 8 \
														       | GPR_INT_PRIORITY_15 << 12)
	#endif

	#ifndef GPR_REG_4
		#define GPR_REG_4                         (GPR_INT_PRIORITY_16 \
														       | GPR_INT_PRIORITY_17 << 4 \
														       | GPR_INT_PRIORITY_18 << 8 \
														       | GPR_INT_PRIORITY_19 << 12)
	#endif

	#ifndef GPR_REG_5
		#define GPR_REG_5                         (GPR_INT_PRIORITY_20 \
														       | GPR_INT_PRIORITY_21 << 4 \
														       | GPR_INT_PRIORITY_22 << 8 \
														       | GPR_INT_PRIORITY_23 << 12)
	#endif

	#ifndef GPR_REG_6
		#define GPR_REG_6                         (GPR_INT_PRIORITY_24 \
														       | GPR_INT_PRIORITY_25 << 4 \
														       | GPR_INT_PRIORITY_26 << 8 \
														       | GPR_INT_PRIORITY_27 << 12)
	#endif

	#ifndef GPR_REG_7
		#define GPR_REG_7                         (GPR_INT_PRIORITY_28 \
														       | GPR_INT_PRIORITY_29 << 4 \
														       | GPR_INT_PRIORITY_30 << 8 \
														       | GPR_INT_PRIORITY_31 << 12)
	#endif

	#ifndef GPR_REG_8
		#define GPR_REG_8                         (GPR_INT_PRIORITY_32 \
														       | GPR_INT_PRIORITY_33 << 4 \
														       | GPR_INT_PRIORITY_34 << 8 \
														       | GPR_INT_PRIORITY_35 << 12)
	#endif

	#ifndef GPR_REG_9
		#define GPR_REG_9                         (GPR_INT_PRIORITY_36 \
														       | GPR_INT_PRIORITY_37 << 4 \
														       | GPR_INT_PRIORITY_38 << 8 \
														       | GPR_INT_PRIORITY_39 << 12)
	#endif

	#ifndef GPR_REG_10
		#define GPR_REG_10                         (GPR_INT_PRIORITY_40 \
														       | GPR_INT_PRIORITY_41 << 4 \
														       | GPR_INT_PRIORITY_42 << 8 \
														       | GPR_INT_PRIORITY_43 << 12)
	#endif

	#ifndef GPR_REG_11
		#define GPR_REG_11                         (GPR_INT_PRIORITY_44 \
														       | GPR_INT_PRIORITY_45 << 4 \
														       | GPR_INT_PRIORITY_46 << 8 \
														       | GPR_INT_PRIORITY_47 << 12)
	#endif

	#ifndef GPR_REG_12
		#define GPR_REG_12                         (GPR_INT_PRIORITY_48 \
														       | GPR_INT_PRIORITY_49 << 4 \
														       | GPR_INT_PRIORITY_50 << 8 \
														       | GPR_INT_PRIORITY_51 << 12)
	#endif

	#ifndef GPR_REG_13
		#define GPR_REG_13                         (GPR_INT_PRIORITY_52 \
														       | GPR_INT_PRIORITY_53 << 4 \
														       | GPR_INT_PRIORITY_54 << 8 \
														       | GPR_INT_PRIORITY_55 << 12)
	#endif

	#ifndef GPR_REG_14
		#define GPR_REG_14                         (GPR_INT_PRIORITY_56 \
														       | GPR_INT_PRIORITY_57 << 4 \
														       | GPR_INT_PRIORITY_58 << 8 \
														       | GPR_INT_PRIORITY_59 << 12)
	#endif

	#ifndef GPR_REG_15
		#define GPR_REG_15                         (GPR_INT_PRIORITY_60 \
														       | GPR_INT_PRIORITY_61 << 4 \
														       | GPR_INT_PRIORITY_62 << 8 \
														       | GPR_INT_PRIORITY_63 << 12)
	#endif

	/* Default Interrupt Enable */

	#ifndef BSP_ENABLE_INTERRUPTS
		#define BSP_ENABLE_INTERRUPTS              true
	#endif
	
#endif


/****************************************************************************
*
* Default CORE Initialization
*
****************************************************************************/
#ifdef INCLUDE_CORE

	#include "coredrv.h"

	/* Default Bus configuration */
	
	#ifndef BUS_CONTROL_EXT_X_MEM_WAIT_STATES
		#define BUS_CONTROL_EXT_X_MEM_WAIT_STATES 0
	#endif

	#ifndef BUS_CONTROL_EXT_P_MEM_WAIT_STATES
		#define BUS_CONTROL_EXT_P_MEM_WAIT_STATES 0
	#endif

	#ifndef BUS_CONTROL_REG
		#define BUS_CONTROL_REG                   ((BUS_CONTROL_EXT_X_MEM_WAIT_STATES << 4) \
														       | BUS_CONTROL_EXT_P_MEM_WAIT_STATES)
	#endif

	/* Default Interrupt Priority configuration */
	
	#ifndef INTERRUPT_PRIORITY_REG
		#define INTERRUPT_PRIORITY_REG      ( IPR_ENABLE_CHANNEL_0         \
											| IPR_ENABLE_CHANNEL_1         \
											| IPR_ENABLE_CHANNEL_2         \
											| IPR_ENABLE_CHANNEL_3         \
											| IPR_ENABLE_CHANNEL_4         \
											| IPR_ENABLE_CHANNEL_5         \
											| IPR_ENABLE_CHANNEL_6         \
											| IPR_ENABLE_IRQA              \
											| IPR_ENABLE_IRQB              \
											| IPR_IRQA_TRIGGER_RISING_EDGE \
											| IPR_IRQB_TRIGGER_RISING_EDGE)
	#endif
	
#endif


/****************************************************************************
*
* Default Memory Initialization
*
****************************************************************************/
#ifdef INCLUDE_MEMORY

	#include "mem.h"

#endif


/****************************************************************************
*
* Default DSP Function Library Initialization
*
****************************************************************************/
#ifdef INCLUDE_DSPFUNC

	#include "dspfunc.h"
	
#endif


/****************************************************************************
*
* Default IO Initialization
*
****************************************************************************/
#ifdef INCLUDE_IO_IO

	#include "io.h"

	#ifndef IO_MAX_DRIVERS
		#define IO_MAX_DRIVERS 5
	#endif

	#ifndef IO_MAX_DEVICES
		#define IO_MAX_DEVICES 12
	#endif
#endif


/****************************************************************************
*
* uC/OS Initialization
*
****************************************************************************/
#ifdef INCLUDE_UCOS

	#define NANOSLEEP_USES_NORMAL_ISR
	
	/* Define SWI ISR handler for uC/OS */
		extern void OSCtxSw(void);
	
		#ifndef INTERRUPT_VECTOR_ADDR_4
			#ifndef NORMAL_ISR_4
				#define NORMAL_ISR_4 OSCtxSw
			#endif
		#endif
	
	
#endif


/****************************************************************************
*
* Quadrature Timer Initialization
*
****************************************************************************/
#ifdef INCLUDE_QUAD_TIMER

	/*
		Define the set of INCLUDE_USER_TIMER_x_n variables as:
			0 => used for the Quadrature Timer (QT)
			1 => used for the POSIX Timer (timer.h), which uses the QT
	*/
    #if \
       !(defined(INCLUDE_USER_TIMER_A_0 ) ||  defined(INCLUDE_USER_TIMER_A_1 ) ||  \
         defined(INCLUDE_USER_TIMER_A_2 ) ||  defined(INCLUDE_USER_TIMER_A_3 ) )  

        /* 
        	Default set of Quadrature Timers if the user has defined 
        	INCLUDE_QUAD_TIMER, yet not specified any timers
        */
		#define INCLUDE_USER_TIMER_A_0  0
		#define INCLUDE_USER_TIMER_A_1  0
		
		#ifndef INCLUDE_TIMER
		    #define INCLUDE_USER_TIMER_A_2  0
		    #define INCLUDE_USER_TIMER_A_3  0
		#endif
    #endif

    #ifdef INCLUDE_TIMER
        #if \
           !((INCLUDE_USER_TIMER_A_0 == 1 ) ||  (INCLUDE_USER_TIMER_A_1 == 1 ) ||  \
             (INCLUDE_USER_TIMER_A_2 == 1 ) ||  (INCLUDE_USER_TIMER_A_3 == 1 ) )  
         
            /* 
        	    Default set of User Timers if the user has defined 
        	    INCLUDE_TIMER, yet not specified any timers
            */

		    #define INCLUDE_USER_TIMER_A_2  1
		    #define INCLUDE_USER_TIMER_A_3  1
		
        #endif
    #endif

	/*
		Find first defined timer that is used for the POSIX nanosleep timer;
		Set it to use a Super ISR, unless NANOSLEEP_USES_NORMAL_ISR is defined
	*/
	#ifndef NANOSLEEP_USES_NORMAL_ISR
	  #if (INCLUDE_USER_TIMER_A_0 == 1)
		#ifndef QT_CALLBACK_A_0_USES_PRAGMA_INTERRUPT
			#define QT_CALLBACK_A_0_USES_PRAGMA_INTERRUPT
		#endif
	  #elif (INCLUDE_USER_TIMER_A_1 == 1)
		#ifndef QT_CALLBACK_A_1_USES_PRAGMA_INTERRUPT
			#define QT_CALLBACK_A_1_USES_PRAGMA_INTERRUPT
		#endif
	  #elif (INCLUDE_USER_TIMER_A_2 == 1)
		#ifndef QT_CALLBACK_A_2_USES_PRAGMA_INTERRUPT
			#define QT_CALLBACK_A_2_USES_PRAGMA_INTERRUPT
		#endif
	  #elif (INCLUDE_USER_TIMER_A_3 == 1)
		#ifndef QT_CALLBACK_A_3_USES_PRAGMA_INTERRUPT
			#define QT_CALLBACK_A_3_USES_PRAGMA_INTERRUPT
		#endif
	  #endif
	#endif


	/* Define ISR addresses for QT */

	#if defined(INCLUDE_USER_TIMER_A_0)
		#ifndef INTERRUPT_VECTOR_ADDR_34
			#if defined(QT_CALLBACK_A_0_USES_PRAGMA_INTERRUPT)
				#define INTERRUPT_VECTOR_ADDR_34 QTimerSuperISRA0
			#else
				#if (GPR_INT_PRIORITY_34 != 0)
					#define NORMAL_ISR_34 QTimerISRA0
				#endif
			#endif
		#endif
	#endif
	
	#if defined(INCLUDE_USER_TIMER_A_1)
		#ifndef INTERRUPT_VECTOR_ADDR_35
			#if defined(QT_CALLBACK_A_1_USES_PRAGMA_INTERRUPT)
				#define INTERRUPT_VECTOR_ADDR_35 QTimerSuperISRA1
			#else
				#if (GPR_INT_PRIORITY_35 != 0)
					#define NORMAL_ISR_35 QTimerISRA1
				#endif
			#endif
		#endif
	#endif

	#if defined(INCLUDE_USER_TIMER_A_2)
		#ifndef INTERRUPT_VECTOR_ADDR_36
			#if defined(QT_CALLBACK_A_2_USES_PRAGMA_INTERRUPT)
				#define INTERRUPT_VECTOR_ADDR_36 QTimerSuperISRA2
			#else
				#if (GPR_INT_PRIORITY_36 != 0)
					#define NORMAL_ISR_36 QTimerISRA2
				#endif
			#endif
		#endif
	#endif
	
	#if defined(INCLUDE_USER_TIMER_A_3)
		#ifndef INTERRUPT_VECTOR_ADDR_37
			#if defined(QT_CALLBACK_A_3_USES_PRAGMA_INTERRUPT)
				#define INTERRUPT_VECTOR_ADDR_37 QTimerSuperISRA3
			#else
				#if (GPR_INT_PRIORITY_37 != 0)
					#define NORMAL_ISR_37 QTimerISRA3
				#endif
			#endif
		#endif
	#endif
	
	#include "quadraturetimer.h"

#endif


/****************************************************************************
*
* Default Timer Initialization
*
****************************************************************************/
#ifdef INCLUDE_TIMER

	/* default TIMER_TICK_NANOSECONDS to 1000000 (1ms) */
	#ifndef TIMER_TICK_NANOSECONDS
		#define TIMER_TICK_NANOSECONDS 1000000
	#endif
	
	/*
		Define the set of INCLUDE_USER_TIMER_x_n variables as:
			0 => used for the Quadrature Timer (QT)
			1 => used for the POSIX Timer (timer.h), which uses the QT
	*/
	
    #if !defined(INCLUDE_QUAD_TIMER)
    #error  "QUADRATURE Timer should be defined"
    #endif /* !defined(INCLUDE_QUAD_TIMER) */

	#if !defined( QT_TIMER_PRESCALER )
        #define QT_TIMER_PRESCALER   128
	#endif /* !defined( QT_TIMER_PRESCALER ) */

	
	/* #include "qtimerdrv.h" is done in QT section */

#endif


/****************************************************************************
*
* Default Flash driver Initialization
*
****************************************************************************/
#ifdef INCLUDE_FLASH

   #include "flashdrv.h"

   #if defined(FLASH_DFIU_PROGRAM_TIME)

      #if !defined(FLASH_DFIU_CKDIVISOR_VALUE)
      #define FLASH_DFIU_CKDIVISOR_VALUE  0x000fu
      #endif 
      #if !defined(FLASH_DFIU_TERASEL_VALUE)
      #define FLASH_DFIU_TERASEL_VALUE    0x000fu
      #endif 
      #if !defined(FLASH_DFIU_TMEL_VALUE)
      #define FLASH_DFIU_TMEL_VALUE       0x000fu
      #endif 
      #if !defined(FLASH_DFIU_TNVSL_VALUE)
      #define FLASH_DFIU_TNVSL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_DFIU_TPGSL_VALUE)
      #define FLASH_DFIU_TPGSL_VALUE      0x01ffu
      #endif 
      #if !defined(FLASH_DFIU_TPROGL_VALUE)
      #define FLASH_DFIU_TPROGL_VALUE     0x03ffu
      #endif 
      #if !defined(FLASH_DFIU_TNVHL_VALUE)
      #define FLASH_DFIU_TNVHL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_DFIU_TNVH1L_VALUE)
      #define FLASH_DFIU_TNVH1L_VALUE     0x0fffu
      #endif 
      #if !defined(FLASH_DFIU_TRCVL_VALUE)
      #define FLASH_DFIU_TRCVL_VALUE      0x003fu
      #endif 
   #endif /* defined(FLASH_DFIU_PROGRAM_TIME) */

   #if defined(FLASH_PFIU_PROGRAM_TIME)

      #if !defined(FLASH_PFIU_CKDIVISOR_VALUE)
      #define FLASH_PFIU_CKDIVISOR_VALUE  0x000fu
      #endif 
      #if !defined(FLASH_PFIU_TERASEL_VALUE)
      #define FLASH_PFIU_TERASEL_VALUE    0x000fu
      #endif 
      #if !defined(FLASH_PFIU_TMEL_VALUE)
      #define FLASH_PFIU_TMEL_VALUE       0x000fu
      #endif 
      #if !defined(FLASH_PFIU_TNVSL_VALUE)
      #define FLASH_PFIU_TNVSL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_PFIU_TPGSL_VALUE)
      #define FLASH_PFIU_TPGSL_VALUE      0x01ffu
      #endif 
      #if !defined(FLASH_PFIU_TPROGL_VALUE)
      #define FLASH_PFIU_TPROGL_VALUE     0x03ffu
      #endif 
      #if !defined(FLASH_PFIU_TNVHL_VALUE)
      #define FLASH_PFIU_TNVHL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_PFIU_TNVH1L_VALUE)
      #define FLASH_PFIU_TNVH1L_VALUE     0x0fffu
      #endif 
      #if !defined(FLASH_PFIU_TRCVL_VALUE)
      #define FLASH_PFIU_TRCVL_VALUE      0x003fu
      #endif 
   #endif /* defined(FLASH_PFIU_PROGRAM_TIME) */

   #if defined(FLASH_BFIU_PROGRAM_TIME)

      #if !defined(FLASH_BFIU_CKDIVISOR_VALUE)
      #define FLASH_BFIU_CKDIVISOR_VALUE  0x000fu
      #endif 
      #if !defined(FLASH_BFIU_TERASEL_VALUE)
      #define FLASH_BFIU_TERASEL_VALUE    0x000fu
      #endif 
      #if !defined(FLASH_BFIU_TMEL_VALUE)
      #define FLASH_BFIU_TMEL_VALUE       0x000fu
      #endif 
      #if !defined(FLASH_BFIU_TNVSL_VALUE)
      #define FLASH_BFIU_TNVSL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_BFIU_TPGSL_VALUE)
      #define FLASH_BFIU_TPGSL_VALUE      0x01ffu
      #endif 
      #if !defined(FLASH_BFIU_TPROGL_VALUE)
      #define FLASH_BFIU_TPROGL_VALUE     0x03ffu
      #endif 
      #if !defined(FLASH_BFIU_TNVHL_VALUE)
      #define FLASH_BFIU_TNVHL_VALUE      0x00ffu
      #endif 
      #if !defined(FLASH_BFIU_TNVH1L_VALUE)
      #define FLASH_BFIU_TNVH1L_VALUE     0x0fffu
      #endif 
      #if !defined(FLASH_BFIU_TRCVL_VALUE)
      #define FLASH_BFIU_TRCVL_VALUE      0x003fu
      #endif 
   #endif /* defined (FLASH_BFIU_PROGRAM_TIME) */

#endif


/****************************************************************************
*
* Default SCI driver Initialization
*
****************************************************************************/
#ifdef INCLUDE_SCI

   #include "scidrv.h"

   #define SCI_230400          230400u
   #define SCI_115200          115200u
   #define SCI_76800            76800u
   #define SCI_57600            57600u         
   #define SCI_38400            38400u
   #define SCI_28800            28800u
   #define SCI_19200            19200u
   #define SCI_14400            14400u
   #define SCI_9600              9600u
   #define SCI_7200              7200u
   #define SCI_4800              4800u
   #define SCI_2400              2400u
   #define SCI_1200              1200u
   #define SCI_600                600u

   #if !defined(SCI_USER_BAUD_RATE_1)   
   #define SCI_USER_BAUD_RATE_1          SCI_GET_SBR(31250u)
   #endif /* !defined(SCI_USER_BAUD_RATE_1) */

   #if !defined(SCI_USER_BAUD_RATE_2)   
   #define SCI_USER_BAUD_RATE_2          SCI_GET_SBR(115200u)
   #endif /* !defined(SCI_USER_BAUD_RATE_2) */

   #define SCI_GET_SBR(BaudRate) (((((unsigned long)(PLL_MUL) * ((unsigned long)BSP_OSCILLATOR_FREQ)) \
   										+ (((unsigned long)BaudRate) * 32ul)) / \
                                    (((unsigned long)BaudRate) * 64ul)) & 0x1fff)

   #if defined(SCI_NONBLOCK_MODE)

      #if !defined(SCI0_SEND_BUFFER_LENGTH)
      #define  SCI0_SEND_BUFFER_LENGTH    8
      #endif /* !defined(SCI0_SEND_BUFFER_LENGTH) */

      #if !defined(SCI0_RECEIVE_BUFFER_LENGTH)
      #define  SCI0_RECEIVE_BUFFER_LENGTH 8
      #endif /* !defined(SCI0_RECEIVE_BUFFER_LENGTH) */

      #if !defined(SCI1_SEND_BUFFER_LENGTH)
      #define  SCI1_SEND_BUFFER_LENGTH    8
      #endif /* !defined(SCI1_SEND_BUFFER_LENGTH) */

      #if !defined(SCI1_RECEIVE_BUFFER_LENGTH)
      #define  SCI1_RECEIVE_BUFFER_LENGTH 8
      #endif /* !defined(SCI1_RECEIVE_BUFFER_LENGTH) */

   #endif /* defined(SCI_NONBLOCK_MODE) */

#endif

/****************************************************************************
*
* Default Serial DataFlash Initialization
*
****************************************************************************/
#ifdef INCLUDE_SERIAL_DATAFLASH
	#ifndef INCLUDE_SPI
		#error SPI component must be defined for Serial DataFlash operation
	#endif

	#include "serialdataflash.h"
#endif

/****************************************************************************
*
* Default SPI driver Initialization
*
****************************************************************************/
#ifdef INCLUDE_SPI

   	#include "spi.h"
   	

	
#endif

/****************************************************************************
*
*  Codec NEW Initialization
*
****************************************************************************/
#ifdef INCLUDE_NEW_CODEC
	#ifndef INCLUDE_IO
		#error IO component must be defined for CODEC operation
	#endif

	#include "codec.h"
	
    #ifndef CODEC_MASK
        #define CODEC_MASK                        CODEC_INTERRUPT_MASKED
    #endif

    #ifndef CODEC_DO1
        #define CODEC_DO1                         CODEC_DIGITAL_OUTPUT_1_LOW
    #endif

    #ifndef CODEC_LEFT_D2A_ATTENUATION
        #define CODEC_LEFT_D2A_ATTENUATION        0 /* 0 to 31 */
    #endif
    
    #ifndef CODEC_LA
        #define CODEC_LA                          (CODEC_LEFT_D2A_ATTENUATION << 5)
    #endif

    #ifndef CODEC_RIGHT_D2A_ATTENUATION
        #define CODEC_RIGHT_D2A_ATTENUATION       0 /* 0 to 31 */
    #endif

    #ifndef CODEC_RA
        #define CODEC_RA                          CODEC_RIGHT_D2A_ATTENUATION
    #endif

    #ifndef CODEC_MUTE
        #define CODEC_MUTE                        CODEC_MUTE_DISABLED
    #endif

    #ifndef CODEC_ISL
        #define CODEC_ISL                         CODEC_LEFT_INPUT_LINE_1
    #endif
    
    #ifndef CODEC_ISR
        #define CODEC_ISR                         CODEC_RIGHT_INPUT_LINE_1
    #endif

    #ifndef CODEC_LEFT_A2D_GAIN    
        #define CODEC_LEFT_A2D_GAIN               15  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_LG
        #define CODEC_LG                          (CODEC_LEFT_A2D_GAIN << 4)
    #endif

    #ifndef CODEC_RIGHT_A2D_GAIN
        #define CODEC_RIGHT_A2D_GAIN              15  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_RG
        #define CODEC_RG                          (CODEC_RIGHT_A2D_GAIN)
    #endif
   
	#ifndef CODEC_RX_CONTROL_WORD
		#define CODEC_RX_CONTROL_WORD             (CODEC_MUTE | \
                                                   CODEC_ISL  | \
                                                   CODEC_ISR  | \
                                                   CODEC_LG   | \
                                                   CODEC_RG)
	#endif

	#ifndef CODEC_TX_CONTROL_WORD
		#define CODEC_TX_CONTROL_WORD             (CODEC_MASK | \
                                                   CODEC_DO1  | \
                                                   CODEC_LA   | \
                                                   CODEC_RA)
	#endif

	#ifndef CODEC_MODE
	    #define CODEC_MODE                     CODEC_STEREO
	#endif

        /****** RELATED SSI DRIVER CONFIGURATION ******/
        
        #ifndef INCLUDE_SSI
            #error SSI driver must be defined for CODEC operation
        #endif
        
        /* SSI mode definition                                            */
        #define SSI_SYNC_MODE              SSI_SYNC_IN
        /* SSI driver software FIFO buffer configuration                  */
        #define SSI_FIFO_DEPTH             SSI_FIFO_32
        /* SSI data configuartion                                         */
        #define SSI_FRAME_LENGTH           SSI_FRAME_LENGTH_2_WORDS
        #define SSI_WORD_LENGTH            SSI_WORD_LENGTH_16_BITS    
        #define SSI_SHIFT_DIRECTION        SSI_MSB_FIRST             
        /* SSI clock configuration                                        */
        #define SSI_CLOCK_POLARITY         SSI_CLOCK_FALLING_EDGE      
        #define SSI_FSYNC_LEVEL            SSI_FSYNC_HIGH_ACTIVE      
        #define SSI_FSYNC_LENGTH           SSI_FSYNC_WORD_LENGTH       
        #define SSI_FSYNC_EARLY            SSI_FSYNC_BIT_BEFORE       
        /* SSI clock rate definition                                      */
        #define SSI_PRESCALER_RANGE        SSI_PRESCALER_1             
        #define SSI_PRESCALER_MODULE       0x07                        
        
#if 0  /* Removed to comply with new SSI Driver */       

	#ifndef CODEC_FIFO_SIZE
		#define CODEC_FIFO_SIZE                   32
	#endif

	#ifndef CODEC_FIFO_THRESHOLD
		#define CODEC_FIFO_THRESHOLD              15
	#endif

	#ifndef CODEC_OPTIMIZATION_BUFFER_SIZE
		#define CODEC_OPTIMIZATION_BUFFER_SIZE    16
	#endif
	
#endif /* Removed to comply with new SSI Driver */       
	
#endif /* NEW_CODEC


/****************************************************************************
*
* SSI_NEW Driver Configuration
*
****************************************************************************/
#ifdef INCLUDE_NEW_SSI

    #ifndef INCLUDE_IO
        #error IO component must be defined for SSI operation
    #endif

    #include "ssi.h"

    /****** SSI CONFIGURATION DEFAULT SETTINGS ******/

    #define SSI_SYN          1               
    #define SSI_TE           0
    #define SSI_RE           0
    #define SSI_TIE          0
    #define SSI_RIE          0
    #define SSI_RFEN         1
    #define SSI_TFEN         1
    #define SSI_NET          1
    #define SSI_SSIEN        0
    #define SSI_SYNRST       0
    #define SSI_INIT         0

    /* SLAVE mode of operations */
    #if   (SSI_SYNC_MODE == SSI_SYNC_IN)  || (SSI_SYNC_MODE == SSI_GATED_IN)
        #define     NORMAL_ISR_60      ssiRxErrorISR
        #define     NORMAL_ISR_59      ssiRxCompletedISR
        #define     SSI_INTERRUPT_MASK SSI_RX_INTERRUPT_ENABLE
    /* MASTER mode of operations */
    #elif (SSI_SYNC_MODE == SSI_SYNC_OUT) || (SSI_SYNC_MODE == SSI_GATED_OUT)
        #define     NORMAL_ISR_58      ssiTxErrorISR
        #define     NORMAL_ISR_57      ssiTxCompletedISR
        #define     SSI_INTERRUPT_MASK SSI_TX_INTERRUPT_ENABLE
    #endif

    /****** SSI MODE CONFIGURATION ******/

    #if   (SSI_SYNC_MODE == SSI_SYNC_IN)
        #define SSI_RXDIR    0
        #define SSI_TXDIR    0
        #define SSI_RFDIR    0  
        #define SSI_TFDIR    0
    #elif (SSI_SYNC_MODE == SSI_SYNC_OUT)
        #define SSI_RXDIR    0
        #define SSI_TXDIR    1
        #define SSI_RFDIR    0  
        #define SSI_TFDIR    1
    #elif (SSI_SYNC_MODE == SSI_GATED_IN)
        #define SSI_RXDIR    1
        #define SSI_TXDIR    0
        #define SSI_RFDIR    0  
        #define SSI_TFDIR    0
    #elif (SSI_SYNC_MODE == SSI_GATED_OUT)
        #define SSI_RXDIR    1
        #define SSI_TXDIR    1
        #define SSI_RFDIR    0  
        #define SSI_TFDIR    0
    #else 
        #error SSI_SYNC_MODE must be initialized in appconfig.h by the one of predefined value
    #endif

    #if ( !defined(SSI_FIFO_DEPTH) ||         \
        ( (SSI_FIFO_DEPTH != SSI_FIFO_8  ) && \
          (SSI_FIFO_DEPTH != SSI_FIFO_16 ) && \
          (SSI_FIFO_DEPTH != SSI_FIFO_32 ) && \
          (SSI_FIFO_DEPTH != SSI_FIFO_64 ) && \
          (SSI_FIFO_DEPTH != SSI_FIFO_128) && \
          (SSI_FIFO_DEPTH != SSI_FIFO_256) ) )
        #error SSI_FIFO_DEPTH must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI NETWORK FRAME LENGTH CONFIGURATION ******/

    #if    (SSI_FRAME_LENGTH == SSI_FRAME_LENGTH_2_WORDS)
        #define SSI_DC0_4    1
        #define SSI_TFWM0_3  4
        #define SSI_RFWM0_3  4
    #elif  (SSI_FRAME_LENGTH == SSI_FRAME_LENGTH_4_WORDS)
        #define SSI_DC0_4    3
        #define SSI_TFWM0_3  4
        #define SSI_RFWM0_3  4
    #elif  (SSI_FRAME_LENGTH == SSI_FRAME_LENGTH_8_WORDS)
        #define SSI_DC0_4    7
        #define SSI_TFWM0_3  4
        #define SSI_RFWM0_3  4
    #else
        #error SSI_FRAME_LENGTH must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI WORD LENGTH CONFIGURATION ******/

    #if    (SSI_WORD_LENGTH == SSI_WORD_LENGTH_8_BITS)
        #define SSI_WL0_1    0x00
    #elif  (SSI_WORD_LENGTH == SSI_WORD_LENGTH_10_BITS)
        #define SSI_WL0_1    0x01
    #elif  (SSI_WORD_LENGTH == SSI_WORD_LENGTH_12_BITS)
        #define SSI_WL0_1    0x02
    #elif  (SSI_WORD_LENGTH == SSI_WORD_LENGTH_16_BITS)
        #define SSI_WL0_1    0x03
    #else
        #error SSI_WORD_LENGTH must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI DATA SHIFT DIRECTION CONFIGURATION ******/

    #if    (SSI_SHIFT_DIRECTION == SSI_LSB_FIRST)
        #define SSI_RSHFD    1    
        #define SSI_TSHFD    1
    #elif  (SSI_SHIFT_DIRECTION == SSI_MSB_FIRST)
        #define SSI_RSHFD    0
        #define SSI_TSHFD    0
    #else
        #error SSI_SHIFT_DIRECTION must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI FRAME SYNC CONFIGURATION ******/

    #if    (SSI_FSYNC_LEVEL == SSI_FSYNC_LOW_ACTIVE)
        #define SSI_RFSI     1
        #define SSI_TFSI     1
    #elif  (SSI_FSYNC_LEVEL == SSI_FSYNC_HIGH_ACTIVE)
        #define SSI_RFSI     0
        #define SSI_TFSI     0
    #else
        #error SSI_FSYNC_LEVEL must be initialized in appconfig.h by the one of predefined value
    #endif

    #if    (SSI_FSYNC_LENGTH == SSI_FSYNC_BIT_LENGTH)
        #define SSI_RFSL     1
        #define SSI_TFSL     1
    #elif  (SSI_FSYNC_LENGTH == SSI_FSYNC_WORD_LENGTH)
        #define SSI_RFSL     0
        #define SSI_TFSL     0
    #else
        #error SSI_FSYNC_LENGTH must be initialized in appconfig.h by the one of predefined value
    #endif

    #if    (SSI_SYNC_FARME_EARLY == SSI_FSYNC_BIT_BEFORE)
        #define SSI_REFS     1
        #define SSI_TEFS     1
    #elif  (SSI_SYNC_FARME_EARLY == SSI_FSYNC_BIT_FIRST)
        #define SSI_REFS     0
        #define SSI_TEFS     0
    #else
        #error SSI_FSYNC_FRAME_EARLY must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI CLOCK POLARITY CONFIGURATION ******/
    
    #if    (SSI_CLOCK_POLARITY == SSI_CLOCK_RISING_EDGE)
        #define SSI_RSCKP    1
        #define SSI_TSCKP    1
    #elif  (SSI_CLOCK_POLARITY == SSI_CLOCK_FALLING_EDGE)
        #define SSI_RSCKP    0
        #define SSI_TSCKP    0
    #else
        #error SSI_CLOCK_POLARITY must be initialized in appconfig.h by the one of predefined value
    #endif

    /****** SSI CLOCK RATE CONFIGURATION (REQUIRED FOR MASTER MODES) ******/

    #if    (SSI_PRESCALER_RANGE == SSI_PRESCALER_1)
        #define SSI_DIV4DIS  1
        #define SSI_PSR      0
    #elif  (SSI_PRESCALER_RANGE == SSI_PRESCALER_4)
        #define SSI_DIV4DIS  0
        #define SSI_PSR      0
    #elif  (SSI_PRESCALER_RANGE == SSI_PRESCALER_8)
        #define SSI_DIV4DIS  1
        #define SSI_PSR      1
    #elif  (SSI_PRESCALER_RANGE == SSI_PRESCALER_64)
        #define SSI_DIV4DIS  0
        #define SSI_PSR      1
    #else
        #error SSI_PRESCALER_RANGE must be initialized in appconfig.h by the one of predefined value
    #endif

    #if defined(SSI_PRESCALER_MODULE)
        #define SSI_PM0_7    SSI_PRESCALER_MODULE
    #else
        #error SSI_PRESCALER_RANGE must be initialized in appconfig.h
    #endif

    #define SSI_SCSR       \
        {                  \
            0, 0, 0, 0,    \
            0, 0, 0, 0,    \
            SSI_REFS,      \
            SSI_RFSL,      \
            SSI_RFSI,      \
            0, 0,          \
            SSI_RSCKP,     \
            SSI_RSHFD,     \
            SSI_DIV4DIS,   \
        }

    #define SSI_SCR2       \
        {                  \
            SSI_TEFS,      \
            SSI_TFSL,      \
            SSI_TFSI,      \
            SSI_NET,       \
            SSI_SSIEN,     \
            SSI_TSCKP,     \
            SSI_TSHFD,     \
            SSI_SYN,       \
            SSI_TXDIR,     \
            SSI_RXDIR,     \
            SSI_TFEN,      \
            SSI_RFEN,      \
            SSI_TE,        \
            SSI_RE,        \
            SSI_TIE,       \
            SSI_RIE,       \
        }

    #define SSI_STXCR      \
        {                  \
            SSI_PM0_7,     \
            SSI_DC0_4,     \
            SSI_WL0_1,     \
            SSI_PSR,       \
        }

    #define SSI_SRXCR      \
        {                  \
            SSI_PM0_7,     \
            SSI_DC0_4,     \
            SSI_WL0_1,     \
            SSI_PSR,       \
        }

    #define SSI_SFCSR      \
        {                  \
            SSI_TFWM0_3,   \
            SSI_RFWM0_3,   \
            0,             \
            0,             \
        }

    #define SSI_STR        \
        {                  \
            0,             \
        }

    #define SSI_SOR        \
        {                  \
            SSI_SYNRST,    \
            0,             \
            SSI_INIT,      \
            SSI_TFDIR,     \
            SSI_RFDIR,     \
            0,             \
        }

#endif /* INCLUDE_SSI */

/*==========================================================================*/

/****************************************************************************
*
* Default SSI Initialization
*
****************************************************************************/
#ifdef INCLUDE_SSI

/***************************************************************************************/
/* STXCR - SSI TX CONTROL REGISTER */
/* SRXCR - SSI RX CONTROL REGISTER */

#define SSI_PRESCALER_1              0x0000u  /* Fixed Prescaler Bypassed */
#define SSI_PRESCALER_8              0x8000u  /* Fixed divide-by-eight prescaler operational */

#define SSI_WORD_LENGTH_8            0x0000u  /* Number of bits/word = 8 */
#define SSI_WORD_LENGTH_10           0x2000u  /* Number of bits/word = 10 */
#define SSI_WORD_LENGTH_12           0x4000u  /* Number of bits/word = 12 */
#define SSI_WORD_LENGTH_16           0x6000u  /* Number of bits/word = 16 */

/***************************************************************************************/
/* SCSR - SSI CONTROL/STATUS REGISTER */

#define SSI_DIVIDE_MCU_CLOCK_4       0x0000u
#define SSI_DIVIDE_MCU_CLOCK_1       0x8000u

#define SSI_RX_SHIFT_DIR_LSB_FIRST   0x4000u
#define SSI_RX_SHIFT_DIR_MSB_FIRST   0x0000u

#define SSI_RX_CLK_POL_FALLING_EDGE  0x0000u
#define SSI_RX_CLK_POL_RISING_EDGE   0x2000u

#define SSI_RX_FRAME_SYNC_ACTIVE_HI  0x0000u
#define SSI_RX_FRAME_SYNC_ACTIVE_LOW 0x0400u

#define SSI_RX_ONE_WORD_FRAME_SYNC   0x0000u
#define SSI_RX_ONE_BIT_FRAME_SYNC    0x0200u

#define SSI_RX_FRAME_SYNC_FIRST_BIT  0x0000u
#define SSI_RX_FRAME_SYNC_EARLY      0x0100u

#define SSI_RX_DATA_REG_FULL         0x0080u
#define SSI_TX_DATA_REG_EMPTY        0x0040u
#define SSI_RX_OVERRUN               0x0020u
#define SSI_TX_UNDERRUN              0x0010u
#define SSI_TX_FRAME_SYNC            0x0008u
#define SSI_RX_FRAME_SYNC            0x0004u
#define SSI_RX_DATA_BUFFER_FULL      0x0002u
#define SSI_TX_DATA_BUFFER_EMPTY     0x0001u

/***************************************************************************************/
/* SCR2 - SSI CONTROL REGISTER 2 */

#define SSI_RX_INTERRUPT_DISABLE     0x0000u
#define SSI_RX_INTERRUPT_ENABLE      0x8000u

#define SSI_TX_INTERRUPT_DISABLE     0x0000u
#define SSI_TX_INTERRUPT_ENABLE      0x4000u

#define SSI_RX_DISABLE               0x0000u
#define SSI_RX_ENABLE                0x2000u

#define SSI_TX_DISABLE               0x0000u
#define SSI_TX_ENABLE                0x1000u

#define SSI_RX_FIFO_DISABLE          0x0000u
#define SSI_RX_FIFO_ENABLE           0x0800u

#define SSI_TX_FIFO_DISABLE          0x0000u
#define SSI_TX_FIFO_ENABLE           0x0400u

#define SSI_RX_CLK_EXTERNAL          0x0000u
#define SSI_RX_CLK_INTERNAL          0x0200u

#define SSI_TX_CLK_EXTERNAL          0x0000u
#define SSI_TX_CLK_INTERNAL          0x0100u

#define SSI_SYNC_MODE_DISABLED       0x0000u
#define SSI_SYNC_MODE_ENABLED        0x0080u

#define SSI_TX_SHIFT_DIR_MSB_FIRST   0x0000u
#define SSI_TX_SHIFT_DIR_LSB_FIRST   0x0040u

#define SSI_TX_CLK_POL_RISING_EDGE   0x0000u
#define SSI_TX_CLK_POL_FALLING_EDGE  0x0020u

#define SSI_DISABLE                  0x0000u
#define SSI_ENABLE                   0x0010u

#define SSI_NET_MODE_DISABLED        0x0000u
#define SSI_NET_MODE_ENABLED         0x0008u

#define SSI_TX_FRAME_SYNC_ACTIVE_HI  0x0000u
#define SSI_TX_FRAME_SYNC_ACTIVE_LOW 0x0004u

#define SSI_TX_ONE_WORD_FRAME_SYNC   0x0000u
#define SSI_TX_ONE_BIT_FRAME_SYNC    0x0002u

#define SSI_TX_FRAME_SYNC_FIRST_BIT  0x0000u
#define SSI_TX_FRAME_SYNC_EARLY      0x0001u

#define SSI_RX_FRAME_SYNC_EXTERNAL   0x0000u
#define SSI_RX_FRAME_SYNC_INTERNAL   0x0020u

#define SSI_TX_FRAME_SYNC_EXTERNAL   0x0000u
#define SSI_TX_FRAME_SYNC_INTERNAL   0x0010u

#define SSI_INIT_RESET_STATE_OFF     0x0000u
#define SSI_INIT_RESET_STATE_ON      0x0008u

#define SSI_FRAME_SYNC_RESET_OFF     0x0000u
#define SSI_FRAME_SYNC_RESET_ON      0x0001u


    #ifndef SSI_PRESCALER
        #define SSI_PRESCALER                     SSI_PRESCALER_1
    #endif

    #ifndef SSI_WORD_LENGTH
        #define SSI_WORD_LENGTH                   SSI_WORD_LENGTH_16
    #endif

    #ifndef SSI_DC
		#define SSI_DC                            2
	#endif

	#ifndef SSI_PM
		#define SSI_PM                            8
	#endif

	#ifndef SSI_FRAME_RATE_DIVIDER
		#define SSI_FRAME_RATE_DIVIDER           ((SSI_DC-1) << 8)
	#endif

	#ifndef SSI_PRESCALE_MODULUS
		#define SSI_PRESCALE_MODULUS              (SSI_PM-1)
	#endif

	#ifndef SSI_RXTX_CONTROL_INITIAL_STATE
		#define SSI_RXTX_CONTROL_INITIAL_STATE   (SSI_PRESCALER          | \
                                                  SSI_WORD_LENGTH        | \
                                                  SSI_FRAME_RATE_DIVIDER | \
                                                  SSI_PRESCALE_MODULUS)
	#endif

    #ifndef SSI_DIV4DIS
        #define SSI_DIV4DIS                      SSI_DIVIDE_MCU_CLOCK_1
    #endif

    #ifndef SSI_RSHFD
        #define SSI_RSHFD                        SSI_RX_SHIFT_DIR_MSB_FIRST
    #endif

    #ifndef SSI_RSCKP
        #define SSI_RSCKP                        SSI_RX_CLK_POL_FALLING_EDGE
    #endif

    #ifndef SSI_RFSI
        #define SSI_RFSI                         SSI_RX_FRAME_SYNC_ACTIVE_LOW
    #endif

    #ifndef SSI_RFSL
        #define SSI_RFSL                         SSI_RX_ONE_WORD_FRAME_SYNC
    #endif

    #ifndef SSI_REFS
        #define SSI_REFS                         SSI_RX_FRAME_SYNC_FIRST_BIT
    #endif

    #ifndef SSI_CONTROL_STATUS_INITIAL_STATE
		#define SSI_CONTROL_STATUS_INITIAL_STATE   (SSI_DIV4DIS | \
                                                    SSI_RSHFD   | \
                                                    SSI_RSCKP   | \
                                                    SSI_RFSI    | \
                                                    SSI_RFSL    | \
                                                    SSI_REFS)
	#endif

    #ifndef SSI_RIE
        #define SSI_RIE                          SSI_RX_INTERRUPT_ENABLE
    #endif

    #ifndef SSI_RE
        #define SSI_RE                           SSI_RX_ENABLE
    #endif

    #ifndef SSI_RFEN
        #define SSI_RFEN                         SSI_RX_FIFO_ENABLE
    #endif

    #ifndef SSI_RXDIR
        #define SSI_RXDIR                        SSI_RX_CLK_INTERNAL
    #endif

    #ifndef SSI_TIE
        #define SSI_TIE                          SSI_TX_INTERRUPT_ENABLE
    #endif

    #ifndef SSI_TE
        #define SSI_TE                           SSI_TX_ENABLE
    #endif

    #ifndef SSI_TFEN
        #define SSI_TFEN                         SSI_TX_FIFO_ENABLE
    #endif

    #ifndef SSI_TXDIR
        #define SSI_TXDIR                        SSI_TX_CLK_INTERNAL
    #endif

    #ifndef SSI_SYN
        #define SSI_SYN                          SSI_SYNC_MODE_DISABLED
    #endif

    #ifndef SSI_TSHFD
        #define SSI_TSHFD                        SSI_TX_SHIFT_DIR_MSB_FIRST
    #endif

    #ifndef SSI_TSCKP
        #define SSI_TSCKP                        SSI_TX_CLK_POL_FALLING_EDGE
    #endif

    #ifndef SSI_SSIEN
        #define SSI_SSIEN                        SSI_DISABLE
    #endif

    #ifndef SSI_NET
        #define SSI_NET                          SSI_NET_MODE_ENABLED
    #endif

    #ifndef SSI_TFSI
        #define SSI_TFSI                         SSI_TX_FRAME_SYNC_ACTIVE_LOW
    #endif

    #ifndef SSI_TFSL
        #define SSI_TFSL                         SSI_TX_ONE_WORD_FRAME_SYNC
    #endif

    #ifndef SSI_TEFS
        #define SSI_TEFS                         SSI_TX_FRAME_SYNC_FIRST_BIT
    #endif

	#ifndef SSI_CONTROL2_INITIAL_STATE
		#define SSI_CONTROL2_INITIAL_STATE  (SSI_RIE   | \
                                             SSI_RE    | \
                                             SSI_RFEN  | \
                                             SSI_RXDIR | \
                                             SSI_TIE   | \
                                             SSI_TE    | \
                                             SSI_TFEN  | \
                                             SSI_TXDIR | \
                                             SSI_SYN   | \
                                             SSI_TSHFD | \
                                             SSI_TSCKP | \
                                             SSI_SSIEN | \
                                             SSI_NET   | \
                                             SSI_TFSI  | \
                                             SSI_TFSL  | \
                                             SSI_TEFS )
	#endif

    #ifndef SSI_RFCNT
        #define SSI_RFCNT                    8
    #endif

    #ifndef SSI_TFCNT
        #define SSI_TFCNT                    8
    #endif

    #ifndef SSI_RFWM
        #define SSI_RFWM                     2  /* 8 */
    #endif

    #ifndef SSI_TFWM
        #define SSI_TFWM                     4  /* 1 */
    #endif

    #ifndef SSI_RX_FIFO_COUNTER
        #define SSI_RX_FIFO_COUNTER          (SSI_RFCNT << 12)
    #endif

    #ifndef SSI_TX_FIFO_COUNTER
        #define SSI_TX_FIFO_COUNTER          (SSI_TFCNT << 8)
    #endif

    #ifndef SSI_RX_FIFO_FULL_WATERMARK
        #define SSI_RX_FIFO_FULL_WATERMARK   (SSI_RFWM << 4)
    #endif

    #ifndef SSI_TX_FIFO_EMPTY_WATERMARK
        #define SSI_TX_FIFO_EMPTY_WATERMARK  SSI_TFWM
    #endif

	#ifndef SSI_FIFO_CNTL_INITIAL_STATE
		#define SSI_FIFO_CNTL_STAT_INITIAL_STATE  (SSI_RX_FIFO_FULL_WATERMARK | \
                                                   SSI_TX_FIFO_EMPTY_WATERMARK )
	#endif

    #ifndef SSI_RFDIR
        #define SSI_RFDIR                          SSI_RX_FRAME_SYNC_INTERNAL
    #endif

    #ifndef SSI_TFDIR
        #define SSI_TFDIR                          SSI_TX_FRAME_SYNC_INTERNAL
    #endif

    #ifndef SSI_INIT
        #define SSI_INIT                           SSI_INIT_RESET_STATE_OFF
    #endif

    #ifndef SSI_SYNRST
        #define SSI_SYNRST                         SSI_FRAME_SYNC_RESET_OFF
    #endif

	#ifndef SSI_OPTION_REGISTER_INITIAL_STATE
		#define SSI_OPTION_REGISTER_INITIAL_STATE  (SSI_RFDIR | \
                                                    SSI_TFDIR | \
                                                    SSI_INIT  | \
                                                    SSI_SYNRST )
	#endif

#endif


/****************************************************************************
*
* Default Codec Initialization
*
****************************************************************************/
#ifdef INCLUDE_CODEC
	#ifndef INCLUDE_IO
		#error IO component must be defined for CODEC operation
	#endif

	#include "codec.h"
	
    #ifndef CODEC_MASK
        #define CODEC_MASK                        CODEC_INTERRUPT_MASKED
    #endif

    #ifndef CODEC_DO1
        #define CODEC_DO1                         CODEC_DIGITAL_OUTPUT_1_LOW
    #endif

    #ifndef CODEC_LEFT_D2A_ATTENUATION
        #define CODEC_LEFT_D2A_ATTENUATION        0 /* 0 to 31 */
    #endif
    
    #ifndef CODEC_LA
        #define CODEC_LA                          (CODEC_LEFT_D2A_ATTENUATION << 5)
    #endif

    #ifndef CODEC_RIGHT_D2A_ATTENUATION
        #define CODEC_RIGHT_D2A_ATTENUATION       0 /* 0 to 31 */
    #endif

    #ifndef CODEC_RA
        #define CODEC_RA                          CODEC_RIGHT_D2A_ATTENUATION
    #endif

    #ifndef CODEC_MUTE
        #define CODEC_MUTE                        CODEC_MUTE_DISABLED
    #endif

    #ifndef CODEC_ISL
        #define CODEC_ISL                         CODEC_LEFT_INPUT_LINE_1
    #endif
    
    #ifndef CODEC_ISR
        #define CODEC_ISR                         CODEC_RIGHT_INPUT_LINE_1
    #endif

    #ifndef CODEC_LEFT_A2D_GAIN    
        #define CODEC_LEFT_A2D_GAIN               2  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_LG
        #define CODEC_LG                          (CODEC_LEFT_A2D_GAIN << 4)
    #endif

    #ifndef CODEC_RIGHT_A2D_GAIN
        #define CODEC_RIGHT_A2D_GAIN              2  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_RG
        #define CODEC_RG                          (CODEC_RIGHT_A2D_GAIN)
    #endif
   
	#ifndef CODEC_RX_CONTROL_WORD
		#define CODEC_RX_CONTROL_WORD             (CODEC_MUTE | \
                                                   CODEC_ISL  | \
                                                   CODEC_ISR  | \
                                                   CODEC_LG   | \
                                                   CODEC_RG)
	#endif

	#ifndef CODEC_TX_CONTROL_WORD
		#define CODEC_TX_CONTROL_WORD             (CODEC_MASK | \
                                                   CODEC_DO1  | \
                                                   CODEC_LA   | \
                                                   CODEC_RA)
	#endif


	#ifndef CODEC_FIFO_SIZE
		#define CODEC_FIFO_SIZE                   1024
	#endif

	#ifndef CODEC_FIFO_THRESHOLD
		#define CODEC_FIFO_THRESHOLD              512
	#endif

	#ifndef CODEC_OPTIMIZATION_BUFFER_SIZE
		#define CODEC_OPTIMIZATION_BUFFER_SIZE    512
	#endif
	
	#ifndef CODEC_MODE
	    #define CODEC_MODE                        CODEC_STEREO
	#endif
	
#endif

/****************************************************************************
*
* Default FastCodec Initialization
*
****************************************************************************/

#ifdef INCLUDE_FCODEC
	#ifndef INCLUDE_IO
		#error IO component must be defined for FCODEC operation
	#endif

	#include "fcodec.h"
	
    #ifndef CODEC_MASK
        #define CODEC_MASK                        CODEC_INTERRUPT_MASKED
    #endif

    #ifndef CODEC_DO1
        #define CODEC_DO1                         CODEC_DIGITAL_OUTPUT_1_LOW
    #endif

    #ifndef CODEC_LEFT_D2A_ATTENUATION
        #define CODEC_LEFT_D2A_ATTENUATION        0 /* 0 to 31 */
    #endif
    
    #ifndef CODEC_LA
        #define CODEC_LA                          (CODEC_LEFT_D2A_ATTENUATION << 5)
    #endif

    #ifndef CODEC_RIGHT_D2A_ATTENUATION
        #define CODEC_RIGHT_D2A_ATTENUATION       0 /* 0 to 31 */
    #endif

    #ifndef CODEC_RA
        #define CODEC_RA                          CODEC_RIGHT_D2A_ATTENUATION
    #endif

    #ifndef CODEC_MUTE
        #define CODEC_MUTE                        CODEC_MUTE_DISABLED
    #endif

    #ifndef CODEC_ISL
        #define CODEC_ISL                         CODEC_LEFT_INPUT_LINE_1
    #endif
    
    #ifndef CODEC_ISR
        #define CODEC_ISR                         CODEC_RIGHT_INPUT_LINE_1
    #endif

    #ifndef CODEC_LEFT_A2D_GAIN    
        #define CODEC_LEFT_A2D_GAIN               2  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_LG
        #define CODEC_LG                          (CODEC_LEFT_A2D_GAIN << 4)
    #endif

    #ifndef CODEC_RIGHT_A2D_GAIN
        #define CODEC_RIGHT_A2D_GAIN              2  /* 0 to 15 */
    #endif
    
    #ifndef CODEC_RG
        #define CODEC_RG                          (CODEC_RIGHT_A2D_GAIN)
    #endif
   
	#ifndef CODEC_RX_CONTROL_WORD
		#define CODEC_RX_CONTROL_WORD             (CODEC_MUTE | \
                                                   CODEC_ISL  | \
                                                   CODEC_ISR  | \
                                                   CODEC_LG   | \
                                                   CODEC_RG)
	#endif

	#ifndef CODEC_TX_CONTROL_WORD
		#define CODEC_TX_CONTROL_WORD             (CODEC_MASK | \
                                                   CODEC_DO1  | \
                                                   CODEC_LA   | \
                                                   CODEC_RA)
	#endif


	#ifndef CODEC_FIFO_SIZE
		#define CODEC_FIFO_SIZE                   1024
	#endif

	#ifndef CODEC_FIFO_THRESHOLD
		#define CODEC_FIFO_THRESHOLD              512
	#endif

	#ifndef CODEC_OPTIMIZATION_BUFFER_SIZE
		#define CODEC_OPTIMIZATION_BUFFER_SIZE    512
	#endif
	
	#ifndef CODEC_MODE
	    #define CODEC_MODE                        CODEC_STEREO
	#endif
	
#endif




/****************************************************************************
*
* Default FILE I/O driver Initialization
*
****************************************************************************/
#ifdef INCLUDE_FILEIO


   #include "fileiodrv.h"

#endif

/****************************************************************************
*
* Default GPIO driver Initialization
*
****************************************************************************/
#ifdef INCLUDE_GPIO

   #include "gpio.h"

#endif

/****************************************************************************
*
* Default LED Initialization
*
****************************************************************************/
#ifdef INCLUDE_LED

	#include "led.h"

#endif

/****************************************************************************
*
* Default Button Initialization
*
****************************************************************************/
#ifdef INCLUDE_BUTTON

	#include "button.h"

	#ifdef BSP_DEVICE_NAME_BUTTON_A
		#ifndef NORMAL_ISR_8
			#if (GPR_INT_PRIORITY_8 != 0)
				#define NORMAL_ISR_8 buttonISRA
			#endif
		#endif
	#endif
	
	#ifdef BSP_DEVICE_NAME_BUTTON_B
		#ifndef NORMAL_ISR_9
			#if (GPR_INT_PRIORITY_9 != 0)
				#define NORMAL_ISR_9 buttonISRB
			#endif
		#endif
	#endif
	
#endif


/****************************************************************************
*
* Default PC Master Initialization
*
****************************************************************************/
#ifdef INCLUDE_PCMASTER

		/* SCI communication algorithm for PC Master */
		#include "pcmasterdrv.h"

		#if !defined(PC_MASTER_REC_BUFF_LEN)
			/* Recorder buffer length */
			#define	PC_MASTER_REC_BUFF_LEN	40						
		#endif 

		#if !defined(PC_MASTER_APPCMD_BUFF_LEN)
			/* Application Command buffer length */
			#define PC_MASTER_APPCMD_BUFF_LEN	0					
		#endif 

		#if !defined(PC_MASTER_RECORDER_TIME_BASE)
			/* Recorder timebase = 50us */
			#define PC_MASTER_RECORDER_TIME_BASE	0x8030  		
		#endif 

		#if !defined(PC_MASTER_GLOB_VERSION_MAJOR)
			/* board firmware version major number */
			#define PC_MASTER_GLOB_VERSION_MAJOR	0				
		#endif
		
		#if !defined(PC_MASTER_GLOB_VERSION_MINOR)
			/* board firmware version minor number */
			#define PC_MASTER_GLOB_VERSION_MINOR	0				
		#endif
		
		#if !defined(PC_MASTER_IDT_STRING)
			/* device identification string */ 
			#define PC_MASTER_IDT_STRING "PC Master communication !"	
		#endif

#endif

	
/****************************************************************************
*
* Serial Bootloader start delay
*
****************************************************************************/

/* Default delay for serial bootloader is 30 second */
#ifndef BSP_BOOTLOADER_DELAY
   #define BSP_BOOTLOADER_DELAY 30u
#endif

#if (BSP_BOOTLOADER_DELAY < 0)
   #undef  BSP_BOOTLOADER_DELAY 
   #define BSP_BOOTLOADER_DELAY 30u
#endif   

#if (BSP_BOOTLOADER_DELAY > 0x00ff)
   #undef  BSP_BOOTLOADER_DELAY 
   #define BSP_BOOTLOADER_DELAY 0x00ffu
#endif   



	/* TBD */


#ifdef __cplusplus
}
#endif

#endif






























#ifndef __APPCONFIG_H
#define __APPCONFIG_H

/*****************************************************************************
*
* Include needed SDK components below by changing #undef to #define.
* Refer to ../config/config.h for complete list of all components and
* component default initialization.
*
*****************************************************************************/

#define  INCLUDE_BSP          /* BSP support - includes SIM, COP, CORE, PLL, and ITCN */

#undef  INCLUDE_ADC           /* ADC support */
#undef  INCLUDE_BLDC          /* BLDC library */
#define INCLUDE_BUTTON        /* Button support */
#undef  INCLUDE_CAN           /* CAN support */
#undef  INCLUDE_COP           /* COP support (subset of BSP) */
#undef  INCLUDE_CORE          /* CORE support (subset of BSP) */
#undef  INCLUDE_DECODER       /* Quadrature Decoder support */
#undef  INCLUDE_DSPFUNC       /* DSP Function library */
#undef  INCLUDE_FILEIO        /* File I/O support */
#undef  INCLUDE_FLASH         /* Flash support */
#undef  INCLUDE_GPIO          /* General Purpose I/O support */
#define INCLUDE_IO            /* I/O support */
#undef  INCLUDE_ITCN          /* ITCN support (subset of BSP) */
#undef  INCLUDE_LED           /* LED support for target board */
#undef  INCLUDE_MCFUNC        /* Motor Control functional library */
#undef  INCLUDE_MEMORY        /* Memory support */
#undef  INCLUDE_PCMASTER      /* PC Master support */
#undef  INCLUDE_PLL           /* PLL support (subset of BSP) */
#undef  INCLUDE_PWM           /* PWM support */
#undef  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_SIM           /* SIM support (subset of BSP) */
#undef  INCLUDE_SPI           /* SPI support */
#undef  INCLUDE_STACK_CHECK   /* Stack utilization routines */
#undef  INCLUDE_SWITCH        /* Switch support */
#define INCLUDE_TIMER         /* Timer support */


/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/


#endif
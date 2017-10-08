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


#undef  INCLUDE_3DES          /* 3des library */
#undef  INCLUDE_ADC           /* ADC support */
#undef  INCLUDE_AEC           /* AEC library */
#undef  INCLUDE_BUTTON        /* Button support */
#undef  INCLUDE_CALLER_ID     /* CallerID library */
#undef  INCLUDE_CAS_DETECT    /* CAS_detect library */
#undef  INCLUDE_CODEC         /* Codec driver */
#undef  INCLUDE_COP           /* COP support (subset of BSP) */
#undef  INCLUDE_CORE          /* CORE support (subset of BSP) */
#undef  INCLUDE_CPT           /* CPT library */
#undef  INCLUDE_DES           /* DES library */
#undef  INCLUDE_DSPFUNC       /* DSP Function library */
#undef  INCLUDE_DTMF_DET      /* DTMF detect library */
#undef  INCLUDE_DTMF_GEN      /* DTMF generation library */
#undef  INCLUDE_EEPROM        /* EEprom support */
#define  INCLUDE_FILEIO        /* File I/O support */
#undef  INCLUDE_FLASH         /* Flash support */
#undef  INCLUDE_G165          /* G165 vocoder library */
#undef  INCLUDE_G711          /* G711 vocoder library */
#undef  INCLUDE_G726          /* G726 vocoder library */
#define  INCLUDE_GPIO          /* General Purpose I/O support */
#define  INCLUDE_IO            /* I/O support */
#undef  INCLUDE_ITCN          /* ITCN support (subset of BSP) */
#undef  INCLUDE_LED           /* LED support for target board */
#undef  INCLUDE_MEMORY        /* Memory support */
#undef  INCLUDE_PCMASTER      /* PC Master support */
#undef  INCLUDE_PLL           /* PLL support (subset of BSP) */
#undef  INCLUDE_QUAD_TIMER    /* Quadrature timer support */
#undef  INCLUDE_SCI           /* SCI support */
#undef  INCLUDE_SIM           /* SIM support (subset of BSP) */
#undef  INCLUDE_SPI           /* SPI support */
#undef  INCLUDE_SSI           /* SSI support */
#undef  INCLUDE_STACK_CHECK   /* Stack utilization routines */
#undef  INCLUDE_TIMER         /* Timer support */
#undef  INCLUDE_VAD           /* VAD library */
#undef  INCLUDE_V8BIS         /* V8bis library */
#undef  INCLUDE_V22           /* V22 library */
#undef  INCLUDE_V42BIS        /* V42bis library */






/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/


#endif

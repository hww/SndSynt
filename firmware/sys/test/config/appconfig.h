/* Refer to config/config.h for complete list of all components and
	component default initialization */

/*****************************************************************************
*
* Include needed SDK components
*
*****************************************************************************/

#define INCLUDE_BSP          /* BSP support */
#define INCLUDE_MEMORY       /* Memory support */
#define INCLUDE_DSPFUNC      /* DSP Function Library */
#define INCLUDE_IO           /* IO support */
#define INCLUDE_TIMER        /* Timer support */
#define INCLUDE_STACK_CHECK  /* Check stack overflow */


/*****************************************************************************
*
* Overwrite default component initializations from config/config.h
* using #defines here
*
*****************************************************************************/


#define GPR_INT_PRIORITY_4  1   /* Enable SWI Interrupt */
#define GPR_INT_PRIORITY_37 2   /* Set interrupt priority for nesting */


/* Timers */
#define INCLUDE_USER_TIMER_A_1  1
#define INCLUDE_USER_TIMER_A_2  1
#define INCLUDE_USER_TIMER_A_3  1


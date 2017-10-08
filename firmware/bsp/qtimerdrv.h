/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: qtimerdrv.h
*
* Description: header file for the quadrature timer driver
*
*****************************************************************************/



#ifndef __QTIMERDRV_H
#define __QTIMERDRV_H


#include "port.h"
#include "periph.h"
#include "quadraturetimer.h"
#include "time.h"
#include "timer.h"


#ifdef __cplusplus
extern "C" {
#endif


/*** quadrature timer device context ***/
typedef struct 
{
    qt_sCallback            CallbackOnOverflow;
    qt_sCallback            CallbackOnInputEdge;
    qt_sCallback            CallbackOnCompare;
} qt_tQTContext;

/*** quadrature timer configuration table ***/
typedef struct 
{   
    arch_sTimerChannel * base;
    qt_tQTContext*       ctx;
}qt_tQTConfig;


/*** control bits ***/
#define QTB_COUNTMODE( mode )        ((mode + 0) << 13)
#define QTB_PRIMARYSOURCE( src )     ((src) << 9 )
#define QTB_SECONDARYSOURCE( src )   ((src) << 7 )
#define QTB_OUTPUTMODE( src )        ((src) & 0x0007)
           

#define QTB_ONCE        0x0040
#define QTB_LENGTH      0x0020
#define QTB_DIR         0x0010
#define QTB_EXTINIT     0x0008


/* status bits */

#define QTB_OEN         0x0001     /* Output Enable */
#define QTB_OPS         0x0002     /* Output Polarity Select  */
#define QTB_FORCE       0x0004     /* Force the OFLAG output */
#define QTB_VAL         0x0008     /* Forced OFLAG Value */
#define QTB_EEOF        0x0010     /* Enable External OFLAG Force */
#define QTB_MSTR        0x0020     /* Master Mode */
#define QTB_INPUT       0x0100     /* External Input Signal */
#define QTB_IPS         0x0200     /* Input Polarity Select */
#define QTB_IEFIE       0x0400     /* Input Edge Flag Interrupt Enable */
#define QTB_IEF         0x0800     /* Input Edge Flag */
#define QTB_TOFIE       0x1000     /* Timer Overflow Flag Interrupt Enable */
#define QTB_TOF         0x2000     /* Timer Overflow Flag */
#define QTB_TCFIE       0x4000     /* Timer Compare Flag Interrupt Enable */
#define QTB_TCF         0x8000     /* Timer Compare Flag */

#define QTB_CM_LOW      0x0040     /* Capture mode, low bit */
#define QTB_CM_HIGH     0x0080     /* Capture mode, low bit */
	
	/* Input Capture Mode */
#define QTB_CAPTUREMODE( cmode )     (   ((cmode) << 6 )   )


/* 
	Declare quad timer data structures that are found in pramdata.c
*/
EXPORT qt_tQTContext   qt_ctx_A_0;
EXPORT qt_tQTContext   qt_ctx_A_1;
EXPORT qt_tQTContext   qt_ctx_A_2;
EXPORT qt_tQTContext   qt_ctx_A_3;

/* QT ISR prototypes */
void QTimerISRA0(void);
void QTimerISRA1(void);
void QTimerISRA2(void);
void QTimerISRA3(void);

/* QT Super ISR prototypes */
void QTimerSuperISRA0(void);
void QTimerSuperISRA1(void);
void QTimerSuperISRA2(void);
void QTimerSuperISRA3(void);


EXPORT const UWord16      qtExtAMode[];
EXPORT const UWord16      qtExtAMask[];
EXPORT const qt_tQTConfig qtDeviceMap[];

EXPORT const int          qtNumberOfDevices;
EXPORT const UWord32      qtINPUT_FREQUENCY;


/* qtimerIoctl inline functions */

#define qtIoctl(FD, Cmd, pParams, DeviceName)  qtIoctl##Cmd(DeviceName, pParams)


#define qtIoctlQT_DISABLE(bspDevice, pParams ) \
    		periphBitClear( 0xE000, &((arch_sTimerChannel*)bspDevice)->ControlReg )
  
#define qtIoctlQT_ENABLE_OUTPUT(bspDevice, pParams ) \
    		periphBitSet( QTB_OEN, &((arch_sTimerChannel*)bspDevice)->StatusControlReg )
  
#define qtIoctlQT_DISABLE_OUTPUT(bspDevice, pParams ) \
    		periphBitClear( QTB_OEN, &((arch_sTimerChannel*)bspDevice)->StatusControlReg )
  
#define qtIoctlQT_FORCE_OUTPUT(bspDevice, pParams ) \
  			{ if (pParams) \
  			  { \
  			  	periphBitSet( QTB_VAL, &((arch_sTimerChannel*)bspDevice)->StatusControlReg ); \
  			  } \
    		  else \
    		  { \
    		  	periphBitClear( QTB_VAL, &((arch_sTimerChannel*)bspDevice)->StatusControlReg ); \
    		  } \
    		  periphBitSet( QTB_FORCE, &((arch_sTimerChannel*)bspDevice)->StatusControlReg ); \
  			}

#define qtIoctlQT_GET_STATUS(bspDevice, pParams ) \
    		periphMemRead(&((arch_sTimerChannel*)bspDevice)->StatusControlReg)

#define qtIoctlQT_WRITE_COMPARE_VALUE1(bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->CompareReg1 )

#define qtIoctlQT_WRITE_COMPARE_VALUE2(bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->CompareReg2 )

#define qtIoctlQT_WRITE_INITIAL_LOAD_VALUE(bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->LoadReg )

#define qtIoctlQT_ENABLE_CAPTURE_REG(bspDevice, Dummy ) \
    		periphBitClear( QTB_IEF, &((arch_sTimerChannel*)bspDevice)->StatusControlReg )

#define qtIoctlQT_READ_CAPTURE_REG( bspDevice, Dummy ) \
    		periphMemRead(&((arch_sTimerChannel*)bspDevice)->CaptureReg)

#define qtIoctlQT_READ_HOLD_REG( bspDevice, Dummy ) \
    		periphMemRead(&((arch_sTimerChannel*)bspDevice)->HoldReg)

#define qtIoctlQT_READ_COUNTER_REG( bspDevice, Dummy ) \
    		periphMemRead(&((arch_sTimerChannel*)bspDevice)->CounterReg)
    
#define qtIoctlQT_WRITE_COUNTER_REG( bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->CounterReg)
    
#define qtIoctlQT_FAST_RESTART( bspDevice, mode, ) \
    		periphMemWrite( \
        		((periphMemRead(&((arch_sTimerChannel*)bspDevice)->ControlReg) \
          				& 0x1FFF ) | QTB_COUNTMODE( mode ) ), \
        		&&((arch_sTimerChannel*)bspDevice)->ControlReg )

#define qtIoctlQT_DISABLE_CALLBACK( bspDevice, iType ) \
    		periphBitClear( iType == qtCompare ? QTB_TCFIE \
        						: iType == qtOverflow ? QTB_TOFIE : QTB_IEFIE, \
        					&((arch_sTimerChannel*)bspDevice)->StatusControlReg )

#define qtIoctlQT_ENABLE_CALLBACK( bspDevice, iType ) \
    		periphBitSet( iType == qtCompare ? QTB_TCFIE  \
        						: iType == qtOverflow ? QTB_TOFIE : QTB_IEFIE, \
        					&((arch_sTimerChannel*)bspDevice)->StatusControlReg )

#define qtIoctlQT_SET_INPUT_CAPTURE_MODE( bspDevice, iType  ) \
			{ \
				periphBitSet( ((iType & qtRisingEdge? QTB_CM_LOW : 0)  \
                       			| ( iType & qtFallingEdge? QTB_CM_HIGH : 0 )),  \
                       		&((arch_sTimerChannel*)bspDevice)->StatusControlReg ); \
                periphBitClear( (((iType & qtRisingEdge) == 0? QTB_CM_LOW : 0) \
                       			| ( (iType & qtFallingEdge) == 0? QTB_CM_HIGH : 0 )), \
                       		&((arch_sTimerChannel*)bspDevice)->StatusControlReg ); \
              }

#define qtIoctlQT_ENABLE(bspDevice, pParams) \
			ioctlQT_ENABLE(qtFindDevice(bspDevice), (qt_sState *)pParams)

#define qtIoctlQT_GET_INPUT_CLK_FREQ(bspDevice, pParams) \
			{ *((UInt32 *) pParams) = qtINPUT_FREQUENCY; }

#define qtIoctlQT_LOAD_COMPARATOR_LOAD_REG1(bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->ComparatorLoad1 )

#define qtIoctlQT_LOAD_COMPARATOR_LOAD_REG2(bspDevice, Value ) \
    		periphMemWrite( Value, &((arch_sTimerChannel*)bspDevice)->ComparatorLoad2 )

/*****************************************************************************
* Prototypes - See documentation for functional descriptions
******************************************************************************/

/* prototypes for ioctl API functions */
int     qtOpen (const char * pName, int OFlags, qt_sState * pParams);
int     qtClose (int FileDesc);

int     qtFindDevice (const char * pName); /* private to driver */

UWord16 ioctlQT_ENABLE (int FileDesc, qt_sState * pParams);

/* EXPORT Result qtCreate(const char * pName) */
#define qtCreate(name) (PASS)



/* services for assembler optimization */

#ifdef __cplusplus
}
#endif

#endif

/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: qtimerdrvIO.h
*
* Description: header file for the quadrature timer I/O driver interface
*
*****************************************************************************/



#ifndef __QTIMERDRVIO_H
#define __QTIMERDRVIO_H


#include "port.h"

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_QUAD_TIMER
		#error INCLUDE_IO_QUAD_TIMER must be defined in appconfig.h to initialize the IO Layer for the Quadrature Timer Driver
	#endif
#endif


#include "periph.h"
#include "quadraturetimer.h"
#include "io.h"
#include "fcntl.h"


#ifdef __cplusplus
extern "C" {
#endif


/*****************************************************************************
* ioctl implementation
******************************************************************************/

#define ioctlQT_DISABLE(pHandle,pParams) \
		qtIoctlQT_DISABLE((((qt_tQTConfig*)pHandle)->base),pParams)
  
#define ioctlQT_ENABLE_OUTPUT(pHandle, pParams) \
		qtIoctlQT_ENABLE_OUTPUT((((qt_tQTConfig*)pHandle)->base), pParams)
  
#define ioctlQT_DISABLE_OUTPUT(pHandle, pParams) \
		qtIoctlQT_DISABLE_OUTPUT((((qt_tQTConfig*)pHandle)->base), pParams)
  
#define ioctlQT_FORCE_OUTPUT(pHandle, pParams) \
		qtIoctlQT_FORCE_OUTPUT((((qt_tQTConfig*)pHandle)->base), pParams)

#define ioctlQT_GET_STATUS(pHandle, pParams) \
		qtIoctlQT_GET_STATUS((((qt_tQTConfig*)pHandle)->base), pParams)

#define ioctlQT_WRITE_COMPARE_VALUE1(pHandle, Value) \
		qtIoctlQT_WRITE_COMPARE_VALUE1((((qt_tQTConfig*)pHandle)->base), Value)

#define ioctlQT_WRITE_COMPARE_VALUE2(pHandle, Value) \
		qtIoctlQT_WRITE_COMPARE_VALUE2((((qt_tQTConfig*)pHandle)->base), Value)

#define ioctlQT_WRITE_INITIAL_LOAD_VALUE(pHandle, Value) \
		qtIoctlQT_WRITE_INITIAL_LOAD_VALUE((((qt_tQTConfig*)pHandle)->base), Value)

#define ioctlQT_ENABLE_CAPTURE_REG(pHandle, Dummy) \
		qtIoctlQT_ENABLE_CAPTURE_REG((((qt_tQTConfig*)pHandle)->base), Dummy)

#define ioctlQT_READ_CAPTURE_REG( pHandle, Dummy ) \
		qtIoctlQT_READ_CAPTURE_REG((((qt_tQTConfig*)pHandle)->base), Dummy)

#define ioctlQT_READ_HOLD_REG( pHandle, Dummy) \
		qtIoctlQT_READ_HOLD_REG((((qt_tQTConfig*)pHandle)->base), Dummy)

#define ioctlQT_READ_COUNTER_REG( pHandle, Dummy) \
		qtIoctlQT_READ_COUNTER_REG((((qt_tQTConfig*)pHandle)->base), Dummy)
    
#define ioctlQT_WRITE_COUNTER_REG( pHandle, Value) \
		qtIoctlQT_WRITE_COUNTER_REG((((qt_tQTConfig*)pHandle)->base), Value)
    
#define ioctlQT_FAST_RESTART( pHandle, mode ) \
		qtIoctlQT_FAST_RESTART((((qt_tQTConfig*)pHandle)->base), mode)

#define ioctlQT_DISABLE_CALLBACK( pHandle, iType ) \
		qtIoctlQT_DISABLE_CALLBACK((((qt_tQTConfig*)pHandle)->base), iType)

#define ioctlQT_ENABLE_CALLBACK( pHandle, iType ) \
		qtIoctlQT_ENABLE_CALLBACK((((qt_tQTConfig*)pHandle)->base), iType)

#define ioctlQT_SET_INPUT_CAPTURE_MODE( pHandle, iType ) \
		qtIoctlQT_SET_INPUT_CAPTURE_MODE((((qt_tQTConfig*)pHandle)->base), iType)

#define ioctlQT_GET_INPUT_CLK_FREQ(pHandle, pParams) \
		qtIoctlQT_GET_INPUT_CLK_FREQ((((qt_tQTConfig*)pHandle)->base), pParams)

#define ioctlQT_LOAD_COMPARATOR_LOAD_REG1(pHandle, Value) \
		qtIoctlQT_LOAD_COMPARATOR_LOAD_REG1((((qt_tQTConfig*)pHandle)->base), Value)

#define ioctlQT_LOAD_COMPARATOR_LOAD_REG2(pHandle, Value) \
		qtIoctlQT_LOAD_COMPARATOR_LOAD_REG2((((qt_tQTConfig*)pHandle)->base), Value)  		

/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT io_sDriver * qtdrvIOOpen(const  char * pName, int OFlags, ...);

/* EXPORT Result qtdrvIOCreate(const char * pName) */
#define qtdrvIOCreate(name) qtCreate(name)


#ifdef __cplusplus
}
#endif

#endif

/*****************************************************************************
*
* buttondrv.h - header file for the Button driver
*
*****************************************************************************/


#ifndef __BUTTONDRV_H
#define __BUTTONDRV_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_BUTTON
		#error INCLUDE_BUTTON must be defined in appconfig.h to initialize the LED Library
	#endif
#endif


#include "port.h"
#include "time.h"
#include "button.h"


#ifdef __cplusplus
extern "C" {
#endif


void buttonISRA(void);
void buttonISRB(void);

typedef struct {
	struct timespec    DebounceTimeExp;
	button_sCallback   Callback;
} button_sButton;


/*****************************************************************************
* Prototypes - See documentation for functional descriptions
******************************************************************************/

int buttonOpen  (const char * pName, int OFlags, button_sCallback * pCallbackParam);
int buttonClose (int FileDesc);


/* EXPORT Result buttonCreate(const char * pName) */
#define buttonCreate(name) (PASS)


#ifdef __cplusplus
}
#endif

#endif
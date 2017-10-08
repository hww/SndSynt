/*****************************************************************************
*
* buttondrvIO.c - Button driver
*
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "io.h"
#include "fcntl.h"

#include "stdarg.h"

#include "bsp.h"
#include "button.h"
#include "const.h"

						
/*****************************************************************************/
io_sDriver * buttondrvIOOpen(const char * pName, int OFlags, ...)
{
	va_list            Args;
	button_sCallback * pCallbackParam;
	int                buttonFD;
			
#if 0
	va_start(Args, OFlags);
#else
	Args = (char *)&OFlags;
#endif

	pCallbackParam = (button_sCallback *)(va_arg(Args, button_sCallback *));
	
	va_end(Args);

	buttonFD = buttonOpen (pName, OFlags, pCallbackParam);
	
    if(buttonFD == buttondrvIODeviceA.FileDesc)
    {
    	return (io_sDriver *)&buttondrvIODeviceA;
	}
	else
	{
	
	#ifdef BSP_DEVICE_NAME_BUTTON_B  
    	if(buttonFD == buttondrvIODeviceB.FileDesc)
    	{
    		return (io_sDriver *)&buttondrvIODeviceB;
		}
		else
		{	
			return (io_sDriver *) -1; /* not my device */
		}
	#endif	
	}
	
}

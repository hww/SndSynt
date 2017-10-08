/*****************************************************************************
*
* leddrvIO.c - IO Layer for LED driver
*
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "io.h"
#include "fcntl.h"

#include "bit.h"
#include "periph.h"

#include "bsp.h"
#include "led.h"
#include "leddrvIO.h"
#include "gpio.h"
#include "const.h"



/*****************************************************************************/
io_sDriver * leddrvIOOpen(const char * pName, int OFlags, ...)
{
    if( pName != BSP_DEVICE_NAME_LED_0 )
    {
        return ((io_sDriver *)IO_NULL_DEVICE_HANDLE); /* not my device */
    }

	ledOpen (pName, 0);
		
	return ((io_sDriver *)&leddrvIODevice);
}

/*****************************************************************************/
int leddrvIOClose(int FileDesc)
{
	return ledClose(FileDesc);
}

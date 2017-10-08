#include "port.h"
#include "arch.h"
#include "io.h"
#include "fcntl.h"

#include "gpiodrvIO.h"
#include "bsp.h"
#include "assert.h"
#include "const.h"

/* 
	Forward declarations
*/

/*******************************************************************************
*
* Module: gpiodrvIOOpen()
*
* Description: 
*     This function will configure the IO services POSIX Virtual Interface to 
*     the Device Driver along with configuring the Device Driver itself. It 
*     provides the necessary separation between the IO services and the Device 
*     Driver that allows them to be used independently. The SDK may be configured
*     to remove any program or data space overhead the IO services may require 
*     should the designer choose to call the Device Driver directly.
*
*     The IO services provide a higher level of abstraction than the Device 
*     Driver layer to allow customers to make design tradeoffs concerning 
*     portability and efficiency. The IO services provide a virtual interface 
*     that promotes portability at the cost of efficiency in some cases.
*
* Returns: 
*     Upon successful completion, the function will return a valid handle to 
*     the GPIO device requested. Otherwise, a NULL (-1) handle will be returned.
*
* Arguments: 
*     pName - identifies the GPIO device to be opened
*		Values:	(See bsp.h for valid list of DAC devices)
*       Example: BSP_DEVICE_NAME_GPIO_A
*
*     OFlags - standard API argument
*		Values: NULL - not used
*
* Range Issues: None
*
* Special Issues:  For executive loop only,
*     All IO Open functions SHALL return NULL (-1) if the device name is incorrect
*     since the IO library cycles through all open functions until it either
*     reaches the end of the list or gets a return value other than NULL.
*
*******************************************************************************/
io_sDriver * gpiodrvIOOpen(const char * pName, int OFlags, ...)
{			
	/* Check for valid device */
    if(
#ifdef BSP_DEVICE_NAME_GPIO_A
   		 pName == BSP_DEVICE_NAME_GPIO_A
#endif
#ifdef BSP_DEVICE_NAME_GPIO_B
    		|| pName == BSP_DEVICE_NAME_GPIO_B
#endif
#ifdef BSP_DEVICE_NAME_GPIO_C
    		|| pName == BSP_DEVICE_NAME_GPIO_C
#endif
#ifdef BSP_DEVICE_NAME_GPIO_D
    		|| pName == BSP_DEVICE_NAME_GPIO_D
#endif
#ifdef BSP_DEVICE_NAME_GPIO_E
    		|| pName == BSP_DEVICE_NAME_GPIO_E
#endif
#ifdef BSP_DEVICE_NAME_GPIO_F
    		|| pName == BSP_DEVICE_NAME_GPIO_F
#endif
#ifdef BSP_DEVICE_NAME_GPIO_G
    		|| pName == BSP_DEVICE_NAME_GPIO_G
#endif
    )
    {
		/* Get handle to GPIO IO device */
		return ((io_sDriver *)&gpiodrvIODevice);
    }

    /* Invalid device */
	return ((io_sDriver *)IO_NULL_DEVICE_HANDLE);
}


/*****************************************************************************/
int gpiodrvIOClose(int FileDesc)
{
	return 0;
}

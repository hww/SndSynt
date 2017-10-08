/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* File Name: spidrv.c
*
* Description: Device driver for the On-Chip Serial Peripheral Interface (SPI).
*
* Modules Included:
*					spidrvIOOpen()
*
*******************************************************************************/
#include "port.h"
#include "io.h"
#include "fcntl.h"
#include "stdarg.h"
#include "bsp.h"
#include "spi.h"
#include "const.h"

/*******************************************************************************
*
* Module: spidrvIoOpen()
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
*     the SPI device requested. Otherwise, a NULL (-1) handle will be returned.
*
* Arguments: 
*     pName - identifies the SPI device to be opened
*		Values:	BSP_DEVICE_NAME_SPI_0  
*
*     OFlags -  
*
* Range Issues: None
*
* Special Issues:
*     All IO Open functions SHALL return NULL (-1) if the device name is incorrect
*     since the IO library cycles through all open functions until it either
*     reaches the end of the list or gets a return value other than NULL.
*
*******************************************************************************/
io_sDriver * spidrvIOOpen(const char * pName, int OFlags, ...)
{
	spi_sParams * pParams;
	va_list       Args;
	int           FileDesc;
		
	/* Get parameters from exstensible interface */
	va_start(Args, OFlags);
	
	pParams = (spi_sParams *)(va_arg(Args, void *));
		
	va_end(Args);
		
	FileDesc = spiOpen(pName, pParams);
	
	if (FileDesc == (int)spidrvIODevice[0].FileDesc) 
	{
		return (io_sDriver *)&spidrvIODevice[0];
	} 
	else if (FileDesc == (int)spidrvIODevice[1].FileDesc)
	{
		return (io_sDriver *)&spidrvIODevice[1];
	} 
	else
	{
		return ((io_sDriver *)-1);
	}
}

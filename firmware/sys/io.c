#include "port.h"
#include "arch.h"

#include "io.h"
#include "fcntl.h"
#include "stdlib.h"
#include "stdarg.h"
#include "assert.h"

static io_sDevice * pDeviceTable;
static UInt16       DeviceTableLen;
static UWord16      DeviceIndex   = 0;

/*****************************************************************************/
int open(const char *pName, int OFlags, ...)
{
	UWord16    I;
	int        Handle;
	va_list    Args;
	void     * pParams;

#if 0
	va_start(Args, OFlags);
#else
	Args = (char *)&OFlags;
#endif

	pParams = va_arg(Args, void *);
	
	va_end(Args);

	if(DeviceIndex == 0)
	{
		return -1;
	}

	for(I = 0; I < DeviceIndex; I++)
	{
		Handle = (int)(pDeviceTable[I].pOpen(pName, OFlags, pParams));

		if(Handle != -1)
		{
			return Handle;
		}
	}

	return -1;
}

/*****************************************************************************/
Result ioDrvInstall(io_sDriver * (*pOpen)(const char *, int, ...))
{
	assert (DeviceIndex < DeviceTableLen);
	
	pDeviceTable[DeviceIndex].pOpen = pOpen;

	DeviceIndex += 1;

	return PASS;
}

/*****************************************************************************/
void ioInitialize(io_sState * pInitialState)
{
	pDeviceTable   = pInitialState->pDeviceTable;
	DeviceTableLen = pInitialState->MaxDevices;
}


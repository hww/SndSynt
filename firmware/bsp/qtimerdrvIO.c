/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: qtimerdrvIO.c 
*
* Description:  - quadrature timer I/O layer driver 
*
*****************************************************************************/

#include "port.h"
#include "io.h"
#include "fcntl.h"
#include "bsp.h"
#include "stdarg.h"
#include "quadraturetimer.h"
#include "const.h"


/*****************************************************************************
*
* Module: qtdrvIOOpen
*
* Description: Open the QT device and configure initial parameters.
*
* Returns: device handle or -1 in case of error
*
* Arguments: device name( predefined list should be used )
*            flags for standard open modes
*            iinterface structure (qt_sState) 
*
* Range Issues: none
*
* Special Issues: 
*
* Test Method: Application
*
*****************************************************************************/
io_sDriver * qtdrvIOOpen(const char * pName, int OFlags, ...  )
{
    int                qtFD;
    int                i;
	va_list            Args;
	qt_sState *        pParams;
			
#if 0
	va_start(Args, OFlags);
#else
	Args = (char *)(&OFlags);
#endif

	pParams = (qt_sState *)(va_arg(Args, qt_sState *));
	
	va_end(Args);

    qtFD = qtOpen (pName, OFlags, pParams);

    for ( i = 0; i < qtNumberOfDevices; i++ )
    {
        if ( qtFD == qtimerdrvIODevice[i].FileDesc )
        {
            return (io_sDriver *)&qtimerdrvIODevice[i];
        }
    }
    
    return (io_sDriver *) -1 ;  
}

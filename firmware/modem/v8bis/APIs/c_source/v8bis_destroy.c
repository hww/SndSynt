/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: v8bis_destroy.c
*
* Description:  Includes V8bis destroy function
*
* Modules Included:
*                   v8bisDestroy ()
*
* Author : Prasad N. R.
*
* Date   : 08 Aug 2000
*
***********************************************************************/

#include "port.h"
#include "v8bis.h"
#include "mem.h"

/***********************************************************************
*
* Module: v8bisDestroy ()
*
* Description: Destroys the instance created by a call to v8bisCreate
*              function.
*
* Returns: None
*
* Arguments: pV8bis - a pointer to v8bis_sHandle structure obtained
*                     after a call to v8bisCreate function
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_v8bis_IS.mcp or test_v8bis_RS.mcp for testing
*
**************************** Change History ****************************
*
*    DD/MM/YY   Code Ver       Description         Author
*    --------   --------       -----------         ------
*    08/08/2000  0.0.1         Created             Prasad N R
*    25/08/2000  1.0.0         Reviewed and        Prasad N R
*                              Baselined 
*
**********************************************************************/

EXPORT void v8bisDestroy (v8bis_sHandle *pV8bis)
{
    if (pV8bis->RXCallback != NULL)
        memFreeEM (pV8bis->RXCallback);
    if (pV8bis->TXCallback != NULL)
        memFreeEM (pV8bis->TXCallback);
    if (pV8bis->Output != NULL)
        memFreeEM (pV8bis->Output);
    if (pV8bis != NULL)
        memFreeEM (pV8bis);

    return;
}
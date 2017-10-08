/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: v8bis_control.c
*
* Description:  Includes V8bis control function
*
* Modules Included:
*                   v8bisControl ()
*
* Author : Prasad N. R.
*
* Date   : 08 Aug 2000
*
***********************************************************************/

#include "port.h"
#include "v8bis.h"

void Goto_Initial_State ();

/***********************************************************************
*
* Module: v8bisControl ()
*
* Description: Controls v8bis processing.
*
* Returns: PASS always
*
* Arguments: pV8bis- a pointer to v8bis_sHandle structure obtained
*                    after a call to v8bisCreate function
*            Command - control command:
*                      STOP_V8BIS_TRANSACTION - stops v8bis processing
*                                               without destroying 
*                                               the instance.
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

EXPORT Result v8bisControl (v8bis_sHandle *pV8bis, UWord16 Command)
{
    
    if (Command == STOP_V8BIS_TRANSACTION)
    {
        /* Call v8bis initialization. The old v8bis instance
         * is not destroyed. However, all intermediate results
         * are lost. */
         
        Goto_Initial_State ();
    }
    
    return (PASS);
}
/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: v8bis_init.c
*
* Description:  Includes function that initializes V8bis
*
* Modules Included:
*                   v8bisInit ()
*
* Author : Prasad N. R.
*
* Date   : 08 Aug 2000
*
***********************************************************************/

#include "port.h"
#include "v8bis.h"
#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

EXPORT void V8bis_Init ();  /* Not the Init function below!! */
EXPORT void V8bis_IS_init (UWord16 *MessagePtr);
EXPORT void V8bis_RS_init (UWord16 *MessagePtr);

/***********************************************************************
*
* Module: v8bisInit ()
*
* Description: Initializes v8bis with local capabilities,
*              remote capabilities, priorities, host config word,
*              and gain.
*
* Returns: PASS or FAIL
*
* Arguments: pV8bis - a pointer to v8bis_sHandle structure obtained
*                     after a call to v8bisCreate function
*            pConfig - a pointer to v8bis_sConfigure structure
*                      containing the v8bis configuration
*            Note: pV8bis should not have been deallocated before
*                  its use.
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

Result v8bisInit (v8bis_sHandle *pV8bis, v8bis_sConfigure *pConfig)
{    
    if (pConfig->Station == V8BIS_INIT_STATION)
    {
        /* Initiating Station Init */
        V8bis_IS_init (pConfig->MessagePtr);
        g_v8bis_flags.initiate_transaction = 1;
    }
    else
    {
        /* Responding Station Init */
        V8bis_RS_init (pConfig->MessagePtr);
        g_v8bis_flags.initiate_transaction = 0;
    }
    
    return (PASS);
}
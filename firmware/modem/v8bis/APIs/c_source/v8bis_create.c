/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: v8bis_create.c
*
* Description:  Includes function that creates an instance to V8bis
*
* Modules Included:
*                   v8bisCreate ()
*
* Author : Prasad N. R.
*
* Date   : 08 Aug 2000
*
***********************************************************************/

#include "port.h"
#include "v8bis.h"
#include "v8bis_typedef.h"
#include "mem.h"

/***********************************************************************
*
* Module: v8bisCreate ()
*
* Description: Creates an instance of V8bis. The memory allocated is
*              as given below:
*              Extenal memory: 19 words
*              Internal memory: 0 words
*
* Returns: v8bis_sHandle structure containing the instance to V.8bis
*
* Arguments: pConfig - a pointer to v8bis_sConfigure structure
*                      containing the v8bis configuration
* 
* Range Issues: None
*
* Special Issues: Should be called before calling any of the API modules.
*                 v8bisDestroy () needs to be called to free the
*                 instance created by v8bisCreate (). 
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

v8bis_sHandle *v8bisCreate (v8bis_sConfigure *pConfig)
{
    v8bis_sHandle *pV8bis;
    Word16 temp;
    
    /* Allocate memory for structure */
    
    pV8bis = (v8bis_sHandle *) memMallocEM (sizeof (v8bis_sHandle));
    if (pV8bis == NULL) return (NULL);
    pV8bis->Output = (Word16 *) memMallocEM (10 * sizeof (Word16));
    if (pV8bis->Output == NULL) return (NULL);
    pV8bis->TXCallback = (v8bis_sTXCallback *) memMallocEM (sizeof (v8bis_sTXCallback));
    if (pV8bis->TXCallback == NULL) return (NULL);
    pV8bis->RXCallback = (v8bis_sRXCallback *) memMallocEM (sizeof (v8bis_sRXCallback));
    if (pV8bis->RXCallback == NULL) return (NULL);
    
    
    /* Copy configuration into Handle, i.e., initialize them */
    
    pV8bis->Station = pConfig->Station;
    pV8bis->MessagePtr = pConfig->MessagePtr;
    pV8bis->TXCallback->pCallback = pConfig->TXCallback.pCallback;
    pV8bis->TXCallback->pCallbackArg = pConfig->TXCallback.pCallbackArg;
    pV8bis->RXCallback->pCallback = pConfig->RXCallback.pCallback;
    pV8bis->RXCallback->pCallbackArg = pConfig->RXCallback.pCallbackArg;
        
    return (pV8bis);
}
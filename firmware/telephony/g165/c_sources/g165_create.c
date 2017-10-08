/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_create.c
*
* Description: This module creates an instance of G.165
*
* Modules Included:
*                   G165Create ()
*
* Author : Sandeep Sehgal
*
* Date   : 25 May 2000
*
*****************************************************************************/

#include "port.h"
#include "mem.h"
#include "arch.h"
#include "g165.h"

#define G165_FRM_BUF_LEN 320


/*****************************************************************************
*
* Module: G165Create ()
*
* Description: This function is used to create an instance of G.165. 
*
* Returns: Pointer to Structure of type g165_sHandle
* 
*                  325 words get allocated per instance
*
* Arguments: pConfig - pointer to the g165_sConfigure structure used 
*                      to configure G.165 application.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g165.mcp and demo_g165.mcp
*
***************************** Change History ********************************
*
*  DD/MM/YY    Code Ver     Description                Author
*  --------    --------     -----------                ------
*  25/05/2000  0.0.1        Function created          Sandeep Sehgal
*  12/07/2000  1.0.0        Modified per review       Sandeep Sehgal
*                           comments and baselined
*
*****************************************************************************/

g165_sHandle   * g165Create ( g165_sConfigure * pConfig)
{
    g165_sHandle *pG165;
    
    pG165 = (g165_sHandle *) memMallocEM (sizeof (g165_sHandle));
    
    if (pG165 == NULL) return (NULL);
    
    pG165->pOutBuf = (Int16 *) memMallocEM (G165_FRM_BUF_LEN * sizeof(Int16));
    if (pG165->pOutBuf == NULL) return (NULL);
    
    pG165->context_buf_length = 0;
    
    pG165->pCallback = (g165_sCallback *) memMallocEM (sizeof(g165_sCallback));
    if (pG165->pCallback == NULL) return (NULL);
    
    pG165->pCallback->pCallback = pConfig->callback.pCallback;
    pG165->pCallback->pCallbackArg = pConfig->callback.pCallbackArg;
    
    return(pG165);
}
    
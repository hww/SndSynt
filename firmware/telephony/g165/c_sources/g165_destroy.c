/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_destroy.c
*
* Description: This module destroys the instance of G.165
*
* Modules Included:
*                   G165destroy ()
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


/*****************************************************************************
*
* Module: g165Destroy ()
*
* Description: Destroy the instance of G165 
*
* Returns: None
* 
* Arguments: Pointer to g165_sHandle structure
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
*****************************************************************/

void g165Destroy( g165_sHandle * pG165)
{
    
    g165Control(pG165, G165_DEACTIVATE);
    
    if (pG165->pOutBuf != NULL)
    memFreeEM(pG165->pOutBuf);
    
    if (pG165->pCallback != NULL)
    memFreeEM(pG165->pCallback);
    
    if (pG165 != NULL)
    memFreeEM(pG165);

}
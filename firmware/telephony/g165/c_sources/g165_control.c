/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_control.c
*
* Description: This file includes the module which controls the function
*              of G.165 process
*
* Modules Included:
*                   G165Control ()
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

extern void G165_CONTROL (UInt16 Command);


/*****************************************************************************
*
* Module: G165Control ()
*
* Description:  Controls the program flow in G165
*               G165_DEACTIVATE
*               G165_NL_OPTION_ENABLE
*               G165_RESET_COEFFICIENTS 
*
* Returns: PASS or FAIL
* 
* Arguments: Command with one of the above values which will 
*            control the corresponding parameter
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
****************************************************************************/

UWord16 g165Control( g165_sHandle * pG165, UInt16 Command)
{

    if ( Command != G165_DEACTIVATE)
    {
        G165_CONTROL ( Command);
    }
    else
    {    
        if ( pG165->context_buf_length != 0)
        {
            (*(pG165->pCallback->pCallback)) (pG165->pCallback->pCallbackArg, 
                             pG165->pOutBuf, pG165->context_buf_length);
        
            pG165->context_buf_length = 0;                             
        }
    }    
    
return (PASS);

}
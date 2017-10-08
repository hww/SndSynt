/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_init.c
*
* Description: This file includes the module which initializes the
*              G.165 variables and buffers.
*
* Modules Included:
*                   G165Init ()
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
* Module: G165Init ()
*
* Description: Initializes the Echo Canceller, Hold-Release logic
*              and Tone Disbaler logic by calling assembly routine. 
*
* Returns: PASS or FAIL
*
* Arguments: Pointer to g165_sConfigure structure and g165_sHandle
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

Result g165Init (g165_sHandle * pG165, g165_sConfigure * pConfig)
{
    typedef struct {
        UInt16 non_lin_option;
        UInt16 Disable_TD;
        UInt16 Inhibit_convergence;
        UInt16 Reset_coefficients;
        UInt16 EchoSpan;
            }g165_sInit; /*Structure local to G165 Init */
                         /*To pass the flags and Echospan to 
                           assembley routine*/
    g165_sInit G165_sInit;
                
    extern void HRL_INIT_subroutine();
    extern void EC_INIT_subroutine(g165_sInit *);
    extern void TD_INIT_subroutine();
            
    G165_sInit.non_lin_option = (pConfig->Flags) & G165_CONFIG_NL_OPTION;
    G165_sInit.Disable_TD = (pConfig->Flags) & G165_CONFIG_DISABLE_TONE_DETECTION;
    G165_sInit.Inhibit_convergence = (pConfig->Flags) & G165_CONFIG_INHIBIT_CONVERGENCE;
    G165_sInit.Reset_coefficients = (pConfig->Flags) & G165_CONFIG_RESET_COEFFICIENTS;
    G165_sInit.EchoSpan = pConfig->EchoSpan;
    
    if ( (pConfig->EchoSpan < 40) | (pConfig->EchoSpan > 320)) return (FAIL);
     
    HRL_INIT_subroutine();
    EC_INIT_subroutine(&G165_sInit);
    TD_INIT_subroutine();
     
    return (PASS);    
}
     
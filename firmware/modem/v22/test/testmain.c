/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: testmain.c
*
* Description: Calls testLoopback routine which inturn does Analog 
*              and Digital self loopback tests for both V22 1200 bps 
*              and V22 2400 bps modem
*
* Modules Included:
*                   main ()
*
* Author : Sanjay Karpoor
*
* Date   : 13 Sept 2000
*
**********************************************************************/

#include "port.h"

Result testLoopback (void);


/**********************************************************************
*
* Module: main ()
*
* Description: Calls testLoopback routine which inturn does Analog 
*              and Digital self loopback tests for both V22 1200 bps 
*              and V22 2400 bps modem
*
* Returns: PASS or FAIL
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: loopback_test.mcp
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/

int main(void)
{
	int res = 0;
	
	res |= testLoopback();
 
    return res;
   
}


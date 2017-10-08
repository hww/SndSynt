/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: testmain.c
*
* Description: Calls the test caller ID function.
*
* Modules Included:
*                   main ()
*
* Author : Meera S. P.
*
* Date   : 11 May 2000
*
*****************************************************************************/

#include "port.h"
 
Result testCallerID (void);

int main(void)
{
	int res = 0;
	
	res |= testCallerID();
 
    return res;
   
}

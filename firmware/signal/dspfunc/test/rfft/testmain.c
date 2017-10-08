/********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*********************************************************************
*
* File Name: testmain.c
*
* Description: Includes main() function.
*
* Modules Included: main
*
* Author(s): Prasad N R and Sandeep S
*
* Date: 27 Jan 2000
*
********************************************************************/

#include "port.h"
#include "test.h"

Result testRfft16(void);
 
int main(void)
{
	int res = 0;
	
	res |= testRfft16();
 
   return res;
   
   
}





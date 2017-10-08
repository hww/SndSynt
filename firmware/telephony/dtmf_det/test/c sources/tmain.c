/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: tmain.c
*
* Description: Calls the test dtmf detection function.
*
* Modules Included: None
*
* Author : Sarang Akotkar
*
* Date   : 14 June 2000
*
*****************************************************************************/

#include "port.h"

extern Result testdtmfdet(void);

int main(void)
{

  
  Result result;
  result = FAIL;
  result = testdtmfdet();
  return result;
   
}
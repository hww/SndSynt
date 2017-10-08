/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: button.c
*
* Description: Buttons driver API test
*
*
*****************************************************************************/

#include "port.h"
#include "button.h"
#include "test.h"

void ButtonAFunc (void *pCallbackArg);
void ButtonBFunc (void *pCallbackArg);

volatile int buttonAcounter;
volatile int buttonBcounter;

button_sCallback ButtonACallbackSpec = {ButtonAFunc, (void*) &buttonAcounter};
button_sCallback ButtonBCallbackSpec = {ButtonBFunc, NULL};


/*****************************************************************************
*
* Button A callback function
*
*****************************************************************************/
void ButtonAFunc (void *pCallbackArg)
{
	if ((*((int*) pCallbackArg)) < 0x7FFE)
	{
		(*((int*) pCallbackArg))++;
	}
}

/*****************************************************************************
*
* Button B callback function
*
*****************************************************************************/
void ButtonBFunc (void *pCallbackArg)
{
	if ((buttonBcounter < 0x7FFE) && (pCallbackArg == NULL))
	{
		buttonBcounter++;
	}
}

void main (void)
{
	int ButtonA; 
	int ButtonB; 
	test_sRec testRec;

	testStart(&testRec, "Buttons test");

	ButtonA = open(BSP_DEVICE_NAME_BUTTON_A, 0, &ButtonACallbackSpec);
	if (ButtonA == -1)
	{
		testFailed(&testRec, "Button IRQA driver open failed");
	}
	ButtonB = open(BSP_DEVICE_NAME_BUTTON_B, 0, &ButtonBCallbackSpec);
	if (ButtonB == -1)
	{
		testFailed(&testRec, "Button IRQB driver open failed");
	}
	
	buttonAcounter = 0;
	buttonBcounter = 0;

	testPrintString( "Please press button IRQA...\n");
	
	while (buttonAcounter == 0)
	{
	}
	
	testComment(&testRec, "Button IRQA pressed");
	
	buttonAcounter = 0;
	buttonBcounter = 0;
	
	testPrintString( "Please press button IRQB...\n");
	
	while (buttonBcounter == 0)
	{
	}
	
	testComment(&testRec, "Button IRQB pressed");

	close(ButtonA);
	close(ButtonB);
	
	testEnd(&testRec );
	
	return;
}

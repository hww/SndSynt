/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME: test.c
*
* Description: 
*
*******************************************************************************/


/*****************************************************************************
* printf removed in order to allow the test applications to use internal memory,
* the reason: printf function need too much resources
*****************************************************************************/
#define TEST_NO_PRINTF

#include "port.h"
#include "test.h"
#include <stdio.h>
#include <string.h>
#include "arch.h"
#include "prototype.h"



/*******************************************************
* Test Package
*******************************************************/

#ifndef TEST_NO_PRINTF

void    testStart  (test_sRec *pTest, const char *pName)
{
	pTest -> passed    = true;
	pTest -> completed = false;

	strncpy (pTest -> name, pName, TEST_NAME_MAX_LEN);
	pTest -> name[TEST_NAME_MAX_LEN - 1] = 0;
	archDisableInt();
	printf("%s - Started\n", pName);
	archEnableInt();
}


void    testFailed (test_sRec *pTest, const char *pMsg)
{
	pTest -> passed = false;

	archDisableInt();
	printf("%s - !!! Failed !!! %s\n", pTest -> name, pMsg);
	archEnableInt();
}


void    testComment (test_sRec *pTest, const char *pMsg)
{
	archDisableInt();
	printf("%s - %s\n", pTest -> name, pMsg);
	archEnableInt();
}


void    testEnd (test_sRec *pTest)
{
	pTest -> completed = true;

	archDisableInt();
	if (pTest -> passed) 
	{
		printf("%s - Passed\n", pTest -> name);
		printf("%s - Ended\n",  pTest -> name);
	} 
	else 
	{
		printf("%s - Ended\n", pTest -> name);
	}
	archEnableInt();
}

void testPrintString( const char *pMsg)
{
	archDisableInt();
	printf("%s", pMsg);
	archEnableInt();
}

#else /* TEST_NO_PRINTF */

/*******************************************************************************
*
* NAME: testStart
*
* DESCRIPTION: Prepare test record and print message that test started
*
********************************************************************************
* PARAMETERS:  Test record and name of test
*
*******************************************************************************/
void    testStart  (test_sRec *pTest, const char *pName)
{
	pTest -> passed    = true;
	pTest -> completed = false;

	strncpy (pTest -> name, pName, TEST_NAME_MAX_LEN);
	pTest -> name[TEST_NAME_MAX_LEN - 1] = 0;
	testPrintString(pName);
	testPrintString(" - Started\n");
}


/*******************************************************************************
*
* NAME: testFailed
*
* DESCRIPTION: Print message that test failed
*
********************************************************************************
* PARAMETERS:  Test record and error message
*
*******************************************************************************/
void    testFailed (test_sRec *pTest, const char *pMsg)
{
	pTest -> passed = false;

	testPrintString(pTest->name);
	testPrintString(" - !!! Failed !!! ");
	testPrintString( pMsg );
	testPrintString("\n");
}


/*******************************************************************************
*
* NAME: testComment
*
* DESCRIPTION: Print test comment message
*
********************************************************************************
* PARAMETERS:  Test record and comment message
*
*******************************************************************************/
void    testComment (test_sRec *pTest, const char *pMsg)
{
	testPrintString(pTest->name);
	testPrintString(" - ");
	testPrintString(pMsg);
	testPrintString("\n");
}


/*******************************************************************************
*
* NAME: testEnd
*
* DESCRIPTION: Print message that test ended
*
********************************************************************************
* PARAMETERS:  Test record
*
*******************************************************************************/
void    testEnd (test_sRec *pTest)
{
	pTest -> completed = true;

	if (pTest -> passed) 
	{
		testPrintString(pTest->name);
		testPrintString(" - Passed\n");
	}
	testPrintString(pTest->name);
	testPrintString(" - Ended\n");
}

/*******************************************************************************
*
* NAME: testPrintString
*
* DESCRIPTION: Sends string to stdout
*
********************************************************************************
* PARAMETERS:  Message
*
*******************************************************************************/
void testPrintString( const char *pMsg)
{
	archDisableInt();
	fwrite( (const void *) pMsg, strlen( pMsg ), 1, (FILE *)stdout );
	archEnableInt();
}

#endif	/* TEST_NO_PRINTF */

/***************************************************************************
*
*  Function: testCompareNum
*
*  Description: compare two numbers with defined tolerance.
*
*  Arguments:
*		a,b       -(in) compared numbers					
*		tolerance -(in) tolerance
*
*  Returns: boolean variable, true when difference is in tolerance range
*
*  Range Issues: none
*
*  Special Issues: none
*
*****************************************************************************/

short testCompareNum(Frac32 a,Frac32 b,Frac32 tolerance)
{
Frac32 t;

t=L_abs(a-b);


if (t>tolerance)
   {
   return(0);
   }
else
   {
   return(1);
   }
}

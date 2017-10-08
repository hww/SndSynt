/* File: test.h */

#ifndef __TEST_H
#define __TEST_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************
* Test Package
*******************************************************/

#define TEST_NAME_MAX_LEN 60

typedef struct {
	bool  passed;
	bool  completed;
	char  name[TEST_NAME_MAX_LEN];
} test_sRec;

EXPORT void    testStart   (test_sRec *pTest, const char *pName);

EXPORT void    testFailed  (test_sRec *pTest, const char *pMsg);

EXPORT void    testComment (test_sRec *pTest, const char *pMsg);

EXPORT void    testEnd     (test_sRec *pTest);

EXPORT void    testPrintString	( const char* str);

EXPORT short testCompareNum(Frac32 a,Frac32 b,Frac32 tolerance);


/* number to string convertions */
EXPORT void    ul2mks (unsigned long, char* buf);
EXPORT void    ul2str (unsigned long, char* buf);


#ifdef __cplusplus
}
#endif

#endif

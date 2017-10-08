#ifndef __TIMESPEC_H
#define __TIMESPEC_H


#include "port.h"
#include "types.h"


#ifdef __cplusplus
extern "C" {
#endif


/**************************************************************************
*  TIMESPEC 
*
*  Implementation Status:
*     IMPLEMENTED - Because it is required by POSIX and is used for the 
*                   nanosleep function. 
*
*  Semantics:
*     The contents of the timespec structure are specified by the POSIX standard
*     and are therefore public.
*
**************************************************************************/

struct timespec
{
	time_t tv_sec;       /* seconds */
	long   tv_nsec;      /* nanoseconds (0 - 999,999,999) */
};

/*************************************************************************
*
* timespecAdd
*
* Semantics:
*    Augments the POSIX time interface to add two timespecs;
*    timeres = time1 + time2
*
**************************************************************************/

EXPORT void timespecAdd (   struct timespec * pTimeres, 
							struct timespec * pTime1, 
							struct timespec * pTime2);


/*************************************************************************
*
* timespecSub
*
* Semantics:
*    Augments the POSIX time interface to subtract two timespecs;
*    timeres = time1 - time2
*
**************************************************************************/

EXPORT void timespecSub (   struct timespec * pTimeres, 
							struct timespec * pTime1, 
							struct timespec * pTime2);

/*************************************************************************
*
* timespecGE
*
* Semantics:
*    Augments the POSIX time interface to subtract two timespecs;
*    returns time1 >= time2
*
**************************************************************************/

EXPORT bool timespecGE (	struct timespec * pTime1, 
							struct timespec * pTime2);


#ifdef __cplusplus
}
#endif

#endif

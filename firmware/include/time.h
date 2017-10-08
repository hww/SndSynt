#ifndef __TIME_H
#define __TIME_H

#include "types.h"
#include "signal.h"
#include "timespec.h"


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_TIME_OF_DAY
		#if !defined( INCLUDE_TIMER ) && !defined( INCLUDE_QUAD_TIMER )
   			#error INCLUDE_TIMER must be defined in appconfig.h to initialize the TIMER Library
		#endif
	#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif


#define CLOCK_REALTIME 0
#define CLOCK_AUX1     1
#define CLOCK_AUX2     2
#define CLOCK_AUX3     3
#define CLOCK_AUX4     4
#define CLOCK_AUX5     5
#define CLOCK_AUX6     6
#define CLOCK_AUX7     7
#define CLOCK_TOD      33



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

#if 0
/* see timespec.h for more details */

struct timespec
{
	time_t tv_sec;       /* seconds */
	long   tv_nsec;      /* nanoseconds (0 - 999,999,999) */
};

#endif


/**************************************************************************
*  ITIMERSPEC 
*
*  Implementation Status:
*     IMPLEMENTED - Because it is required by POSIX
*
*  Semantics:
*     The contents of the timespec structure are specified by the POSIX standard
*     and are therefore public.
*
**************************************************************************/

struct itimerspec
{
	struct timespec it_interval;     /* timer period (reload value) */
	struct timespec it_value;        /* timer expiration */
};

struct tm
{
	int tm_sec;     /* seconds after the minute [0, 61]  */
	int tm_min;     /* minutes after the hour [0, 59] */
	int tm_hour;    /* hour since midnight [0, 23] */
	int tm_mday;    /* day of the month [1, 31] */
	int tm_mon;     /* months since January [0, 11] */
	int tm_year;    /* years since 1900 */
	int tm_wday;    /* days since Sunday [0, 6] */
	int tm_yday;    /* days since January 1 [0, 365] */
	int tm_isdst;   /* flag for daylight savings time */
};
	
/**************************************************************************
*  LOCALTIME
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
extern struct tm * localtime(const time_t *);

/**************************************************************************
*  MKTIME
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
extern time_t mktime(struct tm *timeptr);

/**************************************************************************
*  TIMER_CREATE
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int timer_create(clockid_t cid, struct sigevent * evp, timer_t * tid);

/**************************************************************************
*  LOCALTIME
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int clock_settime(clockid_t cid, const struct timespec * tp);

/**************************************************************************
*  TIMER_DELETE
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int timer_delete(timer_t tid);

/**************************************************************************
*  TIMER_SETTIME
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int timer_settime(timer_t tid, int flags, 
						const struct itimerspec * value, struct itimerspec * ovalue);

/**************************************************************************
*  CLOCK_GETTIME
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int clock_gettime(clockid_t cid, struct timespec * tp);

/**************************************************************************
*  CLOCK_GETRES
*
*  Implementation Status:
*     IMPLEMENTED 
*
*  Semantics:
*
*  Return Value:
*
**************************************************************************/
EXPORT int clock_getres(clockid_t cid, struct timespec * res);

/**************************************************************************
*  NANOSLEEP
*
*  Implementation Status:
*     IMPLEMENTED 
*        The rmtp parameter to nanosleep must be NULL because nanosleep
*        always suspends the thread for at least the amount of time
*        specified in rqtp and so would return 0.
*
*  Semantics:
*     The nanosleep() function shall cause the current thread to be suspended
*     from execution until either the time interval specified by the rqtp
*     argument has elapsed, a signal is delivered to the calling thread and
*     the action of the signal is to invoke a signal-catching function, or
*     the process is terminated.  
*
*     The suspension time may be longer than requested because the argument
*     value is rounded up to an integer multiple of the sleep resolution or
*     because of the scheduling of other activity by the system.  But, except
*     for the case of being interrupted by a signal, the suspension time shall
*     not be less than the time specified by rqtp, as measured by the system
*     clock, CLOCK_REALTIME.
*
*     The use of nanosleep() function shall have no effect on the action or
*     blockage of any signal.
*
*  Return Value:
*     If the nanosleep() function returns because the requested time has
*     elapsed, its return value shall be zero.
*
*     If the nanosleep() function returns because it has been interrupted by
*     a signal, the function shall return a value of -1 and set errno to
*     indicate the interruption.  If the rmtp argument is non-NULL, the
*     timespec structure referenced by it shall be updated to contain the 
*     amount of time remaining in the interval (the requested time minus the
*     time actually slept).  If the rmtp argument is NULL, the remaining
*     time is not returned.
*
*     If nanosleep() fails, it shall return a value of -1 and set errno to
*     indicate the error.
*
**************************************************************************/
EXPORT int nanosleep(const struct timespec * rqtp, struct timespec * rmtp);


#ifdef __cplusplus
}
#endif

#endif

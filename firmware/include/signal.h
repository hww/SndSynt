#ifndef __SIGNAL_H
#define __SIGNAL_H



#ifdef __cplusplus
extern "C" {
#endif

union sigval
{
	int    sival_int;
	void * sival_ptr;
};

struct sigevent
{
	int          sigev_signo;
	union sigval sigev_value;
	int          sigev_notify;
	void         (*sigev_notify_function)(union sigval);
};

#ifdef __cplusplus
}
#endif

#endif

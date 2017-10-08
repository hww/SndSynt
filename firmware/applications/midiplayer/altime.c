#include "port.h"
#include "audiolib.h"

void	alMicroTimeSub( ALMicroTime * time, ALMicroTime delta)
{
	*time -= delta;
	if(*time < 0)*time = 0;
}

void	alMicroTimeAdd( ALMicroTime * time, ALMicroTime delta)
{
	*time += delta;
	if(*time > AL_MAX_MICROTIME) *time -= AL_MAX_MICROTIME;
}

ALMicroTime alMiliToMicro( ALMiliTime time )
{
	return (ALMicroTime)time * 1000;
}
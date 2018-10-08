/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "audiolib.h"

void    alMicroTimeSub( ALMicroTime * time, ALMicroTime delta)
{
    *time -= delta;
    if(*time < 0)*time = 0;
}

void    alMicroTimeAdd( ALMicroTime * time, ALMicroTime delta)
{
    *time += delta;
    if(*time > AL_MAX_MICROTIME) *time -= AL_MAX_MICROTIME;
}

ALMicroTime alMiliToMicro( ALMiliTime time )
{
    return (ALMicroTime)time * 1000;
}
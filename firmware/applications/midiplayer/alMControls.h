/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#ifndef _ALMCONTROLS_H
#define _ALMCONTROLS_H

void	alSeqpControlChange( ALSeqPlayer * seqp, UWord16 chan, u8 contr, u8 val );

#endif
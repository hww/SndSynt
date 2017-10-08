#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "assert.h"

/******************************************************************************
*
*	void    alSeqpSetChlProgram(ALSeqPlayer *seqp, u8 chan, u8 prog)
*	s32     alSeqpGetChlProgram(ALSeqPlayer *seqp, u8 chan)
*
* PARAMETERS
*    seqp      pointer to the sequence player.
*	 chan	   миди канал
*	 prog	   номер инструмента
*
* DESCRIPTION
*     Возвращает и устанавливает инструмент в канале
*     
*******************************************************************************/

void    alSeqpSetChlProgram(ALSeqPlayer *seqp, u8 chan, u8 prog)
{
ALChanState * cs;

	if(prog<seqp->bank->instCount)
	{	if(seqp->bank->instArray[prog] == NULL) prog = 0;
		cs = &seqp->chanState[chan];
		cs->prog 		= prog;
		cs->instrument 	= seqp->bank->instArray[prog];
		cs->bendRange	= cs->instrument->bendRange;	
	}
}

s32     alSeqpGetChlProgram(ALSeqPlayer *seqp, u8 chan)
{
	return seqp->chanState[chan].prog;
}

/******************************************************************************
*
*	void    alSeqpSetChlFXMix(ALSeqPlayer *seqp, u8 chan, u8 fxmix)
*	u8      alSeqpGetChlFXMix(ALSeqPlayer *seqp, u8 chan)
*
* PARAMETERS
*    seqp      pointer to the sequence player.
*	 chan	   миди канал
*	 fxmix	   уровень FX
*
* DESCRIPTION
*     Возвращает и устанавливает уровень FX в канале
*     
*******************************************************************************/

void    alSeqpSetChlFXMix(ALSeqPlayer *seqp, u8 chan, u8 fxmix)
{
	seqp->chanState[chan].fxmix = fxmix;
}

u8      alSeqpGetChlFXMix(ALSeqPlayer *seqp, u8 chan)
{
	return seqp->chanState[chan].fxmix;
}

/******************************************************************************
*
*	void	alSeqpSetChlVol(ALSeqPlayer *seqp, u8 chan, u8 vol)
*	u8		alSeqpGetChlVol(ALSeqPlayer *seqp, u8 chan)
*
* PARAMETERS
*    seqp      pointer to the sequence player.
*	 chan	   миди канал
*	 vol	   громкость
*
* DESCRIPTION
*     Возвращает и устанавливает громкость в канале
*     
*******************************************************************************/

void	alSeqpSetChlVol(ALSeqPlayer *seqp, u8 chan, u8 vol)
{
	seqp->chanState[chan].vol = vol;
}

u8		alSeqpGetChlVol(ALSeqPlayer *seqp, u8 chan)
{
	return seqp->chanState[chan].vol;
}

/******************************************************************************
*
*	void    alSeqpSetChlPan(ALSeqPlayer *seqp, u8 chan, ALPan pan)
*	ALPan   alSeqpGetChlPan(ALSeqPlayer *seqp, u8 chan)
*
* PARAMETERS
*    seqp      pointer to the sequence player.
*	 chan	   миди канал
*	 pan	   панорама
*
* DESCRIPTION
*     Возвращает и устанавливает панораму в канале
*     
*******************************************************************************/

void    alSeqpSetChlPan(ALSeqPlayer *seqp, u8 chan, ALPan pan)
{
	seqp->chanState[chan].pan = pan;
}

ALPan   alSeqpGetChlPan(ALSeqPlayer *seqp, u8 chan)
{
	return seqp->chanState[chan].pan;
}

/******************************************************************************
*
*	void    alSeqpSetChlPriority(ALSeqPlayer *seqp, u8 chan, u8 priority)
*	u8      alSeqpGetChlPriority(ALSeqPlayer *seqp, u8 chan)
*
* PARAMETERS
*    seqp      pointer to the sequence player.
*	 chan	   миди канал
*	 priority  приоритет канала
*
* DESCRIPTION
*     Возвращает и устанавливает приоритет вканале
*     
*******************************************************************************/

void    alSeqpSetChlPriority(ALSeqPlayer *seqp, u8 chan, u8 priority)
{
	seqp->chanState[chan].priority = priority;
}

u8      alSeqpGetChlPriority(ALSeqPlayer *seqp, u8 chan)
{ 
	return seqp->chanState[chan].priority; 
}

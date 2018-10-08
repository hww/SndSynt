/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "controls.h"
#include "terminal.h"

/*****************************************************************************
 *
 *	Help narration text
 *
 *****************************************************************************/

const tHelpList HelpList[] =
{	// Mode: any
	{KBD_MODE_ANY,KEY_HELP,		{WORD_HELP,0,0,0}},
	{KBD_MODE_ANY,KEY_M1,  		{WORD_TEMP,WORD_TONE,0,0}},
	{KBD_MODE_ANY,KEY_M2,  		{WORD_SELECT,WORD_FILES,0,0}},
	{KBD_MODE_ANY,KEY_M3,  		{WORD_SELECT,WORD_INS,0,0}},
	{KBD_MODE_ANY,KEY_M4,  		{WORD_SELECT,WORD_VARIANT,WORD_SOUND_VARIANT,0}},
	{KBD_MODE_ANY,KEY_M5,  		{WORD_SELECT,WORD_GAME,0}},
	{KBD_MODE_ANY,KEY_NEXT,		{WORD_REPEAT,0,0,0}},
	{KBD_MODE_ANY,KEY_PREV,		{WORD_REPEAT,WORD_TWO,0,0}},
	// Modes: tone, tempo
	{KBD_MODE_TONE,KEY_PLAY,    {WORD_START,WORD_FILES,0,0}},
	{KBD_MODE_TONE,KEY_STOP,    {WORD_STOP,WORD_FILES,0,0}},
	{KBD_MODE_TONE,KEY_PLUS_10, {WORD_TEMP,WORD_PLUS,0,0}},
	{KBD_MODE_TONE,KEY_MINUS_10,{WORD_TEMP,WORD_MINUS,0,0}},
	{KBD_MODE_TONE,KEY_PLUS_1,  {WORD_TONE,WORD_PLUS,0,0}},
	{KBD_MODE_TONE,KEY_MINUS_1, {WORD_TONE,WORD_MINUS,0,0}},
	// Mode: choose song
	{KBD_MODE_FILE,KEY_PLAY,    {WORD_START,WORD_FILES,0,0}},
	{KBD_MODE_FILE,KEY_STOP,    {WORD_STOP,WORD_FILES,0,0}},
	{KBD_MODE_FILE,KEY_PLUS_10, {WORD_NUMBER,WORD_FILES,WORD_TENS,WORD_PLUS}},
	{KBD_MODE_FILE,KEY_MINUS_10,{WORD_NUMBER,WORD_FILES,WORD_TENS,WORD_MINUS}},
	{KBD_MODE_FILE,KEY_PLUS_1,  {WORD_NUMBER,WORD_FILES,WORD_ONES,WORD_PLUS}},
	{KBD_MODE_FILE,KEY_MINUS_1, {WORD_NUMBER,WORD_FILES,WORD_ONES,WORD_MINUS}},
	// Mode: chose 
	{KBD_MODE_INS,KEY_PLAY,     {WORD_START,WORD_FILES,0,0}},
	{KBD_MODE_INS,KEY_STOP,     {WORD_STOP,WORD_FILES,0,0}},
	{KBD_MODE_INS,KEY_PLUS_10,  {WORD_VOLUME,WORD_PLUS,0,0}},
	{KBD_MODE_INS,KEY_MINUS_10, {WORD_VOLUME,WORD_MINUS,0,0}},
	{KBD_MODE_INS,KEY_PLUS_1,   {WORD_NUMBER,WORD_INS,WORD_PLUS,0}},
	{KBD_MODE_INS,KEY_MINUS_1,  {WORD_NUMBER,WORD_INS,WORD_MINUS,0}},
	// Mode: game
	{KBD_MODE_GAME,KEY_PLAY,    {WORD_START,WORD_GAME,0,0}},
	{KBD_MODE_GAME,KEY_STOP,    {WORD_STOP,WORD_GAME,0,0}},
	{KBD_MODE_GAME,KEY_PLUS_10, {WORD_NUMBER,WORD_GAME,WORD_PLUS,0}},
	{KBD_MODE_GAME,KEY_MINUS_10,{WORD_NUMBER,WORD_GAME,WORD_MINUS,0}},
	{KBD_MODE_GAME,KEY_PLUS_1,  {WORD_VARIANT,WORD_GAME,WORD_PLUS,0}},
	{KBD_MODE_GAME,KEY_MINUS_1, {WORD_VARIANT,WORD_GAME,WORD_MINUS,0}},
	// EOL
	{KBD_MODE_UNDEFINED,0, 		{0,0,0,0}}
};

/*****************************************************************************
 *
 *	Buttons help
 *
 *****************************************************************************/

const UInt16 * toSpeak;
UInt16 wordIdx;

void speakerUpdate(ALSeqPlayer * seqp)
{
	ALSound * snd;

	if ((toSpeak == NULL) || ((speaker.state & AL_SF_ACTIVE) != 0)) return;
	snd = seqp->bank->instArray[125]->soundArray[(*toSpeak++) + 1];
	if (wordIdx == 4)
	{
		alSynFreeVoice(seqp->drvr, &speaker);
		toSpeak = NULL;
		return;
	}

	if (wordIdx == 0)
	{
		alSynAllocVoice(seqp->drvr, &speaker, 10);
		if (snd->wavetable->rate == MIXFREQ)
			speaker.unityPitch = 0x8000;
		else
			speaker.unityPitch = div_s(negate(snd->wavetable->rate), MIXFREQ);
	}

	alSynStartVoiceParams(seqp->drvr, &speaker, snd->wavetable,
		0x10000L, 0x7fff, 0x40, 0, 0);
	wordIdx++;
}

void speakWords(ALSeqPlayer * seqp, UInt16 * ptr)
{
}
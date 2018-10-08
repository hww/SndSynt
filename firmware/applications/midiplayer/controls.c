/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "audiolib.h"
#include "controls.h"
#include "main.h"
#include "terminal.h"
#include "mem.h" 

#define KBD_CHANEL 0				// midi channel of keyboard

void AltCase(ALSeqPlayer * seqp, Int16 key);
extern const tHelpList HelpList[];

UInt16 		kbdMode, kbdModeOld;	// keyboard mode
bool   		teacherMode;			// teacher mode on/off
UInt16 		volume;					// default volume
UInt16  	fileNum, demoNum;		// sequence number
ALSeq		seq, bgseq;				// sequence
ALSeqMarker begMarker,
oneMarker,
twoMarker;							// markers
UInt16		voices;					// all voices
bool		isMarkers;				// contains markers
bool		demoMode;				// demo sequence
int			prog;					// instrument number

const Int16 volTable[] =			// volumes
{ 0x07FF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF };

/*****************************************************************************
 *
 *	Display for the keyboard
 *
 *****************************************************************************/

const UInt16 modeLeds[] =
{
	0,0,
	LED_HELP,LED_M1,LED_M2,LED_M3,LED_M4,LED_M5
};

void ledsMode()
{
	LEDOFF(LED_M1 | LED_M2 | LED_M3 | LED_M4 | LED_M5 | LED_HELP);
	LEDON(((UInt16)modeLeds[kbdMode]));
}

void ledsLevel(UInt16 level)
{
	LEDOFF(LED_LEVELS);
	LEDFLASH(stdLevels[level + 1]);
}

void ledsPos(UInt16 pos)
{
	LEDOFF(LED_LEVELS);
	LEDFLASH(stdPos[pos + 1]);
}

void speakOnes(int val)
{
	speakDigit(val % 10);
}

void speakTens(int val)
{
	speakDigit(val / 10);
}

typedef struct 
{
	UInt16	mask;
	UInt16	prog0;
	UInt16	vol0;
	UInt16	prog1;
	UInt16	vol1;
} tVoices;

#define ROYAL_VOL 90
#define VOICE_VOL 127

const tVoices voicesTable[] =
{ 
	{	0xffff, 000, ROYAL_VOL, 000, ROYAL_VOL	},
	{	0xffff, 126, VOICE_VOL, 000, ROYAL_VOL	},
	{	0xffff, 000, ROYAL_VOL, 126, VOICE_VOL	},
	{	0xfffe, 126, VOICE_VOL, 126, VOICE_VOL	},
	{	0xfffd, 126, VOICE_VOL, 126, VOICE_VOL	}
};

void muteAllChls(ALSeqPlayer * seqp)
{
	alSeqpSendMidi(seqp, 0, AL_MIDI_ControlChange, AL_MIDI_ALL_NOTES_OFF, 0);
}

void SetVoices(ALSeqPlayer * seqp)
{
	ledsPos(voices);
	muteAllChls(seqp);
	alSeqpSetChlProgram(seqp, 0, voicesTable[voices].prog0);
	alSeqpSetChlProgram(seqp, 1, voicesTable[voices].prog1);
	alSeqpSetChlVol(seqp, 0, voicesTable[voices].vol0);
	alSeqpSetChlVol(seqp, 1, voicesTable[voices].vol1);
	seqp->chanMask = voicesTable[voices].mask;
}

void selectFile(ALSeqPlayer * seqp, ALSeqDir * bank, UInt16 fnum)
{
	alSeqFileNew(&bank->seqFile, bank->drama, fnum);
	// *************** Setup midi file for sequencer ***********
	alSeqNew(&seq, bank->seqFile.seqArray[0].offset, bank->seqFile.seqArray[0].len);
	alSeqpSetSeq(seqp, &seq);
	alSeqGetLoc(&seq, &begMarker);		// Marker of file start
	alSeqGetLoc(&seq, &twoMarker);
	isMarkers = false;
	seqp->xTempo = 0;
	seqp->relTone = 0;
}

void PlayPauseFile(ALSeqPlayer * seqp)
{
	if (seqp->state == AL_PLAYING)
	{
		alSeqpStop(seqp);				// Pause
		muteAllChls(seqp);
		memcpy(&oneMarker, &twoMarker, sizeof(ALSeqMarker));
		alSeqGetLoc(&seq, &twoMarker);	// Marker of last pause
		isMarkers = true;
		terminalSetAnimate(NULL);
	}
	else
	{
		alSeqpPlay(seqp);				// Play
		if (demoMode)terminalSetAnimate(&stdAnimeR);
	}
}

void StopFile(ALSeqPlayer * seqp)
{
	if (demoMode)
	{
		demoMode = false;
		terminalSetAnimate(NULL);
		voices = 0;
		SetVoices(seqp);
		selectFile(seqp, &midiBank, fileNum);
	}
	if (seqp->state == AL_PLAYING)
	{
		alSeqpStop(seqp);
		//muteAllChls(seqp);	
		alSeqSetLoc(&seq, &begMarker);	// To file start
		alSeqGetLoc(&seq, &twoMarker);	// Marker of file start
		isMarkers = false;
		terminalSetAnimate(NULL);
	}
}

void RepeatOne(ALSeqPlayer * seqp)
{
	if (seqp->state == AL_PLAYING)
	{
		PlayPauseFile(seqp);
	}
	else
	{
		if (isMarkers)
		{
			alSeqpLoop(seqp, &oneMarker, &twoMarker, 0);
			alSeqSetLoc(&seq, &oneMarker);	// To start of block and play
			alSeqpPlay(seqp);
		}
	}
}

void RepeatTwo(ALSeqPlayer * seqp)
{
	if ((seqp->state != AL_PLAYING) && isMarkers)
	{
		alSeqpLoop(seqp, &begMarker, &twoMarker, 0);
		alSeqSetLoc(&seq, &begMarker);	// To start of block and play
		alSeqpPlay(seqp);
	}
}

/*****************************************************************************
 *
 *	On key pressed
 *
 *****************************************************************************/

void MainCase(ALSeqPlayer * seqp, Int16 key)
{
	switch (key)
	{
	case KEY_HELP:
		kbdModeOld = kbdMode;
		kbdMode = KBD_MODE_HELP;
		ledsMode();
		break;
	case KEY_M1:
		kbdMode = KBD_MODE_TONE;
		ledsMode();
		break;
	case KEY_M2:
		kbdMode = KBD_MODE_FILE;
		ledsMode();
		break;
	case KEY_M3:
		kbdMode = KBD_MODE_INS;
		ledsMode();
		break;
	case KEY_M4:
		if (++voices > 4) voices = 0;
		SetVoices(seqp);
		break;
	case KEY_M5:
		kbdMode = KBD_MODE_GAME;
		ledsMode();
		break;
	case KEY_TEACHER:
		demoMode = true;
		alSeqpStop(seqp);
		terminalSetAnimate(NULL);
		ledsPos(demoNum);
		speakDigit(demoNum + 1);
		selectFile(seqp, &demoBank, demoNum);
		demoNum++;
		if (demoNum >= demoBank.seqFile.seqCount) demoNum = 0;
		break;
	default:
		AltCase(seqp, key);
		break;
	}
}

void HelpCase(ALSeqPlayer * seqp, Int16 key)
{
	const tHelpList * ptr = &HelpList;

	while (ptr->mode != KBD_MODE_UNDEFINED)
	{
		if ((ptr->mode == KBD_MODE_ANY) || (ptr->mode == kbdModeOld))
		{
			if (key == ptr->key)
			{
				speakWords(&ptr->word);
				break;
			}
		}
		ptr++;
	}
	kbdMode = kbdModeOld;
	ledsMode();
}

/*****************************************************************************
 *
 *	On pressed key in change tone mode
 *
 *****************************************************************************/

void AltCaseTone(ALSeqPlayer * seqp, Int16 key);
void AltCaseTone(ALSeqPlayer * seqp, Int16 key)
{
	switch (key)
	{
	case KEY_PLAY:	PlayPauseFile(seqp);	break;
	case KEY_STOP:	StopFile(seqp);			break;
	case KEY_NEXT:	RepeatOne(seqp);		break;
	case KEY_PREV:	RepeatTwo(seqp);		break;
	case KEY_PLUS_1:
		muteAllChls(seqp);
		if (seqp->relTone < 6)seqp->relTone++;
		break;
	case KEY_MINUS_1:
		muteAllChls(seqp);
		if (seqp->relTone > (-6))seqp->relTone--;
		break;
	case KEY_PLUS_10:
		if (seqp->xTempo < 2)alSeqpSetTempoX(seqp, (seqp->xTempo + 1));
		ledsPos(seqp->xTempo + 2);
		break;
	case KEY_MINUS_10:
		if (seqp->xTempo > -2) alSeqpSetTempoX(seqp, (seqp->xTempo - 1));
		ledsPos(seqp->xTempo + 2);
		break;
	default:
		asm{ nop };
		break;
	}
}

/*****************************************************************************
 *
 *	On pressed key in change fle mode
 *
 *****************************************************************************/

void AltCaseFile(ALSeqPlayer * seqp, Int16 key);
void AltCaseFile(ALSeqPlayer * seqp, Int16 key)
{
	switch (key)
	{
	case KEY_PLAY:	PlayPauseFile(seqp); break;
	case KEY_STOP:	StopFile(seqp);		break;
	case KEY_NEXT:	RepeatOne(seqp); 	break;
	case KEY_PREV:	RepeatTwo(seqp);	break;
	}
	if (demoMode) return;
	//		StopFile(seqp);
	switch (key)
	{
	case KEY_PLUS_10:
		if ((fileNum + 10) < midiBank.seqFile.seqCount) fileNum += 10;
		selectFile(seqp, &midiBank, fileNum);
		speakTens(fileNum);
		break;
	case KEY_MINUS_10:
		if (fileNum > 9) fileNum -= 10;
		selectFile(seqp, &midiBank, fileNum);
		speakTens(fileNum);
		break;
	case KEY_PLUS_1:
		if ((fileNum + 1) < midiBank.seqFile.seqCount) fileNum++;
		selectFile(seqp, &midiBank, fileNum);
		speakOnes(fileNum);
		break;
	case KEY_MINUS_1:
		if (fileNum > 0) fileNum--;
		selectFile(seqp, &midiBank, fileNum);
		speakOnes(fileNum);
		break;
	}
}

/*****************************************************************************
 *
 *	On pressed key in change instrument mode
 *
 *****************************************************************************/

void AltCaseIns(ALSeqPlayer * seqp, Int16 key);
void AltCaseIns(ALSeqPlayer * seqp, Int16 key)
{
	switch (key)
	{
	case KEY_PLAY:	PlayPauseFile(seqp);	break;
	case KEY_STOP:	StopFile(seqp);			break;
	case KEY_NEXT:	RepeatOne(seqp);		break;
	case KEY_PREV:
		RepeatTwo(seqp);
	break;		case KEY_PLUS_10:
		if (volume < 4) volume++;
		seqp->vol = volTable[volume];
		ledsPos(volume);
		break;
	case KEY_MINUS_10:
		if (volume > 0) volume--;
		seqp->vol = volTable[volume];
		ledsPos(volume);
		break;
	case KEY_PLUS_1:
		if (prog < INS_MAX) prog++;
		alSeqpSetChlProgram(seqp, KBD_CHANEL, prog);
		break;
	case KEY_MINUS_1:
		if (prog > INS_MIN)prog--;
		alSeqpSetChlProgram(seqp, KBD_CHANEL, prog);
		break;
	}
}

/*****************************************************************************
 *
 *	On pressed key in change game mode
 *
 *****************************************************************************/

void AltCaseGame(ALSeqPlayer * seqp, Int16 key);
void AltCaseGame(ALSeqPlayer * seqp, Int16 key)
{

}

/*****************************************************************************
 *
 *	On pressed key dispatched
 *
 *****************************************************************************/

void AltCase(ALSeqPlayer * seqp, Int16 key)
{
	switch (kbdMode)
	{
	case KBD_MODE_TONE:	AltCaseTone(seqp, key);	break;
	case KBD_MODE_FILE: AltCaseFile(seqp, key);	break;
	case KBD_MODE_INS:	AltCaseIns(seqp, key);	break;
	case KBD_MODE_GAME:	AltCaseGame(seqp, key);	break;
	}
}

void EnterCase(ALSeqPlayer * seqp, UInt16 key)
{
	if (kbdMode == KBD_MODE_HELP) HelpCase(seqp, key);
	else MainCase(seqp, key);
}

/*****************************************************************************
 *
 *	Initializing of control structure
 *
 *****************************************************************************/

void ControlCreate(ALSeqPlayer * seqp)
{
	kbdMode = KBD_MODE_FILE;
	fileNum = 0;
	demoNum = 0;
	volume = 3;
	voices = 0;
	isMarkers = false;
	demoMode = false;
	prog = INS_MIN;
	seqp->vol = volTable[volume];
	seqp->xTempo = 0;
	seqp->relTone = 0;
	selectFile(seqp, &midiBank, fileNum);
	ledsMode();
	speakCreate();
}
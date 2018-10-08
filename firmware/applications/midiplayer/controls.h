/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "audiolib.h"

void   	MainCase(ALSeqPlayer * seqp, Int16 key);
void   	HelpCase(ALSeqPlayer * seqp, Int16 key);
void   	speakerUpdate(ALSeqPlayer * seqp);
void 	speakWords(const UInt16 * ptr);
void 	speakCreate();
void 	speakDigit(UInt16  val);

// Teacher mode on/off
extern bool   teacherMode;
void ControlCreate(ALSeqPlayer * seqp);
void EnterCase(ALSeqPlayer * seqp, UInt16 key);

// Instrument with voice over phrases
#define WORDS_INS 125	
#define MIN_TEMPO_US   (1000000L/(150*4))
#define MAX_TEMPO_US   (1000000L/(20*4))
#define DELTA_TEMPO_US (1000000L/(20*4))
#define INS_MIN 76
#define INS_MAX 102

// Menu mode
typedef enum
{
	KBD_MODE_UNDEFINED = 0,
	KBD_MODE_ANY,
	KBD_MODE_HELP,
	KBD_MODE_TONE,
	KBD_MODE_FILE,
	KBD_MODE_INS,
	KBD_MODE_VARIANTS,
	KBD_MODE_GAME,
} eKbdMode;

// Phrases in bank
typedef enum
{
	WORD_EOF = 0,
	WORD_HELP,
	WORD_VOLUME,
	WORD_TEMP,
	WORD_TONE,
	WORD_START,
	WORD_STOP,
	WORD_PAUZE,
	WORD_RECORD,
	WORD_REPEAT,
	WORD_PLUS,
	WORD_MINUS,
	WORD_NUMBER,
	WORD_FILES,
	WORD_TENS,
	WORD_ONES,
	WORD_ZERO,
	WORD_ONE,
	WORD_TWO,
	WORD_THRE,
	WORD_FOUR,
	WORD_FIVE,
	WORD_SIX,
	WORD_SEVENT,
	WORD_EIGHT,
	WORD_NINE,
	WORD_VARIANT,
	WORD_SELECT,
	WORD_INS,
	WORD_GAME,
	WORD_SOUND_VARIANT,
	WORD_NET
} eWords;

typedef struct
{
	UInt16	mode;			// Keyboard mode
	UInt16  key;			// Key pressed
	UInt16	word[4];		// Help phrase (0 terminated)
} tHelpList;


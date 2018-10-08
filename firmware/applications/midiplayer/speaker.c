/*****************************************************************************
 * @project SndSynt
 * @info Sound synthesizer library and MIDI file player.
 * @platform DSP
 * @autor Valery P. (https://github.com/hww)
 *****************************************************************************/

#include "controls.h"
#include "terminal.h"
#include "mfr16.h"

/*****************************************************************************
 *
 *  The sequence of narration for voice over
 *
 *****************************************************************************/

const tHelpList HelpList[]=
{
    // In any case
    {KBD_MODE_ANY,KEY_HELP,     {WORD_HELP,0,0,0}},
    {KBD_MODE_ANY,KEY_M1,       {WORD_TEMP,WORD_TONE,0,0}},
    {KBD_MODE_ANY,KEY_M2,       {WORD_SELECT,WORD_FILES,0,0}},
    {KBD_MODE_ANY,KEY_M3,       {WORD_SELECT,WORD_INS,0,0}},
    {KBD_MODE_ANY,KEY_M4,       {WORD_VARIANT,WORD_SOUND_VARIANT,0,0}},
    {KBD_MODE_ANY,KEY_M5,       {WORD_SELECT,WORD_GAME,0}},
    {KBD_MODE_ANY,KEY_NEXT,     {WORD_REPEAT,0,0,0}},
    {KBD_MODE_ANY,KEY_PREV,     {WORD_REPEAT,WORD_TWO,0,0}},
    // Modes tone, tempo
    {KBD_MODE_TONE,KEY_PLAY,    {WORD_START,WORD_FILES,0,0}},
    {KBD_MODE_TONE,KEY_STOP,    {WORD_STOP,WORD_FILES,0,0}},
    {KBD_MODE_TONE,KEY_PLUS_10, {WORD_TEMP,WORD_PLUS,0,0}},
    {KBD_MODE_TONE,KEY_MINUS_10,{WORD_TEMP,WORD_MINUS,0,0}},
    {KBD_MODE_TONE,KEY_PLUS_1,  {WORD_TONE,WORD_PLUS,0,0}},
    {KBD_MODE_TONE,KEY_MINUS_1, {WORD_TONE,WORD_MINUS,0,0}},
    // Modes choose song
    {KBD_MODE_FILE,KEY_PLAY,    {WORD_START,WORD_FILES,0,0}},
    {KBD_MODE_FILE,KEY_STOP,    {WORD_STOP,WORD_FILES,0,0}},
    {KBD_MODE_FILE,KEY_PLUS_10, {WORD_NUMBER,WORD_FILES,WORD_TENS,WORD_PLUS}},
    {KBD_MODE_FILE,KEY_MINUS_10,{WORD_NUMBER,WORD_FILES,WORD_TENS,WORD_MINUS}},
    {KBD_MODE_FILE,KEY_PLUS_1,  {WORD_NUMBER,WORD_FILES,WORD_ONES,WORD_PLUS}},
    {KBD_MODE_FILE,KEY_MINUS_1, {WORD_NUMBER,WORD_FILES,WORD_ONES,WORD_MINUS}},
    // Modes choose instrument
    {KBD_MODE_INS,KEY_PLAY,     {WORD_START,WORD_FILES,0,0}},
    {KBD_MODE_INS,KEY_STOP,     {WORD_STOP,WORD_FILES,0,0}},
    {KBD_MODE_INS,KEY_PLUS_10,  {WORD_VOLUME,WORD_PLUS,0,0}},
    {KBD_MODE_INS,KEY_MINUS_10, {WORD_VOLUME,WORD_MINUS,0,0}},
    {KBD_MODE_INS,KEY_PLUS_1,   {WORD_NUMBER,WORD_INS,WORD_PLUS,0}},
    {KBD_MODE_INS,KEY_MINUS_1,  {WORD_NUMBER,WORD_INS,WORD_MINUS,0}},
    // Modes game
    {KBD_MODE_GAME,KEY_PLAY,    {WORD_START,WORD_GAME,0,0}},
    {KBD_MODE_GAME,KEY_STOP,    {WORD_STOP,WORD_GAME,0,0}},
    {KBD_MODE_GAME,KEY_PLUS_10, {WORD_NUMBER,WORD_GAME,WORD_PLUS,0}},
    {KBD_MODE_GAME,KEY_MINUS_10,{WORD_NUMBER,WORD_GAME,WORD_MINUS,0}},
    {KBD_MODE_GAME,KEY_PLUS_1,  {WORD_VARIANT,WORD_GAME,WORD_PLUS,0}},
    {KBD_MODE_GAME,KEY_MINUS_1, {WORD_VARIANT,WORD_GAME,WORD_MINUS,0}},
    // Last line
    {KBD_MODE_UNDEFINED,0,      {0,0,0,0}}
};

static ALVoice  speaker;                // Voice channel
static Int16    wordIdx;                // Number of sounded words
static UInt16   speakList[4];           // List of words to say

/*****************************************************************************
 *
 *  Help on the key
 *
 *****************************************************************************/

void speakerUpdate( ALSeqPlayer * seqp)
{
    ALSound *   snd;
    int         ok;
    // Wait request
    if(wordIdx == -1) return;
    // Wait previous word
    if((speaker.state & AL_SF_ACTIVE) != 0) return;
    // In case if all 4 words finished
    if((wordIdx == 4) || (speakList[wordIdx] == WORD_EOF))
    {   wordIdx = -1;
        return;
    }
    // Chose sound word to play
    snd = seqp->bank->instArray[125]->soundArray[speakList[wordIdx]-1];
    // In case of first word of sentence
    ok = alSynAllocVoice( seqp->drvr, &speaker, 40 );
    if(ok != 0)
    {
        if(snd->wavetable->rate == MIXFREQ)
            speaker.unityPitch = 0x8000;
        else
            speaker.unityPitch = div_s(negate(snd->wavetable->rate),MIXFREQ);
        // Play
        alSynSetGain( seqp->drvr, &speaker, 0x7fff);
        alSynStartVoiceParams(  seqp->drvr, &speaker, snd->wavetable,
                                  0x10000L, 0x7fff, 0x40, 0, 0);
        wordIdx++;
    }
}

void speakWords(  const UInt16 * ptr )
{
    int n;
    if(wordIdx == -1)
    {   for(n = 0; n<4 ;n++) speakList[n] = *ptr++;
        wordIdx = 0;
        speaker.state = 0;
    }
}

void speakDigit(  UInt16  val )
{
    int n;
    if(wordIdx == -1)
    {   for(n = 0; n<4 ;n++) speakList[n] = 0;
        speakList[0]= val + WORD_ZERO;
        wordIdx = 0;
        speaker.state = 0;
    }
}

void speakCreate( )
{
    wordIdx = -1;
}
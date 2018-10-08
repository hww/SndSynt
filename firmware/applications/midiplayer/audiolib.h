/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#ifndef __SOUND_H
#define __SOUND_H

#include "port.h"
#include "size_t.h"
#include "arch.h"
#include "stdio.h"

#ifdef __cplusplus
extern "C" {
#endif

#define DI  archDisableInt()
#define EI  archEnableInt()

/*****************************************************************************
 * Data types
 *****************************************************************************/

typedef char s8;
typedef unsigned char u8;
typedef Int16  s16;
typedef UInt16 u16;
typedef Int32  s32;
typedef UInt32 u32;
typedef Int32  f32;
typedef UInt32 Ptr32;

/*****************************************************************************
 * Settings and definitions
 *****************************************************************************/

#define PCHANELS 16                         // Polyphony
#define MAX_VOICES 32                       // Virtual voices
#define MAX_EVENTS 96                       // Max events
#define MAX_CHANNELS 16                     // Max MIDI channels
#define MIX_BUF_SIZE 640                    // buffer of samples mixer 10 ms
#define VOL_BUF_SIZE MIX_BUF_SIZE/32        // fadeout buffer 4 mks
#define CASH_L2_SIZE MIX_BUF_SIZE           // sample's renderer buffer 10 ms
#define CASH_L1_SIZE (CASH_L2_SIZE << 1)    // sample's cache buffer
#define MIXFREQ 32000                       // Sample frequency
#define FRAME_TIME_US  20000                // Time uS for single frame
#define FRAME_SIZE (MIXFREQ/1000*(FRAME_TIME_US/1000)) // Size of file in samples
#define FRAME_BUF_SIZE (FRAME_SIZE << 1)    // Size of all frames in samples
#define FX_ADDR  0xC000                     // Buffer start FX
#define FX_MODULO (0xFFFF-FX_ADDR)          // For MODULO
#define FX_SIZE  (FX_MODULO + 1)            // Buffer size for FX
#define FX_SCALE (0x7FFF/0x7F)              // Volume scale FX
#define PAN_SCALE ((0x7FFF)/0x7F)           // Volume scale
#define MAX_PRIORITY    127                 // Max priority
#define INT2FRAC(x) (x * (0x7FFF/0x7F))     // Scale 0..127 to 0..32767
#define ms *(((Int32)MIXFREQ/500) & ~0x1)   // Convert ms to stereo16
#define FX_OUT_MAX_POINTERS 4
#define ENVELOPE_TIME_US  20000             // time uS on the single envelope unit
#define VOLUME_PRIORITY                     // priority of volume
#undef  DMAS_ON
#define NBUFFERS            16              // Number of DMAs
#define MAX_BUFFER_LENGTH   1024            // DMA buffer size

#include "alLinker.h"

/***********************************************************************
 * DMA Stuff
 ***********************************************************************/

typedef struct
{
    ALLink      node;
    UInt32      startAddr;          // reading pointer
    UInt16      lastFrame;          // last access time
    UInt16      *ptr;               // buffer pointer
} DMABuffer;

typedef struct
{
    u8          initialized;
    DMABuffer   *firstUsed;
    DMABuffer   *firstFree;

} DMAState;

#define START_DMA(addr,dst,size) sdram_load_64( (UInt32)addr, (UWord16*) dst, (size_t) size)

UInt16      dmaCallBack(UInt32 addr, UInt16 len, void *state);
typedef     UInt16(*ALDMAproc)(UInt32 addr, UInt16 len, void *state);
typedef     ALDMAproc(*ALDMANew)(void *state);
ALDMAproc   dmaNew(DMAState ** state);
void        CleanDMABuffs(void);


/***********************************************************************
 * Sample's flags
 ***********************************************************************/

#define AL_SF_LOOP      0x0001  // Sample has loop
#define AL_SF_FADEOUT   0x0002  // Sample has fadeout
#define AL_SF_ACTIVE    0x0010  // Sample is active
#define AL_SF_ALOCATED  0x0020  // Sample is polyphonic
#define AL_SF_ZERO      0x0040  // Sample has volume 0
#define AL_SF_TARGET    0x0080  // Sample has defined volume

/***********************************************************************
 * Sound flags
 ***********************************************************************/

#define AL_ENV_SUSTANE  0x0100  // Envelope with sustain
#define AL_ENV_LOOP     0x0200  // Envelope with loop
#define AL_ENV_VOL      0x0400  // Has volume envelope
#define AL_ENV_PAN      0x0800  // Has pan envelope
#define AL_INDEXED      0x8000  // Record is indexed

/***********************************************************************
 * MIN MAX DEFINES
 ***********************************************************************/

#define MIX_VOL_MAX     0x7F
#define PAN_CENTER      0x40
#define PAN_LEFT        0
#define PAN_RIGHT       0x7F
#define VOL_FULL        0x7F
#define KEY_MIN         0
#define KEY_MAX         127
#define DEFAULT_FXMIX   0
#define SUSTAIN         127

 /***********************************************************************
  * FX Stuff
  ***********************************************************************/

#define    AL_FX_NONE          0
#define    AL_FX_SMALLROOM     1
#define    AL_FX_BIGROOM       2
#define    AL_FX_CHORUS        3
#define    AL_FX_FLANGE        4
#define    AL_FX_ECHO          5
#define    AL_FX_CUSTOM        6

typedef UInt16   ALFxId;
typedef void    *ALFxRef;

/***********************************************************************
 * MicroTime & MiliTime
 ***********************************************************************/

#define AL_MAX_MICROTIME 999999999L

typedef  Int16  ALMiliTime;
typedef  Int32  ALMicroTime;

void        alMicroTimeSub(ALMicroTime * time, ALMicroTime delta);
void        alMicroTimeAdd(ALMicroTime * time, ALMicroTime delta);
ALMicroTime alMiliToMicro(ALMiliTime time);

/***********************************************************************
 * ADPCM State
 ***********************************************************************/

#define ADPCMVSIZE      8
#define ADPCMFSIZE      16

typedef short ADPCM_STATE[ADPCMFSIZE];

typedef  Int16  ALPan;

/***********************************************************************
 * data structures for sound banks
 ***********************************************************************/

typedef struct {
    Int16   left;
    Int16   right;
} stereo16;

typedef struct {
    Int32   left;
    Int32   right;
} stereo32;

/***********************************************************************
 * Sound Bank data
 ***********************************************************************/

#define AL_BANK_VERSION    'B2'

 /* Possible wavetable types */
enum {
    AL_BRR_WAVE = 0,
    AL_RAW_WAVE,
};

typedef struct {
    UInt16      velocityMin;
    UInt16      velocityMax;
    UInt16      keyMin;
    UInt16      keyMax;
    UInt16      keyBase;
    Int16      detune;
} ALKeyMap;

typedef struct ALWaveTable_s {
    UInt32      base;           /* ptr to start of wave data    */
    UInt32      len;            /* length of data in bytes      */
    UInt16      type;           /* compression type             */
    UInt16      flags;          /* offset/address flags         */
    UInt16      rate;
    UInt16      ltype;
    UInt32      start;
    UInt32      end;
    UInt32      count;
} ALWaveTable;

typedef struct {
    u16         type;
    u16         sustaneStart;
    u16         sustaneEnd;
    u16         loopStart;
    u16         loopEnd;
    u16         pointCount;
    struct
    {
        u16         val;
        ALMiliTime  time;
    }           pointArray[1];
} ALEnvelopeTable;

typedef struct ALSound_s {
    ALEnvelopeTable *envelope;
    ALEnvelopeTable *penvelope;
    ALKeyMap    *keyMap;
    ALWaveTable *wavetable;     /* offset to wavetable struct           */
    ALPan       samplePan;
    UInt16      sampleVolume;
    ALMiliTime  sampleFadeout;
    UInt16      flags;
} ALSound;

typedef struct {
    UInt16      volume;         /* overall volume for this instrument   */
    ALPan       pan;            /* 0 = hard left, 127 = hard right      */
    UInt16      priority;       /* voice priority for this instrument   */
    UInt16      flags;
    UInt16      vibType;        /* the type of tremelo osc. to use      */
    UInt16      vibRate;        /* the rate of the tremelo osc.         */
    UInt16      vibDepth;       /* the depth of the tremelo osc         */
    UInt16      vibDelay;       /* the delay for the tremelo osc        */
    Int16       bendRange;      /* pitch bend range in cents            */
    Int16       soundCount;     /* number of sounds in this array       */
    ALSound     *soundArray[1];
} ALInstrument;

typedef struct ALBank_s {
    UInt16              instCount;      /* number of programs in this bank */
    UInt16              flags;
    ALInstrument        *percussion;    /* default percussion for GM       */
    ALInstrument        *instArray[1];  /* ARRAY of instruments            */
} ALBank;

typedef struct {                /* Note: sizeof won't be correct        */
    UWord32     ctl_size;
    UWord32     tbl_size;
    Int16       revision;       /* format revision of this file         */
    Int16       bankCount;      /* number of banks                      */
    ALBank      *bankArray[1];  /* ARRAY of bank offsets                */
} ALBankFile;

void alBnkfNew(ALBankFile *ctl, Ptr32 tbl);
UWord32 snd_load_bank(char * name, ALBankFile** ctl, UInt32 addr);
UWord32 snd_load_tbl(char * name, UInt32 addr);

/*****************************************************************************
 *
 * Synthesizer
 *
 *****************************************************************************/
/*****************************************************************************
 * Single polyphony-channel
 *****************************************************************************/

typedef struct PVoice_s
{
    ALLink  node;               // link
    void   *vvoice;             // virtual voice pointer
    UInt32  pos;                // current position in the sample
    UInt16  fpos;               // fraction par of position in the sample
    UInt32  end;                // end of loop
    UInt32  endsub;             // subtract at the end
    UInt32  count;              // Loop's count
    UInt32  pitch;              // fixed point increment
    Int32   curVolume;          // current volume
    Int32   tgtVolume;          // target volume
    Int32   addVolume;          // volume increment
    Int16   phaseVolume;        // position in the 32х samples buffer
    Int16   curPan;             // current pan
    Int16   tgtPan;             // target pan
    Int16   addPan;             // pan increment
    Int16   gain;               // volume scale
    Int16   lvol;               // left volume
    Int16   rvol;               // right volume
} PVoice;

typedef struct Voice_s
{
    ALLink           node;      // link
    PVoice          *pvoice;    // polyphony voice
    ALWaveTable     *wavetable; // waveform parameters
    UInt16          state;      // (loop/one-shot)(release)
    UInt16          priority;   // sample's priority
    Frac16          unityPitch; // ratio Waverate/MIXFREQ
} ALVoice;

/*****************************************************************************
 * Synthesizer and it's configuration
 *****************************************************************************/

typedef ALMicroTime(*ALVoiceHandler)(void *);

typedef struct {
    //    s32                 maxVVoices;     /* obsolete */
    u16                 maxPVoices;
    //    s32                 maxUpdates;
    //    s32                 maxFXbusses;
    //    void                *dmaproc;
    //    ALHeap              *heap;
    //    s32                 outputRate;     /* output sample rate */
    //    ALFxId              fxType;
    UInt16                *params;
} ALSynConfig;

typedef struct
{
    ALLink      pFreeList;      // free polyphony-voices
    ALLink      pAllocList;     // used polyphony-voices
    ALLink      pLameList;      // lame polyphony-voices (maybe to delete)
    void       *clientData;     // player's data
    ALVoiceHandler handler;     // player's procedure
    ALMicroTime callTime;       // mks before call
    UInt32      samplesLeft;    // sample's count before call
    ALVoiceHandler fhandler;    // procedure pointer FRAME_TIME_US
    ALMicroTime fcallTime;      // mks before call f handler
    UInt16      numPVoices;     // number of polyphony-voices
    PVoice     *pvoice;         // voices list
    stereo32   *mix_buf;        // mixer buffer
} ALSynth;

void    alAudioFrame(ALSynth* s, stereo16 *outBuf, size_t samples);
void    alSynUpdate(ALSynth* s);
bool    alSynNew(ALSynth *s, ALSynConfig *cfg);
void    alSynDelete(ALSynth * s);
void    alSynAddPlayer(ALSynth *s, void *client);
void    alSynSetVol(ALSynth * synth, ALVoice *voice, Int16 vol, ALMicroTime time);
void    alSynStartVoice(ALSynth * synth, ALVoice *voice, ALWaveTable *w);
void    alSynSetPan(ALSynth * synth, ALVoice *voice, ALPan pan, ALMicroTime time);
void    alSynSetPitch(ALSynth * synth, ALVoice *voice, Int32 ratio);
void    alSynSetFXMix(ALSynth * synth, ALVoice *voice, Int16 fxmix);
void    alSynSetPriority(ALSynth * synth, ALVoice *voice, Int16 priority);
Int16   alSynGetPriority(ALSynth * synth, ALVoice *voice);
void    alSynStartVoiceParams(ALSynth * synth, ALVoice *voice, ALWaveTable *w,
                              Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix,
                              ALMicroTime t);
void    alSynStopVoice(ALSynth *drvr, ALVoice *voice);
Int16   alSynAllocVoice(ALSynth *s, ALVoice *v, UInt16 priority);
void    alSynFreeVoice(ALSynth *s, ALVoice *voice);
void    alSynSetGain(ALSynth * s, ALVoice *v, Int16 vol);

/*****************************************************************************
 *
 * Globals
 *
 *****************************************************************************/

typedef struct {
    ALSynth     drvr;
} ALGlobals;

extern ALGlobals * alGlobals;

void    alInit(ALGlobals *glob, ALSynConfig *c);
void    alClose(ALGlobals *glob);

/*****************************************************************************
 *
 * MIDI files bank
 *
 *****************************************************************************/

#define AL_SEQBANK_VERSION    'S1'

typedef struct {
    Ptr32       offset;
    s32         len;
} ALSeqData;

typedef struct {                /* Note: size of won't be correct       */
    s16         revision;       /* format revision of this file         */
    s16         seqCount;       /* number of sequences                  */
    ALSeqData   seqArray[1];    /* ARRAY of sequence info               */
} ALSeqFile;

typedef struct
{
    UInt32      drama;
    ALSeqFile   seqFile;
} ALSeqDir;

void    alSeqFileNew(ALSeqFile *f, Ptr32 base, UInt16 fnum);
unsigned char alSeqGet8(UWord32 * addr);
UWord32 alSeqGet32(UWord32 * addr);
UWord16 alSeqGet16(UWord32 * addr);
UWord32 alSeqFileLoad(char * name, UInt32 addr);

/*****************************************************************************
 *
 * Sequencer data
 *
 *****************************************************************************/

// Player states
#define AL_STOPPED      0
#define AL_PLAYING      1
#define AL_STOPPING     2

#define AL_DEFAULT_PRIORITY     5
#define AL_DEFAULT_VOICE        0
#define AL_MAX_CHANNELS         16

 /*
  * Audio Library event type definitions
  */
enum ALMsg {
    AL_SEQ_NOP_EVT,
    AL_SEQ_REF_EVT,         // Reference to a pending event in the sequence.
    AL_SEQ_MIDI_EVT,        // midi event
    AL_SEQP_MIDI_EVT,       // midi event to stop sequencer
    AL_TEMPO_EVT,           // change tempo
    AL_SEQP_TEMPO_EVT,      // change tempo
    AL_SEQ_END_EVT,         // end of sequence
    AL_NOTE_END_EVT,        // end of sound, voice is free
    AL_SEQP_EVOL_EVT,       // volume of envelope
    AL_SEQP_EPAN_EVT,       // pan of envelope
    AL_SEQP_META_EVT,
    AL_SEQP_PROG_EVT,       // change instrument
    AL_SEQP_API_EVT,
    AL_SEQP_VOL_EVT,        // event main volume
    AL_SEQP_LOOP_EVT,
    AL_SEQP_PRIORITY_EVT,   // change priority
    AL_SEQP_SEQ_EVT,
    AL_SEQP_BANK_EVT,       // change bank
    AL_SEQP_PLAY_EVT,       // play
    AL_SEQP_STOP_EVT,       // stop
    AL_SEQP_STOPPING_EVT,   // stop (FADEOUT)
    AL_TRACK_END,           // end of track
    AL_CSP_LOOPSTART,
    AL_CSP_LOOPEND,
    AL_CSP_NOTEOFF_EVT,
    AL_TREM_OSC_EVT,        // event TREMOLO OSC
    AL_VIB_OSC_EVT          // event VIBTRATO OSC
};

/*
 * Midi event definitions
 */
#define AL_EVTQ_END     0x7fffffff

enum AL_MIDIstatus {
    /* For distinguishing channel number from status */
    AL_MIDI_ChannelMask = 0x0F,
    AL_MIDI_StatusMask = 0xF0,

    /* Channel voice messages */
    AL_MIDI_ChannelVoice = 0x80,
    AL_MIDI_NoteOff = 0x80,
    AL_MIDI_NoteOn = 0x90,
    AL_MIDI_PolyKeyPressure = 0xA0,
    AL_MIDI_ControlChange = 0xB0,
    AL_MIDI_ChannelModeSelect = 0xB0,
    AL_MIDI_ProgramChange = 0xC0,
    AL_MIDI_ChannelPressure = 0xD0,
    AL_MIDI_PitchBendChange = 0xE0,

    /* System messages */
    AL_MIDI_SysEx = 0xF0, /* System Exclusive */

    /* System common */
    AL_MIDI_SystemCommon = 0xF1,
    AL_MIDI_TimeCodeQuarterFrame = 0xF1,
    AL_MIDI_SongPositionPointer = 0xF2,
    AL_MIDI_SongSelect = 0xF3,
    AL_MIDI_Undefined1 = 0xF4,
    AL_MIDI_Undefined2 = 0xF5,
    AL_MIDI_TuneRequest = 0xF6,
    AL_MIDI_EOX = 0xF7, /* End of System Exclusive */

    /* System real time */
    AL_MIDI_SystemRealTime = 0xF8,
    AL_MIDI_TimingClock = 0xF8,
    AL_MIDI_Undefined3 = 0xF9,
    AL_MIDI_Start = 0xFA,
    AL_MIDI_Continue = 0xFB,
    AL_MIDI_Stop = 0xFC,
    AL_MIDI_Undefined4 = 0xFD,
    AL_MIDI_ActiveSensing = 0xFE,
    AL_MIDI_SystemReset = 0xFF,
    AL_MIDI_Meta = 0xFF      /* MIDI Files only */
};

enum AL_MIDIctrl {
    AL_MIDI_DATA_ENTRY_H = 0x06,
    AL_MIDI_VOLUME_CTRL = 0x07,
    AL_MIDI_PAN_CTRL = 0x0A,
    AL_MIDI_EXPRESSION = 0x0B,
    AL_MIDI_PRIORITY_CTRL = 0x10, /* use general purpose controller for priority */
    AL_MIDI_FX_CTRL_0 = 0x14,
    AL_MIDI_FX_CTRL_1 = 0x15,
    AL_MIDI_FX_CTRL_2 = 0x16,
    AL_MIDI_FX_CTRL_3 = 0x17,
    AL_MIDI_FX_CTRL_4 = 0x18,
    AL_MIDI_FX_CTRL_5 = 0x19,
    AL_MIDI_FX_CTRL_6 = 0x1A,
    AL_MIDI_FX_CTRL_7 = 0x1B,
    AL_MIDI_FX_CTRL_8 = 0x1C,
    AL_MIDI_FX_CTRL_9 = 0x1D,
    AL_MIDI_DATA_ENTRY_L = 0x26,
    AL_MIDI_SUSTAIN_CTRL = 0x40,
    AL_MIDI_FX1_CTRL = 0x5B,
    AL_MIDI_FX3_CTRL = 0x5D,
    AL_MIDI_NRPN_L = 0x62,
    AL_MIDI_NRPN_H = 0x63,
    AL_MIDI_RPN_L = 0x64,
    AL_MIDI_RPN_H = 0x65,
    AL_MIDI_ALL_NOTES_OFF = 0x7B
};

enum AL_MIDImeta {
    AL_MIDI_META_TEMPO = 0x51,
    AL_MIDI_META_EOT = 0x2f
};

#define AL_CMIDI_BLOCK_CODE           0xFE
#define AL_CMIDI_LOOPSTART_CODE       0x2E
#define AL_CMIDI_LOOPEND_CODE         0x2D
#define AL_CMIDI_CNTRL_LOOPSTART      102
#define AL_CMIDI_CNTRL_LOOPEND        103
#define AL_CMIDI_CNTRL_LOOPCOUNT_SM   104
#define AL_CMIDI_CNTRL_LOOPCOUNT_BIG  105

typedef struct {
    Ptr32       curPtr;         /* ptr to the next event */
    s32         lastTicks;      /* sequence clock ticks (used by alSeqSetLoc) */
    s32         curTicks;       /* sequence clock ticks of next event (used by loop end test) */
    s16         lastStatus;     /* the last status msg */
} ALSeqMarker;

typedef struct {
    s32         ticks;          /* MIDI, Tempo and End events must start with ticks */
    u8          status;
    u8          byte1;
    u8          byte2;
    u32         duration;
} ALMIDIEvent;

typedef struct {
    s32         ticks;
    u8          status;
    u8          type;
    u8          len;
    u8          byte1;
    u8          byte2;
    u8          byte3;
} ALTempoEvent;

typedef struct {
    s32         ticks;
    u8          status;
    u8          type;
    u8          len;
} ALEndEvent;

typedef struct {
    struct ALVoice_s    *voice;
} ALNoteEvent;

typedef struct {
    struct ALVoice_s    *voice;
    ALMicroTime         delta;
    u8                  vol;
} ALVolumeEvent;

typedef struct {
    s16                 vol;
} ALSeqpVolEvent;

typedef struct {
    ALSeqMarker         *start;
    ALSeqMarker         *end;
    s32                  count;
} ALSeqpLoopEvent;

typedef struct {
    u8          chan;
    u8          priority;
} ALSeqpPriorityEvent;

typedef struct {
    void        *seq;   // pointer to a seq (could be an ALSeq or an ALCSeq).
} ALSeqpSeqEvent;

typedef struct {
    ALBank      *bank;
} ALSeqpBankEvent;

typedef struct {
    struct ALVoiceState_s      *vs;
} ALOscEvent;

typedef struct {
    s16                     type;
    union {
        ALMIDIEvent         midi;
        ALTempoEvent        tempo;
        ALEndEvent          end;
        ALNoteEvent         note;
        ALVolumeEvent       vol;
        ALSeqpLoopEvent     loop;
        ALSeqpVolEvent      spvol;
        ALSeqpPriorityEvent sppriority;
        ALSeqpSeqEvent      spseq;
        ALSeqpBankEvent     spbank;
        ALOscEvent          osc;
    } msg;
} ALEvent;

typedef struct {
    ALLink      node;
    ALMicroTime delta;
    ALEvent     evt;
} ALEventListItem;

typedef struct {
    ALLink      freeList;
    ALLink      allocList;
    s32         eventCount;
} ALEventQueue;

void            alEvtqNew(ALEventQueue *evtq, ALEventListItem *items, s32 itemCount);
ALMicroTime     alEvtqNextEvent(ALEventQueue *evtq, ALEvent *evt);
void            alEvtqPostEvent(ALEventQueue *evtq, ALEvent *evt, ALMicroTime delta);
void            alEvtqFlush(ALEventQueue *evtq);
void            alEvtqFlushType(ALEventQueue *evtq, s16 type);
void            alEvtqFlushVoice(ALEventQueue *evtq, void * vs);

#define AL_PHASE_NOTEOFF        0
#define AL_PHASE_NOTEON         1
#define AL_PHASE_SUSTAIN        2
#define AL_PHASE_RELEASE        3
#define AL_ENV_OFF              0
#define AL_ENV_ON               1
#define AL_ENV_HOLD             2

typedef struct ALEnvState_s {
    ALMicroTime EndTime;        // time of envelope segment end ABSOLUTE
    u16         Val;            // current envelope gain
    u16         Phase;          // SUSTANE
} ALEnvState;

typedef struct ALVoiceState_s {
    ALVoice     voice;
    ALSound     *sound;         // Sound pointer
    ALInstrument*instrument;    // Instrument pointer
    s32         pitch;          // Pitch state
    s32         vibrato;        // Vibrato state
    u16         envPhase;       // AL_PHASE_SUSTAIN, AL_PHASE_RELEASE, AL_PHASE_SUSTREL
    ALMicroTime fadeTime;       // Time RELEASE
    u16         fadeVol;        // Volume of sound
    ALEnvState  envVolState;    // State of volume envelope
    ALEnvState  envPanState;    // State of pan envelope
    u8          channel;        // channel assignment
    u8          key;            // note on key number
    u8          velocity;       // note on velocity
    void        *VibOscState;   // vibrato OSC
    u8          flags;          // vibrato enabled?
} ALVoiceState;

#define NO_OSC      0
#define VIBRATO_OSC 1

typedef struct {
    ALInstrument        *instrument;    /* instrument assigned to this chan */
    s16                 prog;           /* program number                   */
    s16                 bendRange;      /* pitch bend range in cents        */
    ALFxId              fxId;           /* type of fx assigned to this chan */
    ALPan               pan;            /* overall pan for this chan        */
    u8                  priority;       /* priority for this chan           */
    u8                  vol;            /* current volume for this chan     */
    u8                  fxmix;          /* current fx mix for this chan     */
    u8                  sustain;        /* current sustain pedal state      */
    s32                 pitchBend;      /* current pitch bend val in cents  */
} ALChanState;

typedef struct ALSeq_s {
    Ptr32       base;                   /* ptr to start of sequence file   */
    Ptr32       trackStart;             /* ptr to first MIDI event         */
    Ptr32       curPtr;                 /* ptr to next event to read       */
    s32         lastTicks;              /* MIDI ticks for(ДО) last event   */
    s32         len;                    /* length of sequence in bytes     */
    f32         qnpt;                   /* qrter notes / tick (1/division) */
    s16         division;               /* ticks per quarter note          */
    s16         lastStatus;             /* for running status              */
} ALSeq;

#define NO_SOUND_ERR_MASK          0x01
#define NOTE_OFF_ERR_MASK          0x02
#define NO_VOICE_ERR_MASK          0x04

typedef struct {
    s32         maxVoices;         /* max number of voices to alloc    */
    s32         maxEvents;         /* max internal events to support   */
    u8          maxChannels;       /* max MIDI channels to support (16)*/
    u8          debugFlags;        /* control which error get reported */
    void        *initOsc;
    void        *updateOsc;
    void        *stopOsc;
} ALSeqpConfig;

typedef ALMicroTime(*ALOscInit)(void **oscState, Int32 *initVal, UInt16 oscType,
    UInt16 oscRate, UInt16 oscDepth, UInt16 oscDelay);
typedef ALMicroTime(*ALOscUpdate)(void *oscState, Int32 *updateVal);
typedef void(*ALOscStop)(void *oscState);

typedef struct {
    ALSynth             *drvr;          /* reference to the client driver   */
    ALSeq               *target;        /* current sequence                 */
    ALMicroTime         curTime;
    ALBank              *bank;          /* current ALBank                   */
    s32                 uspt;           /* microseconds per tick            */
    s32                 nextDelta;      /* microseconds to next callback    */
    s32                 state;
    u16                 chanMask;       /* active channels                  */
    s16                 vol;            /* overall sequence volume          */
    s16                 relTone;        /* Относительная нота */
    s16                 xTempo;         /* множитель темпа */
    s32                 Tempo;          /* темп в микросекундах */
    u8                  maxChannels;    /* number of MIDI channels          */
    u8                  debugFlags;     /* control which error get reported */
    ALEvent             nextEvent;
    ALEventListItem    *eventItems;
    ALEventQueue        evtq;
    s32                 fnextDelta;      /* microseconds to next callback    */
    ALEvent             fnextEvent;
    ALEventListItem    *feventItems;
    ALEventQueue        fevtq;
    ALMicroTime         frameTime;
    ALChanState        *chanState;      /* 16 channels for MIDI             */
    ALVoiceState       *vvoices;
    ALLink              vAllocList;     /* list of allocated voice state structs */
    ALLink              vFreeList;      /* list of free voice state structs */
    ALOscInit           initOsc;
    ALOscUpdate         updateOsc;
    ALOscStop           stopOsc;
    ALSeqMarker         *loopStart;
    ALSeqMarker         *loopEnd;
    s32                 loopCount;          /* -1 = loop forever, 0 = no loop   */
} ALSeqPlayer;

/*
 * Sequence data representation routines
 */
void    alSeqNew(ALSeq *seq, Ptr32 ptr, s32 len);
void    alSeqNextEvent(ALSeq *seq, ALEvent *event);
s32     alSeqGetTicks(ALSeq *seq);
f32     alSeqTicksToSec(ALSeq *seq, s32 ticks, u32 tempo);
u32     alSeqSecToTicks(ALSeq *seq, f32 sec, u32 tempo);
void    alSeqNewMarker(ALSeq *seq, ALSeqMarker *m, u32 ticks);
void    alSeqSetLoc(ALSeq *seq, ALSeqMarker *marker);
void    alSeqGetLoc(ALSeq *seq, ALSeqMarker *marker);

/*
 * Sequence Player routines
 */
f32     alCents2Ratio(s32 cents);
UInt32  alGetLinearRate(UWord16 note, Int16 finetune);

void    alSeqpNew(ALSeqPlayer *seqp, ALSeqpConfig *config);
void    alSeqpDelete(ALSeqPlayer *seqp);
void    alSeqpSetSeq(ALSeqPlayer *seqp, ALSeq *seq);
ALSeq   *alSeqpGetSeq(ALSeqPlayer *seqp);
void    alSeqpPlay(ALSeqPlayer *seqp);
void    alSeqpStop(ALSeqPlayer *seqp);
s32     alSeqpGetState(ALSeqPlayer *seqp);
void    alSeqpSetBank(ALSeqPlayer *seqp, ALBank *b);
void    alSeqpSetTempo(ALSeqPlayer *seqp, s32 tempo);
void    alSeqpSetTempoX(ALSeqPlayer *seqp, Int16 xTempo);
s32     alSeqpGetTempo(ALSeqPlayer *seqp);
s16     alSeqpGetVol(ALSeqPlayer *seqp);        /* Master volume control */
void    alSeqpSetVol(ALSeqPlayer *seqp, s16 vol);
void    alSeqpLoop(ALSeqPlayer *seqp, ALSeqMarker *start, ALSeqMarker *end, s32 count);

void    alSeqpSetChlProgram(ALSeqPlayer *seqp, u8 chan, u8 prog);
s32     alSeqpGetChlProgram(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlFXMix(ALSeqPlayer *seqp, u8 chan, u8 fxmix);
u8      alSeqpGetChlFXMix(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlVol(ALSeqPlayer *seqp, u8 chan, u8 vol);
u8      alSeqpGetChlVol(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlPan(ALSeqPlayer *seqp, u8 chan, ALPan pan);
ALPan   alSeqpGetChlPan(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlPriority(ALSeqPlayer *seqp, u8 chan, u8 priority);
u8      alSeqpGetChlPriority(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSendMidi(ALSeqPlayer *seqp, s32 ticks, u8 status, u8 byte1, u8 byte2);
void    alSeqpEnvPhase(ALSeqPlayer * seqp, ALVoiceState * vs);

/***********************************************************************
 * Hardware MIDI stuff
 ***********************************************************************/

void    midiOpen(void);
void    midiClose(void);
int     midiGetMsg(ALEvent * evt);

/***********************************************************************
 * OSC stuff
 ***********************************************************************/

#define  VIBRATO_SIN        1
#define  VIBRATO_SQR        2
#define  VIBRATO_DSC_SAW    3
#define  VIBRATO_ASC_SAW    4
#define  VIBRATO_MASK       7

#define  OSC_HIGH   0
#define  OSC_LOW    1
#define  TWO_PI     6.2831853

typedef struct {
    UInt16   rate;
    UInt16   depth;
    UInt16   oscCount;
} defData;

typedef struct {
    Int16    depthcents;
} vibSinData;

typedef struct {
    Int16    loRatio;
    Int16    hiRatio;
} vibSqrData;

typedef struct {
    Int16   hicents;
    Int16   centsrange;
} vibDSawData;

typedef struct {
    Int16   locents;
    Int16   centsrange;
} vibASawData;

typedef struct oscData_s {
    struct oscData_s  *next;
    UInt16  type;
    UInt16  stateFlags;
    UInt16  maxCount;
    UInt16  curCount;
    union {
        defData         def;
        vibSinData      vsin;
        vibSqrData      vsqr;
        vibDSawData     vdsaw;
        vibASawData     vasaw;
    } data;
} oscData;

ALMicroTime initOsc(void **oscState, Int32 *initVal, UInt16 oscType,
    UInt16 oscRate, UInt16 oscDepth, UInt16 oscDelay);
ALMicroTime updateOsc(void *oscState, Int32 *updateVal);
void stopOsc(void *oscState);
void createAllOsc(void);

#ifdef __cplusplus
}
#endif

#endif




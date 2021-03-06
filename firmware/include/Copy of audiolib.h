/*====================================================================
 * sound.h
 *
 * DPMS
 *
 *====================================================================*/

#ifndef __SOUND_H
#define __SOUND_H

#include "port.h"
#include "size_t.h"

#ifdef __cplusplus
extern "C" {
#endif

/*****************************************************************************
* ���� ������
******************************************************************************/

typedef char s8;
typedef unsigned char u8;
typedef Int16  s16;
typedef UInt16 u16;
typedef Int32  s32;
typedef UInt32 u32;
typedef Int32  f32;
typedef UInt32 Ptr32;

/*****************************************************************************
* �������� ������� ������
******************************************************************************/
#undef FX_ON								// ���������� ��������
#define PCHANELS 16							// ���������� �������������� �������
#define MAX_VOICES 32						// ����������� �������
#define MAX_EVENTS 96						// �������� ���������
#define MAX_CHANNELS 24						// ���������� ���� �������
#define MIX_BUF_SIZE 640					// ����� ������� ������� 10 ��
#define FADE_BUF_SIZE 128					// ����� fadeout ������� 4 ���
#define CASH_L2_SIZE MIX_BUF_SIZE			// ����� ���������� ������� 10 ��
#define CASH_L1_SIZE (CASH_L2_SIZE << 1)	// ����� ����������� �������
#define MIXFREQ 32000						// ������� �������������
#define FRAME_TIME_US  20000				// ����� � uS �� ���� �����
#define FRAME_SIZE (MIXFREQ/1000*(FRAME_TIME_US/1000)) // ������ ������ ������ � �������
#define FRAME_BUF_SIZE (FRAME_SIZE << 1)	// ������ ���� ������� � �������
#define	FX_ADDR  0xC000						// ������ ������ ������ FX
#define	FX_MODULO (0xFFFF-FX_ADDR)			// ��� ���� MODULO
#define	FX_SIZE  (FX_MODULO + 1)			// ������ ������ FX
#define FX_SCALE (0x7FFF/0x7F)				// ������� ��������� FX
#define PAN_SCALE ((0x7FFF)/0x7F)			// ������� ���������
#define MAX_PRIORITY    127					// ������������ ���������
#define INT2FRAC(x) (x * (0x7FFF/0x7F))			// ��������������� 0..127 � 0..32767
#define ms *(((Int32)MIXFREQ/500) & ~0x1)	// �������������� ms � stereo16
#define FX_OUT_MAX_POINTERS 4
#define ENVELOPE_TIME_US  20000				// ����� � uS �� ������� ���������
#define VOLUME_PRIORITY						// ��������� ������� ����������
#undef  DMAS_ON
#define NBUFFERS       		16				// ����� ������� DMA	
#define MAX_BUFFER_LENGTH 	1024			// ������ ������ DMA
#define FADE_SUB_VAL 16					// �������� fadeout
/***********************************************************************
 * Link betwin records
 ***********************************************************************/

typedef struct ALLink_s {
    struct ALLink_s      *next;
    struct ALLink_s      *prev;
} ALLink;

void    alUnlink(ALLink *element);
void    alLink(ALLink *element, ALLink *after);

/***********************************************************************
 * DMA Stuff
 ***********************************************************************/

typedef struct 
{
    ALLink      node;
    UInt32      startAddr;			// ����� ������ ����� ���������
    UInt16      lastFrame;			// � ����� ������ � ���� ����������
    UInt16      *ptr;				// ��� � ������ �����
} DMABuffer;

typedef struct 
{
    u8          initialized;
    DMABuffer   *firstUsed;
    DMABuffer   *firstFree;

} DMAState;

#define START_DMA(addr,dst,size) sdram_load_64( (UInt32)addr, (UWord16*) dst, (size_t) size)

UInt16 		dmaCallBack(UInt32 addr, UInt16 len, void *state);
typedef 	UInt16 (*ALDMAproc)(UInt32 addr, UInt16 len, void *state);
typedef 	ALDMAproc (*ALDMANew)(void *state);
ALDMAproc 	dmaNew(DMAState ** state);
void 		CleanDMABuffs(void);

/***********************************************************************
 * � ���������� ����� ����� ���� �����
 ***********************************************************************/

// ����� �����

#define AL_SF_LOOP      0x0001	// ����� ����� �����
#define AL_SF_FADEOUT   0x0002	// ����� ����� �����
#define AL_SF_ACTIVE    0x0010	// ��������� � �������� ���������

// ����� ������

#define AL_ENV_SUSTANE 	0x0100	// ��������� � ���������
#define AL_ENV_LOOP    	0x0200	// ��������� � �����
#define AL_ENV_VOL   	0x0400	// ���� ��������� ���������
#define AL_ENV_PAN   	0x0800	// ���� ��������� ��������

#define AL_INDEXED		0x8000	// ������ ����������������

/***********************************************************************
 * MIN MAX DEFINES
 ***********************************************************************/
 
#define MIX_VOL_MAX		0x7F
#define PAN_CENTER   	0x40
#define PAN_LEFT     	0
#define PAN_RIGHT    	0x7F
#define VOL_FULL     	0x7F
#define KEY_MIN      	0
#define KEY_MAX      	127
#define DEFAULT_FXMIX	0
#define SUSTAIN      	127

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

typedef  Int16	ALMiliTime;
typedef  Int32  ALMicroTime;

void		alMicroTimeSub( ALMicroTime * time, ALMicroTime delta);
void		alMicroTimeAdd( ALMicroTime * time, ALMicroTime delta);
ALMicroTime alMiliToMicro( ALMiliTime time );

/***********************************************************************
 * ADPCM State
 ***********************************************************************/

#define ADPCMVSIZE		8
#define ADPCMFSIZE      16

typedef short ADPCM_STATE[ADPCMFSIZE];
    
typedef  Int16  ALPan;

/***********************************************************************
 * data structures for sound banks
 ***********************************************************************/

typedef struct{
	Int16 	left;
	Int16	right;
} stereo16;

typedef struct{
	Int32 	left;
	Int32	right;
} stereo32;

/***********************************************************************
 * ��������� ��������� �����
 ***********************************************************************/

#define AL_BANK_VERSION    'B1'

/* Possible wavetable types */
enum    {AL_ADPCM_WAVE = 0,
         AL_RAW_WAVE,
};

typedef struct {
    Int32 order;
    Int32 npredictors;
    Int16 book[1];        /* Actually variable size. Must be 8-byte aligned */
} ALADPCMBook;

typedef struct {
    Int32       start;
    Int32       end;
    Int32       count;
    ADPCM_STATE state;
} ALADPCMloop;

typedef struct {
    UInt32      start;
    UInt32      end;
    UInt32      count;
} ALRawLoop;

typedef struct {
    ALMicroTime attackTime;
    ALMicroTime decayTime;
    ALMicroTime releaseTime;
    UInt16      attackVolume;
    UInt16      decayVolume;
} ALEnvelope;

typedef struct {
    UInt16      velocityMin;
    UInt16      velocityMax;
    UInt16      keyMin;
    UInt16      keyMax;
    UInt16      keyBase;
    Int16      detune;
} ALKeyMap;

typedef struct {
    ALADPCMloop *loop;
    ALADPCMBook *book;
} ALADPCMWaveInfo;

typedef struct {
    ALRawLoop *loop;
} ALRAWWaveInfo;

typedef struct ALWaveTable_s {
    Int32       base;           /* ptr to start of wave data    */
    Int32       len;            /* length of data in bytes      */
    UInt16      type;           /* compression type             */
    UInt16      flags;          /* offset/address flags         */
    Int16		pad;
	union {
        ALADPCMWaveInfo adpcmWave;
        ALRAWWaveInfo   rawWave;
    } waveInfo;
} ALWaveTable;

typedef struct {
	u16			type;
	u16			sustaneStart;
	u16			sustaneEnd;
	u16			loopStart;
	u16			loopEnd;
	u16			pointCount;
	struct
	{
		u16			val;
		ALMiliTime	time;		
	}			pointArray[1];
} ALEnvelopeTable;

typedef struct ALSound_s {
    ALEnvelopeTable *envelope;
    ALEnvelopeTable *penvelope;
    ALKeyMap    *keyMap;
    ALWaveTable *wavetable;     /* offset to wavetable struct           */
    ALPan       samplePan;
    UInt16      sampleVolume;
    ALMiliTime	sampleFadeout;	
    UInt16      flags;
} ALSound;

typedef struct {
    UInt16      volume;         /* overall volume for this instrument   */
    ALPan       pan;            /* 0 = hard left, 127 = hard right      */
    UInt16      priority;       /* voice priority for this instrument   */
    UInt16      flags;
    UInt16      tremType;       /* the type of tremelo osc. to use      */
    UInt16      tremRate;       /* the rate of the tremelo osc.         */
    UInt16      tremDepth;      /* the depth of the tremelo osc         */
    UInt16      tremDelay;      /* the delay for the tremelo osc        */
    UInt16      vibType;        /* the type of tremelo osc. to use      */
    UInt16      vibRate;        /* the rate of the tremelo osc.         */
    UInt16      vibDepth;       /* the depth of the tremelo osc         */
    UInt16      vibDelay;       /* the delay for the tremelo osc        */
    Int16       bendRange;      /* pitch bend range in cents            */
    Int16       soundCount;     /* number of sounds in this array       */
    ALSound     *soundArray[1];
} ALInstrument;

typedef struct ALBank_s {
    Int16               instCount;      /* number of programs in this bank */
    UInt16              flags;
   // UInt16              pad;
    Int32               sampleRate;     /* e.g. 44100, 22050, etc...       */
    ALInstrument        *percussion;    /* default percussion for GM       */
    ALInstrument        *instArray[1];  /* ARRAY of instruments            */
} ALBank;

typedef struct {                /* Note: sizeof won't be correct        */
	UWord32		ctl_size;
	UWord32		tbl_size;
    Int16       revision;       /* format revision of this file         */
    Int16       bankCount;      /* number of banks                      */
    ALBank      *bankArray[1];  /* ARRAY of bank offsets                */
} ALBankFile;

void alBnkfNew(ALBankFile *ctl, Ptr32 tbl);
ALBankFile *snd_load_bank( char * name );
UWord32 snd_load_tbl( char * name, UInt32 addr );

/*****************************************************************************
*
* ��������� �����������
*
******************************************************************************/


/*****************************************************************************
* ��������� ��������������� ������
******************************************************************************/

typedef struct PVoice_s
{   
// ���������� ��������������� ������
    ALLink  node;		 		// ������
	UInt16  priority;			// ��������� �� ����������� �����
    UInt16 	state;              // (loop/one-shot)(release)
    UInt32	pos;	            // ������� ������� � ������
	UInt16 	fpos;				// ������� ����� �������
    UInt32 	end;  	            // ����� �����
    UInt32 	endsub;             // ������ ��� ���������� �����
    UInt32  pitch;				// ������������� ����� ���������
	UInt16 	rvol;				// ��������� ������� ������					
	UInt16 	lvol;				// ��������� ������ ������
    UInt16	rfxmix;				// ������� FX	
    UInt16	lfxmix;				// ������� FX	
	UInt16	volf;				// ������� ��������� ������� �����
	Int16 	vol;                // ������� ��������� ( ����������� ������ �� volf !!)
    Int16	volgain;			// ������� ��������� 0..7FFF
	Int32	volinc;				// ������� ��������� 
    Int16   voltg;				// ��������� � ������� ���������
    UInt16 	panf;               // �������� ������� �����
    Int16 	pan;                // ������� �������� ( ����������� ������ �� pdnf !)
    Int16 	pantg;              // �������� � ������� ���������
	Int32	paninc;				// ������� ��������� 
    Int16	fxmix;				// ������� FX	 
    UInt16	fadeval;			// ������� fadeout   
    UInt16	fadesub;			// fadeout substract   
	void   *vvoice;
} PVoice;

#define AL_VOICE_ALLOCATE 1
#define AL_VOICE_PLAY	  2
#define AL_VOICE_SUSTANE  3

typedef struct Voice_s
{
    ALLink            node;		 // ������
    struct PVoice_s  *pvoice;    // ��������� �� �������������� �����
    ALWaveTable 	 *wavetable; // ��������� �������� �����
    UInt16 	          priority;  // ��������� ������
	s16				  state;	 // ��������� ������
} ALVoice;

/*****************************************************************************
* ��������� ����������� � ��������� ��� ���������������
******************************************************************************/

typedef ALMicroTime (*ALVoiceHandler)(void *);

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
    ALLink      pFreeList;      // ������ ��������� �������-�������
    ALLink      pAllocList;     // ������ ������� �������-�������
    ALLink      pLameList;      // ������ ������������ �������-�������
    void       *clientData;   	// ��������� �� ������ ������
    ALVoiceHandler handler;     // ��������� �� ��������� ������
    ALMicroTime    callTime;    // ���������� �� ������
    UInt32      samplesLeft;    // ������� ������� �� ������
    ALVoiceHandler fhandler;    // ��������� �� ��������� ������ � �������� FRAME_TIME_US    
    ALMicroTime    fcallTime;   // ���������� �� ������ fhandler
	UInt16      numPVoices;		// ����� �������������� �������
	PVoice     *pvoice;			// ��������� �� ����� �������
	UInt16 	   *cash_1;			// ��������� �� ��� ������� ������
	UInt16     *cash_2;			// ��������� �� ��� ������� ������
	stereo32   *mix_buf;		// ��������� �� ����� �������
	stereo32   *vol_buf;		// ��������� �� ����� ���������
    UInt16		fxptrnum;		// ���������� �������� ���������
    UInt16		fxinptr;		// ��������� ������� ������ FX 
    UInt16		fxdelay[FX_OUT_MAX_POINTERS];	// �������� � �������
    UInt16		fxvol[FX_OUT_MAX_POINTERS];		// ��������� 
} ALSynth;

void 	alAudioFrame(ALSynth* s, stereo16 *outBuf, size_t samples);
void 	alSynUpdate( ALSynth* s );
bool 	alSynNew( ALSynth *s , ALSynConfig *cfg);
void 	alSynDelete( ALSynth * s );
void 	alSynAddPlayer(ALSynth *s, void *client);
void 	alSynVolumeSlide( ALSynth * s );
void    alSynSetVol( ALSynth * synth, ALVoice *voice, Int16 vol, ALMicroTime time);
void    alSynStartVoice( ALSynth * synth, ALVoice *voice, ALWaveTable *w );
void    alSynSetPan( ALSynth * synth, ALVoice *voice, ALPan pan);
void    alSynSetPanTime( ALSynth * synth, ALVoice *voice, ALPan pan, ALMicroTime time);
void    alSynSetPitch( ALSynth * synth, ALVoice *voice, Int32 ratio);
void    alSynSetFXMix( ALSynth * synth, ALVoice *voice, Int16 fxmix);
void    alSynSetPriority( ALSynth * synth, ALVoice *voice, Int16 priority);
Int16   alSynGetPriority( ALSynth * synth, ALVoice *voice);
void    alSynStartVoiceParams(  ALSynth * synth, ALVoice *voice, ALWaveTable *w,
                              Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix,
                              ALMicroTime t);
void 	alSynStopVoice(ALSynth *drvr, ALVoice *voice);

Int16   alSynAllocVoice( ALSynth *s, ALVoice *v, UInt16 priority );
void    alSynFreeVoice(ALSynth *s, ALVoice *voice);
void    alSynSetGain( ALSynth * s, ALVoice *v, Int16 volume);
Int16   alSynGetGain( ALSynth * s, ALVoice *v );
void 	alSynEnvPhase( ALSynth * s, PVoice * v );
void 	alSynStartEnvelope( ALSynth * s, ALVoice * v, ALEnvelope * env , UInt16 phase );
Int16   alSynReAllocVoice( ALSynth *s, ALVoice *vold, ALVoice *vnew, UInt16 priority);
void	alSynFadeOut(ALSynth *s, ALVoice *voice);

/*****************************************************************************
*
* ���������� ����������
*
******************************************************************************/

typedef struct {
    ALSynth     drvr;
} ALGlobals;

extern ALGlobals * alGlobals;

void    alInit(ALGlobals *glob, ALSynConfig *c);
void    alClose(ALGlobals *glob);

/*****************************************************************************
*
* ��������� ����� ���� ������
*
******************************************************************************/

#define AL_SEQBANK_VERSION    'S1'

typedef struct {
    Ptr32       offset;
    s32         len;
} ALSeqData;

typedef struct {                /* Note: sizeof won't be correct        */
    s16         revision;       /* format revision of this file         */
    s16         seqCount;       /* number of sequences                  */
    ALSeqData   seqArray[1];    /* ARRAY of sequence info               */
} ALSeqFile;

void    alSeqFileNew(ALSeqFile *f, Ptr32 base, UInt16 fnum );
unsigned char alSeqGet8( UWord32 * addr );
UWord32 alSeqGet32( UWord32 * addr );
UWord16 alSeqGet16( UWord32 * addr );
UWord32 alSeqFileLoad( char * name, UInt32 addr );

/*****************************************************************************
*
* ��������� ����������
*
******************************************************************************/

/*
 * Play states
 */

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
    AL_SEQ_REF_EVT,			// Reference to a pending event in the sequence.
    AL_SEQ_MIDI_EVT,		// ���� ��������� 	
    AL_SEQP_MIDI_EVT,		// ���� ��������� ��������������� ���������
    AL_TEMPO_EVT,			// ��������� �����
    AL_SEQ_END_EVT,			// ����� ���������
    AL_NOTE_END_EVT,		// ���� �������� ����� �������������
    AL_SEQP_EVOL_EVT,		// ��������� ��������� ���������
    AL_SEQP_EPAN_EVT,		// ��������� �������� ���������
    AL_SEQP_META_EVT,
    AL_SEQP_PROG_EVT,		// ����� �����������
    AL_SEQP_API_EVT,		
    AL_SEQP_VOL_EVT,		// ��������� ��������� �����
    AL_SEQP_LOOP_EVT,
    AL_SEQP_PRIORITY_EVT,	// ����� ����������
    AL_SEQP_SEQ_EVT,	
    AL_SEQP_BANK_EVT,		// ����� �����
    AL_SEQP_PLAY_EVT,		// ���������������
    AL_SEQP_STOP_EVT,		// ����
    AL_SEQP_STOPPING_EVT,	// ��������� (FADEOUT)
    AL_TRACK_END,			// ����� �����
    AL_CSP_LOOPSTART,		
    AL_CSP_LOOPEND,
    AL_CSP_NOTEOFF_EVT,
    AL_TREM_OSC_EVT,		// ��������� TREMOLO OSC
    AL_VIB_OSC_EVT			// ��������� VIBTRATO OSC
};

/*
 * Midi event definitions
 */
#define AL_EVTQ_END     0x7fffffff

enum AL_MIDIstatus {
    /* For distinguishing channel number from status */
    AL_MIDI_ChannelMask         = 0x0F,
    AL_MIDI_StatusMask          = 0xF0,

    /* Channel voice messages */
    AL_MIDI_ChannelVoice        = 0x80,
    AL_MIDI_NoteOff             = 0x80,
    AL_MIDI_NoteOn              = 0x90,
    AL_MIDI_PolyKeyPressure     = 0xA0,
    AL_MIDI_ControlChange       = 0xB0,
    AL_MIDI_ChannelModeSelect   = 0xB0,
    AL_MIDI_ProgramChange       = 0xC0,
    AL_MIDI_ChannelPressure     = 0xD0,
    AL_MIDI_PitchBendChange     = 0xE0,

    /* System messages */
    AL_MIDI_SysEx               = 0xF0, /* System Exclusive */

    /* System common */
    AL_MIDI_SystemCommon            = 0xF1,
    AL_MIDI_TimeCodeQuarterFrame    = 0xF1,
    AL_MIDI_SongPositionPointer     = 0xF2,
    AL_MIDI_SongSelect              = 0xF3,
    AL_MIDI_Undefined1              = 0xF4,
    AL_MIDI_Undefined2              = 0xF5,
    AL_MIDI_TuneRequest             = 0xF6,
    AL_MIDI_EOX                     = 0xF7, /* End of System Exclusive */

    /* System real time */
    AL_MIDI_SystemRealTime  = 0xF8,
    AL_MIDI_TimingClock     = 0xF8,
    AL_MIDI_Undefined3      = 0xF9,
    AL_MIDI_Start           = 0xFA,
    AL_MIDI_Continue        = 0xFB,
    AL_MIDI_Stop            = 0xFC,
    AL_MIDI_Undefined4      = 0xFD,
    AL_MIDI_ActiveSensing   = 0xFE,
    AL_MIDI_SystemReset     = 0xFF,
    AL_MIDI_Meta            = 0xFF      /* MIDI Files only */
};

enum AL_MIDIctrl {
    AL_MIDI_VOLUME_CTRL         = 0x07,
    AL_MIDI_PAN_CTRL            = 0x0A,
    AL_MIDI_PRIORITY_CTRL       = 0x10, /* use general purpose controller for priority */
    AL_MIDI_FX_CTRL_0           = 0x14,
    AL_MIDI_FX_CTRL_1           = 0x15,
    AL_MIDI_FX_CTRL_2           = 0x16,
    AL_MIDI_FX_CTRL_3           = 0x17,
    AL_MIDI_FX_CTRL_4           = 0x18,
    AL_MIDI_FX_CTRL_5           = 0x19,
    AL_MIDI_FX_CTRL_6           = 0x1A,
    AL_MIDI_FX_CTRL_7           = 0x1B,
    AL_MIDI_FX_CTRL_8           = 0x1C,
    AL_MIDI_FX_CTRL_9           = 0x1D,
    AL_MIDI_SUSTAIN_CTRL        = 0x40,
    AL_MIDI_FX1_CTRL            = 0x5B,
    AL_MIDI_FX3_CTRL            = 0x5D,
    AL_MIDI_ALL_NOTES_OFF		= 123
};

enum AL_MIDImeta {
    AL_MIDI_META_TEMPO          = 0x51,
    AL_MIDI_META_EOT            = 0x2f
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
    s32	       	curTicks;		/* sequence clock ticks of next event (used by loop end test) */
    s16         lastStatus;     /* the last status msg */
} ALSeqMarker;

typedef struct {
    s32         ticks;    		/* MIDI, Tempo and End events must start with ticks */
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
    u8			chan;
    u8			priority;
} ALSeqpPriorityEvent;

typedef struct {
    void		*seq;	// pointer to a seq (could be an ALSeq or an ALCSeq). 
} ALSeqpSeqEvent;

typedef struct {
    ALBank		*bank;
} ALSeqpBankEvent;

typedef struct {
    struct ALVoiceState_s      *vs;
//    void                       *oscState;
//    u8                         chan;
} ALOscEvent;

typedef struct {
    s16                 	type;
    union {
        ALMIDIEvent     	midi;
        ALTempoEvent    	tempo;
        ALEndEvent      	end;
		ALNoteEvent     	note;
		ALVolumeEvent   	vol;
		ALSeqpLoopEvent 	loop;
		ALSeqpVolEvent  	spvol;
		ALSeqpPriorityEvent	sppriority;
		ALSeqpSeqEvent		spseq;
		ALSeqpBankEvent		spbank;
		ALOscEvent      	osc;
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
void        	alEvtqFlush(ALEventQueue *evtq);
void        	alEvtqFlushType(ALEventQueue *evtq, s16 type);
void			alEvtqFlushVoice(ALEventQueue *evtq, void * vs);

#define AL_PHASE_NOTEOFF        0
#define AL_PHASE_NOTEON         1
#define AL_PHASE_SUSTAIN        2
#define AL_PHASE_RELEASE        3
#define AL_ENV_OFF 				0
#define AL_ENV_ON  				1
#define AL_ENV_HOLD 			2

/*
#define AL_PHASE_ATTACK         0
#define AL_PHASE_NOTEON         0
#define AL_PHASE_DECAY          1
#define AL_PHASE_SUSTAIN        2
#define AL_PHASE_RELEASE        3
#define AL_PHASE_SUSTREL        4
*/

typedef struct
{
    ALMicroTime EndTime;     	// time of envelope segment end ABSOLUTE
    u16         Val;         	// current envelope gain        
    u16         Phase;       	// SUSTANE
} ALEnvState;

typedef struct ALVoiceState_s {
//    struct ALVoiceState_s *next;/* MUST be first                */
    ALVoice     voice;
    ALSound     *sound;			// ��������� �� ����
    ALInstrument*instrument;    // ��������� �� ����������
    s32         pitch;       	// ������� �������� ��������        
    s32         vibrato;     	// ������� �������� �������
	u16         envPhase;    	// AL_PHASE_SUSTAIN, AL_PHASE_RELEASE, AL_PHASE_SUSTREL 
	ALMicroTime	fadeTime;
	u16			fadeVol;		// ��������� �����
	ALEnvState	envVolState;
	ALEnvState  envPanState;
    u8          channel;        // channel assignment          
    u8          key;            // note on key number          
    u8          velocity;       // note on velocity            
	void		*VibOscState;	// ��� ��������� �������
    u8          flags;          // ������� ��������            
} ALVoiceState;

#define NO_OSC      0
#define VIBRATO_OSC 1

typedef struct {
    ALInstrument        *instrument;    /* instrument assigned to this chan */
    s16					prog;		    /* program number                   */
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
    Ptr32       curPtr;                	/* ptr to next event to read       */
    s32         lastTicks;              /* MIDI ticks for(��) last event   */
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
//  ALHeap      *heap;             /* ptr to initialized heap          */
    void        *initOsc;
    void        *updateOsc;
    void        *stopOsc;
} ALSeqpConfig;

typedef ALMicroTime   (*ALOscInit)(void **oscState,Int32 *initVal, UInt16 oscType,
                                   UInt16 oscRate, UInt16 oscDepth, UInt16 oscDelay);
typedef ALMicroTime   (*ALOscUpdate)(void *oscState, Int32 *updateVal);
typedef void          (*ALOscStop)(void *oscState);

typedef struct {
   //LPlayer            node;           /* note: must be first in structure */
    ALSynth             *drvr;          /* reference to the client driver   */
    ALSeq               *target;        /* current sequence                 */
    ALMicroTime         curTime;
    ALBank              *bank;          /* current ALBank                   */
    s32                 uspt;           /* microseconds per tick            */
    s32                 nextDelta;      /* microseconds to next callback    */
    s32                 state;
    u16                 chanMask;       /* active channels                  */
    s16                 vol;            /* overall sequence volume          */
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
    ALChanState        *chanState;     /* 16 channels for MIDI             */
	ALVoiceState       *vvoices;		
    ALLink        	    vAllocList;    /* list of alocated voice state structs */
    ALLink        	    vFreeList;     /* list of free voice state structs */
    ALOscInit           initOsc;
    ALOscUpdate         updateOsc;
    ALOscStop           stopOsc;
    ALSeqMarker         *loopStart;
    ALSeqMarker         *loopEnd;
    s32                 loopCount;      /* -1 = loop forever, 0 = no loop   */
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
s32		alSeqpGetState(ALSeqPlayer *seqp);
void    alSeqpSetBank(ALSeqPlayer *seqp, ALBank *b);
void    alSeqpSetTempo(ALSeqPlayer *seqp, s32 tempo);
s32     alSeqpGetTempo(ALSeqPlayer *seqp);
s16     alSeqpGetVol(ALSeqPlayer *seqp);		/* Master volume control */
void    alSeqpSetVol(ALSeqPlayer *seqp, s16 vol);
void    alSeqpLoop(ALSeqPlayer *seqp, ALSeqMarker *start, ALSeqMarker *end, s32 count);

void    alSeqpSetChlProgram(ALSeqPlayer *seqp, u8 chan, u8 prog);
s32     alSeqpGetChlProgram(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlFXMix(ALSeqPlayer *seqp, u8 chan, u8 fxmix);
u8      alSeqpGetChlFXMix(ALSeqPlayer *seqp, u8 chan);
void	alSeqpSetChlVol(ALSeqPlayer *seqp, u8 chan, u8 vol);
u8		alSeqpGetChlVol(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlPan(ALSeqPlayer *seqp, u8 chan, ALPan pan);
ALPan   alSeqpGetChlPan(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSetChlPriority(ALSeqPlayer *seqp, u8 chan, u8 priority);
u8      alSeqpGetChlPriority(ALSeqPlayer *seqp, u8 chan);
void    alSeqpSendMidi(ALSeqPlayer *seqp, s32 ticks, u8 status, u8 byte1, u8 byte2);
void 	alSeqpEnvPhase( ALSeqPlayer * seqp, ALVoiceState * vs );

/***********************************************************************
 * Hardware MIDI stuff
 ***********************************************************************/

void	midiOpen( void );
void 	midiClose( void );
int		midiGetMsg( ALEvent * evt );


/***********************************************************************
 * OSC stuff
 ***********************************************************************/

/******************************************************************************
*
*	���� ������� � �������
*
*******************************************************************************/

#define  VIBRATO_SIN        1
#define  VIBRATO_SQR        2
#define  VIBRATO_DSC_SAW    3
#define  VIBRATO_ASC_SAW    4
#define  VIBRATO_MASK		7        

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

ALMicroTime initOsc(void **oscState, Int32 *initVal,UInt16 oscType,
                    UInt16 oscRate,UInt16 oscDepth,UInt16 oscDelay);
ALMicroTime updateOsc(void *oscState, Int32 *updateVal);
void stopOsc(void *oscState);
void createAllOsc( void );

#ifdef __cplusplus
}
#endif

#endif




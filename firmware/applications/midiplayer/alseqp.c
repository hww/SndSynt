/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "mem.h"
#include "assert.h"
#include "mfr16.h"
#include "alseqp.h"
#include "alMControls.h"

/*****************************************************************************
 *
 * Sequence Player routines
 *
 *****************************************************************************/

/*****************************************************************************
 *
 *     f32    alCents2Ratio(s32 cents);
 *
 * PARAMETERS
 *     cents     the value measured in cents (a cent is 100th of a whole step)
 *
 * DESCRIPTION
 *     alCents2Ratio is a utility routine for converting a detune value measured
 *     in cents, into a ratio to be multiplied against the base pitch. Negative
 *     values lower the pitch, while positive values raise the pitch.
 *
 * EXAMPLE
 *     A value of 1200 cents will produce a ratio value of 2, which when
 *     multiplied times the base pitch, will produce a pitch one octave higher.
 *     A value of -1200 will produce a ratio value of 0.5, which when multiplied
 *     against the base pitch will produce a pitch of one octave lower.
 *
 *****************************************************************************/

f32     alCents2Ratio(s32 cents)
{
    return alGetLinearRate(5 * 12, cents);
}

/*****************************************************************************
 *
 *  UWord16 alGetLinearRate(UWord16 note, Int16 finetune)
 *
 * PARAMETERS
 *
 *   Note       tone from 0  to 95 (0 = C-0, 95 = B-7)
 *   finetune    from -1200 to +1200
 *              -100     -1 half tone,
 *              +100     +1 half tone,
 *              -1200    -1 octave
 *              +1200    +1 octave
 *
 *  ratestable[] for the octave 9, and "DO" at 5 octave has RATE 1.0 (aka 32000Hz)
 *
 *****************************************************************************/

#define OCT_OF_RATE_TABLE 9                 // Rate table for octave
#define BASE_NOTE (5*12)                    // Note without re-sampling

UWord32 ratestable[] =
{
    1048576L,   1110928L,   1176987L,   1246974L,
    1321123L,   1399681L,   1482910L,   1571089L,
    1664511L,   1763488L,   1868350L,   1979448L, 2097152L,
};

UInt32 alGetLinearRate(UWord16 note, Int16 finetune)
{
    UWord32 rate;
    UInt16  n, o;
    UInt16  ftnotes, ftpercents;

    finetune += 1200;               // positive 0..2400
    ftnotes = finetune / 100;       // offset 0..24
    ftpercents = finetune % 100;    // percent  0..99
    note = note - 12 + ftnotes;     // shift note
    n = note % 12;                  // note in octave
    o = note / 12;                  // octave
    rate = ratestable[n];           // get RATE

    if (ftpercents != 0)
    {
        rate *= (100 - ftpercents);
        rate += (ratestable[n + 1] * ftpercents);
        rate /= 100;
    }

    if (o < OCT_OF_RATE_TABLE)
    {
        // octave less than in table
        while (o < OCT_OF_RATE_TABLE)
        {
            rate >>= 1;
            o++;
        }
    }

    return rate;
}


void    alSeqpNew(ALSeqPlayer *seqp, ALSeqpConfig *config)
{
    int n, max;
    ALEventListItem * events;
    ALVoiceState    * voices;

    seqp->vol = 0x7fff;
    seqp->nextEvent.type = AL_SEQ_NOP_EVT;
    seqp->curTime = 0;
    seqp->nextDelta = 0;
    seqp->initOsc = config->initOsc;                                // OSCs of envelopes
    seqp->updateOsc = config->updateOsc;
    seqp->stopOsc = config->stopOsc;
    seqp->debugFlags = config->debugFlags;
    max = config->maxChannels;
    seqp->maxChannels = max;
    seqp->chanState = calloc(max, sizeof(ALChanState));             // memory for channels

    max = config->maxVoices;
    seqp->vvoices = calloc(max, sizeof(ALVoiceState));              // memory for voices

    seqp->vAllocList.next = NULL;
    seqp->vAllocList.prev = NULL;
    seqp->vFreeList.next = NULL;
    seqp->vFreeList.prev = NULL;

    for (n = 0; n < max; n++)
    {
        alLink(&seqp->vvoices[n].voice.node, &seqp->vFreeList);     // free list
    }

    seqp->chanMask = 0xFFFF;                                        // all chanels inactive

    max = config->maxEvents;
    seqp->eventItems = calloc(max, sizeof(ALEventListItem));        // for messages
    alEvtqNew(&seqp->evtq, seqp->eventItems, max);
    seqp->feventItems = calloc(max, sizeof(ALEventListItem));       // for free messages
    alEvtqNew(&seqp->fevtq, seqp->feventItems, max);

    seqp->drvr = &alGlobals->drvr;                                  // synthesizer
    seqp->drvr->handler = &alSeqpHandler;                           // player
    seqp->drvr->clientData = (void*)seqp;                           // sequencer
    seqp->drvr->fhandler = &alSeqpFrameHandler;                     // player
    seqp->xTempo = 0;
    seqp->relTone = 0;
    midiOpen();                                                     // open MIDI
}

/*****************************************************************************
 *
 *  void    alSeqpSetChlProgram(ALSeqPlayer *seqp, u8 chan, u8 prog)
 *  s32     alSeqpGetChlProgram(ALSeqPlayer *seqp, u8 chan)
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *   chan      MIDI channel
 *   prog      Instrument number
 *
 * DESCRIPTION
 *     Return and set instrument in the channel
 *
 *****************************************************************************/

void    alSeqpDelete(ALSeqPlayer *seqp)
{
    free(seqp->chanState);      // memory for channels
    free(seqp->vvoices);        // memory for voices
    free(seqp->eventItems);     // memory for events
    midiClose();
}

/*****************************************************************************
 *
 *  void    alSeqpSetSeq(ALSeqPlayer *seqp, ALSeq *seq)
 *  ALSeq  *alSeqpGetSeq(ALSeqPlayer *seqp)
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *   seq       MIDI sequence
 *
 * DESCRIPTION
 *    Set and return sequence
 *
 *****************************************************************************/

void    alSeqpSetSeq(ALSeqPlayer *seqp, ALSeq *seq)
{
    seqp->target = seq;
}

ALSeq  *alSeqpGetSeq(ALSeqPlayer *seqp)
{
    return seqp->target;
}

/*****************************************************************************
 *
 *  void    alSeqpPlay(ALSeqPlayer *seqp)
 *  void    alSeqpStop(ALSeqPlayer *seqp)
 *  s32     alSeqpGetState(ALSeqPlayer *seqp)
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *
 * DESCRIPTION
 *     Set and return sequencer state
 *
 *****************************************************************************/

void    alSeqpPlay(ALSeqPlayer *seqp)
{
    ALEvent evt;
    if (seqp->state == AL_PLAYING) return;
    seqp->state = AL_PLAYING;
    evt.type = AL_SEQP_PLAY_EVT;
    alEvtqPostEvent(&seqp->evtq, &evt, 10000);
}

void    alSeqpStop(ALSeqPlayer *seqp)
{
    ALVoiceState * vs;
    seqp->state = AL_STOPPED;
    vs = seqp->vAllocList.next;
    while (vs != NULL)
    {
        if (vs->envPhase != AL_PHASE_RELEASE) alSeqpVoiceOff(seqp, vs);
        vs = vs->voice.node.next;
    }
    alEvtqFlushType(&seqp->evtq, AL_SEQP_MIDI_EVT);
    alEvtqFlushType(&seqp->evtq, AL_SEQP_TEMPO_EVT);
}
s32     alSeqpGetState(ALSeqPlayer *seqp) { return seqp->state; }

/*****************************************************************************
 *
 * void alSeqpSetBank(ALSeqPlayer *seqp, ALBank *b);
 *
 * PARAMETERS
 *     seqp      pointer to the sequence player.
 *     b         pointer to the instrument bank to use.
 *
 * DESCRIPTION
 *     alSeqpSetBank specifies which ALBank the sequence player should use when
 *     mapping MIDI notes to instruments.  The bank must be loaded into RAM and
 *     initialized with a call to alBnkfNew before being used by alSeqpSetBank.
 *
 *****************************************************************************/

void    alSeqpSetBank(ALSeqPlayer *seqp, ALBank *b) { seqp->bank = b; }

/*****************************************************************************
 *
 *  void alSeqpSetTempo(ALSeqPlayer *seqp, s32 tempo);
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *    tempo     tempo in microseconds per MIDI quarter note.
 *
 * DESCRIPTION
 *     alSeqpSetTempo specifies a new sequence tempo for playback. Note that
 *     tempo change messages in the sequence will override tempos set with this
 *     call.
 *
 *****************************************************************************/

void    alSeqpSetTempo(ALSeqPlayer *seqp, s32 tempo)
{
    Int16 x = seqp->xTempo;
    s32   diff = tempo >> 2;

    seqp->Tempo = tempo;

    while (x > 0) { tempo -= diff; x--; }
    while (x < 0) { tempo += diff; x++; }

    seqp->uspt = tempo / seqp->target->division;        // ������� ���������� �������� � ����������
}

void    alSeqpSetTempoX(ALSeqPlayer *seqp, Int16 xTempo)
{
    seqp->xTempo = xTempo;
    alSeqpSetTempo(seqp, seqp->Tempo);
}

/*****************************************************************************
 *
 *  s32     alSeqpGetTempo(ALSeqPlayer *seqp);
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *
 * DESCRIPTION
 *     alSeqpGetTempo return tempo of quoter of tick in MKS.
 *
 *****************************************************************************/

s32     alSeqpGetTempo(ALSeqPlayer *seqp)
{
    return seqp->Tempo;
}

/*****************************************************************************
 *
 *  s16     alSeqpGetVol(ALSeqPlayer *seqp)
 *  void    alSeqpSetVol(ALSeqPlayer *seqp, s16 vol)
 *
 * PARAMETERS
 *    seqp    pointer to the sequence player.
 *   vol        volume, with 0x7fff is max
 *
 * DESCRIPTION
 *     Get or set volume of sequence player
 *
 *****************************************************************************/

s16     alSeqpGetVol(ALSeqPlayer *seqp) { return seqp->vol; }
void    alSeqpSetVol(ALSeqPlayer *seqp, s16 vol) { seqp->vol = vol; }

/*****************************************************************************
 *
 *  void    alSeqpLoop(ALSeqPlayer *seqp, ALSeqMarker *start, ALSeqMarker *end, s32 count)
 *
 * PARAMETERS
 *    seqp      pointer to the sequence player.
 *   start   loop start
 *   end         loop end
 *   count   repeats count
 *
 * DESCRIPTION
 *     Set loop at the sequence player
 *
 *****************************************************************************/

void    alSeqpLoop(ALSeqPlayer *seqp, ALSeqMarker *start, ALSeqMarker *end, s32 count)
{
    seqp->loopStart = start;
    seqp->loopEnd = end;
    seqp->loopCount = count;
}

/*****************************************************************************
 *
 * void    alSeqpSendMidi(ALSeqPlayer *seqp, long ticks, u8 status, u8 byte1, u8 byte2);
 *
 * PARAMETERS
 *     seqp      pointer to sequence player.
 *     ticks     time offset, in MIDI clock ticks that the MIDI event is to
 *               occur.
 *
 *     status    the message's MIDI status byte.
 *     byte1     the first byte in the message.
 *     byte2     the second byte in the message (if required).
 *
 * DESCRIPTION
 *     alSeqpSendMidi sends a MIDI message to the sequence player. This can be
 *     used to trigger notes not in the sequence, add controller information in
 *     real-time, or otherwise change the performance of a sequence.
 *     alSeqpSendMidi can be used as an alternative for alSeqpSetChlProgram,
 *     alSeqpSetChlVol, alSeqpSetChlPan, and alSeqpSetChlFXMix.
 *
 *     Note that only channel voice messages are supported. See the MIDI 1.0
 *     specification or any of the various World Wide Web MIDI pages for more
 *     information.
 *
 *     The ticks field contains the time offset (in MIDI clock ticks) at which
 *     the event is to occur. The status byte contains the message type in the
 *     high nibble and the channel number in the low nibble. The next bytes are
 *     the MIDI data, which is determined by the message type.
 *
 *****************************************************************************/

void    alSeqpSendMidi(ALSeqPlayer *seqp, s32 ticks, u8 status, u8 byte1, u8 byte2)
{
    ALEvent event;
    UInt16  chan;
    UInt16  cmd;
    ALChanState * chanstate;
    Int16   dword;

    cmd = status & AL_MIDI_StatusMask;
    chan = status & AL_MIDI_ChannelMask;
    if ((seqp->chanMask & (1 << chan)) == 0) return;

    if (ticks > 0)
    {   
        // delay event for given ticks
        event.type = AL_SEQ_MIDI_EVT;
        event.msg.midi.ticks = 0;
        event.msg.midi.status = status;
        event.msg.midi.byte1 = byte1;
        event.msg.midi.byte2 = byte2;
        alEvtqPostEvent(&seqp->evtq, &event, seqp->uspt * ticks);
    }
    else
    {
        chanstate = &seqp->chanState[chan];

        switch (cmd)
        {
        case AL_MIDI_NoteOn:
            if (byte2 > 0)      // volume 0 is release key
            {
                alSeqpKeyOn(seqp, chan, byte1, byte2);
                break;
            }
        case AL_MIDI_NoteOff:
            alSeqpKeyOff(seqp, chan, byte1, byte2);
            break;
        case AL_MIDI_ControlChange:
            alSeqpControlChange(seqp, chan, byte1, byte2);
            break;
        case AL_MIDI_ProgramChange:
            alSeqpSetChlProgram(seqp, chan, byte1);
            break;
        case AL_MIDI_PitchBendChange:
            // value 0 - 16383. the mid position is 8192
            dword = (byte1 + (byte2 << 7)) - 8192;
            chanstate->pitchBend = ((Int32)(chanstate->bendRange) * dword) / 8192;
            alSeqpChangePitch(seqp, chan);
            break;
        case AL_MIDI_PolyKeyPressure:
            break;
        case AL_MIDI_ChannelPressure:
            break;
        }
    }
}

/*****************************************************************************
 *
 *  void     alSeqpSwitchEvent( ALSeqPlayer *seqp, ALEvent * event)
 *
 *  Event handler
 *
 *****************************************************************************/

void     alSeqpSwitchEvent(ALSeqPlayer *seqp, ALEvent * event)
{
    Int16           etype;
    ALMicroTime     time;
    ALVoiceState    *vs;

    etype = event->type;

    switch (etype)
    {
    case AL_SEQP_MIDI_EVT:
        alSeqpPlayer(seqp);
    case AL_SEQ_MIDI_EVT:
        alSeqpSendMidi(seqp, 0,
            event->msg.midi.status,
            event->msg.midi.byte1,
            event->msg.midi.byte2);
        break;
    case AL_SEQP_TEMPO_EVT:
    case AL_TEMPO_EVT:
        time = ((UInt32)event->msg.tempo.byte1 << 16) +
            ((UInt16)event->msg.tempo.byte2 << 8) +
            ((UInt16)event->msg.tempo.byte3);

        alSeqpSetTempo(seqp, time);
        if (etype == AL_SEQP_TEMPO_EVT)alSeqpPlayer(seqp);
        break;

    case AL_SEQ_END_EVT:
        alSeqpStop(seqp);
        seqp->target->curPtr = seqp->target->trackStart;
        seqp->target->lastTicks = 0;
        seqp->target->lastStatus = 0;
        break;

    case AL_SEQP_EVOL_EVT:
        alSeqpEnvVolEvent(seqp, event);
        break;

    case AL_SEQP_EPAN_EVT:
        alSeqpEnvPanEvent(seqp, event);
        break;

    case AL_NOTE_END_EVT:
        //vs = event->msg.note.voice;
        //if(vs->flags != 0)
        //{ seqp->stopOsc(vs->VibOscState);
        //  vs->flags = 0;
        //}
        //alEvtqFlushVoice(&seqp->evtq, vs);
        //alSeqpFreeVoice( seqp, vs );
        break;

    case AL_SEQP_PLAY_EVT:
        alSeqpPlayer(seqp);
        break;

        //case AL_VIB_OSC_EVT:
        //  alSeqpVibOscEvent( seqp, event );
        //  break;

    case AL_SEQ_NOP_EVT:
        alEvtqPostEvent(&seqp->evtq, event, seqp->uspt * (seqp->target->division >> 5));
        while (midiGetMsg(event) != 0)
        {
            alSeqpSendMidi(seqp, 0, event->msg.midi.status, event->msg.midi.byte1, event->msg.midi.byte2);
        }
        break;
    }
}

/*****************************************************************************
 *
 *  ALMicroTime alSeqpHandler( void * data )
 *
 *  The event's player
 *
 *****************************************************************************/

ALMicroTime alSeqpHandler(void * data)
{
    ALSeqPlayer  * seqp = (ALSeqPlayer*)data;

    alMicroTimeAdd(&seqp->curTime, seqp->nextDelta);
    alSeqpEnvTimers(seqp, seqp->nextDelta);

    do
    {
        alSeqpSwitchEvent(seqp, &seqp->nextEvent);

        if (seqp->evtq.eventCount > 0)
        {
            // get closest in time event, and read it's time
            seqp->nextDelta = alEvtqNextEvent(&seqp->evtq, &seqp->nextEvent);
        }
        else
        {
            assert(!"No more evens");
        }

    } while (seqp->nextDelta == 0);

    if (seqp->nextDelta < 0)
    {
        assert(!"CallTime too big");
    }
    return seqp->nextDelta;
}

ALMicroTime alSeqpFrameHandler(void * data)
{
    ALSeqPlayer  * seqp = (ALSeqPlayer*)data;

    do
    {
        alSeqpVibOscEvent(seqp, &seqp->fnextEvent);
        // alSeqpSwitchEvent( seqp, &seqp->fnextEvent);
        // get closest in time event, and read it's time
        if (seqp->fevtq.eventCount != 0)
            seqp->fnextDelta = alEvtqNextEvent(&seqp->fevtq, &seqp->fnextEvent);
        else
        {
            seqp->fnextDelta = 0;
            break;
        }
    } while (seqp->fnextDelta == 0);

    if (seqp->fnextDelta < 0)
        assert(!"CallTime too big");
    return seqp->fnextDelta;
}

/*****************************************************************************
 *
 *  void alSeqpGetSomeEvents( ALSeqPlayer seqp )
 *
 *  Get events from queue until meet (DELTATIME > 0).
 *
 *****************************************************************************/

void alSeqpPlayer(ALSeqPlayer * seqp)
{
    ALEvent     evt;
    ALSeq      *seq = seqp->target;
    ALMicroTime time;

    evt.msg.midi.ticks = 0;                     // initialized

    while ((seqp->state == AL_PLAYING) && (evt.msg.midi.ticks == 0))
    {
        alSeqNextEvent(seq, &evt);              // get event
        if (evt.msg.midi.ticks == 0)            // execute event
        {
            alSeqpSwitchEvent(seqp, &evt);
        }
        else                                    // found delayed event, put it to queue
        {
            if (evt.type == AL_SEQ_MIDI_EVT) evt.type = AL_SEQP_MIDI_EVT;
            if (evt.type == AL_TEMPO_EVT) evt.type = AL_SEQP_TEMPO_EVT;
            time = seqp->uspt * evt.msg.midi.ticks;
            alEvtqPostEvent(&seqp->evtq, &evt, time);
        }
        if (seqp->loopEnd != NULL)
        {
            if (seqp->loopEnd->curPtr == seqp->target->curPtr)
            {
                if (seqp->loopCount == 0)
                {
                    alSeqpSendMidi(seqp, 0, AL_MIDI_ControlChange, AL_MIDI_ALL_NOTES_OFF, 0);
                    alSeqpStop(seqp);
                }
                else
                {
                    alSeqSetLoc(seqp->target, seqp->loopStart);
                    seqp->loopCount--;
                }
            }
        }
    }
}

/*****************************************************************************
 *
 *  ALVoiceState * alSeqpGetFreeVoice( ALSeqPlayer * seqp )
 *
 *  Return status of free voice.
 *  Attention!!!
 *      Does not terminate other voices just return null in worst case
 *
 *  void alSeqpFreeVoice( ALSeqPlayer * seqp, ALVoiceState * voice )
 *
 *      Release virtual voice
 *
 *  bool alSeqpCheckVoice( ALSeqPlayer * seqp, ALVoiceState * voice )
 *
 *      Check if voice linked with poly-voice. If it is not then
 *      release this voice.
 *
 *****************************************************************************/

ALVoiceState * alSeqpGetFreeVoice(ALSeqPlayer * seqp)
{
    ALVoiceState * vs = seqp->vFreeList.next;

    if (vs != NULL)                                     // has free voices ?
    {
        alUnlink(&vs->voice.node);
        alLink(&vs->voice.node, &seqp->vAllocList);
        return vs;
    }
    return NULL;
}

void alSeqpFreeVoice(ALSeqPlayer * seqp, ALVoiceState * voice)
{
    if (alSeqpCheckVoice(seqp, voice))                  // voice is linked to poly-voice
    {
        alSynStopVoice(seqp->drvr, &voice->voice);
        alSynFreeVoice(seqp->drvr, &voice->voice);
    }
    alUnlink(&voice->voice.node);
    alLink(&voice->voice.node, &seqp->vFreeList);
}

bool alSeqpCheckVoice(ALSeqPlayer * seqp, ALVoiceState * voice)
{
    return ((voice->voice.state & AL_SF_ALOCATED) != 0);// voice is linked?
}

void alSeqpFlushEventsOfVoice(ALSeqPlayer * seqp, ALVoiceState * vs)
{
    if ((vs->flags & VIBRATO_OSC) != 0)
    {
        seqp->stopOsc(vs->VibOscState);
        vs->flags &= ~VIBRATO_OSC;
    }
    alEvtqFlushVoice(&seqp->evtq, vs);
    alEvtqFlushVoice(&seqp->fevtq, vs);
}

/*****************************************************************************
 *
 *  void    alSeqpKeyOn( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity )
 *
 *  seqp        the sequence player
 *  chan        MIDI channel
 *  key     key
 *  velocity    force
 *
 *  Start synthesizer to play pressed key
 *
 *****************************************************************************/

void    alSeqpKeyOn(ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity)
{
    ALChanState  * chanstate;
    ALInstrument * ins;
    Int16          priority;
    ALVoiceState * vs;
    ALVoiceState * vsold;
    ALSound      * snd;
    Int16          ok;

    chanstate = &seqp->chanState[chan];                 // channel state
    if ((ins = chanstate->instrument) == NULL) return;      // channel's instrument
    priority = ins->priority + chanstate->priority;         // sound's priority
    /*
     *  check sound for this keys and test if this force is enough to play
     */
    if (chanstate->prog != 127) key += seqp->relTone;
    if ((snd = alSeqpGetSound(ins, key, velocity)) == NULL) return; // sound was not found
    /*
     *  Get virtual channel. But before lets check if there is already this tone
     *  In case if it is exist then start Release
     */
    vs = seqp->vAllocList.next;
    while ((vs = alSeqpFindVoiceChlKey(vs, chan, key)) != NULL)
    {
        alSeqpVoiceOff(seqp, vs);
        vs = vs->voice.node.next;
    }
    if ((vs = alSeqpGetFreeVoice(seqp)) == NULL)  return;   // free VoiceState was not found
    ok = alSynAllocVoice(seqp->drvr, &vs->voice, priority); // use polyphony
    /*
     *  voice has poly-voice
     */
    if (ok == 1)
    {
        vs->instrument = ins;                       // set instrument
        vs->sound = snd;                            // set sound
        vs->channel = chan;                         // set MIDI channel
        vs->key = key;                              // set key number
        vs->velocity = velocity;                    // set force
        if (snd->wavetable->rate == MIXFREQ)
            vs->voice.unityPitch = 0x8000;
        else
            vs->voice.unityPitch = div_s(negate(snd->wavetable->rate), MIXFREQ);
        alSeqpStartEnvelope(seqp, vs);
        alSeqpStartOsc(seqp, vs);
        alSeqpSetPitch(seqp, vs);
        alSynStartVoice(seqp->drvr, &vs->voice, snd->wavetable); // set waveform
    }
    else alSeqpFreeVoice(seqp, vs);                 // release virtual voice
}

/*****************************************************************************
 *
 *  void    alSeqpKeyOff( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity )
 *
 *  seqp        the sequence player
 *  chan        MIDI channel
 *  key     key
 *  velocity    force of press/release
 *
 *  Stop key in channel
 *
 *****************************************************************************/

void    alSeqpVoiceOff(ALSeqPlayer * seqp, ALVoiceState * vs)
{
    vs->envPhase = AL_PHASE_RELEASE;
    alSeqpVolMix(seqp, vs);
}

void    alSeqpKeyOff(ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity)
{
    ALVoiceState * vs;
    if (seqp->chanState[chan].prog != 127) key += seqp->relTone;

    vs = seqp->vAllocList.next;
    while ((vs = alSeqpFindVoiceChlKey(vs, chan, key)) != NULL)
    {
        if (seqp->chanState[chan].sustain == 0)
            alSeqpVoiceOff(seqp, vs);
        else
            vs->envPhase = AL_PHASE_SUSTAIN;

        vs = vs->voice.node.next;
    }
}

/*****************************************************************************
 *
 *  ALSound * alSeqpGetSound( ALInstrument ins, u8 key )
 *
 *  seqp        the sequence player
 *  key     key
 *
 *  Return structure ALSound, by given key number
 *
 *****************************************************************************/

ALSound * alSeqpGetSound(ALInstrument * ins, u8 key, u8 vel)
{
    int       n, max;
    ALSound * snd;
    ALKeyMap* kmap;

    max = ins->soundCount;
    for (n = 0; n < max; n++)
    {
        snd = ins->soundArray[n];
        kmap = snd->keyMap;
        if ((kmap->keyMin <= key) && (kmap->keyMax >= key) &&
            (kmap->velocityMin <= vel) && (kmap->velocityMax >= vel)) return snd;
    }
    return NULL;
}

/*****************************************************************************
 *
 *  void alSeqpEnvelope(  ALEnvState * state, ALEnvelopeTable * env, bool sustane )
 *
 *  vs          pointer to virtual voice
 *  state       state of envelope
 *  env         pointer to envelope's table
 *  sustane     state SUSTANE if TRUE
 *
 *  Switch to next envelope phase. Modify volume and pan.
 *  returns true state was switched, and false if was not switched
 *
 *****************************************************************************/

ALMicroTime alSeqpEnvelope(ALVoiceState * vs, ALEnvState * state, ALEnvelopeTable * env, bool sustain);
ALMicroTime alSeqpEnvelope(ALVoiceState * vs, ALEnvState * state, ALEnvelopeTable * env, bool sustain)
{
    bool step = true;

    if (sustain && ((env->type & AL_ENV_SUSTANE) != 0))
    {
        //  while hold key we SUSTANE
        if (state->Phase >= env->sustaneEnd)
        {
            if (env->sustaneStart == env->sustaneEnd) step = false;
            else state->Phase = env->sustaneStart;
        }
    }
    else if ((env->type & AL_ENV_LOOP) != 0)
    {
        //  now in SUSTANE but there is LOOP
        if (state->Phase >= env->loopEnd)
        {
            if (env->loopStart == env->loopEnd)
            {
                step = false;
                vs->envPhase = AL_PHASE_RELEASE;
            }
            else state->Phase = env->loopStart;
        }
    }
    else
    {
        //  envelope without SUSTANE or LOOP
        if (state->Phase >= (env->pointCount - 1))
        {
            step = false;
            vs->envPhase = AL_PHASE_RELEASE;
        }
    }

    if (step)
    {
        state->EndTime = (ALMicroTime)(UInt16)env->pointArray[state->Phase++].time * 1000;
        if (state->EndTime == 0) state->EndTime = FRAME_TIME_US - 1;
        state->Val = env->pointArray[state->Phase].val;
    }
    else state->EndTime = 0;

    return state->EndTime;
}

/*****************************************************************************
 *
 *  void    alSeqpEnvTimers( ALSeqPlayer * seqp, ALMicroTime delta );
 *
 *  seqp    the player
 *
 *  Decrease counter of envelopes and fade-outs.
 *
 *****************************************************************************/

void    alSeqpEnvTimers(ALSeqPlayer * seqp, ALMicroTime delta)
{
    ALVoiceState * vs = seqp->vAllocList.next;
    ALVoiceState * vsnext;

    while (vs != NULL)
    {
        vsnext = vs->voice.node.next;
        alMicroTimeSub(&vs->envVolState.EndTime, delta);
        alMicroTimeSub(&vs->envPanState.EndTime, delta);

        if ((vs->voice.state & AL_SF_ACTIVE) == 0)
        {
            alSeqpFlushEventsOfVoice(seqp, vs);
            alSeqpFreeVoice(seqp, vs);
        }
        else if (vs->envPhase == AL_PHASE_RELEASE)
        {
            alMicroTimeSub(&vs->fadeTime, delta);
            if ((vs->voice.state & (AL_SF_TARGET | AL_SF_ZERO)) == (AL_SF_TARGET | AL_SF_ZERO))
            {
                alSeqpFlushEventsOfVoice(seqp, vs);
                alSeqpFreeVoice(seqp, vs);
            }
        }

        vs = vsnext;
    }
}

/*****************************************************************************
 *
 *  void alSeqpEnvPhase( ALSeqPlayer * seqp, ALVoiceState * vs )
 *
 *  seqp        the player
 *  vs      pointer to voice state
 *
 *  Set envelope parameters of voice and switch to next phase.
 *  Called by event, and send event for next envelope point
 *
 *****************************************************************************/

ALMicroTime alSeqpEnvVolEvent(ALSeqPlayer * seqp, ALEvent * event)
{
    bool            sustain;
    ALMicroTime     time;
    ALVoiceState *  vs = event->msg.note.voice;

    sustain = ((seqp->chanState[vs->channel].sustain != 0) || (vs->envPhase != AL_PHASE_RELEASE));
    time = alSeqpEnvelope(vs, &vs->envVolState, vs->sound->envelope, sustain);
    alSeqpVolMix(seqp, vs);
    if (time != 0)
    {
        alEvtqPostEvent(&seqp->evtq, event, time);
    }
    return time;
}

ALMicroTime alSeqpEnvPanEvent(ALSeqPlayer * seqp, ALEvent * event)
{
    bool            sustain;
    ALMicroTime     time;
    ALVoiceState *  vs = event->msg.note.voice;

    sustain = ((seqp->chanState[vs->channel].sustain != 0) || (vs->envPhase != AL_PHASE_RELEASE));
    time = alSeqpEnvelope(vs, &vs->envPanState, vs->sound->penvelope, sustain);
    if (time != 0)
    {
        alSeqpPanMix(seqp, vs);
        alEvtqPostEvent(&seqp->evtq, event, time);
    }
    return time;
}

/*****************************************************************************
 *
 *  void    alSeqpStartEnvelope( ALSeqPlayer * seqp, ALVoiceState * vs )
 *
 *  seqp        the player
 *  vs      pointer to voice state
 *
 *  Start envelope
 *
 *****************************************************************************/

void    alSeqpStartEnvelope(ALSeqPlayer * seqp, ALVoiceState * vs)
{
    ALEvent event;
    ALMicroTime time;

    vs->fadeVol = 0x7FFF;
    vs->envPhase = AL_PHASE_NOTEON;

    if ((vs->sound->flags & AL_ENV_VOL) != 0)
    {
        vs->fadeTime = alMiliToMicro(vs->sound->envelope->pointArray[vs->sound->envelope->pointCount - 1].time);
        event.type = AL_SEQP_EVOL_EVT;
        event.msg.note.voice = vs;
        vs->envVolState.Phase = 0;
        vs->envVolState.Val = vs->sound->envelope->pointArray[0].val;
        vs->envVolState.EndTime = 0;
        alSeqpVolMix(seqp, vs);
        time = alSeqpEnvVolEvent(seqp, &event);
    }
    else
    {
        vs->fadeTime = alMiliToMicro(vs->sound->sampleFadeout);
        vs->envVolState.EndTime = 0;
        vs->envVolState.Val = 0x7f;
        alSeqpVolMix(seqp, vs);
    }

    if ((vs->sound->flags & AL_ENV_PAN) != 0)
    {
        event.type = AL_SEQP_EPAN_EVT;
        event.msg.note.voice = vs;
        vs->envPanState.Phase = 0;
        vs->envPanState.Val = vs->sound->penvelope->pointArray[0].val;
        vs->envPanState.EndTime = 0;
        alSeqpPanMix(seqp, vs);
        time = alSeqpEnvPanEvent(seqp, &event);
    }
    else
    {
        vs->envPanState.EndTime = 0;
        vs->envPanState.Val = 0x40;
        alSeqpPanMix(seqp, vs);
    }
}

/*****************************************************************************
 *
 *  void alSeqpVolMix( ALSeqPlayer * seqp, ALVoiceState *vs )
 *
 *  seqp        the player
 *  vs      pointer to voice state
 *
 *  Set final, main volume
 *
 *  vs->velocity                        press force
 *  libvol                          sound and instrument volume
 *  seqp->vol                           sequencer volume
 *  seqp->chanState[vs->channel].vol    MIDI channel volume
 *
 *****************************************************************************/

void alSeqpVolMix(ALSeqPlayer * seqp, ALVoiceState *vs)
{
    UInt16      cvol, lvol, evol;
    ALMicroTime t;

    cvol = mult(INT2FRAC(vs->velocity), INT2FRAC(seqp->chanState[vs->channel].vol));
    lvol = mult(vs->sound->sampleVolume, vs->instrument->volume);
    cvol = mult(cvol, lvol);
    cvol = mult(cvol, seqp->vol);
    t = vs->envVolState.EndTime;
    if (vs->envPhase == AL_PHASE_RELEASE)   //  "fadeout"
    {
        if ((vs->fadeTime <= vs->envVolState.EndTime) || (vs->envVolState.EndTime == 0))
        {
            vs->fadeVol = 0;
            t = vs->fadeTime;
        }
        else
        {
            vs->fadeVol = ((((Int32)vs->fadeVol << 16) / vs->fadeTime)*vs->envVolState.EndTime) >> 16;
        }
    }
    evol = mult(INT2FRAC(vs->envVolState.Val), vs->fadeVol);
    alSynSetGain(seqp->drvr, &vs->voice, cvol);
    alSynSetVol(seqp->drvr, &vs->voice, evol, t);
}

//#define MIXPAN(x,y) ((x+y)>>1)
#define MIXPAN(x,y) (x+y)-0x40
void alSeqpPanMix(ALSeqPlayer * seqp, ALVoiceState *vs)
{
    ALPan cpan, lpan, epan;

    lpan = MIXPAN(vs->sound->samplePan, vs->instrument->pan);
    cpan = MIXPAN(seqp->chanState[vs->channel].pan, lpan);
    epan = (vs->envPanState.Val - PAN_CENTER) + cpan;
    if (epan > 0x7f)    epan = 0x7f;
    else if (epan < 0) epan = 0;
    alSynSetPan(seqp->drvr, &vs->voice, epan, vs->envPanState.EndTime);
}

/*****************************************************************************
 *
 *  ALVoiceState * alSeqpFindVoiceChl( ALVoiceState * vs, UWord16 chan )
 *
 *  vs      pointer to voice state
 *  chan        MIDI channel
 *
 *  Find voice by MIDI channel number
 *
 *******************************************************************************
 *
 *  ALVoiceState * alSeqpFindVoiceChlKey( ALVoiceState * vs, UWord16 chan, u8 key )
 *
 *  vs      pointer to voice state
 *  chan        MIDI channel
 *
 *  Find voice by MIDI channel and tone (NOTE)
 *
 *****************************************************************************/

ALVoiceState * alSeqpFindVoiceChl(ALVoiceState * vs, UWord16 chan)
{
    while (vs != NULL)
    {
        if (vs->channel == chan) return vs;
        vs = vs->voice.node.next;
    }
    return vs;
}

ALVoiceState * alSeqpFindVoiceChlKey(ALVoiceState * vs, UWord16 chan, u8 key)
{
    while (vs != NULL)
    {
        if ((vs->channel == chan) && (vs->key == key) && (vs->envPhase != AL_PHASE_RELEASE)) return vs;
        vs = vs->voice.node.next;
    }
    return vs;
}

/*****************************************************************************
 *
 *  void alSeqpSetPitch( ALSeqPlayer * seqp, ALVoiceState * vs)
 *
 *  seqp        the player
 *  vs      pointer to voice state
 *
 *  Set  channel's pitch.
 *
 *******************************************************************************
 *
 *  void alSeqpChangePitch( ALSeqPlayer * seqp, UInt16 channel)
 *
 *  seqp        the player
 *  channel MIDI channel
 *
 *  Find voices, by channel, and set it's Pitch.
 *
 *****************************************************************************/

void alSeqpSetPitch(ALSeqPlayer * seqp, ALVoiceState * vs)
{
    ALKeyMap * kmap = vs->sound->keyMap;
    Int16      key = vs->key;
    Int32      pitch;
    float      f;

    pitch = kmap->detune + vs->vibrato + seqp->chanState[vs->channel].pitchBend;

    key += (BASE_NOTE - kmap->keyBase);
    pitch = alGetLinearRate(key, pitch);
    vs->pitch = pitch;
    alSynSetPitch(seqp->drvr, &vs->voice, pitch);
}

void alSeqpChangePitch(ALSeqPlayer * seqp, UInt16 channel)
{
    ALVoiceState * vs = seqp->vAllocList.next;

    while (true)
    {
        vs = alSeqpFindVoiceChl(vs, channel);
        if (vs == NULL) return;
        alSeqpSetPitch(seqp, vs);
        vs = vs->voice.node.next;
    }
}

/*****************************************************************************
 *
 *  void    alSeqpStartOsc( ALSeqPlayer * seqp, ALVoiceState * vs )
 *
 *  seqp        the player
 *  vs      pointer to voice state
 *
 *  Start OSC and put to the events queue.
 *
 *******************************************************************************
 *
 *  void    alSeqpVibOscEvent( ALSeqPlayer * seqp, ALEvent * event  )
 *
 *  seqp        the player
 *  event   event message
 *
 *  Event OSC for vibrato will update the variable vibrato and then change pitch
 *
 *****************************************************************************/

void    alSeqpStartOsc(ALSeqPlayer * seqp, ALVoiceState * vs)
{
    ALMicroTime     time;
    ALEvent         event;
    ALInstrument *  ins = vs->instrument;

    vs->flags = NO_OSC;
    vs->vibrato = 0;
    if (ins->vibType == 0)  return;
    time = seqp->initOsc(&vs->VibOscState, &vs->vibrato, ins->vibType,
        ins->vibRate, ins->vibDepth, ins->vibDelay);

    vs->flags |= VIBRATO_OSC;
    if (seqp->drvr->fcallTime > time)
    {
        alEvtqPostEvent(&seqp->fevtq, &seqp->fnextEvent, seqp->drvr->fcallTime);
        seqp->drvr->fcallTime = time;
        seqp->fnextEvent.type = AL_VIB_OSC_EVT;
        seqp->fnextEvent.msg.osc.vs = vs;
    }
    else if (seqp->drvr->fcallTime == 0)
    {
        seqp->drvr->fcallTime = time;
        seqp->fnextEvent.type = AL_VIB_OSC_EVT;
        seqp->fnextEvent.msg.osc.vs = vs;
    }
    else
    {
        if (seqp->drvr->fcallTime == time) time = 0;
        event.type = AL_VIB_OSC_EVT;
        event.msg.osc.vs = vs;
        alEvtqPostEvent(&seqp->fevtq, &event, time);
    }
}

ALMicroTime alSeqpVibOscEvent(ALSeqPlayer * seqp, ALEvent * event)
{
    ALMicroTime time;
    ALVoiceState * vs = event->msg.osc.vs;
    if ((vs->voice.state & AL_SF_ACTIVE) != 0)
    {
        time = seqp->updateOsc(vs->VibOscState, &vs->vibrato);
        alSeqpSetPitch(seqp, vs);
        if (time == 0) return;
        alEvtqPostEvent(&seqp->fevtq, event, time);
        return time;
    }
    return 0;
}

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
#include "mfr16.h"
#include "assert.h"

/*****************************************************************************
 *
 *  Word32  alSeqGetDeltaTime(UWord32 * addr)
 *
 *  Return DELTA TIME and shift pointer
 *
 *****************************************************************************/

Word32  alSeqGetDeltaTime(UWord32 * addr)
{
    UWord32 rv;
    UWord16 b;

    if(((rv=alSeqGet8( addr ))&0x80)!=0)
    {
        rv&=0x7F;
        do
        {
            rv=(rv<<7)+((b=alSeqGet8( addr ))&0x7F);
        } while((b&0x80) != 0);
    }
    return rv;
}

/*****************************************************************************
 *
 *     alSeqNew - initialize an Ultra 64 MIDI sequence structure
 *
 * SYNOPSIS
 *
 *     #include <sound.h>
 *
 *     void alSeqNew(ALSeq *seq, u8 *ptr, s32 len);
 *
 * PARAMETERS
 *
 *     seq       pointer to the ALSeq structure you wish to initialize.
 *     ptr       pointer to the MIDI data.
 *     len       length of the MIDI data in bytes.
 *
 * DESCRIPTION
 *
 *     In order to play a MIDI sequence with the Sequence Player, you must first
 *     initialize the ALSeq runtime data structure with a pointer to the MIDI
 *     sequence data ptr and the length of the data len.
 *     Note that the MIDI sequence must be a Type 0 Standard MIDI file as
 *     specified by the MIDI Manufacturer's Association. You can use the midicvt
 *     tool to convert from a Type 1 sequence to Type 0 sequence.
 *
 *****************************************************************************/

void    alSeqNew(ALSeq *seq, Ptr32 ptr, s32 len)
{
    UWord32 chunksize;
    UWord32 addr = ptr;
    UWord16 temp;

    seq->base           = ptr;
    addr+=4;                                    // 'MThd'
    chunksize           = alSeqGet32( &addr );  // size of chunk
    addr+=4;                                    // MIDI type
    seq->division       = alSeqGet16( &addr );  // Ticks in quoter
    addr+=(chunksize - (6 - 4));                //
    seq->len            = alSeqGet32( &addr );  // Track size
    seq->trackStart     = addr;                 // Firs message
    seq->curPtr         = seq->trackStart;      // Current message
    seq->lastTicks      = 0;                    // MIDI ticks for last messahe
//  seq->qnpt           = 0;            // ???  // quoter notes / tick (1/division)
    seq->lastStatus     = 0;                    // Last STATUS
}

/*****************************************************************************
 *
 *     void alSeqNextEvent(ALSeq *seq, ALEvent *event);
 *
 * PARAMETERS
 *     seq       pointer to the sequence to get the event from.
 *     event     pointer to the ALEvent structure to return the event in.
 *
 * DESCRIPTION
 *     alSeqNextEvent returns the next MIDI event in the sequence. Repeatedly
 *     calling this function will step through the sequence.
 *
 *     Note: If you are using the Sequence Player, you will not need to call
 *     this function. The Sequence Player will do it for you.
 *
 *****************************************************************************/

void    alSeqNextEvent(ALSeq *seq, ALEvent *event)
{
    UInt16    msg;
    UInt16    tmp;
    UWord32 * addr  = &seq->curPtr;
    UWord32   delta = 0;

    event->msg.midi.ticks = 0;

    do
    {
        delta += alSeqGetDeltaTime(&seq->curPtr);

        tmp = alSeqGet8( addr );

        if(tmp>0x7f)
        {   // it is STATUS
            event->msg.midi.status = tmp;
            seq->lastStatus        = tmp;
            event->msg.midi.byte1  = alSeqGet8( addr );
        }
        else
        {   // actual previous STATUS
            event->msg.midi.status = seq->lastStatus;
            event->msg.midi.byte1  = tmp;
        }

        msg = event->msg.midi.status & AL_MIDI_StatusMask;

        switch(msg)
        {
            case AL_MIDI_ProgramChange:
            case AL_MIDI_ChannelPressure:
                event->type = AL_SEQ_MIDI_EVT;
                break;
            case AL_MIDI_SysEx:
                msg = event->msg.midi.status;
                switch(msg)
                {
                    case AL_MIDI_Meta:
                        tmp = event->msg.midi.byte1;
                        event->msg.tempo.len  = alSeqGet8( addr );
                        switch(tmp)
                        {
                        case AL_MIDI_META_TEMPO:
                            event->type = AL_TEMPO_EVT;
                            event->msg.tempo.byte1 = alSeqGet8( addr );
                            event->msg.tempo.byte2 = alSeqGet8( addr );
                            event->msg.tempo.byte3 = alSeqGet8( addr );
                            break;
                        case AL_MIDI_META_EOT:
                            event->type = AL_SEQ_END_EVT;
                            break;
                        default:
                            event->type = AL_SEQ_REF_EVT;
                            (*addr)+=event->msg.tempo.len;
                        }
                        break;
                    default:
                        event->type = AL_SEQ_REF_EVT;
                        (*addr)+=event->msg.midi.byte1;
                        break;
                }
                break;
            default:
                //case AL_MIDI_NoteOff:
                //case AL_MIDI_NoteOn:
                //case AL_MIDI_PolyKeyPressure:
                //case AL_MIDI_ControlChange:
                //case AL_MIDI_PitchBendChange:
                event->type = AL_SEQ_MIDI_EVT;
                event->msg.midi.byte2 = alSeqGet8( addr );
                break;
        }
    }while(event->type == AL_SEQ_REF_EVT);

        event->msg.midi.ticks  = delta;
        seq->lastTicks        += delta;
}

/*****************************************************************************
 *
 *     s32 alSeqGetTicks(ALSeq *seq);
 *
 * PARAMETERS
 *     seq       pointer to the sequence.
 *
 * DESCRIPTION
 *     alSeqGetTicks returns the MIDI clock tick count of the last MIDI event
 *     read from the sequence using alSeqNextEvent().
 *
 *****************************************************************************/

s32     alSeqGetTicks(ALSeq *seq)
{
    return seq->lastTicks;
}

/*****************************************************************************
 *
 *  float alSeqTicksToSec(ALSeq *seq, s32 ticks, u32 tempo);
 *
 * PARAMETERS
 *     seq       pointer to the ALSeq structure you wish to operate on.
 *     ticks     number of MIDI clock ticks.
 *     tempo     tempo in microsends per tick.
 *
 * DESCRIPTION
 *     MIDI sequences represent time in clock ticks relative to some tempo
 *     (speed).  The alSeqTicksToSec call converts these clock ticks to seconds.
 *     It does not take into account the tempo changes listed in the sequence.
 *
 *****************************************************************************/

f32     alSeqTicksToSec(ALSeq *seq, s32 ticks, u32 tempo)
{
}

u32     alSeqSecToTicks(ALSeq *seq, f32 sec, u32 tempo)
{
}

/*****************************************************************************
 *
 *     void    alSeqNewMarker(ALSeq *seq, ALSeqMarker *m, u32 ticks)
 *
 * PARAMETERS
 *     seq       pointer to the ALSeq structure to operate on.
 *     m         pointer to the ALSeqMarker to initialize.
 *     ticks     the sequence location, in MIDI clock ticks, to be represented
 *               by the marker.
 *
 * DESCRIPTION
 *     alSeqNewMarker initializes a sequence marker at the location secified in
 *     ticks. The sequence marker contains sequence state information required
 *     to locate and play the sequence from that point.
 *
 *****************************************************************************/

void    alSeqNewMarker(ALSeq *seq, ALSeqMarker *m, u32 ticks)
{
    Ptr32   taddr = seq->trackStart;
    UInt32  loc = 0;
    ALEvent event;
    ALSeq   tseq;

    tseq.lastTicks      = 0;
    tseq.lastStatus     = 0;
    tseq.curPtr         = seq->curPtr;

    while(tseq.lastTicks<ticks)
    {
        alSeqNextEvent(&tseq, &event);
    }
    alSeqGetLoc( &seq, m );
}

/*****************************************************************************
 *
 *     void    alSeqSetLoc(ALSeq *seq, ALSeqMarker *marker)
 *
 * PARAMETERS
 *     seq       pointer to the ALSeq structure to operate on.
 *     marker    pointer to the ALSeqMarker to initialize.
 *
 * DESCRIPTION
 *     alSeqSetLoc sets the sequence player location to be that specified in the
 *     marker. The marker should have been previously initialized with
 *     alSeqNewMarker() or alSeqGetLoc().
 *
 * NOTE
 *     Changing the location of the sequence does not revert the channel
 *     parameters (pan, vol, priority, FXMix) to the values that would exist if
 *     the sequence was played from the begining to the new location. Channel
 *     parameters remain what they were prior to the call of alSeqSetLoc. This
 *     may require the sequence to imbed controllers for updating the channel
 *     parameters, or for the application to make calls to set these parameters.
 *
 *****************************************************************************/

void    alSeqSetLoc(ALSeq *seq, ALSeqMarker *marker)
{
    seq->curPtr     = marker->curPtr;
    seq->lastTicks  = marker->lastTicks;
    seq->lastStatus = marker->lastStatus;
}

/*****************************************************************************
 *
 *    void alSeqGetLoc(ALSeq *seq, ALSeqMarker *marker);
 *
 * PARAMETERS
 *
 *     seq       pointer to the sequence.
 *     marker    marker to be filled in with the current sequence location.
 *
 * DESCRIPTION
 *     alSeqGetLoc initializes marker with the current sequence location. This
 *     can be used by alSeqSetLoc to later position the sequence playback at
 *     this point.
 *
 *****************************************************************************/

void    alSeqGetLoc(ALSeq *seq, ALSeqMarker *marker)
{
    Ptr32 taddr        = seq->curPtr;
    marker->curPtr     = taddr;
    marker->lastTicks  = seq->lastTicks;
    marker->curTicks   = alSeqGetDeltaTime( &taddr ) + seq->lastTicks;
    marker->lastStatus = seq->lastStatus;
}

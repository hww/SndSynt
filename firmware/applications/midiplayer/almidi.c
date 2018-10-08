/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "assert.h"
#include "io.h"
#include "fcntl.h"
#include "mem.h"
#include "bsp.h"
#include "sci.h"
#include "types.h"
#include "audiolib.h"
#include "terminal.h"

#define SUSEX_SKIP  10  // Skip this amount of messages for single LED flash

static bool     bUartIsOpened = false;
static int      midiUart;
static UInt16   msgbuf[3];
static UInt16   msgidx;
static Int16    susexCntr;

int     midiGetBytes(UInt16 need);

/*****************************************************************************
 *
 *  void    midiOpen( void )
 *
 * PARAMETERS
 *
 * DESCRIPTION
 *     Initialize MIDI interface
 *
 *****************************************************************************/

void    midiOpen(void)
{
    sci_sConfig       SciConfig;

    SciConfig.SciCntl = SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_NONE;
    SciConfig.SciHiBit = SCI_HIBIT_0;
    SciConfig.BaudRate = SCI_BAUD_USER1;

    if (bUartIsOpened == false)
    {
        /* open SCI 0 in Blocking mode with 8 bit word length without parity */
        /* and on 9600 baud rate.  */
        midiUart = open(BSP_DEVICE_NAME_SERIAL_0, O_RDONLY | O_NONBLOCK, &(SciConfig));

        if (midiUart == -1)
        {
            assert(!" Open /sci0 device failed.");
        }

        ioctl(midiUart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);

        bUartIsOpened = true;
    }
    msgidx = 0;
    susexCntr = 0;
}

/*****************************************************************************
 *
 *  void    midiClose( void )
 *
 * PARAMETERS
 *
 * DESCRIPTION
 *     Close MIDI interface
 *
 *****************************************************************************/

void    midiClose(void)
{
    bUartIsOpened = false;
    close(midiUart);
}

/*****************************************************************************
 *
 *  int     midiGetBytes( int numbytes )
 *
 * PARAMETERS
 *
 *  numbytes    number of bytes to read
 *  return      1  successful reading
 *              0  failed
 *
 * DESCRIPTION
 *     Read requested bytes from MIDI
 *
 *****************************************************************************/

int     midiGetBytes(UInt16 need)
{
    if ((need -= msgidx) > 0)
    {
        if (need > ioctl(midiUart, SCI_GET_READ_SIZE, NULL)) return 0;
        read(midiUart, &msgbuf[msgidx], need);
        msgidx += need;
    }
    return 1;
}

/*****************************************************************************
 *
 *  int     midiGetMsg( ALEvent * evt )
 *
 * PARAMETERS
 *
 *  numbytes    number of bytes to read
 *  return      1  successful reading
 *              0  failed
 *
 * DESCRIPTION
 *     Read requested bytes from MIDI
 *
 *****************************************************************************/

int     midiGetMsg(ALEvent * evt)
{
    UInt16  tmp;
    UInt16  cmd;
    UInt16  need;
    int     ReadCount;

    if (bUartIsOpened == false) return 0;                   // device was not open

    do
    {
        ReadCount = ioctl(midiUart, SCI_GET_READ_SIZE, NULL);
        if (ReadCount == 0)  return 0;

        if (msgidx == 0)                                    // no STATUS in message
        {
            do
            {
                msgidx = 0;
                if (ReadCount == 0) return 0;               // no records in buffer
                read(midiUart, &tmp, 1);
                if (tmp < 0x80) msgbuf[++msgidx] = tmp;     // is RuningStatus
                else msgbuf[msgidx] = tmp;
                ReadCount--;
            } while (msgbuf[0] < 0x80);                     // until good STATUS
            msgidx++;
        }

        // 100% STATUS

        cmd = msgbuf[0];
        if (cmd < 0xF0) cmd &= AL_MIDI_StatusMask;          // STATUS < 0xF0

        switch (cmd)
        {
        case AL_MIDI_NoteOff:
        case AL_MIDI_NoteOn:
        case AL_MIDI_PolyKeyPressure:
        case AL_MIDI_ControlChange:
        case AL_MIDI_PitchBendChange:                       // 3x bytes message
            if (midiGetBytes(3) == 0) return 0;
            break;

        case AL_MIDI_ProgramChange:
        case AL_MIDI_ChannelPressure:                       // 2x bytes message
            if (midiGetBytes(2) == 0) return 0;
            break;

        case AL_MIDI_SysEx:                                 // System Exclusive
            msgidx = 0;
            break;

        case AL_MIDI_SongPositionPointer:                   // 3x bytes message
            if (midiGetBytes(3) == 0) return 0;
            break;

        case AL_MIDI_SongSelect:
            if (midiGetBytes(2) == 0) return 0;
            break;

        case AL_MIDI_ActiveSensing:                         // Check MIDI connection
            if ((susexCntr++) >= SUSEX_SKIP)
            {
                susexCntr = 0;
                LEDFLASH(LED_M4);
            }
        case AL_MIDI_SystemReset:                           // System reset
        case AL_MIDI_EOX:                                   // End of System Exclusive
            msgidx = 0;
            break;

        //case AL_MIDI_Start:                               // Single byte messages
        //case AL_MIDI_Continue:
        //case AL_MIDI_Stop:
        default:
            break;
        }
    } while (msgidx == 0);

    memcpy(&evt->msg.midi.status, msgbuf, msgidx);
    msgidx = 0;
    return 1;
}
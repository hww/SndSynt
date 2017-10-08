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

#define SUSEX_SKIP	10	// Сколько сообщений проверки связий пропустить
						// для одного FLASH светодиода

static bool     bUartIsOpened = false;
static int		midiUart;
static UInt16	msgbuf[3];
static UInt16	msgidx;	
static Int16	susexCntr;

int		midiGetBytes( UInt16 need );

/******************************************************************************
*
*	void	midiOpen( void )
*
* PARAMETERS
*
* DESCRIPTION
*     Инициализирует МИДИ интерфейс на приём сообщений
*     
*******************************************************************************/

void	midiOpen( void )
{
sci_sConfig       SciConfig;
	
		SciConfig.SciCntl    =  SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_NONE;
   	    SciConfig.SciHiBit   =  SCI_HIBIT_0;
   	    SciConfig.BaudRate   =  SCI_BAUD_USER1;

		if(bUartIsOpened == false)
		{
			/* open SCI 0 in Blocking mode with 8 bit word length without parity */
			/* and on 9600 baud rate.  */ 
			midiUart = open(BSP_DEVICE_NAME_SERIAL_0, O_RDONLY | O_NONBLOCK, &(SciConfig));
		
			if (midiUart  == -1)
			{
				assert(!" Open /sci0 device failed.");
			}

			ioctl(midiUart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);

			bUartIsOpened = true;
		}
		msgidx 	  = 0;
		susexCntr = 0;
}

/******************************************************************************
*
*	void 	midiClose( void )
*
* PARAMETERS
*
* DESCRIPTION
*     Закрывает МИДИ интерфейс на приём сообщений
*     
*******************************************************************************/

void 	midiClose( void )
{
     bUartIsOpened = false;
	 close(midiUart);
}


/******************************************************************************
*
*	int		midiGetBytes( int numbytes )
*
* PARAMETERS
*
*	numbytes	сколько байт требуется прочитать
*	return		1 в случае успешного выполнения
*		 		0 в случает не успешного выполнения
*
* DESCRIPTION
*     Прочитывает запрашиваемое число байт из интерфейса
*     
*******************************************************************************/

int		midiGetBytes( UInt16 need )
{
	if((need -= msgidx) >0)
	{
		if(need > ioctl(midiUart,SCI_GET_READ_SIZE, NULL)) return 0;
		read (midiUart, &msgbuf[msgidx], need);		// прочитали необходимое число байт
		msgidx+=need;
	}
	return 1;
}

/******************************************************************************
*
*	int		midiGetMsg( ALEvent * evt )
*
* PARAMETERS
*
*	numbytes	сколько байт требуется прочитать
*	return		1 в случае успешного выполнения
*		 		0 в случает не успешного выполнения
*
* DESCRIPTION
*     Прочитывает запрашиваемое число байт из интерфейса
*     
*******************************************************************************/

int		midiGetMsg( ALEvent * evt )
{

UInt16  tmp;
UInt16	cmd;
UInt16	need;
int 	ReadCount;

	if(bUartIsOpened == false) return 0;					// устройство не было открыто

	do
	{
		ReadCount = ioctl(midiUart,SCI_GET_READ_SIZE, NULL);
		if(ReadCount == 0)  return 0;						// не принято нисколько байт

		if(msgidx == 0)										// если сообщение не имеет даже статуса
		{
			do
			{
				msgidx = 0;
				if(ReadCount==0) return 0;					// Если в буфере уже нетзаписей			
				read (midiUart, &tmp, 1);					// прочитали один байт
				if(tmp < 0x80) msgbuf[++msgidx] = tmp;		// если это RuningStatus
				else msgbuf[msgidx] = tmp;
				ReadCount--;			
			}while(msgbuf[0]<0x80);							// До тех пор пока не получим
															// нормальный STATUS 
			msgidx++;
		}

		// 100% есть STATUS в буфере
	
		cmd = msgbuf[0];
		if(cmd<0xF0) cmd &= AL_MIDI_StatusMask;				// обрежим только для STATUS < 0xF0

		switch(cmd)
		{
	    case AL_MIDI_NoteOff:
	    case AL_MIDI_NoteOn:
	    case AL_MIDI_PolyKeyPressure:
	    case AL_MIDI_ControlChange:
	    case AL_MIDI_PitchBendChange:						// 3х байтовое сообщение
			if(midiGetBytes(3)==0) return 0;				// прочитали один байт
			break;											// Приняли !

	    case AL_MIDI_ProgramChange:
	    case AL_MIDI_ChannelPressure:						// 2х байтовое сообщение
			if(midiGetBytes(2)==0) return 0;				// прочитали один байт
			break;											// Приняли !
			
    	case AL_MIDI_SysEx:				 					// System Exclusive
			msgidx=0;
			break;
    									 
    	case AL_MIDI_SongPositionPointer:					// 3 х байтовое 
			if(midiGetBytes(3)==0) return 0;				// прочитали один байт
    		break;
    	
    	case AL_MIDI_SongSelect:
			if(midiGetBytes(2)==0) return 0;				// прочитали один байт
			break;    	
    	
    	case AL_MIDI_ActiveSensing:			// Проверка соединения МИДИ
			if((susexCntr++) >= SUSEX_SKIP)
			{	susexCntr = 0;
				LEDFLASH(LED_M4);
    		}
    	case AL_MIDI_SystemReset:    		// Системный сброс
    	case AL_MIDI_EOX: 					// End of System Exclusive 
			msgidx=0;
			break;

    	//case AL_MIDI_Start:					// Однобайтовые сообщения 
    	//case AL_MIDI_Continue:
    	//case AL_MIDI_Stop:
    	default:
    		break;
		}
	}while(msgidx==0);

	memcpy( &evt->msg.midi.status, msgbuf, msgidx ); 
	msgidx = 0;
	return 1;
}
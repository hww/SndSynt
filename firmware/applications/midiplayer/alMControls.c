#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "mem.h"
#include "assert.h"
#include "mfr16.h"
#include "alMControls.h"
#include "alseqp.h"


UInt16	nrpnNum;
UInt16	rpnNum;
UInt16  insNum;
UInt16  sndNum;
UInt16  detune;

enum AL_NRPNS {
    AL_INS_NUM          		= 0x00,
    AL_INS_VOL		            = 0x01,
    AL_INS_PAN          		= 0x02,
    AL_INS_BEND_RANGE      		= 0x03,
    AL_INS_PRIORITY	       		= 0x04,
    AL_SND_NUM		    		= 0x05,
    AL_SND_VOL		    		= 0x06,
    AL_SND_PAN		    		= 0x07,
    AL_SND_FADE		    		= 0x08,
    AL_SND_KEY_MIN	    		= 0x09,
    AL_SND_KEY_MAX	    		= 0x0A,
    AL_SND_KAY_BASE	    		= 0x0B,
    AL_SND_VEL_MIN	    		= 0x0C,
    AL_SND_VEL_MAX	    		= 0x0D,
    AL_SND_DETUNE	    		= 0x0E,
    AL_SND_VIB_TYPE	    		= 0x0F,
    AL_SND_VIB_DELAY	   		= 0x10,
    AL_SND_VIB_RATE	    		= 0x11,
    AL_SND_VIB_DEPTH	   		= 0x12,
};

static void alContrDataEntryPointer( ALSeqPlayer * seqp, UInt16 chan, UInt16 data, UInt16 mask );
static void alDataEntry( UInt16 * ptr, UInt16 data, UInt16 mask );

#define MIDI_HI(x,v)	x = (x & 0x7f) + ((v & 0x7f) << 7)
#define MIDI_LO(x,v)	x = (x & (0x7f<<7)) + (v & 0x7f)

/******************************************************************************
*
*	void alSeqpControlChange( ALSeqPlayer * seqp, UWord16 chan, u8 contr, u8 val )
*
*	Event "ControlChange"
*
*******************************************************************************/

void	alSeqpControlChange( ALSeqPlayer * seqp, UWord16 chan, u8 contr, u8 val )
{
ALVoiceState * vs = seqp->vAllocList.next;;

	switch(contr)
	{
	    case AL_MIDI_VOLUME_CTRL:        		//0x07 volume of all sounds in channel
	    case AL_MIDI_EXPRESSION:          		//0x0B expression level
	       	alSeqpSetChlVol(seqp, chan, val); 
			while((vs = alSeqpFindVoiceChl( vs, chan )) != NULL)
			{	alSeqpVolMix( seqp, vs );
				vs = vs->voice.node.next;
	    	}
	    	break;
	    case AL_MIDI_PAN_CTRL:            		//0x0A pan of all sounds in channel
	    	alSeqpSetChlPan(seqp, chan, val); 
			while((vs = alSeqpFindVoiceChl( vs, chan )) != NULL)
			{	alSeqpPanMix( seqp, vs );
				vs = vs->voice.node.next;
	    	}
	    	break;
	    case AL_MIDI_PRIORITY_CTRL:       		//0x10 use general purpose controller for priority
	    	alSeqpSetChlPriority(seqp, chan, val); 
	    	break;
	/*  case AL_MIDI_FX_CTRL_0:           		//0x14 
	    case AL_MIDI_FX_CTRL_1:           		//0x15
	    case AL_MIDI_FX_CTRL_2:           		//0x16
	    case AL_MIDI_FX_CTRL_3:           		//0x17
	    case AL_MIDI_FX_CTRL_4:           		//0x18
	    case AL_MIDI_FX_CTRL_5:           		//0x19
	    case AL_MIDI_FX_CTRL_6:           		//0x1A
	    case AL_MIDI_FX_CTRL_7:           		//0x1B
	    case AL_MIDI_FX_CTRL_8:           		//0x1C
	    case AL_MIDI_FX_CTRL_9:           		//0x1D
			break;    
	*/  case AL_MIDI_SUSTAIN_CTRL:        		//0x40 keep sound of all released keys
	    	seqp->chanState[chan].sustain = val;
			while((vs = alSeqpFindVoiceChl( vs, chan )) != NULL)
			{	if(vs->envPhase == AL_PHASE_SUSTAIN) alSeqpVoiceOff( seqp, vs );
				vs = vs->voice.node.next;
			}
	    	break;
	    case AL_MIDI_FX1_CTRL:            		//0x5B FX value
	    	alSeqpSetChlFXMix(seqp, chan, val); 
	    	break;
	    case AL_MIDI_FX3_CTRL:            		//0x5D Chorus value
			break;
		case AL_MIDI_ALL_NOTES_OFF:
			while(vs != NULL)
			{	if(vs->envPhase != AL_PHASE_RELEASE) alSeqpVoiceOff( seqp, vs );
				vs = vs->voice.node.next;
			}
			break;
		case AL_MIDI_DATA_ENTRY_H:
			alContrDataEntryPointer( seqp, chan, val<<7, 0x7f );
			break;
		case AL_MIDI_DATA_ENTRY_L:
			alContrDataEntryPointer( seqp, chan, val, (0x7f<<7) );
			break;
		case AL_MIDI_NRPN_L:
			rpnNum = 0x3FFF;
			MIDI_LO(nrpnNum,val);
			break;
		case AL_MIDI_NRPN_H:
			rpnNum = 0x3FFF;
			MIDI_HI(nrpnNum,val);
			break;
		case AL_MIDI_RPN_L:
			nrpnNum = 0x3FFF;
			MIDI_LO(rpnNum,val);
			break;
		case AL_MIDI_RPN_H:
			nrpnNum = 0x3FFF;
			MIDI_HI(rpnNum,val);
			break;
	}
}

void alContrDataEntryPointer( ALSeqPlayer * seqp, UInt16 chan, UInt16 data, UInt16 mask )
{
ALInstrument * ins = NULL;
ALSound 	 * snd = NULL;
ALKeyMap	 * kmap = NULL;
UInt16		   data7f = data & 0x7f;

		if(nrpnNum == 0x3FFF) return;

		if(insNum < seqp->bank->instCount)
		{	ins = seqp->bank->instArray[insNum]; 
			if(sndNum < ins->soundCount)
			 	{	snd = ins->soundArray[sndNum]; 
					kmap = snd->keyMap;
				}
		}

		switch(nrpnNum)
		{
	    case AL_INS_NUM: 
	    	alDataEntry( &insNum, data7f, mask); 
	    	alSeqpSetChlProgram(seqp, chan, insNum);
	    	break;
	    case AL_INS_VOL: 
	    	if(mask != 0x7f)
	    		ins->volume =  INT2FRAC(data7f); 
	    	break;
	    case AL_INS_PAN:
	    	alDataEntry( &ins->pan, data7f, mask); 
	    	break;
	    case AL_INS_BEND_RANGE:
	    	alDataEntry( &ins->bendRange, data, mask); 
	    	alSeqpSetChlProgram(seqp, chan, insNum);
	    	break;
	    case AL_INS_PRIORITY:
	    	alDataEntry( &ins->priority, data7f, mask); 
	    	break;
	    case AL_SND_NUM: 
   	    	alDataEntry( &sndNum, data7f, mask); 
	    	detune = 0;
	    	break;
	    case AL_SND_VOL:
	    	if(mask != 0x7f)
	    		snd->sampleVolume =  INT2FRAC(data7f); 
	    	break;
	    case AL_SND_PAN:
	    	alDataEntry( &snd->samplePan, data7f, mask); 
	    	break;
	    case AL_SND_FADE:
	    	alDataEntry( &snd->sampleFadeout, data, mask); 
	    	break;
	    case AL_SND_VIB_TYPE:
	    	alDataEntry( &ins->vibType, data7f, mask); 
	    	break;
	    case AL_SND_VIB_DELAY:
	    	alDataEntry( &ins->vibDelay, data, mask); 
	    	break;
	    case AL_SND_VIB_RATE:
	    	alDataEntry( &ins->vibRate, data, mask); 
	    	break;
	    case AL_SND_VIB_DEPTH:
	    	alDataEntry( &ins->vibDepth, data, mask); 
	    	break;
	    case AL_SND_KEY_MIN:
	    	alDataEntry( &kmap->keyMin, data7f, mask); 
	    	break;
	    case AL_SND_KEY_MAX:
	    	alDataEntry( &kmap->keyMax, data7f, mask); 
	    	break;
	    case AL_SND_VEL_MIN:
	    	alDataEntry( &kmap->velocityMin, data7f, mask); 
	    	break;
	    case AL_SND_VEL_MAX:
	    	alDataEntry( &kmap->velocityMax, data7f, mask); 
	    	break;
	    case AL_SND_DETUNE:
	    	alDataEntry( &detune, data, mask); 
			kmap->detune = detune - 200;
	    	break;
	    case AL_SND_KAY_BASE:
	    	alDataEntry( &kmap->keyBase, data, mask); 
	    	break;
		}		
} 


void alDataEntry( UInt16 * ptr, UInt16 data, UInt16 mask )
{
	if(ptr == NULL) return;
	*ptr = (*ptr & mask) | data;
}

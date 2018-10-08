/*****************************************************************************
 * @project SndSynt
 * @info Sound synthesizer library and MIDI file player.
 * @platform DSP
 * @autor Valery P. (https://github.com/hww)
 *****************************************************************************/

#include "port.h"
#include "audiolib.h"
#include "stdio.h"
#include "sdram.h"
#include "mem.h" 
#include "terminal.h"
#include "fcodec.h"
#include "fcntl.h"
#include "fileio.h"
#include "controls.h"
#include "flashacc.h"

//#define PC_MODE
//#define SAVE_TO_FLASH

ALGlobals global;		// Synthesizer
ALSeqDir midiBank;		// Sequences
ALSeqDir bgBank;
ALSeqDir demoBank;
ALSeqDir gameLevel[5];

#define DRAM_FREE_ADDR      0
#define DRAM_CTL_ADDR       0x0020fff0u 
#define DRAM_CTL_SIZE_ADDR  0x0020fff2u 
#define DRAM_TBL_ADDR       0x0020fff4u 
#define DRAM_MIDI_ADDR      0x0020fff6u 
#define DRAM_BG_ADDR        0x0020fff8u 
#define DRAM_DEMO_ADDR      0x0020fffAu 


UInt16	get_cfg(void);
UInt16	get_cfg(void)
{
#ifdef PC_MODE
	int Fd;
	UInt32 fsize;
	UInt16 poly;

	Fd = open("\\\\PC\\D\\sbk\\config.bin", O_RDONLY);
	if (Fd == 0) return 16;

	ioctl(Fd, FILE_IO_GET_SIZE, fsize);

	if (fsize == 0) return 0;

	ioctl(Fd, FILE_IO_DATAFORMAT_RAW, NULL);
	read(Fd, &poly, 1);

	close(Fd);
	return poly;
#endif // PC_MODE
	return 21;
}

void main(void)
{
	UWord32			size, drama = DRAM_FREE_ADDR;
	UWord32			ctl_src;
	size_t			ctl_size;
	ALSeqPlayer 	seqp;				// Sequence player
	ALSeqpConfig 	seqcnf;				// Seq. player configure
	ALBankFile	*	bankfile;			// Configuration file
	ALSynConfig 	syncfg;				// Synthesizer configuration
	int				n;
	Int16			key;				// Number of button

#define SECTION_COUNT 4
#define SECTION_SIZE  2

	UInt16	params[SECTION_COUNT*SECTION_SIZE + 2] = {

	 4,   250 ms,
	 // output    coef  
	 240 ms,   0x1000,
	 200 ms,   0x500,
	 139 ms,   0x100,
	  78 ms,   0x100
	};

	// **************** Terminal *******************	
	terminalOpen();
	terminalSetAnimate(&stdAnimePP);

	// ************** Synthesizer ******************	
	syncfg.maxPVoices = get_cfg();
	syncfg.params = &params;
	alInit(&global, &syncfg);

	// *************** Sequencer *******************	
	createAllOsc();

	seqcnf.maxVoices = MAX_VOICES;
	seqcnf.maxEvents = MAX_EVENTS;
	seqcnf.maxChannels = MAX_CHANNELS;
	seqcnf.initOsc = &initOsc;
	seqcnf.updateOsc = &updateOsc;
	seqcnf.stopOsc = &stopOsc;

	alSeqpNew(&seqp, &seqcnf);

	// *********** Load sound bank *****************
#ifdef PC_MODE
	size = snd_load_tbl("\\\\PC\\D\\sbk\\tone.tbl", drama);
	sdram_write32(DRAM_TBL_ADDR, drama);
	drama += size;

	size = snd_load_bank("\\\\PC\\D\\sbk\\tone.ctl", &bankfile, drama);
	sdram_write32(DRAM_CTL_ADDR, drama);
	sdram_write32(DRAM_CTL_SIZE_ADDR, size);
	drama += size;
#else
	LoadFromFlash();
	ctl_src = sdram_read32(DRAM_CTL_ADDR);
	ctl_size = (size_t)sdram_read32(DRAM_CTL_SIZE_ADDR);
	bankfile = malloc(ctl_size);
	sdram_save(ctl_src, bankfile, ctl_size);
#endif // PC_MODE
	alBnkfNew(bankfile, 0);

	// ************ Set player bank ****************
	alSeqpSetBank(&seqp, bankfile->bankArray[0]);

	// ************ Load midi bank *****************
#ifdef PC_MODE
	size = alSeqFileLoad("\\\\PC\\D\\sbk\\midi.sbk", drama);
	sdram_write32(DRAM_MIDI_ADDR, drama);
	drama += size;

	size = alSeqFileLoad("\\\\PC\\D\\sbk\\bg.sbk", drama);
	sdram_write32(DRAM_BG_ADDR, drama);
	drama += size;

	size = alSeqFileLoad("\\\\PC\\D\\sbk\\demo.sbk", drama);
	sdram_write32(DRAM_DEMO_ADDR, drama);
	drama += size;
#endif // PC_MODE

	midiBank.drama = sdram_read32(DRAM_MIDI_ADDR);
	alSeqFileNew(&midiBank.seqFile, drama, 0);
	bgBank.drama = sdram_read32(DRAM_BG_ADDR);
	alSeqFileNew(&bgBank.seqFile, drama, 0);
	demoBank.drama = sdram_read32(DRAM_DEMO_ADDR);;
	alSeqFileNew(&demoBank.seqFile, drama, 0);

#ifdef SAVE_TO_FLASH
	SaveToFlash();
#endif

	ControlCreate(&seqp);

	for (n = 0; n < 16; n++)
	{
		alSeqpSetChlProgram(&seqp, n, 0);
		alSeqpSetChlVol(&seqp, n, 0x7f);
		alSeqpSetChlPan(&seqp, n, 0x40);
		alSeqpSetChlPriority(&seqp, n, 5);
		alSeqpSetChlFXMix(&seqp, n, 0x0);
	}
	//alSeqpSetChlProgram(&seqp, 1, 1);
	//alSeqpSetChlProgram(&seqp, 2, 2);
	//alSeqpSetChlPriority(&seqp, 1, 7);
	alSeqpSetTempo(&seqp, 500000);
	seqp.chanMask = (0xfffF);
	//alSeqpPlay(&seqp);
	terminalSetAnimate(NULL);
	fcodecMute(false);
	while (1)
	{
		alSynUpdate(&global.drvr);
		key = terminalRead();
		if (key != KEY_NO)
		{
			EnterCase(&seqp, key);
		}
		speakerUpdate(&seqp);
	}
	return;
}


/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "sdram.h"

// Global variables
ALGlobals * alGlobals;				
 
void    alInit(ALGlobals *glob, ALSynConfig *c)
{
	sdram_init();					// initializing SDRAM
	alGlobals = glob;				// Synthesizer
	alSynNew(&alGlobals->drvr, c);
}

void    alClose(ALGlobals *glob)
{
	alSynDelete( &alGlobals->drvr );
}
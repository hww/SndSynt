#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "sdram.h"

ALGlobals * alGlobals;				// Synthesizer
 
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
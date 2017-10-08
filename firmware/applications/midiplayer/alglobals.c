#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "sdram.h"

ALGlobals * alGlobals;				// Указатель на синтезатор, он обязательно глобальный
 
void    alInit(ALGlobals *glob, ALSynConfig *c)
{
	sdram_init();					// Иниуиализация SDRAM
	alGlobals = glob;				// Глобальный указатель на синтезатор
	alSynNew(&alGlobals->drvr, c);
}

void    alClose(ALGlobals *glob)
{
	alSynDelete( &alGlobals->drvr );
}
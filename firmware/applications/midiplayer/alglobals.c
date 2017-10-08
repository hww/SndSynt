#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "sdram.h"

ALGlobals * alGlobals;				// ��������� �� ����������, �� ����������� ����������
 
void    alInit(ALGlobals *glob, ALSynConfig *c)
{
	sdram_init();					// ������������� SDRAM
	alGlobals = glob;				// ���������� ��������� �� ����������
	alSynNew(&alGlobals->drvr, c);
}

void    alClose(ALGlobals *glob)
{
	alSynDelete( &alGlobals->drvr );
}
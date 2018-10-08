/* File: main.c */

#include "port.h"
#include "sound.h"
#include "sbankdrv.h"
#include "fcntl.h"
#include "fileio.h"
#include "mem.h"
#include "gpio.h"
#include "bsp.h"

/*******************************************************
* Skeleton C main program for use with Embedded SDK
*******************************************************/
ALBankFile *Bnk;

void main (void)
{

loop:
    Bnk = (ALBankFile*) snd_load_bank("\\\\PC\\D\\sbk\\tone.ctl");
    snd_load_tbl( "\\\\PC\\D\\sbk\\tone.tbl" );
    goto loop;
    return;          /* C statements */
}

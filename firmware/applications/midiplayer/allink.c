/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/
/*****************************************************************************
 *
 *	Double Linked list
 *
 *****************************************************************************/

#include "port.h"
#include "null.h"
#include "audiolib.h"

/*****************************************************************************
 *
 *	Remove Link
 *
 *****************************************************************************/

void    alUnlink(ALLink *element)
{												
    if(element->prev != NULL) element->prev->next = element->next;
    if(element->next != NULL) element->next->prev = element->prev;
    element->prev = NULL;
    element->next = NULL;
}

/*****************************************************************************
 *
 *	Add Link
 *
 *****************************************************************************/

void    alLink(ALLink *element, ALLink *after)
{
    element->next = after->next;
    element->prev = after;
    after->next   = element;
    if(element->next != NULL) element->next->prev = element;
}
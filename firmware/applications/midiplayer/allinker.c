/******************************************************************************
*
*	РАБОТА СО СПИСКАМИ
*
*******************************************************************************/

#include "port.h"
#include "null.h"
#include "audiolib.h"

/******************************************************************************
*
*	Вырезать элемент списка
*
*******************************************************************************/

void    alUnlink(ALLink *element)
{												
	if(element->prev != NULL) element->prev->next = element->next;
	if(element->next != NULL) element->next->prev = element->prev;
	element->prev = NULL;
	element->next = NULL;
}

/******************************************************************************
*
*	Добавить элемент списка 
*
*******************************************************************************/

void    alLink(ALLink *element, ALLink *after)
{
	element->next = after->next;
	element->prev = after;
	after->next   = element;
	if(element->next != NULL) element->next->prev = element;
}
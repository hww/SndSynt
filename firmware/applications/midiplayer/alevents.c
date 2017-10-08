#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "mem.h"
#include "mfr16.h"
#include "assert.h"

/******************************************************************************
*
*	void	alEvtqNew(ALEventQueue *evtq, ALEventListItem *items, s32 itemCount)
*
*	создаёт список сообщений в очереди
*
*******************************************************************************/

void	alEvtqNew(ALEventQueue *evtq, ALEventListItem *items, s32 itemCount)
{

	evtq->allocList.next = NULL;
	evtq->allocList.prev = NULL;
	evtq->freeList.next  = NULL;
	evtq->freeList.prev  = NULL;
	evtq->eventCount 	 = 0;							// Установили число сообщений

	while(itemCount>0)
	{
		itemCount--;
		alLink(&items[itemCount].node, &evtq->freeList);// Связали в список свободных
	}
}

/******************************************************************************
*
*	ALMicroTime     alEvtqNextEvent(ALEventQueue *evtq, ALEvent *evt)
*
*	Возвращает время до самого ближайшего сообщения. При этом само сообщение 
*   копирует по указателю. Найти сообщение не трудно, достаточно взять самое
* 	первое. Но его дельта тайм отнимается от всех дельтатайм в очереди. А само
*	найденное сообщение из очереди удаляется. 
*
*******************************************************************************/
//	A								      R2             R3
ALMicroTime alEvtqNextEvent(ALEventQueue *evtq, ALEvent *evt)
{
ALEventListItem * item = evtq->allocList.next;	// Первое сообщение
ALEventListItem * idxi;

	if(item != NULL)
	{
		memcpy( evt, &item->evt, sizeof(ALEvent));  // Скопировали сообщение
		alUnlink( &item->node );					// Удалили сообщение
		alLink( &item->node, &evtq->freeList);		// Поставли в очередь свободных
		evtq->eventCount--;
	
		idxi = evtq->allocList.next;	
		while(idxi != NULL)
		{
			idxi->delta -= item->delta;
			idxi 		 = idxi->node.next;
		}
		return item->delta;							// Время до этого сообщения
	}
	return 0;		
}

/******************************************************************************
*
*	void alEvtqPostEvent(ALEventQueue *evtq, ALEvent *evt, ALMicroTime delta)
*
*	Поставить сообщение в очередь. Программа найдёт и поставит сообщение
*	в очередь в порядке его исполнения. Таким образом самое первое сообщение
*	в очереди есть самое первое во времени.
*
*******************************************************************************/

void alEvtqPostEvent(ALEventQueue *evtq, ALEvent *evt, ALMicroTime delta)
{
ALEventListItem * item  = evtq->freeList.next;	// Первое свободное сообщение;
ALEventListItem * fitem = evtq->allocList.next;	// Позиция для поиска
	
	if(delta<0) assert(!"delta has wrong sign");
	
	if(item !=NULL)
	{
		item->delta = delta;						// Время до его исполнения
		memcpy(&item->evt, evt, sizeof(ALEvent));	// Само его сообщение
		
		if(fitem == NULL)
		{	// Ни одного сообщения нет вот и поставим одно
			alUnlink(&item->node);						// убрали из свободных
			alLink(&item->node, &evtq->allocList);		// поставили в занятые
		}
		else
		{
			// теперь найем сообщение время которого >= заданного времени
			while((fitem->node.next != NULL) && (fitem->delta<delta))
			{
				fitem = fitem->node.next;
			}
			if(fitem->delta>delta) fitem = fitem->node.prev;
			
			alUnlink(&item->node);						// убрали из свободных
			alLink(&item->node, &fitem->node);			// поставили в занятые
		}
		evtq->eventCount++;
	}
	else
	{
		assert(!"cant alloc event");
	}
}
/*
void alSeqpPostEvent( ALSeqPlayer * seqp,  ALEvent *evt, ALMicroTime delta)
{
	alEvtqPostEvent( &seqp->evtq, evt, delta + seqp->curTime);
}
*/
/******************************************************************************
*
*	void  	alEvtqFlush(ALEventQueue *evtq)
*
*	Очищает буфер сообщений
*
*******************************************************************************/

void  	alEvtqFlush(ALEventQueue *evtq)
{
ALEventListItem * evtitem;

	evtitem = evtq->allocList.next;
	while(evtitem!=NULL)
	{
		evtitem = evtitem->node.next;
		alUnlink(evtitem);
		alLink(evtitem,&evtq->freeList);
	}
	evtq->allocList.next = NULL;
	evtq->allocList.prev = NULL;
	evtq->eventCount = 0;
}

/******************************************************************************
*
*	alEvtqFlushType(ALEventQueue *evtq, s16 type)
*
*	Очищает буфер сообщений только от сообщений типа заданного переменной type
*
*******************************************************************************/

void	alEvtqFlushType(ALEventQueue *evtq, s16 type)
{
ALEventListItem * evt;
ALEventListItem * next;

	evt = evtq->allocList.next;
	while(evt!=NULL)
	{	next = evt->node.next;
		if(evt->evt.type == type)
		{	alUnlink(evt);
			alLink(evt,&evtq->freeList);
			evtq->eventCount--;
		}
		evt = next;
	}
}

/******************************************************************************
*
*	alEvtqFlushVoice(ALEventQueue *evtq, ALVoiceState * vs)
*
*	Очищает буфер сообщений только от сообщений для канала vs
*
*******************************************************************************/

void	alEvtqFlushVoice(ALEventQueue *evtq, void * vs)
{
ALEventListItem * evt;
ALEventListItem * next;

	evt = evtq->allocList.next;
	while(evt!=NULL)
	{	next = evt->node.next;
		if(evt->evt.msg.note.voice == vs)
		{	if((evt->evt.type == AL_SEQP_EVOL_EVT)  || (evt->evt.type == AL_SEQP_EPAN_EVT) || (evt->evt.type == AL_VIB_OSC_EVT))
			{	alUnlink(evt);
				alLink(evt,&evtq->freeList);
				evtq->eventCount--;
			}
		}		
		evt = next;
	}
}

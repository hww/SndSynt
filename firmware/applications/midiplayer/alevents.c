/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "null.h"
#include "audiolib.h"
#include "mem.h"
#include "mfr16.h"
#include "assert.h"

/*****************************************************************************
 *
 *  void    alEvtqNew(ALEventQueue *evtq, ALEventListItem *items, s32 itemCount)
 *
 *  Create list of events in the queue
 *
 *****************************************************************************/

void    alEvtqNew(ALEventQueue *evtq, ALEventListItem *items, s32 itemCount)
{

    evtq->allocList.next = NULL;
    evtq->allocList.prev = NULL;
    evtq->freeList.next  = NULL;
    evtq->freeList.prev  = NULL;
    evtq->eventCount     = 0;

    while(itemCount>0)
    {
        itemCount--;
        alLink(&items[itemCount].node, &evtq->freeList);
    }
}

/*****************************************************************************
 *
 *  ALMicroTime     alEvtqNextEvent(ALEventQueue *evtq, ALEvent *evt)
 *
 *   Return closest in time event. And copy this event to given pointer
 *
 *****************************************************************************/
//  A                                     R2             R3
ALMicroTime alEvtqNextEvent(ALEventQueue *evtq, ALEvent *evt)
{
ALEventListItem * item = evtq->allocList.next;
ALEventListItem * idxi;

    if(item != NULL)
    {
        memcpy( evt, &item->evt, sizeof(ALEvent));
        alUnlink( &item->node );
        alLink( &item->node, &evtq->freeList);
        evtq->eventCount--;

        idxi = evtq->allocList.next;
        while(idxi != NULL)
        {
            idxi->delta -= item->delta;
            idxi         = idxi->node.next;
        }
        return item->delta;
    }
    return 0;
}

/*****************************************************************************
 *
 *  void alEvtqPostEvent(ALEventQueue *evtq, ALEvent *evt, ALMicroTime delta)
 *
 *  Add event to the queue
 *
 *****************************************************************************/

void alEvtqPostEvent(ALEventQueue *evtq, ALEvent *evt, ALMicroTime delta)
{
    ALEventListItem * item  = evtq->freeList.next;
    ALEventListItem * fitem = evtq->allocList.next;

    if(delta<0) assert(!"delta has wrong sign");

    if(item !=NULL)
    {
        item->delta = delta;
        memcpy(&item->evt, evt, sizeof(ALEvent));   å

        if(fitem == NULL)
        {
            alUnlink(&item->node);
            alLink(&item->node, &evtq->allocList);
        }
        else
        {
            while((fitem->node.next != NULL) && (fitem->delta<delta))
            {
                fitem = fitem->node.next;
            }
            if(fitem->delta>delta) fitem = fitem->node.prev;

            alUnlink(&item->node);                      // delete free
            alLink(&item->node, &fitem->node);          // add to used
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
/*****************************************************************************
 *
 *  void    alEvtqFlush(ALEventQueue *evtq)
 *
 *  Clear events
 *
 *****************************************************************************/

void    alEvtqFlush(ALEventQueue *evtq)
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

/*****************************************************************************
 *
 *  alEvtqFlushType(ALEventQueue *evtq, s16 type)
 *
 *  Clear events of type
 *
 *****************************************************************************/

void    alEvtqFlushType(ALEventQueue *evtq, s16 type)
{
ALEventListItem * evt;
ALEventListItem * next;

    evt = evtq->allocList.next;
    while(evt!=NULL)
    {   next = evt->node.next;
        if(evt->evt.type == type)
        {   alUnlink(evt);
            alLink(evt,&evtq->freeList);
            evtq->eventCount--;
        }
        evt = next;
    }
}

/*****************************************************************************
 *
 *  alEvtqFlushVoice(ALEventQueue *evtq, ALVoiceState * vs)
 *
 *  Clear events for given channel
 *
 *****************************************************************************/

void    alEvtqFlushVoice(ALEventQueue *evtq, void * vs)
{
ALEventListItem * evt;
ALEventListItem * next;

    evt = evtq->allocList.next;
    while(evt!=NULL)
    {   next = evt->node.next;
        if(evt->evt.msg.note.voice == vs)
        {   if((evt->evt.type == AL_SEQP_EVOL_EVT)  || (evt->evt.type == AL_SEQP_EPAN_EVT) || (evt->evt.type == AL_VIB_OSC_EVT))
            {   alUnlink(evt);
                alLink(evt,&evtq->freeList);
                evtq->eventCount--;
            }
        }
        evt = next;
    }
}

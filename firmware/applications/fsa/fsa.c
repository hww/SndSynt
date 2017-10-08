/*******************************************************
* fsa.h
*******************************************************/

#include "port.h"
#include "null.h"
#include "stdio.h"
#include "alLinker.h"
#include "fsa.h"

 
static void osFsaToEndQueue(ALLink * ptr, tFsa * fsa);
static void osFsaToBegQueue(ALLink * ptr, tFsa * fsa);
static tFsa * osFsaFromQueue(ALLink * ptr);
static void readQueueRoll( OSMesgQueue *mq );
static void writeQueueRoll( OSMesgQueue *mq );
static void osAddFsaQueue( ALLink list, tFsa * fsa );
static void osDelFsaQueue( tFsa * fsa );
static void	fsaX(tFsa * fsa);
static void	fsaY(tFsa * fsa);
static void	clrLink(ALLink * link);

static void	clrLink(ALLink * link)
{	link->next	= NULL;
	link->prev	= NULL;
}

/*******************************************************
* Sheduler & Queue
*******************************************************/

static tOpSysInfo os;	//	������������ �������

/*
 *	��������� ����������� ���������
 */
static void	fsaX(tFsa * fsa)
{
	UInt16	n;
	tXY		xx, pr, mask, gotxx = 0;
	const tLS  * line = fsa->tptr;			// ������� ������									
	tFncX *	xtbl = &fsa->table->x;			// ��� ���������
	pr 	 = 0;								// ��������� ��� � 0
	
	do
	{	if((xx = line->xs) == 0)			// ������ ��������� � ���� ������?
		{	fsa->yqueue = fsa->grp->yList;	// ���! ������ ����������� ����������
			fsa->grp->yList = fsa;
			return;
		}
		xx  &= ~gotxx;						// ��� ������������ ��������� ����
		gotxx |= xx;						// ����� �����������		
		mask = 1;							// ����� ������� ��������
		n 	 = 0;							// ������� ��������
		
		while(xx != 0)						// ���� �� �������� ���� ����������
		{	if(xx & mask)					// ���� �������� ?
			{ 	if(xtbl[n]!=NULL) 			// ��������� �� ���� ����?
				{	if(xtbl[n]((void*)fsa))	// ��! �������� ��� 
								pr |= mask;	// ������ pr ���� true
				}		
				else 						// ������ ERROR ���� ��� ���������
					RETURN_ERROR(ERR_FSA_HAVNT_X);
			}
			xx &= ~mask;	 
			mask<<=1;
		}
		if((pr ^ fsa->tptr->exor) == 0)		// ������� ����������� ?
		{	fsa->yqueue = fsa->grp->yList;	// ��! 
			fsa->grp->yList = fsa;			// ������ ����������� 
			return;
		}
		else line++;						// ���! ��������� ��������� ������
	} while(line->s != fsa->state);			// ��� ������ ����� ����� ��������� 
}

/*
 *	��������� ����������� ��������
 */

static void	fsaY(tFsa * fsa)
{
	tState 	s;
	tXY		yy, mask;
	tFncX *	ytbl;
	UInt16	n;				
	const tLS  * line = fsa->tptr;			// ������� ������									
		
	if((yy = line->xs) != 0)				// ������ �������� � ���� ������?
	{
		ytbl = fsa->table->y;				// ��� ���������
		mask = 1;							// ����� ������� ��������
		n 	 = 0;							// ������� ��������
		
		while(yy != 0)						// ���� �� �������� ���� ����������
		{	if(yy & mask)					// ��� �������� ?
			{ 	if(ytbl[n]!=NULL) 			// ��������� �� ���� ����?
					ytbl[n]((void*)fsa);	// ��! �������� ��� 
				else 						// ������ ERROR ���� ��� ���������
					RETURN_ERROR(ERR_FSA_HAVNT_X);
			}
			yy &= ~mask;	 
			mask<<=1;
		}
	}
	alUnlink(&fsa->runmsg);
	alLink(&fsa->runmsg,&fsa->grp->xList);
	
	s = line->ns;							// ��������� ���������
	line = fsa->table->table;				// ������ ������ � �������
	
	while((line->s != s) || (line->s != 0))
		line++;								// ���������� ������
	if(line->s == 0) RETURN_ERROR( ERR_FSA_HAVNT_STATE );
}

/*******************************************************
*
*	������������ �������
*
*	void osRun( UInt16	todo );
*
*		��������� ���� ������� todo ���
*
*
*******************************************************/
static void osExecute( void )
{


}

/*******************************************************
*
*	������������ �������
*
*	void osRun( UInt16	todo );
*
*		��������� ���� ������� todo ���. ���� todo = 0
*		����� ��������� ������!
*
*******************************************************/

void osRun( UInt16	todo )
{	
	if(os.osState == OS_STATE_UNINITIALIZED) return;
	os.osState = OS_STATE_RUNNING ;
	if(todo == 0)
		while(1) osExecute();
	else
	{	while(todo)
		{	osExecute();
			todo--;
		}
		os.osState = OS_STATE_INITIALIZED ;
	}
}

/*******************************************************
*
*	void osInitialize( void )
*
*	�������������� ����������� �������
*
*******************************************************/

void osInitialize( void )
{
	clr(&os.grpList);				// ����� ���
	clr(&os.fsaList);				// FSA 	 ���
	os.curPri  	= 1;				// ������� ���������
	os.curFsa  	= NULL;				// ������� FSA
	os.curFsa  	= NULL;				// ������� ������
	os.yList	= NULL;				// ��� Y ��
	os.osState 	= OS_STATE_INITIALIZED;
}

/*******************************************************
*
*	void osCreateGroup( tGroupInfo * grp, tPri pri )
*
* 	�������������� ������ FSA
*
*******************************************************/

void osCreateGroup( tGroupInfo * grp, tPri pri )
{
	grp->pri = pri;						// ������ �� � ����������� pri
	clrLink(&grp->runList);				// ��� RUNNING KA
	alLink( &grp->node, &os->grpList );	// ��������� ������ � ������
}

/*******************************************************
* Fsa Interface
*******************************************************/
/*******************************************************
* ���� ������ FSA
*******************************************************/

tGroupInfo * osGetGroup( tPri pri )
{
	tGroupInfo * grp = AQ->grpList.next;
	while((grp != NULL)&&(grp->pri != pri)) grp = grp->node.next;
	return grp;
}

/*******************************************************
* ������ FSA � ������� ������
*******************************************************/

void osCreateFsa(tFsa * fsa, tId id, tFsaTblPtr table, void * args, tPri pri)
{
	fsa->grp		= osGetGroup( pri );	// ������ FSA
	fsa->id    		= id;					// ID ��������
	fsa->table 		= table;				// ��� �������
	fsa->args  		= args;					// ��� ���������
	fsa->pri   		= pri;					// ���������
	fsa->error 		= 0;					// ������ ���
	fsa->tptr  		= table->table;			// ������� ������
	fsa->state 		= table->table->s;		// ������� ���������
	fsa->queue 		= fsa->grp->runList;	// FSA ������ ������� � runList
	clrLink(&fsa->runmsg);					// �� �� �����!
	fsa->yqueue		= NULL;					// FSA �� � ������� ��������
	fsa->called		= NULL;					// FSA ����� �� ��������
	fsa->gstate		= FSA_STATE_READY;		// �����  � ������
	alLink(fsa,AQ->fsaList);				// ������� ��� � ������ ���� FSA
}

/*******************************************************
 *
 *	���������� FSA, ������� ��� �� ���� ��������
 *	
 *******************************************************/

void osDestroyFsa(tFsa * fsa)
{ 	
	alUnlink(&fsa->runmsg);					// �� ��������
	fsa->queue = NULL;						// 
	alUnlink(&fsa->node);					// �� ������ ���� FSA
	fsa->gstate   = FSA_STATE_NONEXISTENT;	// �� �����
}

void osStartFsa(tFsa * fsa)
{ 	
	if(fsa->gsate == FSA_STATE_READY)		// ������ �� ��������� READY
	{	fsa->gstate = FSA_STATE_RUNING;
		alLink(&fsa->runmsg, fsa->queue);	// ������ � ������� ��� ����� ��
	}
}

void osStopFsa(tFsa * fsa) 
{ 	
	alUnlik( fsa->runmsg );					// ������ �� �������
	fsa->gstate = FSA_STATE_READY; 			// ����� � ������
}

tId  osGetFsaId(tFsa * fsa){ return fsa->id; }
tPri osGetFsaPri(tFsa * fsa) { return fsa->pri; }
void osSetFsaPri(tFsa * fsa, tPri pri)
{ 	
tGroupInfo * newgrp = osGetGroup( pri );		// ����� ������ FSA
		fsa->pri = pri;						// ��� ����� ��������� 
	
	if(fsa->queue  == fsa->grp->runList)	// ���� FSA ��� � ������� run
		fsa->queue = &newgrp->runList;		// ������ �� ����� �������
	if(fsa->yqueue == fsa->grp->yList)		// ���� FSA ��� � ������� Y
		fsa->queue = &newgrp->yList;		// ������ �� �������

	if(fsa->gstate == FSA_STATE_RUNING)
	{	alUnlink(&fsa->runmsg);				// ������ ���
		alLink(&fsa->runmsg,fsa->queue);	// �������� � ����� run
	}
	fsa->grp = newgrp;						// ������ FSA
}

/*******************************************************
 *
 *	������ FSA � ��������� �������� � ������� ������ ������
 *	������� ������� ptr. �� ������ � ����� �������!
 *
 *******************************************************/

void osFsaToEndQueue(ALLink * ptr, tFsa * fsa)
{
	fsa->gstate = FSA_STATE_QUEUE_BLOCK;	// ���� ����������
	fsa->queue	= ptr;						// ������ �� ������� � �������
	while(ptr->node.next != NULL) 
		ptr = ptr->node.next;				// ����� ��������� FSA � ������� 
	alUnlink(&fsa->runmsg);					// ������ �� �������
	alLink(&fsa->runmsg,ptr);				// � ���� ������� ��������� �� ����
}

/*******************************************************
 *
 *	������ FSA � ��������� �������� � ������� ������ ������
 *	������� ������� ptr. �� ������ � ������ �������!
 *
 *******************************************************/

void osFsaToBegQueue(ALLink * ptr, tFsa * fsa)
{
	fsa->gstate = FSA_STATE_QUEUE_BLOCK;	// ���� ����������
	fsa->queue	= ptr;						// ������ �� ������� � �������
	alUnlink(&fsa->runmsg);					// ������ �� �������
	alLink(&fsa->runmsg,ptr);				// � ���� ������� ��������� �� ����
}

/*******************************************************
 *
 *	��������� FSA �� ��������� �������� � ������� 
 *	������ ������ ������� ������� ptr.
 *
 *******************************************************/

tFsa * osFsaFromQueue(ALLink * ptr)
{
tFsa * 	fsa = ptr->next;
		fsa->gstate = FSA_STATE_RUNING;		// ��������� FSA
		alUnlink(fsa->runmsg);
		alLink(&fsa->runmsg,&fsa->grp->xList);
		return fsa;
}

/*
 *	����� �� ����� �������������� ������ �� ���������. ����
 * 	���������� �� ��� � ���� ����� ����� ��� ��������. ����
 *	������ �� ����������� �� ������� �������� ����������� �
 *	��������� 'RT'. �� ���������� ���������� ��������� �
 *	����� ������ ��������� ������� ���������.
 */

bool osCallFsa(tFsa * fsa, void * args, Int16 flag) 
{ 
	if(fsa->gstate != FSA_STATE_STOP)		// FSA �� �����
	{	if(flag == OS_MESG_NO_BLOCK) 
			return false;					// �� ����������� �� ����
		else osFsaToQueue(&fsa->callq, AQ->curFsa);
		return true;
	}
	fsa->args = args;		
	fsa->called = AQ->curFsa;				// ���������� fsa ���������
											// �� �������
	fsa->called->gstate = FSA_STATE_CALL;	// ������ �����������
	osStartFsa(fsa);						// �������� fsa
	return true;					
}

/*******************************************************
* Messages Interface
*******************************************************/

/*******************************************************
 *  ��������� ����� ���������� � ��������� �� ���������� 
 *	��� ��������. ���������� flag == OS_MESG_BLOCK 
 *	��������� ������������ ��������� � ������ ������������. 
 *	���� flag == OS_MESG_NO_BLOCK ��������� �� ��������� 
 *	��. ������� ���������� true ���� ��������� ���������� 
 *	� false ���� ����� �� ��������. 
 *	
 *	����� ������� "�������������� �����������"
 *
 *	bool x1( tFsa * obj )
 *	{ 	return osSendMesg( mq, msg, OS_MESG_NO_BLOCK); }
 *	bool x2( tFsa * obj )
 *	{ 	return osSendMesg( mq1, msg, OS_MESG_NO_BLOCK); }
 *
 *	LS( 'S0','S2',X1, 0 )	� ���� ������ �� ��������� �
 *							S2 ���� ��������� ����������
 *							� mq
 *	LS( 'S0','S3',X1, 0 )	� ���� ������ �� ��������� �
 *							S3 ���� ��������� ����������
 *							� mq1
 *	
 *	���������� ��� � ����������� �� ���� ���� ����� �����
 *  ���� ��������� �� ������ �������. �� �������! ���������
 * 	����� ���������� ������ � ���� ������� ���� ���� ���
 *	������� ��������.
 *
 *******************************************************/

void osCreateMesgQueue(OSMesgQueue *mq, OSMesg *msg, Int16 count)
{
	mq->msg 			= msg;		// ARRAY ���������
	mq->msgCount 		= count;	// ������� �� ����� ����
	mq->first			= 0;		// ������ ��������� 0
	mq->validCount  	= 0;		// ���������� 0
	clrLink(&mq->waitrd);			// ������� ��������� ������
	clrLink(&mq->waitwr);			// ������� ��������� ������
}

/*******************************************************
 *
 *	������ ��������� � ����� ������� ���������. 
 *
 *	���� ������� �������� � �� ����� 0, �� ������ ���������
 *	� ������� � ���������� true.
 * 
 *	���� ������� ������ � flag == OS_MESG_NO_BLOCK �� 
 *	���������� false. 
 *	
 *	���� ������� ������ � flag == OS_MESG_BLOCK �� ������ 
 *	������� ����������� � ������ ������� ���������.
 *
 *	����� ���� ��� ��������� ����������� � ������� ��
 *	� ������� FSA �� ������ ���� FSA �� ������� ������������
 *	���������� FSA � ��������� �� ��������� ������� ��� �����
 *
 *******************************************************/

bool osSendMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag)
{	
	Int16 idx;
	if(mq->validCount == mq->msgCount)				// ������� ������
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// ���� ����� ������
		else
		{ 	osFsaToEndQueue(&mq->waitwr, AQ->curFsa);// ������� ��������
			AQ->curFsa->msg   = msg;				// ��������� ��������
			return false;
		}
	}
	
	if((idx = mq->validCount + mq->first) >= mq->msgCount) idx -= mq->msgCount;
	mq->msg[idx] = msg;
	mq->validCount++;
	if(mq->waitrd.next != NULL) readQueueRoll(mq);	
	return true;
}

/*******************************************************
 *
 *	������ ��������� � ������ ������� ���������. 
 *
 *	���� ������� �������� � �� ����� 0, �� ������ ���������
 *	� ������� � ���������� true.
 * 
 *	���� ������� ������ � flag == OS_MESG_NO_BLOCK �� 
 *	���������� false. 
 *	
 *	���� ������� ������ � flag == OS_MESG_BLOCK �� ������ 
 *	������� ����������� � ������ ������� ���������.
 *
 *	����� ���� ��� ��������� ����������� � ������� ��
 *	� ������� FSA �� ������ ���� FSA �� ������� ������������
 *	���������� FSA � ��������� �� ��������� ������� ��� �����
 *
 *******************************************************/

bool osJamMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag)
{	
	Int16 idx;
	if(mq->validCount == mq->msgCount)				// ������� ������
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// ���� ����� ������
		else
		{ 	osFsaToBegQueue(&mq->waitwr, AQ->curFsa);// ������� ��������
			AQ->curFsa->msg = msg;					// ��������� ��������
			return false;
		}
	}
	if((idx = mq->first-1) < 0) idx += mq->msgCount;
	mq->msg[idx] = msg;
	mq->validCount++;	
	if(mq->waitrd.next != NULL) readQueueRoll(mq);	
	return true;
}

/*******************************************************
 *
 *	�������� ��������� �� ������� ���������. 
 *	
 *	����  � ������� ���� ������, �� �������� � � 
 *	���������� true.
 * 	
 *	���� ������� ����� � flag == OS_MESG_NO_BLOCK �� 
 *	���������� false. 
 *
 *	���� ������� ����� � flag == OS_MESG_BLOCK �� ������
 *	������� ���������� � ����� ������� ����������. 
 *	
 *	����� ���� ��� ��������� ����� �� �������, ����������� 
 *	������� FSA � ������� �� ������. ���� ����� FSA ����
 *	����������� �� ����������� ��������� � ������� �� ���
 *	��� ���� ������� �� ����������.
 *
 *	� ������ ����� ������ ������� ����� 0 ��� ����� � 
 *	������� ���	���������, �� ���� FSA � ������� �� ������
 *	�� ��������� ������������� �� ����� FSA ����� ���� �� 
 *	�������������.
 *
 *******************************************************/

bool osRecvMesg(OSMesgQueue *mq, OSMesg *msg, Int16 flag)
{	
tFsa * fsa;
Int16 idx;

	if((mq->validCount == 0) && (mq->waitwr==NULL))
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// ���� ����� ����
		else
		{ 	osFsaToQueue(&mq->waitrd, AQ->curFsa);	// ������� ��������
			AQ->curFsa->msg = msg;					// ��������� ��������
			return false;
		}
	}

	if(mq->validCount != 0)							// ��������� � �������
	{	*msg = mq->msg[mq->first++];				// ������ ������ ���������
		mq->validCount--;							// ������� �� ������
		if(mq->first >=  mq->msgCount) 
			mq->first = 0;							// ��������� overlap
		if(mq->waitwr.next!=NULL)					// �� � ������� ����
			readFsaRoll(mq);						// ���������� �������	
	}
	else if(mq->waitwr!=NULL)						// ��������� � �������������� FSA
	{	fsa = osFsaFromQueue(&mq->waitwr);			// ������ � �������
		msg = fsa->msg;								// ��������� ��������� 
	}	
	return true;
}

/*
 *	���������� ������� �� ������
 */

void writeQueueRoll( OSMesgQueue *mq )
{
	Int16 	idx;
	tFsa *	fsa;
	
	while(mq->validCount < mq->msgCount)			// ������� ��������
	{	if(mq->waitwr.next == NULL ) return;		// � � ������� �� ���� ���						
		{	if((idx = mq->validCount + mq->first) >= mq->msgCount) 
				idx -= mq->msgCount;
			fsa = osFsaFromQueue(&mq->waitwr);		// ������ � �������
			mq->msg[idx] = fsa->msg;				// ��������� �������
			mq->validCount++;						// ����� �� ������
		}
	}
}

/*
 *	���������� ������� �� ������
 */ 

void readQueueRoll( OSMesgQueue *mq )
{
	Int16 	idx;
	tFsa *	fsa;
	
	while(mq->validCount > 0)						// ������� ��������
	{	if(mq->waitrd.next == NULL ) return;		// � � ������� �� ���� ���						
		{	fsa = osFsaFromQueue(&mq->waitrd);		// ������ � �������
			*fsa->msg = mq->msg[mq->first++];		// ������ ������ ���������
			mq->validCount--;						// ������� �� ������
			if(mq->first >=  mq->msgCount) 
				mq->first = 0;						// ��������� overlap
		}
	}
}

/*
 *	��������� ������� -> ��������� � ������� ���� ��� ����� ������� !
 *
 */

void osSetEventMesg(OSEvent e, OSMesgQueue *mq, OSMesg m)
{	
	// ���� �� �����������

}

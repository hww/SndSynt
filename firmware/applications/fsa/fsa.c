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

static tOpSysInfo os;	//	операционная система

/*
 *	Программа выполняющая предикаты
 */
static void	fsaX(tFsa * fsa)
{
	UInt16	n;
	tXY		xx, pr, mask, gotxx = 0;
	const tLS  * line = fsa->tptr;			// Текущая строка									
	tFncX *	xtbl = &fsa->table->x;			// Где предикаты
	pr 	 = 0;								// Предикаты все в 0
	
	do
	{	if((xx = line->xs) == 0)			// Естьли предикаты в этой строке?
		{	fsa->yqueue = fsa->grp->yList;	// Нет! Строка выполняется безусловно
			fsa->grp->yList = fsa;
			return;
		}
		xx  &= ~gotxx;						// Уже отработанные предикаты ВЫКЛ
		gotxx |= xx;						// Какие отработанны		
		mask = 1;							// Маска нулевой предикат
		n 	 = 0;							// нулевой предикат
		
		while(xx != 0)						// Пока не выполним всех предикатов
		{	if(xx & mask)					// Этот предикат ?
			{ 	if(xtbl[n]!=NULL) 			// Указатель на него ЕСТЬ?
				{	if(xtbl[n]((void*)fsa))	// ДА! Выполним его 
								pr |= mask;	// Взведём pr если true
				}		
				else 						// Взведём ERROR если нет предиката
					RETURN_ERROR(ERR_FSA_HAVNT_X);
			}
			xx &= ~mask;	 
			mask<<=1;
		}
		if((pr ^ fsa->tptr->exor) == 0)		// Условие выполнилось ?
		{	fsa->yqueue = fsa->grp->yList;	// Да! 
			fsa->grp->yList = fsa;			// Строка выполняется 
			return;
		}
		else line++;						// Нет! Попробуем следующую строку
	} while(line->s != fsa->state);			// Нет больше строк этого состояния 
}

/*
 *	Программа выполняющая действия
 */

static void	fsaY(tFsa * fsa)
{
	tState 	s;
	tXY		yy, mask;
	tFncX *	ytbl;
	UInt16	n;				
	const tLS  * line = fsa->tptr;			// Текущая строка									
		
	if((yy = line->xs) != 0)				// Естьли действия в этой строке?
	{
		ytbl = fsa->table->y;				// Где предикаты
		mask = 1;							// Маска нулевое действие
		n 	 = 0;							// нулевое действие
		
		while(yy != 0)						// Пока не выполним всех предикатов
		{	if(yy & mask)					// Это действие ?
			{ 	if(ytbl[n]!=NULL) 			// Указатель на него ЕСТЬ?
					ytbl[n]((void*)fsa);	// ДА! Выполним его 
				else 						// Взведём ERROR если нет предиката
					RETURN_ERROR(ERR_FSA_HAVNT_X);
			}
			yy &= ~mask;	 
			mask<<=1;
		}
	}
	alUnlink(&fsa->runmsg);
	alLink(&fsa->runmsg,&fsa->grp->xList);
	
	s = line->ns;							// Следующее состояние
	line = fsa->table->table;				// Первая строка в таблице
	
	while((line->s != s) || (line->s != 0))
		line++;								// перебираем строки
	if(line->s == 0) RETURN_ERROR( ERR_FSA_HAVNT_STATE );
}

/*******************************************************
*
*	Операционная система
*
*	void osRun( UInt16	todo );
*
*		Выполняет ядро системы todo раз
*
*
*******************************************************/
static void osExecute( void )
{


}

/*******************************************************
*
*	Операционная система
*
*	void osRun( UInt16	todo );
*
*		Выполняет ядро системы todo раз. Если todo = 0
*		тогда выполняет всегда!
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
*	Инициализирует операционую систему
*
*******************************************************/

void osInitialize( void )
{
	clr(&os.grpList);				// Групп нет
	clr(&os.fsaList);				// FSA 	 нет
	os.curPri  	= 1;				// Текущий приоритет
	os.curFsa  	= NULL;				// Текущий FSA
	os.curFsa  	= NULL;				// Текущая группа
	os.yList	= NULL;				// Нет Y КА
	os.osState 	= OS_STATE_INITIALIZED;
}

/*******************************************************
*
*	void osCreateGroup( tGroupInfo * grp, tPri pri )
*
* 	Инициализирует группу FSA
*
*******************************************************/

void osCreateGroup( tGroupInfo * grp, tPri pri )
{
	grp->pri = pri;						// Группа КА с приоритетом pri
	clrLink(&grp->runList);				// Нет RUNNING KA
	alLink( &grp->node, &os->grpList );	// Поставили группу в список
}

/*******************************************************
* Fsa Interface
*******************************************************/
/*******************************************************
* Ищет группу FSA
*******************************************************/

tGroupInfo * osGetGroup( tPri pri )
{
	tGroupInfo * grp = AQ->grpList.next;
	while((grp != NULL)&&(grp->pri != pri)) grp = grp->node.next;
	return grp;
}

/*******************************************************
* Ставит FSA в очередь группы
*******************************************************/

void osCreateFsa(tFsa * fsa, tId id, tFsaTblPtr table, void * args, tPri pri)
{
	fsa->grp		= osGetGroup( pri );	// группа FSA
	fsa->id    		= id;					// ID процесса
	fsa->table 		= table;				// Где таблицы
	fsa->args  		= args;					// Где аргументы
	fsa->pri   		= pri;					// Приоритет
	fsa->error 		= 0;					// Ошибок нет
	fsa->tptr  		= table->table;			// текущая строка
	fsa->state 		= table->table->s;		// Текущее состояние
	fsa->queue 		= fsa->grp->runList;	// FSA должен стоянть в runList
	clrLink(&fsa->runmsg);					// Но не стоит!
	fsa->yqueue		= NULL;					// FSA не в очереди действий
	fsa->called		= NULL;					// FSA никто не вызывает
	fsa->gstate		= FSA_STATE_READY;		// Готов  к работе
	alLink(fsa,AQ->fsaList);				// Включим его в список всех FSA
}

/*******************************************************
 *
 *	Уничтожает FSA, убирает его из всех очередей
 *	
 *******************************************************/

void osDestroyFsa(tFsa * fsa)
{ 	
	alUnlink(&fsa->runmsg);					// Из ожидания
	fsa->queue = NULL;						// 
	alUnlink(&fsa->node);					// Из списка всех FSA
	fsa->gstate   = FSA_STATE_NONEXISTENT;	// Не готов
}

void osStartFsa(tFsa * fsa)
{ 	
	if(fsa->gsate == FSA_STATE_READY)		// Только из состояния READY
	{	fsa->gstate = FSA_STATE_RUNING;
		alLink(&fsa->runmsg, fsa->queue);	// Ставим в очередь где стоял КА
	}
}

void osStopFsa(tFsa * fsa) 
{ 	
	alUnlik( fsa->runmsg );					// Убрали из очереди
	fsa->gstate = FSA_STATE_READY; 			// Готов к работе
}

tId  osGetFsaId(tFsa * fsa){ return fsa->id; }
tPri osGetFsaPri(tFsa * fsa) { return fsa->pri; }
void osSetFsaPri(tFsa * fsa, tPri pri)
{ 	
tGroupInfo * newgrp = osGetGroup( pri );		// Новая группа FSA
		fsa->pri = pri;						// Его новый приоритет 
	
	if(fsa->queue  == fsa->grp->runList)	// Если FSA был в очереди run
		fsa->queue = &newgrp->runList;		// Укажем на новую очередь
	if(fsa->yqueue == fsa->grp->yList)		// Если FSA был в очереди Y
		fsa->queue = &newgrp->yList;		// Укажем на очередь

	if(fsa->gstate == FSA_STATE_RUNING)
	{	alUnlink(&fsa->runmsg);				// Снимем его
		alLink(&fsa->runmsg,fsa->queue);	// Поставим в новую run
	}
	fsa->grp = newgrp;						// группа FSA
}

/*******************************************************
 *
 *	Ставит FSA в состояние ожидания в очереди первыя запись
 *	которой указана ptr. Но ставит в конец очереди!
 *
 *******************************************************/

void osFsaToEndQueue(ALLink * ptr, tFsa * fsa)
{
	fsa->gstate = FSA_STATE_QUEUE_BLOCK;	// Этот Остановили
	fsa->queue	= ptr;						// Укажем на позицию в очереди
	while(ptr->node.next != NULL) 
		ptr = ptr->node.next;				// Нашли последний FSA в очереди 
	alUnlink(&fsa->runmsg);					// Убрали из очереди
	alLink(&fsa->runmsg,ptr);				// В него вписали указатель на этот
}

/*******************************************************
 *
 *	Ставит FSA в состояние ожидания в очереди первыя запись
 *	которой указана ptr. Но ставит в начало очереди!
 *
 *******************************************************/

void osFsaToBegQueue(ALLink * ptr, tFsa * fsa)
{
	fsa->gstate = FSA_STATE_QUEUE_BLOCK;	// Этот Остановили
	fsa->queue	= ptr;						// Укажем на позицию в очереди
	alUnlink(&fsa->runmsg);					// Убрали из очереди
	alLink(&fsa->runmsg,ptr);				// В него вписали указатель на этот
}

/*******************************************************
 *
 *	Выключает FSA из состояние ожидания в очереди 
 *	первыя запись которой указана ptr.
 *
 *******************************************************/

tFsa * osFsaFromQueue(ALLink * ptr)
{
tFsa * 	fsa = ptr->next;
		fsa->gstate = FSA_STATE_RUNING;		// Запустили FSA
		alUnlink(fsa->runmsg);
		alLink(&fsa->runmsg,&fsa->grp->xList);
		return fsa;
}

/*
 *	Вызов КА может осуществляться только из предиката. Если
 * 	вызываемый КА был в СТОП тогда вызов его возможен. Вызы
 *	вающий КА блокируется до момента перехода вызываемого в
 *	состояние 'RT'. Но фактически вызываемый переходит в
 *	самое первое состояние таблицы состояний.
 */

bool osCallFsa(tFsa * fsa, void * args, Int16 flag) 
{ 
	if(fsa->gstate != FSA_STATE_STOP)		// FSA не готов
	{	if(flag == OS_MESG_NO_BLOCK) 
			return false;					// Но блокировать не надо
		else osFsaToQueue(&fsa->callq, AQ->curFsa);
		return true;
	}
	fsa->args = args;		
	fsa->called = AQ->curFsa;				// Вызываемый fsa указывает
											// на хозяина
	fsa->called->gstate = FSA_STATE_CALL;	// хозяин блокируется
	osStartFsa(fsa);						// запустим fsa
	return true;					
}

/*******************************************************
* Messages Interface
*******************************************************/

/*******************************************************
 *  Сообщения можно отправлять и принимать из предикатов 
 *	или действий. Переменная flag == OS_MESG_BLOCK 
 *	разрешает блокирование процессса в момент коммуникации. 
 *	Если flag == OS_MESG_NO_BLOCK сообщение не блокирует 
 *	КА. Функция возвращает true если сообщение доставлено 
 *	и false если этого не поизошло. 
 *	
 *	Можно создать "Альтернативный конструктор"
 *
 *	bool x1( tFsa * obj )
 *	{ 	return osSendMesg( mq, msg, OS_MESG_NO_BLOCK); }
 *	bool x2( tFsa * obj )
 *	{ 	return osSendMesg( mq1, msg, OS_MESG_NO_BLOCK); }
 *
 *	LS( 'S0','S2',X1, 0 )	В этой строке КА переходит в
 *							S2 если сообщение отправлено
 *							в mq
 *	LS( 'S0','S3',X1, 0 )	В этой строке КА переходит в
 *							S3 если сообщение отправлено
 *							в mq1
 *	
 *	Получается что в зависимости от того куда будет доств
 *  лено сообщение КА примет решение. Но главное! Сообщение
 * 	будет доставлено только в одну очередь даже если обе
 *	очереди свободны.
 *
 *******************************************************/

void osCreateMesgQueue(OSMesgQueue *mq, OSMesg *msg, Int16 count)
{
	mq->msg 			= msg;		// ARRAY сообщений
	mq->msgCount 		= count;	// Сколько их может быть
	mq->first			= 0;		// Первое сообщение 0
	mq->validCount  	= 0;		// Количество 0
	clrLink(&mq->waitrd);			// Очередь ожидающих чтение
	clrLink(&mq->waitwr);			// Очередь ожидающих запись
}

/*******************************************************
 *
 *	Ставит сообщение в конце очереди сообщений. 
 *
 *	Если очередь свободна и не равна 0, то ставит сообщение
 *	в очередь и возвращает true.
 * 
 *	Если очередь занята и flag == OS_MESG_NO_BLOCK то 
 *	возвращает false. 
 *	
 *	Если очередь занята и flag == OS_MESG_BLOCK то ставит 
 *	процесс отправитель в начало очереди ожидающих.
 *
 *	После того как сообщение оказывается в очереди но
 *	в очереди FSA на чтение есть FSA то очередь продвигается
 *	освобождая FSA и передавая им сообщения которые они ждали
 *
 *******************************************************/

bool osSendMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag)
{	
	Int16 idx;
	if(mq->validCount == mq->msgCount)				// Очередь полная
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// Если буфер полный
		else
		{ 	osFsaToEndQueue(&mq->waitwr, AQ->curFsa);// Процесс вочередь
			AQ->curFsa->msg   = msg;				// Сообщение запомним
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
 *	Ставит сообщение в начале очереди сообщений. 
 *
 *	Если очередь свободна и не равна 0, то ставит сообщение
 *	в очередь и возвращает true.
 * 
 *	Если очередь занята и flag == OS_MESG_NO_BLOCK то 
 *	возвращает false. 
 *	
 *	Если очередь занята и flag == OS_MESG_BLOCK то ставит 
 *	процесс отправитель в начало очереди ожидающих.
 *
 *	После того как сообщение оказывается в очереди но
 *	в очереди FSA на чтение есть FSA то очередь продвигается
 *	освобождая FSA и передавая им сообщения которые они ждали
 *
 *******************************************************/

bool osJamMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag)
{	
	Int16 idx;
	if(mq->validCount == mq->msgCount)				// Очередь полная
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// Если буфер полный
		else
		{ 	osFsaToBegQueue(&mq->waitwr, AQ->curFsa);// Процесс вочередь
			AQ->curFsa->msg = msg;					// Сообщение запомним
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
 *	Получает сообщение из очереди сообщений. 
 *	
 *	Если  в очереди есть запись, то получает её и 
 *	возвращает true.
 * 	
 *	Если очередь пуста и flag == OS_MESG_NO_BLOCK то 
 *	возвращает false. 
 *
 *	Если очередь пуста и flag == OS_MESG_BLOCK то ставит
 *	процесс получатель в конец очереди ожидающийх. 
 *	
 *	После того как сообщение взято из очереди, проверяется 
 *	наличие FSA в очереди на запись. Если такие FSA есть
 *	освобождает их переписывая сообщения в очередь до тех
 *	пор пока очередь не наполнится.
 *
 *	В случае когда размер очереди равен 0 или когда в 
 *	очереди нет	сообщений, но есть FSA в очереди на запись
 *	то сообщение прочитывается из этого FSA после чего он 
 *	освобождается.
 *
 *******************************************************/

bool osRecvMesg(OSMesgQueue *mq, OSMesg *msg, Int16 flag)
{	
tFsa * fsa;
Int16 idx;

	if((mq->validCount == 0) && (mq->waitwr==NULL))
	{ 	if(flag == OS_MESG_NO_BLOCK) return false;	// Если буфер пуст
		else
		{ 	osFsaToQueue(&mq->waitrd, AQ->curFsa);	// Процесс вочередь
			AQ->curFsa->msg = msg;					// Сообщение запомним
			return false;
		}
	}

	if(mq->validCount != 0)							// Сообщение в очереди
	{	*msg = mq->msg[mq->first++];				// Прочтём первое сообщение
		mq->validCount--;							// Теперрь их меньше
		if(mq->first >=  mq->msgCount) 
			mq->first = 0;							// Произошёл overlap
		if(mq->waitwr.next!=NULL)					// КА в очереди есть
			readFsaRoll(mq);						// Продвинули очередь	
	}
	else if(mq->waitwr!=NULL)						// Сообщение у блокированоого FSA
	{	fsa = osFsaFromQueue(&mq->waitwr);			// Первый в очереди
		msg = fsa->msg;								// Прочитали сообщение 
	}	
	return true;
}

/*
 *	Продвигает очередь на запись
 */

void writeQueueRoll( OSMesgQueue *mq )
{
	Int16 	idx;
	tFsa *	fsa;
	
	while(mq->validCount < mq->msgCount)			// Очередь доступна
	{	if(mq->waitwr.next == NULL ) return;		// А в очереди ни кого нет						
		{	if((idx = mq->validCount + mq->first) >= mq->msgCount) 
				idx -= mq->msgCount;
			fsa = osFsaFromQueue(&mq->waitwr);		// Первый в очереди
			mq->msg[idx] = fsa->msg;				// сообщение забрали
			mq->validCount++;						// число их больше
		}
	}
}

/*
 *	Продвигает очередь на чтение
 */ 

void readQueueRoll( OSMesgQueue *mq )
{
	Int16 	idx;
	tFsa *	fsa;
	
	while(mq->validCount > 0)						// Очередь доступна
	{	if(mq->waitrd.next == NULL ) return;		// А в очереди ни кого нет						
		{	fsa = osFsaFromQueue(&mq->waitrd);		// Первый в очереди
			*fsa->msg = mq->msg[mq->first++];		// Прочтём первое сообщение
			mq->validCount--;						// Теперрь их меньше
			if(mq->first >=  mq->msgCount) 
				mq->first = 0;						// Произошёл overlap
		}
	}
}

/*
 *	Назначает событию -> сообщение и очередь куда оно будет послано !
 *
 */

void osSetEventMesg(OSEvent e, OSMesgQueue *mq, OSMesg m)
{	
	// ПОКА НЕ РЕАЛИЗОВАНО

}

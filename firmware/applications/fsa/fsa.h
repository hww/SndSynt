/*******************************************************
* fsa.h
*******************************************************/

#include "port.h"
#include "null.h"
#include "alLinker.h"

/*******************************************************
* New types
*******************************************************/

#define NUM_XY	16
#define DEFAULT_PRI 0xFFFF

typedef UInt16 tError;
typedef UInt32 tId;
typedef UInt16 tState;
typedef UInt16 tXY;
typedef UInt16 tPri;
typedef bool(*tFncX)( void * fsa );
typedef void(*tFncY)( void * fsa );

typedef UInt16 OSEvent;				// СОБЫТИЯ !was u32
typedef void * OSMesg;				// СООБЩЕНИЕ
typedef struct GroupInfo_s;			// Очередь групп

typedef enum
{	FSA_STATE_NONEXISTENT = 0,		// не готов
	FSA_STATE_READY,				// стоит
	FSA_STATE_RUNING,  				// работает
	FSA_STATE_QUEUE_BLOCK,			// блокирован, в очереди
	FSA_STATE_CALL,					// сделал ВЫЗОВ
	FSA_STATE_ERROR 				// совершил ошибку
} FsaState;

typedef enum
{	FSA_PHASE_X     =	0,			// предикаты
	FSA_PHASE_Y     				// действия
} FsaPhase;

#define RETURN_ERROR(x) {fsa->error = x; fsa->state = FSA_STATE_ERROR;return;}
#define ERR_FSA_HAVNT_X 1
#define ERR_FSA_HAVNT_Y 2
#define ERR_FSA_HAVNT_STATE 4

/*******************************************************
* FSA
*******************************************************/
/*******************************************************
* заполнение таблицы состояний
*******************************************************/
#define SB(x) ((1<<x)+(1<<(x+NUM_XY)))
#define NB(x)  (1<<x)

#define X(x)  SB(x)
#define nX(x) NB(x)
#define Y(x)  SB(x)

const tXY x1 =X(0);  const tXY x2 =X(1);  const tXY x3 =X(2);  const tXY x4 =X(3);
const tXY x5 =X(4);  const tXY x6 =X(5);  const tXY x7 =X(6);  const tXY x8 =X(7);
const tXY x9 =X(8);  const tXY x10=X(9);  const tXY x11=X(10); const tXY x12=X(11);
const tXY x13=X(12); const tXY x14=X(13); const tXY x15=X(14); const tXY x16=X(15);

const tXY nx1 =nX(0);  const tXY nx2 =nX(1);  const tXY nx3 =nX(2);  const tXY nx4 =nX(3);
const tXY nx5 =nX(4);  const tXY nx6 =nX(5);  const tXY nx7 =nX(6);  const tXY nx8 =nX(7);
const tXY nx9 =nX(8);  const tXY nx10=nX(9);  const tXY nx11=nX(10); const tXY nx12=nX(11);
const tXY nx13=nX(12); const tXY nx14=nX(13); const tXY nx15=nX(14); const tXY nx16=nX(15);

const tXY y1 =Y(0);  const tXY y2 =Y(1);  const tXY y3 =Y(2);  const tXY y4 =Y(3);
const tXY y5 =Y(4);  const tXY y6 =Y(5);  const tXY y7 =Y(6);  const tXY y8 =Y(7);
const tXY y9 =Y(8);  const tXY y10=Y(9);  const tXY y11=Y(10); const tXY y12=Y(11);
const tXY y13=Y(12); const tXY y14=Y(13); const tXY y15=Y(14); const tXY y16=Y(15);

#define MASK_XY ((1<<NUM_XY)-1)
#define LS( state, nstate, xx, yy ) {((tState)state),\
									 ((tState)nstate),\
									 ((tXY)xx & MASK_XY),\
									 ((tXY)(xx>>NUM_XY) & MASK_XY),\
									 ((tXY) yy & MASK_XY)}
#define ES LS( 0 ,0 ,0 ,0 )			

typedef struct LS_s
{
	tState	s;			// Состояние
	tState	ns;			// Следующее
	tXY		xs;			// Предикаты
	tXY		exor;		// exclusive OR
	tXY		ys;			// Действия
} tLS;

typedef struct FsaTbl_s
{
	tFncX	x[NUM_XY];
	tFncX	y[NUM_XY];
	tLS		table[];
} tFsaTbl;

typedef const tFsaTbl * tFsaTblPtr;
typedef struct OpSysInfo_s;

typedef struct Fsa_s
{
		ALLink			runmsg;		// Очередь работающих/ожидающих КА  
		ALLink		*	queue;		// Указатель на очередь где стоит КА
struct	Fsa_s		*	yqueue;		// Очередь действий
struct	GroupInfo_s	*	grp;		// Группа FSA
		ALLink			node;		// Список всех КА в системе 
		tId				id;			// Идентификатор процесса
		tPri			pri;		// Приоритет
		tState			gstate;		// Состояние процесса
		tState			state;		// Состояние
 		tFsaTblPtr     	table;		// Указатель на таблицу состояний
const 	tLS			*	tptr;		// Указатель на текущую строку
		void		*	args;		// Аргументы процесса
		tError			error;		// флаги ошибок
struct 	Fsa_s		*	called;		// Кто вызвал этот fsa
		OSMesg		*	msg;		// Сообщение вызваашее блокировку
} tFsa;

void osCreateFsa(tFsa * fsa, tId id, tFsaTblPtr table, void * args, tPri pri);
void osDestroyFsa(tFsa * fsa);
void osStartFsa(tFsa * fsa);
void osStopFsa(tFsa * fsa);
tId	 osGetFsaId(tFsa * fsa);
void osSetFsaPri(tFsa * fsa, tPri pri);
tPri osGetFsaPri(tFsa * fsa);
bool osCallFsa(tFsa * fsa, void * args, Int16 flag);

/*******************************************************
* OS and Groups
*******************************************************/

typedef struct GroupInfo_s
{
	ALLink		grpList;	// Очередь групп 
	ALLink		runList;	// Очередь FSA группы
	tPri		pri;		// Приоритет группы
} tGroupInfo;

typedef enum {
   OS_STATE_UNINITIALIZED=0,// Не инициализирована
   OS_STATE_INITIALIZED,    // Инициализирована
   OS_STATE_RUNNING         // В работе
} OpSysState;

typedef struct OpSysInfo_s {
	UInt16		osState;	// Состояние системы	
	ALLink		fsaList;	// Очередь всех КА в системе 
	ALLink		grpList;	// Очередь групп FSA по приоритетам
	tFsa      *	yList;		// Очередь Y
	tPri		curPri;		// Текущий приоритет 
	tFsa      * curFsa;		// Текущий КА 
	tGroupInfo* curGroup;	// Текущая группа
} tOpSysInfo;

void osRun( UInt16	todo );
void osInitialize( void );
void osCreateGroup( tGroupInfo * grp, tPri pri );

/*******************************************************
* Messages Interface
*******************************************************/

#define OS_MESG_NO_BLOCK	0
#define OS_MESG_BLOCK		1

							// ОЧЕРЕДЬ СООБЩЕНИЙ
typedef struct OSMesgQueue_s {
struct 	Fsa_s	*	waitrd;	// Очередь ожидающих чтение
struct 	Fsa_s	*	waitwr;	// Очередь ожидающих запись
	Int16	 validCount;	// число валидных чообщений в очереди
	Int16	 first;			// индекс первого валидного сообщения
	Int16	 msgCount;		// Сколько сообщений может принять очередь
	OSMesg	*msg;			// Указатель на буфер очереди
} OSMesgQueue;

void  osCreateMesgQueue(OSMesgQueue *mq, OSMesg *msg, Int16 count);
bool  osSendMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag);
bool  osJamMesg(OSMesgQueue *mq, OSMesg msg, Int16 flag);
bool  osRecvMesg(OSMesgQueue *mq, OSMesg *msg, Int16 flag);
void  osSetEventMesg(OSEvent e, OSMesgQueue *mq, OSMesg m);


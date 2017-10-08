#include "port.h"
#include "fsa.h"

/*******************************************************
* Тестирование
*******************************************************/
/*******************************************************
* Моделируем ИНЕ
*******************************************************/

typedef struct Ine_s
{
	tFsa	fsa;						// КА
	bool *	inpA;						// вход 1
	tFsa * 	inpB;						// вход 2
} tIne;
										// Предикаты
static bool inex1(tIne * obj){ return   *obj->inpA; }
static bool inex2(tIne * obj){ return ((*obj->inpB).state == 'S1'); }
static bool inex3(tIne * obj){ return ((*obj->inpB).state == 'S0'); }

const tFsaTbl	IneTBL = 
{
	{&inex1,&inex2,&inex3},				// предикаты
	{},									// действия
	{
	LS('S1', 'S0',  x1|x2, 	0),			// строки состояния
	LS('S0', 'S1',  nx1,	0),
	LS('S0', 'S1',  x3,	    0),
	ES
	}
};
										// КОНСТРУКТОР
CreateIne( tIne * obj, bool * pin1, tFsa * pin2 )
{
	osCreateFsa((tFsa*) obj, '&N', &IneTBL, NULL, DEFAULT_PRI );
	obj->inpA = pin1;
	obj->inpB = pin2; 
}

/*******************************************************
* Моделируем Тригер
*******************************************************/

typedef struct RS_s
{
	tIne  ine1;						// Элемент ИНЕ 1
	tIne  ine2;						// Элемент ИНЕ 2
} tRS;

CreateRS( tRS * obj, bool * r, bool * s )
{
	obj->ine1.inpA = r;				// Вход Reset
	obj->ine2.inpA = s;				// Вход Set
	obj->ine1.inpB = &obj->ine2;	// перекрёстная связь
	obj->ine2.inpB = &obj->ine1;	// перекрёстная связь
}

/*******************************************************
* Тестовая програма
*******************************************************/

tFsaQueue   fsaQ;

main ()
{
	bool	r,s;					// Входы тригера
	tRS		trs;					// Тригер
	
	CreateSheduler(&fsaQ);			// Создадим очередь КА
	SetActiveQueue(&fsaQ);			// Она активная

	CreateRS(&trs,&r,&s);			// Создадим тригер

	r = s = false;					// rs = 00	
	FsaSheduler(1000);				// Выполним очередь 1000 раз

	r = s = true;					// rs = 11	
	FsaSheduler(1000);				// Выполним очередь 1000 раз		
}
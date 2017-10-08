#include "port.h"
#include "fsa.h"

/*******************************************************
* ������������
*******************************************************/
/*******************************************************
* ���������� ���
*******************************************************/

typedef struct Ine_s
{
	tFsa	fsa;						// ��
	bool *	inpA;						// ���� 1
	tFsa * 	inpB;						// ���� 2
} tIne;
										// ���������
static bool inex1(tIne * obj){ return   *obj->inpA; }
static bool inex2(tIne * obj){ return ((*obj->inpB).state == 'S1'); }
static bool inex3(tIne * obj){ return ((*obj->inpB).state == 'S0'); }

const tFsaTbl	IneTBL = 
{
	{&inex1,&inex2,&inex3},				// ���������
	{},									// ��������
	{
	LS('S1', 'S0',  x1|x2, 	0),			// ������ ���������
	LS('S0', 'S1',  nx1,	0),
	LS('S0', 'S1',  x3,	    0),
	ES
	}
};
										// �����������
CreateIne( tIne * obj, bool * pin1, tFsa * pin2 )
{
	osCreateFsa((tFsa*) obj, '&N', &IneTBL, NULL, DEFAULT_PRI );
	obj->inpA = pin1;
	obj->inpB = pin2; 
}

/*******************************************************
* ���������� ������
*******************************************************/

typedef struct RS_s
{
	tIne  ine1;						// ������� ��� 1
	tIne  ine2;						// ������� ��� 2
} tRS;

CreateRS( tRS * obj, bool * r, bool * s )
{
	obj->ine1.inpA = r;				// ���� Reset
	obj->ine2.inpA = s;				// ���� Set
	obj->ine1.inpB = &obj->ine2;	// ����������� �����
	obj->ine2.inpB = &obj->ine1;	// ����������� �����
}

/*******************************************************
* �������� ��������
*******************************************************/

tFsaQueue   fsaQ;

main ()
{
	bool	r,s;					// ����� �������
	tRS		trs;					// ������
	
	CreateSheduler(&fsaQ);			// �������� ������� ��
	SetActiveQueue(&fsaQ);			// ��� ��������

	CreateRS(&trs,&r,&s);			// �������� ������

	r = s = false;					// rs = 00	
	FsaSheduler(1000);				// �������� ������� 1000 ���

	r = s = true;					// rs = 11	
	FsaSheduler(1000);				// �������� ������� 1000 ���		
}
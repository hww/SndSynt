#include "port.h"
#include "sdramdrv.h"
#include "mem.h"
#include "fcntl.h"
#include "fileio.h"
#include "io.h"

#define DELAY } asm { nop }; asm { nop }; asm {
#define FDELAY } asm { nop }; asm { nop }; asm {

#define SMART_DMA		// DMA не грузит блок если он в памяти

#ifdef SMART_DMA
static UInt16 last_addressl;
static UInt16 last_addressh;
static UInt16 last_size;
static UInt16 sucess;
#endif

/*****************************************************************************
*
* ИНИЦИАЛИЗАЦИЯ SDRAM
*
*****************************************************************************/

Int16 sdram_init(void)
{
asm	{ 
		CMD_GET_DATA(y0)
		DELAY
		CMD_PRECHARGE_ALL	
		DELAY
		CMD_AUTO_RFSH		
		DELAY
		CMD_AUTO_RFSH		
		DELAY
		CMD_SET_MODE		
		DELAY
		CMD_SELF_RFSH
	}
#ifdef SMART_DMA	
	sucess = 0;
#endif
}

/*****************************************************************************
*
* ФУНКЦИИ ЧТЕНИЯ ИЗ ПАМЯТИ
*
*****************************************************************************/

Int16 sdram_read16( UInt32 addr )
{
asm	{
		CMD_PRECHARGE_ALL
		CMD_ACTIVE(a0)
		CMD_RDCOLAP(a1)
		DELAY
		CMD_GET_DATA(y0)
		CMD_SELF_RFSH
	}
}

Int32 sdram_read32( UInt32 addr )
{
asm	{
		CMD_PRECHARGE_ALL
		CMD_ACTIVE(a0)
		CMD_RDCOL(a1)
		DELAY
		CMD_GET_DATA(a0)
		CMD_RDCOLAP(a1)
		DELAY
		CMD_GET_DATA(a1)
		CMD_SELF_RFSH
	}
}

/*****************************************************************************
*
* ПРОЦЕДУРЫ ЗАПИСИ В ПАМЯТЬ
*
*****************************************************************************/

void sdram_write16( UInt32 addr, Int16 data )
{
asm	{
		CMD_PRECHARGE_ALL
		CMD_ACTIVE(a0)
		CMD_WRCOLAP(a1)
		CMD_SET_DATA(y0)
		CMD_SELF_RFSH
	}
}

void sdram_write32( UInt32 addr, Int32 data )
{
asm	{
		move	data,b0
		move	data+1,b1
		CMD_PRECHARGE_ALL
		CMD_ACTIVE(a0)
		CMD_WRCOL(a1)
		CMD_SET_DATA(b0)
		CMD_WRCOLAP(a1)
		CMD_SET_DATA(b1)
		CMD_SELF_RFSH
	}
}

/*****************************************************************************
*
* ПРОЦЕДУРЫ КОПИРОВАНИЯ БЛОКОВ
*
*****************************************************************************/

UInt32 sdram_load( UInt32 addr, UWord16 * src, size_t size )
{
	do
	{
		sdram_write16( addr++, *src++ );
		size--;
	} while(size>0);
	
	return addr;
}

UInt32 sdram_save( UInt32 addr, UWord16 * dst, size_t size )
{
	do
	{
		*dst++ = sdram_read16( addr++ );
		size--;
	} while(size>0);

	return addr;
}

/*****************************************************************************
*
*	ПРОЦЕДУРЫ НЕОБХОДИМЫЕ ДЛЯ СЕМПЛЕРА
*
*	void sdram_load_64( UInt32 addr, UWord16 * dst, size_t size )
*
* 	Прочитывает блок из SDRAM в память
* 	
*		A		addr	Адрес источника
*		R2		dst		Адрес кеш области
*		Y0		size	Размер измеряется 64 битных записях
*
*****************************************************************************/

void sdram_load_64( UInt32 addr, UWord16 * dst, size_t size )
{
	asm
	{
		move	y0,x0
		move	#4,y0
		clr		y1
#ifdef SMART_DMA
		move	last_addressh,b
		move	last_addressl,b0
		cmp		a,b
		bne		newest
		cmp		last_size,x0
		bne		newest
		inc		sucess;
		rts
newest:
		move	a0,last_addressl
		move	a1,last_addressh
		move	x0,last_size			
#endif
		CMD_PRECHARGE_ALL
		
		tstw    x0
		beq     EndDo
		do      x0,EndDo
		
		CMD_ACTIVE(a0)
		CMD_RDCOL(a1)
		DELAY
		CMD_GET_DATA(x0)
		CMD_RDCOL(a1)
		move	x0,X:(r2)+
		FDELAY
		CMD_GET_DATA(x0)
		CMD_RDCOL(a1)
		move	x0,X:(r2)+
		FDELAY
		CMD_GET_DATA(x0)
		CMD_RDCOLAP(a1)
		move	x0,X:(r2)+
		FDELAY
		CMD_GET_DATA(x0)
		move	x0,X:(r2)+
		add		y,a
EndDo:		
		CMD_SELF_RFSH
	};
}

/*****************************************************************************
*
* ЗАГРУЗКА ФАЙЛА В SDRAM
*
*	int sdram_load_file( int Fd, UInt32 addr, UInt32 nWords )
*
*	Fd		дескриптор файла
*	addr	адрес назначения в SDRAM
*	nWords	количество слов для копирования
*
*****************************************************************************/

#define COPY_BUFFER_SIZE 0x7F

int sdram_load_file( int Fd, UInt32 addr, UInt32 nWords )
{

size_t   words;
UWord16 *copybuf;

	copybuf = (UWord16*)malloc(COPY_BUFFER_SIZE);	// Запросим память на буфер COPY
	if(copybuf == 0) return 0;						// Ошибка
	
	words = COPY_BUFFER_SIZE;						// Блоками по длине буфера копированния
	
	do
	{
		if(nWords < COPY_BUFFER_SIZE)				// Осталось слов меньше буфера
		{
			words=nWords;							// Значит блок такой сколько осталось
		}
		read(Fd,copybuf, words );					// прочитали блок
		addr = sdram_load( addr, copybuf, words );	// Переписали в SDRAM
		nWords-=words;								// Уменьшили счётчик
	} while(nWords>0);								// Если 0 то ВСЁ!
	
	free(copybuf);									// Освободим память
	return 1;
}
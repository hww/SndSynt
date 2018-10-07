#include "port.h"
#include "sdramdrv.h"
#include "mem.h"
#include "fcntl.h"
#include "fileio.h"
#include "io.h"

#define DELAY } asm { nop }; asm { nop }; asm {
#define FDELAY } asm { nop }; asm { nop }; asm {

#define SMART_DMA		// DMA skip block if it is already in memory

#ifdef SMART_DMA
static UInt16 last_addressl;
static UInt16 last_addressh;
static UInt16 last_size;
static UInt16 sucess;
#endif

/*****************************************************************************
*
* Initialize SDRAM
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
* Memory read
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
* Memory write
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
* Copy blocks in memory
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
*	Routines for sampler
*
*	void sdram_load_64( UInt32 addr, UWord16 * dst, size_t size )
*
* 	Read block to SDRAM 
* 	
*		A		addr	source
*		R2		dst		destination (cache) address
*		Y0		size	size in 64 bits words
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
* Load file to SDRAM
*
*	int sdram_load_file( int Fd, UInt32 addr, UInt32 nWords )
*
*	Fd		file descriptor
*	addr	target address SDRAM
*	nWords	words count
*
*****************************************************************************/

#define COPY_BUFFER_SIZE 0x7F

int sdram_load_file( int Fd, UInt32 addr, UInt32 nWords )
{

size_t   words;
UWord16 *copybuf;

	copybuf = (UWord16*)malloc(COPY_BUFFER_SIZE);	
	if(copybuf == 0) return 0;						
	
	words = COPY_BUFFER_SIZE;						
	
	do
	{
		if(nWords < COPY_BUFFER_SIZE)				
		{
			words=nWords;							
		}
		read(Fd,copybuf, words );					
		addr = sdram_load( addr, copybuf, words );	
		nWords-=words;								
	} while(nWords>0);								
	
	free(copybuf);									
	return 1;
}
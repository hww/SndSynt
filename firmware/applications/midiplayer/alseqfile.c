#include "port.h"
#include "audiolib.h"
#include "mem.h"
#include "fcntl.h"
#include "fileio.h"
#include "io.h"
#include "sdram.h"

/*****************************************************************************
 *
 * 	Read SDRAM
 *
 *	unsigned char alSeqGet8(  UWord32 * addr )
 *	      UWord16 alSeqGet16( UWord32 * addr )
 *	      UWord32 alSeqGet16( UWord32 * addr )
 *
 *	addr		address in DRAMM
 *
 *	pointer increments by size of data
 *
 *****************************************************************************/

unsigned char alSeqGet8( UWord32 * addr )
{
	return sdram_read16( (*addr)++ ) & 0xFF; 
}

UWord16 alSeqGet16( UWord32 * addr )
{
UWord16 word;

	word  = (sdram_read16( (*addr)++ )<<8); 
	word +=	(sdram_read16( (*addr)++ ) & 0xFF);
	return word;
}

UWord32 alSeqGet32( UWord32 * addr )
{
UWord32 dword;
	dword  = ((UWord32)alSeqGet16( addr )<<16);
	dword += alSeqGet16( addr );
	return dword;
}

/*****************************************************************************
 *
 * Load MIDI file to SDRAM
 *
 *	UWord32 alSeqFileLoad( char * name, UInt32 addr )
 *
 *	name		file name
 *	addr		address in SDRAM
 *
 *	return file size in words (16 bits)
 *
 *****************************************************************************/

void    alSeqFileNew(ALSeqFile *f, Ptr32 base, UInt16 fnum )
{
int t;
UWord32 addr = base;

    f->revision = alSeqGet16( &addr );        /* format revision of this file         */
    f->seqCount = alSeqGet16( &addr );        /* number of sequences                  */

	if((f->revision == 0x5331) && (f->seqCount>fnum))
	{
		addr+=(fnum<<3); 									 

	   	f->seqArray[0].offset = alSeqGet32( &addr ) + base;  
	   	f->seqArray[0].len 	  = alSeqGet32( &addr );  		 
	}
	else
	{	f->seqArray[0].offset = 0xFFFFFFFF;  	
	}
}

/*****************************************************************************
 *
 * Load MIDI file to SDRAM
 *
 *	UWord32 alSeqFileLoad( char * name, UInt32 addr )
 *
 *	name		file name
 *	addr		address in SDRAM
 *
 *	return file size in words (16 bits)
 *
 *****************************************************************************/

UWord32 alSeqFileLoad( char * name, UInt32 addr )
{
	int Fd;
	UInt32 fsize;

	Fd = open(name, O_RDONLY);
	if(Fd == 0) return 0;

	ioctl(Fd, FILE_IO_GET_SIZE, fsize );

	if(fsize==0) return 0;

	ioctl(Fd, FILE_IO_DATAFORMAT_EIGHTBITCHARS,NULL); 
	
	sdram_load_file( Fd, addr, fsize );

	close(Fd);
	return fsize;
}
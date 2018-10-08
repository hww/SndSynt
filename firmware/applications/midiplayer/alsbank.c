#include "port.h"
#include "audiolib.h"
#include "mem.h"
#include "fcntl.h"
#include "fileio.h"
#include "io.h"
#include "sdram.h"

static UWord16 ctl_org;
static UWord32 tbl_org;
static void snd_idx_wave( ALWaveTable* Wave );
static void snd_idx_sound( ALSound* Sound );
static void snd_idx_inst( ALInstrument* Inst  );
static void snd_idx_bank( ALBank *bank );

/*****************************************************************************
 *
 * Wave form indexing
 *
 *****************************************************************************/

void snd_idx_wave( ALWaveTable* Wave )
{
UWord16 *ptr;
	if(( Wave->flags & AL_INDEXED) == 0)
	{	Wave->base>>=1;							// байты в слова
		Wave->len>>=1;							// байты в слова
		Wave->flags |= AL_INDEXED;
	}
}

/*****************************************************************************
 *
 * Sound indexing
 *
 *****************************************************************************/

void snd_idx_sound( ALSound* Sound )
{
	UWord16 *ptr;
	int	n;
	
	if(( Sound->flags & AL_INDEXED) == 0)
	{	
		Sound->sampleVolume = INT2FRAC(Sound->sampleVolume);
		ptr = (UWord16*)Sound;	
		for(n = 0; n < 4 ; n++)
		{
			if(*ptr != NULL) *ptr +=ctl_org;  	// Индексировали указатели
			ptr++; 
		}
		snd_idx_wave( Sound->wavetable );	// Индексировали волну	
		Sound->flags |= AL_INDEXED;
	}
}

/*****************************************************************************
 *
 * Itrument indexing
 *
 *****************************************************************************/

void snd_idx_inst( ALInstrument* Inst  )
{
	UWord16 *ptr;
	size_t   nSound = (size_t)Inst->soundCount;

	ptr = (UWord16*)Inst->soundArray;	

	if((Inst->flags & AL_INDEXED) == 0)			
	{	// Если ещё не проиндексировали
		Inst->volume = INT2FRAC(Inst->volume);
		while (nSound != 0)
		{	(*ptr)+=ctl_org;				// индексировали указатель
			snd_idx_sound( (ALSound*)*ptr); // Индексировали звук		
			ptr++;
			nSound--;						// До 0
		} 
		Inst->flags |= AL_INDEXED;
	}
}

/*****************************************************************************
 *
 * nexig sund bank
 *
 *****************************************************************************/

void snd_idx_bank( ALBank *bank )
{
	UWord16 *ptr;
	size_t   nInst = (size_t)bank->instCount;

	if((bank->flags & AL_INDEXED) == 0)			
	{	// Если ещё не проиндексировали
		ptr = (UWord16*)&bank->percussion;	
		if(*ptr !=0 ) nInst++;						// На один инструмент перкуссии больше
		else ptr++;									// Или тперкуссии НЕТ!
		while (nInst != 0)
		{	if(*ptr!=NULL)
			{	*ptr += ctl_org;					// Индексировали указатель
				snd_idx_inst((ALInstrument*) *ptr); // Индексировали инструмент		
			}
			ptr++;
			nInst--;								// До 0
		} 
		bank->flags |= AL_INDEXED;
	}
}

/*****************************************************************************
 *
 * Idexng sound ank
 *
 *****************************************************************************/

void alBnkfNew(ALBankFile *ctl, Ptr32 tbl)
{
	UWord16 *ptr;
	size_t   nBanks = (size_t)ctl->bankCount;
	
	ctl_org = (UWord16)ctl;
	tbl_org = (UWord32)tbl;
	
	if( nBanks > 0)
	{
		ptr = (UWord16*)ctl->bankArray;	

		do
		{
			*ptr=*ptr+ctl_org;				// индексировали указатель
			snd_idx_bank( (ALBank*)*ptr );	// Индексировали банк		
			ptr++;							// Следующий банк
			nBanks--;						// До 0
		} while (nBanks != 0);
	}
}

/*****************************************************************************
 *
 * Lod sound bank
 *
 *****************************************************************************/

UWord32 snd_load_bank( char * name, ALBankFile ** ctl, UInt32 addr )
{
	int 	     Fd;
	UWord32      fsize;
	size_t       words;

	Fd = open(name, O_RDONLY);
	if(Fd == 0) return 0;

	ioctl(Fd, FILE_IO_GET_SIZE, fsize );

	words=fsize>>1;
		
	ioctl(Fd, FILE_IO_DATAFORMAT_RAW,NULL); 
	
	if(words>0)
	{
		*ctl = malloc( words );
		read(Fd,*ctl, words ); // Read file
		sdram_load( addr, (UInt16*)*ctl, words );
	}
	close(Fd);
	
	return words;
}

/*****************************************************************************
 *
 * Loading samples
 *
 *	UWord32 snd_load_tbl( char * name, UInt32 addr )
 *
 *	name 		file name
 *	addr			target address
 *	
 *	return size of file
 *
 *****************************************************************************/

UWord32 snd_load_tbl( char * name, UInt32 addr )
{
	int Fd;
	UInt32 nWords, fsize;

	Fd = open(name, O_RDONLY);
	if(Fd == 0) return 0;

	ioctl(Fd, FILE_IO_GET_SIZE, fsize );
	
 	nWords = fsize>>1;

	if(nWords==0) return 0;

	ioctl(Fd, FILE_IO_DATAFORMAT_RAW,NULL); 
	
	sdram_load_file( Fd, addr, nWords );

	close(Fd);
	return nWords;
}
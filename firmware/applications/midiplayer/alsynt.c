#include "port.h"
#include "size_t.h"
#include "sdram.h"
#include "mem.h"
#include "fcodec.h"
#include "bsp.h"	
//#include "time.h"
#include "stdio.h"
#include "assert.h"
#include "audiolib.h"
#include "test.h"

static void alSynMixVoice( PVoice* v, UInt32* dst, size_t todo );
static void alSynRenderVoice( PVoice* v, size_t todo );
static void alSynMix32To16(UInt16 *dste, UInt32 *srce, size_t todo);
static void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo);
static void alSynPanSlide(ALSynth * s);
static void alSynMixPanGain(PVoice *pv);

static Int32 volTable[VOL_BUF_SIZE+1];	// Volumes tables 
static Int32 panTable[VOL_BUF_SIZE+1];	// Volume conversion table
UInt16 *cash_1;							// Cache of first level
UInt16 *cash_2;							// Cache of second level

/******************************************************************************
* Common macro definitions
*******************************************************************************/

#ifndef MIN
#define MIN(a,b) (((a)<(b))?(a):(b))
#endif

#ifndef MAX
#define MAX(a,b) (((a)>(b))?(a):(b))
#endif

#ifndef WORDS2SAMPLES
#define WORDS2SAMPLES(words) (words>>1)
#endif

#ifndef SAMPLES2WORDS
#define SAMPLES2WORDS(samples) (samples<<1)
#endif

/*****************************************************************************
* API to machine code
******************************************************************************/

#define v(x) X:(r3+PVoice.x)
#define PITCHF v(pitch)
#define PITCHI v(pitch+1)
#define FPOS   v(fpos)
#define POSL   v(pos)
#define POSH   v(pos+1)
#define ENDL   v(end)
#define ENDH   v(end+1)
#define CVOLL  v(curVolume)
#define CVOLH  v(curVolume+1)
#define DVOLL  v(addVolume)
#define DVOLH  v(addVolume+1)
#define TVOLL  v(tgtVolume)
#define TVOLH  v(tgtVolume+1)
#define RVOL   v(rvol)
#define LVOL   v(lvol)
#define PHASE  v(phaseVolume)

#define s(x) X:(r0+ALSynth.x)
#define CASH_1 cash_1
#define CASH_2 cash_2

/******************************************************************************
* 	Mix rendered sample to right channel of MIX
*
* 	Count address difference
*	r1 = target
*	r2 = source
*	x0 = size
*	y0 = left volume
*	y1 = right volume
*******************************************************************************/
void alSynMakeVolumes( PVoice * v );
void alSynMakeVolumes( PVoice * v )
{
	asm
	{	move	v,r3    				// r3  	= voice
		move	#volTable,r2			// r2	= dst
		move	#VOL_BUF_SIZE+1,x0		// x0 	= todo
		move	#2,N
		move	CVOLH,a					// A 	= curVolume
		move	CVOLL,a0
		move	TVOLH,b					// B 	= targetVolume
		move	TVOLL,b0		
		move	DVOLH,y1				// Y 	= deltaVolume
		move	DVOLL,y0		
		tstw	y1
		bgt		isplus					// Y 	positive
		blt		isminus
iszero:	//********************************************************
		do		x0,zeroend				// Y	negative
		move	a,X:(r2+1)				// *dst++ = curVolume
		move	a0,X:(r2)+N				
zeroend:
		jmp		plsend				

isminus://********************************************************
		do		x0,minend				// Y	negative
		move	a,X:(r2+1)				// *dst++ = curVolume
		move	a0,X:(r2)+N				
		add		y,a						// curVolume+=deltaVolume
		cmp		b,a						// if(a<b) 
		tlt		b,a						// 		a=b
minend:	
		jmp		plsend				
		
isplus:	//********************************************************
		do		x0,plsend				 
		move	a,X:(r2+1)				// *dst++ = curVolume
		move	a0,X:(r2)+N
		add		y,a						// curVolume+=deltaVolume
		cmp		a,b						// if(a>b)
		tlt		b,a						// 		a=b
plsend:
		move	#volTable+1,r2			// r2	= src
		move	#panTable,r1			// r1	= dst
		move	RVOL,y1					// 7FFF = rightchannel
		move	LVOL,y0
		move	#VOL_BUF_SIZE+1,x0		// x0 	= todo
		do		x0,panend
		move	X:(r2)+N,x0
		mpyr	y0,x0,a
		mpyr	y1,x0,b
		move	b,X:(r1+1)
		move	a,X:(r1)+N
panend:
	}
}

/******************************************************************************
*
* void alSynMixVoice( PVoice* v, UInt32* dst, size_t todo )
*
*	Mix single voice to the buffer
*
*	s		synthesizer
*	v		poly-channel
*	dst		target
*	todo	size
*
* 	cash_2 	source of data
*
*******************************************************************************/
//						R2		  R3			    Y0
void alSynMixVoice( PVoice* v, UInt32* dst, size_t todo )
{
	asm
	{
		move	#2,N					
		move	#0xFFFF,M01				// MODULO OFF
		move	v,r3    				// r3  = voice
		move	todo,y0					// y0  = todo 
		move	PHASE,y1				// y1  = phase 
		move	#panTable,r0			// r0  = pantable
		move	#volTable,r1			// r1  = voltable
		move	CASH_2,r2				// r2  = src	
		move	dst,r3					// r3  = dest
		tstw	y1
		beq		phase0
loop:
		cmp		y0,y1
		bgt		bigY1
		move	y1,x0
		bra		min
bigY1:
		move	y0,x0
min:
		sub		x0,y1
		sub		x0,y0
		move	y1,a1
		move	y0,a0
		move	X:(r0+1),y1				// y1  = right volume
		move	X:(r0),y0				// y0  = left volume
		do		x0,Exit					// no! mix bought channels
		move	X:(r2)+,x0				// x0  = (sample)*LEV2ptr++
		move	X:(r3+1),b			
		move	X:(r3),b0				// b   = (s32sample)*dest
		mac 	x0,y0,b					// b  += (sample * leftvol)
		move	b,X:(r3+1)	
		move	b0,X:(r3)+n				
		move	X:(r3+1),b				// b   = (s32sample)*dest
		move	X:(r3),b0				// *dest++ = b				
		mac		x0,y1,b					// b  += (sample * rightvol)
		move	b,X:(r3+1)
		move	b0,X:(r3)+n				// *dest++ = b
Exit:	
		move	a0,y0
		move	a1,y1
		tstw	y1
		bne		bigphase				// фаза > 0
phase0:
		move	#32,y1
		lea		(r0)+N					// pptr++
		lea		(r1)+N					// vptr++
bigphase:		
		tstw	y0						// if(todo>0)
		bgt		loop					//		goto loop;
		move	v,r3
		move	y1,PHASE
		move	X:(r1+1),y1
		move	X:(r1),y0
		move	y1,CVOLH
		move	y0,CVOLL
	}
}

/******************************************************************************
*
* void alSynRenderVoice( PVoice* v, size_t todo )
*
*	Render sample
*
*	v		poly channel
*	dst		target
*	todo	size
*
* 	cash_1 	load from SDRAM
*	cash_2	for sample rendering 
*
*******************************************************************************/

void alSynRenderVoice( PVoice* v, size_t todo )
{
	UInt16 rendfpos;
	UInt16 framepos;
	asm
	{
	/*
	 * 	Read to cache 
	 */
		move	v,r3    				// r3  = voice
										// work + (U32)((U32)pith * (Int16)todo)
		move	todo,x0					// 		x0  = todo
		move	PITCHF,y0				//
		move	PITCHI,y1				// 		y   = pitch
		mpysu	y0,x0,b					// 		b   = pitch.fr * todo
		asr		b						// 		b   = fract2int(b)
		impy	y1,x0,y1				// 		y1  = pitch.int * todo 
		add		y1,b					// 		b   = (U32)pitch * (U16)todo
										//**********************************
										// На сколько сместится целая часть счётчика
										// work+=pos & 0x3ffff
		move	FPOS,y0					// 		y0  = pos.fr
		move	POSL,y1					// 		y1  = pos.int
		andc	#3,y1					// 		y  &= 3FFFF	
		move	y0,rendfpos				// 		rendfpos = pos.fr
		move	y1,framepos				// 		framepos = pos.int & 3
		add		y,b						// 		b  += pos & 0x3FFFF
		move	b0,FPOS					// fpos = (U16)(work & 0xFFFF)
										// pos  = (pos & 0xFFFFFFFC) + (work>>16)
		move	b1,y0					// y0   = sampleswork
		move	b1,b0					//		b  = work>>=16
		clr		b1						
		move	POSH,a1					// 		a   = pos 
		move	POSL,a0					// 
		andc	#$FFFC,a0				// 		a &= 0xFFFFFFFC
		add		a,b						//		b += a 
		move	b0,POSL					// 		pos = b
		move	b1,POSH
										//*********************************
										// Count size of cached words
		move	#2,x0					// x2
		asrr	y0,x0,y0				// integer shift / 4
		inc		y0						// y0  = blocks count
		inc		y0
		move	CASH_1,r2				// r2  = cache start
		jsr		sdram_load_64			// Load block
	   /*
		*	Interpolate block in the cache
		*/
		move	CASH_1,y0				// y0  = sart of cache
		add		framepos,y0				// y0  = pos.int + CASH_1
		move	y0,r2					// r2  = level_1
		move	CASH_2,r1				// r4  = level_2
		move	rendfpos,y1				// y1  = pos.fr
		move	PITCHF,y0				// y0  = increment.fr
		move	PITCHI,N				// N   = increment.int
		move	todo,x0
		do		x0,interpolation		
		move	X:(r2),x0				// x0  = (sample)(*level_1)
		not		y1						// y1  = NOT(index.fr)
		mpysu	x0,y1,b					// b   = (S16)sample * NOT(index.fr)
		move	X:(r2+1),x0				// x0  = (sample)(*(level_1+1)) 
		not		y1						// y1  = NOT(index.fr)
		macsu	x0,y1,b					// b  += (S16)sample * index.fr
		asr		b
		rnd		b
		lea		(r2)+n					// level_1+=increment.int
		add		y0,y1					// a1 += increment.fr
		bcc		NoC						// if(CARY SET)
		lea		(r2)+					// level_1++
NoC:	move 	b,X:(r1)+				// *level_2++ = b	
interpolation:								
	}
}

/******************************************************************************
*
*	Convert 32 bits data to 16 bits
*
*******************************************************************************/
//                          R2            R3           Y0
void alSynMix32To16(UInt16 *dste, UInt32 *srce, size_t todo)
{
	asm{
			move	#2,n
			do		y0,EndDo
			move	X:(r3+1),a				// a = (sample32)(r3)		
			move	X:(r3)+n,a0				// r3 to next sample
			rnd		a						// round sample
			move	a,X:(R2)+				// *dst++=saturate(a)
			move	X:(r3+1),a
			move	X:(r3)+n,a0
			rnd		a
			move	a,X:(R2)+
EndDo:
	}
}

#include "mfr16.h"

/******************************************************************************
*
*	void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo)
*
*	Render single channel
*
*	s		synthesizer
*	v		voice
*	dst		input buffer
*	todo	size in samples
*
*   Could require several attempts. For example in case if there are less samples
*   to the end of sample than todo samples. It will process existing then jump
*   to the loop point
*
*******************************************************************************/

void alSynAddChannel(ALSynth* s, PVoice* pv, stereo32* dst, size_t todo)
{
    UInt32  end;
    UInt16	done;
    UInt32  estimate;

    while(todo > 0)
    {   
    	// обновить 'current' позицию учитывая зацикливание, или
        // остановить воспроизведение если достигли конца семпла

		if(((pv->pos == pv->end) && (pv->fpos>0)) || (pv->pos > pv->end))
		//if(pv->pos >= pv->end)
		{	// воспроизведение вперёд и текущая
			// позиция достигла конца
        	if((((ALVoice*)pv->vvoice)->state & AL_SF_LOOP) != 0) 
        	{	// семпл зациклен
        		pv->pos -= pv->endsub;
           	}
           	else
           	{	// семпл не зациклен
               	// остановим воспроизведение
				alSynStopVoice(s, (ALVoice*)pv->vvoice);
				//((ALVoice*)pv->vvoice)->state &= (~AL_SF_ACTIVE & ~AL_SF_ALOCATED);
				return;      
			}
       	} 
       	
		estimate = (((pv->end - pv->pos)<<16) - (UInt32)(UInt16)pv->fpos)  / pv->pitch + 1;        
		done = MIN(estimate, todo);

        if(done==0)
        {	alSynStopVoice(s, (ALVoice*)pv->vvoice);
        	return;
        }

	    alSynRenderVoice( pv, done );
	    alSynMakeVolumes( pv );
		alSynMixVoice( pv, dst, done );

		if(pv->addVolume != 0)						// Если стремимся к громкости
		{	if(pv->tgtVolume == pv->curVolume)
			{ 	pv->addVolume = 0;
				((ALVoice*)pv->vvoice)->state |= AL_SF_TARGET;
			}
		}
		
        todo -= done;
        dst  += done;		// Так как dst указатель на 4 слова
        					// +done выглядит реально как +done<<2
    }
	return;
}

/******************************************************************************
*
*	void alAudioFrame(ALSynth* s, stereo16 *outBuf, size_t samples)
*
*	ГЕНЕРАЦИЯ БУФЕРА
*
*	s		синтезатор
*	outBuf	выходной буфер
*	samples	количество семплов
*
*	Переменная todo в количествах семплов на один канал. Генерирует целый буфер
*	размером todo. Нарезает его на фрагменты необходимые для секвенсора. 
*	Например если для секвенсора необходимо N семплов то программа генерирует
*	ch1[1..N], ch2[1..N], ... , chN[N]. Затем генерирует M семплов, где 
*	M = todo-N. После генерации всего буфера программа генерирует спецэффекты.
*
*******************************************************************************/

void alAudioFrame(ALSynth* s, stereo16 *outBuf, size_t samples)
{
    UWord16   left, portion = 0, count;
    void     *dst;
    Int16     t;
	PVoice   *pv,*nextpv;
	ALMicroTime time;
	UWord16   fxoutptr;
	
    while(samples>0)
    {   // Вызов плеера и инициализация таймера секвенсора
    	if(s->samplesLeft==0)
        {   if(s->handler!=NULL)
        	{	 s->callTime	= s->handler((ALSeqPlayer*) s->clientData);
				 s->samplesLeft = (Int32)(s->callTime * 100)/((Int32)100000000 /MIXFREQ);
        	}
        	else s->samplesLeft = samples;
        }
        /*
		 * наименьшее из двух, заказанный блок или интервал SEQ-таймера
         */
        left = MIN(s->samplesLeft, samples);
        
        dst	    		= outBuf;
        s->samplesLeft -= left;
        samples    	   -= left;

        outBuf = (void*)((UWord16)outBuf + SAMPLES2WORDS(left));

        while(left>0)
        {  	portion = MIN(left, MIX_BUF_SIZE);

			/* 
			 *	Обнулили слов в количестве = семплов * 4
			 * 	Из за стерео и 32 х битного разрмера
             */
            memset(s->mix_buf, 0, portion<<2);

			pv = (PVoice*)s->pAllocList.next;            	
         	while( pv != NULL)
           	{   nextpv=(PVoice*)pv->node.next;
           		if((((ALVoice*)pv->vvoice)->state & AL_SF_ACTIVE) != 0)
                {   alSynAddChannel(s, pv, s->mix_buf, portion);
            	}
				pv=nextpv;
       		}
			// на выход идёт то что в буфере MIX
            alSynMix32To16( dst, s->mix_buf, portion);

            dst   = (stereo16*)((UWord16)dst+SAMPLES2WORDS(portion));
            left -= portion;
        }
    }
}

/******************************************************************************
*
*	ОБНОВЛЕНИЕ ДРАЙВЕРА СИНТЕЗАТОРА
*
*******************************************************************************/

void alSynUpdate( ALSynth* s )
{
Int16 * ptr; 
long delta=0;

	ptr = fcodecWaitBuf();							// текущий буфер
	alAudioFrame( s, (stereo16*)ptr, FRAME_SIZE);	// сгенерировали
	alSynPanSlide( s );
	if(s->fcallTime == 0)return;
	alMicroTimeSub(&s->fcallTime, FRAME_TIME_US);
	if(s->fcallTime == 0)
		s->fcallTime	= s->fhandler((ALSeqPlayer*) s->clientData);
}

/******************************************************************************
*
*	СОЗДАЁТ И ИНИЦИАЛИЗИРУЕТ СИНТЕЗАТОР
*
*******************************************************************************/

bool alSynNew( ALSynth *s , ALSynConfig *cfg)
{
UInt16 n, *ptr;
		
	fcodecOpen();
	s->numPVoices = cfg->maxPVoices;
	s->pvoice = (PVoice*) memCallocIM(s->numPVoices, sizeof(PVoice));
	if( s->pvoice == NULL ) goto error; 
	
	memset(s->pvoice, 0,  s->numPVoices * sizeof(ALVoice));
	
	for( n = 0; n<s->numPVoices; n++)
		alLink(&s->pvoice[n].node, &s->pFreeList);
		
	cash_1 	= (UInt16*) malloc( CASH_L1_SIZE * sizeof(UInt16));		
	if( cash_1  == NULL ) goto error; 

	cash_2 	= (UInt16*) malloc( CASH_L2_SIZE * sizeof(UInt16));
	if( cash_2  == NULL ) goto error; 

	s->mix_buf	= (stereo32*) malloc( MIX_BUF_SIZE * sizeof(stereo32));			
	if( s->mix_buf == NULL ) goto error; 

	s->fcallTime 	= 0;
	s->samplesLeft 	= 0;	
	s->handler 		= NULL;
	s->fhandler		= NULL;
	return true;
error:	
	alSynDelete(s);
	return false;
}

/******************************************************************************
*
*	УНИЧТОЖАЕТ СИНТЕЗАТОР
*
*******************************************************************************/

void alSynDelete( ALSynth * s )
{
	if(s->pvoice !=NULL)free(s->pvoice);
	if(    cash_1!=NULL)free(cash_1);
	if(    cash_2!=NULL)free(cash_2);
	if(s->mix_buf!=NULL)free(s->mix_buf);
}

/******************************************************************************
*
*	Назначает клиента для синтезатора
*	клиент является программой секвенсора
*
*******************************************************************************/

void alSynAddPlayer(ALSynth *s, void *client)
{
	s->clientData=client;
}

/******************************************************************************
*
*	synt_env_set_delta( sVinfo* voice, ALMicroTime time, UInt16 vol )
*
*	Инициализирует генератор огибающей для тостижения амплитуды
*	в течении заданного времени.
*
*	sVinfo* voice		Структура канала
*	ALMicroTime time	Время за которое необходимо достичь громкости
*	UInt16 vol			Громкость которую необходимо достичь
*						0 - 7FFF 
*
*******************************************************************************/

void   alSynSetVol( ALSynth * s, ALVoice *v, Int16 volume, ALMicroTime time)
{
PVoice * pv = v->pvoice;

	pv->tgtVolume = (Int32)volume<<16;
	pv->curVolume &= 0x7FFF0000;
	pv->phaseVolume = 32;
	if(volume == 0) v->state |=  AL_SF_ZERO;
	else 			v->state &= ~AL_SF_ZERO;

	
	if(time<1000)
	{	pv->addVolume=0;
		pv->curVolume = pv->tgtVolume;
		v->state |=  AL_SF_TARGET;
	}	
	else 
	{	pv->addVolume = (pv->tgtVolume - pv->curVolume)/(time / 1000);
		v->state &= ~AL_SF_TARGET;
	}	
}

/******************************************************************************
*
*	Скольжение громкости 
*
*******************************************************************************/

void alSynPanSlide( ALSynth * s )
{
	PVoice   *pv;
				
		pv = (PVoice*)s->pAllocList.next;            	
	    while(pv!=NULL)
	    {	if(((((ALVoice*)pv->vvoice)->state & AL_SF_ACTIVE) != 0) && (pv->addPan !=0))
			{	pv->curPan += pv->addPan;
				if(pv->addPan>0) 
				{	if(((UInt16)pv->curPan >= (UInt16)pv->tgtPan))
					{	pv->curPan = pv->tgtPan;
						pv->addPan = 0;
					}
				}
				else 
				{ 	if(pv->curPan <= pv->tgtPan)
					{	pv->curPan = pv->tgtPan;
						pv->addPan = 0;
					}
				}
				alSynMixPanGain(pv);
			}	
			pv = (PVoice*)pv->node.next;
		}
}

/******************************************************************************
*
*	void    SynSetPan(ALSynth *s, ALVoice *voice, ALPan pan)
*
*	Set voice panning
*
*******************************************************************************/

void   alSynMixPanGain( PVoice *pv)
{
Frac16 rpan, lpan;
	rpan = pv->curPan>>8;			// 0  .. 40 .. 7F
	lpan = 0x80 - rpan;				// 80 .. 40 .. 1
	if(lpan > 0x7f) lpan = 0x7f;
	rpan *= (0x7FFF/0x7F);
	lpan *= (0x7FFF/0x7F);
	pv->rvol = mult_r(pv->gain, rpan);
	pv->lvol = mult_r(pv->gain, lpan);
}

void   alSynSetPan( ALSynth * s, ALVoice *v, ALPan pan, ALMicroTime time)
{
PVoice * pv = v->pvoice;
	
	pan <<= 8;
	pv->tgtPan = pan;
	if(time<FRAME_TIME_US)
	{	pv->addPan = 0;
		pv->curPan = pan;
	}	
	else
	{	pv->addPan  = (pan - pv->curPan)/(time / FRAME_TIME_US);
	}
	alSynMixPanGain(pv);
}

void   alSynSetGain( ALSynth * s, ALVoice *v, Int16 vol)
{
	v->pvoice->gain = vol;
	alSynMixPanGain(v->pvoice);
}

/******************************************************************************
*
*	SynSetPitch(ALSynth *s, ALVoice *voice, Int32 ratio)
*
*	Set voice pitch
*
*	Значение ratio = 0x10000 означает воспроизводить ноту как есть
*			 ratio = 0x20000 означает воспроизводить ноту на октаву выше
*			 ratio = 0x08000 на октаву ниже
*			 0 < ratio 0x2000
*			 если rate>2 то rate ограничивается до двух
*
*******************************************************************************/

void    alSynSetPitch( ALSynth * s, ALVoice *v, Int32 ratio)
{
		ratio = L_negate(L_mult_ls(ratio,v->unityPitch));
		if(ratio>0x20000) v->pvoice->pitch = 0x20000;
		else if(ratio==0) v->pvoice->pitch = 1;
		else v->pvoice->pitch=ratio; 
}

/******************************************************************************
*
*	void    SynSetFXMix(ALSynth *s, ALVoice *voice, Int16 fxmix)
*
*	Устанавливает уровень FX для голоса
*	Если значение рано MIX_VOL_MAX то на выход идёт только 
*	обработанный эфектом поток. Если MIX_VOL_MIN то только
*	чистый поток
*
*******************************************************************************/

void    alSynSetFXMix( ALSynth * s, ALVoice *v, Int16 fxmix)
{
	//v->pvoice->fxmix=fxmix;
}

/******************************************************************************
*
*	void    SynSetPriority(ALSynth *s, ALVoice *voice, Int16 priority)
*
*	Устанавливает приоритет голоса
*
*******************************************************************************/

void    alSynSetPriority(ALSynth * s, ALVoice *v, Int16 priority)
{
	v->priority=priority;
}

/******************************************************************************
*
*	Int16     SynGetPriority(ALSynth *s, ALVoice *voice)
*
*	Возвращает приоритет голоса
*
*	return Int16 		Приоритет
*
*******************************************************************************/

Int16     alSynGetPriority( ALSynth * s, ALVoice *v )
{
	return v->priority;
}

/******************************************************************************
*
*	void    SynStartVoice(ALSynth *s, ALVoice *voice, ALWaveTable *w)
*
*	Запуск воспроизведения волновой формы
*
*
*******************************************************************************/

void    alSynStartVoice( ALSynth * s, ALVoice *voice, ALWaveTable *w )
{
	PVoice    * pv = voice->pvoice;

	voice->wavetable = w;	
	voice->state    |= (w->ltype & AL_SF_LOOP); // параметры волновой формы
	voice->state    |= AL_SF_ACTIVE;
	pv->pos		     = w->base;   				// старт семпла
 
	if((voice->state & AL_SF_LOOP) != 0)
    {	pv->end 	= w->end + w->base;     	// конец петли
    	pv->endsub 	= (w->end- w->start)+1;		// отнять при достижении конца +1
		pv->count   = w->count;
	}
	else
	{	pv->end	= w->base + w->len - 2;    		// конец семпла
	}
}

/******************************************************************************
*
*	void    SynStartVoiceParams( ALVoice *v, ALWaveTable *w,
*							Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix
*							ALMicroTime t)
*
*	Запуск воспроизведения волновой формы
*
*
*******************************************************************************/

void    alSynStartVoiceParams(  ALSynth * s, ALVoice *v, ALWaveTable *w,
                              Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix,
                              ALMicroTime t)
{
   alSynStartVoice( s, v, w);		// Запуск семпла
	 alSynSetFXMix( s, v, fxmix);	// FX
	 alSynSetPitch( s, v, pitch);	// тональность
	   alSynSetPan( s, v, pan, t);	// панорама
	   alSynSetVol( s, v, vol, t);	// громкость	
}

void alSynStopVoice(ALSynth *drvr, ALVoice *voice)
{
	voice->state &= ~AL_SF_ACTIVE;						// Остановим синтез
	alUnlink(&voice->pvoice->node);						// выкинули из списка занятых	
	alLink(&voice->pvoice->node, &drvr->pLameList);		// в список сомнительных
}

/******************************************************************************
*
*	Int16   SynAllocVoice( ALSynth *s, ALVoice *v, UInt16 priority )
*
*	Привязывает к голосу один из полифонических голосов.
*	НО! возвращает 0 если это не произошло
*	Алгоритм поиска таков.
*	1. Сперва смотрим свободный голос во pFreeList
*	2. Потом  смотрим сомнительный голос в pLameList. В этот лист попадают 
*      голоса автомномно достигшие громкости 0. 
*   3. Ищем самый низкоприоритетный голос в pAllocList и если его приоритет
*      ниже или равен запрашиваемому то он вполне подходит.
*
*******************************************************************************/

Int16   alSynAllocVoice( ALSynth *s, ALVoice *v, UInt16 priority )
{
Int32	  minvol= 0x7FFFFFFF;
PVoice  * pv;
PVoice  * newpv = NULL;

	if( s->pFreeList.next != NULL )
	{	newpv = s->pFreeList.next;						// привязали к голосу один полифонический голос
		alUnlink(newpv);								// отвязали от списка свободных
		alLink( &newpv->node, &s->pAllocList);			// привязали к списку размещённых
		goto good;
	}

	if( s->pLameList.next != NULL )
	{	newpv = s->pLameList.next;						// привязали к голосу один полифонический голос
		alUnlink(newpv);								// отвязали от списка сомнительных
		alLink( &newpv->node, &s->pAllocList);			// привязали к списку размещённых
		goto good;
	}
	/*
	 *	Найдём голос сприоритетом меньше или равным заданному и
	 *	минимальной громкостью.
	 */
	pv = s->pAllocList.next;
	while(pv != NULL)
	{	if((((ALVoice*)pv->vvoice)->priority <= priority) 
	    && (pv->curVolume < minvol))
		{	minvol = pv->curVolume;
			newpv  = pv;
		}	
		pv = pv->node.next;								// следующий
	}
	
	if(newpv!=NULL)	
	{ 	// предыдущий виртуальный канал не активен и не имеет полиголоса
		((ALVoice*)newpv->vvoice)->state &= (~AL_SF_ACTIVE & ~AL_SF_ALOCATED);	
		((ALVoice*)newpv->vvoice)->pvoice = NULL;				
		goto good;										
	}
	return 0;

good:
	v->pvoice = newpv;				// привязали к голосу один полифонический голос
	v->priority = priority;			// Установили приоритет
	v->pvoice->vvoice = v;			// полиголос -> виртуальный
	v->state = AL_SF_ALOCATED;		// флаг ALOC САМЫЙ ПЕРВЫЙ ФЛАГ У ГОЛОСА
	return 1;
}

/******************************************************************************
*
*	void    alSynFreeVoice(ALSynth *s, ALVoice *voice)
*
*	Освобождает полифонический голос
*
*	НО! возвращает 0 если это не произошло
*
*******************************************************************************/

void    alSynFreeVoice(ALSynth *s, ALVoice *voice)
{
	alUnlink(&voice->pvoice->node);						// выкинули из списка занятых	
	alLink(&voice->pvoice->node, &s->pFreeList);		// в список свободных
	voice->pvoice = NULL;								// Убили связку на физический
	voice->state &= (~AL_SF_ACTIVE & ~AL_SF_ALOCATED);
}

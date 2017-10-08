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

static void alSynMixVolume( ALSynth* s, PVoice* v );
static void alMixLeft( void );
static void alMixRight( void );
static void alMixStereo( void );
static void alSynMixVoice( ALSynth* s, PVoice* v, UInt32* dst, size_t todo );
static void alSynRenderVoice( ALSynth* s, PVoice* v, size_t todo );
static void alSynFadeVoice( ALSynth* s, PVoice* v, UInt32* dst, size_t todo );
static void alSynMix32To16(UInt16 *dste, UInt32 *srce, size_t todo);
static UInt16 alSynMix32To16FX(UInt16 * dste, UInt32 *srce, size_t todo);
static UInt16 alSynMix16To32FX(UInt32 * dste, UInt16 * src, UInt16 vol, size_t todo);
static void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo);

//DMAState * dmastate;

/******************************************************************************
* Макросы модуля
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
* ДОСТУП ИЗ АССЕМБЛЕРА К СТРУКТУРЕ ГОЛОСА
******************************************************************************/

#define v(x) X:(r3+PVoice.x)
#define PITCHF v(pitch)
#define PITCHI v(pitch+1)
#define FPOS   v(fpos)
#define POSL   v(pos)
#define POSH   v(pos+1)
#define ENDL   v(end)
#define ENDH   v(end+1)
#define LVOL   v(lvol)
#define RVOL   v(rvol)
#define VOL    v(vol)
#define PAN    v(pan)
#define LFXMIX v(lfxmix)
#define RFXMIX v(rfxmix)
#define FXMIX  v(fxmix)
#define GAIN   v(volgain)
#define FADE   v(fadeval)
#define FADESUB v(fadesub)

#define s(x) X:(r0+ALSynth.x)
#define CASH_1 s(cash_1)
#define CASH_2 s(cash_2)

/******************************************************************************
* 	МИКСЕРЫ ГРОМКОСТЕЙ И БАЛАНСОВ
*		 pan = 64  середина
*		 pan = 127 в правый канал
*		 pan = 0   в левый канал
*		 lvol,rvol от 0 до 7FFF 	
*******************************************************************************/
//				     	      R2		   R3
void alSynMixVolume( ALSynth * s, PVoice * v )
{
	asm
	{
		move	VOL,y0					// y0 = vol
		move	GAIN,x0					// y0 = vol
		mpyr	y0,x0,b					// b1 = масштабированная громкость 
		move	PAN,y0					// y0 = pan
		move	#PAN_CENTER,y1			// 0x40 is center	
		cmp		y0,y1
		beq		midle					// yes it is center
		move	#PAN_RIGHT,y1			// y1 = 0x7f
		sub		y0,y1					// y1 = 0x7f - pan
midle:
		move	#PAN_SCALE,x0			// x0 = COEFF
		impy	y0,x0,y0				// y0 = pan * COEFF
		impy	y1,x0,y1				// y1 = (0x7f-pan) * COEFF
		move	b1,x0					// x0 = громкость
		mpyr	y0,x0,a					// a  = rnd( y0 * vol ) 
		move	a,RVOL					// rvol = a1
		mpyr	y1,x0,a					// a  = rnd( y1 * vol ) 
		move	a,LVOL					// lvol = a1
	}
#ifdef FX_ON
	asm
	{
		move	FXMIX,y0				// y0 = fxmix
		move	#$7f,y1					// y1 = 0x7f
		sub		y0,y1					// y1 = 0x7f - fxmix
		move	#FX_SCALE,x0			// x0 = COEFF
		impy	y0,x0,y0				// y0 = fxmix * COEFF
		impy	y1,x0,y1				// y1 = (0x7f - fxmix) * COEFF
		move	RVOL,x0					// x0 = rvol
		mpyr	y0,x0,a					// a  = rnd( y0 * rvol )
		move	a,RFXMIX				// rfxmix = a
		mpyr	y1,x0,a					// a  = rnd( y1 * rvol )
		move	a,RVOL					// rvol = a
		move	LVOL,x0					// x0 = lvol
		mpyr	y0,x0,a					// a  = rnd( y0 * lvol ) => 0 .. 3fff
		move	a,LFXMIX				// lfxmix = a1	
		mpyr	y1,x0,a					// a  = rnd( y1 * lvol ) => 0 .. 3fff
		move	a,LVOL					// lvol = a
	}
#endif
}

/******************************************************************************
* 	ПРИМЕШАТЬ РЕНДЕРЁНЫЙ СЕМПЛ В ЛЕВЫЙ КАНАЛ БУФЕРА MIX
*
* 	Посчитаем на сколько сместится счётчик
*	r1 = адрес приёмника
*	r2 = адрес источника
*	x0 = количество семплов
*	y0 = левая громкость
*	y1 = правая громкость
*******************************************************************************/

void alMixLeft( void )
{
	asm
		{
		move	#4,n					// через 4 слова
		do		x0,Exit	
		move	X:(r2)+,x0				// x0  = (sample)*LEV2ptr++
		move	X:(r1+1),b			
		move	X:(r1),b0				// b   = (s32sample)*dest
		mac		x0,y0,b					// b  += (sample * leftvol)
		move	b,X:(r1+1)
		move	b0,X:(r1)+n				// *dest++ = b
Exit:	
		}
}

/******************************************************************************
* 	ПРИМЕШАТЬ РЕНДЕРЁНЫЙ СЕМПЛ В ПРАВЫЙ КАНАЛ БУФЕРА MIX
*
* 	Посчитаем на сколько сместится счётчик
*	r1 = адрес приёмника
*	r2 = адрес источника
*	x0 = количество семплов
*	y0 = левая громкость
*	y1 = правая громкость
*******************************************************************************/

void alMixRight( void )
{
	asm
		{
		move	#2,n
		lea		(r1)+n					// на следующий семпл
		move	#4,n					// через 4 слова
		do		x0,Exit	
		move	X:(r2)+,x0				// x0  = (sample)*LEV2ptr++
		move	X:(r1+1),b			
		move	X:(r1),b0				// b   = (s32sample)*dest
		mac 	x0,y1,b					// b  += (sample * leftvol)
		move	b,X:(r1+1)
		move	b0,X:(r1)+n				// *dest++ = b
Exit:
		}
}

/******************************************************************************
* 	ПРИМЕШАТЬ РЕНДЕРЁНЫЙ СЕМПЛ В ОБА КАНАЛА БУФЕРА MIX
*
* 	Посчитаем на сколько сместится счётчик
*	r1 = адрес приёмника
*	r2 = адрес источника
*	x0 = количество семплов
*	y0 = левая громкость
*	y1 = правая громкость
*******************************************************************************/

void alMixStereo( void )
{
	asm
		{
		cmp		#0,y0					// левая громкость равна 0 ?
		bne		left_to_be				// нет! 
		cmp		#0,y1					// правая громкость равна 0 ?
		beq		Exit					// да! оба канала в 0
		jsr		alMixRight				// Смешали только правый канал
		bra		Exit		
left_to_be:
		cmp		#0,y1					// правая громкость равна 0 ?
		bne		mix_both				// нет! оба канала не в 0
		jsr		alMixLeft				// примешаем только левй канал
		bra		Exit		
mix_both:
		move	#2,n					
		do		x0,Exit					// нет! смешаем оба канала
		move	X:(r2)+,x0				// x0  = (sample)*LEV2ptr++
		move	X:(r1+1),b			
		move	X:(r1),b0				// b   = (s32sample)*dest
		mac 	x0,y0,b					// b  += (sample * leftvol)
		move	b,X:(r1+1)	
		move	b0,X:(r1)+n				
		move	X:(r1+1),b				// b   = (s32sample)*dest
		move	X:(r1),b0				// *dest++ = b				
		mac		x0,y1,b					// b  += (sample * rightvol)
		move	b,X:(r1+1)
		move	b0,X:(r1)+n				// *dest++ = b
Exit:
		}
}

/******************************************************************************
*
* void alSynMixVoice( ALSynth* s, PVoice* v, UInt32* dst, size_t todo )
*
*	ПРИМЕШАТЬ ОДИН ГОЛОС К БУФЕРУ
*
*	s		синтезатор
*	v		полифонический канал
*	dst		приёмник
*	todo	размер
*
* 	cash_2 	источник входных данных
*
*******************************************************************************/
//						A			R2		 R3			    Y0
void alSynMixVoice( ALSynth* s, PVoice* v, UInt32* dst, size_t todo )
{
	asm
	{
		move	s,r0					// r0  = synt
		move	v,r3    				// r3  = voice
#ifdef FX_ON
		move	FXMIX,x0
		cmp		#0,x0
		beq		clean_sound
		cmp		#0x7F,x0
		beq		fx_sound
mixed_sound:
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	LVOL,y0					// y0  = левая громкость
		move	RVOL,y1					// y1  = правая громкость
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	#MIX_BUF_SIZE*4,n		// вторая половина(FX буфер)
		lea		(r1)+n	
		move	LFXMIX,y0				// y0  = левая громкость
		move	RFXMIX,y1				// y1  = правая громкость
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		bra		Exit
fx_sound:
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	#MIX_BUF_SIZE*4,n		// вторая половина(FX буфер)
		lea		(r1)+n	
		move	LFXMIX,y0				// y0  = левая громкость
		move	RFXMIX,y1				// y1  = правая громкость
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		bra		Exit
#endif
clean_sound:			
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	LVOL,y0					// y0  = левая громкость
		move	RVOL,y1					// y1  = правая громкость
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
Exit:
	}
}

/******************************************************************************
*
* void alSynRenderVoice( ALSynth* s, PVoice* v, size_t todo )
*
*	Отрендерить Семпл
*
*	s		синтезатор
*	v		полифонический голос
*	dst		куда отрендерить
*	todo	размер блока
*
* 	cash_1 	используется для подкачки из SDRAM
*	cash_2	для оендеринга семпла
*
*******************************************************************************/

void alSynRenderVoice( ALSynth* s, PVoice* v, size_t todo )
{
	UInt16 rendfpos;
	UInt16 framepos;
	asm
	{
	/*
	 * 	ПРОЧИТАТЬ В КЕШ ( Посчитаем на сколько сместится счётчик )
	 */
		move	s,r0					// r0  = synt
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
										// Вычислим число слов для кеширования
		move	#2,x0					// сдвинуть на два бита
		asrr	y0,x0,y0				// целое смещение / 4
		inc		y0						// y0  = число блоков
		inc		y0
		move	CASH_1,r2				// r2  = начало кеша
		jsr		sdram_load_64			// ЗАГРУЗИМ БЛОК
	   /*
		*	Теперь проинтерполируем блок в кеше
		*/
		move	CASH_1,y0				// y0  = начало кеша
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
*	ПРЕОБРАЗОВАНИЕ БЛОКА 32Х БИТНЫХ ДАННЫХ В 16 БИТОВЫЕ
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

/******************************************************************************
*
*	Смешивание 32x битных буферов с FADEOUT src буфера
*
*******************************************************************************/
//                          R2            R3           Y0
void alSynFadeVoice( ALSynth* s, PVoice* v, UInt32* dst, size_t todo )
{
	asm
		{
		move	s,r0					// r0  = synt
		move	v,r3    				// r3  = voice
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	todo,x0					// x0  = todo 
		move	#2,n					
		move	LVOL,a0					// y0  = левая громкость
		move	RVOL,a1					// y1  = правая громкость
		do		x0,Exit					// **********************
		move	FADE,x0					// x0  = fadeout
		move	FADESUB,y0
		sub		y0,x0
		bcc		ok
		clr		x0
ok:										// если CARY = 0 then b=x0
		move	a1,y1					
		move	a0,y0
		move	x0,FADE		
		mpyr	y0,x0,b					
		move	b1,y0					// y0  = громкость * fadeout
		mpyr	y1,x0,b
		move	b1,y1					// y1  = громкость * fadeout
		move	X:(r2)+,x0				// x0  = (sample)*LEV2ptr++
		move	X:(r1+1),b			
		move	X:(r1),b0				// b   = (s32sample)*dest
		mac 	x0,y0,b					// b  += (sample * leftvol)
		move	b,X:(r1+1)	
		move	b0,X:(r1)+n				
		move	X:(r1+1),b				// b   = (s32sample)*dest
		move	X:(r1),b0				// *dest++ = b				
		mac		x0,y1,b					// b  += (sample * rightvol)
		move	b,X:(r1+1)
		move	b0,X:(r1)+n				// *dest++ = b
Exit:									// **********************
		}
}

/******************************************************************************
*
*	ПРЕОБРАЗОВАНИЕ БЛОКА 32Х БИТНЫХ ДАННЫХ В 16 БИТОВЫЕ НО В PRAM
*
*******************************************************************************/
#ifdef FX_ON
UInt16  alSynMix32To16FX(UInt16 * dste, UInt32 *srce, size_t todo)
{
	asm
		{
		move	r2,r0					// r0 = dst
		move	#FX_MODULO,m01
		move	#2,N					// sample = 2 words
		do		y0,EndDo
		move	X:(r3+1),a				// a = (sample32)(r3)			
		move	X:(r3)+N,a0				// r3 to next sample
		rnd		a						// round sample
		move	a,P:(r0)+				// (r0)+=saturate(a)
		move	X:(r3+1),a				// a = (sample32)(r3)			
		move	X:(r3)+N,a0				// r3 to next sample
		rnd		a						// round sample
		move	a,P:(r0)+				// (r0)+=saturate(a)
EndDo:
		move	r0,y0					// return dst = r0
		}
}

/******************************************************************************
*
*	МИКШИРОВАНИЕ БЛОКА 16ти БИТНЫХ ДАННЫХ ИЗ PRAM В 32 БИТОВЫЕ
*
*******************************************************************************/

UInt16  alSynMix16To32FX(UInt32 * dste, UInt16 * src, UInt16 vol, size_t todo)
{											
	asm									// r2 = dst	
		{								// y0 = volume
		move	r3,r0					// r0 = src				
		move	#FX_MODULO,m01
		move	#2,N
		do		y1,EndDo
		move	P:(r0)+,x0				// x0  = *src++
		move	X:(r2+1),a				// a   = *dst			
		move	X:(r2),a0
		mac		y0,x0,a					// a   = a + x0 * y0 
		move	a,X:(r2+1)				//*dst = a			
		move	a0,X:(r2)+N				// dst+=2
		move	P:(r0)+,x0				// x0  = *src++
		move	X:(r2+1),a				// a   = *dst			
		move	X:(r2),a0
		mac		y0,x0,a					// a   = a + x0 * y0 
		move	a,X:(r2+1)				//*dst = a			
		move	a0,X:(r2)+N				// dst+=2
EndDo:
		move	r0,y0					// return r0 = src
		}
}
#endif

#include "mfr16.h"

/******************************************************************************
*
*	void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo)
*
*	ГЕНЕРАЦИЯ ОДНОГО КАНАЛА
*
*	s		синтезатор
*	v		голос
*	dst		выходной буфер
*	todo	размер в семплах
*
*	Делает это за несколько	итераций если это необходимо. Например если до 
*	конца семпла осталось меньше чем todo семплов. То сначала запросим необхо-
*	димое количество а затем перейдя вначало петли запросим сколько ещё необ-
*	ходимо.
*
*******************************************************************************/

void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo)
{
    UInt32  end;
    UInt16	done;
    UInt32  estimate;

    while(todo > 0)
    {   
    	// обновить 'current' позицию учитывая зацикливание, или
        // остановить воспроизведение если достигли конца семпла

		if(((v->pos == v->end) && (v->fpos>0)) || (v->pos > v->end))
		{	// воспроизведение вперёд и текущая
			// позиция достигла конца
        	if(v->state & AL_SF_LOOP) 
        	{	// семпл зациклен
        		v->pos -= v->endsub;
           	}
           	else
           	{	// семпл не зациклен
               	// остановим воспроизведение
				v->state &= !AL_SF_ACTIVE;
				return;      
			}
       	} 
       	
		estimate = (((v->end - v->pos)<<16) - (UInt32)(UInt16)v->fpos)  / v->pitch + 1;        
		done = MIN(estimate, todo);

        if((done==0) || (v->fadeval==0)) goto error; 

       	alSynRenderVoice( s, v, done );
       	if((v->state & AL_SF_FADEOUT) == 0)
			alSynMixVoice( s, v, dst, done );
		else
		{	alSynFadeVoice( s, v, dst, done );
			
		}
		
        todo -= done;
        dst  += done;		// Так как dst указатель на 4 слова
        					// +done выглядит реально как +done<<2
    }
	return;
	
error:
			// аварийная ситуация !!!
        	v->state &= !AL_SF_ACTIVE;
			alUnlink(&v->node);						// выкинули из списка занятых	
			alLink(&v->node, &s->pLameList);		// в список сомнительных
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
	PVoice   *v;
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
#ifdef FX_ON // FX *************************
            memset(s->fx_buf, 0, portion<<2);
#endif       // FX *************************     			
			v = (PVoice*)s->pAllocList.next;            	
              	
         	while( v != NULL)
           	{   if(v->state & AL_SF_ACTIVE)
                {   alSynMixVolume( s, v );
                    alSynAddChannel(s, v, s->mix_buf, portion);
            	}
				v=(PVoice*)v->node.next;
       		}
#ifdef FX_ON // FX *************************
			/*
			 *	в буферы MIX и FX примешивается то что в задержке
			 *	затем в задержку уходит то что в буфере FX
			 */
			if(s->fxptrnum!=0)
			{	for( t = 0; t < s->fxptrnum; t++)
				{	fxoutptr = s->fxinptr + s->fxdelay[t];
					while(fxoutptr<FX_ADDR) fxoutptr-=FX_SIZE;
					alSynMix16To32FX((UInt32*)s->fx_buf,  (UInt16*)fxoutptr, s->fxvol[t], portion);
					alSynMix16To32FX((UInt32*)s->mix_buf, (UInt16*)fxoutptr, 0x7fff, portion);
				}
	        	s->fxinptr = alSynMix32To16FX( (UInt16*)s->fxinptr, s->fx_buf, portion);            
			}
#endif		// FX *************************
		//	alSynMixFade( (UInt32*)s->mix_buf, s->fade_buf, FADE_BUF_SIZE);
			// на выход идёт то что в буфере MIX
            alSynMix32To16( dst, s->mix_buf, portion);

            dst   = (stereo16*)((UWord16)dst+SAMPLES2WORDS(portion));
            left -= portion;
        }
    }
}

/******************************************************************************
*
*	Скольжение громкости 
*
*******************************************************************************/

void alSynVolumeSlide( ALSynth * s )
{
	PVoice   *v;
    Int16     t;
	Int32     tv;
				
		v = (PVoice*)s->pAllocList.next;            	
	    while(v!=NULL)
	    {	if(v->state & AL_SF_ACTIVE)
			{	if(v->volinc !=0)
				{	tv = (((Int32)v->vol<<16) + (UInt32)v->volf);
					tv+= v->volinc;
					v->vol  = (UInt16)(tv>>16);
					v->volf = (UInt16)tv; 		
					if(v->volinc>0)
					{	if((UInt16)v->vol >= (UInt16)v->voltg)
						{ 	v->vol=v->voltg;
							v->volinc=0;
						}
					}
					else
					{	if(v->vol <= 0)
						{ 	v->vol=0;
							v->volinc=0;
				        	v->state &= !AL_SF_ACTIVE;
							alUnlink(&v->node);						// выкинули из списка занятых	
							alLink(&v->node, &s->pLameList);		// в список сомнительных
						}
					}
				}
				if(v->paninc !=0)
				{	tv = (((Int32)v->pan<<16) + (UInt32)v->panf);
					tv+= v->paninc;
					v->pan  = (UInt16)(tv>>16);
					v->panf = (UInt16)tv; 		
					if(v->paninc>0)
					{	if((UInt16)v->pan >= (UInt16)v->pantg)
						{ 	v->pan=v->pantg;
							v->paninc=0;
						}
					}
					else
					{	if(v->pan <= 0)
						{ 	v->pan=0;
							v->paninc=0;
						}
					}
				}
			}	
			v = (PVoice*)v->node.next;
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
/* Get system elapsed time */ 
//struct timespec before; 
//struct timespec after; 
long delta=0;

	// Наполнили буфер
	ptr = fcodecWaitBuf();				// текущий буфер
	// Проинтерполировали громкости
//	clock_gettime (CLOCK_REALTIME, &before);
	alSynVolumeSlide( s );
	alAudioFrame( s, (stereo16*)ptr, FRAME_SIZE);
	if(s->fcallTime == 0)return;
	alMicroTimeSub(&s->fcallTime, FRAME_TIME_US);
	if(s->fcallTime == 0)
		s->fcallTime	= s->fhandler((ALSeqPlayer*) s->clientData);
//	CleanDMABuffs();
//	clock_gettime (CLOCK_REALTIME, &after);
//	delta=after.tv_nsec-before.tv_nsec;
//	asm{ nop };
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
		
	s->cash_1 	= (UInt16*) malloc( CASH_L1_SIZE * sizeof(UInt16));		
	if( s->cash_1  == NULL ) goto error; 

	s->cash_2 	= (UInt16*) malloc( CASH_L2_SIZE * sizeof(UInt16));
	if( s->cash_2  == NULL ) goto error; 

#ifdef FX_ON 
	s->mix_buf	= (stereo32*) malloc( (MIX_BUF_SIZE<<1) * sizeof(stereo32));			
	if( s->mix_buf == NULL ) goto error; 

	s->fx_buf   = (stereo32*) s->mix_buf + MIX_BUF_SIZE;
	for( n = 0xFFFF; n>=FX_ADDR ; n--) 
	{
		memWriteP16( 0, (UInt16*) n );
	}
	
	ptr = cfg->params;
	s->fxptrnum = *ptr++; ptr++;
	s->fxinptr  = FX_ADDR;
	for( n = 0 ; n < s->fxptrnum; n++)
	{
		s->fxdelay[n] = *ptr++;
		s->fxvol[n]   = *ptr++;
	}
#else
	s->mix_buf	= (stereo32*) malloc( MIX_BUF_SIZE * sizeof(stereo32));			
	if( s->mix_buf == NULL ) goto error; 
#endif

	s->fcallTime 	= 0;
	s->samplesLeft 	= 0;	
	s->handler 		= NULL;
	s->fhandler		= NULL;
	// dmaNew(&dmastate);
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
	if(s->pvoice!=NULL) free(s->pvoice);
	if(s->cash_1!=NULL) free(s->cash_1);
	if(s->cash_2!=NULL) free(s->cash_2);
	if(s->mix_buf!=NULL) free(s->mix_buf);
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

	if(time<FRAME_TIME_US)
	{
		pv->volinc=0;
		pv->vol=volume;
	}	
	else
	{
		pv->volinc  = ((Int32)(volume - pv->vol)<<16)/(time / FRAME_TIME_US);
	}
	pv->voltg = volume;
	pv->volf=0;
}

void   alSynSetGain( ALSynth * s, ALVoice *v, Int16 volume) { v->pvoice->volgain = volume; }
Int16  alSynGetGain( ALSynth * s, ALVoice *v ) { return v->pvoice->volgain; }

/******************************************************************************
*
*	void    SynSetPan(ALSynth *s, ALVoice *voice, ALPan pan)
*
*	Устанавливает панораму для голоса
*
*******************************************************************************/

void   alSynSetPan( ALSynth * s, ALVoice *v, ALPan pan)
{
	v->pvoice->pan = pan;
}

void   alSynSetPanTime( ALSynth * s, ALVoice *v, ALPan pan, ALMicroTime time)
{
PVoice * pv = v->pvoice;

	if(time<FRAME_TIME_US)
	{
		pv->paninc=0;
		pv->pan=pan;
	}	
	else
	{
		pv->paninc  = ((Int32)(pan - pv->pan)<<16)/(time / FRAME_TIME_US);
	}
	pv->pantg = pan;
	pv->panf=0;
}	
/******************************************************************************
*
*	SynSetPitch(ALSynth *s, ALVoice *voice, Int32 ratio)
*
*	Устанавливает питч (частоту звучания) для голоса
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
	v->pvoice->fxmix=fxmix;
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
	ALRawLoop * loop;
	PVoice    * pv = voice->pvoice;

	pv->fadeval = 0x7fff;
	voice->wavetable= w;						// параметры волновой формы
    pv->state	= w->flags | AL_SF_ACTIVE;		// флаги семпла
	pv->pos		= w->base;    					// старт семпла
												// семпл активен и клавиша удерживается
	if(pv->state & AL_SF_LOOP)
    {	loop = w->waveInfo.rawWave.loop;
    	pv->end 	= loop->end + w->base;     	// конец петли
    	pv->endsub 	= loop->end-loop->start+1;	// отнять при достижении конца
	}
	else
	{	pv->end	= w->base + w->len - 1;    		// конец семпла
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
	   alSynSetPan( s, v, pan);		// панорама
	   alSynSetVol( s, v, vol, t);	// громкость	
	  alSynSetGain( s, v, 0x7fff);  // Масштаб максимальный
}

void alSynStopVoice(ALSynth *drvr, ALVoice *voice)
{
	voice->pvoice->state &= AL_SF_ACTIVE;					// Остановим синтез
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
UInt16    minpriority = MAX_PRIORITY;
Int16	  minvolume   = 0x7FFF;
Int16 	  curvol;
PVoice  * pvoice;
PVoice  * minpvoice = NULL;

	if( s->pFreeList.next != NULL )
	{	v->pvoice = s->pFreeList.next;					// привязали к голосу один полифонический голос
		alUnlink(s->pFreeList.next);					// отвязали от списка свободных
		alLink( &v->pvoice->node, &s->pAllocList);		// привязали к списку размещённых
		goto good;
	}
	if( s->pLameList.next != NULL )
	{	v->pvoice = s->pLameList.next;					// привязали к голосу один полифонический голос
		alUnlink(s->pLameList.next);					// отвязали от списка сомнительных
		alLink( &v->pvoice->node, &s->pAllocList);		// привязали к списку размещённых
		goto good;
	}
	pvoice = s->pAllocList.next;
	while(pvoice != NULL)
	{	curvol = mult(pvoice->vol, pvoice->fadeval);
		if((pvoice->priority <= priority) && (curvol < minvolume))
		{	minvolume = curvol;
			minpvoice = pvoice;
		}	
	//	if(pvoice->priority < minpriority)				// Найден более низкий приоритет
	//	{	minpriority = pvoice->priority;				// теперь он самый-самый
	//		minpvoice = pvoice;							// и указатель на него
	//	}
		pvoice = pvoice->node.next;						// следующий
	}

//	if(priority >= minpriority)							// найден подходящий голос
//	{	v->pvoice = minpvoice;							// виртуальный на физический
//		goto good;
//	}
	if(minpvoice==NULL)	return 0;
	else v->pvoice = minpvoice;							// виртуальный на физический
good:
	v->pvoice->priority = priority;						// У физического голоса установим приоритет
	v->priority = priority;								// У виртуального тоже
	v->pvoice->vvoice = v;
	return 1;
}

Int16   alSynReAllocVoice( ALSynth *s, ALVoice *vold, ALVoice *vnew, UInt16 priority)
{
	vnew->pvoice = vold->pvoice;
	vold->pvoice = NULL;
	vnew->pvoice->priority = priority;					// У физического голоса установим приоритет
	vnew->priority = priority;							// У виртуального тоже
	vnew->pvoice->vvoice = vnew;
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
}

void	alSynFadeOut(ALSynth *s, ALVoice *voice)
{
	voice->pvoice->state |= AL_SF_FADEOUT;
}

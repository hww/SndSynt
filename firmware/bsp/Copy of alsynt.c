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
* ������� ������
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
* ������ �� ���������� � ��������� ������
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
* 	������� ���������� � ��������
*		 pan = 64  ��������
*		 pan = 127 � ������ �����
*		 pan = 0   � ����� �����
*		 lvol,rvol �� 0 �� 7FFF 	
*******************************************************************************/
//				     	      R2		   R3
void alSynMixVolume( ALSynth * s, PVoice * v )
{
	asm
	{
		move	VOL,y0					// y0 = vol
		move	GAIN,x0					// y0 = vol
		mpyr	y0,x0,b					// b1 = ���������������� ��������� 
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
		move	b1,x0					// x0 = ���������
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
* 	��������� �����Ш��� ����� � ����� ����� ������ MIX
*
* 	��������� �� ������� ��������� �������
*	r1 = ����� ��������
*	r2 = ����� ���������
*	x0 = ���������� �������
*	y0 = ����� ���������
*	y1 = ������ ���������
*******************************************************************************/

void alMixLeft( void )
{
	asm
		{
		move	#4,n					// ����� 4 �����
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
* 	��������� �����Ш��� ����� � ������ ����� ������ MIX
*
* 	��������� �� ������� ��������� �������
*	r1 = ����� ��������
*	r2 = ����� ���������
*	x0 = ���������� �������
*	y0 = ����� ���������
*	y1 = ������ ���������
*******************************************************************************/

void alMixRight( void )
{
	asm
		{
		move	#2,n
		lea		(r1)+n					// �� ��������� �����
		move	#4,n					// ����� 4 �����
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
* 	��������� �����Ш��� ����� � ��� ������ ������ MIX
*
* 	��������� �� ������� ��������� �������
*	r1 = ����� ��������
*	r2 = ����� ���������
*	x0 = ���������� �������
*	y0 = ����� ���������
*	y1 = ������ ���������
*******************************************************************************/

void alMixStereo( void )
{
	asm
		{
		cmp		#0,y0					// ����� ��������� ����� 0 ?
		bne		left_to_be				// ���! 
		cmp		#0,y1					// ������ ��������� ����� 0 ?
		beq		Exit					// ��! ��� ������ � 0
		jsr		alMixRight				// ������� ������ ������ �����
		bra		Exit		
left_to_be:
		cmp		#0,y1					// ������ ��������� ����� 0 ?
		bne		mix_both				// ���! ��� ������ �� � 0
		jsr		alMixLeft				// ��������� ������ ���� �����
		bra		Exit		
mix_both:
		move	#2,n					
		do		x0,Exit					// ���! ������� ��� ������
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
*	��������� ���� ����� � ������
*
*	s		����������
*	v		�������������� �����
*	dst		�������
*	todo	������
*
* 	cash_2 	�������� ������� ������
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
		move	LVOL,y0					// y0  = ����� ���������
		move	RVOL,y1					// y1  = ������ ���������
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	#MIX_BUF_SIZE*4,n		// ������ ��������(FX �����)
		lea		(r1)+n	
		move	LFXMIX,y0				// y0  = ����� ���������
		move	RFXMIX,y1				// y1  = ������ ���������
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		bra		Exit
fx_sound:
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	#MIX_BUF_SIZE*4,n		// ������ ��������(FX �����)
		lea		(r1)+n	
		move	LFXMIX,y0				// y0  = ����� ���������
		move	RFXMIX,y1				// y1  = ������ ���������
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
		bra		Exit
#endif
clean_sound:			
		move	CASH_2,r2				// r2  = level_2	
		move	dst,r1					// r4  = dest
		move	LVOL,y0					// y0  = ����� ���������
		move	RVOL,y1					// y1  = ������ ���������
		move	todo,x0					// x0  = todo 
		jsr		alMixStereo			
Exit:
	}
}

/******************************************************************************
*
* void alSynRenderVoice( ALSynth* s, PVoice* v, size_t todo )
*
*	����������� �����
*
*	s		����������
*	v		�������������� �����
*	dst		���� �����������
*	todo	������ �����
*
* 	cash_1 	������������ ��� �������� �� SDRAM
*	cash_2	��� ���������� ������
*
*******************************************************************************/

void alSynRenderVoice( ALSynth* s, PVoice* v, size_t todo )
{
	UInt16 rendfpos;
	UInt16 framepos;
	asm
	{
	/*
	 * 	��������� � ��� ( ��������� �� ������� ��������� ������� )
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
										// �� ������� ��������� ����� ����� ��������
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
										// �������� ����� ���� ��� �����������
		move	#2,x0					// �������� �� ��� ����
		asrr	y0,x0,y0				// ����� �������� / 4
		inc		y0						// y0  = ����� ������
		inc		y0
		move	CASH_1,r2				// r2  = ������ ����
		jsr		sdram_load_64			// �������� ����
	   /*
		*	������ ���������������� ���� � ����
		*/
		move	CASH_1,y0				// y0  = ������ ����
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
*	�������������� ����� 32� ������ ������ � 16 �������
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
*	���������� 32x ������ ������� � FADEOUT src ������
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
		move	LVOL,a0					// y0  = ����� ���������
		move	RVOL,a1					// y1  = ������ ���������
		do		x0,Exit					// **********************
		move	FADE,x0					// x0  = fadeout
		move	FADESUB,y0
		sub		y0,x0
		bcc		ok
		clr		x0
ok:										// ���� CARY = 0 then b=x0
		move	a1,y1					
		move	a0,y0
		move	x0,FADE		
		mpyr	y0,x0,b					
		move	b1,y0					// y0  = ��������� * fadeout
		mpyr	y1,x0,b
		move	b1,y1					// y1  = ��������� * fadeout
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
*	�������������� ����� 32� ������ ������ � 16 ������� �� � PRAM
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
*	������������ ����� 16�� ������ ������ �� PRAM � 32 �������
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
*	��������� ������ ������
*
*	s		����������
*	v		�����
*	dst		�������� �����
*	todo	������ � �������
*
*	������ ��� �� ���������	�������� ���� ��� ����������. �������� ���� �� 
*	����� ������ �������� ������ ��� todo �������. �� ������� �������� ������-
*	����� ���������� � ����� ������� ������� ����� �������� ������� ��� ����-
*	������.
*
*******************************************************************************/

void alSynAddChannel(ALSynth* s, PVoice* v, stereo32* dst, size_t todo)
{
    UInt32  end;
    UInt16	done;
    UInt32  estimate;

    while(todo > 0)
    {   
    	// �������� 'current' ������� �������� ������������, ���
        // ���������� ��������������� ���� �������� ����� ������

		if(((v->pos == v->end) && (v->fpos>0)) || (v->pos > v->end))
		{	// ��������������� ����� � �������
			// ������� �������� �����
        	if(v->state & AL_SF_LOOP) 
        	{	// ����� ��������
        		v->pos -= v->endsub;
           	}
           	else
           	{	// ����� �� ��������
               	// ��������� ���������������
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
        dst  += done;		// ��� ��� dst ��������� �� 4 �����
        					// +done �������� ������� ��� +done<<2
    }
	return;
	
error:
			// ��������� �������� !!!
        	v->state &= !AL_SF_ACTIVE;
			alUnlink(&v->node);						// �������� �� ������ �������	
			alLink(&v->node, &s->pLameList);		// � ������ ������������
			return;
}

/******************************************************************************
*
*	void alAudioFrame(ALSynth* s, stereo16 *outBuf, size_t samples)
*
*	��������� ������
*
*	s		����������
*	outBuf	�������� �����
*	samples	���������� �������
*
*	���������� todo � ����������� ������� �� ���� �����. ���������� ����� �����
*	�������� todo. �������� ��� �� ��������� ����������� ��� ����������. 
*	�������� ���� ��� ���������� ���������� N ������� �� ��������� ����������
*	ch1[1..N], ch2[1..N], ... , chN[N]. ����� ���������� M �������, ��� 
*	M = todo-N. ����� ��������� ����� ������ ��������� ���������� �����������.
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
    {   // ����� ������ � ������������� ������� ����������
    	if(s->samplesLeft==0)
        {   if(s->handler!=NULL)
        	{	 s->callTime	= s->handler((ALSeqPlayer*) s->clientData);
				 s->samplesLeft = (Int32)(s->callTime * 100)/((Int32)100000000 /MIXFREQ);
        	}
        	else s->samplesLeft = samples;
        }
        /*
		 * ���������� �� ����, ���������� ���� ��� �������� SEQ-�������
         */
        left = MIN(s->samplesLeft, samples);
        
        dst	    		= outBuf;
        s->samplesLeft -= left;
        samples    	   -= left;

        outBuf = (void*)((UWord16)outBuf + SAMPLES2WORDS(left));

        while(left>0)
        {  	portion = MIN(left, MIX_BUF_SIZE);

			/* 
			 *	�������� ���� � ���������� = ������� * 4
			 * 	�� �� ������ � 32 � ������� ��������
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
			 *	� ������ MIX � FX ������������� �� ��� � ��������
			 *	����� � �������� ������ �� ��� � ������ FX
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
			// �� ����� ��� �� ��� � ������ MIX
            alSynMix32To16( dst, s->mix_buf, portion);

            dst   = (stereo16*)((UWord16)dst+SAMPLES2WORDS(portion));
            left -= portion;
        }
    }
}

/******************************************************************************
*
*	���������� ��������� 
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
							alUnlink(&v->node);						// �������� �� ������ �������	
							alLink(&v->node, &s->pLameList);		// � ������ ������������
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
*	���������� �������� �����������
*
*******************************************************************************/

void alSynUpdate( ALSynth* s )
{
Int16 * ptr; 
/* Get system elapsed time */ 
//struct timespec before; 
//struct timespec after; 
long delta=0;

	// ��������� �����
	ptr = fcodecWaitBuf();				// ������� �����
	// ������������������ ���������
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
*	������� � �������������� ����������
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
*	���������� ����������
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
*	��������� ������� ��� �����������
*	������ �������� ���������� ����������
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
*	�������������� ��������� ��������� ��� ���������� ���������
*	� ������� ��������� �������.
*
*	sVinfo* voice		��������� ������
*	ALMicroTime time	����� �� ������� ���������� ������� ���������
*	UInt16 vol			��������� ������� ���������� �������
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
*	������������� �������� ��� ������
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
*	������������� ���� (������� ��������) ��� ������
*
*	�������� ratio = 0x10000 �������� �������������� ���� ��� ����
*			 ratio = 0x20000 �������� �������������� ���� �� ������ ����
*			 ratio = 0x08000 �� ������ ����
*			 0 < ratio 0x2000
*			 ���� rate>2 �� rate �������������� �� ����
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
*	������������� ������� FX ��� ������
*	���� �������� ���� MIX_VOL_MAX �� �� ����� ��� ������ 
*	������������ ������� �����. ���� MIX_VOL_MIN �� ������
*	������ �����
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
*	������������� ��������� ������
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
*	���������� ��������� ������
*
*	return Int16 		���������
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
*	������ ��������������� �������� �����
*
*
*******************************************************************************/

void    alSynStartVoice( ALSynth * s, ALVoice *voice, ALWaveTable *w )
{
	ALRawLoop * loop;
	PVoice    * pv = voice->pvoice;

	pv->fadeval = 0x7fff;
	voice->wavetable= w;						// ��������� �������� �����
    pv->state	= w->flags | AL_SF_ACTIVE;		// ����� ������
	pv->pos		= w->base;    					// ����� ������
												// ����� ������� � ������� ������������
	if(pv->state & AL_SF_LOOP)
    {	loop = w->waveInfo.rawWave.loop;
    	pv->end 	= loop->end + w->base;     	// ����� �����
    	pv->endsub 	= loop->end-loop->start+1;	// ������ ��� ���������� �����
	}
	else
	{	pv->end	= w->base + w->len - 1;    		// ����� ������
	}
}

/******************************************************************************
*
*	void    SynStartVoiceParams( ALVoice *v, ALWaveTable *w,
*							Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix
*							ALMicroTime t)
*
*	������ ��������������� �������� �����
*
*
*******************************************************************************/

void    alSynStartVoiceParams(  ALSynth * s, ALVoice *v, ALWaveTable *w,
                              Int32 pitch, Int16 vol, ALPan pan, Int16 fxmix,
                              ALMicroTime t)
{
   alSynStartVoice( s, v, w);		// ������ ������
	 alSynSetFXMix( s, v, fxmix);	// FX
	 alSynSetPitch( s, v, pitch);	// �����������
	   alSynSetPan( s, v, pan);		// ��������
	   alSynSetVol( s, v, vol, t);	// ���������	
	  alSynSetGain( s, v, 0x7fff);  // ������� ������������
}

void alSynStopVoice(ALSynth *drvr, ALVoice *voice)
{
	voice->pvoice->state &= AL_SF_ACTIVE;					// ��������� ������
	alUnlink(&voice->pvoice->node);						// �������� �� ������ �������	
	alLink(&voice->pvoice->node, &drvr->pLameList);		// � ������ ������������
}

/******************************************************************************
*
*	Int16   SynAllocVoice( ALSynth *s, ALVoice *v, UInt16 priority )
*
*	����������� � ������ ���� �� �������������� �������.
*	��! ���������� 0 ���� ��� �� ���������
*	�������� ������ �����.
*	1. ������ ������� ��������� ����� �� pFreeList
*	2. �����  ������� ������������ ����� � pLameList. � ���� ���� �������� 
*      ������ ���������� ��������� ��������� 0. 
*   3. ���� ����� ����������������� ����� � pAllocList � ���� ��� ���������
*      ���� ��� ����� �������������� �� �� ������ ��������.
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
	{	v->pvoice = s->pFreeList.next;					// ��������� � ������ ���� �������������� �����
		alUnlink(s->pFreeList.next);					// �������� �� ������ ���������
		alLink( &v->pvoice->node, &s->pAllocList);		// ��������� � ������ �����������
		goto good;
	}
	if( s->pLameList.next != NULL )
	{	v->pvoice = s->pLameList.next;					// ��������� � ������ ���� �������������� �����
		alUnlink(s->pLameList.next);					// �������� �� ������ ������������
		alLink( &v->pvoice->node, &s->pAllocList);		// ��������� � ������ �����������
		goto good;
	}
	pvoice = s->pAllocList.next;
	while(pvoice != NULL)
	{	curvol = mult(pvoice->vol, pvoice->fadeval);
		if((pvoice->priority <= priority) && (curvol < minvolume))
		{	minvolume = curvol;
			minpvoice = pvoice;
		}	
	//	if(pvoice->priority < minpriority)				// ������ ����� ������ ���������
	//	{	minpriority = pvoice->priority;				// ������ �� �����-�����
	//		minpvoice = pvoice;							// � ��������� �� ����
	//	}
		pvoice = pvoice->node.next;						// ���������
	}

//	if(priority >= minpriority)							// ������ ���������� �����
//	{	v->pvoice = minpvoice;							// ����������� �� ����������
//		goto good;
//	}
	if(minpvoice==NULL)	return 0;
	else v->pvoice = minpvoice;							// ����������� �� ����������
good:
	v->pvoice->priority = priority;						// � ����������� ������ ��������� ���������
	v->priority = priority;								// � ������������ ����
	v->pvoice->vvoice = v;
	return 1;
}

Int16   alSynReAllocVoice( ALSynth *s, ALVoice *vold, ALVoice *vnew, UInt16 priority)
{
	vnew->pvoice = vold->pvoice;
	vold->pvoice = NULL;
	vnew->pvoice->priority = priority;					// � ����������� ������ ��������� ���������
	vnew->priority = priority;							// � ������������ ����
	vnew->pvoice->vvoice = vnew;
	return 1;
}

/******************************************************************************
*
*	void    alSynFreeVoice(ALSynth *s, ALVoice *voice)
*
*	����������� �������������� �����
*
*	��! ���������� 0 ���� ��� �� ���������
*
*******************************************************************************/

void    alSynFreeVoice(ALSynth *s, ALVoice *voice)
{
	alUnlink(&voice->pvoice->node);						// �������� �� ������ �������	
	alLink(&voice->pvoice->node, &s->pFreeList);		// � ������ ���������
	voice->pvoice = NULL;								// ����� ������ �� ����������
}

void	alSynFadeOut(ALSynth *s, ALVoice *voice)
{
	voice->pvoice->state |= AL_SF_FADEOUT;
}

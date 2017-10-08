/******************************************************************************
*
*	ПОИСК СВОБОДНОГО КАНАЛА ДЛЯ ВОСПРОИЗВЕДЕНИЯ
*
*******************************************************************************/

sVinfo*	synt_find_liked_voice( ALInstrument* inst, UInt16 note, UInt16 mchanel );
sVinfo*	synt_find_liked_voice( ALInstrument* inst, UInt16 note, UInt16 mchanel )
{	// Поиск подобного канала
int ch;

	for( ch=0; ch<PCHANELS ; ch++ )
	{
		if(((UInt16)vinfo[ch].inst == (UInt16)inst) && (vinfo[ch].note==note) && (vinfo[ch].mchan == mchanel))
		{	// найден и инструмент и нота и в томже канале
			return &vinfo[ch];
		}
	}
	return NULL;
}

sVinfo*	synt_find_free_voice( UInt16 priority );
sVinfo*	synt_find_free_voice( UInt16 priority )
{	// Поиск свободного или низкоприоритетного канала

	int ch;
	int tpr=11, tch; 	// tpr = max priority + 1
	
	for( ch=0; ch<PCHANELS ; ch++ )
	{
		if(vinfo[ch].active==0) return &vinfo[ch];	// найден свободный канал
		if(vinfo[ch].priority < tpr)
		{	// найден более низкий приоритет
			tpr = vinfo[ch].priority;
			tch = ch;			
		}
	}
	// Найден самый низкоприоритетный канал
	// но если его приоритет выше нового то
	// возвращаем NULL
	if(tpr>priority) return NULL;
	// Возвращаем канал с самым низким приоритетом
	return &vinfo[tch];
}

/******************************************************************************
*
*	ОПРЕДЕЛЕНИЯ СЕМПЛА ИЗ ИНСТРУМЕНТА И НОТЫ
*
*******************************************************************************/

ALSound*	synt_find_sound( ALInstrument* inst, UInt16 note );
ALSound*	synt_find_sound( ALInstrument* inst, UInt16 note )
{
	Int16 		sound_count = inst->soundCount;
	Int16 		sidx;
	ALSound* 	sound;
	ALKeyMap*	keymap;
	
	for( sidx = 0 ; sidx < sound_count ; sidx ++ )
	{	// перебираем все звуки 
		sound = inst->soundArray[sidx];
		// проверяем допустимость ноты диапазону карты клавиатуры
		keymap = sound->keyMap;
		if(((keymap->keyMin) >= note) & (keymap->keyMax >= note))
		{	// нашли диапазон подходит для ноты
			return	sound;	
		}
	}
	// Ничего не нашли подходящего
	return NULL;
}

/******************************************************************************
*
*	ЗАПУСК ВОСПРОИЗВЕДЕНИЯ ИНСТРУМЕНТА
*
*	
*
*
*
*
*
*
*
*******************************************************************************/
void synt_play_instrument( ALInstrument* inst, UInt16 key, UInt16 velocity, UInt16 mchanel );
void synt_play_instrument( ALInstrument* inst, UInt16 key, UInt16 velocity, UInt16 mchanel )
{
	// найдём свободный канал
	ALSound* sound;
	ALKeyMap* keymap;
	sVinfo*	voice;
	ALWaveTable* wave;
	ALRawLoop* loop;
	
	if( (voice = synt_find_liked_voice( inst, key, mchanel ))==NULL)
	{	// подобный голос не найден
		// ищем пустой голос. И если
		// не находим то ничего не делаем
	 	if((voice = synt_find_free_voice( inst->priority ))==NULL) return;
	}	// голос найден
	
	// теперь определим семпл который будет использован	
	if((sound = synt_find_sound( inst, note ))==NULL) return;

	keymap = sound->keyMap;
	// достаточна ли сила нажатия ?
	if( velocity < keymap->velocityMin ) return;
	// всё нормально сила больше минимума
	// ограничим сверху, если это необходимо
	if( velocity > keymap->velocityMax ) velocity = keymap->velocityMax; // огранчим 
	
	wave = sound->wavetable;	// начало информации о волне
	loop = wave->waveInfo.rawWave.loop;
	
	voice->kick=1;              		// =1 -> sample has to be restarted
    voice->active=1;            		// =1 -> sample is playing
    voice->flags = wave->flags;    		// 16/8 bits looping/one-shot
    voice->start = wave->base ; 		// старт семпла
    voice->end = wave->base+wave->len;	// конец семпла
    voice->endsub = loop->end-loop->start; // отнять при достижении конца
    voice->repend = loop->end;             // конец петли
    
    voice->priority = inst->priority; // приоритет семпла
	voice->note = note;			// нота
	voice->mchan = mchanel;		// номер миди канала
	voice->inst = inst;			// инструмент звучащий в канале	
	voice->sound = sound;		// звук звучащий в канале
    voice->envelope = sound->envelope;	// огибающая
    voice->keyMap = keymap;		// раскладка клавиатуры
    voice->wavetable = wave;	// параметры волновой формы
    voice->loop = loop;     	// параметры петли
	synt_env_start( voice );	// инициализировали переменные
	
    voice->frq;                 // текущая частота
    voice->vol;                 // текущая громкость
    voice->pan;                 // текущая панорама
    voice->pos;	            	// текущая позиция в семпле
	voice->fpos;				// дробная часть позиции
    voice->increment;           // фиксированная точка инкремент
	voice->rvol;				// громкость правого канала					
	voice->lvol;				// громкость левого канала
}
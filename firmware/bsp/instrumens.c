/******************************************************************************
*
*	����� ���������� ������ ��� ���������������
*
*******************************************************************************/

sVinfo*	synt_find_liked_voice( ALInstrument* inst, UInt16 note, UInt16 mchanel );
sVinfo*	synt_find_liked_voice( ALInstrument* inst, UInt16 note, UInt16 mchanel )
{	// ����� ��������� ������
int ch;

	for( ch=0; ch<PCHANELS ; ch++ )
	{
		if(((UInt16)vinfo[ch].inst == (UInt16)inst) && (vinfo[ch].note==note) && (vinfo[ch].mchan == mchanel))
		{	// ������ � ���������� � ���� � � ����� ������
			return &vinfo[ch];
		}
	}
	return NULL;
}

sVinfo*	synt_find_free_voice( UInt16 priority );
sVinfo*	synt_find_free_voice( UInt16 priority )
{	// ����� ���������� ��� ������������������ ������

	int ch;
	int tpr=11, tch; 	// tpr = max priority + 1
	
	for( ch=0; ch<PCHANELS ; ch++ )
	{
		if(vinfo[ch].active==0) return &vinfo[ch];	// ������ ��������� �����
		if(vinfo[ch].priority < tpr)
		{	// ������ ����� ������ ���������
			tpr = vinfo[ch].priority;
			tch = ch;			
		}
	}
	// ������ ����� ����������������� �����
	// �� ���� ��� ��������� ���� ������ ��
	// ���������� NULL
	if(tpr>priority) return NULL;
	// ���������� ����� � ����� ������ �����������
	return &vinfo[tch];
}

/******************************************************************************
*
*	����������� ������ �� ����������� � ����
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
	{	// ���������� ��� ����� 
		sound = inst->soundArray[sidx];
		// ��������� ������������ ���� ��������� ����� ����������
		keymap = sound->keyMap;
		if(((keymap->keyMin) >= note) & (keymap->keyMax >= note))
		{	// ����� �������� �������� ��� ����
			return	sound;	
		}
	}
	// ������ �� ����� �����������
	return NULL;
}

/******************************************************************************
*
*	������ ��������������� �����������
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
	// ����� ��������� �����
	ALSound* sound;
	ALKeyMap* keymap;
	sVinfo*	voice;
	ALWaveTable* wave;
	ALRawLoop* loop;
	
	if( (voice = synt_find_liked_voice( inst, key, mchanel ))==NULL)
	{	// �������� ����� �� ������
		// ���� ������ �����. � ����
		// �� ������� �� ������ �� ������
	 	if((voice = synt_find_free_voice( inst->priority ))==NULL) return;
	}	// ����� ������
	
	// ������ ��������� ����� ������� ����� �����������	
	if((sound = synt_find_sound( inst, note ))==NULL) return;

	keymap = sound->keyMap;
	// ���������� �� ���� ������� ?
	if( velocity < keymap->velocityMin ) return;
	// �� ��������� ���� ������ ��������
	// ��������� ������, ���� ��� ����������
	if( velocity > keymap->velocityMax ) velocity = keymap->velocityMax; // �������� 
	
	wave = sound->wavetable;	// ������ ���������� � �����
	loop = wave->waveInfo.rawWave.loop;
	
	voice->kick=1;              		// =1 -> sample has to be restarted
    voice->active=1;            		// =1 -> sample is playing
    voice->flags = wave->flags;    		// 16/8 bits looping/one-shot
    voice->start = wave->base ; 		// ����� ������
    voice->end = wave->base+wave->len;	// ����� ������
    voice->endsub = loop->end-loop->start; // ������ ��� ���������� �����
    voice->repend = loop->end;             // ����� �����
    
    voice->priority = inst->priority; // ��������� ������
	voice->note = note;			// ����
	voice->mchan = mchanel;		// ����� ���� ������
	voice->inst = inst;			// ���������� �������� � ������	
	voice->sound = sound;		// ���� �������� � ������
    voice->envelope = sound->envelope;	// ���������
    voice->keyMap = keymap;		// ��������� ����������
    voice->wavetable = wave;	// ��������� �������� �����
    voice->loop = loop;     	// ��������� �����
	synt_env_start( voice );	// ���������������� ����������
	
    voice->frq;                 // ������� �������
    voice->vol;                 // ������� ���������
    voice->pan;                 // ������� ��������
    voice->pos;	            	// ������� ������� � ������
	voice->fpos;				// ������� ����� �������
    voice->increment;           // ������������� ����� ���������
	voice->rvol;				// ��������� ������� ������					
	voice->lvol;				// ��������� ������ ������
}
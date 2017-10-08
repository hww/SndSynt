// Обработчик сексенсора и его основные компоненты

ALMicroTime	    	alSeqpHandler( void * data );
ALMicroTime			alSeqpFrameHandler( void * data );
void			alSeqpEnvTimers( ALSeqPlayer * seqp, ALMicroTime delta );
void 		alSeqpPlayer( ALSeqPlayer * seqp );

// Утилиты

ALSound * 	alSeqpGetSound( ALInstrument * ins, u8 key, u8 vel );
UInt32 		alGetLinearRate(UWord16 note, Int16 finetune);

// Обработка Миди событий

void			alSeqpVoiceOff( ALSeqPlayer * seqp, ALVoiceState * vs );
void	    	alSeqpKeyOn( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity );
void			alSeqpKeyOff( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity );

// Установка параметров голоса

void 		alSeqpSetPitch( ALSeqPlayer * seqp, ALVoiceState * vs);
void 		alSeqpChangePitch( ALSeqPlayer * seqp, UInt16 channel);
void			alSeqpStartEnvelope( ALSeqPlayer * seqp, ALVoiceState * vs );
void			alSeqpStartOsc( ALSeqPlayer * seqp,  ALVoiceState * vs );
void 		alSeqpVolMix( ALSeqPlayer * seqp, ALVoiceState *vs );
void 		alSeqpPanMix( ALSeqPlayer * seqp, ALVoiceState *vs );

// Подбор подходящего голоса и освобождение голосов

ALVoiceState * alSeqpGetFreeVoice( ALSeqPlayer * seqp );
ALVoiceState * alSeqpFindVoiceChl( ALVoiceState * vs, UWord16 chan );
ALVoiceState * alSeqpFindVoiceChlKey( ALVoiceState * vs, UWord16 chan, u8 key );
void     	alSeqpFreeVoice( ALSeqPlayer * seqp, ALVoiceState * voice );
bool 		alSeqpCheckVoice( ALSeqPlayer * seqp, ALVoiceState * voice );
void 		alSeqpFlushEventsOfVoice( ALSeqPlayer * seqp, ALVoiceState * vs );

// обработчики сообщений

void     	alSeqpSwitchEvent( ALSeqPlayer * seqp, ALEvent * event);
ALMicroTime 	alSeqpEnvVolEvent( ALSeqPlayer * seqp, ALEvent * event );
ALMicroTime 	alSeqpEnvPanEvent( ALSeqPlayer * seqp, ALEvent * event );
ALMicroTime	alSeqpVibOscEvent( ALSeqPlayer * seqp, ALEvent * event  );

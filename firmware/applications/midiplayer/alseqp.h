// Sequencer

ALMicroTime	alSeqpHandler( void * data );
ALMicroTime	alSeqpFrameHandler( void * data );
void		alSeqpEnvTimers( ALSeqPlayer * seqp, ALMicroTime delta );
void 		alSeqpPlayer( ALSeqPlayer * seqp );

// Utilities

ALSound * 	alSeqpGetSound( ALInstrument * ins, u8 key, u8 vel );
UInt32 		alGetLinearRate(UWord16 note, Int16 finetune);

// Midi events 

void		alSeqpVoiceOff( ALSeqPlayer * seqp, ALVoiceState * vs );
void	    alSeqpKeyOn( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity );
void		alSeqpKeyOff( ALSeqPlayer * seqp, UWord16 chan, u8 key, u8 velocity );

// Voice parameters setters

void 		alSeqpSetPitch( ALSeqPlayer * seqp, ALVoiceState * vs);
void 		alSeqpChangePitch( ALSeqPlayer * seqp, UInt16 channel);
void		alSeqpStartEnvelope( ALSeqPlayer * seqp, ALVoiceState * vs );
void		alSeqpStartOsc( ALSeqPlayer * seqp,  ALVoiceState * vs );
void 		alSeqpVolMix( ALSeqPlayer * seqp, ALVoiceState *vs );
void 		alSeqpPanMix( ALSeqPlayer * seqp, ALVoiceState *vs );

// Find best voice 

ALVoiceState * alSeqpGetFreeVoice( ALSeqPlayer * seqp );
ALVoiceState * alSeqpFindVoiceChl( ALVoiceState * vs, UWord16 chan );
ALVoiceState * alSeqpFindVoiceChlKey( ALVoiceState * vs, UWord16 chan, u8 key );
void     	alSeqpFreeVoice( ALSeqPlayer * seqp, ALVoiceState * voice );
bool 		alSeqpCheckVoice( ALSeqPlayer * seqp, ALVoiceState * voice );
void 		alSeqpFlushEventsOfVoice( ALSeqPlayer * seqp, ALVoiceState * vs );

// Event dispatcher

void     	alSeqpSwitchEvent( ALSeqPlayer * seqp, ALEvent * event);
ALMicroTime alSeqpEnvVolEvent( ALSeqPlayer * seqp, ALEvent * event );
ALMicroTime alSeqpEnvPanEvent( ALSeqPlayer * seqp, ALEvent * event );
ALMicroTime	alSeqpVibOscEvent( ALSeqPlayer * seqp, ALEvent * event  );

;------------------------------------------------------------------------------
; Module Name:	cpsi_api.asm
;
; Last Update:	26.Sep.2000
;
; Author     :  Manohar Babu
;
; Description:	This module is designed to provide an API interface to
;		the Call Progress, and Silence detection routines.
;
;------------------------------------------------------------------------------

    include "cpt_api.inc"                ; include CPT definitions
	
	SECTION cpt_data
;------------------------------------------------------------------------------ 
; External Variable Definitions
;------------------------------------------------------------------------------ 

	GLOBAL	cpt_level
	GLOBAL	n_e
	GLOBAL  decimate_flag

;------------------------------------------------------------------------------ 
; Local Scratch Variable Definitions 
;------------------------------------------------------------------------------ 
	ORG     x:

cpt_on_timer    ds      1               ;timer for call progress tone on
cpt_off_timer   ds      1               ;timer for call progress tone off
cpt_state       ds      1               ;call progress debounce state variable
cpt_last_on     ds      1               ;history for call progress on time
cpt_last_off    ds      1               ;history for call progress off time
cpt_status      ds      1               ;status concerning call progress tone
cpt_bursts      ds      1               ;counter for bursts of call progress
cpt_last_state  ds      1               ;history for call progress state
cpt_last_code   ds      1               ;history for call progress code value
cpt_last_group  ds      1               ;history for call progress group
previous_cpt    ds      1               ;previous call progress tone value

sil_on_timer    ds      1               ;timer for silence on
sil_off_timer   ds      1               ;timer for silence off
sil_status      ds      1               ;status concerning the silence

cpt_level       ds      2               ; Call Progress detection threshold
n_e             ds      2               ;Adaptive Noise level
file_out2       ds      1
decimate_flag   ds      1               ;flag to decimate by 2
		
    ENDSEC
	

	SECTION     cpt_code			
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	
	;--- API function Prototypes ---;
	GLOBAL    SILENCE_DETECT
	GLOBAL    SILENCE_DEBOUNCE 
	GLOBAL    FCALLPROGRESS_DETECT_INIT
	GLOBAL    CALLPROGRESS_DETECT 
	GLOBAL    CALLPROGRESS_DEBOUNCE
	GLOBAL    CALLPROGRESS_DECODE

;------------------------------------------------------------------------------
; Module Code
;------------------------------------------------------------------------------
	ORG       p:


;------------------------------------------------------------------------------
; Routine:	return_val = SILENCE_DETECT ()
;
; Description:	This routine performs silence detection on the samples found
;		in the ANA_BUF analysis buffer.  If silence is detected, 
;		a non-zero value is returned, else zero is returned.
;
; Stack Parameters:
;
;	------------
;	 return_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	N/A
;
;	Output Parms:	N/A
;
;	Return Value:	1 if silence detected, 0 otherwise
;
; Other Input/Output:	N/A
;
; Pseudocode:
;		SIL_DEC ()
;               return
;
;------------------------------------------------------------------------------

SILENCE_DETECT:

	; define stack positions of routine parameters
	define SP_return_val	'x:(sp-2)'
	
	; save context if necessary

	jsr	   SIL_DEC                      ;test against thresholds
	
	move   x0,SP_return_val             ;place return value on stack
	rts	                                ;return

	; undefine stack positions of routine parameters
	undef  SP_return_val
	
;------------------------------------------------------------------------------
; Routine:	return_val = SILENCE_DEBOUNCE (boolean, on_time)
;
; Description:	This routine performs debounce logic for silence detection.
;
; Stack Parameters:
;
;	------------
;	  boolean	x:(sp-4)
;	------------
;	  on_time	x:(sp-3)
;	------------
;	 return val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	boolean = value returned by SILENCE_DETECT routine 
;		           (not modified during routine)
;
;	Output Parms: 	on_time = number of consecutive frames silence has been 
;			   detected on
;
;	Return Value:	status of the silence detection (see the tone_api.inc 
;			file for bit definitions)
;
; Other Input/Output:	N/A
;
; Pseudocode:
;		sil_status &= $FF00
;		sil_status |= boolean
;		if (boolean == 0)
;			sil_off_timer++
;			if (sil_status & DEBOUNCED_OFF)
;				sil_on_timer = 0
;			else
;				if (sil_off_timer >= MIN_SIL_OFF)
;					sil_status |= DEBOUNCED_OFF
;					sil_status &= !(DEBOUNCED_ON)
;					sil_on_timer = 0
;				endif
;			endif
;		else
;			sil_on_timer++
;			if (sil_status & DEBOUNCED_ON)
;				sil_off_timer = 0
;			else
;				if (sil_on_timer >= MIN_SIL_ON)
;					sil_status |= DEBOUNCED_ON
;					sil_status &= !(DEBOUNCED_OFF)
;					sil_off_timer = 0
;				endif
;			endif
;		endif
;
;		return_val = sil_status
;		on_time = sil_on_timer
;		return
;		
;------------------------------------------------------------------------------

SILENCE_DEBOUNCE:

	; define stack positions of routine parameters
	define SP_boolean	'x:(sp-4)'
	define SP_on_time	'x:(sp-3)'
	define SP_return_val	'x:(sp-2)'

	; save context if necessary
	
	move 	SP_boolean,y1               ;y1 = boolean
	move    x:sil_status,y0            	;y0 = sil_status
	move	x:sil_on_timer,a            ;a = sil_on_timer
	move	x:sil_off_timer,b           ;b = sil_off_timer
	
	bfclr	#$FF,y0                     ;sil_status &= $FF00
	or	    y1,y0                       ;sil_status |= boolean

	;--- check if silence was detected ---;
	tstw	y1                          ;if (boolean != 0)
	bne     _sil_detected               ;goto _sil_detected
	
;--- silence has NOT been detected in current frame ---;
_sil_not_detected
	incw	b                     		;sil_off_timer++

	;--- check if already debounced off ---;
	brclr	#DEBOUNCED_OFF,y0,_min_off	;if !(sil_status&DEBOUNCED_OFF)
	                                    ;   goto _min_off
	clr	    a                           ;else sil_on_timer = 0
	bra	    _exit_detect                ;goto _exit_detect 
						
_min_off	
	;--- check debounced off condition ---;
	cmp     #MIN_SIL_OFF,b              ;if (min_off > sil_off_timer)
	blt     _exit_detect                ;goto _exit_detect
	
	;--- at this point, silence has been debounced off ---;
	bfset	#DEBOUNCED_OFF,y0           ;sil_status |= DEBOUNCED_OFF
	bfclr	#DEBOUNCED_ON,y0            ;sil_status &= !(DEBOUNCED_ON)
	clr     a                           ;sil_on_timer = 0
	bra     _exit_detect                ;goto _exit_detect 
	
;--- silence has been detected in current frame ---;
_sil_detected
	incw	a                     		;sil_on_timer++

	;--- check if already debounced on ---;
	brclr	#DEBOUNCED_ON,y0,_min_on	;if !(sil_status&DEBOUNCED_ON)
                                        ;   goto _min_on
	clr	    b                           ;sil_off_timer = 0
	bra     _exit_detect                ;goto _exit_detect 
						
_min_on
	;--- check debounced on condition ---;
	cmp     #MIN_SIL_ON,a              ;if (min_on > sil_on_timer)
	blt     _exit_detect               ;goto _exit_detect
	
	;--- at this point, silence has been debounced on ---;
	bfset	#DEBOUNCED_ON,y0           ;sil_status |= DEBOUNCED_ON
	bfclr	#DEBOUNCED_OFF,y0          ;sil_status &= !(DEBOUNCED_OFF)
	clr	    b                          ;sil_off_timer = 0

_exit_detect
	move	y0,SP_return_val           ;return_val = sil_status
	move	a,SP_on_time               ;on_time = sil_on_timer

	move    y0,x:sil_status	           ;update sil_status
	move	a,x:sil_on_timer           ;update sil_on_timer
	move	b,x:sil_off_timer          ;update sil_off_timer
	rts

	; undefine stack positions of routine parameters
	undef SP_boolean
	undef SP_on_time
	undef SP_return_val



;------------------------------------------------------------------------------
; Routine:	CALLPROGRESS_DETECT_INIT (level)
;
; Description:	This routine performs initialization for the call progress 
;		tone detection module by resetting state variables and 
;		initializing thresholds.
;
; Stack Parameters:
;
;	------------
;	    level	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	level = call progress tone absolute threshold
;
;	Output Parms:	N/A
;
;	Return Value:	N/A
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------
FCALLPROGRESS_DETECT_INIT:
	; define stack positions of routine parameters

	move	#0,x0
	move	x0,x:cpt_on_timer           ; cpt_on_timer = 0
	move	x0,x:cpt_off_timer          ; cpt_off_timer = 0
	move	x0,x:cpt_status             ; cpt_status = 0
	move	x0,x:cpt_last_on            ; cpt_last_on = 0
	move	x0,x:cpt_last_off           ; cpt_last_off = 0
	move	x0,x:cpt_bursts	            ; cpt_bursts = 0
	move    x0,x:cpt_last_state         ; cpt_last_state = 0
	move	x0,x:sil_on_timer           ; sil_on_timer = 0
	move	x0,x:sil_off_timer	        ; sil_off_timer = 0
	move	x0,x:sil_status             ; sil_status = 0

    move    #ANA_BUF,x:ana_buf_ptr      ;Initialize the sample buffer
    move    x0,x:ana_buf_count          ;  pointer and the sample count
	move    #1,x:decimate_flag          ;Initialize to pick the first sample

	move	#no_cpt,x:cpt_state	        ; cpt_state = no_cpt

	move    #INVALID_TONE,x0
	move    x0,x:cpt_last_code          ; cpt_last_code = INVALID_TONE
	move    x0,x:cpt_last_group         ; cpt_last_group = INVALID_TONE
	move    x0,x:previous_cpt           ; previous_cpt = INVALID_TONE

	move    #NOISE_LEVEL1,x:n_e     	;Maximum noise level (upper word)
	move    #NOISE_LEVEL2,x:n_e+1       ;Maximum noise level (lower word)		
	rts 


;------------------------------------------------------------------------------
; Routine:	return_val = CALLPROGRESS_DETECT ()
;
; Description:	This routine performs call progress tone detection on the
;		samples found in the ANA_BUF analysis buffer.  If call 
;		progress is detected, a non-zero value is returned, else 
;		zero is returned.
;
; Stack Parameters:
;
;	------------
;	 return_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	a = sig_energy for CPT computed over 80 samples at 4Kz
;                           and is double precision number
;
;	Output Parms:	N/A
;
;	Return Value:	1 if Call Progress Tone detected, 0 otherwise
;
; Other Input/Output:	N/A
;
; Pseudocode:
;               NEWNNUM_CPT()
;------------------------------------------------------------------------------
CALLPROGRESS_DETECT:
	; define stack positions of routine parameters
	define SP_return_val	'x:(sp-2)'

	; save context if necessary
    move    a,x:sig_energy             ;Save sig_energy for CPT
	move    a0,x:sig_energy+1

	jsr     NEWNUM_CPT
    jsr     TST_CPT
	tstw    x0
	bne     _cpt_detected
	move    #INVALID_TONE,x0

_cpt_detected      
	move	x0,SP_return_val	       ;place return value on stack
	rts	                               ;return

	; undefine stack positions of routine parameters
	undef	SP_return_val
	


;------------------------------------------------------------------------------
; Routine:	return_val = CALLPROGRESS_DEBOUNCE (tone_val, on_time, off_time)
;
; Description:	This routine performs debounce logic for Call Progress Tone
;		detection.
;
; Stack Parameters:
;
;	------------
;	  tone_val	x:(sp-5)
;	------------
;	  on_time	x:(sp-4)
;	------------
;	  off_time	x:(sp-3)
;	------------
;	 return_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	tone_val = value returned by CALLPROGRESS_DETECT 
;			   and SILENCE_DETECT routine
;
;	Output Parms:	tone_val = call progress tone group actively being 
;			   debounced
;			on_time = number of consecutive frames call progress 
;			   has been detected on
;			off_time = number of consecutive frames call progress 
;			   has been detected off
;
;	Return Value:	status of the call progress detection (see the 
;			tone_api.inc file for bit definitions)
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------

CALLPROGRESS_DEBOUNCE:

	; define stack positions of routine parameters
    define SP_tone_val    'x:(sp-5)' 
    define SP_on_time     'x:(sp-4)'
    define SP_off_time    'x:(sp-3)'
    define SP_return_val  'x:(sp-2)'

	; save context if necessary
	
    move 	SP_tone_val,y0             ;y0 = tone_val
    move    x:cpt_status,y1            ;y1 = cpt_status
    move	x:cpt_on_timer,a           ;a = cpt_on_timer
    move	x:cpt_off_timer,b          ;b = cpt_off_timer

    ;--- switch (cpt_state)	---;
    move	x:cpt_state,x0             ;x0 = cpt_state
    lea	    (sp)+
    move	x0,x:(sp)+
    move	sr,x:(sp)
    rts					
	

    ;--- case no_cpt:  ---;
no_cpt
    cmp     #SILENCE,y0	               ;if (tone_val == SILENCE)
    jeq     exit_cpt_debounce          ;goto exit_cpt_debounce
    cmp     #INVALID_TONE,y0           ;if (tone_val == INVALID_TONE)
    jeq     exit_cpt_debounce          ;goto exit_cpt_debounce
    
    jmp	new_cpt                        ;goto new_cpt
	
;--- case cpt_on:  ---;
cpt_on
    cmp     #INVALID_TONE,y0           ;if (tone_val != INVALID_TONE)
    bne     _check_silence             ;goto _check_silence

    move    #noisy_cpt,x:cpt_state     ;else cpt_state = noisy_cpt
    jmp     exit_cpt_debounce          ;goto exit_cpt_debounce
	
_check_silence
    cmp     #SILENCE,y0                ;if (tone_val != SILENCE)
    beq     end_cpt                    ;goto _end_cpt
    bfclr   #INVALID2,y1               ;Clear invalid2 bit in cpt status
    bra	    check_previous_cpt             ;goto check_previous_cpt


;--- case noisy_cpt:  ---;
noisy_cpt
        
    cmp     #INVALID_TONE,y0           ;if (tone_val == INVALID_TONE)
    beq     end_cpt	                   ;goto end_cpt
					
    cmp     #SILENCE,y0                ;if (tone_val == SILENCE)
    beq     end_cpt	                   ;goto end_cpt

    move	#cpt_on,x:cpt_state		   ;cpt_state = cpt_on
    bra	    check_previous_cpt         ;goto check_previous_cpt
	
end_cpt	
    bfset   #INVALID2,y1              ;Allow 20 msec invalid between
    jcc     exit_cpt_debounce         ;  2 tone on's
    bftstl  #DEBOUNCED_ON,y1          ;if !(cpt_status&DEBOUNCED_ON)
    jcs     reset                     ;    goto reset
    move    #1,b                      ;else cpt_off_timer = 1
    move    #cpt_silence,x:cpt_state  ;cpt_state = cpt_silence
    jmp     exit_cpt_debounce
	
;--- case cpt_silence:  ---;
cpt_silence 
    cmp     #INVALID_TONE,y0          ;if (tone_val == INVALID_TONE)
    bne     _check_silence            ;goto _check_silence
	
    move    #noisy_sil,x:cpt_state    ;else cpt_state = noise_sil
    bra     exit_cpt_debounce         ;goto exit_cpt_debounce

_check_silence
    cmp     #SILENCE,y0               ;if (tone_val == SILENCE)
    bne     new_cpt	                  ;goto new_cpt
	
    ; --- sahoo --- 08/01 ---
    ;	move    #0,x:previous_cpt
    bra     check_cpt_off             ;goto check_cpt_off

	
    ;--- case noisy_sil:  ---;
noisy_sil
    cmp    #INVALID_TONE,y0           ;if (tone_val != INVALID_TONE)
    beq    reset                      ;goto reset
	
    cmp    #SILENCE,y0	              ;if (tone_val != SILENCE)
    bne    new_cpt	                  ;goto new_cpt
	
    move   #cpt_silence,x:cpt_state   ;cpt_state = cpt_silence
    bra    check_cpt_off              ;goto check_cpt_off
	
new_cpt
    move   #cpt_on,x:cpt_state	      ;cpt_state = cpt_on

    ; --- sahoo --- 08/01 ---
    clr    y1                         ;cpt_status = 0
    clr    b                          ;cpt_off_timer = 0
    move   #1,a                       ;cpt_on_timer = 1
    move   y0,x:previous_cpt          ;previous_cpt = tone_val
    bra    exit_cpt_debounce          ;goto exit_cpt_debounce

check_previous_cpt
    cmp    x:previous_cpt,y0          ;if (tone_val != previous_cpt)
    bne    new_cpt                    ;goto new_cpt
	
    incw   a                          ;cpt_on_timer ++
    cmp    #MIN_CPT_ON,a              ;if (cpt_on_timer < MIN_CPT_ON)
    blt    exit_cpt_debounce          ;goto exit_cpt_debounce
	
    bfset  #DEBOUNCED_ON,y1           ;cpt_status |= DEBOUNCED_ON

    ; --- sahoo --- 08/01 ---
    ;	clr     b                         ;Clear the cpt_off_timer
    bfclr  #DEBOUNCED_OFF,y1          ;Clear the Debounce off
    bra    exit_cpt_debounce

check_cpt_off
    incw   b                          ;off_timer++

    cmp    #MAX_CPT_OFF,b             ;if (cpt_off_timer>MAX_CPT_OFF)
    bgt    reset                      ;goto reset
	
    cmp    #MIN_CPT_OFF,b             ;if (cpt_off_timer<MIN_CPT_OFF)
    blt    exit_cpt_debounce          ;goto exit_cpt_debounce
	
    bfset  #DEBOUNCED_OFF,y1          ;cpt_status |= DEBOUNCED_OFF

    ; --- sahoo --- 08/01 ---
    ;	clr     a                     ;Clear the cpt_on_timer
    bfclr  #DEBOUNCED_ON,y1           ;Clear the Debounce on
    bra    exit_cpt_debounce

reset
    move   #no_cpt,x:cpt_state	      ;cpt_state = no_cpt
    clr    y1                         ;cpt_status = 0
    clr    a                          ;on_time = 0
    clr    b                          ;off_time = 0

exit_cpt_debounce
    move   y1,SP_return_val           ;return val = cpt_status
    move   b,SP_off_time              ;off_time = cpt_off_timer
    move   a,SP_on_time               ;on_time = cpt_on_timer
    move   x:previous_cpt,x0
    move   x0,SP_tone_val             ;tone_val = previous_cpt

    move   y1,x:cpt_status	          ;update cpt_status
    move   a,x:cpt_on_timer          ;update cpt_on_timer
    move   b,x:cpt_off_timer         ;update cpt_off_timer
    rts

	; undefine stack positions of routine parameters
    undef  SP_tone_val
    undef  SP_on_time
    undef  SP_off_time
    undef  SP_return_val

;------------------------------------------------------------------------------
; Routine:	return_val = CALLPROGRESS_DECODE (tone_val, status, on_time, 
;		                                  off_time)
;
; Description:	This routine performs decode logic to determine the type
;		of call progress tone detected by testing the temporal pattern.
;
;
; Stack Parameters:
;
;	------------
;	  tone_val	x:(sp-6)
;	------------
;	   status	x:(sp-5)
;	------------
;	  on_time	x:(sp-4)
;	------------
;	  off_time	x:(sp-3)
;	------------
;	 return_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
;	Input Parms:	tone_val = output parameter of CALLPROGRESS_DEBOUNCE
;		           (not modified during routine)
;			status = value returned by CALLPROGRESS_DEBOUNCE
;		           (not modified during routine)
;			on_time = output parameter of CALLPROGRESS_DEBOUNCE
;		           (not modified during routine)
;			off_time = output parameter of CALLPROGRESS_DEBOUNCE
;		           (not modified during routine)
;
;	Return Value:	call progress tone detected (assigned INVALID_TONE if 
;			   none detected; see tone_api.inc for immediate values)
;
;			return_val	Call Progress Tone
;			----------	------------------
;			#DIAL_TONE	Dial Tone
;			#MSG_WAIT	Message Waiting 
;			#RECALL		Recall Dial Tone
;			#BUSY		Line Busy
;			#REORDER	Reorder
;			#RING		Audible Ringing
;
; Pseudocode:	
;
;	return_val = INVALID_TONE
;	if (status & DEBOUNCED_ON)
;		if (tone_val == cpt_last_group)
;			if (cpt_last_state == OFF)
;				if (tone_val == CPT_GROUP_1)
;					a = abs(cpt_last_on - BURST_ON)
;					if (a <= BURST_ON_DEV)
;						a = abs (cpt_last_off - BURST_OFF)
;						if (a <= BURST_OFF_DEV)
;							cpt_bursts++
;						else
;							cpt_bursts = 0
;						endif
;       				else
;						cpt_bursts = 0
;       				endif
;				elseif (tone_val == CPT_GROUP_2)
;					a = abs (cpt_last_on - REORDER_ON)
;					if (a <= REORDER_ON_DEV)
;						a = abs (cpt_last_off - REORDER_OFF)
;	 					if (a <= REORDER_OFF_DEV)
;							cpt_bursts++
;						else
;							cpt_bursts = 0
;						endif
;						if (cpt_bursts == REORDER_BURSTS)
;							return_val = REORDER
;  						endif
;		 	 		else
;						a = abs (cpt_last_on - BUSY_ON)
;						if (a <= BUSY_ON_DEV)
;							a = abs(cpt_last_off - BUSY_OFF)
;	 						if (a <= BUSY_OFF_DEV)
;								cpt_bursts++
;							else
;								cpt_bursts = 0
;							endif
;							if (cpt_bursts == BUSY_BURSTS)
;								return_val = BUSY
;						endif
;					endif
;		 	 	elseif (tone_val == CPT_GROUP_3)
;					cpt_bursts = 0;
;		 	 		a = abs (cpt_last_on - RING_ON)
;		 	 		if (a <= RING_ON_DEV)
;		 	 			a = abs (cpt_last_off - RING_OFF)
;		 	 			if (a <= RING_OFF_DEV)
;		 	 				return_val = RING
;		 	 			endif
;		 	 		endif
;				endif
;		
;
;			elseif (tone_val == CPT_GROUP_1 && 
;			           on_time > BURST_ON+BURST_ON_DEV)
;				if (cpt_bursts == RECALL_BURSTS)
;					return_val = RECALL
;				elseif (cpt_bursts == MSG_WAIT_BURSTS)
;					return MSG_WAIT
;				elseif (on_time >= DIAL_TONE_ON)
;					return_val = DIAL_TONE
;				endif
;			endif
;		else
;			cpt_bursts = 0
;		endif
;
;		cpt_last_state = ON
;		cpt_last_on = on_time
;		cpt_last_group = tone_val
;			
;	elseif (status & DEBOUNCED_OFF)
;		cpt_last_state = OFF
;		cpt_last_off = off_time
;	endif
;
;	if (return_val == cpt_last_code)
;		return_val = INVALID_TONE
;	else
;		cpt_last_code = return_val
;	endif
;		
;	return return_val
;------------------------------------------------------------------------------
CALLPROGRESS_DECODE:

	; define stack positions of routine parameters
	define SP_tone_val	'x:(sp-6)'
	define SP_status	'x:(sp-5)'
	define SP_on_time	'x:(sp-4)'
	define SP_off_time	'x:(sp-3)'
	define SP_return_val	'x:(sp-2)'

	; save context if necessary
	 
    move    #INVALID_TONE,x0               ;x0 = return_val = INVALID_TONE
    move    x0,SP_return_val               ;return_val = INVALID_TONE
                                           ;  overwritten if necessary
	move	SP_tone_val,b	        	   ;b = tone_val
	move	SP_on_time,y0                  ;y0 = on_time
	move	SP_off_time,y1	           	   ;y1 = off_time
	
	
	bftstl	#DEBOUNCED_ON,SP_status	       ;if !(cpt_status&DEBOUNCED_ON)
	jcs     not_cpt	                       ;goto not_cpt
	
	cmp     x:cpt_last_group,b	           ;if (cpt_last_group != tone_val)
	bne     clear_bursts		           ;   goto clear_bursts

;dont_chk_grp
	tstw	x:cpt_last_state	           ;if (cpt_last_state == ON)
	jne     last_on			               ;goto last_on
	cmp     #CPT_GROUP_1,b	               ;if (tone_val != CPT_GROUP_1)
	bne     check_group2		           ;goto check_group2
						
	; check for BURST_ON temporal match
	move	x:cpt_last_on,a			       ;a = cpt_last_on
	sub     #BURST_ON,a	         	       ;a = cpt_last_on - BURST_ON
	abs     a			                   ;a = abs(a)
	cmp     #BURST_ON_DEV,a                ;if (BURST_ON_DEV < a)
	bgt     clear_bursts	               ;goto clear_bursts

	; check for BURST_OFF temporal match
	move	x:cpt_last_off,a	           ;a = cpt_last_off
	sub     #BURST_OFF,a		           ;a = cpt_last_off - BURST_OFF
	abs     a			                   ;a = abs(a)
	cmp     #BURST_OFF_DEV,a	           ;if (BURST_OFF_DEV < a)
	bgt     clear_bursts		           ;goto clear_bursts

	; burst has been detected
	incw	x:cpt_bursts                   ;cpt_bursts++
	jmp     end_cpt_on		       	       ;goto end_cpt_on
	
clear_bursts
	move	#0,x:cpt_bursts                ;else cpt_bursts = 0
	jmp     end_cpt_on                     ;goto end_cpt_on

check_group2
	cmp     #CPT_GROUP_2,b		           ;if (tone_val != CPT_GROUP_2)
	bne     check_group3		           ;goto check_group3
	
	; check for REORDER_ON temporal match
	move	x:cpt_last_on,a		           ;a = cpt_last_on
	sub     #REORDER_ON,a                  ;a = cpt_last_on - REORDER_ON
	abs     a			       	           ;a = abs(a)
	cmp     #REORDER_ON_DEV,a       	   ;if (REORDER_ON_DEV < a)
	bgt     _check_busy                    ;_check_busy

	; check for REORDER_OFF temporal match
	move    x:cpt_last_off,a	       	   ;a = cpt_last_off
	sub     #REORDER_OFF,a	        	   ;a = cpt_last_off - REORDER_OFF
	abs     a			                   ;a = abs(a)
	cmp     #REORDER_OFF_DEV,a	           ;if (REORDER_OFF_DEV < a)
	bgt     _check_busy		               ;_check_busy

	incw    x:cpt_bursts                   ;cpt_bursts++
	move    #REORDER_BURSTS,a
	cmp     x:cpt_bursts,a                 ;If (cpt_bursts != REORDER_BURSTS)
	jne     end_cpt_on		               ;  goto end_cpt_on
	move	#REORDER,x0			           ;x0 = return_val = REORDER
	bra     clear_bursts		           ;goto clear_bursts

_check_busy
	; check for BUSY_ON temporal match
	move	x:cpt_last_on,a	               ;a = cpt_last_on
	sub     #BUSY_ON,a		               ;a = cpt_last_on - BUSY_ON
	abs     a                              ;a = abs(a)
	cmp     #BUSY_ON_DEV,a                 ;if (BUSY_ON_DEV < a)
	bgt     end_cpt_on                     ;end_cpt_on

	; check for BUSY_OFF temporal match
	move	x:cpt_last_off,a               ;a = cpt_last_off
	sub     #BUSY_OFF,a	                   ;a = cpt_last_off - BUSY_OFF
	abs     a			                   ;a = abs(a)
	cmp     #BUSY_OFF_DEV,a	               ;if (BUSY_OFF_DEV < a)
	bgt     end_cpt_on		               ;end_cpt_on

	incw    x:cpt_bursts		           ;cpt_bursts++
	move    #BUSY_BURSTS,a
	cmp     x:cpt_bursts,a		           ;If (cpt_bursts != BUSY_BURSTS)
	bne     end_cpt_on		               ;  goto end_cpt_on
	move    #BUSY,x0		               ;x0 = return_val = BUSY
	bra     clear_bursts		           ;goto clear_bursts
	
check_group3	
	cmp     #CPT_GROUP_3,b		           ;if (tone_val != CPT_GROUP_3)
	bne     end_cpt_on		               ;goto end_cpt_on
	
	; check for RING_ON temporal match
	move    x:cpt_last_on,a		           ;a = cpt_last_on
	sub     #RING_ON,a		               ;a = cpt_last_on - RING_ON
	abs     a			                   ;a = abs(a)
	cmp     #RING_ON_DEV,a                 ;if (RING_ON_DEV < a)
	bgt     end_cpt_on		          	   ;end_cpt_on

	; check for RING_OFF temporal match
	move    x:cpt_last_off,a	           ;a = cpt_last_off
	sub     #RING_OFF,a		               ;a = cpt_last_off - RING_OFF
	abs     a		                       ;a = abs(a)
	cmp     #RING_OFF_DEV,a		           ;if (RING_OFF_DEV < a)
	bgt     end_cpt_on		               ;end_cpt_on

	move    #RING,x0                       ;x0 = return_val = BUSY
	bra     end_cpt_on		               ;goto end_cpt_on

last_on
	cmp     #CPT_GROUP_1,b		           ;if (tone_val != CPT_GROUP_1)
	bne     end_cpt_on		               ;goto end_cpt_on
	
	cmp     #BURST_ON+BURST_ON_DEV,y0      ;if (on_time <= BURST_ON+BURST_ON_DEV)
	ble     end_cpt_on		               ;goto end_cpt_on

	move    x:cpt_bursts,a		           ;a = cpt_bursts
	
	; check for recall call progress tone
	cmp     #RECALL_BURSTS,a               ;if (cpt_bursts != RECALL_BURSTS)
	bne     _check_msg_wait	               ;goto _check_msg_wait
	move    #RECALL,x0                     ;x0 = return_val = RECALL
	bra     end_cpt_on	                   ;goto end_cpt_on
	
_check_msg_wait	
	; check for message waiting call progress tone
	cmp     #MSG_WAIT_BURSTS,a             ;if (cpt_bursts != MSG_WAIT_BURSTS)
	bne     _check_dial_tone               ;goto _check_dial_tone
	move    #MSG_WAIT,x0	               ;x0 = return_val = MSG_WAIT
	bra     end_cpt_on	                   ;goto end_cpt_on
	
_check_dial_tone
	cmp     #DIAL_TONE_ON,y0               ;if (on_time < DIAL_TONE_ON)
	blt     end_cpt_on                     ;goto end_cpt_on
	move    #DIAL_TONE,x0	               ;x0 = return_val = DIAL_TONE

end_cpt_on

; --- sahoo --- 08/01 ---
;        tstw    b
;	beq     dont_change_group
	move    b,x:cpt_last_group        	   ;cpt_last_group = tone_val

;dont_change_group
	move    #ON,x:cpt_last_state	       ;cpt_last_state = ON
	move    y0,x:cpt_last_on	           ;cpt_last_on = on_time
	bra     exit_decode		               ;goto _exit_decode

not_cpt
				                           ;if !(cpt_status&DEBOUNCED_OFF)
				                           ;  goto _exit_decode
	brclr   #DEBOUNCED_OFF,SP_status,exit_decode	
	move    #OFF,x:cpt_last_state	       ;cpt_last_state = OFF
	move    y1,x:cpt_last_off              ;cpt_last_off = off_time
    move    y1,x:file_out2
						
exit_decode
	; ensure that codes are only generated once for each valid detection
	cmp     x:cpt_last_code,x0	           ;if (return_val==cpt_last_code)
	beq     _return			               ;goto _return
	move    x0,x:cpt_last_code	           ;cpt_last_code = return_val
	move    x0,SP_return_val

_return

; --- sahoo --- 08/01 ---
;	move	b,x:cpt_last_group             ;cpt_last_group = tone_val
	rts				                       ; return

	; undefine stack positions of routine parameters
	undef   SP_status
	undef   SP_on_time
	undef   SP_off_time
	undef   SP_return_val
	
	ENDSEC

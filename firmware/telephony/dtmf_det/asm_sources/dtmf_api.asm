;------------------------------------------------------------------------------
; Module Name:	dtmf_api.asm
;
; Description:	This module is designed to provide an API interface to
;		the DTMF detection routines.
;
; Last Update:	7/3/97
;------------------------------------------------------------------------------

	include "tone_api.inc"		; include DTMF definitions
	
        section dtmf_api GLOBAL			
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	org     p:
	
        ;--- API function Prototypes ---;
	GLOBAL 	DTMF_DETECT_INIT
	GLOBAL  DTMF_DETECT 
	GLOBAL  DTMF_DEBOUNCE 
	GLOBAL  SILENCE_DETECT_INIT
	GLOBAL  SILENCE_DETECT
        

;------------------------------------------------------------------------------ 
; External Routine References 
;------------------------------------------------------------------------------ 
	org	p:

   xref    NEWNUM
   xref    TST_DTMF
   xref    CALC_NUM
   xref    CALC_MG_EN

	xref    GENERATE_ANALYSIS_ARRAY
	xref    INITIALIZE_ANALYSIS_ARRAY
	xref    CALC_SIG_EN

	xref    SIL_DEC

;------------------------------------------------------------------------------ 
; External variables References 
;------------------------------------------------------------------------------ 
   org    x:
	xref   dtmf_level
	xref   dtmf_off_timer
	xref   dtmf_on_timer
	xref   dtmf_state
	xref   dtmf_status
	xref   n_e
	xref   previous_dtmf
	xref   sig_energy
	

;------------------------------------------------------------------------------
; Module Code
;------------------------------------------------------------------------------
	org 	p:

;------------------------------------------------------------------------------
; Routine:	DTMF_DETECT_INIT (level)
;
; Description:	This routine performs initialization for the DTMF/CAS detection 
;		module by resetting state variables, initializing thresholds,
;		and clearing the elements in the analysis history buffer.
;
; Stack Parameters:
;
;	------------
;	   level(lo)	x:(sp-3)
;	------------
;	   level(hi)	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
; 	Input Parms:	level = DTMF absolute threshold
;
; 	Output Parms:	N/A
;
; 	Return Value:	N/A
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------

DTMF_DETECT_INIT:

    ; define stack positions of routine parameters
    define	SP_level_lo	'x:(sp-3)'
    define	SP_level_hi	'x:(sp-2)'
   
    move    #0,x0                                                   
	move    x0,x:dtmf_on_timer		; dtmf_on_timer = 0
	move    x0,x:dtmf_off_timer     	; dtmf_off_timer = 0
	move    x0,x:dtmf_status        	; dtmf_status = 0
	move    #INVALID_TONE,x:previous_dtmf   ; previous_dtmf = INVALID_TONE
	move    #no_dtmf,x:dtmf_state           ; dtmf_state = no_dtmf
	move	SP_level_hi,x0			; x0 = level(hi)
	move    x0,x:dtmf_level     		; dtmf_level = level 
	move	SP_level_lo,x0			; x0 = level(lo)
	move    x0,x:dtmf_level+1     		; dtmf_level = level 
	jsr	    INITIALIZE_ANALYSIS_ARRAY
	rts

	; undefine stack positions of routine parameters
        undef SP_level_lo
	undef SP_level_hi
;------------------------------------------------------------------------------
; Routine:	return_val = DTMF_DETECT ()
;
; Description:	This routine performs DTMF/CAS detection on samples found
;		in the ANA_BUF analysis buffer.  If a valid tone is detected, 
;		the numeric value which corresponds with that tone is returned,
;               else, the value INVALID_TONE is returned.
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
; 	Input Parms:	a = sig_energy for DTMF/CAS and is double precision 
;                           number
;
; 	Output Parms:	N/A
;
; 	Return Value:	Ascii value of tone detected (assigned INVALID_TONE if none detected)
;
;			return_val	DTMF key 
;			----------	--------
;			   $31		    1
;			   $32		    2
;			   $33		    3
;			   $41		    A
;			   $34		    4
;			   $35		    5
;			   $36		    6
;			   $42		    B
;			   $37		    7
;			   $38		    8
;			   $39		    9
;			   $43		    C
;			   $2a  	    *
;			   $30		    0
;			   $23		    #
;			   $44		    D
;              $ff          INVALID
;
;
; Other Input/Output:	N/A
;
; Pseudocode:
;		NEWNUM ()
;		If (TST_DTMF () != FAIL)
;			return CALC_NUM ()
;		else
;			return INVALID_TONE
;
;               endif
;------------------------------------------------------------------------------
DTMF_DETECT:
	; define stack positions of routine parameters
	define SP_return_val	'x:(sp-2)'

	; save context if necessary

	move    a,x:sig_energy          ;Save the signal energy for CAS/DTMF
	move    a0,x:sig_energy+1

	
	; NEWNUM ()
	jsr	    NEWNUM                  ;find sik's for DTMF filters

	jsr     CALC_MG_EN              ;Calculate MG_EN of CAS/DTMF 

_test_dtmf
    jsr	TST_DTMF                    ;else, test if DTMF tone exists
					                ;   test result returned in x0
	tstw	x0			            ;if (x0 == FAIL)
	beq	_fails_tests		        ;goto _fails_tests
	jsr	CALC_NUM		            ;else calculate the DTMF tone detected
					                ;   calculation result returned x0
	bra	_end_detect		            ;goto _end_detect

_fails_tests
	
	move    #INVALID_TONE,x0    	;x0 = INVALID_TONE
	
_end_detect
	move	x0,SP_return_val	    ;place return value on stack
	rts				                ;return

	; undefine stack positions of routine parameters
	undef	SP_return_val

	

;------------------------------------------------------------------------------
; Routine:	return_val = DTMF_DEBOUNCE (tone_val, on_time)
;
; Description:	This routine performs debounce logic for the tones
;		detected with the DTMF_DETECT routine.  
;
; Stack Parameters:
;
;	------------
;	  tone_val	x:(sp-4)
;	------------
;	  on_time	x:(sp-3)
;	------------
;	 return_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
; 	Input Parms:	tone_val = value returned by DTMF_DETECT routine
;
; 	Output Parms:	tone_val = tone actively being debounced
;	on_time = number of consecutive frames the active
;		  tone has been detected on
;
;                 Note:  on_time parameter is valid only an active
;			detection of a tone (i.e., only until the DEBOUNCE_OFF
;			bit is set in the status word returned)
;
; 	Return Value:	status of the DTMF detection (see the tone_api.inc file
;			for bit definitions; tone_val is placed in lower byte)
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------

DTMF_DEBOUNCE:

	; define stack positions of routine parameters
	define SP_tone_val	'x:(sp-4)'
	define SP_on_time	'x:(sp-3)'
	define SP_return_val	'x:(sp-2)'

	; save context if necessary
	
	move   SP_tone_val,y0			;y0 = tone_val
	move   x:previous_dtmf,y1               ;y1 = previous_dtmf
	move   x:dtmf_on_timer,a		;a = dtmf_on_timer
	move   x:dtmf_off_timer,b		;b = dtmf_off_timer
	move   x:dtmf_status,n			;n = dtmf_status
	
;--- switch (dtmf_state)	---;
	move   x:dtmf_state,x0	                ;x0 = dtmf_state
	lea	   (sp)+
	move   x0,x:(sp)+
	move   sr,x:(sp)
	rts					
	

;--- case no_dtmf:  ---;
no_dtmf
	cmp	#SILENCE,y0			        ;if (tone_val == SILENCE)
    jeq	reset				        ;goto exit_dtmf_debounce
	cmp	#INVALID_TONE,y0		    ;if (tone_val == INVALID_TONE)
	jeq	reset				        ;goto exit_dtmf_debounce

new_dtmf
	move	#dtmf_on,x:dtmf_state	;dtmf_state = tone_on
	clr	b				            ;dtmf_off_timer = 0
	clr	n				            ;dtmf_status = 0
	move	#1,a				    ;dtmf_on_timer = 1
	move	y0,y1				    ;previous_dtmf = tone_val
	jmp	exit_dtmf_debounce		    ;goto exit_dtmf_debounce
	
;--- case dtmf_on:  ---;
dtmf_on
	cmp	#INVALID_TONE,y0		    ;if (tone_val != INVALID_TONE)
	bne	_check_silence			    ;goto _check_silence
	move  #noisy_dtmf,x:dtmf_state	;else dtmf_state = noisy_dtmf
	jmp	exit_dtmf_debounce		    ;goto exit_dtmf_debounce
	
_check_silence
	cmp	#SILENCE,y0			        ;if (tone_val != SILENCE)
	beq	end_dtmf			        ;goto end_dtmf

check_previous_dtmf
	cmp	y1,y0				        ;if (tone_val != previous_dtmf)
	bne	new_dtmf			        ;goto new_dtmf
	
	incw	a				        ;dtmf_on_timer ++

check_min_on
	move	#MIN_DTMF_ON,x0			;x0 = MIN_DTMF_ON
    nop
    cmp	    x0,a	     	        ;if (dtmf_on_timer<MIN_ON)
	blt	    _not_min_on	            ;goto _not_min_on
	
	bfset	#DEBOUNCED_ON,n			;dtmf_status |= DEBOUNCED_ON

_not_min_on
	bra	exit_dtmf_debounce		    ;goto exit_dtmf_debounce

;--- case noisy_dtmf:  ---;
noisy_dtmf
	cmp	#INVALID_TONE,y0		    ;if (tone_val == INVALID_TONE)
	beq	end_dtmf			        ;goto end_dtmf

	cmp	#SILENCE,y0			        ;if (tone_val == SILENCE)
	beq	end_dtmf			        ;goto end_dtmf

	incw	a				        ;dtmf_on_timer++
	move	#dtmf_on,x:dtmf_state   ;dtmf_state = dtmf_on
	bra	check_previous_dtmf		    ;goto check_previous_dtmf
	

end_dtmf
	brclr	#DEBOUNCED_ON,n,reset		
			                                   ;if !(dtmf_status&DEBOUNCED_ON)
						           ;goto reset
	move	#1,b				   ;else dtmf_off_timer = 1
	                               ;dtmf_state = dtmf_silence
	move	#dtmf_silence,x:dtmf_state 
	bra	exit_dtmf_debounce
	
;--- case dtmf_silence:  ---;
dtmf_silence
	cmp	#INVALID_TONE,y0		   ;if (tone_val != INVALID_TONE)
	bne	_check_silence			   ;goto _check_silence
	bra	reset                      ;else goto reset
	
_check_silence
	cmp	#SILENCE,y0			       ;if (tone_val == SILENCE)
	jne	new_dtmf			       ;goto new_dtmf
	
_off_frame
	incw	b				       ;off_timer++
	
	move	#MIN_DTMF_OFF,x0	   ;x0 = MIN_DTMF_OFF
        nop
	cmp	x0,b				       ;if (off_timer < MIN_OFF)
	blt	exit_dtmf_debounce		   ;goto exit_dtmf_debounce
	
	;--- at this point, the tone is valid and debounced ---;
	bfset	#DEBOUNCED_OFF,n	   ;dtmf_status |= DEBOUNCED_OFF
	move	#no_dtmf,x:dtmf_state  ;dtmf_state no_dtmf
	bra	exit_dtmf_debounce		   ;goto exit_dtmf_debounce

reset
	move	#no_dtmf,x:dtmf_state  ;dtmf_state = no_dtmf
	clr	a				           ;on_time = 0
        clr	b				           ;off_time = 0
	clr	n				           ;dtmf_status = 0
	move	#INVALID_TONE,y1	   ;previous_dtmf = INVALID_TONE

exit_dtmf_debounce
	move	a,SP_on_time		   ;on_time = dtmf_on_timer
	move	y1,SP_tone_val		   ;tone_val = previous_dtmf
	move	n,x0				   ;x0 = dtmf_status
	bfclr	#$FF,x0				   ;clear low byte of dtmf_status
	or	y0,x0				       ;place active tone in low byte
	move	x0,SP_return_val	   ;return val = dtmf_status

	move    x0,x:dtmf_status	   ;update dtmf_status
	move	y1,x:previous_dtmf	   ;update previous_dtmf
	move	a,x:dtmf_on_timer	   ;update dtmf_on_timer
	move	b,x:dtmf_off_timer	   ;update dtmf_off_timer
	rts

	; undefine stack positions of routine parameters
	undef SP_tone_val
	undef SP_on_time
	undef SP_return_val


;------------------------------------------------------------------------------
; Routine:	SILENCE_DETECT_INIT (level)
;
; Description:	This routine performs initialization for the silence detection 
;		module by resetting state variables and initializing thresholds.
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
;	Input Parms:	level = voice energy absolute threshold
;
;	Output Parms:	N/A
;
;	Return Value:	N/A
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------
SILENCE_DETECT_INIT:
	
	move    #NOISE_LEVEL1,x:n_e	    ;Maximum noise level (upper word)
	move    #NOISE_LEVEL2,x:n_e+1   ;Maximum noise level (lower word)		
	rts 



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
		    
	tstw    x:Fspeech_flag
	move    #1,x0
	bne     _continue_tst1
	jsr  	SIL_DEC		
_continue_tst1	
	move	x0,SP_return_val		;place return value on stack
	rts					            ;return

	; undefine stack positions of routine parameters
	undef	SP_return_val
	
	endsec

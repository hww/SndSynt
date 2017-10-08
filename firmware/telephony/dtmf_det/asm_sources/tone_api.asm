;------------------------------------------------------------------------------
; Module Name:	tone_api.asm
;
; Description:	This module is provides a Public API (Application
;		Programming Interface) for the DTMF, Call Progress, 
;		and silence detection routines.
;
; LastUpdate:7/3/97;------------------------------------------------------------------------------

	include "tone_api.inc"		; include DTMF definitions
	
	section tone_api  GLOBAL			
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
    

	org     p:
	
	;--- Public API function Prototypes ---;
	
	GLOBAL  PAPI_DTMF_DETECT
	GLOBAL  FINIT_DTMF_DETECT
	
;------------------------------------------------------------------------------ 
; External Routine References 
;------------------------------------------------------------------------------ 


    xref    DTMF_DETECT_INIT
    xref    DTMF_DETECT
    xref    DTMF_DEBOUNCE

    xref    GENERATE_ANALYSIS_ARRAY
    xref    CALC_SIG_EN

	xref    SILENCE_DETECT_INIT
	xref    SILENCE_DETECT

;-----------------------------------------------------------------------------
; External X memory variables reference
;-----------------------------------------------------------------------------

    org     x:

    xref    dtmf_r1
	xref    max_val
	xref    result_ptr
	xref    sil_r1
	xref    sig_en_hi1

	
;------------------------------------------------------------------------------ 
; Module Code
;------------------------------------------------------------------------------ 
    org 	p:

 
;-----------------------------------------------------------------------------
; Initialization of DTMF_DETECT and SILENCE_DETECT
;-----------------------------------------------------------------------------
FINIT_DTMF_DETECT

;Fill top of stack with Absolute magnitude threshold and
;call DTMF_DETECT_INIT

        lea  (sp)+
		move #THRESH1_DTMF_LO,x0
		move x0,x:(sp)+
		move #THRESH1_DTMF_HI,x0
		move x0,x:(sp)
        jsr  DTMF_DETECT_INIT
		pop
		pop

		jsr  SILENCE_DETECT_INIT
		
		move #PASS,y0
		    
		rts



;------------------------------------------------------------------------------
; Routine:  return_val = FPAPI_TONE_DETECT_CALL (input_buf)
;
; Description: This routine loads stack and calls PAPI_TONE_DETECT
;------------------------------------------------------------------------------
         
         
;------------------------------------------------------------------------------
; Routine:	return_val = PAPI_DTMF_DETECT (input_buf, tone_val, on_time)
;
; Description:	This routine performs DTMF detection on an input buffer,
;		debounces the detection, and returns state information for
;		the current detection.  This is a Public API (PAPI) routine.
; Stack Parameters:
;
;	------------
;	  input_buf	x:(sp-4)
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
; 	Input Parms:  input_buf = pointer to 10ms frame @ 8KHz (80 samples)
;
; 	Output Parms:	on_time = number of frames that code_val has been detected on
;
; 	Return Value: code_val = Ascii value corresponding to type of detection
;
;			HEX VALUE		DETECTION
;			---------------------------------------
;			$31-$44			DTMF
;			$17			    SILENCE
;			$FF			    INVALID
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------
PAPI_DTMF_DETECT: 
	; define stack positions of routine parameters
	define	SP_status   	'x:(sp-5)'
	define	SP_input_buf	'x:(sp-4)'
	define	SP_on_time	    'x:(sp-3)'
	define	SP_return_val	'x:(sp-2)'
	
	move	#INVALID_TONE,x0		; x0 = INVALID_TONE
	move	x0,SP_return_val		; return_val = INVALID_TONE
						            ; (default is overwritten
						            ; if tone/silence detected)

	;--- initialize the frame info structure ---;
	move	x0,x:dtmf_r1			; dtmf_r1 = INVALID_TONE
	clr	    x0
	move	x0,x:sil_r1			    ; sil_r1 = 0
	
	move	#sig_en_hi1,x:result_ptr	; result_ptr = sig_en_hi1
	move	SP_input_buf,r0			; r0 = input_buf

_dtmf_det_loop
	;--- max_val = GENERATE_ANAYLSIS_ARRAY (input_buf)  ---;
	lea     (sp)+
	move    r0,x:(sp)+              ; push input_buf and allocate
						            ; space for return value
	jsr     GENERATE_ANALYSIS_ARRAY
	pop	    x0				        ; x0 = max sample value
	pop     				        ; adjust stack for input parm
	
	move	x0,x:max_val		    ; update max_val

	;--- b = CALC_SIG_EN () ---;
	jsr	    CALC_SIG_EN			    ; calculate signal energy in
						            ;   ANA_BUF (returned in a)
		
	move 	x:result_ptr,r0		    ; r0 = frame_info pointer
	nop
	move	b,x:(r0)+			    ; store off the double precision
	move	b0,x:(r0)+			    ;   energy returned in a
	move	r0,x:result_ptr		    ; update frame_info pointer

_dtmf_test
	;--- tone_val = DTMF_DETECT (sig_en) ---;
	lea	    (sp)+				    ; allocate space for return val
	jsr	    DTMF_DETECT
	move	x:result_ptr,r0		    ; r0 = dtmf result
	pop     x0				        ; x0 = tone_val
	move	x0,x:(r0)			    ; store off result
        
	move	#INVALID_TONE,x0	    ; x0 = INVALID_TONE
	cmp     x:dtmf_r1,x0			; if (cas_r1 != INVALID_TONE)
	bne     _debounce_dtmf			; goto _sil_detect

	
_sil_detect
	move	#sig_en_hi1,r0			; r0 = pointer to sig_en_hi1
	nop

_sil_detect_loop
	move	x:(r0)+,a			    ; a0 = sig_en_hi
	move	x:(r0)+,a0			    ; a = sig_en_lo

	move	r0,x:result_ptr		    ;result_ptr = ptr to dtmf result
        
	;--- bool = SILENCE_DETECT (sig_en) ---;
	lea	    (sp)+				    ; allocate space for return val
	jsr	    SILENCE_DETECT
	pop	    x0				        ; x0 = boolean (return value)
       
	move	x:result_ptr,r0			; r0 = result_ptr	
	tstw 	x0				        ; if (boolean == 0)
	beq	_no_sil				        ; goto _no_sil
	
	move	#SILENCE,y0
	move	y0,x:(r0)+		        ; dtmf_result = SILENCE
	move	x0,x:(r0)+			    ; sil_result = boolean

_no_sil

_debounce_dtmf
	move	#dtmf_r1,r0			    ; r0 = pointer to dtmf_r1
	nop

	;--- DTMF_DEBOUNCE (tone_val, on_time) ---;
	move    x:(r0)+,x0			    ; x0 = dtmf result
	move	r0,x:result_ptr			; result_ptr = pointer to sil-r1

	lea	    (sp)+				    ; push dtmf result
	move	x0,x:(sp)+			    ; and alloc space for on_time
	lea	    (sp)+				    ; alloc space for return value
	jsr	    DTMF_DEBOUNCE
	pop	    x0				        ; x0 = dtmf_status (return val)
	pop	    y1				        ; y1 = on_time
	pop    	a				        ; a = tone_val
	
	
	; if !(sil_status & DEBOUNCED_ON) goto _end_debounce
	brset	#DEBOUNCED_OFF,x0,_end_debounce
	move    #INVALID_TONE,a
_end_debounce	

	; set return value and output parameters
	move	a,SP_return_val			; return_val = table code value
	move	y1,SP_on_time			; on_time = # of 20ms frames

	move    #~DIGIT_DETECTED,y0
	brclr   #DEBOUNCED_OFF,x0,_no_digit_detected
	move    #DIGIT_DETECTED,y0
_no_digit_detected
    move    y0,SP_status

_frame_done	
	rts	; end of function TONE_DETECT
	
	undef	SP_input_buf
	undef	SP_on_time
	undef	SP_return_val
	undef	SP_status
	

    endsec

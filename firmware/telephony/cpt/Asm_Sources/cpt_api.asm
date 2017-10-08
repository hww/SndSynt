;------------------------------------------------------------------------------
; Module Name:	cpt_api.asm
;
; Last Update:  26.Sep.2000
;
; Author Name:  Manohar Babu
;
; Description:	This module provides a Public API (Application
;         		Programming Interface) for the  Call Progress, 
;       		and silence detection routines.
;
;------------------------------------------------------------------------------

   include "cpt_api.inc"                    ; include CPT definitions

   SECTION  cpt_data
	
;------------------------------------------------------------------------------ 
; Local Scratch Variable Definitions 
;------------------------------------------------------------------------------ 
	
	ORG     x:

result_ptr	  ds	1                        ; pointer into frame_info
frame_info	  ds	4                        ; frame information structure
sig_en_hi1	  equ	frame_info+0		     ; sig_en high word for 20ms
sig_en_lo1	  equ	frame_info+1		     ; sig_en low word for 20ms
cpt_r1		  equ	frame_info+2		     ; cpt detection for 20ms
sil_r1		  equ	frame_info+3		     ; sil detection for 20ms

    ENDSEC

	
	SECTION cpt_code			
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	
	;--- Public API function Prototypes ---;
	GLOBAL 	  PAPI_TONE_DETECT

;------------------------------------------------------------------------------ 
; Module Code
;------------------------------------------------------------------------------ 
	ORG  	p:

;------------------------------------------------------------------------------
; Routine:	return_val = PAPI_TONE_DETECT (input_sample, tone_val, on_time)
;
; Description:	This routine performs CPT detection on an input buffer,
;       		debounces the detection, and returns state information for
;		        the current detection. This is a Public API (PAPI) routine.
; 
; Stack Parameters:
;
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
; 	Input Parms:    input_sample
;
; 	Output Parms:	on_time = number of frames that code_val has been detected on
;
; 	Return Value:   code_val = value corresponding to type of detection
;
;			HEX VALUE		DETECTION
;			---------------------------------------
;			$11-$16			CALL PROGRESS TONE
;			$17			    SILENCE
;			$FF			    INVALID
;
; Other Input/Output:	N/A
;
; Pseudocode:
;------------------------------------------------------------------------------

PAPI_TONE_DETECT: 
        define  SP_on_time      'x:(sp-3)'
        define  SP_return_val   'x:(sp-2)'

    	move    #INVALID_TONE,x0                ; x0 = INVALID_TONE
        move    x0,SP_return_val                ; return_val = INVALID_TONE
			                        			;   (default is overwritten
						                        ;    if tone/silence detected)

	;--- GENERATE_ANALYSIS_ARRAY_CPT (input_sample) ---;

        jsr     GENERATE_ANALYSIS_ARRAY_CPT
        cmp     #PASS,y0
        beq     _cpt_process
        move    #INVALID_TONE,y0                ;  status return value 

        rts

_cpt_process

   ;--- initialize the frame info structure ---;
        move    x0,x:cpt_r1                     ; cpt_r1 = INVALID_TONE
        clr     x0
        move    x0,x:sil_r1                     ; sil_r1 = 0

	;--- a = CALC_SIG_EN_CPT () ---;
	
        jsr     CALC_SIG_EN_CPT                 ; calculate signal energy in
                                                ;   ANA_BUF (returned in a)
	
	;--- CALLPROGRESS_DETECT (sig_en) ---;
        lea     (sp)+                           ; allocate space for return val
        jsr     CALLPROGRESS_DETECT
        pop     x0                              ; x0 = group_val (return value)
        move    x0,x:cpt_r1
        
_sil_detect
        move    #INVALID_TONE,x0                ; x0 = INVALID_TONE	
        cmp     x:cpt_r1,x0                     ; if cpt_result != INVALID_TONE
        bne     _debounce_cpt                   ; goto _debounce_all
        move    #sig_en_hi1,r0                  ; r0 = pointer to sig_en_hi1
        nop

_sil_detect_loop
        move    x:(r0)+,a                       ; a0 = sig_en_hi
        move    x:(r0)+,a0                      ; a = sig_en_lo
	
	
	;--- bool = SILENCE_DETECT (sig_en) ---;
        lea     (sp)+		                    ; allocate space for return val
        jsr     SILENCE_DETECT
        pop     x0                              ; x0 = boolean (return value)
       
        tstw    x0                              ; if (boolean == 0)
        beq     _no_sil                         ; goto _no_sil
        
        move    #cpt_r1,r0
        move    #SILENCE,y0
        move    y0,x:(r0)+                      ; cpt_result = SILENCE
        move    x0,x:(r0)+                      ; sil_result = boolean
_no_sil
    
_debounce_cpt
               
	;--- CALLPROGRESS_DEBOUNCE (tone_val, on_time, off_time) ---;
        move    #cpt_r1,r0                      ; r0 = pointer to cpt result
        lea     (sp)+
        move    x:(r0)+,x0                      ; x0 = cpt result
        move    x0,x:(sp)+                      ; push cpt result and alloc 
                                                ;   space for on_time
        lea     (sp)+                           ; alloc space for off_time
        lea     (sp)+                           ; alloc space for return value
        jsr     CALLPROGRESS_DEBOUNCE
        pop     x0                              ; x0 = cpt_status (return value)
        pop     y0                              ; y0 = off_time
        pop     y1                              ; y1 = on_time
        pop     a                               ; a = tone_val
	
_decode_cpt
	;--- CALLPROGRESS_DECODE (tone_val, cpt_status, on_time, off_time) ---;
        lea     (sp)+				
        move    a,x:(sp)+                       ; push tone_val
        move    x0,x:(sp)+                      ; push cpt_status
        move    y1,x:(sp)+                      ; push on_time
        move    y0,x:(sp)+                      ; push off_time and alloc space
                                                ; for return value
        jsr	    CALLPROGRESS_DECODE
        pop     x0                              ; x0 = code_val (return value)
        pop     y0                              ; y0 = off_time
        pop     y1                              ; y1 = on_time
        pop     a                               ; a = cpt_status
        pop     b                               ; b = tone_val

	
	; set return value and output parameters
        move    x0,SP_return_val                ; return_val = code_val
        move    y1,SP_on_time                   ; on_time = # of 20ms frames
	
_debounce_sil

	;--- SILENCE_DEBOUNCE (boolean, on_time) --;
        move    #sil_r1,r0                      ; r0 = pointer to sil result
        lea     (sp)+
        move    x:(r0),x0                       ; x0 = sil result
        move    x0,x:(sp)+                      ; push sil_result and alloc 
                                                ;   space for on_time
        lea     (sp)+                           ; alloc space for return value
        jsr     SILENCE_DEBOUNCE
        pop     x0                              ; x0 = sil_status (return value)
        pop     y1                              ; y1 = on_time
        pop     a                               ; a = boolean

	; if !(sil_status & DEBOUNCED_ON) goto _end_debounce
        brclr   #DEBOUNCED_ON,x0,_end_debounce

	; if CPT has been detected, do not overwrite with silence
        move    #INVALID_TONE,x0                ; x0 = INVALID_TONE
        cmp     SP_return_val,x0                ; if return_val != INVALID_TONE
        bne     _end_debounce                   ; goto _end_debounce
	
	; set return value and output parameters
        move    #SILENCE,SP_return_val          ; return_val = INVALID_TONE
        move    y1,SP_on_time                   ; on_time = # of 20ms frames

_end_debounce	

        rts	                                    ; end of function TONE_DETECT
	
        undef   SP_on_time
        undef   SP_return_val
	

        ENDSEC 

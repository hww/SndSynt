;------------------------------------------------------------------------------
; Module Name:	tone_buf.asm
;
; Description:	This module is contains the shared analysis buffers for
;		the DTMF and Call Progress/Silence detection modules as
;		well as the routines for generating the analysis buffers.
;
; Last Update: 7/3/97
;------------------------------------------------------------------------------

	include "tone_api.inc"		; include API definitions
	
	section tone_buf  GLOBAL		
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	org     p:
	GLOBAL  GENERATE_ANALYSIS_ARRAY 
	GLOBAL	INITIALIZE_ANALYSIS_ARRAY
	GLOBAL  CALC_SIG_EN

;------------------------------------------------------------------------------ 
; External variables References 
;------------------------------------------------------------------------------ 
    org     x:
	xref    ANA_BUF
	xref    LAST_BUF
	xref    shift_count
;------------------------------------------------------------------------------ 
; Module Code
;------------------------------------------------------------------------------ 
	org 	p:
	
;------------------------------------------------------------------------------
; Routine:	GENERATE_ANALYSIS_ARRAY (input_buf)
;
; Description:	This routine generates the analysis buffer suitable for
;		input to the DTMF, and silence detection
;		routines.  The buffer created is stored in the global
;		array ANA_BUF.
;
; Stack Parameters:
;
;	------------
;	 input_buf	x:(sp-3)
;	------------
;	 ret_val	x:(sp-2)
;	------------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
; 	Input:	input_buf = pointer to input frame
;
; 	Output:	N/A
;
; 	Return Value:	Max over 80 samples at 8Khz of input buffer (10msec)
;
; Other Input/Output:
;
;	Input:	LAST_BUF = contains previous LAST_BUF_SIZE samples of ANA_BUF
;	
;	Output:	ANA_BUF = analysis buffer for DTMF/Silence detect
;		LAST_BUF = set to last samples of ANA_BUF for next frame
; Pseudocode:
;		i = 0
;		j = 0
;		k = 0
;
;		do LAST_BUF_SIZE times
;			ANA_BUF[j++] = LAST_BUF[i++]
;		enddo
;
;		do ANA_BUF_SIZE-2*LAST_BUF_SIZE times
;			ANA_BUF[j++] = input_buf[k++]
;		enddo
;
;		i = 0
;		do LAST_BUF_SIZE times
;			ANA_BUF[j++] = input_buf[k]
;			LAST_BUF[i++] = input_buf[k++]
;		enddo
;
;------------------------------------------------------------------------------

GENERATE_ANALYSIS_ARRAY:

	; save context if necessary

	Define  SP_ret_val 'x:(sp-2)' 
	Define  SP_input_buf 'x:(sp-3)' 
                                    ;
	move	#LAST_BUF,r0		    ;r0 = LAST_BUF
	move	#ANA_BUF,r1			    ;r1 = analysis_buf

	clr     x0 
	move    x:(r0)+,a
	do      #(LAST_BUF_SIZE>>1),_max_last_buf
	abs     a        x:(r0)+,b
	or      a1,x0
    	abs     b        x:(r0)+,a
	or      b1,x0                   ;x0=max value in LAST BUFF
_max_last_buf
	clr     y1
	move    SP_input_buf,r0
	move    #((ANA_BUF_SIZE-LAST_BUF_SIZE))>>1,y0
	move    x:(r0)+,a               ;Get max over 80 samples
	do      y0,_max_sample_buf
	abs     a        x:(r0)+,b
        or      a1,y1
	abs     b        x:(r0)+,a
	or      b1,y1
_max_sample_buf
	andc	#$7FFF,x0			    ;disallow $FFFF
	andc	#$7FFF,y1			    ;disallow $FFFF
	or      y1,x0                   ;Get max for DTMF/CAS
	move    y1,SP_ret_val           ;Return value

	move    x0,a	
	jsr     FIND_SHIFT
	add     #SAMPLE_SHIFT,a
	move    #LAST_BUF,r0
	move	#LAST_BUF,r2			;r2 = LAST_BUF
	blt     _left_shift
        move    a,y0

	do	#LAST_BUF_SIZE,_end_copy1  	;do LAST_BUF_SIZE times
	move	x:(r0)+,y1			    ;y1 = LAST_BUF[r0++]
	asrr    y1,y0,y1
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy1					        ;enddo

	move	SP_input_buf,r0			;r0 = input_buf
	
	move	#ANA_BUF_SIZE-2*LAST_BUF_SIZE,lc
	do	lc,_end_copy2			
	move	x:(r0)+,y1			    ;y1 = input_buf[r0++] 
	asrr	y1,y0,y1			    ;y1>>shift_count-SAMPLE_SHIFT
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy2					        ;enddo

	do	#LAST_BUF_SIZE,_end_copy3  	;do LAST_BUF_SIZE times
	move	x:(r0)+,y1			    ;y1 = input_buf[r0++] 
	move	y1,x:(r2)+			    ;LAST_BUF[r2++] = y1
	asrr	y1,y0,y1			    ;y1>>shift_count-SAMPLE_SHIFT
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy3
	bra     _end_gen_ana_arr

_left_shift
	neg     a
	move    a,y0
	do	#LAST_BUF_SIZE,_end_copy1_lft  	
	move	x:(r0)+,y1			    ;do LAST_BUF_SIZE times
	                                ;y1 = LAST_BUF[r0++]
	lsll    y1,y0,y1
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy1_lft					    ;enddo

	move	SP_input_buf,r0			;r0 = input_buf
	
	move	#ANA_BUF_SIZE-2*LAST_BUF_SIZE,lc
	do	lc,_end_copy2_lft
	move	x:(r0)+,y1			    ;y1 = input_buf[r0++] 
	lsll	y1,y0,y1			    ;y1 = y1<<SAMPLE_SHIFT
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy2_lft                                  ;enddo

	do	#LAST_BUF_SIZE,_end_copy3_lft  	
	                                ;do LAST_BUF_SIZE times
	move	x:(r0)+,y1			    ;y1 = input_buf[r0++] 
	move	y1,x:(r2)+			    ;LAST_BUF[r2++] = y1
	lsll	y1,y0,y1			    ;y1 = y1<<SAMPLE_SHIFT
	move	y1,x:(r1)+			    ;analysis_buf[r1++] = y1
_end_copy3_lft

_end_gen_ana_arr


	rts

	Undef   SP_input_buf
	Undef   SP_ret_val


FIND_SHIFT
	move    #0,r0
	tst     a                       ;Reflect the flags for norm
	rep     #14                     ;  instruction
	norm    r0,a
	move    r0,a
	move    a,b
	abs     b
	move    b,x:shift_count
	rts
	



;------------------------------------------------------------------------------
; Routine:	INITIALIZE_ANALYSIS_ARRAY (void)
;
; Description:	This routine performs initialization of the analysis array
;		used in tone/silence detection routines.
;
; Stack Parameters:
;
; Other Input/Output:
;	Input:	LAST_BUF = contains previous LAST_BUF_SIZE samples of ANA_BUF
;	
;	Output:	LAST_BUF = cleared
;
; Pseudocode:
;		for (i = 0; i < LAST_BUF_SIZE; i++)
;			LAST_BUF[i] = 0;
;	endfor
;------------------------------------------------------------------------------

INITIALIZE_ANALYSIS_ARRAY:

	clr	x0			; x0 = 0
	move    #LAST_BUF,r0            ; r0 = pointer to LAST_BUF      
	rep     #2*(Nc-Ns)              ; repeat 2*(Nc-Ns) times        
	move    x0,x:(r0)+              ; clear each element in LAST_BUF  
	rts 



;------------------------------------------------------------------------------
; Routine:	CALC_SIG_EN ()
;
; Description:	
;               This module computes the energy over specified number of
;               samples and scales it according to DTMF requirements.
;               This energy is proportional to the mg_energies which can
;               be used for various tests for DTMF/CAS.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
; 	Input:	        ANA_BUF = Contains the samples from 
;                                 GENERATE_ANALYSIS_ARRAY
;
; 	Output:		a = energy and is double prcision.
;
; 	Return Value:	b = energy (scaled appropriately)
;
; Modules Called:
;                   SIG_SCLE (sig_energy, mul_val)
;
; Pseudocode:
;                   Begin
;                   for i=0 to num_samples-1
;                       sig_energy = sig_energy + sample*sample
;                       jsr SIG_SCLE
;                   end
;
; NOTE : Register x0 should not be disturbed in this module
;
;------------------------------------------------------------------------------

CALC_SIG_EN
	
	move    #ANA_BUF,r2
	move	#mul_val,x0                  ;x0 = mul_val = 2*Nc/128
	clr     a        x:(r2)+,y0          ;sig_energy=0, get the first sample
        move	#2*Nc,y1                     ;y1 = 2*Nc 
	do      y1,_compute_energy
	asr	y0                           ;divide each sample by 2 to 
					     ;   compensate for extra 52 samples
	mac     y0,y0,a  x:(r2)+,y0          ;a = sig_energy
_compute_energy
	jsr     SIG_SCLE                     ;Scale the signal energy
	
	tfr	a,b
        move    x:shift_count,y0
        asl     y0
        rep     y0
        asr     b

	rts



;------------------------------------------------------------------------------
; Routine:	SIG_SCLE
;
; Description:	
;       This routine scales the signal energy of the current channel up by
;       2*Ns/2*mul_val
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;    sig_energy(hi) = | 0.fff ffff | ffff ffff | in a1
;    sig_energy(lo) = | ffff ffff  | ffff ffff | in a0
;    mul_val        = | 0.fff ffff | ffff ffff | in x0
;
;  Output:
;    sig_energy(hi) = | 0.fff ffff | ffff ffff | in a1
;    sig_energy(lo) = | ffff ffff  | ffff ffff | in a0
;    
;
; Pseudocode:
;               for the current channel
;                   sig_energy = sig_energy*mul_val - n_comp
;
;------------------------------------------------------------------------------

SIG_SCLE:

	move    a0,y0                     ;y0 = sig_energy(lo)
	move    a,y1                      ;y1 = sig_energy(hi)
	mpysu   x0,y0,a                   ;a = sig_energy(lo)*mul_val
	move    a1,b0
	move    a2,a
	move    b0,a0
	mac     y1,x0,a                   ;a = sig(lo)*mul_val*2**(-16)
					                  ;+ sig(hi)*mul_val
	rep     #6
	asl     a                         ;a = sig(lo)*num_samples
					                  ;*mul_val*2**(-16) + sig(hi)*
					                  ; num_samples
	move    #n_comp,x0                ;Get Noise compensator to x0
	sub     x0,a                      ;Subtract magic number from
					                  ;sig_energy
	rts

	endsec 

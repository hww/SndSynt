;------------------------------------------------------------------------------
; Module Name:	cpt_buf.asm
;
; Author Name:  Manohar Babu
;
; Description:	This module contains the routines for generating shared 
;               analysis buffer for  Call Progress/Silence detection modules.
;
; Last Update:	15.Sep.2000
;------------------------------------------------------------------------------


	include "cpt_api.inc"		      	    ; include API definitions
	
	
;------------------------------------------------------------------------------ 
; External Variable Definitions 
;------------------------------------------------------------------------------ 
    SECTION    cpt_data
	
	GLOBAL	   ANA_BUF
	GLOBAL	   shift_count
	GLOBAL	   sig_energy
    GLOBAL     ana_buf_ptr
    GLOBAL     ana_buf_count

;------------------------------------------------------------------------------ 
; Local Scratch Variable Definitions 
;------------------------------------------------------------------------------ 
	
	ORG         x:
	
sig_energy      dsm     2*M                ;Signal energies for M channels
						                   ;  in double precision
ANA_BUF		    ds	    Nc_cpt      	   ;analysis buffer
shift_count     ds      1                  ;Sample normalising count
ana_buf_ptr     ds      1
ana_buf_count   ds      1
 
    ENDSEC

	
	SECTION     cpt_code			
	
;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 


	GLOBAL    GENERATE_ANALYSIS_ARRAY_CPT
	GLOBAL    CALC_SIG_EN_CPT

;------------------------------------------------------------------------------ 
; Module Code
;------------------------------------------------------------------------------ 

    ORG       p:
	
;------------------------------------------------------------------------------
; Routine:	GENERATE_ANALYSIS_ARRAY_CPT (input_buf)
;
; Description:	This routine generates the analysis buffer suitable for
;               input to the  call progress detection routines. The buffer
;               created is stored in the global	array ANA_BUF.
;
; Stack Parameters:
;
;	-----------
;	     PC		x:(sp-1)
;	------------
;	     SR		x:(sp)
;	------------
;
; 	Input:	sample in y0
;
; 	Output:	N/A
;
; 	Return Value:	PASS or FAIL in y0
;
;	Output:	ANA_BUF = analysis buffer for Call Progress
;
; Pseudocode:
;       
;       *(ana_buf_ptr++) = input_sample;
;       ana_buf_count++;
;       if(ana_buf_count == ANA_BUF_SIZE)
;       {
;       ana_buf_ptr = &ANA_BUF;
;       ana_buf_count = 0;
;       return(PASS)
;       }
;       
;       else
;       {
;         return(FAIL);
;       }
;
;------------------------------------------------------------------------------

GENERATE_ANALYSIS_ARRAY_CPT:

        bfchg   #1,x:decimate_flag
        bcc     _SkipSample
     
        move    x:ana_buf_ptr,r0             ;Current buffer pointer 
        move    x:ana_buf_count,x0
        move    y0,x:(r0)+                   ;New sample in y0
        incw    x0
        cmp     #ANA_BUF_SIZE,x0             ;Check to see whether enough 
        beq     _process_buffer              ;  samples are collected for

        move    x0,x:ana_buf_count          
        move    r0,x:ana_buf_ptr             
       
_SkipSample
        move    #FAIL,y0                     ;return value shold be zero if 
                                             ; the buff is not processed
        rts                                  ;  20 ms frame processing

_process_buffer
        move    #ANA_BUF,x:ana_buf_ptr       ;Re-initialize the sample
        move    #0,x:ana_buf_count           ;  buffer pointer & count
       
        move    #ANA_BUF,r0 
        clr     y1
        move    #(ANA_BUF_SIZE>>1),y0
        move    x:(r0)+,a                    
        do      y0,_max_sample_buf
        abs     a        x:(r0)+,b
        or      a1,y1
        abs     b        x:(r0)+,a
        or      b1,y1
_max_sample_buf
        move    y1,a                          ;Get maximum value 
        andc    #$7fff,a                      ;Disallow $ffff
         
		jsr     FIND_SHIFT
		move    #ANA_BUF,r1                   ;Get the working buff. address
	
		move	#ANA_BUF_SIZE,lc
		add     #SAMPLE_SHIFT_CPT,a
		blt     _left_shift_cpt
	    move    a,y0                          ;Get the right shift count
		do      lc,_end_copy_cpt
		move	x:(r1),y1	                  
		asrr	y1,y0,y1		              ;y1>>shift_count-SAMPLE_SHIFT
		move	y1,x:(r1)+		              ;analysis_buf[r1++] = y1
_end_copy_cpt				                  ;enddo
        bra     _done_analysis_array
	
_left_shift_cpt
	    neg     a
		move    a,y0
		do      lc,_end_copy1_cpt
		move	x:(r1),y1		     
		lsll	y1,y0,y1		             ;y1>>shift_count-SAMPLE_SHIFT
		move	y1,x:(r1)+		             ;analysis_buf[r1++] = y1
_end_copy1_cpt				                 ;enddo
	
_done_analysis_array
        move   #PASS,y0                      ;return value should be 1 if the 
	                                         ;buffer is processed
        rts
	
FIND_SHIFT:
        move    #0,r0
        tst     a                            ;Reflect the flags for norm
        rep     #14                          ;  instruction
        norm    r0,a
        move    r0,a
        move    a,b
        abs     b
        move    b,x:shift_count
        rts


;------------------------------------------------------------------------------
; Routine:	CALC_SIG_EN_CPT ()
;
; Description:	
;               This module computes the energy over specified number of
;               samples and scales it according to call progress requirements.
;               This energy is proportional to the mg_energies which can
;               be used for various tests for CPT
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
; 	Input:	        ANA_BUF = Contains the samples from GENERATE_      
;                                 ANALYSIS_ARRAY_CPT
;
; 	Output:		a = energy and is double precision.
;
; 	Return Value:	a = energy (scaled appropriately)
;
; Modules Called:
;                   SIG_SCLE (sig_energy, mul_val)
;
; Pseudocode:
;                   Begin
;                   for i=0 to num_samples-1
;                       sig_energy = sig_energy + sample*sample
;                   end
;                   jsr SIG_SCLE
;
; NOTE : Register x0 should not be disturbed in this module
;
;------------------------------------------------------------------------------

CALC_SIG_EN_CPT:

	move    #ANA_BUF,r2
	move	#mul_val_cpt,x0	                 ;x0 = mul_val_cpt = Nc_cpt/128
	clr     a        x:(r2)+,y0              ;sig_energy=0, get the first sample
	move	#Nc_cpt/2,y1                     ;y1 = Nc_cpt
	do      y1,_compute_energy
	mac     y0,y0,a  x:(r2)+,y0              ;a = sig_energy
	mac     y0,y0,a  x:(r2)+,y0              ;a = sig_energy
_compute_energy

	jsr     SIG_SCLE                         ;Scale the signal energy
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

	move    a0,y0                            ;y0 = sig_energy(lo)
	move    a,y1                             ;y1 = sig_energy(hi)
	mpysu   x0,y0,a                          ;a = sig_energy(lo)*mul_val
	move    a1,b0
	move    a2,a
	move    b0,a0
	mac     y1,x0,a                          ;a = sig(lo)*mul_val*2**(-16)
					                         ;    + sig(hi)*mul_val
	rep     #6
	asl     a                                ;a = sig(lo)*num_samples
					                         ;  *mul_val*2**(-16) + sig(hi)*
					                         ;  num_samples
	move    #n_comp,x0                       ;Get Noise compensator to x0
	sub     x0,a                             ;Subtract magic number from
					                         ;  sig_energy
	rts


	ENDSEC 

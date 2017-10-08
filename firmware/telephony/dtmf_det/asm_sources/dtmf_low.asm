;------------------------------------------------------------------------------
; Module Name:	dtmf_low.asm
;
; Description:	This module is designed to provide the low-level routines
;		invoked by the API routines found in dtmf_api.asm.  These
;		routines perform the necessary calculations and tests for
;		the tone/silence detection module.
;
;------------------------------------------------------------------------------

	include "tone_api.inc"		; include API definitions
	
	section dtmf_low  GLOBAL			

;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	org     p:
	
	;--- Low-Level Function Prototypes ---;
	GLOBAL 	NEWNUM
	GLOBAL  TST_DTMF
	GLOBAL  CALC_NUM
	GLOBAL  CALC_MG_EN
    
     
;------------------------------------------------------------------------------ 
; External Variables Reference
;------------------------------------------------------------------------------ 
    org    x:

	xref   ANA_BUF
	xref   Thresh2a
	xref   Thresh2b
	xref   Thresh4a
	xref   Thresh4b
	xref   Thresh5a
	xref   Thresh5c
	xref   alfa
	xref   cosval
	xref   dtmf_level
	xref   loop_cntr
	xref   map_to_digit
	xref   mg_energy
	xref   n_e
	xref   pk_add
	xref   shift_count
	xref   sig_energy
	xref   sik
	xref   Fspeech_flag
	

;------------------------------------------------------------------------------
; Module Code
;------------------------------------------------------------------------------
	org 	p:

	
;------------------------------------------------------------------------------
; Routine:	NEWNUM (analysis_buf)
;
; Description:	
;       This macro is the main DTMF loop.
;       It runs the filter state updating module
;       for Ns samples.
;
;       For  details see the design document.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
; 	Input:          ANA_BUF - Samples generated from
;                       GENERATE_ANALYSIS_ARRAY_CPT
;
; 	Output:		N/A
;
; 	Return Value:	N/A
;
; Pseudocode:
;                   Reset pointer and registers
;                   for k=0 to Nc-1
;                       GET_DTMF
;                       reset cosval pointer
;                       UPD
;                       reset pointer and register
;                   DECISION
;
;------------------------------------------------------------------------------

NEWNUM:

	move    #ANA_BUF,r2               ;Pointer to working buffer
	clr     b                         ;b = 0
					                  ;also b represent last filter's
					                  ;si(k) to allow for 
					                  ;move b,x:(r0)+n in UPD for the
					                  ;first time
        
    move    #sik+2*NO_DTMF-1,r1       ;Clear Filter States "sik" before
    rep     #2*NO_DTMF                ;MG Filtering
    move    b,x:(r1)-
        
	move    #sik+2*NO_DTMF-3,r0       ;set r0
	move    #sik,r3                   ;r3 -> si(k-1) of first filter
	move    #2*NO_DTMF-1,m01          ;Set r0 for modulo 2*NO_DTMF      
	move    #2,n                      ;Set n  for offset of 2
	move	x:(r0)+,y1
	move	x:(r3)+,x0

	move	#Nc,x:loop_cntr
	
	;Do for Ns samples of input
do_Nc_times
	
	move    x:(r2)+n,a                ;a  = tone[r2]
					                  ;inc r2 by 2
	move    #cosval,r1                ;r1 -> cosval(0)
	jsr	    UPD                       ;Update MG filter states
	move    #sik,r3                   ;r3 -> si(k-1) of first channel      
	decw	x:loop_cntr
	move    x:(r3)+,y1                ;y1 = si(k-1)
	move    x:(r3),x0                 ;x0 = si(k-2)
	bgt 	do_Nc_times
	move    b,x:(r0)+n                ;Write last si(k)
	move    #-1,m01                   ;Restore r0 & r1 to linear addressing
	rts


;------------------------------------------------------------------------------
; Routine:	UPD
;
; Description:	
;       The input is used to update
;           a) MG filter states for NO_FIL filters, ie. for DTMF filter
;
;       For  details see the design document.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
;    Input:
;	x(k)        = | s.fff ffff | ffff ffff |      in  a 
;	si(k)       = | s.fff ffff | ffff ffff |      in  x:sik
;	si(k-1)     = | s.fff ffff | ffff ffff |      in  x:sik+1
;	                                                     i=0,..,NO_DTMF-1
;	cosval(i)   = | s.fff ffff | ffff ffff |      in  x:cosval to
;	                                                  x:cosval+8
;	r0 -> last si(k) (modulo 2*NO_FIL)
;	r3 -> current channel's s0(k-2) 
;	r1 -> cosval(0)
;	n  =  2
;	x0 =  current channel's s0(k-2)
;	y1 =  current channel's s0(k-1)
;	b  =  last si(k)
;
;    Output:
;	si(k)       = | s.fff ffff | ffff ffff |      in  x:sik
;	si(k-1)     = | s.fff ffff | ffff ffff |      in  x:sik+1
;	                                                     i=0,..,NO_FIL-1
;	r0 -> current channel's last si(k)
;	r1 -> s9(k-2)
;	r3 -> cosval(9)
;	y0 =  cosval(9)
;	y1 =  s9(k-1)
;	x0 =  s9(k-2)
;	b  =  last si(k)
;
; Pseudocode:
;               for i=0 to NO_DTMF-1
;                   si(k-2) = si(k-1)
;                   si(k-1) = si(k)
;                   si(k) = x(k) + 2.0*cosval(i)*si(k-1) - si(k-2)

;------------------------------------------------------------------------------

UPD:

	move    x:(r1)+,y0                ;y0 = cosval(0)
				                	  ;  r1 -> cosval(1)
	do      #NO_DTMF,end_updl         ;Do for MG filters
	mpy     y0,y1,b  b,x:(r0)+n       ;b = si(k-1)*cosval(i), save
					                  ;  previous si(k)
					                  ;  r0 -> current si(k)
	asl     b        y1,x:(r3)+n      ;b = 2.0*si(k-1)*cosval(i),
					                  ;  si(k-2) = si(k-1)
					                  ;  r3 -> s(k-2) of next filter
	sub	x0,b         x:(r1)+,y0       ;b = - si(k-2)
	move	         x:(r3)-,x0       ;  + 2.0*cosval*si(k-1)
					                  ;x0 = next si(k-2)
					                  ;  r3 ->next si(k-1) 
					                  ;  y0 = next cosval
					                  ;  r1 -> cosval(i+2)
                					  ;  The last position also
				                	  ;  contains cosval(0) so that
					                  ;  once a channel is over, x0
 					                  ;  gets cosval(0) for the next
					                  ;  channel
	add     a,b     x:(r3)+,y1        ;b = x(k) + 2.0*si(k-1)*cosval(i)
					                  ;  - si(k-2)
					                  ;  y1 = s(k-1) of next filter
					                  ;  r3 -> next s(k-2)
end_updl
	rts


;------------------------------------------------------------------------------
; Routine:	return_val = CALC_MG_EN
;
; Description:	
;	This routine computes the MG_energies of all MG filters
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
;	Input:
;
;	Output:
;
; Pseudocode:
;
;       Calculate MG_EN of all CAS/DTMF filters
;--------------------------------------------------------------------------
CALC_MG_EN:
                                    
	move    #NO_DTMF,y1
	move    #cosval,r3                  ;r3 -> cosval(0)
	jsr	    MG_EN                  	    ;find mg_energies
	rts


;------------------------------------------------------------------------------
; Routine:	return_val = TST_DTMF
;
; Description:	
;	This routine calls other subroutines to test the existence of DTMF tone.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;
;	Input:
;
;	Output:
;
;	Return Value: 1 if all tests pass, 0 otherwise in x0
;
; Pseudocode:
;       Call FIND_PKS to find the peak for DTMF filters
;       Call MAG to test
;       set thresh5c for DTMF 
;       Call REL_EN to test
;       Call TWIST to test
;       Call REL_MAG to test
;***************************** Assembly Code ******************************

TST_DTMF:
	jsr	    FIND_PKS            ;find out the hi and lo peaks between 
					            ;mg_energy(0) to mg_energy(7)

	jsr	    MAG			        ;carry out MAG test
	tstw	x0			        ;if pass
	bne	    _Test2			    ;goto _Test2
	rts				            ;else return

_Test2					
	move    #Thresh4a_dtmf,x:Thresh4a
	move    #Thresh4b_dtmf,x:Thresh4b
 	jsr	    TWIST			    ;carry out TWIST test
	tstw	x0			        ;if pass
	bne	    _Test3			    ;goto _Test4
	rts				            ;else return

_Test3
;-------TH5C			        ;set Thresh5c for REL_EN
	move    #Thresh5cDTMF,x:Thresh5c
;-------

	jsr	    REL_EN   	        ;carry out REL_EN test
	tstw	x0			        ;if pass
	bne	    _Test4		        ;goto _Test3
	rts				            ;else return

_Test4
 	jsr	REL_MAG			    ;carry out REL_MAG test
	rts


;------------------------------------------------------------------------------
; Routine:	MG_EN
;
; Description:	
;       This routine calculates the Modified Goertzel filter energies for
;       the current channel using the MG filter states of that channel.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     M - chl_no   = | 0000 0000  | 000i iiii |  in  lc
;     si(k)        = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no
;     si(k-1)      = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no+1
;                                                        i=0,..,NO_FIL-1
;     cosval(i)    = | s.fff ffff | ffff ffff |  in  x:cosval+i
;                                                        i=0,..,NO_FIL-1
;     y1           = Number of filters
;     r3           -> Appropriate cos table
;
;  Output:
;     mg_energy(i) = | 0.fff ffff | ffff ffff |  in  x:mg_energy+i
;                                                        i=0,..,NO_FIL-1
;
; Pseudocode:
;               for the current channel
;                   for i=0 to NO_FIL-1
;                       mg_energy(i) = si(N-1)*si(N-1) + si(N-2)*si(N-2)
;                                 - 2.0*cosval(i)*si(N-1)*si(N-2)
;------------------------------------------------------------------------------

MG_EN:
                                    ;
	move    #mg_energy-1,r0         ;r0 -> location before
					                ;  mg_energy(0)
	move    #sik,r1                 ; r1 = sik                   
					                ;  i.e. r1 -> si(0) of first  

    move    x:(r0),b                ; b = contents of location before
					                ;  mg_energy(0), to account for
					                ;  the write operation in the
			         	            ;  first loop
	move    x:(r1)+,y0 
	move    x:(r3)+,x0  
	                                ; y0 = s0(k-1), x0 = cosval(0)
					                ; r1 -> s0(k-2) r3 -> cosval(1)
	do      y1,end_mg               ; For all MG frequencies
	mpy     x0,y0,b         b,x:(r0)+   
	                                ; b = cosval(i) * si(N-1)
					                ; store mg_energy(i-1)
					                ;r0 -> mg_energy(i)
	asl     b               x:(r1)+,y1  
	                                ;b = 2 * cosval(i) * si(N-1)
					                ;y1 = si(N-2)
					                ;r1 -> next si(N-1)
	sub     y1,b            x:(r3)+,x0  
	                                ;b = 2*cosval(i)*si(N-1) - si(N-2)
					                ;x0 = cosval(i+1)
					                ;r3 -> cosval(i+2)
	move    b,b                     ;Saturate b
	mpy     -b1,y1,b                ;b = si(N-2)*( si(N-2) - 
					                ;       2*cosval(i)*si(N-1) )
					                ;  = si(N-2)*si(N-2) -
					                ;       2*cosval(i)*si(N-1)*si(N-2)
	mac     y0,y0,b         x:(r1)+,y0  
	                                ;b = si(N-1)*si(N-1)+si(N-2)*si(N-2)
						            ;    - 2*cosval(i)*si(N-1)*si(N-2)
					                ;y0 = next si(N-1)
					                ;r1 -> next si(N-2)
end_mg
	move    b,x:(r0)+               ;Store mg_energy(NO_FIL-1)
	rts				
				
					                
;------------------------------------------------------------------------------
; Routine:	return_val = MAG
;
; Description:	
;       This routine checks that the magnitudes of the peak energies of
;       the low & high group of MG filters is greater than a threshold.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     mg_energy(i) = | 0.fff ffff | ffff ffff |     in  x:mg_energy+i
;                                                          i=0,..,NO_FIL-1
;     lo_add       = | iiii iiii  | iiii iiii |     in  x:pk_add
;     hi_add       = | iiii iiii  | iiii iiii |     in  x:pk_add+1
;
;  Output:
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
; Pseudocode:
;               for the current frame
;                   if lo_peak < Thresh1
;                       return 0
;                   if hi_peak < Thresh1
;                       return 0
;		    return 1
;
;------------------------------------------------------------------------------

MAG:
	
	move    x:pk_add,r0               ;r0 = Address of low group peak
	clr	    x0	            		  ;x0 = 0 => failed test
	move    x:(r0),b                  ;b = lo_peak
	move    x:pk_add+1,r0             ;r0 = Address of high group peak

	; ggw -- 9/14/96 -- changed constant to variable threshold
	move	x:dtmf_level,a		      ;a = DTMF threshold level(hi)
	move	x:dtmf_level+1,a0	      ;a0= DTMF threshold level(lo)

	move    x:shift_count,y0
	asl     y0
	rep     y0
	asr     b
	cmp     b,a         x:(r0)+,b     ;Compare lo_peak & Thresh1
					                  ;  b = hi_peak
	bgt	_Failed			              ;If lo_peak < Thresh1 goto
					                  ;  _Failed
	rep     y0
	asr     b
	cmp     b,a			              ;Compare hi_peak & Thresh1
	bgt     _Failed			          ;If hi_peak < Thresh1 goto
					                  ;  _Failed
	move	#1,x0			          ;x0 = 1 => passed test
	
_Failed
	rts

	
;------------------------------------------------------------------------------
; Routine:	return_val = REL_EN
;
; Description:	
;       This routine performs the Relative Energy tests as part of the
;       decision logic. 
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;   M - chl_no     = | 0000 0000  | 000i iiii | in  lc
;   mg_energy(i)   = | 0.fff ffff | ffff ffff | in  x:mg_energy+i
;                                                         i=0,..,NO_FIL-1
;   lo_add         = | iiii iiii  | iiii iiii | in  x:pk_add
;   hi_add         = | iiii iiii  | iiii iiii | in  x:pk_add+1
;   sig_energy(hi) = | 0.fff ffff | ffff ffff | in  x:sig_energy+2*chl_no
;   sig_energy(lo) = | ffff ffff  | ffff ffff | in  x:sig_energy+2*chl_no+1
;
;  Output:
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
; Pseudocode:
;               for the current channel
;                 lo_ind = lo_add - address of mg_energy(0)
;                 hi_ind = hi_add - address of mg_energy(4)
;                 if lo_peak < hi_peak/TWIST
;                    if ((sig_energy - hi_peak)*Thresh5a(lo_ind) > lo_peak)
;                           return 0
;                 else
;                    if ((sig_energy - lo_peak)*Thresh5b(hi_ind) > hi_peak)
;                           return 0
;                 if ((sig_energy*Thresh5c) > (lo_peak+hi_peak))
;                    return 0
;		  return 1
;------------------------------------------------------------------------------

REL_EN:

	tstw    x:Fspeech_flag
	beq     _continue_tst
	move    #1,x0
	rts
_continue_tst	
	
	move    #Thresh5a,x0
	sub     #mg_energy,x0
	move    x0,n
	
	move    x:pk_add+1,r0             ;r0 -> hi_peak
	move    x:pk_add,r1               ;r1 -> lo_peak
	move    x:(r0)+n,x0               ;x0 = hi_peak
					                  ;r0 -> Thresh5b(hi_ind)
	move    #sig_energy,r2            ;r2 -> current channel's
					                  ;  sig_energy
	move    #TWIST_INV,y0             ;y0 = 1/TWIST
	mpy     y0,x0,b      x:(r1)+n,a   ;b  = hi_peak/TWIST
					                  ;a = lo_peak
					                  ;r1 -> Thresh5a(lo_ind)
	cmp     b,a                       ;Compare lo_peak - hi_peak/TWIST
   
	
	tge     a,b          r0,r1        ;If hi_peak/twist < lo_peak
					                    				;B = lo_peak
					                  ;  r1 -> Thresh5b(hi_ind)
	tge     x0,a                      ;  A = hi_peak
					                  ;Else
	tlt     x0,b                      ;  B = hi_peak
					                  ;  r1 -> Thresh5a(lo_ind)
					                  ;  A = lo_peak
	move    a,y1                      ;y1 = A
	move    x:(r2)+,a                 ;a1 = sig_energy(hi)
	move    x:(r2)-,a0                ;a0 = sig_energy(lo)
	sub     b,a          x:(r2)+,x0   ;a = sig_energy - B
					                  ;  x0 = sig_energy(hi)
					                  ;  r2 -> sig_energy(lo)
	add     y1,b         x:(r1)+,y0   ;b = A+B = hi_peak + lo_peak
					                  ;  y0 = Thresh
	mpy     a1,y0,a                   ;a = (sig_energy - B)*Thresh
						   
	cmp     y1,a                      ;Compare (sig_energy-B)*Thresh - A
	bgt     _Failed              	  ;If (sig_energy - B)*Thresh > A
					                  ;  go to invalid_addr
	move    x:Thresh5c,y0             ;y0 = Thresh5c
	mpy     x0,y0,a                   ;a = sig_energy(hi)*Thresh5c
	cmp     b,a                       ;Compare sig_energy(hi)*Thresh5c -
					                  ;  (hi_peak + lo_peak)
	bgt     _Failed              	  ;If (lo_peak + hi_peak) <
					                  ;  sig_energy*Thresh5c
					                  ;  go to invalid_addr
	move	#1,x0				      ;x0 = 1 => passed test
	rts	
	
_Failed
	clr	x0				              ;x0 = 0 => failed test
	rts
	

;------------------------------------------------------------------------------
; Routine:	return_val = TWIST
;
; Description:	
;       This macro checks if the 'twist' between the peaks of the low
;       and high groups of MG filters is within a specified range. 
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     mg_energy(i) = | 0.fff ffff | ffff ffff |     in  x:mg_energy+i
;                                                          i=0,..,NO_FIL-1
;     lo_add       = | iiii iiii  | iiii iiii |     in  x:pk_add
;     hi_add       = | iiii iiii  | iiii iiii |     in  x:pk_add+1
;
;  Output:
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
; Pseudocode:
;               for the current frame
;                   If hi_peak < lo_peak*Thresh4a
;                       return 0
;                   If lo_peak < hi_peak*Thresh4b
;                       return 0
;		    return 1
;------------------------------------------------------------------------------

TWIST:

	move    x:pk_add,r0               ;r0 = Address of low group peak
	move    x:Thresh4b,y1             ;y1 = Thresh4b
	move    x:(r0),x0                 ;x0 = lo_peak
	move    x:pk_add+1,r1             ;r0 = Address of high group peak
	tfr     x0,a                      ;a = lo_peak
	move    x:(r1),y0                 ;y0 = hi_peak
	mpy     y1,y0,b                   ;b = hi_peak*Thresh4b
	cmp     a,b                       ;Compare lo_peak &
					                  ;  (hi_peak*Thresh4b)
	bge     _Failed                   ;If lo_peak < (hi_peak*Thresh4b)
			                		  ;  go to INVALNUM
	move    x:Thresh4a,y1             ;y1 = Thresh4a
	mpy     y1,x0,a                   ;a = lo_peak*Thresh4a
	cmp     y0,a                      ;Compare hi_peak & 
					                  ;  (lo_peak*Thresh4a)
	bge     _Failed                   ;If hi_peak < (lo_peak*Thresh4a)
					                  ;  go to INVALNUM
	move	#1,x0				      ;x0 = 1 => passed test
	rts	
	
_Failed
	clr	x0				              ;x0 = 0 => failed test
	rts


;------------------------------------------------------------------------------
; Routine:	FIND_PKS
;
; Description:	
;       This routine finds the addresses of the highest MG filter energy
;       in the high and low groups. It stores these 2 addresses in a
;       buffer.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     mg_energy(i) = | 0.fff ffff | ffff ffff |     in  x:mg_energy+i
;                                                          i=0,..,NO_FIL-1
;
;  Output:
;     lo_add       = | iiii iiii  | iiii iiii |     in  x:pk_add
;     hi_add       = | iiii iiii  | iiii iiii |     in  x:pk_add+1
;
; Pseudocode:
;               lo_add = address of mg_energy(0)
;               max = mg_energy(0)
;               for i=1 to 3
;                   if mg_energy(i) > max
;                       lo_add = address of mg_energy(i)
;               hi_add = address of mg_energy(4)
;               max = mg_energy(4)
;               for i=5 to 7
;                   if mg_energy(i) > max
;                       hi_add = address of mg_energy(i)
;------------------------------------------------------------------------------

FIND_PKS:

	move    #mg_energy,r0             ;r0 -> mg_energy(0)
	move    #pk_add,r1                ;r1 -> lo_add

	;For low & high group (j=0 & 1)
	move	#2,x:loop_cntr
_peaks_loop
	move    x:(r0)+,a                 ;a = mg_energy(4*j)
					                  ;  r0 -> mg_energy(4*j+1)
	move    r0,b                      ; b -> mg_energy(4*j+1)

	do      #3,_find_each             ;For i=1 to 3
	move    x:(r0)+,x0                ;x0 = mg_energy(4*j+i)
					                  ;  r0 -> mg_energy(4*j+i+1)
	cmp     x0,a                      ;Compare max & mg_energy(4*j+i)
	tlt     x0,a                      ;If max < mg_energy(4*j+i)
	move    r0,y0                     ;  max = mg_energy(4*j+i)
	tlt     y0,b                      ;   b -> 1 location after max
_find_each

	dec     b                         ;Decrement r3, r3 -> max
	move    b,x:(r1)+                 ;Save address of max
	decw	x:loop_cntr		
	bgt	_peaks_loop
	
	rts
	

;------------------------------------------------------------------------------
; Routine:	return_val = REL_MAG
;
; Description:	
;       This routine checks that the weighted peak energies of the
;       low & high group of MG filters are greater than the other energies
;       of that group. If the peak of the low group is the first frequency,
;       an the weighted low group peak is compared with the energy of an
;       additional frequency. In any of these cases, if the weighted peak
;       energy is less than the other energy, the test fails.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     lo_add       = | iiii iiii  | iiii iiii |  in  x:pk_add
;     hi_add       = | iiii iiii  | iiii iiii |  in  x:pk_add+1
;     mg_energy(i) = | s.fff ffff | ffff ffff |  in  x:mg_energy + i
;                                                      i = 0,..,NO_FIL-1
;     Thresh2a(i)  = | s.fff ffff | ffff ffff |  in  x:Thresh2a + i
;                                                      i = 0,..,NO_FIL-2
;     Thresh2b(i)  = | s.fff ffff | ffff ffff |  in  x:Thresh2b + i
;                                                      i = 0,..,3
;  Output:
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
; Pseudocode:
;               for the current frame
;                   lo_ind = lo_add - address of mg_energy(0)
;                   hi_ind = hi_add - address of mg_energy(4)
;                   if (lo_ind = 0)
;                      if (lo_peak*Thresh2a(0) < mg_energy(8))
;                          return 0
;                   for i=0 to (lo_ind-1)
;                      if (lo_peak*Thresh2a(lo_ind) < mg_energy(i))
;                          return 0
;                   if (lo_ind = 3)
;                      if (lo_peak*Thresh2b(lo_ind) < mg_energy(8))
;                          return 0
;                   for i=(lo_ind+1) to 3
;                      if (lo_peak*Thresh2b(lo_ind) < mg_energy(i))
;                          return 0
;                   for i=0 to 3
;                      if i != hi_ind
;                          if (hi_peak*Thresh2a(hi_ind+4) < mg_energy(i+4))
;                              return 0
;		    return 1
;------------------------------------------------------------------------------

REL_MAG:
    
	move    x:pk_add,r2               ;r2 -> lo_peak
	move    r2,b                      ;b -> lo_peak i.e. b = mg_energy
					                  ;  + lo_ind
	move    #Thresh2a,x0              ;n = offset from mg_energy
	sub     #mg_energy,x0             ;  to Thresh2a table
	move    x0,n
    					                  
	move    #mg_energy,y0             ;y0 -> mg_energy(0)
	sub     y0,b         x:(r2)+n,y1  ;b = lo_ind, y1 = lo_peak
					                  ;  r2 -> Thresh2a(lo_ind)
	move    #Thresh2b,x0
	sub     #Thresh2a,x0              ;n = offset from Thresh2a table
	move    x0,n		              ;  to Thresh2b table		                  
					                  
	move    y0,r3                     ;r3 -> mg_energy(0)
	move    x:(r2)+n,x0               ;  x0 = Thresh2a(lo_ind)
					                  ;  r2 -> Thresh2b(lo_ind)
	mpy     x0,y1,a      x:(r3)+,y0   ;a = lo_peak*Thresh2a(lo_ind)
					                  ;  y0 = mg_energy(0)
	move    #3,r0                     ;r0 = 3
	move    #0,r1                     ;r1 = 0
	tstw    b                         ;Test lo_ind
	bne     _no_test2c                ;If lo_ind != 0, skip test 2c
					                  ;  for extra frequency
    lea    (sp)+
    move   r0,x:(sp)
    move   #mg_energy,r0
    move   #(NO_DTMF-1),n
    nop
    move   x:(r0+n),x0
    pop    r0        	                                  
	cmp     x0,a                      ;Compare lo_peak*Thresh2a(lo_ind)
					                  ;  & mg_energy(9)
	jlt     _Failed                   ;If lo_peak*Thresh2a(lo_ind)
					                  ;  < mg_energy(9) go to INVALNUM
	bra     _t2ah                     ;since lo_ind=0, t2al is not needed
_no_test2c
	lea	   (sp)+			          ; save lo_ind
	move	b,x:(sp)
	do      b1,_end_t2al
	cmp     y0,a    x:(r3)+,y0        ;Compare lo_peak*Thresh2a(lo_ind)
					                  ;  & mg_energy(i)
	tlt     y0,b    r0,r1             ;  r3 -> mg_energy(i+1)
					                  ;If lo_peak*Thresh2a(lo_ind)
_end_t2al                             ;  < mg_energy(i), r1 = 3
	pop     b                         ;restore lo_ind to b
_t2ah        
	sub     #3,b                      ;b = lo_ind - 3
	neg     b            x:(r2)+,x0   ;b =3 - lo_ind
					                  ;x0 = Thresh2b(lo_ind)
	
	bne     _no_test2d                ;if b != 0, test2d is not needed
	
    lea     (sp)+
    move    r0,x:(sp)
    move    #mg_energy,r0
    move    #(NO_DTMF-2),n
    nop
    move    x:(r0+n),y0               ;y0 = mg_energy(8)
    pop     r0					                      
	mpy     x0,y1,a                   ;a = lo_peak*Thresh2b(lo_ind)
	cmp     y0,a                      ;Compare lo_peak*Thresh2b(lo_ind)
					                  ;  & mg_energy(8),
	tlt     y0,b    r0,r1             ;if lo_peak*Thresh2b(lo_ind) <
					                  ;  mg_energy(8), r1 = 3
				                      ;  y0,b dummy
	bra     _end_t2ah
_no_test2d
	mpy     x0,y1,a      x:(r3)+,y0   ;a = lo_peak*Thresh2b(lo_ind)
					                  ;  y0 = mg_energy(lo_ind+1)
	do      b1,_end_t2ah
	cmp     y0,a    x:(r3)+,y0        ;Compare lo_peak*Thresh2b(lo_ind)
					                  ;  & mg_energy(i), y0 = mg_energy(i+1)
	tlt     y0,b    r0,r1             ;  r3 -> mg_energy(i+2)
					                  ;If lo_peak*Thresh2b(lo_ind)
_end_t2ah                             ;  < mg_energy(i), r1 = 3
					                  ;  (y0,b is dummy)
	tstw    r1                        ;Test r1
	bne     _Failed                   ;If r1 != 0, go to INVALNUM
	move    x:pk_add+1,r2             ;r2 -> hi_peak
	move    r2,b                      ;b -> hi_peak i.e. b = mg_energy
					                  ;  + 4 + hi_ind
	move    #Thresh2a,x0
	sub     #mg_energy,x0
	move    x0,n					                  
					                  
	move    #mg_energy+4,y0           ;y0 -> mg_energy(4)
	sub     y0,b         x:(r2)+n,y1  ;b = hi_ind, y1 = hi_peak
					                  ;  r2 -> Thresh2a(4+hi_ind)
	move    y0,r3                     ;r3 -> mg_energy(4)
	move    x:(r2)+,x0                ;
					                  ;  x0 = Thresh2a(4+hi_ind)
	mpy     x0,y1,a      x:(r3)+,y0   ;a = hi_peak*Thresh2a(4+hi_ind)
					                  ;  y0 = mg_energy(4)
					                  ;  r3 -> mg_energy(5)
	move    b,x0                      ;x0 = hi_ind
	tst     b
	beq     _end_t2bl                 ;if hi_ind = 0, skip t_2bl
	do      b1,_end_t2bl
	cmp     y0,a    x:(r3)+,y0        ;Compare hi_peak*Thresh2a(hi_ind)
					                  ;  & mg_energy(i)
	tlt     y0,b    r0,r1             ;  y0 = mg_energy(i+1)
					                  ;  r3 -> mg_energy(i+2)
_end_t2bl                             ; If hi_peak*Thresh2b(hi_ind)
					                  ;  < mg_energy(i), r1 = 3
					                  ;  (y0,b is dummy)

	move    r0,b                      ;b = 3
	sub     x0,b                      ;b = 3 - hi_ind
	tst     b       x:(r3)+,y0        ;y0 = mg_energy(4+hi_peak+1)
					                  ; if 3 - hi_ind = 0 skip t_2bh
	beq     _end_t2bh
	do      b1,_end_t2bh
	cmp     y0,a    x:(r3)+,y0        ;Compare hi_peak*Thresh2a(hi_ind)
	tlt     y0,b    r0,r1             ;  & mg_energy(i)
					                  ;  y0 = mg_energy(i+1)
					                  ;  r3 -> mg_energy(i+2)
_end_t2bh                             ;If hi_peak*Thresh2b(hi_ind)
					                  ;  < mg_energy(i), r1 = 3
					                  ;  (y0,b is dummy)
	tstw    r1                        ;Test r1
	jne     _Failed                   ;If a != 0, go to INVALNUM
	
	move	#1,x0				      ;x0 = 1 => passed test
	rts	
	
_Failed
	clr	x0				              ;x0 = 0 => failed test
	rts
	
;------------------------------------------------------------------------------
; Routine:	CALC_NUM
;
; Description:	
;       This routine calculates the current frame's detected number.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     lo_add       = | iiii iiii | iiii iiii |      in  x:pk_add
;     hi_add       = | iiii iiii | iiii iiii |      in  x:pk_add+1
;
;  Output:
;     num(c)       = | 0000 0000 | 0000 iiii |      in  y1
;
; Pseudocode:
;               lo_ind = lo_add - address of mg_energy(0)
;               hi_ind = hi_add - address of mg_energy(4)
;               num(c) = 4*lo_ind + hi_ind
;------------------------------------------------------------------------------
CALC_NUM:

	move    #mg_energy,x0             ;x0 -> mg_energy(0)
	move    x:pk_add,a                ;a = address of low group peak
	sub     x0,a                      ;a = lo_ind
	asl     a                         ;a= 2*lo_ind
	asl     a                         ;a= 4*lo_ind
	move    #mg_energy+4,y1           ;y1 -> mg_energy(4)
	move    x:pk_add+1,x0             ;x0 = address of high group peak
	sub     y1,x0                     ;x0 = hi_ind
	add     a1,x0                     ;x0 = 4*lo_ind + hi_ind

	move    #map_to_digit,r0
    move    x0,n                      ;Transfer tone val to n
        nop
	move    x:(r0+n),x0

	rts


	endsec


;------------------------------------------------------------------------------
; Module Name:	sil_low.asm
;
; Description:	This module is designed to provide the low-level routines
;		invoked by the API routines found in cpsi_api.asm.  These
;		routines perform the necessary calculations and tests for
;		the call progress/silence detection module.
;
;------------------------------------------------------------------------------

	section sil_low	 GLOBAL		

;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 
	org     p:
	
	;--- Low-Level Function Prototypes ---;
	GLOBAL 	SIL_DEC


;-----------------------------------------------------------------------------
; External variables Reference
;-----------------------------------------------------------------------------

        org    x:
		xref   alfa
		xref   n_e
		xref   sig_energy



    org     p:	

;------------------------------------------------------------------------------
; Routine:	SIL_DEC
;
; Description:	
;       This routine is used to decide whether silence is detected.
;       Two tests will be performed :
;               1) if the whole band is silence, silence is detected.
;               2) if only the silence tone ( for Asia ) dominates, 
;                       silence is assumed.
;
;
; Stack Parameters:	N/A
;
;  Input :       a = Signal energy computed at 10msec interval
;
;  Output:
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
; Pseudocode:
;		return 0
;------------------------------------------------------------------------------
;
;***************************** Input and Output *****************************
;
; Input:
;     The current channel's scaled signal energy present in the buffer 
;                                                            x:sig_buf.
;     The current channel's initial value of noise energy in x:n_e.
; Output:
;     The current channel's detect value (silence/invalid) in x:fsm_in 
;
;***************************** Calling requirements *************************
;
; none
;
;***************************** Module Description ***************************
;
; This module performs the SILENCE TEST if any of the previous tests fail.
; It checks if the current frame is an invalid/silent frame by checking the 
; signal energy with a noise threshold,depending on which it decides whether                       
; the detected tone is SILENT/INVALID. The SILENT/INVALID tones are assigned 
; the values -2/-1 respectively. The detected tone is the input to  
; the state machine.This test is by-passed if the detected tone is VALID one. 
; Depending on the detected tone ( SILENT/INVALID ), the noise energy is
; updated for next comparison with signal energy during this test for next
; frame.
;
;******************************* Pseudo Code ********************************
;Module SIL_CHK
;BEGIN
;   Get current channel's sig_energy;
;   Get current channel's noise energy(n_e);
;
;     if (Thresh6*sig_energy <= n_e)   
;        fsm_in = SILENCE; 
;     else
;        fsm_in = INVALID;
;     endif
;
;     if (sig_energy < n_e)
;        alfa = al1;
;     else
;        if (beta*sig_energy > n_e)
;           alfa = al2;
;        else
;           alfa = al3;
;        endif 
;     endif
;     
;     n_e = (1-alfa)*n_e + alfa*sig_energy;
;
;END
;End Module
;
;****************************** Assembly Code *******************************

SIL_DEC:
	move    a,x:sig_energy        ;sig_energy(hi)
	move    a0,x:sig_energy+1     ;sig_energy(lo)
    move    #n_e,r3               ;y0 -> base of n_e buffer
                                              
    move    a1,x0
	move    a0,y1
    move    #Thresh6,y0           ;Get value of Thresh6 in y0
    mpysu   y0,y1,a               ;a = sig_energy(lo)*Thresh6
    move    a1,r2                 ;r2 = a1 
    move    a2,a                  ;LS part of a1 = a2, a0 =0
    move    r2,a0                 ;a0 = r2
    mac     x0,y0,a               ;a = (sig_energy(lo)*Thresh6 >>
                                  ;  16) + (sig_energy(hi)*Thresh6)
    move    x:(r3)+,b             ;b = Initial value of noise 
    move    x:(r3)-,b0            ;  energy of current channel 
    cmp     b,a                   ;Compare scaled signal energy 
                                      ;  with noise energy.
    bgt     _setval               ;If signal is greater goto label
    move    #1,n                  ;  _setval,else set x:fsm_in to 
    bra     assign1               ;  SILENCE & goto label assign1
_setval                           ;
    move    #0,n                  ;Set x:fsm_in to INVALID
assign1              
	move    x:sig_energy,a        ;Get sig_energy(hi)
	move    x:sig_energy+1,a0     ;Get sig_energy(lo)
    cmp     b,a                   ;Compare signal energy with 
    bge     _chk2                 ;  noise energy,if >= goto _chk2
    move    #al1,x:alfa           ;Else set ALFA to al1
    bra     _n_upd                ;Go to noise update (_n_upd)
_chk2                             ;
    move    #beta,y0              ;Get BETA in y0
    mpysu   y0,y1,a               ;a = sig_energy(lo)*beta
    move    a1,r2                 ;r2 = a1
    move    a2,a                  ;LS part of a1 = a2,a0 = 0
    move    r2,a0                 ;a0 = r2
    mac     x0,y0,a               ;a = (sig_energy(lo)*beta >>
                                  ;  16) + (sig_energy(hi)*beta)
    cmp     b,a                   ;Compare scaled signal energy
    bge     _set41                ;  with noise energy,if >= goto
    move    #al2,x:alfa           ;  _set41,else set ALFA to al2.
    bra     _n_upd                ;Goto noise update(_n_upd)
_set41                            ;
    move    #al3,x:alfa           ;Set ALFA to al3
_n_upd                            ;
    move    x:alfa,y0             ;Get ALFA in y0
    mpysu   y0,y1,a               ;a = sig_energy(lo)*alfa
    move    a1,r2                 ;r2 = a1
    move    a2,a                  ;LS part of a1 = a2,a0 = 0
    move    r2,a0                 ;a0 = r2
    mac     x0,y0,a               ;a = (sig_energy(lo)*alfa >> 
                                  ;  16) + (sig_energy(hi)*alfa)
    clr     b                     ;Clear b
    move    #$8000,b1             ;b1 = #01
    sub     y0,b                  ;b1 = (1-alfa)
    move    b,y0                  ;y0 = (1-alfa)
    move    x:(r3)+,x0            ;Get noise_energy(hi) in x0
    move    x:(r3)-,y1            ;Get noise_energy(lo) in y1
    mpysu   y0,y1,b               ;b = noise_energy(lo)*(1-alfa)
    move    b1,r2                 ;r2=b1
    move    b2,b                  ;LS part of b1 = b2,b0 = 0
    move    r2,b0                 ;b0 = r2
    mac     y0,x0,b               ;b = (noise_energy(lo)*(1-alfa)
                                  ;  >> 16) + (noise_energy(hi)*
                                  ;  (1-alfa)).
    add     b,a                   ;a = (1-alfa)*noise_energy +
                                  ;  sig_energy*alfa
	move    #NOISE_LEVEL1,b		  ;Ceiling noise threshold
	move    #NOISE_LEVEL2,b0      ;  = -18dB
	cmp     b,a			          ;If ( a >= -18dB)
	tge     b,a			          ;  a = -18dB
    move    a,x:(r3)+             ;Store updated noise energy in 
    move    a0,x:(r3)-            ;  x:n_e & x:n_e+1
    move    n,x0                  ;x0 =1 means silence detected
	    		                  ;  Return value to calling module

    rts

;****************************************************************************                                          
	endsec



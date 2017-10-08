;------------------------------------------------------------------------------
; Module Name:	 cpsi_low.asm
;
; Last Updated:  26.Sep.2000
;
; Author Name:   Manohar Babu
;
; Description:	This module is designed to provide the low-level routines
;		invoked by the API routines found in cpsi_api.asm.  These
;		routines perform the necessary calculations and tests for
;		the call progress/silence detection module.
;
;------------------------------------------------------------------------------

      include "cpt_api.inc"                   	; include CPT definitions

      SECTION cpt_data	
	
	
	  ORG     x:


;******************************************* 
; Call Progress, Silence detection variables 
;******************************************* 

alfa          ds      1                        ;Energy updation factor

      ENDSEC
	
	
	  SECTION cpt_code			

;------------------------------------------------------------------------------ 
; External Routine Definitions 
;------------------------------------------------------------------------------ 

	;--- Low-Level Function Prototypes ---;

	  GLOBAL 	SIL_DEC

      ORG       p:	

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
;  Input :       a = Signal energy computed at 20msec interval
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
        move    a,x:sig_energy            ;sig_energy(hi)
        move    a0,x:sig_energy+1         ;sig_energy(lo)
        move    #n_e,r3                   ;y0 -> base of n_e buffer
        
        move    a1,x0
    	move    a0,y1
        move    #Thresh6,y0               ;Get value of Thresh6 in y0
        mpysu   y0,y1,a                   ;a = sig_energy(lo)*Thresh6
        move    a1,r2                     ;r2 = a1 
        move    a2,a                      ;LS part of a1 = a2, a0 =0
        move    r2,a0                     ;a0 = r2
        mac     x0,y0,a                   ;a = (sig_energy(lo)*Thresh6 >>
                                          ;  16) + (sig_energy(hi)*Thresh6)
        move    x:(r3)+,b                 ;b = Initial value of noise 
        move    x:(r3)-,b0                ;  energy of current channel 
        cmp     b,a                       ;Compare scaled signal energy 
                                          ;  with noise energy.
        bgt     _setval                   ;If signal is greater goto label
        move    #1,n                      ;  _setval,else set x:fsm_in to 
        bra     assign1                   ;  SILENCE & goto label assign1
_setval                                   ;
        move    #0,n                      ;Set x:fsm_in to INVALID
assign1              
        move    x:sig_energy,a            ;Get sig_energy(hi)
        move    x:sig_energy+1,a0         ;Get sig_energy(lo)
        cmp     b,a                       ;Compare signal energy with 
        bge     _chk2                     ;  noise energy,if >= goto _chk2
        move    #al1,x:alfa               ;Else set ALFA to al1
        bra     _n_upd                    ;Go to noise update (_n_upd)
_chk2                                     ;
        move    #beta,y0                  ;Get BETA in y0
        mpysu   y0,y1,a                   ;a = sig_energy(lo)*beta
        move    a1,r2                     ;r2 = a1
        move    a2,a                      ;LS part of a1 = a2,a0 = 0
        move    r2,a0                     ;a0 = r2
        mac     x0,y0,a                   ;a = (sig_energy(lo)*beta >>
                                          ;  16) + (sig_energy(hi)*beta)
        cmp     b,a                       ;Compare scaled signal energy
        bge     _set41                    ;  with noise energy,if >= goto
        move    #al2,x:alfa               ;  _set41,else set ALFA to al2.
        bra     _n_upd                    ;Goto noise update(_n_upd)
_set41                                    ;
        move    #al3,x:alfa               ;Set ALFA to al3
_n_upd                                    ;
        move    x:alfa,y0                 ;Get ALFA in y0
        mpysu   y0,y1,a                   ;a = sig_energy(lo)*alfa
        move    a1,r2                     ;r2 = a1
        move    a2,a                      ;LS part of a1 = a2,a0 = 0
        move    r2,a0                     ;a0 = r2
        mac     x0,y0,a                   ;a = (sig_energy(lo)*alfa >> 
                                          ;  16) + (sig_energy(hi)*alfa)
        clr     b                         ;Clear b
        move    #$8000,b1                 ;b1 = #01
        sub     y0,b                      ;b1 = (1-alfa)
        move    b,y0                      ;y0 = (1-alfa)
        move    x:(r3)+,x0                ;Get noise_energy(hi) in x0
        move    x:(r3)-,y1                ;Get noise_energy(lo) in y1
        mpysu   y0,y1,b                   ;b = noise_energy(lo)*(1-alfa)
        move    b1,r2                     ;r2=b1
        move    b2,b                      ;LS part of b1 = b2,b0 = 0
        move    r2,b0                     ;b0 = r2
        mac     y0,x0,b                   ;b = (noise_energy(lo)*(1-alfa)
                                          ;  >> 16) + (noise_energy(hi)*
                                          ;  (1-alfa)).
        add     b,a                       ;a = (1-alfa)*noise_energy +
                                          ;  sig_energy*alfa
        move    #NOISE_LEVEL1,b           ;Ceiling noise threshold
        move    #NOISE_LEVEL2,b0          ;  = -18dB
        cmp     b,a	                      ;If ( a >= -18dB)
        tge     b,a                       ;  a = -18dB
        move    a,x:(r3)+                 ;Store updated noise energy in 
        move    a0,x:(r3)-                ;  x:n_e & x:n_e+1
        move    n,x0                      ;x0 =1 means silence detected
                                          ;  Return value to calling module

        rts

        ENDSEC
        
;****************************************************************************                                          
	
	    


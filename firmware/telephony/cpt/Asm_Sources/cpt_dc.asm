;------------------------------------------------------------------------------
; Module Name:	cpt_dc.asm
;
; Description:	This module contains the memory constant (DC) definitions
;		for the tone_api module.  Note that these constants are
;		a good candidate for x-rom.
;
; Last Update:	15.Sep.2000
;------------------------------------------------------------------------------
     
Pi              SET     3.141592654     ;Set value of Pi
f12             SET     350.0           ;MG Filters for CPT detection
f13             SET     485.0
f14             SET     435.0
f15             SET     620.0
f16             SET     280.0
f17             SET     700.0

Fs              SET     4000            ; Sampling Rate


    SECTION     cpt_data
    
    GLOBAL      cpt_cosval
    
	ORG         x:

cpt_cosval
	dc      @cos(2.0*f12*Pi/Fs)       ;cosval(12) 
	dc      @cos(2.0*f13*Pi/Fs)       ;cosval(13) 
	dc      @cos(2.0*f14*Pi/Fs)       ;cosval(14) 
	dc      @cos(2.0*f15*Pi/Fs)       ;cosval(15) 
	dc      @cos(2.0*f16*Pi/Fs)       ;cosval(16) 
	dc      @cos(2.0*f17*Pi/Fs)       ;cosval(16) 

    ENDSEC


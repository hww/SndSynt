;------------------------------------------------------------------------------
; Module Name:	tone_dc.asm
;
; Description:	This module contains the memory constant (DC) definitions
;		for the tone_api module.  Note that these constants are
;		a good candidate for x-rom.
;
; LastUpdate:01/04/98;------------------------------------------------------------------------------

	include "tone_api.inc"			; include DTMF definitions


    section dtmf_xrom GLOBAL


;****************************************************************************
;Declaring XROM variables for external reference
;***************************************************************************
	org     x:
	
	GLOBAL  cosval

	GLOBAL  Thresh2a
	GLOBAL  Thresh2b
	GLOBAL  Thresh5a
	GLOBAL  Thresh5b
	GLOBAL  map_to_digit



	org x:
;************************
; DTMF x-memory constants
;************************
;Values of cosines used in MG filtering
cosval                                    ;Constants in x-rom 
	dc      0.4539794921875          ;@cos(2.0*f0*Pi/Fs)        cosval(0) 
	dc      0.352020263671875        ;@cos(2.0*f1*Pi/Fs)        cosval(1) 
	dc      0.2349853515625          ;@cos(2.0*f2*Pi/Fs)        cosval(2) 
	dc      0.092529296875           ;@cos(2.0*f3*Pi/Fs)        cosval(3) 
	dc     -0.322418212890625        ;@cos(2.0*f4*Pi/Fs)        cosval(4) 
	dc     -0.504974365234375        ;@cos(2.0*f5*Pi/Fs)        cosval(5) 
	dc     -0.679962158203125        ;@cos(2.0*f6*Pi/Fs)        cosval(6) 
	dc     -0.8375244140625          ;@cos(2.0*f7*Pi/Fs)        cosval(7) 
	dc     -0.01727294921875         ;@cos(2.0*f8*Pi/Fs)        cosval(8) 
	dc      0.552947998046875        ;@cos(2.0*f9*Pi/Fs)        cosval(9) 



	org x:

;------------------------------------------------------------------------------
;Thresholds for DTMF detection tests. Use either set of variables depending 
; on performance
;------------------------------------------------------------------------------


Thresh2a dc     0.50396                    ;Table for Test 2 thresholds 
	dc      0.35939 
	dc	0.39213
	dc      0.19203 
	dc      0.33670 
	dc      0.28012
	dc      0.15347 
	dc      0.12347 
Thresh2b dc     0.31860
	dc      0.19372
	dc      0.16004 
	dc      0.76813 
Thresh5a dc     0.19531
	dc      0.17658 
	dc      0.17794
	dc      0.18498 
Thresh5b dc     0.25064                    ;Table for Test 5 thresholds 
	dc      0.21898 
	dc      0.24124
	dc      0.19978 
	dc      0                         ;Just a dummy word for filter(8) 
	dc      0                         ;Just a dummy word for filter(9) 



;The buffers are as follows for each channel : 
;2*NO_FIL locations per channel & all channels' buffers placed end to end. 
; 
;Channel 1 
;  s0(k) 
;  s0(k-1) 
;  s1(k) 
;  s1(k-1) 
;    . 
;    . 
;    . 
;    . 
; 
;  Similarly for all channels 


; Table for mapping detected tones to key values
;
map_to_digit    dc   $31
                dc   $32
                dc   $33
                dc   $41
                dc   $34
                dc   $35
                dc   $36
                dc   $42
                dc   $37
                dc   $38
                dc   $39
                dc   $43
                dc   $2a
                dc   $30
                dc   $23
                dc   $44


    endsec

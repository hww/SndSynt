;**************************************************************************
;
;   Motorola India Electronics Ltd.
;
;   PROJECT NAME    : DTMF Detection
;
;   ORIGINAL AUTHOR : N.G.Pai
;
;   MODULE NAME     : 
;
;**************************************************************************
;
;   MODULE TESTED   : tone_api.asm,tone_buf.asm,dtmf_api.asm,dtmf_low.asm
;                     cpsi_api.asm,cpsi_low.asm
;
;   DATE            :
;
;**************************************************************************
;
;   PROCESSOR       : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  : test coverage
;                  test case i/o files
;                  test activation settings
;
;**************************************************************************

        include "tone_api.inc"

        SECTION tdtmf_det GLOBAL

   
        org     p:
         
        
        GLOBAL  FPROCESS_DTMF
        
	    xref    PAPI_DTMF_DETECT
	    xref    INIT_DTMF_DETECT
         

;--------------------------------------------------------------------------
; Program Starts Here
;--------------------------------------------------------------------------
 

FPROCESS_DTMF
        
        lea     (sp)+
		lea     (sp)+                     ;space for status output
		                                  ;  if status = DIGIT_DETECTED
										  ;  a valid DTMF key is detected
        move    r2,x:(sp)+                ;x:(sp-4) = Input Buffer Pointer
        lea     (sp)+
        
        jsr     PAPI_DTMF_DETECT

        pop     x0                        ;x0 = return val
        pop     a                         ;a = on time
        pop                               ;Re-adjust Stack Pointer
		pop     y0                        ;Get the status of the frame

		cmp     #DIGIT_DETECTED,y0
		bne     _no_digit
        move    x0,y0
        rts
_no_digit
        move    #~DIGIT_DETECTED,y0
        nop
EndTest
        rts

        ENDSEC




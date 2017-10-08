;**************************************************************************
;
;   Motorola India Electronics Ltd.
;
;   PROJECT NAME    : CALL PROGRESS TONE Detection
;
;   ORIGINAL AUTHOR : Manohar Babu
;
;   MODULE NAME     : process_cpt.asm
;
;**************************************************************************
;
;   MODULE TESTED   : tone_api.asm,tone_buf.asm,tone_low.asm
;                     cpsi_api.asm,cpsi_low.asm
;
;   DATE            : 26.Sep.2000
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


        SECTION  cpt_code  
 ;      tcpt_det GLOBAL

   
        org     p:
         
        
        GLOBAL  FPROCESS_CPT
        
         

;--------------------------------------------------------------------------
; Program Starts Here
;--------------------------------------------------------------------------
 

FPROCESS_CPT
        
        lea     (sp)+
		lea     (sp)+                     ;space for status (return_value & on_time) output
	
        
        jsr     PAPI_TONE_DETECT

        pop     y0                        ;y0 = return val
        pop     a                         ;a = on time

        rts

        ENDSEC




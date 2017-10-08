;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_det.asm
;
; Description:  Calls the basic functions in a particular order
;
; Modules
;    Included:  FCAS_DETECT               
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

      SECTION CAS_DETECT

      GLOBAL  FCAS_DETECT
      
      include "cas_equ.asm"      

        org p:
                
;********************************************************************
;
; Module Name:  FCAS_DETECT
;
; Description:  Calls basic functional modules in order.
;
; Functions 
;      Called:  All the basic functional modules
;
; Calling 
; Requirements: Output : y0 : valid cas flag
;
; C Callable:   Yes
;
; Reentrant:    No
;
; Globals:      None
;
; Statics:      None
;
; Registers 
;      Changed: All
;
; DO loops:     None
;
; REP loops:    None
;
; Environment:  MetroWerks on PC
;
; Special
;     Issues:   For processor 56824
;
;
;******************************Change History************************
;
;   DD/MM/YY   Code Ver      Description        Author
;   --------   --------      -----------        ------
;   15/07/98    0.00         Module created     Andy T.W.Lam
;   14/11/2000  1.00         Modified           Sandeep & B.L.Prasad 
;
;********************************************************************     


FCAS_DETECT:
                 
        lea     (sp)+
        move    omr,x:(sp)
        bfset   #$0020,OMR           ; set 2's complement rounding

        jsr     FILTER_CAS           ; FILTER the signal by highpass filter
                                     ; and band filters
        
        jsr     ENG_CAS              ; calculate signal and band pass energy

        
        jsr     CALSNR_CAS           ; calculate snr

        
        jsr     PERIOD_CAS           ; calculate periods

        
        jsr     SHFPER_CAS           ; calculate period shifts

        
        jsr     METRIC_CAS           ; calculate metric

        
        jsr     DETERMINE_CAS        ; determine valid_cas in x0
        
        move    x0,y0                ; return value of cas flag in y0

        pop     omr
                
        rts


        ENDSEC

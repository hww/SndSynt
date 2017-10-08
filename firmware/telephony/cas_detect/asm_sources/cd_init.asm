;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_init.asm
;
; Description:  Initialize CAS Detect.
;
; Modules
;    Included:  FCAS_DETECT_INIT
;                             
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        


        SECTION  CAS_DETECT

        GLOBAL   FCAS_DETECT_INIT
        
        include "cas_equ.asm"

        org   p:
        
;********************************************************************
;
; Module Name:  FCAS_DETECT_INIT
;
; Description:  Initializes CAS Detect 
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: This function should be called before CAS processing
;               functions.
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
; DO loops:     10, but not nested.
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
        

FCAS_DETECT_INIT:

        clr     x0

; clear signal,f1,f2 buffer
        move    #cd_sig_buf,r0
        do      #CD_BUFF_SIZE,sigbuf_zero
        move    x0,x:(r0)+
sigbuf_zero
        move    #cd_f1_buf,r0
        do      #CD_BUFF_SIZE,f1buf_zero
        move    x0,x:(r0)+
f1buf_zero
        move    #cd_f2_buf,r0
        do      #CD_BUFF_SIZE,f2buf_zero
        move    x0,x:(r0)+
f2buf_zero

;Clear Highpass Biquad Filter States;
        move    #cd_hpf_z,r0
        do      #(2*NO_OF_BIQD+2),hpf_z_zero
        move    x0,x:(r0)+
hpf_z_zero
;Clear F1 Biquad Filter States;
        move    #cd_f1_z,r0
        do      #(2*NO_OF_BIQD+2),f1_z_zero
        move    x0,x:(r0)+
f1_z_zero
;Clear F2 Biquad Filter States;
        move    #cd_f2_z,r0
        do      #(2*NO_OF_BIQD+2),f2_z_zero
        move    x0,x:(r0)+
f2_z_zero

; Clear Signal power buffer
        move    #cd_sig_pw_buf,r0
        do      #(2*CD_SIG_PW_BUF_SIZE),sig_pw_zero
        move    x0,x:(r0)+
sig_pw_zero

; Clear period buffer
        move    #cd_f1_per_buf,r0
        do      #(2*CD_MIN_PERIOD_TIME),f1_per_zero
        move    x0,x:(r0)+
f1_per_zero
        move    #cd_f2_per_buf,r0
        do      #(2*CD_MIN_PERIOD_TIME),f2_per_zero
        move    x0,x:(r0)+
f2_per_zero

; Clear metric buffer
        move    #cd_metric_buf,r0
        do      #CD_MIN_ON_TIME,met_buf_zero
        move    x0,x:(r0)+
met_buf_zero

; clear on timer and potential cas
        move    #0,x:cd_on_timer
        move    #0,x:cd_potential_cas

        rts
       
        ENDSEC 

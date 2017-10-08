;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_msc.asm
;
; Description:  Assembly module for calculating SNR and determining
;               CAS
;
; Modules
;    Included:  CALSNR_CAS
;               DETERMINE_CAS               
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        


     SECTION CAS_DETECT
    
     GLOBAL  CALSNR_CAS

     GLOBAL  DETERMINE_CAS 
     
     include "cas_equ.asm"
     include "portasm.h"
  
     org     p:

;********************************************************************
;
; Module Name:  CALSNR_CAS
;
; Description:  Calculates the SNR and the twist.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: This function should be called after the
   ;            the call to ENG_CAS  routine.
;
; C Callable:   No
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
; DO loops:     1
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

CALSNR_CAS:

; store signal power in buffer and get max signal
     move   x:cd_sig_pw,b
     move   x:(cd_sig_pw+1),b0            ; set b as max_sig_pw = sig_pw
     move   #(cd_sig_pw_buf+2*(CD_SIG_PW_BUF_SIZE-2)+1),r2
     move   #(cd_sig_pw_buf+2*(CD_SIG_PW_BUF_SIZE-1)+1),r0

     move   x:(r2)-,y0
     move   x:(r2)-,a
     move   y0,a0
     move   #CD_SIG_PW_BUF_SIZE-1,lc
 if V2_WORKAROUND==1
     doslc  _csnr_loop
 else
     do     lc,_csnr_loop
 endif
     move   a0,x:(r0)-
     move   a,x:(r0)-
     cmp    b,a
     tgt    a,b                            ;save if a > b
_csnr_com
     move   x:(r2)-,y0
     move   x:(r2)-,a
     move   y0,a0
_csnr_loop
     move   x:cd_sig_pw,y1
     move   x:(cd_sig_pw+1),y0
     move   y0,x:(r0)-
     move   y1,x:(r0)-                    ; cd_sig_pw_buf[0]=cd_sig_pw

; calculate snr
     move   b,x:cd_snr_lower
     move   b0,x:(cd_snr_lower+1)         ; cd_snr_lower = cd_max_sig_pw
     cmp    #0,y1
     bne    _csnr_com1
     cmp    #0,y0
     bne    _csnr_com1                    ; sig_pw <> 0 ? no,jump
     move   #0,x:cd_snr_upper
     move   #0,x:(cd_snr_upper+1)         ; cd_snr_upper = 0
     bra    _csnr_com2
_csnr_com1
     move   x:cd_f1_bpf_pw,b
     move   x:(cd_f1_bpf_pw+1),b0
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0
     add    a,b
     move   b,x:cd_snr_upper
     move   b0,x:(cd_snr_upper+1)         ; cd_snr_upper = cd_f1_bpf_pw + 
                                          ; cd_f2_bpf_pw
_csnr_com2

; calculate twist
     move   x:cd_f1_bpf_pw,b
     move   x:(cd_f1_bpf_pw+1),b0
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0
     cmp    a,b
     bgt    _csnr_com3
     move   a,x:cd_twist_db_lower
     move   a0,x:(cd_twist_db_lower+1)    ; twist_db_lower = f2_bpf_pw
     move   b,x:cd_twist_db_upper
     move   b0,x:(cd_twist_db_upper+1)    ; twist_db_upper = f1_bpf_pw
     bra    _csnr_com4
_csnr_com3
     move   b,x:cd_twist_db_lower
     move   b0,x:(cd_twist_db_lower+1)    ; twist_db_lower = f1_bpf_pw
     move   a,x:cd_twist_db_upper
     move   a0,x:(cd_twist_db_upper+1)    ; twist_db_upper = f2_bpf_pw
_csnr_com4

     rts

;********************************************************************
;
; Module Name:  DETERMINE_CAS
;
; Description:  Determines if valid CAS is present.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: Ouput : valid CAS is passed in x0
;               
;               This function should be called after the
;               the call to METRIC_CAS  routine.
;
; C Callable:   No
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


DETERMINE_CAS:

     move   #1,x:cd_temp0                 ; set valid_frame
     move   #1,x:cd_temp1                 ; set valid_energy
     move   #1,x:cd_temp2                 ; set valid_freq

; perform absolute energy test
     move   #CD_ABS_THRESHOLD_IMAG_HIGH,b
     move   #CD_ABS_THRESHOLD_IMAG_LOW,b0 ; b = abs_thd
     move   x:cd_f1_bpf_pw,a
     move   x:(cd_f1_bpf_pw+1),a0         ; a = f1_bpf_pw
     cmp    b,a                                 
     blt    _detcas_abs_next              ; a<b? yes, jump
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0         ; a = f2_bpf_pw
     cmp    b,a
     bge    _detcas_abs_end               ; a>=b? yes, jump
_detcas_abs_next
     move   #0,x:cd_temp0                 ; clr valid_frame
     move   #0,x:cd_temp1                 ; clr valid_energy
_detcas_abs_end

; perform twist test
     move   x:cd_twist_db_lower,y1
     move   x:(cd_twist_db_lower+1),y0    ; y = twist_db_lower
     move   x:cd_twist_db_upper,b
     move   x:(cd_twist_db_upper+1),b0    ; b = twist_db_upper
     move   #CD_MAX_TWIST_TEST_THD,x0     ; x0 = max_twist_test_thd
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                       ; a=x0*y
     cmp    a,b
     bge    _detcas_tw_end                ; twist_db_upper >= thd_a*lower? yes
     move   #0,x:cd_temp0                 ; clr valid_frame
     move   #0,x:cd_temp1                 ; clr valid_energy
_detcas_tw_end

; perform period test
     move   x:cd_f1_period,a
     move   x:(cd_f1_period+1),a0
     move   #CD_MAX_F1_PER_TEST_THD_HIGH,b
     move   #CD_MAX_F1_PER_TEST_THD_LOW,b0
     cmp    b,a
     bgt    _detcas_per_next              ; f1_period > f1_max_per_thd_a? yes,
     move   #CD_MIN_F1_PER_TEST_THD_HIGH,b
     move   #CD_MIN_F1_PER_TEST_THD_LOW,b0
     cmp    b,a
     blt    _detcas_per_next              ; f1_period < f1_min_per_thd_a? yes,
     move   x:cd_f2_period,a
     move   x:(cd_f2_period+1),a0
     move   #CD_MAX_F2_PER_TEST_THD_HIGH,b
     move   #CD_MAX_F2_PER_TEST_THD_LOW,b0
     cmp    b,a
     bgt    _detcas_per_next              ; f2_period > f2_max_per_thd_a? yes,
     move   #CD_MIN_F2_PER_TEST_THD_HIGH,b
     move   #CD_MIN_F2_PER_TEST_THD_LOW,b0
     cmp    b,a
     bge    _detcas_per_end               ; f2_period >= f2_min_per_thd_a? yes,
_detcas_per_next
     move   #0,x:cd_temp0                 ; clr valid_frame
     move   #0,x:cd_temp2                 ; clr valid_freq
_detcas_per_end

     clr    x0
     move   x0,x:cd_temp3                 ; clr valid_cas
     move   x:cd_potential_cas,y0
     cmp    x0,y0
     bne    _detcas_potent                ; potentail <> 0 ? yes
     move   x:cd_temp0,y0
     cmp    x0,y0
     beq    _detcas_npotent_next          ; valid_frame <> 0? yes
     move   x:cd_on_timer,y0               
     add    #1,y0
     move   y0,x:cd_on_timer              ; cd_on_timer++
     cmp    #CD_MIN_ON_TIME,y0
     jlt    _detcas_potent_end            ; cd_on_timer < CD_ON_TIME? yes
     move   x:cd_total_metric,a
     move   x:(cd_total_metric+1),a0      ; a = total_metric
     move   #CD_TOTAL_METRIC_THD_HIGH,b
     move   #CD_TOTAL_METRIC_THD_LOW,b0   ; b = total_metric_thd
     cmp    b,a
     jle    _detcas_potent_end            ; a <= b? yes
     move   #1,x:cd_potential_cas         ; cd_potential_cas = 1
     move   #CD_OFF_THD_FACTOR,x0         ; x0 = off_thd_factor
     move   x:cd_f1_bpf_pw,y1
     move   x:(cd_f1_bpf_pw+1),y0         ; y = f1_bpf_pw
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                       ; a=off_thd_factor*f1_bpf_pw
     move   a,x:cd_f1_off_thd
     move   a0,x:(cd_f1_off_thd+1)        ; cd_f1_off_thd = a
     move   x:cd_f2_bpf_pw,y1
     move   x:(cd_f2_bpf_pw+1),y0         ; y = f2_bpf_pw
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                       ; a=off_thd_factor*f1_bpf_pw
     move   a,x:cd_f2_off_thd
     move   a0,x:(cd_f2_off_thd+1)        ; cd_f2_off_thd = a
     bra    _detcas_potent_end
_detcas_npotent_next
     move   #0,x:cd_on_timer
     bra    _detcas_potent_end
_detcas_potent
     move   x:cd_f1_bpf_pw,a
     move   x:(cd_f1_bpf_pw+1),a0         ; a = f1_bpf_pw
     move   x:cd_f1_off_thd,b
     move   x:(cd_f1_off_thd+1),b0        ; b = f1_off_thd
     cmp    b,a
     ble    _detcas_potent_next           ; f1_bpf_pw < = f1_off_thd? yes
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0         ; a = f2_bpf_pw
     move   x:cd_f2_off_thd,b
     move   x:(cd_f2_off_thd+1),b0        ; b = f2_off_thd
     cmp    b,a
     ble    _detcas_potent_next           ; f2_bpf_pw < = f2_off_thd? yes
     incw   x:cd_on_timer
     bra    _detcas_potent_end
_detcas_potent_next
     move   x:cd_on_timer,y0
     cmp    #CD_MAX_ON_TIME,y0
     bgt    _detcas_potent_n1             ; cd_on_timer > max_on_time?yes
     move   #1,x:cd_temp3                 ; valid_cas = 1
_detcas_potent_n1
     move   #0,x:cd_potential_cas         ; cd_potential_cas = 0
     move   #0,x:cd_on_timer              ; cd_on_timer = 0
_detcas_potent_end

     move   x:cd_temp3,x0
     rts


     ENDSEC

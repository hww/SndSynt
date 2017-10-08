;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_met.asm
;
; Description:  This module calculates the snr_metric, period_metric, 
;               aps_metric,twist_metric,power_metric and total_metric  
;               for a given frame.
;
; Modules
;    Included:  METRIC_CAS
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

     SECTION CAS_DETECT

     GLOBAL  METRIC_CAS

     include "cas_equ.asm"
     include "portasm.h"

     org     p:
     
;********************************************************************
;
; Module Name:  METRIC_CAS
;
; Description:  This module calculates the snr_metric, period_metric, 
;               aps_metric,twist_metric,power_metric and total_metric  
;               for a given frame.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: This function should be called after the
   ;            the call to SHFPER_CAS  routine.
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
; DO loops:     3, but not nested
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
     
METRIC_CAS:

     move   #0,x:cd_metric                      ; init cd_metric

; absoulte energy metric
     move   #CD_ABS_4DB_THRESHOLD_IMAG_HIGH,b
     move   #CD_ABS_4DB_THRESHOLD_IMAG_LOW,b0   ; b = abs_4db_thd
     move   x:cd_f1_bpf_pw,a
     move   x:(cd_f1_bpf_pw+1),a0               ; a = f1_bpf_pw
     cmp    b,a                                 
     ble    _metcas_abs_next                    ; a<=b? yes, jump
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0               ; a = f2_bpf_pw
     cmp    b,a
     ble    _metcas_abs_next                    ; a<=b? yes, jump
     move   #2,x:cd_metric
     bra    _metcas_abs_end                     ; set cd_metric = 1
_metcas_abs_next
     move   #CD_ABS_2DB_THRESHOLD_IMAG_HIGH,b
     move   #CD_ABS_2DB_THRESHOLD_IMAG_LOW,b0   ; b = abs_4db_thd
     move   x:cd_f1_bpf_pw,a
     move   x:(cd_f1_bpf_pw+1),a0               ; a = f1_bpf_pw
     cmp    b,a
     ble    _metcas_abs_end                     ; a<=b? yes, jump
     move   x:cd_f2_bpf_pw,a
     move   x:(cd_f2_bpf_pw+1),a0               ; a = f2_bpf_pw
     cmp    b,a
     ble    _metcas_abs_end                     ; a<=b? yes, jump
     move   #1,x:cd_metric                      ; set cd_metric =1
_metcas_abs_end

; twist db metric
     move   x:cd_twist_db_lower,y1
     move   x:(cd_twist_db_lower+1),y0          ; y = twist_db_lower
     move   x:cd_twist_db_upper,b
     move   x:(cd_twist_db_upper+1),b0          ; b = twist_db_upper

     move   #CD_TWIST_THD_A,x0                  ; x0 = twist_thd_a
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     ble    _metcas_tw_next                     ; twist_db_upper <= thd_a*lower
                                                ;  ? yes
     move   x:cd_metric,a
     add    #3,a
     move   a,x:cd_metric
     bra    _metcas_tw_end                      ; cd_metric += 3
_metcas_tw_next
     move   x:cd_twist_db_lower,y1
     move   x:(cd_twist_db_lower+1),y0          ; y = twist_db_lower
     move   #CD_TWIST_THD_B,x0                  ; x0 = twist_thd_b
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     ble    _metcas_tw_next1                    ; twist_db_upper <= thd_b*lower
                                                ;  ? yes
     move   x:cd_metric,a
     add    #2,a
     move   a,x:cd_metric
     bra    _metcas_tw_end                      ; cd_metric += 2
_metcas_tw_next1
     move   x:cd_twist_db_lower,y1
     move   x:(cd_twist_db_lower+1),y0          ; y = twist_db_lower
     move   #CD_TWIST_THD_C,x0                  ; x0 = twist_thd_c
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     ble    _metcas_tw_end                      ; twist_db_upper <= thd_c*lower
                                                ;  ? yes
     move   x:cd_metric,a
     add    #1,a
     move   a,x:cd_metric                       ; cd_metric += 1
_metcas_tw_end

; large energy but large twist metic
     move   x:cd_twist_db_lower,y1
     move   x:(cd_twist_db_lower+1),y0          ; y = twist_db_lower
     move   #CD_TWIST_THD_NORMAL,x0             ; x0 = twist_thd_normal
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     bge    _metcas_lelt_end                    ; twist_db_upper >= thd_c*lower
                                                ;  ? yes
     move   x:cd_snr_lower,y1
     move   x:(cd_snr_lower+1),y0
     move   x:cd_snr_upper,b
     move   x:(cd_snr_upper+1),b0
     move   #CD_TWIST_SNR_THRESHOLD,x0
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     ble    _metcas_lelt_end                    ; snr_upper <= 
                                                ;   twist_snr_thd*lower? yes
     move   x:cd_metric,a
     sub    #1,a
     move   a,x:cd_metric                       ; cd_metric -= 1
_metcas_lelt_end

; period metric
     move   x:cd_f1_period,a
     move   x:(cd_f1_period+1),a0
     move   #CD_MAX_F1_PER_THD_A_HIGH,b
     move   #CD_MAX_F1_PER_THD_A_LOW,b0
     cmp    b,a
     bge    _metcas_per_next                    ; f1_period >= f1_max_per_thd_a
                                                ;  ? yes,
     move   #CD_MIN_F1_PER_THD_A_HIGH,b
     move   #CD_MIN_F1_PER_THD_A_LOW,b0
     cmp    b,a
     ble    _metcas_per_next                    ; f1_period <= f1_min_per_thd_a
                                                ;   ? yes,
     move   x:cd_f2_period,a
     move   x:(cd_f2_period+1),a0
     move   #CD_MAX_F2_PER_THD_A_HIGH,b
     move   #CD_MAX_F2_PER_THD_A_LOW,b0
     cmp    b,a
     bge    _metcas_per_next                    ; f2_period >= f2_max_per_thd_a
                                                ;  ? yes,
     move   #CD_MIN_F2_PER_THD_A_HIGH,b
     move   #CD_MIN_F2_PER_THD_A_LOW,b0
     cmp    b,a
     ble    _metcas_per_next                    ; f2_period <= f2_min_per_thd_a
                                                ;  ? yes,
     move   x:cd_metric,a
     add    #2,a
     move   a,x:cd_metric
     bra    _metcas_per_end                     ; cd_metric += 1
_metcas_per_next
     move   x:cd_f1_period,a
     move   x:(cd_f1_period+1),a0
     move   #CD_MAX_F1_PER_THD_B_HIGH,b
     move   #CD_MAX_F1_PER_THD_B_LOW,b0
     cmp    b,a
     bge    _metcas_per_end                     ; f1_period >= f1_max_per_thd_b
                                                ;  ? yes,
     move   #CD_MIN_F1_PER_THD_B_HIGH,b
     move   #CD_MIN_F1_PER_THD_B_LOW,b0
     cmp    b,a
     ble    _metcas_per_end                     ; f1_period <= f1_min_per_thd_b
                                                ;  ? yes,
     move   x:cd_f2_period,a
     move   x:(cd_f2_period+1),a0
     move   #CD_MAX_F2_PER_THD_B_HIGH,b
     move   #CD_MAX_F2_PER_THD_B_LOW,b0
     cmp    b,a
     bge    _metcas_per_end                     ; f2_period >= f2_max_per_thd_b
                                                ;  ? yes,
     move   #CD_MIN_F2_PER_THD_B_HIGH,b
     move   #CD_MIN_F2_PER_THD_B_LOW,b0
     cmp    b,a
     ble    _metcas_per_end                     ; f2_period <= f2_min_per_thd_b
                                                ;  ? yes,
     move   x:cd_metric,a
     add    #1,a
     move   a,x:cd_metric                       ; cd_metric += 1
_metcas_per_end

; snr addition metric
     move   #cd_snr_ar_thd,r2
     move   x:cd_snr_lower,y1
     move   x:(cd_snr_lower+1),y0
     move   x:cd_snr_upper,b
     move   x:(cd_snr_upper+1),b0
     move   #CD_MAX_SNR_ADDTION,lc
 if V2_WORKAROUND==1
     doslc  _metcas_snr_add_loop
 else
     do     lc,_metcas_snr_add_loop
 endif
     move   x:(r2)+,x0
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     ble    _metcas_snr_add_next                ; snr_upper <= 
                                                ;  twist_snr_thd*lower? yes
     incw   x:cd_metric                         ; cd_metric += 1
_metcas_snr_add_next
     move   x:cd_snr_lower,y1
     move   x:(cd_snr_lower+1),y0
_metcas_snr_add_loop

     move   #CD_MAX_SNR_REDUCTION,lc
 if V2_WORKAROUND==1
     doslc  _metcas_snr_red_loop
 else
     do     lc,_metcas_snr_red_loop
 endif
     move   x:(r2)+,x0
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                             ; a=x0*y
     cmp    a,b
     bgt    _metcas_snr_red_next                ; snr_upper > 
                                                ;  twist_snr_thd*lower? yes
     decw   x:cd_metric                         ; cd_metric -= 1
_metcas_snr_red_next
     move   x:cd_snr_lower,y1
     move   x:(cd_snr_lower+1),y0
_metcas_snr_red_loop

; store metirc in buffer
     move   x:cd_metric,a                       ; set a = cd_metric
     move   #(cd_metric_buf+1*CD_MIN_ON_TIME-2),r2
     move   #(cd_metric_buf+1*CD_MIN_ON_TIME-1),r0
     move   #CD_MIN_ON_TIME-1,lc
 if V2_WORKAROUND==1
     doslc  _metcas_stbuf_loop
 else
     do     lc,_metcas_stbuf_loop
 endif
     move   x:(r2)-,x0
     move   x0,x:(r0)-
     add    x0,a                                ; a+= metric_buf[i]
_metcas_stbuf_loop
     move   x:cd_metric,x0
     move   x0,x:(r0)-                          ; metric_buf[0]=cd_metric
     move   a,x:cd_total_metric
     move   a0,x:(cd_total_metric+1)            ; total_metric = a

; calculate total metric
     move   x:cd_aps,b
     move   x:(cd_aps+1),b0
     move   #CD_APS_HIGH_THD_HIGH,a
     move   #CD_APS_HIGH_THD_LOW,a0
     cmp    a,b
     ble    _metcas_caltmet                     ; cd_aps <= aps_high_thd? 
                                                ;  yes, jump
     move   #CD_MAX_APS_METRIC_HIGH,b
     move   #CD_MAX_APS_METRIC_LOW,b0
     move   x:cd_total_metric,a
     move   x:(cd_total_metric+1),a0
     add    b,a
     move   a,x:cd_total_metric
     move   a0,x:(cd_total_metric+1)            ; total_metric += max_aps_metric
     bra    _metcas_caltmet_end
_metcas_caltmet
     move   #CD_APS_LOW_THD_HIGH,a
     move   #CD_APS_LOW_THD_LOW,a0
     cmp    a,b
     ble    _metcas_caltmet_end                 ; cd_aps <= aps_low_thd? 
                                                ;  yes, jump
     sub    a,b                                 ; b = cd_aps-aps_low_thd

     move   b1,x0                               ; x0 = high(b)
     move   #CD_APS_METRIC_SCALE_LOW,y0         ; y0 = aps_metric_scale_low
     mpysu  x0,y0,a
     move   #CD_APS_METRIC_SCALE_HIGH,x0        ; x0 = aps_metric_scale_high
     move   b0,y0                               ; y0 = low(b)
     macsu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0                               ; a shift 16 bit
     move   b1,y1                               ; y1 = high(b)
     mac    x0,y1,a                             ; a = aps_metric_scale * 
                                                ;   (aps-low_thd)
     move   x:cd_total_metric,b
     move   x:(cd_total_metric+1),b0
     add    a,b
     move   b,x:cd_total_metric
     move   b0,x:(cd_total_metric+1)            ; total_metric += max_aps_metric
_metcas_caltmet_end

     rts


     ENDSEC

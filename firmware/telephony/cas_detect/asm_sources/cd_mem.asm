;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_mem.asm
;
; Description:  Variable declarations.
;
; Modules
;    Included:  
;                             
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

       SECTION  CAS_DETECT

;This contains the Equs & Set values for CAS Tone Detection
;=========================================================
       GLOBAL    cd_sum_coef
       GLOBAL    cd_snr_ar_thd
       GLOBAL    cd_f1_bpf_pw
       GLOBAL    cd_f2_bpf_pw
       GLOBAL    cd_f1_period
       GLOBAL    cd_f2_period
       GLOBAL    cd_aps
       GLOBAL    cd_metric
       GLOBAL    cd_total_metric
       GLOBAL    cd_on_timer
       GLOBAL    cd_potential_cas
       GLOBAL    cd_hpf_z
       GLOBAL    cd_sig_buf
       GLOBAL    cd_f1_buf
       GLOBAL    cd_f2_buf
       GLOBAL    cd_hpf_z
       GLOBAL    cd_f1_z
       GLOBAL    cd_f2_z
       GLOBAL    cd_f1_bpf_pw
       GLOBAL    cd_f2_bpf_pw
       GLOBAL    cd_sig_pw
       GLOBAL    cd_f1_max_per
       GLOBAL    cd_f1_min_per
       GLOBAL    cd_f1_off_thd
       GLOBAL    cd_f1_per_buf
       GLOBAL    cd_f2_off_thd
       GLOBAL    cd_f2_per_buf
       GLOBAL    cd_f2_max_per
       GLOBAL    cd_f2_min_per
       GLOBAL    cd_lags
       GLOBAL    cd_metric_buf
       GLOBAL    cd_peak_buf
       GLOBAL    cd_sig_pw_buf
       GLOBAL    cd_snr_lower
       GLOBAL    cd_snr_upper
       GLOBAL    cd_sum
       GLOBAL    cd_w_sum
       GLOBAL    cd_temp0
       GLOBAL    cd_temp1
       GLOBAL    cd_temp2
       GLOBAL    cd_temp3
       GLOBAL    cd_temp4
       GLOBAL    cd_temp5
       GLOBAL    cd_temp6
       GLOBAL    cd_twist_db_lower
       GLOBAL    cd_twist_db_upper       
       GLOBAL    cd_window_imag
       
       include   "cas_equ.asm"

        org     x:

; signal, f1, f2 buffer
;----------------------
cd_sig_buf      ds      CD_BUFF_SIZE
cd_f1_buf       ds      CD_BUFF_SIZE
cd_f2_buf       ds      CD_BUFF_SIZE

; HighPass, f1, f2  Filter State Buffer - zdelay
;-----------------------------------------------
cd_hpf_z        ds      (2*NO_OF_BIQD+2)
cd_f1_z         ds      (2*NO_OF_BIQD+2)
cd_f2_z         ds      (2*NO_OF_BIQD+2)

;* signal,f1,f2 energy
;---------------------
cd_f1_bpf_pw    ds      2
cd_f2_bpf_pw    ds      2
cd_sig_pw       ds      2

;* signal power buffer, maximum signal power
;-------------------------------------------
cd_sig_pw_buf   ds      (2*CD_SIG_PW_BUF_SIZE)

;* snr
;-----
cd_snr_lower    ds      2
cd_snr_upper    ds      2

;* twist
;-------
cd_twist_db_lower ds    2
cd_twist_db_upper ds    2

;* corr and lag buffer
;---------------------
cd_lags         ds      (2*CD_NUM_LAGS)
;cd_corr_sig     ds      CD_CORR_SIZE
cd_peak_buf     ds      CD_MAX_NUM_PEAKS

; highpass, f1, f2, window filter coefficients
;---------------------------------------------
;cd_hpf_coef_imag          ds    6
;cd_f1_bpf_coef_8000_imag  ds   11
;cd_f2_bpf_coef_8000_imag  ds   11
;cd_window_imag            ds   40

; f1 and f2 period
;-----------------
cd_f1_period     ds      2
cd_f2_period     ds      2
cd_w_sum         ds      2
cd_sum           ds      2
;cd_sum_coef      ds      5
cd_f1_per_buf    ds      (2*CD_MIN_PERIOD_TIME)
cd_f2_per_buf    ds      (2*CD_MIN_PERIOD_TIME)
cd_f1_min_per    ds      2
cd_f1_max_per    ds      2
cd_f2_min_per    ds      2
cd_f2_max_per    ds      2
cd_aps           ds      2

; metric and total metric
cd_metric        ds      1
cd_total_metric  ds      2
cd_metric_buf    ds      CD_MIN_ON_TIME

; detection logic
cd_on_timer      ds      1
cd_potential_cas ds      1
cd_f1_off_thd    ds      2
cd_f2_off_thd    ds      2

;Sample Counter
;--------------
cd_temp0         ds      1
cd_temp1         ds      1
cd_temp2         ds      1
cd_temp3         ds      1
cd_temp4         ds      1
cd_temp5         ds      1
cd_temp6         ds      1
cd_normcnt       ds      1

cd_sum_coef
                 dc   $1000
                 dc   $2000
                 dc   $3000
                 dc   $4000
                 dc   $5000
cd_snr_ar_thd
                 dc   $50c5
                 dc   $47fd
                 dc   $402a
                 dc   $3930
                 dc   $32f9
                 dc   $2d6f
                 dc   $040b
                 dc   $0669
                 dc   $0a29

cd_window_imag
                 dc   $00c0
                 dc   $02fc
                 dc   $06a5
                 dc   $0ba7
                 dc   $11e3
                 dc   $1934
                 dc   $216d
                 dc   $2a5e
                 dc   $33d1
                 dc   $3d8c
                 dc   $4757
                 dc   $50f5
                 dc   $5a2e
                 dc   $62ca
                 dc   $6a95
                 dc   $7160
                 dc   $7703
                 dc   $7b5c
                 dc   $7e51
                 dc   $7fd0
                 dc   $7fd0
                 dc   $7e51
                 dc   $7b5c
                 dc   $7703
                 dc   $7160
                 dc   $6a95
                 dc   $62ca
                 dc   $5a2e
                 dc   $50f5
                 dc   $4757
                 dc   $3d8c
                 dc   $33d1
                 dc   $2a5e
                 dc   $216d
                 dc   $1934
                 dc   $11e3
                 dc   $0ba7
                 dc   $06a5
                 dc   $02fc
                 dc   $00c0


      ENDSEC


      SECTION    CAS_DETECT_INT_MEM

       GLOBAL    cd_hpf_coef_imag
       GLOBAL    cd_f1_bpf_coef_8000_imag
       GLOBAL    cd_f2_bpf_coef_8000_imag
       GLOBAL    cd_corr_sig
       
       org    x:
       
       include   "cas_equ.asm"

cd_hpf_coef_imag
                 dc   $0001
                 dc   $37cb
                 dc   $906a
                 dc   $37cb
                 dc   -$be43
                 dc   -$22a3


cd_f1_bpf_coef_8000_imag
                 dc   $0002
                 dc   $078a
                 dc   $ff88
                 dc   $078a
                 dc   -$1822
                 dc   -$7e36
                 dc   $0c43
                 dc   $05ad
                 dc   $0c43
                 dc   -$1bb7
                 dc   -$7e36

cd_f2_bpf_coef_8000_imag
                 dc   $0002
                 dc   $0354
                 dc   $02a6
                 dc   $0354
                 dc   -$4584
                 dc   -$3ed7
                 dc   $06ff
                 dc   $0989
                 dc   $06ff
                 dc   -$4774
                 dc   -$3edb

cd_corr_sig     ds      CD_CORR_SIZE

      ENDSEC
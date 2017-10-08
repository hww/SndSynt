;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_equ.asm
;
; Description:  Equates for CAS
;
; Modules
;    Included: None 
;                             
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

INPUT_BUF_SIZE           equ     80
NO_OF_BIQD               equ     2
CD_FRAME_RATE            equ     10
CD_BUFF_SIZE             equ     48
CD_SIG_DELAY             equ     8
CD_F2_DELAY              equ     4
CD_WINDOW_SIZE           equ     40
CD_SIG_PW_BUF_SIZE       equ     3
CD_DEC_RATIO             equ     8
CD_WINDOW_SCALE          equ     $429a
CD_WSCALE_BIT            equ     1
CD_WSCALE_BIT1           equ     3
CD_CORR_SIZE             equ     10
CD_CORR_OFFSET           equ     15
CD_NUM_LAGS              equ     28
CD_LAGS_SHIFT_BITS       equ     2
CD_MAX_NUM_PEAKS         equ     6
CD_F1_NUM_PEAKS          equ     3
CD_F2_NUM_PEAKS          equ     5
CD_START_PEAK_SEARCH     equ     5
CD_END_PEAK_SEARCH       equ     25
CD_F1_NUM_PEAKS_CONST    equ     $4000
CD_F2_NUM_PEAKS_CONST    equ     $2000
CD_PEAK_COEF             equ     $3
CD_MIN_ON_TIME           equ     6
CD_MIN_PERIOD_TIME       equ     7
CD_MAX_ON_TIME           equ     $e
CD_MAX_SNR_ADDTION       equ     6
CD_MAX_SNR_REDUCTION     equ     3

;Threshold for calculate metric and detection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0.85 ADC drop 6dB
;CD_ABS_THRESHOLD_IMAG_LOW      equ     $b56d
;CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
;CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $4ad1
;CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0004
;CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $b552
;CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0002
; 0.886 ADC drop 5.8dB
;CD_ABS_THRESHOLD_IMAG_LOW      equ     $a79e
;CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
;CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $2820
;CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0004
;CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $9f6f
;CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0002
; 0.886 ADC drop 6dB
CD_ABS_THRESHOLD_IMAG_LOW      equ     $929a
CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $f356
CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0003
CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $7e20
CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0002
; 0.886 ADC drop 6.2dB
;CD_ABS_THRESHOLD_IMAG_LOW      equ     $824f
;CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
;CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $ca69
;CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0003
;CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $644d
;CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0002
; 0.886 ADC drop 6.5dB
;CD_ABS_THRESHOLD_IMAG_LOW      equ     $64a3
;CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
;CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $7fe0
;CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0003
;CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $3545
;CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0002
; 0.886 ADC drop 7dB
;CD_ABS_THRESHOLD_IMAG_LOW      equ     $4152
;CD_ABS_THRESHOLD_IMAG_HIGH     equ     $0001
;CD_ABS_4DB_THRESHOLD_IMAG_LOW  equ     $2727
;CD_ABS_4DB_THRESHOLD_IMAG_HIGH equ     $0003
;CD_ABS_2DB_THRESHOLD_IMAG_LOW  equ     $fd4a
;CD_ABS_2DB_THRESHOLD_IMAG_HIGH equ     $0001

CD_TWIST_THD_A                 equ     $47fb
CD_TWIST_THD_B                 equ     $392d
CD_TWIST_THD_C                 equ     $2d6b
CD_TWIST_THD_NORMAL            equ     $50c3
; 7.0 db
CD_MAX_TWIST_TEST_THD          equ     $198a
; 10.0 db
;CD_MAX_TWIST_TEST_THD          equ     $0ccd
CD_TWIST_SNR_THRESHOLD         equ     $2d6a

CD_MAX_F1_PER_TEST_THD_LOW     equ    $7b64
CD_MAX_F1_PER_TEST_THD_HIGH    equ    $0008
CD_MIN_F1_PER_TEST_THD_LOW     equ    $0979
CD_MIN_F1_PER_TEST_THD_HIGH    equ    $0007
CD_MAX_F2_PER_TEST_THD_LOW     equ    $476d
CD_MAX_F2_PER_TEST_THD_HIGH    equ    $0004
CD_MIN_F2_PER_TEST_THD_LOW     equ    $c148
CD_MIN_F2_PER_TEST_THD_HIGH    equ    $0003
;CD_MAX_F1_PER_TEST_THD_LOW     equ    $b22d
;CD_MAX_F1_PER_TEST_THD_HIGH    equ    $0008
;CD_MIN_F1_PER_TEST_THD_LOW     equ    $e5a1
;CD_MIN_F1_PER_TEST_THD_HIGH    equ    $0006
;CD_MAX_F2_PER_TEST_THD_LOW     equ    $5916
;CD_MAX_F2_PER_TEST_THD_HIGH    equ    $0004
;CD_MIN_F2_PER_TEST_THD_LOW     equ    $b439
;CD_MIN_F2_PER_TEST_THD_HIGH    equ    $0003

CD_MAX_F1_PER_THD_A_LOW        equ    $e042
CD_MAX_F1_PER_THD_A_HIGH       equ    $0007
CD_MIN_F1_PER_THD_A_LOW        equ    $845a
CD_MIN_F1_PER_THD_A_HIGH       equ    $0007
CD_MAX_F2_PER_THD_A_LOW        equ    $10e5
CD_MAX_F2_PER_THD_A_HIGH       equ    $0004
CD_MIN_F2_PER_THD_A_LOW        equ    $ef9e
CD_MIN_F2_PER_THD_A_HIGH       equ    $0003
CD_MAX_F1_PER_THD_B_LOW        equ    $1168
CD_MAX_F1_PER_THD_B_HIGH       equ    $0008
CD_MIN_F1_PER_THD_B_LOW        equ    $599a
CD_MIN_F1_PER_THD_B_HIGH       equ    $0007
CD_MAX_F2_PER_THD_B_LOW        equ    $228f
CD_MAX_F2_PER_THD_B_HIGH       equ    $0004
CD_MIN_F2_PER_THD_B_LOW        equ    $dfbe
CD_MIN_F2_PER_THD_B_HIGH       equ    $0003

CD_APS_METRIC_SCALE_LOW        equ    $0000
CD_APS_METRIC_SCALE_HIGH       equ    $0258
CD_MAX_APS_METRIC_LOW          equ    $0000
CD_MAX_APS_METRIC_HIGH         equ    $0024
; 0.92-0.98
CD_APS_HIGH_THD_LOW            equ    $a3d7
CD_APS_HIGH_THD_HIGH           equ    $7d70
CD_APS_LOW_THD_LOW             equ    $8f5c
CD_APS_LOW_THD_HIGH            equ    $75c2
; 0.921-0.981
;CD_APS_HIGH_THD_LOW            equ    $6873
;CD_APS_HIGH_THD_HIGH           equ    $7d91
;CD_APS_LOW_THD_LOW             equ    $53f8
;CD_APS_LOW_THD_HIGH            equ    $75e3

CD_TOTAL_METRIC_THD_LOW        equ    $4000
;CD_TOTAL_METRIC_THD_HIGH       equ    $003b    ; 59
;CD_TOTAL_METRIC_THD_HIGH       equ    $0039     ; 57
CD_TOTAL_METRIC_THD_HIGH       equ    $0037     ; 55
CD_OFF_THD_FACTOR              equ    $2000



;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_pshf.asm
;
; Description:  Assembly module for calculating the APS parameter
;
; Modules
;    Included:  SHFPER_CAS
;              _cshift_period               
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

     SECTION CAS_DETECT
 
     GLOBAL  SHFPER_CAS
     
     include "cas_equ.asm"

     org     p:
     
;********************************************************************
;
; Module Name:  SHFPER_CAS
;
; Description:  Calculates the period shift and aps parameter.
;
; Functions 
;      Called:  _cshift_period (local to this file)
;
; Calling 
; Requirements: This function should be called after the
;               the call to PERIOD_CAS  routine.
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

SHFPER_CAS:
; store period in buffer and get max period and min period
     move   x:cd_f1_period,b
     move   x:(cd_f1_period+1),b0
     move   #(cd_f1_per_buf+2*(CD_MIN_PERIOD_TIME-1)+1),r0
     move   #(cd_f1_per_buf+2*(CD_MIN_PERIOD_TIME-2)+1),r2
     move   #cd_f1_max_per,r1
     move   #cd_f1_min_per,r3
     move   b,x:(r1)+
     move   b0,x:(r1)-                     ; cd_f1_max_per = cd_f1_period
     move   b,x:(r3)+
     move   b0,x:(r3)-                     ; cd_f1_min_per = cd_f1_period
     jsr    _cshift_period                 ; calculate period shift
     move   x:cd_f1_period,a
     move   x:(cd_f1_period+1),a0
     move   a,x:cd_f1_per_buf
     move   a0,x:(cd_f1_per_buf+1)         ; cd_f1_per_buf[0]=cd_f1_period

     asr    b
     move   b,x:cd_temp0
     move   b0,x:cd_temp1                  ; temp0|temp1 = f1_per_shift >> 1

     move   x:cd_f2_period,b
     move   x:(cd_f2_period+1),b0
     move   #(cd_f2_per_buf+2*(CD_MIN_PERIOD_TIME-1)+1),r0
     move   #(cd_f2_per_buf+2*(CD_MIN_PERIOD_TIME-2)+1),r2
     move   #cd_f2_max_per,r1
     move   #cd_f2_min_per,r3
     move   b,x:(r1)+
     move   b0,x:(r1)-                     ; cd_f2_max_per = cd_f2_period
     move   b,x:(r3)+
     move   b0,x:(r3)-                     ; cd_f2_min_per = cd_f2_period
     jsr    _cshift_period                 ; calculate period shift
     move   x:cd_f2_period,a
     move   x:(cd_f2_period+1),a0
     move   a,x:cd_f2_per_buf
     move   a0,x:(cd_f2_per_buf+1)         ; cd_f2_per_buf[0]=cd_f2_period

     asr    b                              ; b = f2_per_shift >> 1
     move   x:cd_temp0,a
     move   x:cd_temp1,a0                  ; get a = temp0|temp1
     add    b,a
     move   a,x:cd_aps
     move   a0,x:cd_aps+1                  ; cd_aps = (f1_per_shift>>1) +
                                           ; (f2_per_shift>>1)

     rts

;********************************************************************
;
; Module Name:  _cshift_period
;
; Description:  Calculates the avg period shift and aps parameter.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: input : r0=ptr to per_buf[CD_MIN_PERIOD_TIME-1]  
;                       r2=ptr to per_buf[CD_MIN_PERIOD_TIME-2]  
;                       r1=ptr to max_per                        
;                       r3=ptr to min_per                        
;               output: b = period shift                     
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
; DO loops:     1, but not nested
;
; REP loops:    3
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

_cshift_period

     move   x:(r3)+,b
     move   x:(r3)-,b0                     ; b = min_per
     move   x:(r2)-,x0

     do     #CD_MIN_PERIOD_TIME-1,_cshper_loop 
     move   x:(r2)-,a
     move   x0,a0
     move   a0,x:(r0)-
     move   a,x:(r0)-                      ; a = period[i]
     cmp    b,a
     bge    _cshper_com                    ; if a >= b, jump
     move   a,x:(r3)+
     move   a0,x:(r3)-                     ; save min_per
_cshper_com
     move   x:(r1)+,b
     move   x:(r1)-,b0                     ; b = max_per
     cmp    b,a
     ble    _cshper_com1                   ; if a <= b, jump
     move   a,x:(r1)+
     move   a0,x:(r1)-                     ; save max_per
_cshper_com1
     move   x:(r3)+,b
     move   x:(r3)-,b0                     ; b = min_per
     move   x:(r2)-,x0
_cshper_loop

     move   x:(r1)+,a
     move   x:(r1)-,a0                     ; a=max_per
     cmp    #0,a
     ble    _cshper_com2                   ; a<=0? yes, jump
     rep    #8
     asl    a
_shf_max_per_lf
     rnd    a                              ; a1 = round(max_per<<8)
     move   a1,y0                          ; y0 = a1
     move   x:(r3)+,b
     move   x:(r3)-,b0
     rep    #8
     asl    b
_shf_min_per_lf
     rnd    b                              ; b1 = round(min_per<<8)
     bfclr  #$0001,sr
     rep    #16
     div    y0,b                           ; b0 = b/a
_max_min_per_ratio
     move   b0,b
     rts
_cshper_com2
     clr    b
     rts


     ENDSEC

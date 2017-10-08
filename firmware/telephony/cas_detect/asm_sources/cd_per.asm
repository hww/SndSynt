;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_per.asm
;
; Description:  Calculates the f1period and f2period
;
; Modules
;    Included:  PERIOD_CAS
;              _calc_lags
;              _find_peaks
;              _calc_peak_adjust               
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        
        SECTION  CAS_DETECT
  
        GLOBAL   PERIOD_CAS 
        
        include  "cas_equ.asm"
        include  "portasm.h"

        org      p:

;********************************************************************
;
; Module Name:  PERIOD_CAS
;
; Description:  Calculates the f1 period and f2 period.
;
; Functions 
;      Called:  _calc_lags, _find_peaks (local to this file)
;               _calc_peak_adjust (local to this file)
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

PERIOD_CAS:

     move   #cd_f1_buf,r0
     move   #cd_lags,r2
     jsr    _calc_lags                 ; calculate autocorrelation
     jsr    _find_peaks                ; find peak, return total peak in x0
     cmp    #CD_F1_NUM_PEAKS,x0
     bne    _percas_f0                 ; peak number ok? no, jump
     move   x:(cd_peak_buf+1*CD_F1_NUM_PEAKS-1),x0
     jsr    _calc_peak_adjust          ; a = exact peak location
     move   a,x:cd_f1_period
     move   a0,x:(cd_f1_period+1)      ; f1_period=last peak location
     move   x:cd_peak_buf,x0
     jsr    _calc_peak_adjust          ; a = first exact peak location
     move   x:cd_f1_period,b
     move   x:(cd_f1_period+1),b0      ; b = last peak location
     sub    a,b                        ; b = last peak - first peak
     move   b1,y1
     move   b0,y0                      ; y = b
     move   #CD_F1_NUM_PEAKS_CONST,x0  ; x0 = F1_NUM_PEAKS_CONST
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                    ; a=x0*y
     move   a,x:cd_f1_period
     move   a0,x:(cd_f1_period+1)      ; f1_period = a
     bra    _percas_f1
_percas_f0
     move   #0,x:cd_f1_period
     move   #0,x:(cd_f1_period+1)      ; set f1_period to zero
_percas_f1

     move   #cd_f2_buf,r0
     move   #cd_lags,r2
     jsr    _calc_lags                 ; calculate autocorrelation
     jsr    _find_peaks                ; find peak, return total peak in x0
     cmp    #CD_F2_NUM_PEAKS,x0
     bne    _percas_f2                 ; peak number ok? no, jump
     move   x:(cd_peak_buf+1*CD_F2_NUM_PEAKS-1),x0
     jsr    _calc_peak_adjust          ; a = exact peak location
     move   a,x:cd_f2_period
     move   a0,x:cd_f2_period+1        ; f2_period=last peak location
     move   x:cd_peak_buf,x0
     jsr    _calc_peak_adjust          ; a = first exact peak location
     move   x:cd_f2_period,b
     move   x:cd_f2_period+1,b0        ; b = last peak location
     sub    a,b                        ; b = last peak - first peak
     move   b1,y1
     move   b0,y0                      ; y = b
     move   #CD_F2_NUM_PEAKS_CONST,x0  ; x0 = F2_NUM_PEAKS_CONST
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                    ; a=x0*y
     move   a,x:cd_f2_period
     move   a0,x:(cd_f2_period+1)      ; f2_period = a
     bra    _percas_f3
_percas_f2
     move   #0,x:cd_f2_period
     move   #0,x:(cd_f2_period+1)      ; set f2_period to zero
_percas_f3

     rts

;********************************************************************
;
; Module Name:  _calc_lags
;
; Description:  Calculates the autocorrelation.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: r0: input buffer
;               r2: lag buffer
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
; DO loops:     2, but not nested
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

_calc_lags

     move   r0,r1                      ; duplicate r0(input_buffer) to r1
     move   #CD_CORR_OFFSET,n
     move   #cd_corr_sig,r3            ; r3 ptr to cd_corr_sig
     move   x:(r1)+n,x0                ; dummy read for update 
                                       ; r1+=cd_corr_offset
     move   #CD_CORR_SIZE,lc
 if V2_WORKAROUND==1
     doslc  _clags_loop1
 else
     do     lc,_clags_loop1
 endif
     move   x:(r1)+,y0
     move   y0,x:(r3)+                 ; *corr_sig = *r1 >> lags_shift_bits
_clags_loop1

; run correlation
     move   #CD_NUM_LAGS,b
     move   #CD_CORR_SIZE,b0
     move   #cd_corr_sig,n             ; r3 = cd_corr_sig
     move   r0,r1                      ; duplicate r0(input buffer) to r1
     move   #0,a                       ; clr a for later addition
     move   n,r3
     move   #0,y1
     
_clags_loop2
     move   x:(r1)+,y0 x:(r3)+,x0
     do     b0,_clags_inloop
     mac    x0,y0,a  x:(r1)+,y0  x:(r3)+,x0
_clags_inloop
     move   a,x:(r2)+
     move   a0,x:(r2)+                 ; store a to r2(lag_buffer)

     move   n,r3
     dec    b   x:(r0)+,y0             ; check count, dummy move
     tgt    y1,a  r0,r1     
     bne    _clags_loop2               ; cd_temp0==0? no, jump

     rts


;********************************************************************
;
; Module Name:  _find_peaks
;
; Description:  Find the autocorrelation peaks.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: xo: Number of peaks
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

_find_peaks
     move   #cd_peak_buf,r2
     move   #0,x0

     do     #(CD_MAX_NUM_PEAKS),_peak_buf_zero
     move   x0,x:(r2)+                 ; init cd_peak_buf to zero
_peak_buf_zero

     move   #cd_peak_buf,r2            ; r2 = cd_peak_buf
 ;    move   #CD_START_PEAK_SEARCH,x:cd_temp1 
     move   #CD_START_PEAK_SEARCH,x0   ; cd_temp1 = START_PEAK_SEARCH
     move   #(cd_lags+2*CD_START_PEAK_SEARCH+1),r0
                                       ; r0 = cd_lags+2*START_PEAK_SEARCH+1
     move   #2,n

_find_peaks_loop1
     move   r0,r1                      ; duplicate the lag ptr
     move   r2,y0
     cmp    #(cd_peak_buf+1*CD_MAX_NUM_PEAKS),y0
     bge    _find_peaks_end            ; cd_temp >= MAX_NUM_PEAKS? yes,end
     cmp    #(1*CD_END_PEAK_SEARCH+1),x0
     bge    _find_peaks_end            ; cd_temp1 >= END_PEAK_SEARCH+1? yes, end

     move   x:(r1)-,y0
     move   x:(r1)-,a
     move   y0,a0                      ; *cd_lags = a
     cmp    #0,a
     ble    _fps_next                  ; a<=0? yes, jump
     move   x:(r1)-,y0
     move   x:(r1),b
     move   y0,b0                      ; *(cd_lag-1) = b
     cmp    b,a
     ble    _fps_next                  ; a<=b? jump
     lea    (r1)+n                     ; increment ptr by 2
     lea    (r1)+n                     ; increment ptr by 2
     move   x:(r1)+,b
     move   x:(r1)+,b0                 ; *(cd_laf+1) = b
     cmp    b,a
     blt    _fps_next                  ; a<b? jump

     move   x0,x:(r2)+                 ; *r2++=cd_temp1
_fps_next
     lea    (r0)+n                     ; update r0 ptr by 2
     inc    x0
     bra    _find_peaks_loop1

_find_peaks_end
     move   r2,x0
     move   #cd_peak_buf,y1
     sub    y1,x0                      ; a1 = peak index
     rts


;********************************************************************
;
; Module Name:  _calc_peak_adjust
;
; Description:  Fractional adjustment of first and last peak.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: Output : a = fractional adjustment.
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
; REP loops:    4
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

_calc_peak_adjust:

     move   x0,x:cd_temp0
     dec    x0
     dec    x0
     asl    x0
     move   #cd_lags,y1
     add    y1,x0
     move   x0,r0                      ; r0 = cd_lags + (cd_temp0 - 2)*2

     move   #cd_sum_coef,r2
     move   #cd_w_sum,r1
     move   #cd_sum,r3
     
     move   #0,b
     move   b,x:(r1)+
     move   b,x:(r1)-
     move   b,x:(r3)+
     move   b,x:(r3)-

     move   x:(r0)+,a
     move   x:(r0)+,a0                 ; a = *(cd_lags+(cd_temp0-2+lc)*2)
     move   x:(r2)+,x0                  ; x0 = sum coef

     do     #5,_cpadj_loop0
     cmp    #0,a
     ble    _cpadj_next                ; a<=0? yes,jump

     move   x:(r3)+,b
     move   x:(r3)-,b0
     add    a,b

     move   a1,y1
     move   a0,y0                      ; y = a
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a  b,x:(r3)+         ; a=x0*y
     move   b0,x:(r3)-                 ; cd_sum += a

     move   x:(r1)+,b
     move   x:(r1)-,b0
     add    a,b
     move   b,x:(r1)+
     move   b0,x:(r1)-          ; cd_w_sum += a

_cpadj_next
     move   x:(r0)+,a
     move   x:(r0)+,a0                  ; a = *(cd_lags+(cd_temp0-2+lc)*2)
     move   x:(r2)+,x0                  ; x0 = sum coef
_cpadj_loop0

     move   #0,r0
     tst    b
     rep     #31
     norm   r0,b 
_norm_w_sum
     move   r0,a
     abs    a
     move   a,x:cd_temp1               ; cd_temp1 = shift count for cd_w_sum
     move   b,x:cd_w_sum
     move   b0,x:(cd_w_sum+1)          ; cd_w_sum is normalized

     move   x:cd_sum,a
     move   x:(cd_sum+1),a0
     move   #0,r0
     tst    a
     rep    #31
     norm   r0,a
_norm_cd_sum
     move   r0,b
     abs    b
     move   b,x:cd_temp2               ; cd_temp2 = shift count for cd_sum
     move   a,x:cd_sum
     move   a0,x:(cd_sum+1)            ; cd_sum is normalized

     move   #0,x0                      ; init shift count
     move   x:cd_w_sum,b
     move   x:(cd_w_sum+1),b0
     cmp    a,b
     ble    _cpadj_next1               ; cd_w_sum <= cd_sum
     incw   x0                         ; inc shift count
     asr    b
_cpadj_next1

     rnd    b                          ; round w_sum
     rnd    a                          ; round sum
     move   a1,y0
     bfclr  #$0001,sr
     rep     #16
     div    y0,b                       ; b0 = w_sum/sum
_div_w_sum
     nop
     move   b0,b

     move   x:cd_temp1,y1
     add    #12,y1
     sub    x0,y1
     move   x:cd_temp2,x0
     sub    x0,y1                      ; total shift in y1
     move   y1,a

     cmp    #0,a
     blt    _cpadj_next2
     rep    a
     asr    b                          ; shift the fract part to xx.xx format
_shf_rt_b
     bra    _cpadj_next3
_cpadj_next2
     abs    a
     rep     a
     asl    b                          ; shift the fract part to xx.xx format
_shf_lf_b

_cpadj_next3

     move   x:cd_temp0,a
     add    b,a
     move   #CD_PEAK_COEF,b
     sub    b,a
     rts

     ENDSEC

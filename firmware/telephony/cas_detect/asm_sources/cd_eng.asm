;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_eng.asm
;
; Description:  Calculate the hanning windowed energy of the high
;                 pass filtered, f1 bandpass and f2 bandpass filtered
;                 output for recent 40 samples.
;
; Modules
;    Included:  ENG_CAS
;              _cd_eng_s0               
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        

     SECTION CAS_DETECT

     GLOBAL  ENG_CAS
     
     include "cas_equ.asm"
     include "portasm.h"
     
     org     p:

;********************************************************************
;
; Module Name:  ENG_CAS
;
; Description:  Calcuate the hanning windowed energy of 40 samples
;
; Functions 
;      Called:  _cd_eng_s0 (local to this file)
;
; Calling 
; Requirements: This function should be called after the
   ;            the call to FILTER_CAS  routine.
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

ENG_CAS:
     move   #cd_window_imag,r3
     move   #cd_f1_buf,r1
     move   #cd_f1_bpf_pw,r0
     move   #0,x:cd_f1_bpf_pw
     move   #0,x:cd_f1_bpf_pw+1        ; cd_f1_bpf_pw = 0
     move   #CD_WSCALE_BIT1,x:cd_temp1
     jsr    _cd_eng_s0                   ; calculate power

     move   #cd_window_imag,r3
     move   #(cd_f2_buf+1*CD_F2_DELAY),r1
     move   #cd_f2_bpf_pw,r0
     move   #0,x:cd_f2_bpf_pw
     move   #0,x:cd_f2_bpf_pw+1        ; cd_f2_bpf_pw = 0
     move   #CD_WSCALE_BIT,x:cd_temp1
     jsr    _cd_eng_s0                   ; calculate power

     move   #cd_window_imag,r3
     move   #(cd_sig_buf+1*CD_SIG_DELAY),r1
     move   #cd_sig_pw,r0
     move   #0,x:cd_sig_pw
     move   #0,x:cd_sig_pw+1           ; cd_sig_pw = 0
     move   #CD_WSCALE_BIT,x:cd_temp1
                                       ; calculate power
                                       
;********************************************************************
;
; Module Name:  _cd_eng_s0
;
; Description:  Calculates the energy.
;
; Functions 
;      Called:  None
;
; Calling 
; Requirements: To be called from ENG_CAS
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

_cd_eng_s0
     move   #CD_WINDOW_SIZE,lc
     move   x:(r1)+,y0 
     move   x:(r3)+,x0
     move   #0,n
     move   x:(r0),b
     
 if V2_WORKAROUND==1
     doslc  _cd_eng_s0_loop
 else
     do     lc,_cd_eng_s0_loop
 endif

     mpy    x0,y0,b    b,x:(r0)+n       ; b = *(cd_f1_buf++) x 
                                        ;  *(cd_widow_imag)
     move   b0,y1                       ;Double precision multiplication
     move   b1,y0                       ;of input sample. hi*hi +2*hi*lo
     mpysu  y0,y1,a                     ;lo is unsigned.lo*lo product is
     asl    a          x:(r3)+,x0       ;neglected
     move   a1,y1
     move   a2,a
     move   y1,a0
     mac    y0,y0,a    x:(r0)+,b        ; a=b*b
     move   x:(r0),b0
     add    a,b  x:(r1)+,y0 
     move   b0,x:(r0)-                  ; *(r0) = b
_cd_eng_s0_loop

     move   b,x:(r0)
     move   b1,y1
     move   b0,y0
     move   #CD_WINDOW_SCALE,x0
     mpysu  x0,y0,a
     move   a1,y0
     move   a2,a
     move   y0,a0
     mac    y1,x0,a                     ; a = *(r0) x CD_WINOW_SCALE
     move   x:cd_temp1,x0
     do     x0,wscale_shift_loop
     asr    a                           ; shift one bit for wscale_bit
wscale_shift_loop
     move   a,x:(r0)+
     move   a0,x:(r0)-
 
     rts


     ENDSEC

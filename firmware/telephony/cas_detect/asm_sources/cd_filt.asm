;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    cd_filt.asm
;
; Description:  Biquad Filter function.
;
; Modules
;    Included:  FILTER_CAS
;
; Author(s):    Andy Lam
;
; Date:         15/07/1998
;
;********************************************************************        


      SECTION CAS_DETECT

      GLOBAL  FILTER_CAS
      
      include "cas_equ.asm"

      org     p:
      
;********************************************************************
;
; Module Name:  FILTER_CAS
;
; Description:  High pass and two bandpass filtering.
;
; Functions 
;      Called:  BIQUAD and BIQUAD1
;
; Calling 
; Requirements: Input samples should be pointed by register r2 before
;               the call to this function.
; 
;               This function should be called after the
;               the call to CAS_DETECT_INIT  routine.
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
      

FILTER_CAS:

; update signal buffer
     move   #(cd_sig_buf+1*CD_BUFF_SIZE-1-1*CD_FRAME_RATE),r0
     move   #(cd_sig_buf+1*CD_BUFF_SIZE-1),r1
     move   #(CD_BUFF_SIZE-CD_FRAME_RATE),y0
     do     y0,_cd_floop1
     move   x:(r0)-,x0
     move   x0,x:(r1)-
_cd_floop1

; update f1 buffer
     move   #(cd_f1_buf+1*CD_BUFF_SIZE-1-1*CD_FRAME_RATE),r0
     move   #(cd_f1_buf+1*CD_BUFF_SIZE-1),r1
     do     y0,_cd_floop2
     move   x:(r0)-,x0
     move   x0,x:(r1)-
_cd_floop2

; update f2 buffer
     move   #(cd_f2_buf+1*CD_BUFF_SIZE-1-1*CD_FRAME_RATE),r0
     move   #(cd_f2_buf+1*CD_BUFF_SIZE-1),r1
     do     y0,_cd_floop3
     move   x:(r0)-,x0
     move   x0,x:(r1)-
_cd_floop3


; get decimation and filtering
     move   #INPUT_BUF_SIZE,x:cd_temp0      
                                        ; cd_temp0 = input buffer counter
     move   #CD_DEC_RATIO,x:cd_temp1    
                                        ; cd_temp1 = decimation counter
     move   #(cd_sig_buf+1*CD_FRAME_RATE-1),x:cd_temp2 
                                        ; cd_temp2 = sig_buf address ptr
     move   #(cd_f1_buf+1*CD_FRAME_RATE-1),x:cd_temp3  
                                        ; cd_temp3 = f1_buf address ptr
     move   #(cd_f2_buf+1*CD_FRAME_RATE-1),x:cd_temp4  
                                        ; cd_temp4 = f2_buf address ptr
_cd_fmainl

     move   x:(r2)+,y1                  ; get the input data
     move   y1,x:cd_temp6               ; store to cd_temp6 r
     asr    y1                          ; shift right to prevent over flow
     move   y1,x:cd_temp5               ; store to cd_temp5 r

     decw   x:cd_temp1                  ; decimation ok?
     jeq    _cd_fdec_ok                 ; yes

     ; highpass filter output to b
     move   #cd_hpf_z,r0                ; get highpass delay state ptr to r0
     move   #cd_hpf_coef_imag,r3        ; get highpass coef ptr to r3
     jsr    BIQUAD1                     ; multiply actutal coef


     ; f1 filter output to b
     move   x:cd_temp6,y1               ; get input sample to y1
     move   #cd_f1_z,r0                 ; get f1 delay state ptr to r0
     move   #cd_f1_bpf_coef_8000_imag,r3
                                        ; get f1 coef ptr to r3
     jsr    BIQUAD1                     ; multiply actutal coef


     ; f2 filter output to b
     move   x:cd_temp5,y1               ; get input sample to y1
     move   #cd_f2_z,r0                 ; get f2 delay state ptr to r0
     move   #cd_f2_bpf_coef_8000_imag,r3
                                        ; get f2 coef ptr to r3
     jsr    BIQUAD                      ; multiply coef/2


     bra    _cd_fcommon

_cd_fdec_ok
     move   #CD_DEC_RATIO,x:cd_temp1    ; update decimation counter

     ; highpass filter output to b
     move   x:cd_temp5,y1               ; get input sample to y1
     move   #cd_hpf_z,r0                ; get highpass delay state ptr to r0
     move   #cd_hpf_coef_imag,r3        ; get highpass coef ptr to r3
     jsr    BIQUAD1                     ; multiply actutal coef


     move   x:cd_temp2,r0               ; get sig_buf ptr to r0
     move   x:cd_temp6,y1               ; get input sample to y1
     move   b,x:(r0)-                   ; store output t0 sig_buf
     move   r0,x:cd_temp2               ; update sig_buf ptr

     move   #cd_f1_z,r0                 ; get f1 delay state ptr to r0
     move   #cd_f1_bpf_coef_8000_imag,r3
                                        ; get f1 bpf coef ptr to r3
     jsr    BIQUAD1                     ; multiply actutal coef


     move   x:cd_temp3,r0               ; get f1_buf ptr to r0
     move   x:cd_temp5,y1               ; get input sample to y1
     move   b,x:(r0)-                   ; store output to f1_buf
     move   r0,x:cd_temp3               ; update f1_buf ptr

     move   #cd_f2_z,r0                 ; get f2 delay state ptr to r0
     move   #cd_f2_bpf_coef_8000_imag,r3
                                        ; get f2 bpf coef ptr to r3
     jsr    BIQUAD                      ; multiply coef/2


     move   x:cd_temp4,r0               ; get f2_buf ptr to r0
     nop
     move   b,x:(r0)-                   ; store output to f2_buf
     move   r0,x:cd_temp4               ; update f2_buf ptr

_cd_fcommon
     decw   x:cd_temp0                  ; cd_temp0--;
     jgt    _cd_fmainl                  ; if cd_temp0 > 0 fo to 
                                        ;  process next sample
     rts

     ENDSEC

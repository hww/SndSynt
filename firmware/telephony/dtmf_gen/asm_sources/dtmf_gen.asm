;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2001 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    dtmf_gen.asm
;
; Description:  Assembly module for DTMF generation
;
; Modules
;    Included:  dtmf_gen
;
; Author(s):    Sudarshan & Mahesh
;
; Date:         11. Jul. 2001
;
;********************************************************************

;********************************************************************
;
; Module Name:  Fdtmf_gen
;
; Description:  
;  This function generates the DTMF tone using two digital oscillators, 
;  one producing each of the low group and high group frequencies. The
;  output is the sum of the outputs of the two oscillators and this 
;  also computes the updated states of the oscillator. The tone burst 
;  duration can either be specified by the user, or can be set to a 
;  default value.
;
; Input(s):     DTMF Handle pointed by R2.
;
; Output(s):    dtmf sample in Y0
;
; Functions 
;      Called:  None  
;
; Calling 
; Requirements: 1. r2 -> Pointer to DTMF Handle.
;
; C Callable:   Yes
;
; Reentrant:    Yes
;
; Globals:      None
;
; Statics:      None
;
; Registers 
;      Changed: a0   b0    x0  y0     sr
;               a1   b1        y1     
;               a2   b2                             
;               r0   r1    r2  n
;
; DO loops:     None
;
; REP loops:    None
;
; Environment:  MetroWerks on PC
;
; Reference:    HAWK code on UNIX
;
; Cycle Count:  13 + 17*(Ton*T)+ 3*(Toff*T),
;               [where T = Fs/1000, Fs in Hz].
;
; Special
;     Issues:   None
;
;******************************Change History************************
;
;    DD/MM/YY     Code Ver     Description      Author(s)
;    --------     --------     -----------      ---------
;    18/03/96      0.1        Module created    Omkar.S.P
;    10/04/96      1.0        Reviewed &        Omkar.S.P
;                             Baselined                  
;    11/07/01      2.0        Changed for       Sudarshan &
;                             Multichannel      Mahesh                   
;
;********************************************************************

ONDURATION_OFFSET         EQU   0
OFFDURATION_OFFSET        EQU   1
TEMPONDURATION_OFFSET     EQU   2  
TEMPOFFDURATION_OFFSET    EQU   3   
SAMPLERATE_OFFSET         EQU   4
COEFBUF_OFFSET            EQU   5
KEYGENERATED_OFFSET       EQU  13 
AMP_OFFSET                EQU  14 
SH1_OFFSET                EQU  15 
SH2_OFFSET                EQU  16 
SL1_OFFSET                EQU  17 
SL2_OFFSET                EQU  18 
AL2_OFFSET                EQU  19 
AH2_OFFSET                EQU  20 
RINDX_OFFSET              EQU  21 
CINDX_OFFSET              EQU  22 

        SECTION  DTMF_GEN

        GLOBAL   Fdtmf_gen

        org p:

Fdtmf_gen

; **** Fetch the arguements ****

    move    r2,n
    move    #AH2_OFFSET,r0
    move    #AL2_OFFSET,r1
    move    x:(r0+n),y0                   ; y0 = AH/2
    move    x:(r1+n),x0                   ; x0 = AL/2
        
    move    #SL1_OFFSET,r0
    move    #SH1_OFFSET,r1
    lea     (r0)+n        
    lea     (r1)+n        

; **** Arguement fetching ends ****

    move    #-1,n
    move    x:(r0)+,y1                    ; Get sl1 in b,increment r0, 
                                          ;  r0 now points to lo_buf+1
    mpy     y1,x0,b                       ; Save sl1 in y1 for update,
                                          ;  (al/2*sl1) in b
    move    x:(r0),a                      ; Get sl2 in a from 
                                          ; x:(lo_buf+1),
    asl     b            y1,x:(r0)+n
    sub     a,b                           ; term1=(al*sl1-sl2) in b,
                                          ;  update sl2_up = sl1 in 
                                          ;  x:(lo_buf+1),
                                          ;  increment r0 to lo_buf
    move    b,x:(r0)                      ; Update sl1_up=term1 in
                                          ; x:(lo_buf)
    move    x:(r1)+,y1                    ; Get sh1 in a,incrment r1 
                                          ;  to hi_buf+1
    mpy     y1,y0,a                       ; Save sh1 in x1 for update,
                                          ;  (ah/2*sh1) in a
    move    x:(r1),b                      ; Get sh2 in b from
                                          ; x:(hi_buf+1)
    asl     a          
    sub     b,a          y1,x:(r1)+n      ; term2=(ah*sh1-sh2) in a,
                                          ; update sh2_up=sh1 from x1 in
                                          ; x:(hi_buf_+1),increment  r1
                                          ; to hi_buf
    move    a,x:(r1)                      ; Update sh1_up=term2 from a
                                          ;  in x:(hi_buf)
    move    x:(r0),y1                     ; Get term1 in y1 to add
    add     y1,a                          ; dtone=term1+term2 in a
        
    move    a,y0

    rts
        
    ENDSEC

;****************************** End of File ****************************
